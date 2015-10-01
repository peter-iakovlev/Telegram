#import "TGModernGalleryImageItem.h"
#import "TGMediaPickerAsset.h"

@interface TGMediaPickerGalleryItem : NSObject <TGModernGalleryItem>

@property (nonatomic, strong) TGMediaPickerAsset *asset;
@property (nonatomic, strong) UIImage *immediateThumbnailImage;
@property (nonatomic, assign) bool asFile;

- (instancetype)initWithAsset:(TGMediaPickerAsset *)asset;

@end
