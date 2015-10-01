#import <SSignalKit/SSignalKit.h>

@class TGBridgeSubscription;

@interface TGBridgeClientold: NSObject

- (SSignal *)requestSignalWithSubscription:(TGBridgeSubscription *)subcription;

+ (instancetype)sharedInstance;

@end
