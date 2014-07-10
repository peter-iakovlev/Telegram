#import "TGUpdatePresenceActor.h"

#import "TGTelegraph.h"

#import "ActionStage.h"

#import "TGTimer.h"

@interface TGUpdatePresenceActor ()

@property (nonatomic, strong) TGTimer *timeoutTimer;

@end

@implementation TGUpdatePresenceActor

@synthesize timeoutTimer = _timeoutTimer;

+ (NSString *)genericPath
{
    return @"/tg/service/updatepresence/@";
}

- (void)dealloc
{
    if (_timeoutTimer != nil)
    {
        [_timeoutTimer invalidate];
        _timeoutTimer = nil;
    }
}

- (void)execute:(NSDictionary *)__unused options
{
    NSString *presence = [self.path substringWithRange:NSMakeRange(28, self.path.length - 1 - 28)];
    if ([presence isEqualToString:@"timeout"])
    {
        _timeoutTimer = [[TGTimer alloc] initWithTimeout:5.0 repeat:false completion:^
        {
            _timeoutTimer = nil;
            
            self.cancelToken = [TGTelegraphInstance doSetPresence:false actor:self];
        } queue:[ActionStageInstance() globalStageDispatchQueue]];
        [_timeoutTimer start];
    }
    else if ([presence isEqualToString:@"online"])
    {
        self.cancelToken = [TGTelegraphInstance doSetPresence:true actor:self];
    }
    else
    {
        self.cancelToken = [TGTelegraphInstance doSetPresence:false actor:self];
    }
}

- (void)updatePresenceSuccess
{
    [ActionStageInstance() actionCompleted:self.path result:nil];
}

- (void)updatePresenceFailed
{
    [ActionStageInstance() actionFailed:self.path reason:-1];
}

- (void)cancel
{
    if (_timeoutTimer != nil)
    {
        [_timeoutTimer invalidate];
        _timeoutTimer = nil;
    }
    
    [super cancel];
}

@end
