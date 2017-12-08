#import <LegacyComponents/TGModernGalleryModel.h>

@class TGWebPageMediaAttachment;

@interface TGExternalGalleryModel : TGModernGalleryModel

- (instancetype)initWithWebPage:(TGWebPageMediaAttachment *)webPage peerId:(int64_t)peerId messageId:(int32_t)messageId;

@end
