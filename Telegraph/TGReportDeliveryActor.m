#import "TGReportDeliveryActor.h"

#import "ActionStage.h"

#import "TGTelegraph.h"
#import "TGDatabase.h"

#import "TGApplyUpdatesActor.h"

@interface TGReportDeliveryActor ()
{
    bool _isQts;
}

@property (nonatomic) int value;
@property (nonatomic) int nextValue;

@end

@implementation TGReportDeliveryActor

+ (NSString *)genericPath
{
    return @"/tg/messages/reportDelivery/@";
}

- (void)execute:(NSDictionary *)options
{
    if ([self.path hasSuffix:@"(qts)"])
    {
        _isQts = true;
        
        int32_t qts = [options[@"qts"] intValue];
        if (qts == 0)
            [ActionStageInstance() actionFailed:self.path reason:-1];
        else
            [self maybeReportValue:qts];
    }
    else
    {
        int mid = [[options objectForKey:@"mid"] intValue];
        if (mid == 0)
        {
            [ActionStageInstance() actionFailed:self.path reason:-1];
            return;
        }
        
        [self maybeReportValue:mid];
    }
}

- (void)watcherJoined:(ASHandle *)watcherHandle options:(NSDictionary *)options waitingInActorQueue:(bool)waitingInActorQueue
{
    [self maybeReportValue:_isQts ? [options[@"qts"] intValue] : [options[@"mid"] intValue]];
    
    [super watcherJoined:watcherHandle options:options waitingInActorQueue:waitingInActorQueue];
}

- (void)maybeReportValue:(int)reportValue
{
    if (_value == 0)
    {
        _value = reportValue;
        
        if (_isQts)
            self.cancelToken = [TGTelegraphInstance doReportQtsReceived:_value actor:self];
        else
            self.cancelToken = [TGTelegraphInstance doReportDelivery:_value actor:self];
    }
    else if (reportValue > _nextValue)
    {
        _nextValue = reportValue;
    }
}

- (void)reportDeliverySuccess:(int)maxMid deliveredMessages:(NSArray *)deliveredMessages
{
    NSMutableArray *mids = [[NSMutableArray alloc] init];
    NSMutableSet *midsWithoutSound = [[NSMutableSet alloc] init];
    
    for (TLReceivedNotifyMessage *receivedMessage in deliveredMessages)
    {
        [mids addObject:@(receivedMessage.n_id)];
        if (receivedMessage.flags & (1 << 0))
        {
            [midsWithoutSound addObject:@(receivedMessage.n_id)];
        }
    }
    
    TGLog(@"receivedMessages: maxId: %d, mids: %@, withoutSound: %@", maxMid, mids, midsWithoutSound);
    
    [TGApplyUpdatesActor applyDelayedNotifications:maxMid mids:mids midsWithoutSound:midsWithoutSound maxQts:0 randomIds:nil];
    
    if (maxMid == _value)
    {
        [TGDatabaseInstance() updateLatestMessageId:_value applied:true completion:nil];
        
        _value = 0;
        
        if (_nextValue != 0)
        {
            _value = _nextValue;
            _nextValue = 0;
            
            self.cancelToken = [TGTelegraphInstance doReportDelivery:_value actor:self];
        }
        else
            [ActionStageInstance() actionCompleted:self.path result:nil];
    }
}

- (void)reportDeliveryFailed:(int)maxMid
{
    if (maxMid == _value)
    {
        _value = 0;
        
        if (_nextValue != 0)
        {
            _value = _nextValue;
            _nextValue = 0;
            
            self.cancelToken = [TGTelegraphInstance doReportDelivery:_value actor:self];
        }
        else
            [ActionStageInstance() actionFailed:self.path reason:-1];
    }
}

- (void)reportQtsSuccess:(int32_t)qts randomIds:(NSArray *)randomIds
{
    TGLog(@"receivedQueue: qts: %d, randomIds: %@", qts, randomIds);
    
    [TGApplyUpdatesActor applyDelayedNotifications:0 mids:nil midsWithoutSound:nil maxQts:qts randomIds:randomIds];
    
    if (qts == _value)
    {
        [TGDatabaseInstance() updateLatestQts:_value applied:true completion:nil];
        
        _value = 0;
        
        if (_nextValue != 0)
        {
            _value = _nextValue;
            _nextValue = 0;
            
            self.cancelToken = [TGTelegraphInstance doReportQtsReceived:_value actor:self];
        }
        else
            [ActionStageInstance() actionCompleted:self.path result:nil];
    }
}

- (void)reportQtsFailed:(int32_t)qts
{
    if (qts == _value)
    {
        _value = 0;
        
        if (_nextValue != 0)
        {
            _value = _nextValue;
            _nextValue = 0;
            
            self.cancelToken = [TGTelegraphInstance doReportQtsReceived:_value actor:self];
        }
        else
            [ActionStageInstance() actionFailed:self.path reason:-1];
    }
}

@end
