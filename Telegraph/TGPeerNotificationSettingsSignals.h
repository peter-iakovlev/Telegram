#import <Foundation/Foundation.h>
#import <SSignalKit/SSignalKit.h>

@interface TGPeerNotificationSettings : NSObject

@property (nonatomic, readonly) int32_t muteUntil;

- (instancetype)initWithMuteUntil:(int32_t)muteUntil;

@end

@interface TGPeerNotificationSettingsSignals : NSObject

+ (SSignal *)notificationSettingsWithPeerId:(int64_t)peerId;
+ (SSignal *)updatePeerNotificationSettingsWithPeerId:(int64_t)peerId settings:(TGPeerNotificationSettings *)settings;

@end
