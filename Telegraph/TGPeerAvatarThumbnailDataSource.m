#import "TGPeerAvatarThumbnailDataSource.h"

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
        queue = [[ASQueue alloc] initWithName:"org.telegram.peerAvatarThumbnailTaskManagementQueue"];
    });
    
    return queue;
}

@implementation TGPeerAvatarThumbnailDataSource

+ (NSString *)uriPrefix
{
    return @"peer-avatar-thumbnail";
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
    return [uri hasPrefix:[[NSString alloc] initWithFormat:@"%@://", [TGPeerAvatarThumbnailDataSource uriPrefix]]];
}

- (bool)canHandleAttributeUri:(NSString *)uri
{
    return [uri hasPrefix:[[NSString alloc] initWithFormat:@"%@://", [TGPeerAvatarThumbnailDataSource uriPrefix]]];
}

- (id)loadDataAsyncWithUri:(NSString *)uri progress:(void (^)(float))progress partialCompletion:(void (^)(TGDataResource *resource))__unused partialCompletion completion:(void (^)(TGDataResource *))completion
{
    TGMediaPreviewTask *previewTask = [[TGMediaPreviewTask alloc] init];
    
    [taskManagementQueue() dispatchOnQueue:^
    {
        NSDictionary *args = [TGStringUtils argumentDictionaryInUrlString:[uri substringFromIndex:[[NSString alloc] initWithFormat:@"%@://?", [TGPeerAvatarThumbnailDataSource uriPrefix]].length]];
        
        if (![args[@"width"] respondsToSelector:@selector(intValue)] || ![args[@"height"] respondsToSelector:@selector(intValue)])
        {
            return;
        }
        
        CGSize size = CGSizeMake([args[@"width"] intValue], [args[@"height"] intValue]);
        
        TGWorkerTask *workerTask = [[TGWorkerTask alloc] initWithBlock:^(bool (^isCancelled)())
        {
            TGDataResource *result = [TGPeerAvatarThumbnailDataSource _performLoad:uri isCancelled:isCancelled];
            
            if (result != nil && progress != nil)
                progress(1.0f);
            
            if (isCancelled != nil && isCancelled())
                return;
            
            if (completion != nil)
                completion(result != nil ? result : [TGPeerAvatarThumbnailDataSource resultForUnavailableImage:size]);
        }];
        
        bool completed = false;
        if ([TGPeerAvatarThumbnailDataSource _isDataLocallyAvailableForUri:uri])
        {
            TGDataResource *result = [TGPeerAvatarThumbnailDataSource _performLoad:uri isCancelled:nil];
            if (result != nil)
            {
                completed = true;
                
                if (completion)
                    completion(result);
            }
        }
        
        if (!completed)
        {
            NSDictionary *args = [TGStringUtils argumentDictionaryInUrlString:[uri substringFromIndex:[[NSString alloc] initWithFormat:@"%@://?", [TGPeerAvatarThumbnailDataSource uriPrefix]].length]];
            
            if ([args[@"legacy-thumbnail-cache-url"] respondsToSelector:@selector(characterAtIndex:)])
            {
                [previewTask executeWithTargetFilePath:nil uri:args[@"legacy-thumbnail-cache-url"] completion:^(bool success)
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
                            completion([TGPeerAvatarThumbnailDataSource resultForUnavailableImage:size]);
                    }
                } workerTask:workerTask];
            }
            else
            {
                if (completion != nil)
                    completion([TGPeerAvatarThumbnailDataSource resultForUnavailableImage:size]);
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

+ (TGDataResource *)resultForUnavailableImage:(CGSize)size
{
    static TGDataResource *imageData = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^
    {
        imageData = [[TGDataResource alloc] initWithImage:TGAverageColorRoundImage([UIColor whiteColor], size) decoded:true];
    });
    
    return imageData;
}

- (id)loadAttributeSyncForUri:(NSString *)uri attribute:(NSString *)attribute
{
    NSDictionary *args = [TGStringUtils argumentDictionaryInUrlString:[uri substringFromIndex:[[NSString alloc] initWithFormat:@"%@://?", [TGPeerAvatarThumbnailDataSource uriPrefix]].length]];
    
    if (![args[@"width"] respondsToSelector:@selector(intValue)] || ![args[@"height"] respondsToSelector:@selector(intValue)])
    {
        return nil;
    }
    
    __unused CGSize size = CGSizeMake([args[@"width"] intValue], [args[@"height"] intValue]);
    
    if ([attribute isEqualToString:@"placeholder"])
    {
        NSNumber *averageColor = [[TGMediaStoreContext instance] mediaImageAverageColor:uri];
        if (averageColor != nil)
        {
            UIImage *image = TGAverageColorRoundImage(UIColorRGB([averageColor intValue]), size);
            return image;
        }
        
        static UIImage *placeholder = nil;
        static dispatch_once_t onceToken;
        dispatch_once(&onceToken, ^
        {
            placeholder = TGAverageColorRoundImage([UIColor whiteColor], size);
        });
        
        return placeholder;
    }
    
    return nil;
}

- (TGDataResource *)loadDataSyncWithUri:(NSString *)uri canWait:(bool)canWait acceptPartialData:(bool)__unused acceptPartialData asyncTaskId:(__autoreleasing id *)__unused asyncTaskId progress:(void (^)(float))__unused progress partialCompletion:(void (^)(TGDataResource *))__unused partialCompletion completion:(void (^)(TGDataResource *))__unused completion
{
    if (uri == nil)
        return nil;
    
    UIImage *cachedImage = [[TGRemoteImageView sharedCache] cachedImage:uri availability:TGCacheMemory];
    if (cachedImage != nil)
        return [[TGDataResource alloc] initWithImage:cachedImage decoded:true];
    
    if (!canWait)
        return nil;
    
    return [TGPeerAvatarThumbnailDataSource _performLoad:uri isCancelled:nil];
}

+ (bool)_isDataLocallyAvailableForUri:(NSString *)uri
{
    NSDictionary *args = [TGStringUtils argumentDictionaryInUrlString:[uri substringFromIndex:[[NSString alloc] initWithFormat:@"%@://?", [TGPeerAvatarThumbnailDataSource uriPrefix]].length]];
    
    if (![args[@"width"] respondsToSelector:@selector(intValue)] || ![args[@"height"] respondsToSelector:@selector(intValue)])
    {
        return false;
    }
    
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
        return nil;
    
    NSDictionary *args = [TGStringUtils argumentDictionaryInUrlString:[uri substringFromIndex:[[NSString alloc] initWithFormat:@"%@://?", [TGPeerAvatarThumbnailDataSource uriPrefix]].length]];
    
    if (![args[@"width"] respondsToSelector:@selector(intValue)] || ![args[@"height"] respondsToSelector:@selector(intValue)])
    {
        return nil;
    }
    
    CGSize size = CGSizeMake([args[@"width"] intValue], [args[@"height"] intValue]);
    
    UIImage *image = nil;
    
    if ([args[@"legacy-thumbnail-cache-url"] respondsToSelector:@selector(characterAtIndex:)])
    {
        image = [[TGRemoteImageView sharedCache] cachedImage:args[@"legacy-thumbnail-cache-url"] availability:TGCacheDisk];
    }
    
    if (image != nil)
    {
        NSNumber *averageColor = [[TGMediaStoreContext instance] mediaImageAverageColor:uri];
        bool needsAverageColor = averageColor == nil;
        uint32_t averageColorValue = [averageColor intValue];
        
        image = TGRoundImage(image, size);
        
        if (image != nil)
        {
            if (needsAverageColor)
                [[TGMediaStoreContext instance] setMediaImageAverageColorForKey:uri averageColor:@(averageColorValue)];
            
            [[TGRemoteImageView sharedCache] cacheImage:image withData:nil url:uri availability:TGCacheMemory];
            
            return [[TGDataResource alloc] initWithImage:image decoded:true];
        }
    }
    
    return nil;
}

@end
