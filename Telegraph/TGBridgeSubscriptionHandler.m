#import "TGBridgeSubscriptionHandler.h"

@implementation TGBridgeSubscriptionHandler

+ (SSignal *)handlingSignalForSubscription:(TGBridgeSubscription *)__unused method server:(TGBridgeServer *)__unused server
{
    return nil;
}

+ (NSArray *)handledSubscriptions
{
    NSAssert(false, @"Handler should handle something");
    return nil;
}

@end
