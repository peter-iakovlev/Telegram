#import <SSignalKit/SSignalKit.h>

#import "TGTwoStepConfig.h"

@interface TGTwoStepVerifyPasswordSignal : NSObject

+ (SSignal *)passwordSettings:(NSString *)password config:(TGTwoStepConfig *)config;
+ (SSignal *)passwordSettings:(NSString *)password config:(TGTwoStepConfig *)config outPasswordHash:(NSData **)outPasswordHash;
+ (SSignal *)passwordHashSettings:(NSData *)currentPasswordHash secretPasswordHash:(NSData *)secretPasswordHash;

+ (SSignal *)checkPassword:(NSString *)password config:(TGTwoStepConfig *)config;
+ (SSignal *)authorizeWithPassword:(NSString *)password config:(TGTwoStepConfig *)config;
+ (SSignal *)verifiedPasswordHash:(NSString *)password config:(TGTwoStepConfig *)config;
+ (SSignal *)tmpPassword:(NSString *)password config:(TGTwoStepConfig *)config durationSeconds:(int32_t)durationSeconds;

@end
