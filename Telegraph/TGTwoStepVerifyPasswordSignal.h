#import <SSignalKit/SSignalKit.h>

#import "TGTwoStepConfig.h"

@class TGPasswordKdfAlgo;

@interface TGTwoStepVerifyPasswordSignal : NSObject

+ (SSignal *)passwordSettings:(NSString *)password config:(TGTwoStepConfig *)config;
+ (SSignal *)passwordSettings:(NSString *)password config:(TGTwoStepConfig *)config outPasswordHash:(NSData **)outPasswordHash;
+ (SSignal *)passwordHashSettings:(NSData *)currentPasswordHash secretPasswordHash:(NSData *)secretPasswordHash config:(TGTwoStepConfig *)config;

+ (SSignal *)checkPassword:(NSString *)password config:(TGTwoStepConfig *)config;
+ (SSignal *)tmpPassword:(NSString *)password config:(TGTwoStepConfig *)config durationSeconds:(int32_t)durationSeconds;

@end
