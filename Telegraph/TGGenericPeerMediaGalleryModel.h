#import "TGModernGalleryModel.h"

@interface TGGenericPeerMediaGalleryModel : TGModernGalleryModel

@property (nonatomic, readonly) int64_t peerId;

- (instancetype)initWithPeerId:(int64_t)peerId atMessageId:(int32_t)atMessageId;

@end
