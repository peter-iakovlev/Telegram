#import "TGModernConversationActivity.h"

#import "ATQueue.h"
#import "TGTimer.h"

@interface TGModernConversationActivityHolder : NSObject

@property (nonatomic, weak) TGModernConversationActivity *activity;

@end

@implementation TGModernConversationActivityHolder

- (void)dealloc
{
    TGModernConversationActivity *activity = _activity;
    if (activity.onDelete)
        activity.onDelete(activity);
}

@end

@interface TGModernConversationActivity ()
{
    ATQueue *_timeoutQueue;
    TGTimer *_timer;
    TGTimer *_tickTimer;
    NSTimeInterval _tickInterval;
}

@end

@implementation TGModernConversationActivity

- (instancetype)initWithType:(NSString *)type priority:(NSInteger)priority tickInterval:(NSTimeInterval)tickInterval timeout:(NSTimeInterval)timeout timeoutQueue:(ATQueue *)timeoutQueue
{
    self = [super init];
    if (self != nil)
    {
        _type = type;
        _priority = priority;
        _tickInterval = tickInterval;
        _timeout = timeout;
        
        _timeoutQueue = timeoutQueue;
        
        __weak TGModernConversationActivity *weakSelf = self;
        
        if (timeout > DBL_EPSILON)
        {
            _timer = [[TGTimer alloc] initWithTimeout:timeout repeat:false completion:^
            {
                __strong TGModernConversationActivity *strongSelf = weakSelf;
                [strongSelf _onTimeout];
            } queue:[timeoutQueue nativeQueue]];
            [_timer start];
        }
        else
            [self _startTickTimer];
    }
    return self;
}

- (void)dealloc
{
    TGTimer *timer = _timer;
    TGTimer *tickTimer = _tickTimer;
    if (timer != nil)
    {
        [_timeoutQueue dispatch:^
        {
            [timer invalidate];
            [tickTimer invalidate];
        }];
    }
}

- (void)resetTimeout
{
    [_timeoutQueue dispatch:^
    {
        [_timer resetTimeout:_timeout];
        
        if (_tickTimer == nil)
            [self _startTickTimer];
    }];
}

- (void)_startTickTimer
{
    [_tickTimer invalidate];
    
    __weak TGModernConversationActivity *weakSelf = self;
    _tickTimer = [[TGTimer alloc] initWithTimeout:_tickInterval repeat:true completion:^
    {
        __strong TGModernConversationActivity *strongSelf = weakSelf;
        if (strongSelf.onTick)
            strongSelf.onTick(strongSelf);
    } queue:[_timeoutQueue nativeQueue]];
    [_tickTimer start];
}

- (void)_onTimeout
{
    if (_onDelete)
        _onDelete(self);
}

- (BOOL)isEqual:(id)object
{
    return [object isKindOfClass:[TGModernConversationActivity class]] && TGStringCompare(((TGModernConversationActivity *)object)->_type, _type) && ((TGModernConversationActivity *)object)->_priority == _priority && ABS(((TGModernConversationActivity *)object)->_timeout - _timeout) < DBL_EPSILON;
}

- (id)holder
{
    TGModernConversationActivityHolder *holder = [[TGModernConversationActivityHolder alloc] init];;
    holder.activity = self;
    return holder;
}

@end
