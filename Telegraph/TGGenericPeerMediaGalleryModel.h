#import "TGModernGalleryModel.h"

@protocol TGModernGalleryItem;

@interface TGGenericPeerMediaGalleryModel : TGModernGalleryModel

@property (nonatomic, readonly) int64_t peerId;

- (instancetype)initWithPeerId:(int64_t)peerId atMessageId:(int32_t)atMessageId allowActions:(bool)allowActions important:(bool)important;
- (instancetype)initWithPeerId:(int64_t)peerId allowActions:(bool)allowActions messages:(NSArray *)messages atMessageId:(int32_t)atMessageId;

- (void)replaceMessages:(NSArray *)messages;

@end
