#import "TGWebSearchImageDataSource.h"

#import "ASQueue.h"
#import "ActionStage.h"

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
        queue = [[ASQueue alloc] initWithName:"org.telegram.webSearchGalleryThumbnailTaskManagementQueue"];
    });
    
    return queue;
}

@implementation TGWebSearchImageDataSource

+ (void)load
{
    @autoreleasepool
    {
        [TGImageDataSource registerDataSource:[[self alloc] init]];
    }
}

+ (NSString *)uriPrefix
{
    return @"web-search-gallery://";
}

- (bool)canHandleUri:(NSString *)uri
{
    return [uri hasPrefix:[TGWebSearchImageDataSource uriPrefix]];
}

- (bool)canHandleAttributeUri:(NSString *)uri
{
    return [uri hasPrefix:[TGWebSearchImageDataSource uriPrefix]];
}

+ (NSString *)imageAddressForUri:(NSString *)uri size:(out CGSize *)size thumbnailUrl:(__autoreleasing NSString **)thumbnailUrl
{
    NSDictionary *args = [TGStringUtils argumentDictionaryInUrlString:[uri substringFromIndex:[[NSString alloc] initWithFormat:@"%@?", [TGWebSearchImageDataSource uriPrefix]].length]];
    
    CGSize imageSize = CGSizeMake([args[@"width"] intValue], [args[@"height"] intValue]);
    
    if (size != NULL)
        *size = imageSize;
    
    if (args[@"thumbnailUrl"] != nil)
    {
        if (thumbnailUrl != NULL)
            *thumbnailUrl = args[@"thumbnailUrl"];
    }
    
    
    return args[@"url"] == nil ? nil : [[NSString alloc] initWithFormat:@"%@", args[@"url"]];
}

