#import "TGModernGalleryImageItem.h"

@class TGWebPageMediaAttachment;

@interface TGExternalGalleryItem : TGModernGalleryImageItem

@property (nonatomic, strong, readonly) TGWebPageMediaAttachment *webPage;

- (instancetype)initWithWebPage:(TGWebPageMediaAttachment *)webPage;

@end
