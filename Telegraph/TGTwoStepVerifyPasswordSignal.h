#import <SSignalKit/SSignalKit.h>

#import "TGTwoStepConfig.h"

@interface TGTwoStepVerifyPasswordSignal : NSObject

+ (SSignal *)checkPassword:(NSString *)password config:(TGTwoStepConfig *)config;
+ (SSignal *)authorizeWithPassword:(NSString *)password config:(TGTwoStepConfig *)config;
+ (SSignal *)verifiedPasswordHash:(NSString *)password config:(TGTwoStepConfig *)config;
+ (SSignal *)tmpPassword:(NSString *)password config:(TGTwoStepConfig *)config durationSeconds:(int32_t)durationSeconds;

@end
