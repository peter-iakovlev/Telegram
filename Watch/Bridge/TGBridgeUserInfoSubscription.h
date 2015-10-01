#import "TGBridgeSubscription.h"

@interface TGBridgeUserInfoSubscription : TGBridgeSubscription

@property (nonatomic, readonly) NSArray *userIds;

- (instancetype)initWithUserIds:(NSArray *)userIds;

@end


@interface TGBridgeUserBotInfoSubscription : TGBridgeSubscription

@property (nonatomic, readonly) NSArray *userIds;

- (instancetype)initWithUserIds:(NSArray *)userIds;

@end

@interface TGBridgeBotReplyMarkupSubscription : TGBridgeSubscription

@property (nonatomic, readonly) int64_t peerId;

- (instancetype)initWithPeerId:(int64_t)peerId;

@end
