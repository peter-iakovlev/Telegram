#import "TGConversationHistoryAsyncRequestActor.h"

#import "ActionStage.h"

#import "TGSchema.h"

#import "TGTelegraph.h"

#import "TGUserDataRequestBuilder.h"

#import "TGConversation+Telegraph.h"
#import "TGMessage+Telegraph.h"

#import "TGDownloadMessagesSignal.h"
#import "TGConversationAddMessagesActor.h"

@interface TGConversationHistoryAsyncRequestActor ()
{
    int32_t _fromMid;
    bool _down;
    
    id<SDisposable> _disposable;
}

@end

@implementation TGConversationHistoryAsyncRequestActor

+ (NSString *)genericPath
{
    return @"/tg/conversations/@/asyncHistory/@";
}

- (id)initWithPath:(NSString *)path
{
    self = [super initWithPath:path];
    if (self != nil)
    {
        self.requestQueueName = @"messages";
    }
    return self;
}

- (void)dealloc
{
    [_disposable dispose];
}

- (void)execute:(NSDictionary *)options
{
    NSRange range;
    range.location = [@"/tg/conversations/(" length];
    range.length = self.path.length - [@")/asyncHistory" length] - range.location;
    int64_t conversationId = [[self.path substringWithRange:range] longLongValue];
    
    {
        range = [self.path rangeOfString:@"/asyncHistory/("];
        int maxMid = [[self.path substringWithRange:NSMakeRange(range.location + range.length, self.path.length - 1 - range.location - range.length)] intValue];
        int limit = 100;
        if ([options objectForKey:@"limit"] != nil)
            limit = [TGSchema intFromObject:[options objectForKey:@"limit"]];
        
        _fromMid = maxMid;
        
        int offset = 0;
        
        _down = [options[@"down"] boolValue];
        if (_down)
            offset = -limit;
        
        self.cancelToken = [TGTelegraphInstance doRequestConversationHistory:conversationId accessHash:0 maxMid:maxMid orOffset:offset limit:limit actor:self];
    }
}

- (void)conversationHistoryRequestFailed
{
    [ActionStageInstance() nodeRetrieveFailed:self.path];
}

- (void)conversationHistoryRequestSuccess:(TLmessages_Messages *)messages
{
    [TGUserDataRequestBuilder executeUserDataUpdate:messages.users];
    
    NSRange range;
    range.location = [@"/tg/conversations/(" length];
    range.length = self.path.length - [@")/asyncHistory" length] - range.location;
    int64_t conversationId = [[self.path substringWithRange:range] longLongValue];
    range = [self.path rangeOfString:@"/asyncHistory/("];
    
    TGConversation *conversation = nil;
    NSMutableDictionary *otherConversations = [[NSMutableDictionary alloc] init];
    
    for (TLChat *chatDesc in messages.chats)
    {
        TGConversation *chatConversation = [[TGConversation alloc] initWithTelegraphChatDesc:chatDesc];
        if (chatConversation.conversationId == conversationId) {
            conversation = chatConversation;
        } else if (chatConversation.conversationId != 0) {
            otherConversations[@(chatConversation.conversationId)] = chatConversation;
        }
    }
    
    NSMutableArray *messageItems = [[NSMutableArray alloc] init];
    
    int maxMid = 0;
    
    int minRemoteMid = INT_MAX;
    int maxRemoteMid = 0;
    
    for (TLMessage *messageDesc in messages.messages)
    {
        TGMessage *message = [[TGMessage alloc] initWithTelegraphMessageDesc:messageDesc];
        if (!message.outgoing && message.mid > maxMid)
            maxMid = message.mid;
        minRemoteMid = MIN(minRemoteMid, message.mid);
        maxRemoteMid = MAX(maxRemoteMid, message.mid);
        [messageItems addObject:message];
    }
    
    if (messageItems.count == 0)
        [TGDatabaseInstance() storePeerMinMid:conversationId minMid:1];
    
    dispatch_block_t continueBlock = ^
    {
        [TGDatabaseInstance() transactionAddMessages:messageItems updateConversationDatas:otherConversations notifyAdded:false];
        
        if (_down && maxRemoteMid >= _fromMid)
        {
            [TGDatabaseInstance() fillConversationHistoryHole:conversationId indexSet:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(_fromMid, maxRemoteMid - _fromMid)]];
        }
        else if (!_down && minRemoteMid <= _fromMid)
        {
            [TGDatabaseInstance() fillConversationHistoryHole:conversationId indexSet:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(minRemoteMid, _fromMid - minRemoteMid)]];
        }
        
        if (maxMid > 0)
        {
            [TGDatabaseInstance() updateLatestMessageId:maxMid applied:false completion:^(int greaterMidForSynchronization)
             {
                 if (greaterMidForSynchronization > 0)
                 {
                     [ActionStageInstance() requestActor:[[NSString alloc] initWithFormat:@"/tg/messages/reportDelivery/(messages)"] options:[[NSDictionary alloc] initWithObjectsAndKeys:[[NSNumber alloc] initWithInt:maxMid], @"mid", nil] watcher:TGTelegraphInstance];
                 }
             }];
        }
        
        [ActionStageInstance() actionCompleted:self.path result:messageItems];
    };
    
    [[self signalForCompleteMessages:messageItems] startWithNext:^(__unused NSArray *processedMessages)
    {
    } error:^(__unused id error)
    {
        continueBlock();
    } completed:^
    {
        continueBlock();
    }];
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
