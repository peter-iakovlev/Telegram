#import "TGImageView.h"
#import "TGAssetImageManager.h"

@class TGMediaPickerAsset;

@interface TGAssetImageView : TGImageView

@property (nonatomic, copy) void (^progressChanged)(CGFloat);
@property (nonatomic, copy) void (^availabilityStateChanged)(bool);

- (bool)isAvailableNow;

- (void)loadWithImage:(UIImage *)image;
- (void)loadWithAsset:(TGMediaPickerAsset *)asset imageType:(TGAssetImageType)imageType size:(CGSize)size;
- (void)loadWithAsset:(TGMediaPickerAsset *)asset imageType:(TGAssetImageType)imageType size:(CGSize)size completionBlock:(void (^)(UIImage *result))completionBlock;

@end
