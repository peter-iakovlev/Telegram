#import "TGBingSearchResultItem+TGMediaItem.h"

#import <objc/runtime.h>
#import "UIImage+TG.h"
#import "TGImageManager.h"
#import "TGImageUtils.h"
#import "TGStringUtils.h"
#import "TGPhotoEditorUtils.h"

@implementation TGBingSearchResultItem (TGMediaItem)

- (bool)isVideo
{
    return false;
}

- (NSString *)uniqueIdentifier
{
    return [TGStringUtils stringByEscapingForURL:self.imageUrl];
}

- (CGSize)originalSize
{
    return TGFitSize(self.imageSize, CGSizeMake(1600, 1600));
}

- (SSignal *)thumbnailImageSignal
{
    return [[SSignal alloc] initWithGenerator:^id<SDisposable>(SSubscriber *subscriber)
    {
        id token = nil;
        
        if (self.fetchOriginalThumbnailImage != nil)
        {
            self.fetchOriginalThumbnailImage(self, ^(UIImage *image)
            {
                [subscriber putNext:image];
                [subscriber putCompletion];
            });
        }
        else
        {
            NSString *uri = [[NSString alloc] initWithFormat:@"web-search-thumbnail://?url=%@&width=90&height=90", [TGStringUtils stringByEscapingForURL:self.previewUrl]];
            
            token = [[TGImageManager instance] beginLoadingImageAsyncWithUri:uri decode:true progress:nil partialCompletion:nil completion:^(UIImage *image)
            {
                [subscriber putNext:image];
                [subscriber putCompletion];
            }];
        }
        
        return [[SBlockDisposable alloc] initWithBlock:^
        {
            [[TGImageManager instance] cancelTaskWithId:token];
        }];
    }];
}

- (SSignal *)screenImageSignal:(NSTimeInterval)position
{
    return [[self originalImageSignal:position] map:^UIImage *(UIImage *image)
    {
        CGSize maxSize = TGPhotoEditorScreenImageMaxSize();
        CGSize targetSize = TGFitSize(self.originalSize, maxSize);
        return TGScaleImage(image, targetSize);
    }];
}

- (SSignal *)originalImageSignal:(NSTimeInterval)__unused position
{
    SSignal *fetchOriginalSignal = [[SSignal alloc] initWithGenerator:^id<SDisposable>(SSubscriber *subscriber)
    {
        if (self.fetchOriginalImage != nil)
        {
            self.fetchOriginalImage(self, ^(UIImage *image)
            {
                if (image != nil)
                {
                    [subscriber putNext:image];
                    [subscriber putCompletion];
                }
                else
                {
                    [subscriber putError:nil];
                }
            });
        }
        else
        {
            [subscriber putError:nil];
        }
        
        return nil;
    }];
    
    SSignal *loadSignal = [[SSignal alloc] initWithGenerator:^id<SDisposable>(SSubscriber *subscriber)
    {
        CGSize fittedSize = TGFitSize(self.imageSize, CGSizeMake(1600, 1600));
        NSString *uri = [[NSString alloc] initWithFormat:@"web-search-gallery://?url=%@&thumbnailUrl=%@&width=%d&height=%d", [TGStringUtils stringByEscapingForURL:self.imageUrl], [TGStringUtils stringByEscapingForURL:self.previewUrl], (int)fittedSize.width, (int)fittedSize.height];
        
        id token = [[TGImageManager instance] beginLoadingImageAsyncWithUri:uri decode:true progress:^(float progress)
        {
            [subscriber putNext:@(progress)];
        }
        partialCompletion:^(UIImage *image)
        {
            if (image != nil)
            {
                image.degraded = true;
                [subscriber putNext:image];
            }
        } completion:^(UIImage *image)
        {
            if (image != nil)
            {
                [subscriber putNext:image];
                [subscriber putCompletion];
            }
            else
            {
                [subscriber putError:nil];
            }
        }];
        
        return [[SBlockDisposable alloc] initWithBlock:^
        {
            [[TGImageManager instance] cancelTaskWithId:token];
        }];
    }];
    
    return [fetchOriginalSignal catch:^SSignal *(__unused id error)
    {
        return loadSignal;
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
