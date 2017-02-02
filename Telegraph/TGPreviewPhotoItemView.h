#import "TGMenuSheetItemView.h"

@class TGImageMediaAttachment;

@interface TGPreviewPhotoItemView : TGMenuSheetItemView

- (instancetype)initWithImageAttachment:(TGImageMediaAttachment *)attachment;
- (instancetype)initWithThumbURL:(NSURL *)thumbUrl url:(NSURL *)url size:(CGSize)size;

@end
