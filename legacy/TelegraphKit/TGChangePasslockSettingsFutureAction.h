#import "TGFutureAction.h"

#define TGChangePasslockSettingsFutureActionType ((int)0x8934fab4)

@interface TGChangePasslockSettingsFutureAction : TGFutureAction

@property (nonatomic) int32_t lockSince;

- (instancetype)initWithLockSince:(int32_t)lockSince;

@end
