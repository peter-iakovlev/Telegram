#import <LegacyComponents/TGModernGalleryModel.h>

@class TGMessage;

@interface TGGenericPeerMediaGalleryModel : TGModernGalleryModel

@property (nonatomic, copy) void (^shareAction)(NSArray *messageIds, int64_t fromPeerId, NSArray *peerIds, NSString *caption);
@property (nonatomic, copy) void (^openLinkRequested)(NSString *url);

@property (nonatomic, readonly) int64_t peerId;
@property (nonatomic) int64_t attachedPeerId;
@property (nonatomic) bool disableActions;
@property (nonatomic) bool disableDelete;

- (instancetype)initWithPeerId:(int64_t)peerId atMessageId:(int32_t)atMessageId allowActions:(bool)allowActions important:(bool)important;
- (instancetype)initWithPeerId:(int64_t)peerId allowActions:(bool)allowActions messages:(NSArray *)messages atMessageId:(int32_t)atMessageId;

- (instancetype)initWithFeedId:(int64_t)feedId atMessageId:(int32_t)atMessageId atPeerId:(int64_t)atPeerId allowActions:(bool)allowActions;

- (void)replaceMessages:(NSArray *)messages;

@end
