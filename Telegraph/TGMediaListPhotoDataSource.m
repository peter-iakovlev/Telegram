#import "TGMediaListPhotoDataSource.h"

#import "ASQueue.h"

#import "TGWorkerPool.h"
#import "TGWorkerTask.h"
#import "TGMediaPreviewTask.h"

#import "TGMemoryImageCache.h"

#import "TGImageUtils.h"
#import "TGStringUtils.h"
#import "TGRemoteImageView.h"

#import "TGImageBlur.h"
#import "UIImage+TG.h"

#import "TGMediaStoreContext.h"

#import "TGAppDelegate.h"

static TGWorkerPool *workerPool()
{
    static TGWorkerPool *instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^
    {
        instance = [[TGWorkerPool alloc] init];
    });
    
    return instance;
}

static ASQueue *taskManagementQueue()
{
    static ASQueue *queue = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^
    {
        queue = [[ASQueue alloc] initWithName:"org.telegram.mediaListPhotoThumbnailTaskManagementQueue"];
    });
    
    return queue;
}

@implementation TGMediaListPhotoDataSource

+ (void)load
{
    @autoreleasepool
    {
        [TGImageDataSource registerDataSource:[[self alloc] init]];
    }
}

+ (NSString *)uriScheme
{
    return @"media-list-photo-thumbnail";
}

- (bool)canHandleUri:(NSString *)uri
{
    return [uri hasPrefix:[[NSString alloc] initWithFormat:@"%@://", [TGMediaListPhotoDataSource uriScheme]]];
}

- (bool)canHandleAttributeUri:(NSString *)uri
{
    return [uri hasPrefix:[[NSString alloc] initWithFormat:@"%@://", [TGMediaListPhotoDataSource uriScheme]]];
}

- (id)loadDataAsyncWithUri:(NSString *)uri progress:(void (^)(float))progress partialCompletion:(void (^)(TGDataResource *resource))__unused partialCompletion completion:(void (^)(TGDataResource *))completion
{
    TGMediaPreviewTask *previewTask = [[TGMediaPreviewTask alloc] init];
    
    [taskManagementQueue() dispatchOnQueue:^
    {
        TGWorkerTask *workerTask = [[TGWorkerTask alloc] initWithBlock:^(bool (^isCancelled)())
        {
            TGDataResource *result = [TGMediaListPhotoDataSource _performLoad:uri isCancelled:isCancelled];
            
            if (result != nil && progress != nil)
                progress(1.0f);
            
            if (isCancelled != nil && isCancelled())
                return;
            
            if (completion != nil)
                completion(result != nil ? result : [TGMediaListPhotoDataSource resultForUnavailableImage]);
        }];
        
        if ([TGMediaListPhotoDataSource _isDataLocallyAvailableForUri:uri])
        {
            [previewTask executeWithWorkerTask:workerTask workerPool:workerPool()];
        }
        else
        {
            NSDictionary *args = [TGStringUtils argumentDictionaryInUrlString:[uri substringFromIndex:[[NSString alloc] initWithFormat:@"%@://?", [TGMediaListPhotoDataSource uriScheme]].length]];
            
            if ([args[@"legacy-thumbnail-cache-url"] respondsToSelector:@selector(characterAtIndex:)])
            {
                static NSString *filesDirectory = nil;
                static dispatch_once_t onceToken;
                dispatch_once(&onceToken, ^
                {
                    filesDirectory = [[TGAppDelegate documentsPath] stringByAppendingPathComponent:@"files"];
                });
                
                NSString *photoDirectoryName = nil;
                if (args[@"id"] != nil)
                {
                    photoDirectoryName = [[NSString alloc] initWithFormat:@"image-remote-%" PRIx64 "", (int64_t)[args[@"id"] longLongValue]];
                }
                else
                {
                    photoDirectoryName = [[NSString alloc] initWithFormat:@"image-local-%" PRIx64 "", (int64_t)[args[@"local-id"] longLongValue]];
                }
                NSString *photoDirectory = [filesDirectory stringByAppendingPathComponent:photoDirectoryName];
                
                [[NSFileManager defaultManager] createDirectoryAtPath:photoDirectory withIntermediateDirectories:true attributes:nil error:nil];
                
                NSString *temporaryThumbnailImagePath = [photoDirectory stringByAppendingPathComponent:@"image-thumb.jpg"];
                
                [previewTask executeWithTargetFilePath:temporaryThumbnailImagePath uri:args[@"legacy-thumbnail-cache-url"] completion:^(bool success)
                {
                    if (success)
                        [previewTask executeWithWorkerTask:workerTask workerPool:workerPool()];
                    else
                    {
                        if (completion != nil)
                            completion([TGMediaListPhotoDataSource resultForUnavailableImage]);
                    }
                } workerTask:workerTask];
            }
            else
            {
                if (completion != nil)
                    completion([TGMediaListPhotoDataSource resultForUnavailableImage]);
            }
        }
    }];
    
    return previewTask;
}

