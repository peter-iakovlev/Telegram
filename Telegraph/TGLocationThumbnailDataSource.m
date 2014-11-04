#import "TGLocationThumbnailDataSource.h"

#import "ASQueue.h"

#import "TGWorkerPool.h"
#import "TGWorkerTask.h"
#import "TGMediaPreviewTask.h"

#import "TGMemoryImageCache.h"

#import "TGImageUtils.h"
#import "TGStringUtils.h"

#import "TGImageBlur.h"
#import "UIImage+TG.h"
#import "NSObject+TGLock.h"

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
        queue = [[ASQueue alloc] initWithName:"org.telegram.mapThumbnailTaskManagementQueue"];
    });
    
    return queue;
}

@interface TGLocationThumbnailDataSource ()
{
}

@end

@implementation TGLocationThumbnailDataSource

+ (void)load
{
    @autoreleasepool
    {
        [TGImageDataSource registerDataSource:[[self alloc] init]];
    }
}

- (bool)canHandleUri:(NSString *)uri
{
    return [uri hasPrefix:@"map-thumbnail://"];
}

- (bool)canHandleAttributeUri:(NSString *)uri
{
    return [uri hasPrefix:@"map-thumbnail://"];
}

+ (NSString *)mapAddressForUri:(NSString *)uri size:(out CGSize *)size
{
    NSDictionary *args = [TGStringUtils argumentDictionaryInUrlString:[uri substringFromIndex:@"map-thumbnail://?".length]];
    
    CGSize imageSize = CGSizeMake([args[@"width"] intValue], [args[@"height"] intValue]);
    
    if (size != NULL)
        *size = imageSize;
    
    return [[NSString alloc] initWithFormat:@"https://maps.googleapis.com/maps/api/staticmap?center=%.5f,%.5f&zoom=15&size=%dx%d&sensor=false&scale=%d&format=jpg&mobile=true", [args[@"latitude"] doubleValue], [args[@"longitude"] doubleValue], (int)(imageSize.width), (int)(imageSize.height + 24), 2];
}

- (id)loadDataAsyncWithUri:(NSString *)uri progress:(void (^)(float))progress partialCompletion:(void (^)(TGDataResource *resource))__unused partialCompletion completion:(void (^)(TGDataResource *))completion
{
    TGMediaPreviewTask *previewTask = [[TGMediaPreviewTask alloc] init];
    
    [taskManagementQueue() dispatchOnQueue:^
    {
        TGWorkerTask *workerTask = [[TGWorkerTask alloc] initWithBlock:^(bool (^isCancelled)())
        {
            TGDataResource *result = [TGLocationThumbnailDataSource _performLoad:uri isCancelled:isCancelled];
            
            if (result != nil && progress != nil)
                progress(1.0f);
            
            if (isCancelled != nil && isCancelled())
                return;
            
            if (completion != nil)
                completion(result != nil ? result : [TGLocationThumbnailDataSource resultForUnavailableImage]);
        }];
        
        if ([TGLocationThumbnailDataSource _isDataLocallyAvailableForUri:uri])
        {
            [previewTask executeWithWorkerTask:workerTask workerPool:workerPool()];
        }
        else
        {
            [previewTask executeWithTargetFilePath:nil uri:[TGLocationThumbnailDataSource mapAddressForUri:uri size:NULL] completion:^(bool success)
            {
                if (success)
                {
                    [previewTask executeWithWorkerTask:workerTask workerPool:workerPool()];
                }
                else
                {
                    if (completion != nil)
                        completion([TGLocationThumbnailDataSource resultForUnavailableImage]);
                }
            } workerTask:workerTask];
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
        imageData = [[TGDataResource alloc] initWithImage:TGAverageColorAttachmentImage([UIColor whiteColor]) decoded:true];
    });
    
    return imageData;
}

- (id)loadAttributeSyncForUri:(NSString *)__unused uri attribute:(NSString *)attribute
{
    if ([attribute isEqualToString:@"placeholder"])
    {
        static UIImage *placeholder = nil;
        static dispatch_once_t onceToken;
        dispatch_once(&onceToken, ^
        {
            placeholder = TGAverageColorAttachmentImage([UIColor whiteColor]);
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
    
    return [TGLocationThumbnailDataSource _performLoad:uri isCancelled:nil];
}

+ (bool)_isDataLocallyAvailableForUri:(NSString *)uri
{
    NSString *mapAddress = [self mapAddressForUri:uri size:NULL];
    return [[[TGMediaStoreContext instance] temporaryFilesCache] containsValueForKey:[mapAddress dataUsingEncoding:NSUTF8StringEncoding]];
}

+ (TGDataResource *)_performLoad:(NSString *)uri isCancelled:(bool (^)())isCancelled
{
    if (isCancelled && isCancelled())
        return nil;
    
    static NSString *filesDirectory = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^
    {
        filesDirectory = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, true)[0] stringByAppendingPathComponent:@"files"];
    });
    
    CGSize size = CGSizeZero;
    NSString *imageUrl = [TGLocationThumbnailDataSource mapAddressForUri:uri size:&size];
    
    NSData *thumbnailSourceData = [[[TGMediaStoreContext instance] temporaryFilesCache] getValueForKey:[imageUrl dataUsingEncoding:NSUTF8StringEncoding]];
    UIImage *thumbnailSourceImage = [[UIImage alloc] initWithData:thumbnailSourceData];
    
    UIGraphicsBeginImageContextWithOptions(size, true, 0.0f);
    
    CGRect imageRect = CGRectMake(0.0f, -12.0f, size.width, size.height + 24.0f);
    [thumbnailSourceImage drawInRect:imageRect blendMode:kCGBlendModeCopy alpha:1.0f];
    
    thumbnailSourceImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    if (thumbnailSourceImage != nil)
    {
        UIImage *thumbnailImage = nil;
        
        NSNumber *averageColor = [[TGMediaStoreContext instance] mediaImageAverageColor:uri];
        bool needsAverageColor = averageColor == nil;
        uint32_t averageColorValue = [averageColor intValue];
        
        thumbnailImage = TGLoadedAttachmentImage(thumbnailSourceImage, size, needsAverageColor ? &averageColorValue : NULL);
        
        if (thumbnailImage != nil)
        {
            [[TGMediaStoreContext instance] setMediaImageAverageColorForKey:uri averageColor:@(averageColorValue)];
            [[TGMediaStoreContext instance] setMediaImageForKey:uri image:thumbnailImage attributes:@{}];
            
            return [[TGDataResource alloc] initWithImage:thumbnailImage decoded:true];
        }
    }
    
    return nil;
}

@end
