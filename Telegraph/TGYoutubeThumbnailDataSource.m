#import "TGYoutubeThumbnailDataSource.h"

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
        queue = [[ASQueue alloc] initWithName:"org.telegram.youtubeThumbnailTaskManagementQueue"];
    });
    
    return queue;
}

@implementation TGYoutubeThumbnailDataSource

+ (void)load
{
    @autoreleasepool
    {
        [TGImageDataSource registerDataSource:[[self alloc] init]];
    }
}

+ (NSString *)uriPrefix
{
    return @"youtube-preview://";
}

- (bool)canHandleUri:(NSString *)uri
{
    return [uri hasPrefix:[TGYoutubeThumbnailDataSource uriPrefix]];
}

- (bool)canHandleAttributeUri:(NSString *)uri
{
    return [uri hasPrefix:[TGYoutubeThumbnailDataSource uriPrefix]];
}

+ (NSString *)imageAddressForUri:(NSString *)uri size:(out CGSize *)size
{
    NSDictionary *args = [TGStringUtils argumentDictionaryInUrlString:[uri substringFromIndex:[[NSString alloc] initWithFormat:@"%@?", [TGYoutubeThumbnailDataSource uriPrefix]].length]];
    
    CGSize imageSize = CGSizeMake([args[@"width"] intValue], [args[@"height"] intValue]);
    
    if (size != NULL)
        *size = imageSize;
        
    return [[NSString alloc] initWithFormat:@"https://img.youtube.com/vi/%@/0.jpg", args[@"videoId"]];
}

