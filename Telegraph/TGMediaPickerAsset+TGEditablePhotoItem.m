#import "TGMediaPickerAsset+TGEditablePhotoItem.h"

#import "TGAssetImageManager.h"
#import "TGImageUtils.h"
#import "TGPhotoEditorUtils.h"

#import <objc/runtime.h>

@implementation TGMediaPickerAsset (TGEditablePhotoItem)

- (CGSize)originalSize
{
    if ([TGAssetImageManager usesLegacyAssetsLibrary])
        return TGFitSize(self.dimensions, TGAssetImageManagerLegacySizeLimit);
    
    return self.dimensions;
}

- (void)fetchThumbnailImageWithCompletion:(void (^)(UIImage *))completion
{
    if (completion == nil)
        return;
    
    CGFloat thumbnailImageSide = TGPhotoThumbnailSizeForCurrentScreen().width * [UIScreen mainScreen].scale;
    
    [TGAssetImageManager requestImageWithAsset:self
                                     imageType:TGAssetImageTypeAspectRatioThumbnail
                                          size:CGSizeMake(thumbnailImageSide, thumbnailImageSide)
                               completionBlock:^(UIImage *image, NSError *error)
    {
        if (error != nil)
            completion(nil);
        else
            completion(image);
    }];
}

- (void)fetchOriginalScreenSizeImageWithCompletion:(void (^)(UIImage *))completion
{
    if (completion == nil)
        return;
    
    [TGAssetImageManager requestImageWithAsset:self
                                     imageType:TGAssetImageTypeScreen
                                          size:TGPhotoEditorScreenImageMaxSize()
                               completionBlock:^(UIImage *image, NSError *error)
    {
        if (error != nil)
            completion(nil);
        else
            completion(image);
    }];
}

- (void)fetchOriginalFullSizeImageWithCompletion:(void (^)(UIImage *))completion
{
    if (completion == nil)
        return;
    
    [TGAssetImageManager requestImageWithAsset:self
                                     imageType:TGAssetImageTypeFullSize
                                          size:CGSizeZero
                               completionBlock:^(UIImage *image, NSError *error)
    {
        if (error != nil)
            completion(nil);
        else
            completion(image);
    }];
}

- (void)fetchMetadataWithCompletion:(void (^)(NSDictionary *))completion
{
    if (completion == nil)
        return;
    
    [TGAssetImageManager requestImageMetadataWithAsset:self completionBlock:^(NSDictionary *metadata, NSError *error)
    {
        if (error != nil)
            completion(nil);
        else
            completion(metadata);
    }];
}

#pragma mark -

- (PGPhotoEditorValues *(^)(id<TGEditablePhotoItem>))fetchEditorValues
{
    return objc_getAssociatedObject(self, @selector(fetchEditorValues));
}

- (void)setFetchEditorValues:(PGPhotoEditorValues *(^)(id<TGEditablePhotoItem>))fetchEditorValues
{
    objc_setAssociatedObject(self, @selector(fetchEditorValues), fetchEditorValues, OBJC_ASSOCIATION_COPY_NONATOMIC);
}

- (NSString *(^)(id<TGEditablePhotoItem>))fetchCaption
{
    return objc_getAssociatedObject(self, @selector(fetchCaption));
}

- (void)setFetchCaption:(NSString *(^)(id<TGEditablePhotoItem>))fetchCaption
{
    objc_setAssociatedObject(self, @selector(fetchCaption), fetchCaption, OBJC_ASSOCIATION_COPY_NONATOMIC);
}

- (UIImage *(^)(id<TGEditablePhotoItem>))fetchThumbnailImage
{
    return objc_getAssociatedObject(self, @selector(fetchThumbnailImage));
}

- (void)setFetchThumbnailImage:(UIImage *(^)(id<TGEditablePhotoItem>))fetchThumbnailImage
{
    objc_setAssociatedObject(self, @selector(fetchThumbnailImage), fetchThumbnailImage, OBJC_ASSOCIATION_COPY_NONATOMIC);
}

- (UIImage *(^)(id<TGEditablePhotoItem>))fetchScreenImage
{
    return objc_getAssociatedObject(self, @selector(fetchScreenImage));
}

- (void)setFetchScreenImage:(UIImage *(^)(id<TGEditablePhotoItem>))fetchScreenImage
{
    objc_setAssociatedObject(self, @selector(fetchScreenImage), fetchScreenImage, OBJC_ASSOCIATION_COPY_NONATOMIC);
}

- (void(^)(id<TGEditablePhotoItem>, void(^)(UIImage *image)))fetchOriginalImage
{
    return objc_getAssociatedObject(self, @selector(fetchOriginalImage));
}

- (void)setFetchOriginalImage:(void(^)(id<TGEditablePhotoItem>, void(^)(UIImage *image)))fetchOriginalImage
{
    objc_setAssociatedObject(self, @selector(fetchOriginalImage), fetchOriginalImage, OBJC_ASSOCIATION_COPY_NONATOMIC);
}

- (void(^)(id<TGEditablePhotoItem>, void(^)(UIImage *image)))fetchOriginalThumbnailImage
{
    return objc_getAssociatedObject(self, @selector(fetchOriginalThumbnailImage));
}

- (void)setFetchOriginalThumbnailImage:(void(^)(id<TGEditablePhotoItem>, void(^)(UIImage *image)))fetchOriginalThumbnailImage
{
    objc_setAssociatedObject(self, @selector(fetchOriginalThumbnailImage), fetchOriginalThumbnailImage, OBJC_ASSOCIATION_COPY_NONATOMIC);
}

@end
