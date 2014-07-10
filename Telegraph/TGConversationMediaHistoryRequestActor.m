#import "TGConversationMediaHistoryRequestActor.h"

#import "ActionStage.h"
#import "SGraphNode.h"
#import "SGraphObjectNode.h"

#import "TGTelegraph.h"
#import "TGMessage+Telegraph.h"
#import "TGConversation+Telegraph.h"

#import "TGDatabase.h"

#import "TGSchema.h"

#import "TGUserDataRequestBuilder.h"

@interface TGConversationMediaHistoryRequestActor ()

@property (nonatomic) int64_t conversationId;
@property (nonatomic) int limit;
@property (nonatomic) int atMessageId;
@property (nonatomic) int maxMid;
@property (nonatomic) int maxLocalMid;
@property (nonatomic) int maxDate;

@property (nonatomic, strong) NSArray *localResult;
@property (nonatomic) int localCountResult;

@property (nonatomic) bool isEncrypted;

@end

@implementation TGConversationMediaHistoryRequestActor

+ (NSString *)genericPath
{
    return @"/tg/conversations/@/mediahistory/@";
}

- (void)prepare:(NSDictionary *)options
{
    NSRange range;
    range.location = [@"/tg/conversations/(" length];
    range.length = self.path.length - [@")/mediahistory" length] - range.location;
    _conversationId = [[self.path substringWithRange:range] longLongValue];
    
    _limit = 20;
    if ([options objectForKey:@"limit"] != nil)
        _limit = [TGSchema intFromObject:[options objectForKey:@"limit"]];
    
    _atMessageId = 0;
    if ([options objectForKey:@"atMessageId"] != nil)
        _atMessageId = [TGSchema intFromObject:[options objectForKey:@"atMessageId"]];
    
    _maxDate = INT_MAX;
    if ([options objectForKey:@"maxDate"] != nil)
        _maxDate = [TGSchema intFromObject:[options objectForKey:@"maxDate"]];

    _maxMid = INT_MAX;
    if ([options objectForKey:@"maxMid"] != nil)
        _maxMid = [TGSchema intFromObject:[options objectForKey:@"maxMid"]];
    
    _maxLocalMid = INT_MAX;
    if ([options objectForKey:@"maxLocalMid"] != nil)
        _maxLocalMid = [TGSchema intFromObject:[options objectForKey:@"maxLocalMid"]];
    
    _isEncrypted = [options[@"isEncrypted"] boolValue];

    _localCountResult = 0;
    
    if (_atMessageId != 0)
    {
        _localResult = [[TGDatabase instance] loadMediaInConversation:_conversationId atMessageId:_atMessageId limitAfter:_limit count:&_localCountResult];
    }
    else
    {
        _localResult = [[TGDatabase instance] loadMediaInConversation:_conversationId maxMid:_maxMid maxLocalMid:_maxLocalMid maxDate:_maxDate limit:_limit count:&_localCountResult];
        
        if (_localResult.count != 0 || _isEncrypted)
            self.requestQueueName = nil;
        else
        {
            int databaseMinMediaMid = [TGDatabaseInstance() loadPeerMinMediaMid:_conversationId];
            if (databaseMinMediaMid == 0)
            {
                self.requestQueueName = @"messages";
            }
        }
    }
}

- (void)execute:(NSDictionary *)__unused options
{
    if (_localResult.count == 0)
    {
        _localCountResult = 0;
        
        _localResult = [[TGDatabase instance] loadMediaInConversation:_conversationId maxMid:_maxMid maxLocalMid:_maxLocalMid maxDate:_maxDate limit:_limit count:&_localCountResult];
    }
    
    if (_localResult.count != 0 || _isEncrypted)
    {
        SGraphObjectNode *result = [[SGraphObjectNode alloc] initWithObject:[[NSDictionary alloc] initWithObjectsAndKeys:_localResult, @"messages", [[NSNumber alloc] initWithInt:_localCountResult], @"count", nil]];
        [ActionStageInstance() nodeRetrieved:self.path node:result];
        
        return;
    }
    
    int databaseMinMediaMid = [TGDatabaseInstance() loadPeerMinMediaMid:_conversationId];
    if (databaseMinMediaMid != 0 || _conversationId == [TGTelegraphInstance serviceUserUid])
    {
        SGraphObjectNode *result = [[SGraphObjectNode alloc] initWithObject:[[NSDictionary alloc] initWithObjectsAndKeys:[NSArray array], @"messages", [[NSNumber alloc] initWithInt:-1], @"count", nil]];
        [ActionStageInstance() nodeRetrieved:self.path node:result];
        
        return;
    }
    
    self.cancelToken = [TGTelegraphInstance doRequestConversationMediaHistory:_conversationId maxMid:(_maxMid == INT_MAX ? 0 : _maxMid) maxDate:(_maxDate == INT_MAX ? 0 : _maxDate) limit:_limit actor:self];
}

- (void)mediaHistoryRequestSuccess:(TLmessages_Messages *)messages
{
    NSMutableArray *messageItems = [[NSMutableArray alloc] init];
    
    for (TLMessage *messageDesc in messages.messages)
    {
        if (messageDesc.n_id >= _maxMid)
            continue;
        
        TGMessage *message = [[TGMessage alloc] initWithTelegraphMessageDesc:messageDesc];
        if (message.mid != 0)
            [messageItems addObject:message];
    }
    
    if (messages.messages.count == 0)
        [TGDatabaseInstance() storePeerMinMediaMid:_conversationId minMediaMid:1];
    
    [TGDatabaseInstance() addMediaToConversation:_conversationId messages:messageItems completion:^(int count)
    {
        [ActionStageInstance() dispatchOnStageQueue:^
        {
            SGraphObjectNode *result = [[SGraphObjectNode alloc] initWithObject:[[NSDictionary alloc] initWithObjectsAndKeys:messageItems, @"messages", [[NSNumber alloc] initWithInt:count], @"count", nil]];
            [ActionStageInstance() nodeRetrieved:self.path node:result];
        }];
    }];
}

- (void)mediaHistoryRequestFailed
{
    [ActionStageInstance() nodeRetrieveFailed:self.path];
}

@end
