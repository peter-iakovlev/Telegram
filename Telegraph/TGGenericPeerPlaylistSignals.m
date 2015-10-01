#import "TGGenericPeerPlaylistSignals.h"

#import "ActionStage.h"

#import "TGMusicPlayerPlaylist.h"
#import "TGSharedMediaCacheSignals.h"
#import "TGMessage.h"

@interface TGGenericPeerPlaylistHelper : NSObject <ASWatcher>
{
    int64_t _peerId;
    bool _important;
    int32_t _atMessageId;
    void (^_updated)(TGMusicPlayerPlaylist *);
    id<SDisposable> _cachedMediaDisposable;
    
    NSMutableArray *_currentMessages;
    NSMutableDictionary *_currentItemKeyAliases;
}

@property (nonatomic, strong) ASHandle *actionHandle;

@end

@implementation TGGenericPeerPlaylistHelper

- (NSArray *)sortedMessages:(NSArray *)array
{
    return [array sortedArrayUsingComparator:^NSComparisonResult(TGMessage *message1, TGMessage *message2)
    {
        NSTimeInterval date1 = message1.date;
        NSTimeInterval date2 = message2.date;
        
        if (ABS(date1 - date2) < DBL_EPSILON)
        {
            if (message1.mid > message2.mid)
                return NSOrderedDescending;
            else
                return NSOrderedAscending;
        }
        
        return date1 > date2 ? NSOrderedDescending : NSOrderedAscending;
    }];
}

- (NSArray *)itemListFromMessages:(NSArray *)messages
{
    NSMutableArray *items = [[NSMutableArray alloc] init];
    for (TGMessage *message in messages)
    {
        TGMusicPlayerItem *item = [TGMusicPlayerItem itemWithMessage:message];
        if (item != nil)
            [items addObject:item];
    }
    return items;
}

- (instancetype)initWithPeerId:(int64_t)peerId important:(bool)important atMessageId:(int32_t)atMessageId updated:(void (^)(TGMusicPlayerPlaylist *))updated
{
    self = [super init];
    if (self != nil)
    {
        _peerId = peerId;
        _important = important;
        _atMessageId = atMessageId;
        _updated = [updated copy];
        
        _currentMessages = [[NSMutableArray alloc] init];
        _currentItemKeyAliases = [[NSMutableDictionary alloc] init];
        
        _actionHandle = [[ASHandle alloc] initWithDelegate:self];
        
        __weak TGGenericPeerPlaylistHelper *weakSelf = self;
        
        _cachedMediaDisposable = [[[TGSharedMediaCacheSignals cachedMediaForPeerId:peerId itemType:TGSharedMediaCacheItemTypeAudio important:_important] filter:^bool (id next)
        {
            if ([next respondsToSelector:@selector(objectAtIndex:)])
            {
                for (TGMessage *message in next)
                {
                    if (message.mid == atMessageId)
                        return true;
                }
            }
            
            return false;
        }] startWithNext:^(NSArray *messages)
        {
            [ActionStageInstance() dispatchOnStageQueue:^
            {
                __strong TGGenericPeerPlaylistHelper *strongSelf = weakSelf;
                if (strongSelf != nil)
                {
                    [strongSelf replaceMessages:messages];
                }
            }];
        } completed:^
        {
            [ActionStageInstance() watchForPaths:@[
                [NSString stringWithFormat:@"/tg/conversation/(%lld)/messages", _peerId],
                [NSString stringWithFormat:@"/tg/conversation/(%lld)/messagesChanged", _peerId],
                [NSString stringWithFormat:@"/tg/conversation/(%lld)/messagesDeleted", _peerId]
            ] watcher:self];
        }];
    }
    return self;
}

- (void)dealloc
{
    [_cachedMediaDisposable dispose];
    
    [_actionHandle reset];
    [ActionStageInstance() removeWatcher:self];
}

- (void)replaceMessages:(NSArray *)messages
{
    [_currentItemKeyAliases removeAllObjects];
    [_currentMessages removeAllObjects];
    
    [_currentMessages addObjectsFromArray:[self sortedMessages:messages]];
    
    if (_updated)
    {
        _updated([[TGMusicPlayerPlaylist alloc] initWithItems:[self itemListFromMessages:_currentMessages] itemKeyAliases:[[NSDictionary alloc] initWithDictionary:_currentItemKeyAliases]]);
    }
}

