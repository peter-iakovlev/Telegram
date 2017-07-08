#import "TGModernGalleryModel.h"

@class TGMessage;

@interface TGGenericPeerMediaGalleryModel : TGModernGalleryModel

@property (nonatomic, copy) void (^shareAction)(TGMessage *message, NSArray *peerIds, NSString *caption);

@property (nonatomic, readonly) int64_t peerId;
@property (nonatomic) int64_t attachedPeerId;
@property (nonatomic) bool disableActions;

- (instancetype)initWithPeerId:(int64_t)peerId atMessageId:(int32_t)atMessageId allowActions:(bool)allowActions important:(bool)important;
- (instancetype)initWithPeerId:(int64_t)peerId allowActions:(bool)allowActions messages:(NSArray *)messages atMessageId:(int32_t)atMessageId;

- (void)replaceMessages:(NSArray *)messages;

@end
