#import "TGModernGalleryZoomableItemView.h"
#import "TGModernGalleryEditableItemView.h"

@class TGAssetImageView;

@interface TGMediaPickerGalleryPhotoItemView : TGModernGalleryZoomableItemView <TGModernGalleryEditableItemView>

@property (nonatomic) CGSize imageSize;

@property (nonatomic, strong) TGAssetImageView *imageView;

@end
