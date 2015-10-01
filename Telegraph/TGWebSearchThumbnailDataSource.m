#import "TGWebSearchThumbnailDataSource.h"

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
        queue = [[ASQueue alloc] initWithName:"org.telegram.webSearchThumbnailTaskManagementQueue"];
    });
    
    return queue;
}

@implementation TGWebSearchThumbnailDataSource

+ (void)load
{
    @autoreleasepool
    {
        [TGImageDataSource registerDataSource:[[self alloc] init]];
    }
}

+ (NSString *)uriPrefix
{
    return @"web-search-thumbnail://";
}

- (bool)canHandleUri:(NSString *)uri
{
    return [uri hasPrefix:[TGWebSearchThumbnailDataSource uriPrefix]];
}

- (bool)canHandleAttributeUri:(NSString *)uri
{
    return [uri hasPrefix:[TGWebSearchThumbnailDataSource uriPrefix]];
}

+ (NSString *)imageAddressForUri:(NSString *)uri size:(out CGSize *)size
{
    NSDictionary *args = [TGStringUtils argumentDictionaryInUrlString:[uri substringFromIndex:[[NSString alloc] initWithFormat:@"%@?", [TGWebSearchThumbnailDataSource uriPrefix]].length]];
    
    CGSize imageSize = CGSizeMake([args[@"width"] intValue], [args[@"height"] intValue]);
    
    if (size != NULL)
        *size = imageSize;
    
    return args[@"url"] == nil ? nil : [[NSString alloc] initWithFormat:@"%@", args[@"url"]];
}

- (id)loadDataAsyncWithUri:(NSString *)uri progress:(void (^)(float))progress partialCompletion:(void (^)(TGDataResource *resource))__unused partialCompletion completion:(void (^)(TGDataResource *))completion
{
    if ([TGWebSearchThumbnailDataSource imageAddressForUri:uri size:NULL] == nil)
    {
        if (completion)
            completion([TGWebSearchThumbnailDataSource resultForUnavailableImage]);
        return nil;
    }
    
    TGMediaPreviewTask *previewTask = [[TGMediaPreviewTask alloc] init];
    
    [taskManagementQueue() dispatchOnQueue:^
     {
         TGWorkerTask *workerTask = [[TGWorkerTask alloc] initWithBlock:^(bool (^isCancelled)())
         {
             TGDataResource *result = [TGWebSearchThumbnailDataSource _performLoad:uri isCancelled:isCancelled];
             
             if (result != nil && progress != nil)
                 progress(1.0f);
             
             if (isCancelled != nil && isCancelled())
                 return;
             
             if (completion != nil)
                 completion(result != nil ? result : [TGWebSearchThumbnailDataSource resultForUnavailableImage]);
         }];
         
         if ([TGWebSearchThumbnailDataSource _isDataLocallyAvailableForUri:uri])
         {
             [previewTask executeWithWorkerTask:workerTask workerPool:workerPool()];
         }
         else
         {
             NSString *imageUrl = [TGWebSearchThumbnailDataSource imageAddressForUri:uri size:NULL];
             [previewTask executeTempDownloadWithTargetFilePath:nil uri:imageUrl progress:nil completionWithData:^(NSData *data)
             {
                 if (data != nil)
                 {
                     [[[TGMediaStoreContext instance] temporaryFilesCache] setValue:data forKey:[imageUrl dataUsingEncoding:NSUTF8StringEncoding]];
                     [previewTask executeWithWorkerTask:workerTask workerPool:workerPool()];
                 }
                 else
                 {
                     if (completion != nil)
                         completion([TGWebSearchThumbnailDataSource resultForUnavailableImage]);
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
    
    if ([TGWebSearchThumbnailDataSource imageAddressForUri:uri size:NULL] == nil)
        return [TGWebSearchThumbnailDataSource resultForUnavailableImage];
    
    UIImage *cachedImage = [[TGMediaStoreContext instance] mediaImage:uri attributes:nil];
    if (cachedImage != nil)
        return [[TGDataResource alloc] initWithImage:cachedImage decoded:true];
    
    if (!canWait)
        return nil;
    
    return [TGWebSearchThumbnailDataSource _performLoad:uri isCancelled:nil];
}

+ (bool)_isDataLocallyAvailableForUri:(NSString *)uri
{
    NSString *imageAddress = [self imageAddressForUri:uri size:NULL];
    
    return [[[TGMediaStoreContext instance] temporaryFilesCache] containsValueForKey:[imageAddress dataUsingEncoding:NSUTF8StringEncoding]];
}

+ (TGDataResource *)_performLoad:(NSString *)uri isCancelled:(bool (^)())isCancelled
{
    if (isCancelled && isCancelled())
        return nil;
    
    CGSize size = CGSizeZero;
    NSString *imageUrl = [TGWebSearchThumbnailDataSource imageAddressForUri:uri size:&size];
    
    NSData *thumbnailSourceData = [[[TGMediaStoreContext instance] temporaryFilesCache] getValueForKey:[imageUrl dataUsingEncoding:NSUTF8StringEncoding]];
    UIImage *thumbnailSourceImage = [[UIImage alloc] initWithData:thumbnailSourceData];
    
    if (thumbnailSourceImage == nil)
        return nil;
    
    UIGraphicsBeginImageContextWithOptions(size, true, 0.0f);
    
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
