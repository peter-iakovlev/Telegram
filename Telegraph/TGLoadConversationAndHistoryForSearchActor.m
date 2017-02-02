#import "TGLoadConversationAndHistoryForSearchActor.h"

#import "ActionStage.h"

#import "TGTelegramNetworking.h"
#import <MTProtoKit/MTRequest.h>

#import "TGTelegraph.h"

#import "TGDatabase.h"

#import "TGConversation+Telegraph.h"
#import "TGMessage+Telegraph.h"
#import "TGUserDataRequestBuilder.h"

#import "TGStringUtils.h"

#import "TGChannelManagementSignals.h"

#import "TGPeerIdAdapter.h"

#import "TGDownloadMessagesSignal.h"

@interface TGLoadConversationAndHistoryForSearchActor () <ASWatcher>
{
    int64_t _peerId;
    int64_t _accessHash;
    int32_t _messageId;
    
    bool _loadingFirstHistory;
    
    id<SDisposable> _disposable;
}

@property (nonatomic, strong) ASHandle *actionHandle;

@end

@implementation TGLoadConversationAndHistoryForSearchActor

+ (void)load
{
    [ASActor registerActorClass:self];
}

- (instancetype)initWithPath:(NSString *)path
{
    self = [super initWithPath:path];
    if (self != nil)
    {
        _actionHandle = [[ASHandle alloc] initWithDelegate:self];
    }
    return self;
}

- (void)dealloc
{
    [_actionHandle reset];
    [ActionStageInstance() removeWatcher:self];
    
    [_disposable dispose];
}

+ (NSString *)genericPath
{
    return @"/tg/loadConversationAndMessageForSearch/@";
}

- (void)execute:(NSDictionary *)options
{
    _peerId = [options[@"peerId"] longLongValue];
    _accessHash = [options[@"accessHash"] longLongValue];
    _messageId = [options[@"messageId"] intValue];
    
    if ([TGDatabaseInstance() loadConversationWithId:_peerId] != nil) {
        [self _loadSearchArea];
    } else {
        _loadingFirstHistory = true;
        
        self.cancelToken = [TGTelegraphInstance doRequestConversationHistory:_peerId accessHash:0 maxMid:0 orOffset:0 limit:(int)[self loadCount] / 2 actor:(TGConversationHistoryAsyncRequestActor *)self];
    }
}

- (NSInteger)loadCount
{
#if TARGET_IPHONE_SIMULATOR
    return 10;
#endif
    
    return 100;
}

- (void)_loadSearchArea
{
    if (TGPeerIdIsChannel(_peerId)) {
        NSString *path = self.path;
        NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
        dict[@"peerId"] = @(_peerId);
        dict[@"messageId"] = @(_messageId);
        
        int64_t peerId = _peerId;
        _disposable = [[[TGChannelManagementSignals preloadedHistoryForPeerId:_peerId accessHash:_accessHash aroundMessageId:_messageId] mapToSignal:^SSignal *(NSDictionary *dict) {
            NSArray *removedImportantHoles = nil;
            NSArray *removedUnimportantHoles = nil;
            
            removedImportantHoles = dict[@"hole"] == nil ? nil : @[dict[@"hole"]];
            removedUnimportantHoles = dict[@"hole"] == nil ? nil : @[dict[@"hole"]];
            
            return [[TGDatabaseInstance() modify:^id {
                [TGDatabaseInstance() addMessagesToChannel:peerId messages:dict[@"messages"] deleteMessages:nil unimportantGroups:dict[@"unimportantGroups"] addedHoles:nil removedHoles:removedImportantHoles removedUnimportantHoles:removedUnimportantHoles updatedMessageSortKeys:nil returnGroups:false keepUnreadCounters:false changedMessages:nil];
                
                return [SSignal complete];
            }] switchToLatest];
        }] startWithNext:nil error:^(__unused id error) {
            [ActionStageInstance() actionFailed:path reason:-1];
        } completed:^{
            [ActionStageInstance() actionCompleted:path result:dict];
        }];
    } else {
        self.cancelToken = [TGTelegraphInstance doRequestConversationHistory:_peerId accessHash:0 maxMid:_messageId + 1 orOffset:(int)-[self loadCount] / 2 limit:(int)[self loadCount] actor:(TGConversationHistoryAsyncRequestActor *)self];
    }
}

- (void)cancel
{
    [ActionStageInstance() removeWatcher:self];
    
    [super cancel];
}

- (void)conversationHistoryRequestFailed
{
    [ActionStageInstance() nodeRetrieveFailed:self.path];
}