- (id)loadDataAsyncWithUri:(NSString *)uri progress:(void (^)(float))progress partialCompletion:(void (^)(TGDataResource *resource))__unused partialCompletion completion:(void (^)(TGDataResource *))completion
{
    __autoreleasing NSString *thumbnailUrl = nil;
    NSString *imageUrl = [TGWebSearchImageDataSource imageAddressForUri:uri size:NULL thumbnailUrl:&thumbnailUrl];
    if (imageUrl == nil || thumbnailUrl == nil)
    {
        if (completion)
            completion([TGWebSearchImageDataSource resultForUnavailableImage]);
        return nil;
    }
    
    TGMediaPreviewTask *previewTask = [[TGMediaPreviewTask alloc] init];
    
    [taskManagementQueue() dispatchOnQueue:^
    {
        TGWorkerTask *workerTask = [[TGWorkerTask alloc] initWithBlock:^(bool (^isCancelled)())
        {
            TGDataResource *result = [TGWebSearchImageDataSource _performLoad:uri isCancelled:isCancelled];
            
            if (result != nil && progress != nil)
                progress(1.0f);
            
            if (isCancelled != nil && isCancelled())
                return;
            
            if (completion != nil)
                completion(result != nil ? result : [TGWebSearchImageDataSource resultForUnavailableImage]);
        }];
        
        bool completed = false;
        bool isThumbnail = false;
        if ([TGWebSearchImageDataSource _isDataLocallyAvailableForUri:uri isThumbnail:&isThumbnail])
        {
            TGDataResource *result = [TGWebSearchImageDataSource _performLoad:uri isCancelled:nil];
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
            if (progress)
                progress(0.0f);
            
            [previewTask executeTempDownloadWithTargetFilePath:nil uri:imageUrl progress:^(float value)
            {
                if (progress)
                    progress(value);
            } completionWithData:^(NSData *data)
            {
                if (data != nil)
                {
                    [[[TGMediaStoreContext instance] temporaryFilesCache] setValue:data forKey:[imageUrl dataUsingEncoding:NSUTF8StringEncoding]];
                    [previewTask executeWithWorkerTask:workerTask workerPool:workerPool()];
                }
                else
                {
                    if (completion != nil)
                        completion([TGWebSearchImageDataSource resultForUnavailableImage]);
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
                      imageData = [[TGDataResource alloc] initWithImage:TGAverageColorImage([UIColor whiteColor]) decoded:true];
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
    
    __autoreleasing NSString *thumbnailUrl = nil;
    NSString *imageUrl = [TGWebSearchImageDataSource imageAddressForUri:uri size:NULL thumbnailUrl:&thumbnailUrl];
    if (imageUrl == nil)
        return [TGWebSearchImageDataSource resultForUnavailableImage];
    
    if (!canWait)
        return nil;
    
    bool isThumbnail = false;
    if ([TGWebSearchImageDataSource _isDataLocallyAvailableForUri:uri isThumbnail:&isThumbnail])
    {
        TGDataResource *partialData = [TGWebSearchImageDataSource _performLoad:uri isCancelled:nil];
        
        if (isThumbnail && acceptPartialData && asyncTaskId != NULL)
        {
            *asyncTaskId = [self loadDataAsyncWithUri:uri progress:progress partialCompletion:partialCompletion completion:completion];
        }
        
        return partialData;
    }
    
    return nil;
}

+ (bool)_isDataLocallyAvailableForUri:(NSString *)uri isThumbnail:(bool *)isThumbnail
{
    __autoreleasing NSString *thumbnailUrl = nil;
    NSString *imageUrl = [TGWebSearchImageDataSource imageAddressForUri:uri size:NULL thumbnailUrl:&thumbnailUrl];
    
    if ([[[TGMediaStoreContext instance] temporaryFilesCache] containsValueForKey:[imageUrl dataUsingEncoding:NSUTF8StringEncoding]])
    {
        return true;
    }
    
    if ([[[TGMediaStoreContext instance] temporaryFilesCache] containsValueForKey:[thumbnailUrl dataUsingEncoding:NSUTF8StringEncoding]])
    {
        if (isThumbnail)
            *isThumbnail = true;
        return true;
    }
    
    return false;
}

+ (TGDataResource *)_performLoad:(NSString *)uri isCancelled:(bool (^)())isCancelled
{
    if (isCancelled && isCancelled())
        return nil;
    
    CGSize size = CGSizeZero;
    __autoreleasing NSString *thumbnailUrl = nil;
    NSString *imageUrl = [TGWebSearchImageDataSource imageAddressForUri:uri size:&size thumbnailUrl:&thumbnailUrl];
    
    NSData *thumbnailSourceData = [[[TGMediaStoreContext instance] temporaryFilesCache] getValueForKey:[imageUrl dataUsingEncoding:NSUTF8StringEncoding]];
    bool lowQuality = false;
    if (thumbnailSourceData == nil)
    {
        thumbnailSourceData = [[[TGMediaStoreContext instance] temporaryFilesCache] getValueForKey:[thumbnailUrl dataUsingEncoding:NSUTF8StringEncoding]];
        lowQuality = true;
    }
    
    UIImage *thumbnailSourceImage = [[UIImage alloc] initWithData:thumbnailSourceData];
    
    if (lowQuality)
        size = TGFitSize(size, CGSizeMake(256, 256));
    
    UIGraphicsBeginImageContextWithOptions(size, true, 1.0f);
    
    CGSize drawingSize = TGFitSize(thumbnailSourceImage.size, size);
    if (drawingSize.width < size.width)
    {
        drawingSize.height = drawingSize.height * size.width / drawingSize.width;
        drawingSize.width = size.width;
    }
    if (drawingSize.height < size.height)
    {
        drawingSize.width = drawingSize.width * size.height / drawingSize.height;
        drawingSize.height = size.height;
    }
    
    CGRect imageRect = CGRectMake((size.width - drawingSize.width) / 2.0f, (size.height - drawingSize.height) / 2.0f, drawingSize.width, drawingSize.height);
    [thumbnailSourceImage drawInRect:imageRect blendMode:kCGBlendModeCopy alpha:1.0f];
    
    thumbnailSourceImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    if (lowQuality)
        thumbnailSourceImage = TGBlurredFileImage(thumbnailSourceImage, thumbnailSourceImage.size, NULL, 0);
    
    if (thumbnailSourceImage != nil)
    {
        UIImage *thumbnailImage = nil;
        
        //NSNumber *averageColor = [[TGMediaStoreContext instance] mediaImageAverageColor:uri];
        //bool needsAverageColor = averageColor == nil;
        //uint32_t averageColorValue = [averageColor intValue];
        
        thumbnailImage = thumbnailSourceImage;
        
        if (thumbnailImage != nil)
        {
            //[[TGMediaStoreContext instance] setMediaImageAverageColorForKey:uri averageColor:@(averageColorValue)];
            [[TGMediaStoreContext instance] setMediaImageForKey:uri image:thumbnailImage attributes:@{}];
            
            return [[TGDataResource alloc] initWithImage:thumbnailImage decoded:true];
        }
    }
    
    return nil;
}

@end