- (void)cancelTaskById:(id)taskId
{
    [taskManagementQueue() dispatchOnQueue:^
    {
        if ([taskId isKindOfClass:[TGMediaPreviewTask class]])
        {
            TGMediaPreviewTask *previewTask = taskId;
            [previewTask cancel];
        }
    }];
}

+ (TGDataResource *)resultForUnavailableImage
{
    static TGDataResource *imageData = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^
    {
        imageData = [[TGDataResource alloc] initWithImage:TGAverageColorImage([UIColor whiteColor]) decoded:true];
    });
    
    return imageData;
}

- (id)loadAttributeSyncForUri:(NSString *)uri attribute:(NSString *)attribute
{
    if ([attribute isEqualToString:@"placeholder"])
    {
        UIImage *reducedImage = [[TGMediaStoreContext instance] mediaReducedImage:uri attributes:NULL];
        
        if (reducedImage != nil)
            return reducedImage;
        
        NSNumber *averageColor = [[TGMediaStoreContext instance] mediaImageAverageColor:uri];
        if (averageColor != nil)
        {
            UIImage *image = TGAverageColorImage(UIColorRGB([averageColor intValue]));
            return image;
        }
        
        static UIImage *placeholder = nil;
        static dispatch_once_t onceToken;
        dispatch_once(&onceToken, ^
        {
            placeholder = TGAverageColorImage([UIColor whiteColor]);
        });
        
        return placeholder;
    }
    
    return nil;
}

- (TGDataResource *)loadDataSyncWithUri:(NSString *)uri canWait:(bool)canWait acceptPartialData:(bool)__unused acceptPartialData asyncTaskId:(__autoreleasing id *)__unused asyncTaskId progress:(void (^)(float))__unused progress partialCompletion:(void (^)(TGDataResource *))__unused partialCompletion completion:(void (^)(TGDataResource *))__unused completion
{
    if (uri == nil)
        return nil;
    
    UIImage *cachedImage = [[TGMediaStoreContext instance] mediaImage:uri attributes:nil];
    if (cachedImage != nil)
        return [[TGDataResource alloc] initWithImage:cachedImage decoded:true];
    
    if (!canWait)
        return nil;
    
    return [TGMediaListPhotoDataSource _performLoad:uri isCancelled:nil];
}

