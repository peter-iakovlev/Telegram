#import "TGBridgeSubscriptionHandler.h"

@interface TGBridgeRemoteHandler : TGBridgeSubscriptionHandler

+ (void)handleLocalNotification:(NSDictionary *)userInfo;

@end
