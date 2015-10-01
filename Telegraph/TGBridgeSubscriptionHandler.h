#import <SSignalKit/SSignalKit.h>

@class TGBridgeSubscription;
@class TGBridgeServer;

@interface TGBridgeSubscriptionHandler : NSObject

+ (SSignal *)handlingSignalForSubscription:(TGBridgeSubscription *)subscription server:(TGBridgeServer *)server;
+ (NSArray *)handledSubscriptions;

@end
