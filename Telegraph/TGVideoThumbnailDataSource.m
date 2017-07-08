/*
 * This is the source code of Telegram for iOS v. 1.1
 * It is licensed under GNU GPL v. 2 or later.
 * You should have received a copy of the license in this archive (see LICENSE).
 *
 * Copyright Peter Iakovlev, 2013.
 */

#import "TGVideoThumbnailDataSource.h"

#import "TGStringUtils.h"

#import "TGWorkerPool.h"
#import "TGWorkerTask.h"
#import "TGMediaPreviewTask.h"

#import "TGMemoryImageCache.h"

#import "TGImageUtils.h"
#import "TGStringUtils.h"
#import "TGRemoteImageView.h"

#import "TGImageBlur.h"
#import "UIImage+TG.h"
#import "NSObject+TGLock.h"

#import "TGMediaStoreContext.h"

#import <AVFoundation/AVFoundation.h>

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
        queue = [[ASQueue alloc] initWithName:"org.telegram.videoThumbnailTaskManagementQueue"];
    });
    
    return queue;
}

@implementation TGVideoThumbnailDataSource

+ (void)load
{
    @autoreleasepool
    {
        [TGImageDataSource registerDataSource:[[self alloc] init]];
    }
}

- (bool)canHandleUri:(NSString *)uri
{
    return [uri hasPrefix:@"video-thumbnail://"];
}

- (bool)canHandleAttributeUri:(NSString *)uri
{
    return [uri hasPrefix:@"video-thumbnail://"];
}

- (id)loadDataAsyncWithUri:(NSString *)uri progress:(void (^)(float))progress partialCompletion:(void (^)(TGDataResource *resource))__unused partialCompletion completion:(void (^)(TGDataResource *))completion
{
    TGMediaPreviewTask *previewTask = [[TGMediaPreviewTask alloc] init];
    
    NSDictionary *args = [TGStringUtils argumentDictionaryInUrlString:[uri substringFromIndex:@"video-thumbnail://?".length]];
    bool isFlat = [args[@"flat"] boolValue];
    int cornerRadius = [args[@"cornerRadius"] intValue];
    
    [taskManagementQueue() dispatchOnQueue:^
    {
        TGWorkerTask *workerTask = [[TGWorkerTask alloc] initWithBlock:^(bool (^isCancelled)())
        {
            TGDataResource *result = [TGVideoThumbnailDataSource _performLoad:uri isCancelled:isCancelled];
            
            if (result != nil && progress != nil)
                progress(1.0f);
            
            if (isCancelled != nil && isCancelled())
                return;
            
            if (completion != nil)
                completion(result != nil ? result : [TGVideoThumbnailDataSource resultForUnavailableImage:isFlat cornerRadius:cornerRadius]);
        }];
        
        if ([TGVideoThumbnailDataSource _isDataLocallyAvailableForUri:uri])
        {
            [previewTask executeWithWorkerTask:workerTask workerPool:workerPool()];
        }
        else
        {
            NSDictionary *args = [TGStringUtils argumentDictionaryInUrlString:[uri substringFromIndex:@"video-thumbnail://?".length]];
            
            if ([args[@"legacy-thumbnail-cache-url"] respondsToSelector:@selector(characterAtIndex:)])
            {
                static NSString *filesDirectory = nil;
                static dispatch_once_t onceToken;
                dispatch_once(&onceToken, ^
                {
                    filesDirectory = [[TGAppDelegate documentsPath] stringByAppendingPathComponent:@"files"];
                });
                
                NSString *videoDirectoryName = nil;
                if (args[@"id"] != nil)
                {
                    videoDirectoryName = [[NSString alloc] initWithFormat:@"video-remote-%" PRIx64 "", (int64_t)[args[@"id"] longLongValue]];
                }
                else
                {
                    videoDirectoryName = [[NSString alloc] initWithFormat:@"video-local-%" PRIx64 "", (int64_t)[args[@"local-id"] longLongValue]];                    
                }
                NSString *videoDirectory = [filesDirectory stringByAppendingPathComponent:videoDirectoryName];
                
                [[NSFileManager defaultManager] createDirectoryAtPath:videoDirectory withIntermediateDirectories:true attributes:nil error:nil];
                
                NSString *temporaryThumbnailImagePath = [videoDirectory stringByAppendingPathComponent:@"video-thumb.jpg"];
                
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
                            completion([TGVideoThumbnailDataSource resultForUnavailableImage:isFlat cornerRadius:cornerRadius]);
                    }
                } workerTask:workerTask];
            }
            else
            {
                if (completion != nil)
                    completion([TGVideoThumbnailDataSource resultForUnavailableImage:isFlat cornerRadius:cornerRadius]);
            }
        }
    }];
    
    return previewTask;
}

