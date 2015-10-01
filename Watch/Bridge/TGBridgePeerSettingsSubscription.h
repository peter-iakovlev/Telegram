#import "TGBridgeSubscription.h"

@class TGBridgePeerNotificationSettings;

@interface TGBridgePeerSettingsSubscription : TGBridgeSubscription

@property (nonatomic, readonly) int64_t peerId;

- (instancetype)initWithPeerId:(int64_t)peerId;

@end

@interface TGBridgePeerUpdateNotificationSettingsSubscription : TGBridgeSubscription

@property (nonatomic, readonly) int64_t peerId;
@property (nonatomic, readonly) TGBridgePeerNotificationSettings *settings;

- (instancetype)initWithPeerId:(int64_t)peerId settings:(TGBridgePeerNotificationSettings *)settings;

@end

@interface TGBridgePeerUpdateBlockStatusSubscription : TGBridgeSubscription

@property (nonatomic, readonly) int64_t peerId;
@property (nonatomic, readonly) bool blocked;

- (instancetype)initWithPeerId:(int64_t)peerId blocked:(bool)blocked;

@end
