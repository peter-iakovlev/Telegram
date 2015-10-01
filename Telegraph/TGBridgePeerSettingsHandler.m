#import "TGBridgePeerSettingsHandler.h"
#import "TGBridgePeerSettingsSubscription.h"

#import "TGTelegramNetworking.h"

#import "TGPeerNotificationSettingsSignals.h"
#import "TGBlockedPeersSignals.h"

#import "TGBridgePeerNotificationSettings+TGPeerNotificationSettings.h"

@implementation TGBridgePeerSettingsHandler

+ (SSignal *)handlingSignalForSubscription:(TGBridgeSubscription *)subscription server:(TGBridgeServer *)__unused server
{
    if ([subscription isKindOfClass:[TGBridgePeerSettingsSubscription class]])
    {
        TGBridgePeerSettingsSubscription *settingsSubscription = (TGBridgePeerSettingsSubscription *)subscription;
        
        SSignal *notificationSettingsSignal = [TGPeerNotificationSettingsSignals notificationSettingsWithPeerId:settingsSubscription.peerId];
        SSignal *blockedStatusSignal = [TGBlockedPeersSignals peerBlockedStatusWithPeerId:settingsSubscription.peerId];
        
        NSMutableArray *signals = [[NSMutableArray alloc] init];
        [signals addObject:notificationSettingsSignal];
        
        if (settingsSubscription.peerId > 0)
            [signals addObject:blockedStatusSignal];
        
        return [[SSignal combineSignals:signals] map:^NSDictionary *(NSArray *results)
        {
            NSMutableDictionary *dictionary = [[NSMutableDictionary alloc] init];
            TGBridgePeerNotificationSettings *notificationSettings = [TGBridgePeerNotificationSettings peerNotificationSettingsWithTGPeerNotificationSettings:results[0] currentTime:(int32_t)[[TGTelegramNetworking instance] approximateRemoteTime]];
            
            if (notificationSettings != nil)
                dictionary[@"notifications"] = notificationSettings;
            
            if (results.count > 1)
                dictionary[@"blocked"] = results[1];
            
            return dictionary;
        }];
    }
    else if ([subscription isKindOfClass:[TGBridgePeerUpdateNotificationSettingsSubscription class]])
    {
        TGBridgePeerUpdateNotificationSettingsSubscription *settingsSubscription = (TGBridgePeerUpdateNotificationSettingsSubscription *)subscription;
        TGPeerNotificationSettings *settings = [TGBridgePeerNotificationSettings tgPeerNotificationSettingsWithpeerNotificationSettingsWithBridgePeerNotificationSettings:settingsSubscription.settings currentTime:(int32_t)[[TGTelegramNetworking instance] approximateRemoteTime]];
        
        return [[TGPeerNotificationSettingsSignals updatePeerNotificationSettingsWithPeerId:settingsSubscription.peerId settings:settings] mapToSignal:^SSignal *(__unused id next)
        {
            return [SSignal single:@true];
        }];
    }
    else if ([subscription isKindOfClass:[TGBridgePeerUpdateBlockStatusSubscription class]])
    {
        TGBridgePeerUpdateBlockStatusSubscription *settingsSubscription = (TGBridgePeerUpdateBlockStatusSubscription *)subscription;
        
        return [[TGBlockedPeersSignals updatePeerBlockedStatusWithPeerId:settingsSubscription.peerId blocked:settingsSubscription.blocked] mapToSignal:^SSignal *(__unused id next)
        {
            return [SSignal single:@true];
        }];
    }
    
    return [SSignal fail:nil];
}

+ (NSArray *)handledSubscriptions
{
    return @[ [TGBridgePeerSettingsSubscription class], [TGBridgePeerUpdateNotificationSettingsSubscription class], [TGBridgePeerUpdateBlockStatusSubscription class]];
}

@end