+ (bool)_isDataLocallyAvailableForUri:(NSString *)uri
{
    NSDictionary *args = [TGStringUtils argumentDictionaryInUrlString:[uri substringFromIndex:@"video-thumbnail://?".length]];
    
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
    
    NSString *videoDirectoryName = nil;
    if (args[@"id"] != nil)
    {
        videoDirectoryName = [[NSString alloc] initWithFormat:@"video-remote-%" PRIx64 "", (int64_t)[args[@"id"] longLongValue]];
    }
    else
    {
        videoDirectoryName = [[NSString alloc] initWithFormat:@"video-local-%" PRIx64 "", (int64_t)[args[@"local-id"] longLongValue]];
    }
    NSString *videoDirectory = [filesDirectory stringByAppendingPathComponent:videoDirectoryName];
    
    CGSize size = CGSizeMake([args[@"width"] intValue], [args[@"height"] intValue]);
    CGSize renderSize = CGSizeMake([args[@"renderWidth"] intValue], [args[@"renderHeight"] intValue]);
    
    NSString *thumbnailPath = [videoDirectory stringByAppendingPathComponent:[[NSString alloc] initWithFormat:@"thumbnail-%dx%d-%dx%d.jpg", (int)size.width, (int)size.height, (int)renderSize.width, (int)renderSize.height]];
    
    if ([[NSFileManager defaultManager] fileExistsAtPath:thumbnailPath isDirectory:NULL])
        return true;
    
    NSString *temporaryThumbnailImagePath = [videoDirectory stringByAppendingPathComponent:@"video-thumb.jpg"];
    if ([[NSFileManager defaultManager] fileExistsAtPath:temporaryThumbnailImagePath])
        return true;
    
    NSString *videoPath = [videoDirectory stringByAppendingPathComponent:@"video.mov"];
    if ([[NSFileManager defaultManager] fileExistsAtPath:videoPath isDirectory:NULL])
        return true;
    
    if ([args[@"legacy-video-file-path"] respondsToSelector:@selector(characterAtIndex:)])
    {
        NSString *legacyVideoFilePath = args[@"legacy-video-file-path"];
        if ([[NSFileManager defaultManager] fileExistsAtPath:legacyVideoFilePath isDirectory:NULL])
            return true;
    }
    
    if ([args[@"legacy-thumbnail-cache-url"] respondsToSelector:@selector(characterAtIndex:)])
    {
        NSString *legacyThumbnailImagePath = nil;
        NSString *legacyThumbnailUrl = args[@"legacy-thumbnail-cache-url"];
        
        if ([legacyThumbnailUrl hasPrefix:@"file://"])
            legacyThumbnailImagePath = [legacyThumbnailUrl substringFromIndex:@"file://".length];
        else
            legacyThumbnailImagePath = [[TGRemoteImageView sharedCache] pathForCachedData:args[@"legacy-thumbnail-cache-url"]];
        
        if ([[NSFileManager defaultManager] fileExistsAtPath:legacyThumbnailImagePath isDirectory:NULL])
            return true;
    }
    
    return false;
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
        NSDictionary *args = [TGStringUtils argumentDictionaryInUrlString:[uri substringFromIndex:@"video-thumbnail://?".length]];
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
    
    return [TGVideoThumbnailDataSource _performLoad:uri isCancelled:nil];
}