+ (bool)_isDataLocallyAvailableForUri:(NSString *)uri
{
    NSDictionary *args = [TGStringUtils argumentDictionaryInUrlString:[uri substringFromIndex:[[NSString alloc] initWithFormat:@"%@://?", [TGMediaListPhotoDataSource uriScheme]].length]];
    
    if ((![args[@"id"] respondsToSelector:@selector(longLongValue)] && ![args[@"local-id"] respondsToSelector:@selector(longLongValue)]) || ![args[@"width"] respondsToSelector:@selector(intValue)] || ![args[@"height"] respondsToSelector:@selector(intValue)] || ![args[@"renderWidth"] respondsToSelector:@selector(intValue)] || ![args[@"renderHeight"] respondsToSelector:@selector(intValue)])
    {
        return false;
    }
    
    static NSString *filesDirectory = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^
    {
        filesDirectory = [[TGAppDelegate documentsPath] stringByAppendingPathComponent:@"files"];
    });
    
    NSString *photoDirectoryName = nil;
    if (args[@"id"] != nil)
    {
        photoDirectoryName = [[NSString alloc] initWithFormat:@"image-remote-%" PRIx64 "", (int64_t)[args[@"id"] longLongValue]];
    }
    else
    {
        photoDirectoryName = [[NSString alloc] initWithFormat:@"image-local-%" PRIx64 "", (int64_t)[args[@"local-id"] longLongValue]];
    }
    NSString *photoDirectory = [filesDirectory stringByAppendingPathComponent:photoDirectoryName];
    
    CGSize size = CGSizeMake([args[@"width"] intValue], [args[@"height"] intValue]);
    CGSize renderSize = CGSizeMake([args[@"renderWidth"] intValue], [args[@"renderHeight"] intValue]);
    
    NSString *thumbnailPath = [photoDirectory stringByAppendingPathComponent:[[NSString alloc] initWithFormat:@"thumbnail-%dx%d-%dx%d.jpg", (int)size.width, (int)size.height, (int)renderSize.width, (int)renderSize.height]];
    
    if ([[NSFileManager defaultManager] fileExistsAtPath:thumbnailPath isDirectory:NULL])
        return true;
    
    NSString *imagePath = [photoDirectory stringByAppendingPathComponent:@"image.jpg"];
    if ([[NSFileManager defaultManager] fileExistsAtPath:imagePath isDirectory:NULL])
        return true;
    
    if ([args[@"legacy-file-path"] respondsToSelector:@selector(characterAtIndex:)])
    {
        NSString *legacyCacheFilePath = args[@"legacy-file-path"];
        if ([[NSFileManager defaultManager] fileExistsAtPath:legacyCacheFilePath isDirectory:NULL])
            return true;
    }
    
    NSString *temporaryThumbnailImagePath = [photoDirectory stringByAppendingPathComponent:@"image-thumb.jpg"];
    if ([[NSFileManager defaultManager] fileExistsAtPath:temporaryThumbnailImagePath isDirectory:NULL])
        return true;
    
    if ([args[@"legacy-thumbnail-cache-url"] respondsToSelector:@selector(characterAtIndex:)])
    {
        NSString *legacyThumbnailFilePath = [[TGRemoteImageView sharedCache] pathForCachedData:args[@"legacy-thumbnail-cache-url"]];
        if ([[NSFileManager defaultManager] fileExistsAtPath:legacyThumbnailFilePath isDirectory:NULL])
            return true;
    }
    
    return false;
}

