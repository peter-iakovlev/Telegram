#import <SSignalKit/SSignalKit.h>

#import "TGTwoStepConfig.h"

@interface TGTwoStepVerifyPasswordSignal : NSObject

+ (SSignal *)checkPassword:(NSString *)password config:(TGTwoStepConfig *)config;
+ (SSignal *)authorizeWithPassword:(NSString *)password config:(TGTwoStepConfig *)config;

@end
