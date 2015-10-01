#import "TGPeerAvatarImageDataSource.h"

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
        queue = [[ASQueue alloc] initWithName:"org.telegram.peerAvatarTaskManagementQueue"];
    });
    
    return queue;
}

@interface TGPeerAvatarImageDataSource ()

@end

@implementation TGPeerAvatarImageDataSource

+ (NSString *)uriPrefix
{
    return @"peer-avatar";
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
    }
    return self;
}

- (bool)canHandleUri:(NSString *)uri
{
    return [uri hasPrefix:[[NSString alloc] initWithFormat:@"%@://", [TGPeerAvatarImageDataSource uriPrefix]]];
}

- (bool)canHandleAttributeUri:(NSString *)uri
{
    return [uri hasPrefix:[[NSString alloc] initWithFormat:@"%@://", [TGPeerAvatarImageDataSource uriPrefix]]];
}

- (id)loadDataAsyncWithUri:(NSString *)uri progress:(void (^)(float))progress partialCompletion:(void (^)(TGDataResource *resource))__unused partialCompletion completion:(void (^)(TGDataResource *))completion
{
    TGMediaPreviewTask *previewTask = [[TGMediaPreviewTask alloc] init];
    
    [taskManagementQueue() dispatchOnQueue:^
    {
        TGWorkerTask *workerTask = [[TGWorkerTask alloc] initWithBlock:^(bool (^isCancelled)())
        {
            TGDataResource *result = [TGPeerAvatarImageDataSource _performLoad:uri isCancelled:isCancelled];
            
            if (result != nil && progress != nil)
                progress(1.0f);
            
            if (isCancelled != nil && isCancelled())
                return;
            
            if (completion != nil)
                completion(result != nil ? result : [TGPeerAvatarImageDataSource resultForUnavailableImage]);
        }];
        
        bool isThumbnail = false;
        bool completed = false;
        if ([TGPeerAvatarImageDataSource _isDataLocallyAvailableForUri:uri outIsThumbnail:&isThumbnail])
        {
            TGDataResource *result = [TGPeerAvatarImageDataSource _performLoad:uri isCancelled:nil];
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
        
        if (!completed)
        {
            NSDictionary *args = [TGStringUtils argumentDictionaryInUrlString:[uri substringFromIndex:[[NSString alloc] initWithFormat:@"%@://?", [TGPeerAvatarImageDataSource uriPrefix]].length]];
            
            if ([args[@"legacy-cache-url"] respondsToSelector:@selector(characterAtIndex:)])
            {
                if (progress)
                    progress(0.0);
                [previewTask executeWithTargetFilePath:nil uri:args[@"legacy-cache-url"] progress:^(float value)
                {
                    if (progress)
                        progress(value);
                } completion:^(bool success)
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
                            completion([TGPeerAvatarImageDataSource resultForUnavailableImage]);
                    }
                } workerTask:workerTask];
            }
            else
            {
                if (completion != nil)
                    completion([TGPeerAvatarImageDataSource resultForUnavailableImage]);
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
            placeholder = TGAverageColorImage([UIColor blackColor]);
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
    
    bool isThumbnail = false;
    if ([TGPeerAvatarImageDataSource _isDataLocallyAvailableForUri:uri outIsThumbnail:&isThumbnail])
    {
        TGDataResource *partialData = [TGPeerAvatarImageDataSource _performLoad:uri isCancelled:nil];
        
        if (isThumbnail && acceptPartialData && asyncTaskId != NULL)
        {
            *asyncTaskId = [self loadDataAsyncWithUri:uri progress:progress partialCompletion:partialCompletion completion:completion];
        }
        
        return partialData;
    }
    
    return [TGPeerAvatarImageDataSource _performLoad:uri isCancelled:nil];
}

+ (bool)_isDataLocallyAvailableForUri:(NSString *)uri outIsThumbnail:(bool *)outIsThumbnail
{
    NSDictionary *args = [TGStringUtils argumentDictionaryInUrlString:[uri substringFromIndex:[[NSString alloc] initWithFormat:@"%@://?", [TGPeerAvatarImageDataSource uriPrefix]].length]];
    
    if (![args[@"width"] respondsToSelector:@selector(intValue)] || ![args[@"height"] respondsToSelector:@selector(intValue)])
    {
        return false;
    }
    
    if ([args[@"legacy-cache-url"] respondsToSelector:@selector(characterAtIndex:)])
    {
        NSString *legacyCacheFilePath = [[TGRemoteImageView sharedCache] pathForCachedData:args[@"legacy-cache-url"]];
        if ([[NSFileManager defaultManager] fileExistsAtPath:legacyCacheFilePath isDirectory:NULL])
            return true;
    }
    
    if ([args[@"legacy-thumbnail-cache-url"] respondsToSelector:@selector(characterAtIndex:)])
    {
        NSString *legacyThumbnailFilePath = [[TGRemoteImageView sharedCache] pathForCachedData:args[@"legacy-thumbnail-cache-url"]];
        if ([[NSFileManager defaultManager] fileExistsAtPath:legacyThumbnailFilePath isDirectory:NULL])
        {
            if (outIsThumbnail)
                *outIsThumbnail = true;
            return true;
        }
    }
    
    return false;
}

+ (TGDataResource *)_performLoad:(NSString *)uri isCancelled:(bool (^)())isCancelled
{
    if (isCancelled && isCancelled())
        return nil;
    
    NSDictionary *args = [TGStringUtils argumentDictionaryInUrlString:[uri substringFromIndex:[[NSString alloc] initWithFormat:@"%@://?", [TGPeerAvatarImageDataSource uriPrefix]].length]];
    
    if (![args[@"width"] respondsToSelector:@selector(intValue)] || ![args[@"height"] respondsToSelector:@selector(intValue)])
    {
        return nil;
    }
    
    CGSize size = CGSizeMake([args[@"width"] intValue], [args[@"height"] intValue]);
    
    UIImage *image = nil;
    bool lowQualityThumbnail = false;
    bool decoded = false;
    
    if ([args[@"legacy-cache-url"] respondsToSelector:@selector(characterAtIndex:)])
    {
        image = [[TGRemoteImageView sharedCache] cachedImage:args[@"legacy-cache-url"] availability:TGCacheDisk];
    }
    if (image == nil && [args[@"legacy-thumbnail-cache-url"] respondsToSelector:@selector(characterAtIndex:)])
    {
        image = [[TGRemoteImageView sharedCache] cachedImage:args[@"legacy-thumbnail-cache-url"] availability:TGCacheDisk];
        lowQualityThumbnail = true;
    }
    
    if (image != nil)
    {
        NSNumber *averageColor = [[TGMediaStoreContext instance] mediaImageAverageColor:uri];
        bool needsAverageColor = averageColor == nil;
        uint32_t averageColorValue = [averageColor intValue];
        
        if (lowQualityThumbnail)
        {
            image = TGBlurredFileImage(image, size, needsAverageColor ? &averageColorValue : NULL, 0);
            decoded = true;
        }
        
        if (image != nil)
        {
            if (needsAverageColor)
                [[TGMediaStoreContext instance] setMediaImageAverageColorForKey:uri averageColor:@(averageColorValue)];
            
            return [[TGDataResource alloc] initWithImage:image decoded:decoded];
        }
    }
    
    return nil;
}

@end
