#import <SSignalKit/SSignalKit.h>

@interface TGScreenCaptureSignals : NSObject

+ (SSignal *)screenshotTakenSignal;
+ (SSignal *)screenCapturedSignal;

@end
