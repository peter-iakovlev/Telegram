#import "TGConversationHistoryAsyncRequestActor.h"

#import "ActionStage.h"

#import "TGSchema.h"

#import "TGTelegraph.h"

#import "TGUserDataRequestBuilder.h"

#import "TGConversation+Telegraph.h"
#import "TGMessage+Telegraph.h"

@interface TGConversationHistoryAsyncRequestActor ()
{
    int32_t _fromMid;
    bool _down;
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

- (void)execute:(NSDictionary *)options
{
    NSRange range;
    range.location = [@"/tg/conversations/(" length];
    range.length = self.path.length - [@")/asyncHistory" length] - range.location;
    int64_t conversationId = [[self.path substringWithRange:range] longLongValue];
    
    /*if (conversationId == [TGTelegraphInstance serviceUserUid])
    {
        [TGDatabaseInstance() storePeerMinMid:conversationId minMid:1];
        
        [ActionStageInstance() actionCompleted:self.path result:@[]];
    }
    else*/
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
        
        self.cancelToken = [TGTelegraphInstance doRequestConversationHistory:conversationId maxMid:maxMid orOffset:offset limit:limit actor:self];
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
    
    for (TLChat *chatDesc in messages.chats)
    {
        TGConversation *chatConversation = [[TGConversation alloc] initWithTelegraphChatDesc:chatDesc];
        if (chatConversation.conversationId != 0)
        {
            conversation = chatConversation;
            break;
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
    
    [[TGDatabase instance] addMessagesToConversation:messageItems conversationId:conversationId updateConversation:conversation dispatch:true countUnread:false];
    
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
}


@end
