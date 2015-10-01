#import "TGLocationVenueIconDataSource.h"

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
        queue = [[ASQueue alloc] initWithName:"org.telegram.locationVenueIconTaskManagementQueue"];
    });
    
    return queue;
}

@implementation TGLocationVenueIconDataSource

+ (void)load
{
    @autoreleasepool
    {
        [TGImageDataSource registerDataSource:[[self alloc] init]];
    }
}

+ (NSString *)uriScheme
{
    return @"location-venue-icon";
}

+ (NSString *)uriSchemeFull
{
    return [NSString stringWithFormat:@"%@://", [self uriScheme]];
}

- (bool)canHandleUri:(NSString *)uri
{
    return [uri hasPrefix:[TGLocationVenueIconDataSource uriSchemeFull]];
}

- (bool)canHandleAttributeUri:(NSString *)uri
{
    return [uri hasPrefix:[TGLocationVenueIconDataSource uriSchemeFull]];
}

+ (NSString *)iconAddressForUri:(NSString *)uri size:(out CGSize *)size
{
    NSDictionary *args = [TGStringUtils argumentDictionaryInUrlString:[uri substringFromIndex:[TGLocationVenueIconDataSource uriSchemeFull].length]];
    
    CGSize imageSize = CGSizeMake([args[@"width"] intValue], [args[@"height"] intValue]);
    
    if (size != NULL)
        *size = imageSize;
    
    return args[@"url"] == nil ? nil : [[NSString alloc] initWithFormat:@"%@", args[@"url"]];
}

- (id)loadDataAsyncWithUri:(NSString *)uri progress:(void (^)(float))progress partialCompletion:(void (^)(TGDataResource *resource))__unused partialCompletion completion:(void (^)(TGDataResource *))completion
{
    TGMediaPreviewTask *previewTask = [[TGMediaPreviewTask alloc] init];
    
    [taskManagementQueue() dispatchOnQueue:^
     {
         TGWorkerTask *workerTask = [[TGWorkerTask alloc] initWithBlock:^(bool (^isCancelled)())
         {
             TGDataResource *result = [TGLocationVenueIconDataSource _performLoad:uri isCancelled:isCancelled];
             
             if (result != nil && progress != nil)
                 progress(1.0f);
             
             if (isCancelled != nil && isCancelled())
                 return;
             
             if (completion != nil)
                 completion(result != nil ? result : [TGLocationVenueIconDataSource resultForUnavailableImage]);
         }];
         
         if ([TGLocationVenueIconDataSource _isDataLocallyAvailableForUri:uri])
         {
             [previewTask executeWithWorkerTask:workerTask workerPool:workerPool()];
         }
         else
         {
             [previewTask executeWithTargetFilePath:nil uri:[TGLocationVenueIconDataSource iconAddressForUri:uri size:NULL] completion:^(bool success)
              {
                  if (success)
                  {
                      [previewTask executeWithWorkerTask:workerTask workerPool:workerPool()];
                  }
                  else
                  {
                      if (completion != nil)
                          completion([TGLocationVenueIconDataSource resultForUnavailableImage]);
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
        UIImage *image = nil;
        
        UIGraphicsBeginImageContextWithOptions(CGSizeMake(40, 40), false, 0.0f);
        CGContextRef context = UIGraphicsGetCurrentContext();
        CGContextSetFillColorWithColor(context, UIColorRGB(0xededed).CGColor);
        CGContextFillEllipseInRect(context, CGRectMake(0.0, 0.0f, 40.0f, 40.0f));
        image = UIGraphicsGetImageFromCurrentImageContext();

        UIGraphicsEndImageContext();
        
        imageData = [[TGDataResource alloc] initWithImage:image decoded:true];
    });
    
    return imageData;
}

- (id)loadAttributeSyncForUri:(NSString *)__unused uri attribute:(NSString *)attribute
{
    if ([attribute isEqualToString:@"placeholder"])
    {
        static NSMutableDictionary *placeholderBySize = nil;
        static dispatch_once_t onceToken;
        dispatch_once(&onceToken, ^
        {
            placeholderBySize = [[NSMutableDictionary alloc] init];
        });
        
        CGSize size = CGSizeZero;
        [TGLocationVenueIconDataSource iconAddressForUri:uri size:&size];
        NSString *sizeString = NSStringFromCGSize(size);
        UIImage *placeholder = placeholderBySize[sizeString];
        if (placeholder != nil)
            return placeholder;
        
        //ededed
        //f2f2f2
        UIGraphicsBeginImageContextWithOptions(size, false, 0.0f);
        CGContextRef context = UIGraphicsGetCurrentContext();
        CGContextSetFillColorWithColor(context, UIColorRGB(0xf2f2f2).CGColor);
        CGContextFillEllipseInRect(context, CGRectMake(0.0, 0.0f, size.width, size.height));
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
    
    return [TGLocationVenueIconDataSource _performLoad:uri isCancelled:nil];
}

+ (bool)_isDataLocallyAvailableForUri:(NSString *)uri
{
    NSString *iconAddress = [self iconAddressForUri:uri size:NULL];
    return [[[TGMediaStoreContext instance] temporaryFilesCache] containsValueForKey:[iconAddress dataUsingEncoding:NSUTF8StringEncoding]];
}

+ (TGDataResource *)_performLoad:(NSString *)uri isCancelled:(bool (^)())isCancelled
{
    if (isCancelled && isCancelled())
        return nil;
    
    CGSize size = CGSizeZero;
    NSString *imageUrl = [TGLocationVenueIconDataSource iconAddressForUri:uri size:&size];
    
    NSData *iconSourceData = [[[TGMediaStoreContext instance] temporaryFilesCache] getValueForKey:[imageUrl dataUsingEncoding:NSUTF8StringEncoding]];
    UIImage *iconSourceImage = [[UIImage alloc] initWithData:iconSourceData];
    
    UIGraphicsBeginImageContextWithOptions(iconSourceImage.size, false, iconSourceImage.scale);
    CGContextRef context = UIGraphicsGetCurrentContext();
    [iconSourceImage drawAtPoint:CGPointZero];
    CGContextSetBlendMode (context, kCGBlendModeSourceAtop);
    CGContextSetFillColorWithColor(context, UIColorRGB(0xa0a0a0).CGColor);
    CGContextFillRect(context, CGRectMake(0, 0, iconSourceImage.size.width, iconSourceImage.size.height));
    UIImage *tintedIconImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    UIGraphicsBeginImageContextWithOptions(size, false, 0.0f);
    context = UIGraphicsGetCurrentContext();
    CGContextSetFillColorWithColor(context, UIColorRGB(0xf2f2f2).CGColor);
    CGContextFillEllipseInRect(context, CGRectMake(0.0, 0.0f, size.width, size.height));
    CGRect imageRect = CGRectMake(4.0f, 4.0f, 32.0f, 32.0f);
    [tintedIconImage drawInRect:imageRect];
    
    UIImage *iconImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    if (iconImage != nil)
    {
        [[TGMediaStoreContext instance] setMediaImageForKey:uri image:iconImage attributes:@{}];
        return [[TGDataResource alloc] initWithImage:iconImage decoded:true];
    }
    
    return nil;
}

@end
