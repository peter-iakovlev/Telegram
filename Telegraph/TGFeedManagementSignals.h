#import "TGChannelManagementSignals.h"

@class TGFeedPosition;

typedef enum {
    TGFeedHistoryHoleDirectionNone,
    TGFeedHistoryHoleDirectionEarlier,
    TGFeedHistoryHoleDirectionLater
} TGFeedHistoryHoleDirection;

typedef enum {
    TGSynchronizeFeededChannelsActionNone = 0,
    TGSynchronizeFeededChannelsActionSync = 1,
    TGSynchronizeFeededChannelsActionLoad = 2
} TGSynchronizeFeededChannelsActionType;

@interface TGSynchronizeFeededChannelsAction : NSObject <NSCoding>

@property (nonatomic, readonly) int32_t type;
@property (nonatomic, readonly) int32_t feedId;
@property (nonatomic, readonly) NSSet *peerIds;
@property (nonatomic, readonly) bool alsoNewlyJoined;
@property (nonatomic, readonly) int32_t version;

- (instancetype)initWithType:(int32_t)type feedId:(int32_t)feedId peerIds:(NSSet *)peerIds alsoNewlyJoined:(bool)alsoNewlyJoined version:(int32_t)version;

@end

@interface TGFeedManagementSignals : NSObject

+ (SSignal *)feedMessageHoleForFeedId:(int32_t)feedId hole:(TGMessageHole *)hole direction:(TGFeedHistoryHoleDirection)direction;
+ (SSignal *)preloadedFeedId:(int32_t)feedId aroundPosition:(TGFeedPosition *)position unread:(bool)unread;

+ (bool)_containsPreloadedHistoryForFeedId:(int32_t)feedId aroundMessageId:(int32_t)messageId peerId:(int64_t)peerId;

+ (SSignal *)createFeed:(int32_t)feedId peerIds:(NSSet *)peerIds;

+ (SSignal *)synchronizeFeededChannels;
+ (SSignal *)pullFeededChannels;

+ (SSignal *)groupChannelWithPeerId:(int64_t)peerId feedId:(int32_t)feedId;
+ (SSignal *)ungroupChannelWithPeerId:(int64_t)peerId;
+ (SSignal *)updateFeedChannels:(int32_t)feedId peerIds:(NSSet *)peerIds alsoNewlyJoined:(bool)alsoNewlyJoined;

+ (SSignal *)pollFeedMessages;

+ (SSignal *)readFeedMessages;

@end
