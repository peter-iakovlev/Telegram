#import <SSignalKit/SSignalKit.h>
#import "TGBridgePeerNotificationSettings.h"

@interface TGBridgePeerSettingsSignals : NSObject

+ (SSignal *)peerSettingsWithPeerId:(int64_t)peerId;

+ (SSignal *)updateNotificationSettingsWithPeerId:(int64_t)peerId settings:(TGBridgePeerNotificationSettings *)settings;
+ (SSignal *)updateBlockStatusWithPeerId:(int64_t)peerId blocked:(bool)blocked;

@end
