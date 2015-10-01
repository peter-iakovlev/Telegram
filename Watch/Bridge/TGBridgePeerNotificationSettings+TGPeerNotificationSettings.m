#import "TGBridgePeerNotificationSettings+TGPeerNotificationSettings.h"
#import "TGPeerNotificationSettingsSignals.h"

@implementation TGBridgePeerNotificationSettings (TGPeerNotificationSettings)

+ (TGBridgePeerNotificationSettings *)peerNotificationSettingsWithTGPeerNotificationSettings:(TGPeerNotificationSettings *)settings currentTime:(int32_t)currentTime
{
    int32_t muteFor = MAX(0, settings.muteUntil - currentTime);
    
    TGBridgePeerNotificationSettings *bridgeSettings = [[TGBridgePeerNotificationSettings alloc] init];
    bridgeSettings.muteFor = muteFor;
    
    return bridgeSettings;
}

+ (TGPeerNotificationSettings *)tgPeerNotificationSettingsWithpeerNotificationSettingsWithBridgePeerNotificationSettings:(TGBridgePeerNotificationSettings *)bridgeSettings currentTime:(int32_t)currentTime
{
    int32_t muteFor = bridgeSettings.muteFor;
    int32_t muteUntil = muteFor == 0 ? 0 :  bridgeSettings.muteFor + currentTime;
    
    return [[TGPeerNotificationSettings alloc] initWithMuteUntil:muteUntil];
}

@end