- (void)conversationHistoryRequestSuccess:(TLmessages_Messages *)messages
{
    [TGUserDataRequestBuilder executeUserDataUpdate:messages.users];
    
    TGConversation *conversation = nil;
    
    for (TLChat *chatDesc in messages.chats)
    {
        TGConversation *chatConversation = [[TGConversation alloc] initWithTelegraphChatDesc:chatDesc];
        if (chatConversation.conversationId == _peerId)
        {
            conversation = chatConversation;
            break;
        }
    }
    
    if (conversation != nil || _peerId > 0)
    {
        NSMutableArray *messageItems = [[NSMutableArray alloc] init];
        
        int32_t maxMid = 0;
        int minRemoteMid = INT_MAX;
        int maxRemoteMid = 0;
        for (TLMessage *messageDesc in messages.messages)
        {
            TGMessage *message = [[TGMessage alloc] initWithTelegraphMessageDesc:messageDesc];
            if (message != nil)
            {
                maxMid = MAX(maxMid, (int32_t)message.mid);
                [messageItems addObject:message];
                minRemoteMid = MIN(minRemoteMid, message.mid);
                maxRemoteMid = MAX(maxRemoteMid, message.mid);
            }
        }
        
        if (messageItems.count == 0 || maxMid == 0)
        {
            [ActionStageInstance() actionFailed:self.path reason:-1];
        }
        else
        {
            [[self signalForCompleteMessages:messageItems] startWithNext:^(NSArray *messageItems) {
                if (!_loadingFirstHistory)
                {
                    if (minRemoteMid < maxRemoteMid)
                        [TGDatabaseInstance() addConversationHistoryHoleToLoadedLaterMessages:_peerId maxMessageId:maxRemoteMid];
                }
                
                [TGDatabaseInstance() transactionAddMessages:messageItems updateConversationDatas:conversation == nil ? nil : @{@(conversation.conversationId): conversation} notifyAdded:false];
                
                if (minRemoteMid <= maxRemoteMid)
                {
                    [TGDatabaseInstance() fillConversationHistoryHole:_peerId indexSet:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(minRemoteMid, maxRemoteMid - minRemoteMid)]];
                }
                
                if (_loadingFirstHistory)
                {
                    _loadingFirstHistory = false;
                    [self _loadSearchArea];
                }
                else
                {
                    NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
                    dict[@"peerId"] = @(_peerId);
                    dict[@"messageId"] = @(_messageId);
                    if (conversation != nil)
                        dict[@"conversation"] = conversation;
                    
                    [ActionStageInstance() actionCompleted:self.path result:dict];
                }
            }];
        }
    }
    else
    {
        [ActionStageInstance() actionFailed:self.path reason:-1];
    }
}

- (SSignal *)signalForCompleteMessages:(NSArray *)completeMessages
{
    NSMutableSet *requiredMessageIds = [[NSMutableSet alloc] init];
    for (TGMessage *message in completeMessages)
    {
        for (id attachment in message.mediaAttachments)
        {
            if ([attachment isKindOfClass:[TGReplyMessageMediaAttachment class]])
            {
                if (((TGReplyMessageMediaAttachment *)attachment).replyMessage == nil)
                    [requiredMessageIds addObject:@(((TGReplyMessageMediaAttachment *)attachment).replyMessageId)];
            }
        }
    }
    
    if (requiredMessageIds.count == 0)
        return [SSignal single:completeMessages];
    else
    {
        NSMutableArray *downloadMessages = [[NSMutableArray alloc] init];
        for (NSNumber *nMessageId in [requiredMessageIds allObjects]) {
            [downloadMessages addObject:[[TGDownloadMessage alloc] initWithPeerId:0 accessHash:0 messageId:[nMessageId intValue]]];
        }
        return [[TGDownloadMessagesSignal downloadMessages:downloadMessages] map:^id(NSArray *messages)
        {
            NSMutableDictionary *messageIdToMessage = [[NSMutableDictionary alloc] init];
            for (TGMessage *message in messages)
            {
                messageIdToMessage[@(message.mid)] = message;
            }
            
            for (TGMessage *message in completeMessages)
            {
                for (id attachment in message.mediaAttachments)
                {
                    if ([attachment isKindOfClass:[TGReplyMessageMediaAttachment class]])
                    {
                        TGMessage *requiredMessage = messageIdToMessage[@(((TGReplyMessageMediaAttachment *)attachment).replyMessageId)];
                        if (requiredMessage != nil)
                            ((TGReplyMessageMediaAttachment *)attachment).replyMessage = requiredMessage;
                        
                        break;
                    }
                }
            }
            
            return completeMessages;
        }];
    }
}

@end
