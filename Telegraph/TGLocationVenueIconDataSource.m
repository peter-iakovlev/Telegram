#import "TGLocationVenueIconDataSource.h"

#import <LegacyComponents/LegacyComponents.h>

#import <LegacyComponents/ASQueue.h>

#import "TGWorkerPool.h"
#import "TGWorkerTask.h"
#import "TGMediaPreviewTask.h"

#import <LegacyComponents/TGMemoryImageCache.h>

#import <LegacyComponents/TGRemoteImageView.h>

#import <LegacyComponents/TGImageBlur.h>
#import <LegacyComponents/UIImage+TG.h>

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
    
    if (args[@"type"] == nil)
        return nil;
    
    NSString *url = [NSString stringWithFormat:@"https://ss3.4sqi.net/img/categories_v2/%@_88.png", args[@"type"]];
    return url;
}

- (id)loadDataAsyncWithUri:(NSString *)uri progress:(void (^)(float))progress partialCompletion:(void (^)(TGDataResource *resource))__unused partialCompletion completion:(void (^)(TGDataResource *))completion
{
    TGMediaPreviewTask *previewTask = [[TGMediaPreviewTask alloc] init];
    
    NSDictionary *args = [TGStringUtils argumentDictionaryInUrlString:[uri substringFromIndex:[TGLocationVenueIconDataSource uriSchemeFull].length]];
    UIColor *color = UIColorRGB([args[@"color"] integerValue]);
    
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
                 completion(result != nil ? result : [TGLocationVenueIconDataSource resultForUnavailableImage:color]);
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
                          completion([TGLocationVenueIconDataSource resultForUnavailableImage:color]);
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

+ (TGDataResource *)resultForUnavailableImage:(UIColor *)color
{
    return [[TGDataResource alloc] initWithImage:TGTintedImage(TGComponentsImageNamed(@"LocationMessagePinIcon"), color) decoded:true];
}

- (id)loadAttributeSyncForUri:(NSString *)__unused uri attribute:(NSString *)__unused attribute
{
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
    
    NSDictionary *args = [TGStringUtils argumentDictionaryInUrlString:[uri substringFromIndex:[TGLocationVenueIconDataSource uriSchemeFull].length]];
    
    CGSize size = CGSizeZero;
    NSString *imageUrl = [TGLocationVenueIconDataSource iconAddressForUri:uri size:&size];
    UIColor *color = UIColorRGB([args[@"color"] integerValue]);
    
    NSData *iconSourceData = [[[TGMediaStoreContext instance] temporaryFilesCache] getValueForKey:[imageUrl dataUsingEncoding:NSUTF8StringEncoding]];
    UIImage *iconSourceImage = [[UIImage alloc] initWithData:iconSourceData];
    
    UIGraphicsBeginImageContextWithOptions(size, false, 0.0f);
    CGSize renderSize = CGSizeMake(size.width * 0.75f, size.height * 0.75f);
    CGRect imageRect = CGRectMake((size.width - renderSize.width) / 2.0f, (size.height - renderSize.height) / 2.0f, renderSize.width, renderSize.height);
    [TGTintedImage(iconSourceImage, color) drawInRect:imageRect];
    
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