- (void)addMessages:(NSArray *)messages
{
    NSMutableSet *currentMessageIds = [[NSMutableSet alloc] init];
    for (TGMessage *message in _currentMessages)
    {
        [currentMessageIds addObject:@(message.mid)];
    }
    
    bool added = false;
    for (TGMessage *message in messages)
    {
        if (![currentMessageIds containsObject:@(message.mid)])
        {
            [currentMessageIds addObject:@(message.mid)];
            if ([TGMusicPlayerItem itemWithMessage:message] != nil)
            {
                [_currentMessages addObject:message];
                added = true;
            }
        }
    }
    
    if (added)
    {
        NSArray *sortedMessages = [self sortedMessages:_currentMessages];
        [_currentMessages removeAllObjects];
        [_currentMessages addObjectsFromArray:sortedMessages];
        if (_updated)
        {
            _updated([[TGMusicPlayerPlaylist alloc] initWithItems:[self itemListFromMessages:_currentMessages] itemKeyAliases:[[NSDictionary alloc] initWithDictionary:_currentItemKeyAliases]]);
        }
    }
}

- (void)deleteMessagesWithIds:(NSArray *)messageIds
{
    NSMutableSet *idsSet = [[NSMutableSet alloc] init];
    for (NSNumber *nMessageId in messageIds)
    {
        [idsSet addObject:nMessageId];
    }
    
    for (NSInteger i = 0; i < (NSInteger)_currentMessages.count; i++)
    {
        if ([idsSet containsObject:@(((TGMessage *)_currentMessages[i]).mid)])
        {
            [_currentMessages removeObjectAtIndex:i];
            i--;
        }
    }
    
    if (_updated)
    {
        _updated([[TGMusicPlayerPlaylist alloc] initWithItems:[self itemListFromMessages:_currentMessages] itemKeyAliases:[[NSDictionary alloc] initWithDictionary:_currentItemKeyAliases]]);
    }
}

- (void)remapMessages:(NSDictionary *)messages
{
    for (NSInteger i = 0; i < (NSInteger)_currentMessages.count; i++)
    {
        TGMessage *updatedMessage = messages[@(((TGMessage *)_currentMessages[i]).mid)];
        if (updatedMessage != nil)
        {
            _currentItemKeyAliases[@(((TGMessage *)_currentMessages[i]).mid)] = @(updatedMessage.mid);
            [_currentMessages replaceObjectAtIndex:i withObject:updatedMessage];
        }
    }
    
    NSArray *sortedMessages = [self sortedMessages:_currentMessages];
    [_currentMessages removeAllObjects];
    [_currentMessages addObjectsFromArray:sortedMessages];
    if (_updated)
    {
        _updated([[TGMusicPlayerPlaylist alloc] initWithItems:[self itemListFromMessages:_currentMessages] itemKeyAliases:[[NSDictionary alloc] initWithDictionary:_currentItemKeyAliases]]);
    }
}

- (void)actionStageResourceDispatched:(NSString *)path resource:(id)resource arguments:(id)__unused arguments
{
    if ([path isEqualToString:[[NSString alloc] initWithFormat:@"/tg/conversation/(%lld)/messages", _peerId]])
    {
        NSArray *messages = [((SGraphObjectNode *)resource).object copy];
        [self addMessages:messages];
    }
    else if ([path isEqualToString:[[NSString alloc] initWithFormat:@"/tg/conversation/(%lld)/messagesChanged", _peerId]])
    {
        NSArray *midMessagePairs = ((SGraphObjectNode *)resource).object;
        NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
        for (NSUInteger i = 0; i < midMessagePairs.count; i += 2)
        {
            dict[midMessagePairs[0]] = midMessagePairs[1];
        }
        
        [self remapMessages:dict];
    }
    else if ([path isEqualToString:[[NSString alloc] initWithFormat:@"/tg/conversation/(%lld)/messagesDeleted", _peerId]])
    {
         [self deleteMessagesWithIds:((SGraphObjectNode *)resource).object];
    }
}

@end

@implementation TGGenericPeerPlaylistSignals

+ (SSignal *)playlistForPeerId:(int64_t)peerId important:(bool)important atMessageId:(int32_t)messageId
{
    return [[SSignal alloc] initWithGenerator:^id<SDisposable>(SSubscriber *subscriber)
    {
        TGGenericPeerPlaylistHelper *helper = [[TGGenericPeerPlaylistHelper alloc] initWithPeerId:peerId important:important atMessageId:messageId updated:^(TGMusicPlayerPlaylist *playlist)
        {
            [subscriber putNext:playlist];
        }];
        
        return [[SBlockDisposable alloc] initWithBlock:^
        {
            [helper description]; //keep reference
        }];
    }];
}

@end
