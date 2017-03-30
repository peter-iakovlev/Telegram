#import "TGGalleryVideoPreviewDataSource.h"

#import "ASQueue.h"
#import "ActionStage.h"

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

#import <AVFoundation/AVFoundation.h>

#import "TGAppDelegate.h"

@interface TGGalleryVideoPreviewDataSource () <ASWatcher>

@property (nonatomic, strong) ASHandle *actionHandle;

@end

@implementation TGGalleryVideoPreviewDataSource

+ (NSString *)uriPrefix
{
    return @"media-gallery-video-preview";
}

+ (void)load
{
    @autoreleasepool
    {
        [TGImageDataSource registerDataSource:[[self alloc] init]];
    }
}

- (instancetype)init
{
    self = [super init];
    if (self != nil)
    {
        _actionHandle = [[ASHandle alloc] initWithDelegate:self];
    }
    return self;
}

- (void)dealloc
{
    [_actionHandle reset];
    [ActionStageInstance() removeWatcher:self];
}

- (bool)canHandleUri:(NSString *)uri
{
    return [uri hasPrefix:[[NSString alloc] initWithFormat:@"%@://", [TGGalleryVideoPreviewDataSource uriPrefix]]];
}

- (bool)canHandleAttributeUri:(NSString *)uri
{
    return [uri hasPrefix:[[NSString alloc] initWithFormat:@"%@://", [TGGalleryVideoPreviewDataSource uriPrefix]]];
}

- (id)loadDataAsyncWithUri:(NSString *)uri progress:(void (^)(float))progress partialCompletion:(void (^)(TGDataResource *resource))__unused partialCompletion completion:(void (^)(TGDataResource *))completion
{
    NSString *path = [[NSString alloc] initWithFormat:@"/galleryPhoto/(%@)", uri];
    
    [ActionStageInstance() dispatchOnStageQueue:^
    {
        bool completed = false;
        bool isThumbnail = false;
        if ([TGGalleryVideoPreviewDataSource _isDataLocallyAvailableForUri:uri])
        {
            TGDataResource *result = [TGGalleryVideoPreviewDataSource _performLoad:uri isCancelled:nil];
            if (completion)
                completion(result);
            
            completed = !isThumbnail;
        }
        
        if (!completed)
        {
            NSDictionary *args = [TGStringUtils argumentDictionaryInUrlString:[uri substringFromIndex:[[NSString alloc] initWithFormat:@"%@://?", [TGGalleryVideoPreviewDataSource uriPrefix]].length]];
            
            if (args[@"legacy-thumbnail-cache-url"] != nil && args[@"id"] != nil && args[@"messageId"] != nil && args[@"conversationId"] && args[@"legacy-thumbnail-cache-url"] != nil)
            {
                [ActionStageInstance() requestActor:path options:@{
                   @"isVideo": @true,
                   @"mediaId": args[@"id"],
                   @"messageId": args[@"messageId"],
                   @"conversationId": args[@"conversationId"],
                   @"uri": args[@"legacy-thumbnail-cache-url"],
                   @"legacy-thumbnail-cache-url": args[@"legacy-thumbnail-cache-url"],
                   @"completion": ^(bool success)
                    {
                        if (success)
                        {
                            dispatch_async([TGCache diskCacheQueue], ^
                            {
                                TGDataResource *result = [TGGalleryVideoPreviewDataSource _performLoad:uri isCancelled:nil];
                                if (completion)
                                    completion(result);
                            });
                        }
                        else if (completion)
                            completion(nil);
                    },
                   @"progress": ^(float value)
                    {
                        if (progress)
                            progress(value);
                    }
                } watcher:self];
            }
        }
    }];
    
    return path;
}

+ (bool)_isDataLocallyAvailableForUri:(NSString *)uri
{
    NSDictionary *args = [TGStringUtils argumentDictionaryInUrlString:[uri substringFromIndex:[[NSString alloc] initWithFormat:@"%@://?", [self uriPrefix]].length]];
    
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
        NSString *legacyThumbnailImagePath = [[TGRemoteImageView sharedCache] pathForCachedData:args[@"legacy-thumbnail-cache-url"]];
        if ([[NSFileManager defaultManager] fileExistsAtPath:legacyThumbnailImagePath isDirectory:NULL])
            return true;
    }
    
    return false;
}

- (void)cancelTaskById:(id)taskId
{
    [ActionStageInstance() removeAllWatchersFromPath:taskId];
}

+ (TGDataResource *)resultForUnavailableImage
{
    static TGDataResource *imageData = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^
    {
        imageData = [[TGDataResource alloc] initWithImage:TGAverageColorImage([UIColor blackColor]) decoded:true];
    });
    
    return imageData;
}

- (id)loadAttributeSyncForUri:(NSString *)uri attribute:(NSString *)attribute
{
    if ([attribute isEqualToString:@"placeholder"])
    {
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
    
    if (!canWait)
        return nil;
    
    return [TGGalleryVideoPreviewDataSource _performLoad:uri isCancelled:nil];
}

+ (TGDataResource *)_performLoad:(NSString *)uri isCancelled:(bool (^)())isCancelled
{
    if (isCancelled && isCancelled())
    {
        TGLog(@"[TGPhotoMediaPreviewImageDataSource cancelled while loading %@]", uri);
        return nil;
    }
    
    NSDictionary *args = [TGStringUtils argumentDictionaryInUrlString:[uri substringFromIndex:[[NSString alloc] initWithFormat:@"%@://?", [self uriPrefix]].length]];
    
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
        
        if ([[NSFileManager defaultManager] fileExistsAtPath:videoPath isDirectory:NULL])
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
                    NSString *legacyThumbnailImagePath = [[TGRemoteImageView sharedCache] pathForCachedData:args[@"legacy-thumbnail-cache-url"]];
                    image = [[UIImage alloc] initWithContentsOfFile:legacyThumbnailImagePath];
                    
                    if (image != nil)
                    {
                        [[NSFileManager defaultManager] copyItemAtPath:legacyThumbnailImagePath toPath:temporaryThumbnailImagePath error:nil];
                    }
                }
            }
            
            lowQualityThumbnail = true;
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
        UIGraphicsBeginImageContextWithOptions(size, true, 2.0f);
        
        CGRect imageRect = CGRectMake(0.0f, 0.0f, size.width, size.height);
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
            thumbnailImage = thumbnailSourceImage;
        
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
