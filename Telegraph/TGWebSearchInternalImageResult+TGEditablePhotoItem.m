#import "TGWebSearchInternalImageResult+TGEditablePhotoItem.h"

#import "TGImageInfo.h"
#import "TGPhotoEditorUtils.h"
#import "TGImageUtils.h"

#import <objc/runtime.h>

@implementation TGWebSearchInternalImageResult (TGEditablePhotoItem)

- (NSString *)uniqueId
{
    NSString *uniqueId = objc_getAssociatedObject(self, @selector(uniqueId));
    if (uniqueId == nil)
    {
        TGImageInfo *legacyImageInfo = self.imageInfo;
        CGSize imageSize = CGSizeZero;
        NSString *legacyCacheUrl = [legacyImageInfo closestImageUrlWithSize:CGSizeMake(1600.0f, 1600.0f) resultingSize:&imageSize];
        
        objc_setAssociatedObject(self, @selector(originalSize), [NSValue valueWithCGSize:imageSize], OBJC_ASSOCIATION_RETAIN_NONATOMIC);
        objc_setAssociatedObject(self, @selector(uniqueId), legacyCacheUrl, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
    
    return uniqueId;
}

- (CGSize)originalSize
{
    NSValue *size = objc_getAssociatedObject(self, @selector(originalSize));
    if (size == nil)
    {
        TGImageInfo *legacyImageInfo = self.imageInfo;
        CGSize imageSize = CGSizeZero;
        NSString *legacyCacheUrl = [legacyImageInfo closestImageUrlWithSize:CGSizeMake(1600.0f, 1600.0f) resultingSize:&imageSize];
        
        size = [NSValue valueWithCGSize:imageSize];
        objc_setAssociatedObject(self, @selector(originalSize), size, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
        objc_setAssociatedObject(self, @selector(uniqueId), legacyCacheUrl, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
    
    return size.CGSizeValue;
}

- (void)fetchThumbnailImageWithCompletion:(void (^)(UIImage *))completion
{
    if (completion == nil)
        return;
    
}

- (void)fetchOriginalScreenSizeImageWithCompletion:(void (^)(UIImage *))completion
{
    if (completion == nil)
        return;
    
    [self fetchOriginalFullSizeImageWithCompletion:^(UIImage *image)
    {
        CGSize maxSize = TGPhotoEditorScreenImageMaxSize();
        CGSize targetSize = TGFitSize(self.originalSize, maxSize);
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^
        {
            UIGraphicsBeginImageContextWithOptions(targetSize, true, 1.0f);
            [image drawInRect:CGRectMake(0, 0, targetSize.width, targetSize.height)];
            UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
            UIGraphicsEndImageContext();

            completion(image);
        });
    }];
}

- (void)fetchOriginalFullSizeImageWithCompletion:(void (^)(UIImage *))completion
{
    if (completion == nil)
        return;
    
    if (self.fetchOriginalImage != nil)
    {
        self.fetchOriginalImage(self, ^(UIImage *image)
        {
            if (image != nil)
            {
                completion(image);
            }
            else
            {
                
            }
        });
    }
    else
    {

    }
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