+ (TGDataResource *)_performLoad:(NSString *)uri isCancelled:(bool (^)())isCancelled
{
    if (isCancelled && isCancelled())
    {
        TGLog(@"[TGPhotoMediaPreviewImageDataSource cancelled while loading %@]", uri);
        return nil;
    }
    
    NSDictionary *args = [TGStringUtils argumentDictionaryInUrlString:[uri substringFromIndex:@"video-thumbnail://?".length]];
    
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
    
    NSString *videoDirectoryName = nil;
    bool isLocal = false;
    if (args[@"id"] != nil)
    {
        videoDirectoryName = [[NSString alloc] initWithFormat:@"video-remote-%" PRIx64 "", (int64_t)[args[@"id"] longLongValue]];
    }
    else
    {
        videoDirectoryName = [[NSString alloc] initWithFormat:@"video-local-%" PRIx64 "", (int64_t)[args[@"local-id"] longLongValue]];
        isLocal = true;
    }
    NSString *videoDirectory = [filesDirectory stringByAppendingPathComponent:videoDirectoryName];
    
    CGSize size = CGSizeMake([args[@"width"] intValue], [args[@"height"] intValue]);
    CGSize renderSize = CGSizeMake([args[@"renderWidth"] intValue], [args[@"renderHeight"] intValue]);
    
    NSString *thumbnailPath = [videoDirectory stringByAppendingPathComponent:[[NSString alloc] initWithFormat:@"thumbnail-%dx%d-%dx%d.jpg", (int)size.width, (int)size.height, (int)renderSize.width, (int)renderSize.height]];
    
    UIImage *thumbnailSourceImage = [[UIImage alloc] initWithContentsOfFile:thumbnailPath];
    bool lowQualityThumbnail = false;
    
    if (thumbnailSourceImage == nil)
    {
        [[NSFileManager defaultManager] createDirectoryAtPath:videoDirectory withIntermediateDirectories:true attributes:nil error:nil];
        
        NSString *videoPath = [videoDirectory stringByAppendingPathComponent:@"video.mov"];
        NSString *temporaryThumbnailImagePath = [videoDirectory stringByAppendingPathComponent:@"video-thumb.jpg"];
        
        if (![[NSFileManager defaultManager] fileExistsAtPath:videoPath isDirectory:NULL])
        {
            if ([args[@"legacy-video-file-path"] respondsToSelector:@selector(characterAtIndex:)])
            {
                NSString *legacyVideoFilePath = args[@"legacy-video-file-path"];
                videoPath = legacyVideoFilePath;
            }
        }
        
        UIImage *image = nil;
        
        if (![args[@"secret"] boolValue] && [[NSFileManager defaultManager] fileExistsAtPath:videoPath isDirectory:NULL])
        {
            AVAsset *asset = [AVAsset assetWithURL:[NSURL fileURLWithPath:videoPath]];
            
            AVAssetImageGenerator *imageGenerator = [[AVAssetImageGenerator alloc] initWithAsset:asset];
            imageGenerator.maximumSize = CGSizeMake(800, 800);
            imageGenerator.appliesPreferredTrackTransform = true;
            NSError *imageError = nil;
            CGImageRef imageRef = [imageGenerator copyCGImageAtTime:CMTimeMake(0, asset.duration.timescale) actualTime:NULL error:&imageError];
            image = [[UIImage alloc] initWithCGImage:imageRef];
            if (imageRef != NULL)
                CGImageRelease(imageRef);
        }
        else
        {
            image = [[UIImage alloc] initWithContentsOfFile:temporaryThumbnailImagePath];
            if (image == nil)
            {
                if ([args[@"legacy-thumbnail-cache-url"] respondsToSelector:@selector(characterAtIndex:)])
                {
                    NSString *legacyThumbnailImagePath = nil;
                    NSString *legacyThumbnailUrl = args[@"legacy-thumbnail-cache-url"];
                    
                    if ([legacyThumbnailUrl hasPrefix:@"file://"])
                        legacyThumbnailImagePath = [legacyThumbnailUrl substringFromIndex:@"file://".length];
                    else
                        legacyThumbnailImagePath = [[TGRemoteImageView sharedCache] pathForCachedData:args[@"legacy-thumbnail-cache-url"]];
                    
                    image = [[UIImage alloc] initWithContentsOfFile:legacyThumbnailImagePath];
                    
                    if (image != nil)
                    {
                        [[NSFileManager defaultManager] copyItemAtPath:legacyThumbnailImagePath toPath:temporaryThumbnailImagePath error:nil];
                    }
                }
            }
            
            if (!isLocal || image.size.width < 70)
                lowQualityThumbnail = true;
        }
        
        if (image != nil)
        {
            const float cacheFactor = 0.95f;
            CGSize cachedImageSize = CGSizeMake(CGCeil(size.width * cacheFactor), CGCeil(size.height * cacheFactor));
            CGSize cachedRenderSize = CGSizeMake(CGCeil(renderSize.width * cacheFactor), CGCeil(renderSize.height * cacheFactor));
            UIGraphicsBeginImageContextWithOptions(cachedImageSize, true, 0.0f);
            
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
        UIGraphicsBeginImageContextWithOptions(size, true, 0.0f);
        
        CGRect imageRect = CGRectMake(0.0f, 0.0f, size.width, size.height);
        [thumbnailSourceImage drawInRect:imageRect blendMode:kCGBlendModeCopy alpha:1.0f];
        
        thumbnailSourceImage = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
    }
    
    bool isFlat = [args[@"flat"] boolValue];
    int cornerRadius = [args[@"cornerRadius"] intValue];
    int inset = [args[@"inset"] intValue];
    
    if (thumbnailSourceImage != nil)
    {
        UIImage *thumbnailImage = nil;
        
        NSNumber *averageColor = [[TGMediaStoreContext instance] mediaImageAverageColor:uri];
        bool needsAverageColor = averageColor == nil;
        uint32_t averageColorValue = [averageColor intValue];
        uint32_t *averageColorPtr = needsAverageColor ? &averageColorValue : NULL;
        
        if ([args[@"secret"] boolValue])
        {
            if (isFlat && cornerRadius > 0)
                thumbnailImage = TGSecretBlurredAttachmentWithCornerRadiusImage(thumbnailSourceImage, size, needsAverageColor ? &averageColorValue : NULL, ![args[@"flat"] boolValue], cornerRadius);
            else
                thumbnailImage = TGSecretBlurredAttachmentImage(thumbnailSourceImage, size, needsAverageColor ? &averageColorValue : NULL, ![args[@"flat"] boolValue]);
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
                    thumbnailImage = TGLoadedAttachmentWithCornerRadiusImage(thumbnailSourceImage, size, averageColorPtr, !isFlat, cornerRadius, inset);
                else
                    thumbnailImage = TGLoadedAttachmentImage(thumbnailSourceImage, size, averageColorPtr, !isFlat);
            }
        }
        
        if (thumbnailImage != nil)
        {
            [[TGMediaStoreContext instance] setMediaImageAverageColorForKey:uri averageColor:@(averageColorValue)];
            if (!lowQualityThumbnail)
                [[TGMediaStoreContext instance] setMediaImageForKey:uri image:thumbnailImage attributes:nil];
            
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
    }
    
    return nil;
}

@end
