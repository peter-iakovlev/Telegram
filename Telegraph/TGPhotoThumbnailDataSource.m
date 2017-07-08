/*
 * This is the source code of Telegram for iOS v. 1.1
 * It is licensed under GNU GPL v. 2 or later.
 * You should have received a copy of the license in this archive (see LICENSE).
 *
 * Copyright Peter Iakovlev, 2013.
 */

#import "TGPhotoThumbnailDataSource.h"

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
        queue = [[ASQueue alloc] initWithName:"org.telegram.photoThumbnailTaskManagementQueue"];
    });
    
    return queue;
}

@interface TGPhotoThumbnailDataSource ()
{
}

@end

@implementation TGPhotoThumbnailDataSource

+ (void)load
{
    @autoreleasepool
    {
        [TGImageDataSource registerDataSource:[[self alloc] init]];
    }
}

- (bool)canHandleUri:(NSString *)uri
{
    return [uri hasPrefix:@"photo-thumbnail://"];
}

- (bool)canHandleAttributeUri:(NSString *)uri
{
    return [uri hasPrefix:@"photo-thumbnail://"];
}

- (id)loadDataAsyncWithUri:(NSString *)uri progress:(void (^)(float))progress partialCompletion:(void (^)(TGDataResource *resource))__unused partialCompletion completion:(void (^)(TGDataResource *))completion
{
    TGMediaPreviewTask *previewTask = [[TGMediaPreviewTask alloc] init];
    
    NSDictionary *args = [TGStringUtils argumentDictionaryInUrlString:[uri substringFromIndex:@"photo-thumbnail://?".length]];
    bool isFlat = [args[@"flat"] boolValue];
    int cornerRadius = [args[@"cornerRadius"] intValue];
    
    [taskManagementQueue() dispatchOnQueue:^
    {
        TGWorkerTask *workerTask = [[TGWorkerTask alloc] initWithBlock:^(bool (^isCancelled)())
        {
            TGDataResource *result = [TGPhotoThumbnailDataSource _performLoad:uri isCancelled:isCancelled];
            
            if (result != nil && progress != nil)
                progress(1.0f);
            
            if (isCancelled != nil && isCancelled())
                return;
            
            if (completion != nil)
                completion(result != nil ? result : [TGPhotoThumbnailDataSource resultForUnavailableImage:isFlat cornerRadius:cornerRadius]);
        }];

        if ([TGPhotoThumbnailDataSource _isDataLocallyAvailableForUri:uri])
        {
            [previewTask executeWithWorkerTask:workerTask workerPool:workerPool()];
        }
        else
        {
            NSDictionary *args = [TGStringUtils argumentDictionaryInUrlString:[uri substringFromIndex:@"photo-thumbnail://?".length]];
            
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
                    {
                        dispatch_async([TGCache diskCacheQueue], ^
                        {
                            [previewTask executeWithWorkerTask:workerTask workerPool:workerPool()];
                        });
                    }
                    else
                    {
                        if (completion != nil)
                            completion([TGPhotoThumbnailDataSource resultForUnavailableImage:isFlat cornerRadius:cornerRadius]);
                    }
                } workerTask:workerTask];
            }
            else
            {
                if (completion != nil)
                    completion([TGPhotoThumbnailDataSource resultForUnavailableImage:isFlat cornerRadius:cornerRadius]);
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

+ (TGDataResource *)resultForUnavailableImage:(bool)isFlat cornerRadius:(int)cornerRadius
{
    static TGDataResource *normalData = nil;
    static NSMutableDictionary *flatDatas = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^
    {
        normalData = [[TGDataResource alloc] initWithImage:TGAverageColorAttachmentImage([UIColor whiteColor], true) decoded:true];
        flatDatas = [[NSMutableDictionary alloc] init];
    });
    
    if (isFlat)
    {
        TGDataResource *flatData = flatDatas[@(cornerRadius)];
        if (flatData == nil)
        {
            if (cornerRadius == 0)
            {
                flatData = [[TGDataResource alloc] initWithImage:TGAverageColorAttachmentImage([UIColor whiteColor], false) decoded:true];
            }
            else
            {
                flatData = [[TGDataResource alloc] initWithImage:TGAverageColorAttachmentWithCornerRadiusImage([UIColor whiteColor], false, cornerRadius) decoded:true];
            }
            
            flatDatas[@(cornerRadius)] = flatData;
        }
        return flatData;
    }
    else
    {
        return normalData;
    }
}

- (id)loadAttributeSyncForUri:(NSString *)uri attribute:(NSString *)attribute
{
    if ([attribute isEqualToString:@"placeholder"])
    {
        NSDictionary *args = [TGStringUtils argumentDictionaryInUrlString:[uri substringFromIndex:@"photo-thumbnail://?".length]];
        bool isFlat = [args[@"flat"] boolValue];
        int cornerRadius = [args[@"cornerRadius"] intValue];
        
        UIImage *reducedImage = [[TGMediaStoreContext instance] mediaReducedImage:uri attributes:NULL];
        
        if (reducedImage != nil)
            return reducedImage;
        
        NSNumber *averageColor = [[TGMediaStoreContext instance] mediaImageAverageColor:uri];
        if (averageColor != nil)
        {
            UIImage *image = nil;
            if (isFlat && cornerRadius > 0)
                image = TGAverageColorAttachmentWithCornerRadiusImage(UIColorRGB([averageColor intValue]), !isFlat, cornerRadius);
            else
                image = TGAverageColorAttachmentImage(UIColorRGB([averageColor intValue]), !isFlat);
            return image;
        }
        
        static UIImage *normalPlaceholder = nil;
        static NSMutableDictionary *flatPlaceholders = nil;
        static dispatch_once_t onceToken;
        dispatch_once(&onceToken, ^
        {
            normalPlaceholder = TGAverageColorAttachmentImage([UIColor whiteColor], true);
            flatPlaceholders = [[NSMutableDictionary alloc] init];
        });
        
        if (isFlat)
        {
            UIImage *flatPlaceholder = flatPlaceholders[@(cornerRadius)];
            if (flatPlaceholder == nil)
            {
                if (cornerRadius == 0)
                    flatPlaceholder = TGAverageColorAttachmentImage([UIColor whiteColor], false);
                else
                    flatPlaceholder = TGAverageColorAttachmentWithCornerRadiusImage([UIColor whiteColor], false, cornerRadius);
                
                flatPlaceholders[@(cornerRadius)] = flatPlaceholder;
            }
            return flatPlaceholder;
        }
        else
        {
            return normalPlaceholder;
        }
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
    
    return [TGPhotoThumbnailDataSource _performLoad:uri isCancelled:nil];
}

+ (bool)_isDataLocallyAvailableForUri:(NSString *)uri
{
    NSDictionary *args = [TGStringUtils argumentDictionaryInUrlString:[uri substringFromIndex:@"photo-thumbnail://?".length]];
    
    if ((![args[@"id"] respondsToSelector:@selector(longLongValue)] && ![args[@"local-id"] respondsToSelector:@selector(longLongValue)]) || ![args[@"width"] respondsToSelector:@selector(intValue)] || ![args[@"height"] respondsToSelector:@selector(intValue)] || ![args[@"renderWidth"] respondsToSelector:@selector(intValue)] || ![args[@"renderHeight"] respondsToSelector:@selector(intValue)])
    {
        return false;
    }
    
    NSString *imageUrl = args[@"legacy-thumbnail-cache-url"];
    if (imageUrl.length != 0)
    {
        if ([imageUrl hasPrefix:@"http://"] || [imageUrl hasPrefix:@"https://"])
        {
            return [[[TGMediaStoreContext instance] temporaryFilesCache] containsValueForKey:[imageUrl dataUsingEncoding:NSUTF8StringEncoding]];
        }
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
    
    NSDictionary *args = [TGStringUtils argumentDictionaryInUrlString:[uri substringFromIndex:@"photo-thumbnail://?".length]];
    
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
            if (image != nil)
                lowQualityThumbnail = true;
        }
        
        if (image == nil && [args[@"legacy-thumbnail-cache-url"] respondsToSelector:@selector(characterAtIndex:)])
        {
            image = [[TGRemoteImageView sharedCache] cachedImage:args[@"legacy-thumbnail-cache-url"] availability:TGCacheDisk];
            if (image != nil)
            {
                [[NSFileManager defaultManager] copyItemAtPath:[[TGRemoteImageView sharedCache] pathForCachedData:args[@"legacy-thumbnail-cache-url"]] toPath:temporaryThumbnailImagePath error:nil];
                lowQualityThumbnail = true;
            }
        }
        
        if (image == nil)
        {
            NSString *imageUrl = args[@"legacy-thumbnail-cache-url"];
            if (imageUrl.length != 0)
            {
                if ([imageUrl hasPrefix:@"http://"] || [imageUrl hasPrefix:@"https://"])
                {
                    NSData *imageData = [[[TGMediaStoreContext instance] temporaryFilesCache] getValueForKey:[imageUrl dataUsingEncoding:NSUTF8StringEncoding]];
                    if (imageData != nil)
                    {
                        image = [[UIImage alloc] initWithData:imageData];
                        if (image != nil)
                            lowQualityThumbnail = true;
                    }
                }
            }
        }
        
        if (image != nil)
        {
            const float cacheFactor = 1.0f;
            CGSize cachedImageSize = CGSizeMake(CGCeil(size.width * cacheFactor), CGCeil(size.height * cacheFactor));
            CGSize cachedRenderSize = CGSizeMake(CGCeil(renderSize.width * cacheFactor), CGCeil(renderSize.height * cacheFactor));
            UIGraphicsBeginImageContextWithOptions(cachedImageSize, true, 2.0f);
            
            CGRect imageRect = CGRectMake((cachedImageSize.width - cachedRenderSize.width) / 2.0f, (cachedImageSize.height - cachedRenderSize.height) / 2.0f, cachedRenderSize.width, cachedRenderSize.height);
            [image drawInRect:imageRect blendMode:kCGBlendModeCopy alpha:1.0f];
            
            thumbnailSourceImage = UIGraphicsGetImageFromCurrentImageContext();
            UIGraphicsEndImageContext();
            
            if (thumbnailSourceImage != nil && !lowQualityThumbnail)
            {
                NSData *thumbnailSourceData = UIImageJPEGRepresentation(thumbnailSourceImage, 0.85f);
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
    
    bool isFlat = [args[@"flat"] boolValue];
    int cornerRadius = [args[@"cornerRadius"] intValue];
    
    if (thumbnailSourceImage != nil)
    {
        UIImage *thumbnailImage = nil;
        
        NSNumber *averageColor = [[TGMediaStoreContext instance] mediaImageAverageColor:uri];
        bool needsAverageColor = averageColor == nil;
        uint32_t averageColorValue = [averageColor intValue];
        uint32_t *averageColorPtr = needsAverageColor ? &averageColorValue : NULL;
        
        if ([args[@"secret"] boolValue])
        {
            thumbnailImage = TGSecretBlurredAttachmentImage(thumbnailSourceImage, size, averageColorPtr, ![args[@"flat"] boolValue]);
        }
        else
        {
            if (lowQualityThumbnail)
            {
                if (isFlat && cornerRadius > 0)
                    thumbnailImage = TGBlurredAttachmentWithCornerRadiusImage(thumbnailSourceImage, size, averageColorPtr, !isFlat, cornerRadius);
                else
                    thumbnailImage = TGBlurredAttachmentImage(thumbnailSourceImage, size, averageColorPtr, !isFlat);
            }
            else
            {
                if (isFlat && cornerRadius > 0)
                    thumbnailImage = TGLoadedAttachmentWithCornerRadiusImage(thumbnailSourceImage, size, averageColorPtr, !isFlat, cornerRadius, 0);
                else
                    thumbnailImage = TGLoadedAttachmentImage(thumbnailSourceImage, size, averageColorPtr, !isFlat);
            }
        }
        
        if (thumbnailImage != nil)
        {
            [[TGMediaStoreContext instance] setMediaImageAverageColorForKey:uri averageColor:@(averageColorValue)];
            if (!lowQualityThumbnail)
                [[TGMediaStoreContext instance] setMediaImageForKey:uri image:thumbnailImage attributes:nil];
            
            //TGLog(@"[TGPhotoMediaPreviewImageDataSource loaded %@ in %f/%f ms]", uri, (CFAbsoluteTimeGetCurrent() - time1) * 1000.0, (CFAbsoluteTimeGetCurrent() - startTime) * 1000.0);
            
            NSDictionary *imageAttachments = [thumbnailImage attachmentsDictionary];
            
            [[TGMediaStoreContext instance] inMediaReducedImageCacheGenerationQueue:^
            {
                __autoreleasing NSDictionary *attributes = nil;
                bool alreadyCached = [[TGMediaStoreContext instance] mediaReducedImage:uri attributes:&attributes];
                bool cachedLowQualityThumbnail = [attributes[@"lowQuality"] boolValue];
                
                if (!alreadyCached || (cachedLowQualityThumbnail && !lowQualityThumbnail))
                {
                    UIImage *cachedImage = nil;
                    if (isFlat && cornerRadius > 0)
                        cachedImage = TGReducedAttachmentWithCornerRadiusImage(thumbnailImage, size, !isFlat, cornerRadius);
                    else
                        cachedImage = TGReducedAttachmentImage(thumbnailImage, size, !isFlat);
                    [cachedImage setAttachmentsFromDictionary:imageAttachments];
                    
                    if (cachedImage != nil)
                    {
                        [[TGMediaStoreContext instance] setMediaReducedImageForKey:uri reducedImage:cachedImage attributes:@{@"lowQuality": @(lowQualityThumbnail)}];
                    }
                }
            }];
            
            return [[TGDataResource alloc] initWithImage:thumbnailImage decoded:true];
        }
    } else {
        TGLog(@"Couldn't generate thumbnail");
    }
    
    return nil;
}

@end
