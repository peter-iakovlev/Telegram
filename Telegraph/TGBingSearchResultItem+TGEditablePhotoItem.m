#import "TGBingSearchResultItem+TGEditablePhotoItem.h"

#import "TGImageManager.h"
#import "TGStringUtils.h"
#import "TGImageUtils.h"
#import "TGPhotoEditorUtils.h"

#import <objc/runtime.h>

@implementation TGBingSearchResultItem (TGEditablePhotoItem)

- (NSString *)uniqueId
{
    return [TGStringUtils stringByEscapingForURL:self.imageUrl];
}

- (CGSize)originalSize
{
    return TGFitSize(self.imageSize, CGSizeMake(1600, 1600));
}

- (void)fetchThumbnailImageWithCompletion:(void (^)(UIImage *))completion
{
    if (completion == nil)
        return;
    
    if (self.fetchOriginalThumbnailImage != nil)
    {
        self.fetchOriginalThumbnailImage(self, ^(UIImage *image)
        {
            if (image != nil)
                completion(image);
        });
    }
    else
    {
        NSString *uri = [[NSString alloc] initWithFormat:@"web-search-thumbnail://?url=%@&width=90&height=90", [TGStringUtils stringByEscapingForURL:self.previewUrl]];
        
        [[TGImageManager instance] beginLoadingImageAsyncWithUri:uri decode:true progress:nil partialCompletion:nil completion:^(UIImage *image)
        {
            completion(image);
        }];
    }
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
                completion(image);
        });
    }
    else
    {
        CGSize fittedSize = TGFitSize(self.imageSize, CGSizeMake(1600, 1600));
        NSString *uri = [[NSString alloc] initWithFormat:@"web-search-gallery://?url=%@&thumbnailUrl=%@&width=%d&height=%d", [TGStringUtils stringByEscapingForURL:self.imageUrl], [TGStringUtils stringByEscapingForURL:self.previewUrl], (int)fittedSize.width, (int)fittedSize.height];
        
        [[TGImageManager instance] beginLoadingImageAsyncWithUri:uri decode:true progress:nil partialCompletion:nil completion:^(UIImage *image)
        {
            completion(image);
        }];
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
