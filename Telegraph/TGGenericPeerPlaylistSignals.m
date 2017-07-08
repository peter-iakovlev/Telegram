#import "TGGenericPeerPlaylistSignals.h"

#import "ActionStage.h"

#import "TGMusicPlayerPlaylist.h"
#import "TGSharedMediaCacheSignals.h"
#import "TGMessage.h"

#import "TGDatabase.h"

#import "TGMessageViewedContentProperty.h"
#import "TGTelegraph.h"

#import "TGPeerIdAdapter.h"

@interface TGGenericPeerPlaylistHelper : NSObject <ASWatcher>
{
    int64_t _peerId;
    bool _important;
    int32_t _atMessageId;
    void (^_updated)(TGMusicPlayerPlaylist *);
    id<SDisposable> _cachedMediaDisposable;
    
    NSMutableArray *_currentMessages;
    NSMutableDictionary *_currentItemKeyAliases;
    bool _voice;
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

- (NSArray *)itemListFromMessages:(NSArray *)messages voice:(bool)voice
{
    NSMutableArray *items = [[NSMutableArray alloc] init];
    for (TGMessage *message in messages)
    {
        TGUser *author = nil;
        if (!TGPeerIdIsChannel(message.fromUid)) {
            author = [TGDatabaseInstance() loadUser:(int32_t)message.fromUid];
        }
        TGMusicPlayerItem *item = [TGMusicPlayerItem itemWithMessage:message author:author];
        if (item != nil && item.isVoice == voice)
            [items addObject:item];
    }
    return items;
}

- (instancetype)initWithPeerId:(int64_t)peerId important:(bool)important atMessageId:(int32_t)atMessageId voice:(bool)voice updated:(void (^)(TGMusicPlayerPlaylist *))updated
{
    self = [super init];
    if (self != nil)
    {
        _peerId = peerId;
        _important = important;
        _atMessageId = atMessageId;
        _updated = [updated copy];
        _voice = voice;
        
        _currentMessages = [[NSMutableArray alloc] init];
        _currentItemKeyAliases = [[NSMutableDictionary alloc] init];
        
        _actionHandle = [[ASHandle alloc] initWithDelegate:self];
        
        __weak TGGenericPeerPlaylistHelper *weakSelf = self;
        
        SSignal *initialSignal = [[TGDatabaseInstance() modify:^id{
            TGMessage *message = [TGDatabaseInstance() loadMessageWithMid:atMessageId peerId:peerId];
            if (message != nil) {
                return [SSignal single:@[message]];
            } else {
                return [SSignal complete];
            }
        }] switchToLatest];
        
        _cachedMediaDisposable = [[initialSignal then:[[TGSharedMediaCacheSignals cachedMediaForPeerId:peerId itemType:voice ? TGSharedMediaCacheItemTypeVoiceVideoMessage : TGSharedMediaCacheItemTypeAudio important:_important] filter:^bool (id next)
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
        }]] startWithNext:^(NSArray *messages)
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

+ (void)markItemAsViewed:(TGMusicPlayerItem *)item {
    [TGDatabaseInstance() dispatchOnDatabaseThread:^{
        if ([item.key respondsToSelector:@selector(intValue)]) {
            TGMessage *message = [TGDatabaseInstance() loadMessageWithMid:[(NSNumber *)item.key intValue] peerId:item.peerId];
            if (message != nil && !message.outgoing) {
                if (TGPeerIdIsSecretChat(message.cid)) {
                    int32_t flags = [TGDatabaseInstance() secretMessageFlags:message.mid];
                    if ((flags & TGSecretMessageFlagViewed) == 0) {
                        [TGDatabaseInstance() messageCountdownLocalTime:message.mid enqueueIfNotQueued:true initiatedCountdown:NULL];
                        [ActionStageInstance() requestActor:@"/tg/service/synchronizeserviceactions/(settings)" options:nil watcher:TGTelegraphInstance];
                    }
                } else {
                    if (message.contentProperties[@"contentsRead"] == nil) {
                        NSMutableDictionary *contentProperties = [[NSMutableDictionary alloc] initWithDictionary:message.contentProperties];
                        contentProperties[@"contentsRead"] = [[TGMessageViewedContentProperty alloc] init];
                        
                        TGDatabaseAction action = { .type = TGDatabaseActionReadMessageContents, .subject = message.mid, .arg0 = 0, .arg1 = 0};
                        [TGDatabaseInstance() storeQueuedActions:[NSArray arrayWithObject:[[NSValue alloc] initWithBytes:&action objCType:@encode(TGDatabaseAction)]]];
                        [ActionStageInstance() requestActor:@"/tg/service/synchronizeactionqueue/(global)" options:nil watcher:TGTelegraphInstance];
                        
                        [TGDatabaseInstance() transactionUpdateMessages:@[[[TGDatabaseUpdateContentsRead alloc] initWithPeerId:message.cid messageId:message.mid]] updateConversationDatas:nil];
                        
                        [ActionStageInstance() dispatchResource:[NSString stringWithFormat:@"/tg/conversation/*/readmessageContents"] resource:@{@"messageIds": @[@(message.mid)]}];
                    }
                }
            }
        }
    } synchronous:false];
}

- (void)replaceMessages:(NSArray *)messages
{
    [_currentItemKeyAliases removeAllObjects];
    [_currentMessages removeAllObjects];
    
    [_currentMessages addObjectsFromArray:[self sortedMessages:messages]];
    
    if (_updated)
    {
        _updated([[TGMusicPlayerPlaylist alloc] initWithVoice:_voice items:[self itemListFromMessages:_currentMessages voice:_voice] itemKeyAliases:[[NSDictionary alloc] initWithDictionary:_currentItemKeyAliases] markItemAsViewed:^(TGMusicPlayerItem *item) {
            [TGGenericPeerPlaylistHelper markItemAsViewed:item];
        }]);
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
            if ([TGMusicPlayerItem itemWithMessage:message author:nil] != nil)
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
            _updated([[TGMusicPlayerPlaylist alloc] initWithVoice:_voice items:[self itemListFromMessages:_currentMessages voice:_voice] itemKeyAliases:[[NSDictionary alloc] initWithDictionary:_currentItemKeyAliases] markItemAsViewed:^(TGMusicPlayerItem *item) {
                [TGGenericPeerPlaylistHelper markItemAsViewed:item];
            }]);
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
        _updated([[TGMusicPlayerPlaylist alloc] initWithVoice:_voice items:[self itemListFromMessages:_currentMessages voice:_voice] itemKeyAliases:[[NSDictionary alloc] initWithDictionary:_currentItemKeyAliases] markItemAsViewed:^(TGMusicPlayerItem *item) {
            [TGGenericPeerPlaylistHelper markItemAsViewed:item];
        }]);
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
        _updated([[TGMusicPlayerPlaylist alloc] initWithVoice:_voice items:[self itemListFromMessages:_currentMessages voice:_voice] itemKeyAliases:[[NSDictionary alloc] initWithDictionary:_currentItemKeyAliases] markItemAsViewed:^(TGMusicPlayerItem *item) {
            [TGGenericPeerPlaylistHelper markItemAsViewed:item];
        }]);
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

+ (SSignal *)playlistForPeerId:(int64_t)peerId important:(bool)important atMessageId:(int32_t)messageId voice:(bool)voice
{
    return [[SSignal alloc] initWithGenerator:^id<SDisposable>(SSubscriber *subscriber)
    {
        TGGenericPeerPlaylistHelper *helper = [[TGGenericPeerPlaylistHelper alloc] initWithPeerId:peerId important:important atMessageId:messageId voice:voice updated:^(TGMusicPlayerPlaylist *playlist)
        {
            [subscriber putNext:playlist];
        }];
        
        return [[SBlockDisposable alloc] initWithBlock:^
        {
            [helper description]; //keep reference
        }];
    }];
}

+ (SSignal *)playlistForItem:(TGMusicPlayerItem *)item voice:(bool)voice {
    TGMusicPlayerPlaylist *playlist = [[TGMusicPlayerPlaylist alloc] initWithVoice:voice items:@[item] itemKeyAliases:@{} markItemAsViewed:^(__unused TGMusicPlayerItem *item) {
    }];
    return [SSignal single:playlist];
}

+ (SSignal *)playlistForItemList:(NSArray<TGMusicPlayerItem *> *)itemList voice:(bool)voice {
    TGMusicPlayerPlaylist *playlist = [[TGMusicPlayerPlaylist alloc] initWithVoice:voice items:itemList itemKeyAliases:@{} markItemAsViewed:^(__unused TGMusicPlayerItem *item) {
    }];
    return [SSignal single:playlist];
}

@end
