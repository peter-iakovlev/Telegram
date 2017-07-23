#import "TGWebSearchInternalImageResult+TGMediaItem.h"
#import <objc/runtime.h>

#import <objc/runtime.h>
#import "TGImageInfo.h"
#import "TGImageUtils.h"
#import "TGPhotoEditorUtils.h"

@implementation TGWebSearchInternalImageResult (TGMediaItem)

- (bool)isVideo
{
    return false;
}

- (NSString *)uniqueIdentifier
{
    NSString *uniqueId = objc_getAssociatedObject(self, @selector(uniqueIdentifier));
    if (uniqueId == nil)
    {
        TGImageInfo *legacyImageInfo = self.imageInfo;
        CGSize imageSize = CGSizeZero;
        NSString *legacyCacheUrl = [legacyImageInfo closestImageUrlWithSize:CGSizeMake(1600.0f, 1600.0f) resultingSize:&imageSize];
        
        objc_setAssociatedObject(self, @selector(originalSize), [NSValue valueWithCGSize:imageSize], OBJC_ASSOCIATION_RETAIN_NONATOMIC);
        objc_setAssociatedObject(self, @selector(uniqueIdentifier), legacyCacheUrl, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
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
        objc_setAssociatedObject(self, @selector(uniqueIdentifier), legacyCacheUrl, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
    
    return size.CGSizeValue;
}

- (SSignal *)thumbnailImageSignal
{
    return [[SSignal alloc] initWithGenerator:^id<SDisposable>(SSubscriber *subscriber)
    {
        if (self.fetchOriginalThumbnailImage != nil)
        {
            self.fetchOriginalThumbnailImage(self, ^(UIImage *image)
            {
                [subscriber putNext:image];
                [subscriber putCompletion];
            });
        }
        
        return nil;
    }];
}

- (SSignal *)screenImageSignal:(NSTimeInterval)position
{
    return [[[self originalImageSignal:position] deliverOn:[SQueue concurrentDefaultQueue]] map:^UIImage *(UIImage *image)
    {
        CGSize maxSize = TGPhotoEditorScreenImageMaxSize();
        CGSize targetSize = TGFitSize(self.originalSize, maxSize);
        return TGScaleImage(image, targetSize);
    }];
}

- (SSignal *)originalImageSignal:(NSTimeInterval)__unused position
{
    return [[SSignal alloc] initWithGenerator:^id<SDisposable>(SSubscriber *subscriber)
    {
        if (self.fetchOriginalImage != nil)
        {
            self.fetchOriginalImage(self, ^(UIImage *image)
            {
                [subscriber putNext:image];
                [subscriber putCompletion];
            });
        }
        else
        {
            [subscriber putCompletion];
        }
        
        return nil;
    }];
}

- (void(^)(id<TGMediaEditableItem>, void(^)(UIImage *image)))fetchOriginalImage
{
    return objc_getAssociatedObject(self, @selector(fetchOriginalImage));
}

- (void)setFetchOriginalImage:(void(^)(id<TGMediaEditableItem>, void(^)(UIImage *image)))fetchOriginalImage
{
    objc_setAssociatedObject(self, @selector(fetchOriginalImage), fetchOriginalImage, OBJC_ASSOCIATION_COPY_NONATOMIC);
}

- (void(^)(id<TGMediaEditableItem>, void(^)(UIImage *image)))fetchOriginalThumbnailImage
{
    return objc_getAssociatedObject(self, @selector(fetchOriginalThumbnailImage));
}

- (void)setFetchOriginalThumbnailImage:(void(^)(id<TGMediaEditableItem>, void(^)(UIImage *image)))fetchOriginalThumbnailImage
{
    objc_setAssociatedObject(self, @selector(fetchOriginalThumbnailImage), fetchOriginalThumbnailImage, OBJC_ASSOCIATION_COPY_NONATOMIC);
}

@end
