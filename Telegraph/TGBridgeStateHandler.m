#import "TGBridgeStateHandler.h"
#import "TGBridgeStateSubscription.h"

#import "TGSynchronizationStateSignal.h"

@implementation TGBridgeStateHandler

+ (SSignal *)handlingSignalForSubscription:(TGBridgeSubscription *)subscription server:(TGBridgeServer *)__unused server
{
    if ([subscription isKindOfClass:[TGBridgeStateSubscription class]])
        return [TGSynchronizationStateSignal synchronizationState];
    
    return [SSignal fail:nil];
}

+ (NSArray *)handledSubscriptions
{
    return @[ [TGBridgeStateSubscription class] ];
}

@end
