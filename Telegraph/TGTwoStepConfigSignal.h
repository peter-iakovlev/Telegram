#import <SSignalKit/SSignalKit.h>

#import "TGTwoStepConfig.h"

@interface TGTwoStepConfigSignal : NSObject

+ (SSignal *)twoStepConfig;

+ (NSData *)TGSha512:(NSData *)data;

@end