- (id)loadDataAsyncWithUri:(NSString *)uri progress:(void (^)(float))progress partialCompletion:(void (^)(TGDataResource *resource))__unused partialCompletion completion:(void (^)(TGDataResource *))completion
{
    TGMediaPreviewTask *previewTask = [[TGMediaPreviewTask alloc] init];
    
    NSDictionary *args = [TGStringUtils argumentDictionaryInUrlString:[uri substringFromIndex:[[NSString alloc] initWithFormat:@"%@?", [TGYoutubeThumbnailDataSource uriPrefix]].length]];
    bool isFlat = [args[@"flat"] boolValue];
    
    [taskManagementQueue() dispatchOnQueue:^
     {
         TGWorkerTask *workerTask = [[TGWorkerTask alloc] initWithBlock:^(bool (^isCancelled)())
         {
             TGDataResource *result = [TGYoutubeThumbnailDataSource _performLoad:uri isCancelled:isCancelled];
             
             if (result != nil && progress != nil)
                 progress(1.0f);
             
             if (isCancelled != nil && isCancelled())
                 return;
             
             if (completion != nil)
                 completion(result != nil ? result : [TGYoutubeThumbnailDataSource resultForUnavailableImage:isFlat]);
         }];
         
         if ([TGYoutubeThumbnailDataSource _isDataLocallyAvailableForUri:uri])
         {
             [previewTask executeWithWorkerTask:workerTask workerPool:workerPool()];
         }
         else
         {
             [previewTask executeWithTargetFilePath:nil uri:[TGYoutubeThumbnailDataSource imageAddressForUri:uri size:NULL] completion:^(bool success)
             {
                 if (success)
                 {
                     [previewTask executeWithWorkerTask:workerTask workerPool:workerPool()];
                 }
                 else
                 {
                     if (completion != nil)
                         completion([TGYoutubeThumbnailDataSource resultForUnavailableImage:isFlat]);
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

+ (TGDataResource *)resultForUnavailableImage:(bool)isFlat
{
    static TGDataResource *normalData = nil;
    static TGDataResource *flatData = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^
    {
        normalData = [[TGDataResource alloc] initWithImage:TGAverageColorAttachmentImage([UIColor darkGrayColor], true) decoded:true];
        flatData = [[TGDataResource alloc] initWithImage:TGAverageColorAttachmentImage([UIColor darkGrayColor], false) decoded:true];
    });
    
    return isFlat ? flatData : normalData;
}

- (id)loadAttributeSyncForUri:(NSString *)__unused uri attribute:(NSString *)attribute
{
    if ([attribute isEqualToString:@"placeholder"])
    {
        NSDictionary *args = [TGStringUtils argumentDictionaryInUrlString:[uri substringFromIndex:[[NSString alloc] initWithFormat:@"%@?", [TGYoutubeThumbnailDataSource uriPrefix]].length]];
        bool isFlat = [args[@"flat"] boolValue];
        
        static NSMutableDictionary *placeholderBySize = nil;
        static dispatch_once_t onceToken;
        dispatch_once(&onceToken, ^
        {
            placeholderBySize = [[NSMutableDictionary alloc] init];
        });
        
        CGSize size = CGSizeZero;
        [TGYoutubeThumbnailDataSource imageAddressForUri:uri size:&size];
        NSString *sizeString = [[NSString alloc] initWithFormat:@"%@-%@", NSStringFromCGSize(size), isFlat ? @"flat" : @"normal"];
        UIImage *placeholder = placeholderBySize[sizeString];
        if (placeholder != nil)
            return placeholder;
        
        UIGraphicsBeginImageContextWithOptions(size, false, 0.0f);
        [TGAverageColorAttachmentImage([UIColor blackColor], !isFlat) drawInRect:CGRectMake(0.0f, 0.0f, size.width, size.height) blendMode:kCGBlendModeCopy alpha:1.0f];
        CGRect imageRect = CGRectMake(0.0f, 0.0f, size.width, size.height);
        UIImage *buttonImage = [UIImage imageNamed:@"ModernMessageYoutubeButtonPlaceholder.png"];
        [buttonImage drawInRect:CGRectMake(imageRect.origin.x + CGFloor((imageRect.size.width - buttonImage.size.width) / 2.0f), imageRect.origin.y + CGFloor((imageRect.size.height - buttonImage.size.height) / 2.0f), buttonImage.size.width, buttonImage.size.height)];
        placeholder = UIGraphicsGetImageFromCurrentImageContext();
        if (placeholder != nil)
            placeholderBySize[sizeString] = placeholder;
        UIGraphicsEndImageContext();

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
    
    return [TGYoutubeThumbnailDataSource _performLoad:uri isCancelled:nil];
}

+ (bool)_isDataLocallyAvailableForUri:(NSString *)uri
{
    NSString *mapAddress = [self imageAddressForUri:uri size:NULL];
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
        filesDirectory = [[TGAppDelegate documentsPath] stringByAppendingPathComponent:@"files"];
    });
    
    CGSize size = CGSizeZero;
    NSDictionary *args = [TGStringUtils argumentDictionaryInUrlString:[uri substringFromIndex:[[NSString alloc] initWithFormat:@"%@?", [TGYoutubeThumbnailDataSource uriPrefix]].length]];
    NSString *imageUrl = [TGYoutubeThumbnailDataSource imageAddressForUri:uri size:&size];
    NSData *thumbnailSourceData = [[[TGMediaStoreContext instance] temporaryFilesCache] getValueForKey:[imageUrl dataUsingEncoding:NSUTF8StringEncoding]];
    UIImage *thumbnailSourceImage = [[UIImage alloc] initWithData:thumbnailSourceData];
    
    UIGraphicsBeginImageContextWithOptions(size, true, 0.0f);
    
    CGSize drawingSize = TGFitSize(thumbnailSourceImage.size, size);
    if (drawingSize.width < size.width)
    {
        drawingSize.height = drawingSize.height * size.width / drawingSize.width;
        drawingSize.width = size.width;
    }
    
    CGRect imageRect = CGRectMake((size.width - drawingSize.width) / 2.0f, (size.height - drawingSize.height) / 2.0f, drawingSize.width, drawingSize.height);
    [thumbnailSourceImage drawInRect:imageRect blendMode:kCGBlendModeCopy alpha:1.0f];
    
    UIImage *buttonImage = [UIImage imageNamed:@"ModernMessageYoutubeButton.png"];
    [buttonImage drawInRect:CGRectMake(imageRect.origin.x + CGFloor((imageRect.size.width - buttonImage.size.width) / 2.0f), imageRect.origin.y + CGFloor((imageRect.size.height - buttonImage.size.height) / 2.0f), buttonImage.size.width, buttonImage.size.height)];
    
    thumbnailSourceImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    bool isFlat = [args[@"flat"] boolValue];
    
    if (thumbnailSourceImage != nil)
    {
        UIImage *thumbnailImage = nil;
        
        NSNumber *averageColor = [[TGMediaStoreContext instance] mediaImageAverageColor:uri];
        bool needsAverageColor = averageColor == nil;
        uint32_t averageColorValue = [averageColor intValue];
        
        thumbnailImage = TGLoadedAttachmentImage(thumbnailSourceImage, size, needsAverageColor ? &averageColorValue : NULL, !isFlat);
        
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

