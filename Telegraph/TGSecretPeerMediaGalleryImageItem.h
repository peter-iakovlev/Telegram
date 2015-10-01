#import "TGModernGalleryImageItem.h"

@interface TGSecretPeerMediaGalleryImageItem : TGModernGalleryImageItem

@property (nonatomic) int32_t messageId;
@property (nonatomic) NSTimeInterval messageCountdownTime;
@property (nonatomic) NSTimeInterval messageLifetime;

- (instancetype)initWithImageId:(int64_t)imageId orLocalId:(int64_t)localId peerId:(int64_t)peerId messageId:(int32_t)messageId legacyImageInfo:(TGImageInfo *)legacyImageInfo messageCountdownTime:(NSTimeInterval)messageCountdownTime messageLifetime:(NSTimeInterval)messageLifetime;

@end
