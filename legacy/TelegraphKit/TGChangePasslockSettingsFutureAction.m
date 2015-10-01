#import "TGChangePasslockSettingsFutureAction.h"

@implementation TGChangePasslockSettingsFutureAction

- (instancetype)initWithLockSince:(int32_t)lockSince
{
    self = [super initWithType:TGChangePasslockSettingsFutureActionType];
    if (self != nil)
    {
        self.uniqueId = 1;
        
        _lockSince = lockSince;
    }
    return self;
}

- (NSData *)serialize
{
    NSMutableData *data = [[NSMutableData alloc] initWithCapacity:1 + 4];
    
    uint8_t version = 1;
    [data appendBytes:&version length:1];
    
    [data appendBytes:&_lockSince length:4];
    
    return data;
}

- (TGFutureAction *)deserialize:(NSData *)data
{
    uint8_t version = 0;
    [data getBytes:&version range:NSMakeRange(0, 1)];
    
    int32_t lockSince = 0;
    [data getBytes:&lockSince range:NSMakeRange(1, 4)];
    
    TGChangePasslockSettingsFutureAction *action = [[TGChangePasslockSettingsFutureAction alloc] initWithLockSince:lockSince];
    
    return action;
}

@end