+ (TGDataResource *)_performLoad:(NSString *)uri isCancelled:(bool (^)())isCancelled
{
    if (isCancelled && isCancelled())
    {
        TGLog(@"[TGPhotoMediaPreviewImageDataSource cancelled while loading %@]", uri);
        return nil;
    }
    
    NSDictionary *args = [TGStringUtils argumentDictionaryInUrlString:[uri substringFromIndex:[[NSString alloc] initWithFormat:@"%@://?", [TGMediaListPhotoDataSource uriScheme]].length]];
    
    if ((![args[@"id"] respondsToSelector:@selector(longLongValue)] && ![args[@"local-id"] respondsToSelector:@selector(longLongValue)]) || ![args[@"width"] respondsToSelector:@selector(intValue)] || ![args[@"height"] respondsToSelector:@selector(intValue)] || ![args[@"renderWidth"] respondsToSelector:@selector(intValue)] || ![args[@"renderHeight"] respondsToSelector:@selector(intValue)])
    {
        return nil;
    }
    
    static NSString *filesDirectory = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^
    {
        filesDirectory = [[TGAppDelegate documentsPath] stringByAppendingPathComponent:@"files"];
    });
    
    NSString *photoDirectoryName = nil;
    if (args[@"id"] != nil)
    {
        photoDirectoryName = [[NSString alloc] initWithFormat:@"image-remote-%" PRIx64 "", (int64_t)[args[@"id"] longLongValue]];
    }
    else
    {
        photoDirectoryName = [[NSString alloc] initWithFormat:@"image-local-%" PRIx64 "", (int64_t)[args[@"local-id"] longLongValue]];
    }
    NSString *photoDirectory = [filesDirectory stringByAppendingPathComponent:photoDirectoryName];
    
    CGSize size = CGSizeMake([args[@"width"] intValue], [args[@"height"] intValue]);
    CGSize renderSize = CGSizeMake([args[@"renderWidth"] intValue], [args[@"renderHeight"] intValue]);
    
    NSString *thumbnailPath = [photoDirectory stringByAppendingPathComponent:[[NSString alloc] initWithFormat:@"thumbnail-%dx%d-%dx%d.jpg", (int)size.width, (int)size.height, (int)renderSize.width, (int)renderSize.height]];
    
    UIImage *thumbnailSourceImage = [[UIImage alloc] initWithContentsOfFile:thumbnailPath];
    bool lowQualityThumbnail = false;
    
    if (thumbnailSourceImage == nil)
    {
        [[NSFileManager defaultManager] createDirectoryAtPath:photoDirectory withIntermediateDirectories:true attributes:nil error:nil];
        
        NSString *imagePath = [photoDirectory stringByAppendingPathComponent:@"image.jpg"];
        NSString *temporaryThumbnailImagePath = [photoDirectory stringByAppendingPathComponent:@"image-thumb.jpg"];
        UIImage *image = [[UIImage alloc] initWithContentsOfFile:imagePath];
        
        if (image == nil && [args[@"legacy-file-path"] respondsToSelector:@selector(characterAtIndex:)])
        {
            NSString *legacyCacheFilePath = args[@"legacy-file-path"];
            image = [[UIImage alloc] initWithContentsOfFile:legacyCacheFilePath];
            
            if (image != nil)
            {
                [[NSFileManager defaultManager] copyItemAtPath:legacyCacheFilePath toPath:imagePath error:nil];
            }
        }
        
        if (image == nil)
        {
            image = [[UIImage alloc] initWithContentsOfFile:temporaryThumbnailImagePath];
            lowQualityThumbnail = true;
        }
        
        if (image == nil && [args[@"legacy-thumbnail-cache-url"] respondsToSelector:@selector(characterAtIndex:)])
        {
            image = [[TGRemoteImageView sharedCache] cachedImage:args[@"legacy-thumbnail-cache-url"] availability:TGCacheDisk];
            if (image != nil)
            {
                [[NSFileManager defaultManager] copyItemAtPath:[[TGRemoteImageView sharedCache] pathForCachedData:args[@"legacy-thumbnail-cache-url"]] toPath:temporaryThumbnailImagePath error:nil];
            }
        }
        
        if (image != nil)
        {
            const float cacheFactor = 0.85f;
            CGSize cachedImageSize = CGSizeMake(CGCeil(size.width * cacheFactor), CGCeil(size.height * cacheFactor));
            CGSize cachedRenderSize = CGSizeMake(CGCeil(renderSize.width * cacheFactor), CGCeil(renderSize.height * cacheFactor));
            UIGraphicsBeginImageContextWithOptions(cachedImageSize, true, 2.0f);
            
            CGRect imageRect = CGRectMake((cachedImageSize.width - cachedRenderSize.width) / 2.0f, (cachedImageSize.height - cachedRenderSize.height) / 2.0f, cachedRenderSize.width, cachedRenderSize.height);
            [image drawInRect:imageRect blendMode:kCGBlendModeCopy alpha:1.0f];
            
            thumbnailSourceImage = UIGraphicsGetImageFromCurrentImageContext();
            UIGraphicsEndImageContext();
            
            if (thumbnailSourceImage != nil && !lowQualityThumbnail)
            {
                NSData *thumbnailSourceData = UIImageJPEGRepresentation(thumbnailSourceImage, 0.8f);
                [thumbnailSourceData writeToFile:thumbnailPath atomically:true];
            }
        }
    }
    else
    {
        UIGraphicsBeginImageContextWithOptions(thumbnailSourceImage.size, true, thumbnailSourceImage.scale);
        
        CGRect imageRect = CGRectMake(0.0f, 0.0f, thumbnailSourceImage.size.width, thumbnailSourceImage.size.height);
        [thumbnailSourceImage drawInRect:imageRect blendMode:kCGBlendModeCopy alpha:1.0f];
        
        thumbnailSourceImage = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
    }
    
    if (thumbnailSourceImage != nil)
    {
        UIImage *thumbnailImage = nil;
        
        NSNumber *averageColor = [[TGMediaStoreContext instance] mediaImageAverageColor:uri];
        bool needsAverageColor = averageColor == nil;
        uint32_t averageColorValue = [averageColor intValue];
        
        if (lowQualityThumbnail)
            thumbnailImage = TGBlurredFileImage(thumbnailSourceImage, size, needsAverageColor ? &averageColorValue : NULL, 0);
        else
        {
            thumbnailImage = thumbnailSourceImage;
            if (needsAverageColor)
                TGPlainImageAverageColor(thumbnailSourceImage, &averageColorValue);
        }

        if (thumbnailImage != nil)
        {
            [[TGMediaStoreContext instance] setMediaImageAverageColorForKey:uri averageColor:@(averageColorValue)];
            if (!lowQualityThumbnail)
                [[TGMediaStoreContext instance] setMediaImageForKey:uri image:thumbnailImage attributes:nil];
            
            return [[TGDataResource alloc] initWithImage:thumbnailImage decoded:true];
        }
    }
    
    return nil;
}

@end
