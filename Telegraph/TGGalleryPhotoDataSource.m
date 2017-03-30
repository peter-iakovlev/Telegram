#import "TGGalleryPhotoDataSource.h"

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

#import "TGDatabase.h"

#import "TGAppDelegate.h"

#import "TGSharedMediaUtils.h"

@interface TGGalleryPhotoDataSource () <ASWatcher>

@property (nonatomic, strong) ASHandle *actionHandle;

@end

@implementation TGGalleryPhotoDataSource

+ (NSString *)uriPrefix
{
    return @"media-gallery-image";
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
    return [uri hasPrefix:[[NSString alloc] initWithFormat:@"%@://", [TGGalleryPhotoDataSource uriPrefix]]];
}

- (bool)canHandleAttributeUri:(NSString *)uri
{
    return [uri hasPrefix:[[NSString alloc] initWithFormat:@"%@://", [TGGalleryPhotoDataSource uriPrefix]]];
}

- (id)loadDataAsyncWithUri:(NSString *)uri progress:(void (^)(float))progress partialCompletion:(void (^)(TGDataResource *resource))__unused partialCompletion completion:(void (^)(TGDataResource *))completion
{
    NSString *path = [[NSString alloc] initWithFormat:@"/galleryPhoto/(%@)", uri];
    
    [ActionStageInstance() dispatchOnStageQueue:^
    {
        bool completed = false;
        bool isThumbnail = false;
        if ([TGGalleryPhotoDataSource _isDataLocallyAvailableForUri:uri outIsThumbnail:&isThumbnail])
        {
            TGDataResource *result = [TGGalleryPhotoDataSource _performLoad:uri isCancelled:nil];
            if (isThumbnail)
            {
                if (partialCompletion)
                    partialCompletion(result);
            }
            else
            {
                if (completion)
                    completion(result);
            }
            
            completed = !isThumbnail;
        }
        
        NSDictionary *args = [TGStringUtils argumentDictionaryInUrlString:[uri substringFromIndex:[[NSString alloc] initWithFormat:@"%@://?", [TGGalleryPhotoDataSource uriPrefix]].length]];
        
        if (!completed)
        {
            if (progress)
                progress(0.0f);
            
            if (args[@"id"] != nil && args[@"messageId"] != nil && args[@"conversationId"] != nil && args[@"legacy-cache-url"] && args[@"legacy-thumbnail-cache-url"])
            {
                [ActionStageInstance() requestActor:path options:@{
                    @"mediaId": args[@"id"],
                    @"messageId": args[@"messageId"],
                    @"conversationId": args[@"conversationId"],
                    @"uri": args[@"legacy-cache-url"],
                    @"legacy-thumbnail-cache-url": args[@"legacy-thumbnail-cache-url"],
                    @"completion": ^(bool success)
                    {
                        if (success)
                        {
                            dispatch_async([TGCache diskCacheQueue], ^
                            {
                                TGDataResource *result = [TGGalleryPhotoDataSource _performLoad:uri isCancelled:nil];
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
        else
        {
            if (args[@"messageId"] != nil && args[@"id"] != nil)
            {
                int messageId = [args[@"messageId"] intValue];
                [TGDatabaseInstance() updateLastUseDateForMediaType:2 mediaId:[args[@"id"] longLongValue] messageId:messageId];
            }
        }
    }];

    return path;
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
        imageData = [[TGDataResource alloc] initWithImage:TGAverageColorImage([UIColor whiteColor]) decoded:true];
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
            placeholder = TGAverageColorImage([UIColor blackColor]);
        });
        
        return placeholder;
    }
    
    return nil;
}

- (TGDataResource *)loadDataSyncWithUri:(NSString *)uri canWait:(bool)canWait acceptPartialData:(bool)acceptPartialData asyncTaskId:(__autoreleasing id *)asyncTaskId progress:(void (^)(float))progress partialCompletion:(void (^)(TGDataResource *))partialCompletion completion:(void (^)(TGDataResource *))completion
{
    if (uri == nil)
        return nil;
    
    if (!canWait)
        return nil;
    
    bool isThumbnail = false;
    if ([TGGalleryPhotoDataSource _isDataLocallyAvailableForUri:uri outIsThumbnail:&isThumbnail])
    {
        TGDataResource *partialData = [TGGalleryPhotoDataSource _performLoad:uri isCancelled:nil];
        
        if (isThumbnail && acceptPartialData && asyncTaskId != NULL)
        {
            *asyncTaskId = [self loadDataAsyncWithUri:uri progress:progress partialCompletion:partialCompletion completion:completion];
        }
        else
        {
            NSDictionary *args = [TGStringUtils argumentDictionaryInUrlString:[uri substringFromIndex:[[NSString alloc] initWithFormat:@"%@://?", [TGGalleryPhotoDataSource uriPrefix]].length]];
            if (args[@"messageId"] != nil && args[@"id"] != nil)
            {
                int messageId = [args[@"messageId"] intValue];
                [TGDatabaseInstance() updateLastUseDateForMediaType:2 mediaId:[args[@"id"] longLongValue] messageId:messageId];
            }
        }
        
        return partialData;
    }
    
    return nil;
}

+ (bool)_isDataLocallyAvailableForUri:(NSString *)uri outIsThumbnail:(bool *)outIsThumbnail
{
    NSDictionary *args = [TGStringUtils argumentDictionaryInUrlString:[uri substringFromIndex:[[NSString alloc] initWithFormat:@"%@://?", [TGGalleryPhotoDataSource uriPrefix]].length]];
    
    NSString *legacyCacheUrl = args[@"legacy-cache-url"];
    if ([legacyCacheUrl hasPrefix:@"webdoc"]) {
        return true;
    }
    
    if ((![args[@"id"] respondsToSelector:@selector(longLongValue)] && ![args[@"local-id"] respondsToSelector:@selector(longLongValue)]))
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
    CGSize renderSize = size;
    
    NSString *imagePath = [photoDirectory stringByAppendingPathComponent:@"image.jpg"];
    if ([[NSFileManager defaultManager] fileExistsAtPath:imagePath isDirectory:NULL])
        return true;
    
    if ([args[@"legacy-file-path"] respondsToSelector:@selector(characterAtIndex:)])
    {
        NSString *legacyCacheFilePath = args[@"legacy-file-path"];
        if ([[NSFileManager defaultManager] fileExistsAtPath:legacyCacheFilePath isDirectory:NULL])
            return true;
    }
    
    NSString *thumbnailPath = [photoDirectory stringByAppendingPathComponent:[[NSString alloc] initWithFormat:@"thumbnail-%dx%d-%dx%d.jpg", (int)size.width, (int)size.height, (int)renderSize.width, (int)renderSize.height]];
    
    if ([[NSFileManager defaultManager] fileExistsAtPath:thumbnailPath isDirectory:NULL])
    {
        if (outIsThumbnail != NULL)
            *outIsThumbnail = true;
        
        return true;
    }
    
    NSString *temporaryThumbnailImagePath = [photoDirectory stringByAppendingPathComponent:@"image-thumb.jpg"];
    if ([[NSFileManager defaultManager] fileExistsAtPath:temporaryThumbnailImagePath isDirectory:NULL])
    {
        if (outIsThumbnail != NULL)
            *outIsThumbnail = true;
        
        return true;
    }
    
    if ([args[@"legacy-thumbnail-cache-url"] respondsToSelector:@selector(characterAtIndex:)])
    {
        NSString *legacyThumbnailFilePath = [[TGRemoteImageView sharedCache] pathForCachedData:args[@"legacy-thumbnail-cache-url"]];
        if ([[NSFileManager defaultManager] fileExistsAtPath:legacyThumbnailFilePath isDirectory:NULL])
        {
            if (outIsThumbnail != NULL)
                *outIsThumbnail = true;
            
            return true;
        }
    }
    
    return false;
}

+ (TGDataResource *)_performLoad:(NSString *)uri isCancelled:(bool (^)())isCancelled
{
    if (isCancelled && isCancelled())
    {
        TGLog(@"[TGGalleryPhotoDataSource cancelled while loading %@]", uri);
        return nil;
    }
    
    NSDictionary *args = [TGStringUtils argumentDictionaryInUrlString:[uri substringFromIndex:[[NSString alloc] initWithFormat:@"%@://?", [TGGalleryPhotoDataSource uriPrefix]].length]];
    
    NSString *legacyCacheUrl = args[@"legacy-cache-url"];
    if ([legacyCacheUrl hasPrefix:@"webdoc"]) {
        NSData *data = [[TGSharedMediaUtils sharedMediaTemporaryPersistentCache] getValueForKey:[legacyCacheUrl dataUsingEncoding:NSUTF8StringEncoding]];
        if (data != nil) {
            return [[TGDataResource alloc] initWithImage:[UIImage imageWithData:data] decoded:false];
        }
        return nil;
    }
    
    if ((![args[@"id"] respondsToSelector:@selector(longLongValue)] && ![args[@"local-id"] respondsToSelector:@selector(longLongValue)]) || ![args[@"width"] respondsToSelector:@selector(intValue)] || ![args[@"height"] respondsToSelector:@selector(intValue)])
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
    CGSize renderSize = size;
    
    NSString *imagePath = [photoDirectory stringByAppendingPathComponent:@"image.jpg"];
    UIImage *imageSourceImage = [[UIImage alloc] initWithContentsOfFile:imagePath];
    if (imageSourceImage == nil && [args[@"legacy-file-path"] respondsToSelector:@selector(characterAtIndex:)])
    {
        NSString *legacyCacheFilePath = args[@"legacy-file-path"];
        imageSourceImage = [[UIImage alloc] initWithContentsOfFile:legacyCacheFilePath];
        
        //TODO: remove legacy
        //if (imageSourceImage != nil)
        //    [[NSFileManager defaultManager] copyItemAtPath:legacyCacheFilePath toPath:imagePath error:nil];
    }
    
    if (imageSourceImage != nil)
    {
        /*TG_TIMESTAMP_DEFINE(bpgencode)
        NSData *bpgData = [imageSourceImage encodeWithBPG];
        TG_TIMESTAMP_MEASURE(bpgencode)
        imageSourceImage = [UIImage imageWithBPGData:bpgData];
        TG_TIMESTAMP_MEASURE(bpgencode)*/
        
        UIGraphicsBeginImageContextWithOptions(imageSourceImage.size, true, imageSourceImage.scale);
        
        CGRect imageRect = CGRectMake(0.0f, 0.0f, imageSourceImage.size.width, imageSourceImage.size.height);
        [imageSourceImage drawInRect:imageRect blendMode:kCGBlendModeCopy alpha:1.0f];
        
        imageSourceImage = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
    }
    
    UIImage *thumbnailSourceImage = nil;
    bool lowQualityThumbnail = false;
    
    if (imageSourceImage == nil)
    {
        NSString *thumbnailPath = [photoDirectory stringByAppendingPathComponent:[[NSString alloc] initWithFormat:@"thumbnail-%dx%d-%dx%d.jpg", (int)size.width, (int)size.height, (int)renderSize.width, (int)renderSize.height]];
        
        thumbnailSourceImage = [[UIImage alloc] initWithContentsOfFile:thumbnailPath];
        lowQualityThumbnail = false;
        
        if (thumbnailSourceImage == nil)
        {
            [[NSFileManager defaultManager] createDirectoryAtPath:photoDirectory withIntermediateDirectories:true attributes:nil error:nil];
            
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
    }
    
    if (imageSourceImage != nil || thumbnailSourceImage != nil)
    {
        UIImage *sourceImage = imageSourceImage != nil ? imageSourceImage : thumbnailSourceImage;
        
        UIImage *image = nil;
        
        NSNumber *averageColor = [[TGMediaStoreContext instance] mediaImageAverageColor:uri];
        bool needsAverageColor = averageColor == nil;
        uint32_t averageColorValue = [averageColor intValue];
        
        if (lowQualityThumbnail)
            image = TGBlurredFileImage(sourceImage, size, needsAverageColor ? &averageColorValue : NULL, 0);
        else
            image = sourceImage;
        
        if (image != nil)
        {
            [[TGMediaStoreContext instance] setMediaImageAverageColorForKey:uri averageColor:@(averageColorValue)];
            
            return [[TGDataResource alloc] initWithImage:image decoded:true];
        }
    }
    
    return nil;
}

@end
