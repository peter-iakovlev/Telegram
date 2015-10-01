#import "TGBridgePeerSettingsSignals.h"
#import "TGBridgePeerSettingsSubscription.h"
#import "TGBridgeResponse.h"
#import "TGBridgeClient.h"

@implementation TGBridgePeerSettingsSignals

+ (SSignal *)peerSettingsWithPeerId:(int64_t)peerId;
{
    return [[TGBridgeClient instance] requestSignalWithSubscription:[[TGBridgePeerSettingsSubscription alloc] initWithPeerId:peerId]];
}

+ (SSignal *)updateNotificationSettingsWithPeerId:(int64_t)peerId settings:(TGBridgePeerNotificationSettings *)settings
{
    return [[TGBridgeClient instance] requestSignalWithSubscription:[[TGBridgePeerUpdateNotificationSettingsSubscription alloc] initWithPeerId:peerId settings:settings]];
}

+ (SSignal *)updateBlockStatusWithPeerId:(int64_t)peerId blocked:(bool)blocked
{
    return [[TGBridgeClient instance] requestSignalWithSubscription:[[TGBridgePeerUpdateBlockStatusSubscription alloc] initWithPeerId:peerId blocked:blocked]];
}

@end
