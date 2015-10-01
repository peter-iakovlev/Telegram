#import "TGBridgeStateSubscription.h"

NSString *const TGBridgeStateSubscriptionName = @"state.syncState";

@implementation TGBridgeStateSubscription

- (bool)dropPreviouslyQueued
{
    return true;
}

+ (NSString *)subscriptionName
{
    return TGBridgeStateSubscriptionName;
}

@end
