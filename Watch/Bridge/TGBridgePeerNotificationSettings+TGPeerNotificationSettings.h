#import "TGBridgePeerNotificationSettings.h"

@class TGPeerNotificationSettings;

@interface TGBridgePeerNotificationSettings (TGPeerNotificationSettings)

+ (TGBridgePeerNotificationSettings *)peerNotificationSettingsWithTGPeerNotificationSettings:(TGPeerNotificationSettings *)settings currentTime:(int32_t)currentTime;
+ (TGPeerNotificationSettings *)tgPeerNotificationSettingsWithpeerNotificationSettingsWithBridgePeerNotificationSettings:(TGBridgePeerNotificationSettings *)bridgeSettings currentTime:(int32_t)currentTime;

@end
