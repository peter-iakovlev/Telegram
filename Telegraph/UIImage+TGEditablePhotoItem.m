#import "UIImage+TGEditablePhotoItem.h"

#import "TGImageUtils.h"
#import "TGPhotoEditorUtils.h"
#import <objc/runtime.h>

@implementation UIImage (TGEditablePhotoItem)

- (NSString *)uniqueId
{
    return [NSString stringWithFormat:@"%ld", lrand48()];
}

- (CGSize)originalSize
{
    return self.size;
}

- (void)fetchThumbnailImageWithCompletion:(void (^)(UIImage *))completion
{
    if (completion == nil)
        return;
    
    CGFloat thumbnailImageSide = TGPhotoThumbnailSizeForCurrentScreen().width;
    CGSize targetSize = TGScaleToSize(self.size, CGSizeMake(thumbnailImageSide, thumbnailImageSide));
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^
    {
        UIGraphicsBeginImageContextWithOptions(targetSize, true, 0.0f);
        [self drawInRect:CGRectMake(0, 0, targetSize.width, targetSize.height)];
        UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        
        completion(image);
    });
}

- (void)fetchOriginalScreenSizeImageWithCompletion:(void (^)(UIImage *))completion
{
    if (completion == nil)
        return;
    
    CGSize maxSize = TGPhotoEditorScreenImageMaxSize();
    CGSize targetSize = TGFitSize(self.size, maxSize);
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^
    {
        UIGraphicsBeginImageContextWithOptions(targetSize, true, 1.0f);
        [self drawInRect:CGRectMake(0, 0, targetSize.width, targetSize.height)];
        UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
    
        completion(image);
    });
}

- (void)fetchOriginalFullSizeImageWithCompletion:(void (^)(UIImage *))completion
{
    if (completion != nil)
        completion(self);
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
