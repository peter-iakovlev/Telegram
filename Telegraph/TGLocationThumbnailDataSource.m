#import "TGLocationThumbnailDataSource.h"

#import "ASQueue.h"

#import "TGWorkerPool.h"
#import "TGWorkerTask.h"
#import "TGMediaPreviewTask.h"

#import "TGMemoryImageCache.h"

#import "TGImageUtils.h"
#import "TGStringUtils.h"
#import "TGLocationUtils.h"

#import "TGImageBlur.h"
#import "UIImage+TG.h"
#import "NSObject+TGLock.h"

#import "TGMapSnapshotterActor.h"
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

+ (TGMapSnapshotOptions *)snapshotOptionsForUri:(NSString *)uri size:(out CGSize *)size
{
    NSDictionary *args = [TGStringUtils argumentDictionaryInUrlString:[uri substringFromIndex:@"map-thumbnail://?".length]];
    
    CGSize imageSize = CGSizeMake([args[@"width"] intValue], [args[@"height"] intValue]);
    
    if (size != NULL)
        *size = imageSize;
    
    TGMapSnapshotOptions *options = [[TGMapSnapshotOptions alloc] init];

    CLLocationDegrees latitude = [TGLocationUtils adjustGMapLatitude:[args[@"latitude"] doubleValue] withPixelOffset:-10 zoom:15];
    options.region = MKCoordinateRegionMake(CLLocationCoordinate2DMake(latitude, [args[@"longitude"] doubleValue]), MKCoordinateSpanMake(0.003, 0.003));
    options.imageSize = CGSizeMake(imageSize.width + 1, imageSize.height + 24);
    
    return options;
}

+ (NSString *)mapAddressForUri:(NSString *)uri size:(out CGSize *)size
{
    NSDictionary *args = [TGStringUtils argumentDictionaryInUrlString:[uri substringFromIndex:@"map-thumbnail://?".length]];
    
    CGSize imageSize = CGSizeMake([args[@"width"] intValue], [args[@"height"] intValue]);
    
    if (size != NULL)
        *size = imageSize;
    
    CLLocationDegrees latitude = [TGLocationUtils adjustGMapLatitude:[args[@"latitude"] doubleValue] withPixelOffset:-10 zoom:15];
    
    return [[NSString alloc] initWithFormat:@"https://maps.googleapis.com/maps/api/staticmap?center=%.5f,%.5f&zoom=15&size=%dx%d&sensor=false&scale=%d&format=jpg&mobile=true", latitude, [args[@"longitude"] doubleValue], (int)(imageSize.width), (int)(imageSize.height + 24), 2];
}

+ (NSString *)sourceMapIdentifierForUri:(NSString *)uri size:(out CGSize *)size
{
    if (iosMajorVersion() >= 7)
        return [[self snapshotOptionsForUri:uri size:size] uniqueIdentifier];
    else
        return [self mapAddressForUri:uri size:size];
}

- (id)loadDataAsyncWithUri:(NSString *)uri progress:(void (^)(float))progress partialCompletion:(void (^)(TGDataResource *resource))__unused partialCompletion completion:(void (^)(TGDataResource *))completion
{
    TGMediaPreviewTask *previewTask = [[TGMediaPreviewTask alloc] init];
    
    NSDictionary *args = [TGStringUtils argumentDictionaryInUrlString:[uri substringFromIndex:@"map-thumbnail://?".length]];
    bool isFlat = [args[@"flat"] boolValue];
    int cornerRadius = [args[@"cornerRadius"] intValue];
    
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
                completion(result != nil ? result : [TGLocationThumbnailDataSource resultForUnavailableImage:isFlat cornerRadius:cornerRadius]);
        }];
        
        if ([TGLocationThumbnailDataSource _isDataLocallyAvailableForUri:uri])
        {
            [previewTask executeWithWorkerTask:workerTask workerPool:workerPool()];
        }
        else
        {
            if (iosMajorVersion() >= 7)
            {
                CGSize size = CGSizeZero;
                [previewTask executeWithMapSnapshotOptions:[TGLocationThumbnailDataSource snapshotOptionsForUri:uri size:&size] completionWithImage:^(UIImage *image)
                {
                    if (image != nil)
                    {
                        TGWorkerTask *modernWorkerTask = [[TGWorkerTask alloc] initWithBlock:^(bool (^isCancelled)())
                        {
                            TGDataResource *result = [TGLocationThumbnailDataSource _performLoad:uri image:image size:size isCancelled:isCancelled];
                            
                            if (result != nil && progress != nil)
                                progress(1.0f);
                            
                            if (isCancelled != nil && isCancelled())
                                return;
                            
                            if (completion != nil)
                                completion(result != nil ? result : [TGLocationThumbnailDataSource resultForUnavailableImage:isFlat cornerRadius:cornerRadius]);
                        }];
                        
                        [previewTask executeWithWorkerTask:modernWorkerTask workerPool:workerPool()];
                    }
                    else
                    {
                        if (completion != nil)
                            completion([TGLocationThumbnailDataSource resultForUnavailableImage:isFlat cornerRadius:cornerRadius]);
                    }
                } workerTask:workerTask];
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
                            completion([TGLocationThumbnailDataSource resultForUnavailableImage:isFlat cornerRadius:cornerRadius]);
                    }
                } workerTask:workerTask];
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

+ (TGDataResource *)resultForUnavailableImage:(bool)isFlat cornerRadius:(int)cornerRadius
{
    static TGDataResource *normalData = nil;
    static NSMutableDictionary *flatDatas = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^
    {
        normalData = [[TGDataResource alloc] initWithImage:TGAverageColorAttachmentImage([UIColor whiteColor], true) decoded:true];
        flatDatas = [[NSMutableDictionary alloc] init];
    });
    
    if (isFlat)
    {
        TGDataResource *flatData = flatDatas[@(cornerRadius)];
        if (flatData == nil)
        {
            if (cornerRadius == 0)
            {
                flatData = [[TGDataResource alloc] initWithImage:TGAverageColorAttachmentImage([UIColor whiteColor], false) decoded:true];
            }
            else
            {
                flatData = [[TGDataResource alloc] initWithImage:TGAverageColorAttachmentWithCornerRadiusImage([UIColor whiteColor], false, cornerRadius) decoded:true];
            }
            
            flatDatas[@(cornerRadius)] = flatData;
        }
        return flatData;
    }
    else
    {
        return normalData;
    }
}

- (id)loadAttributeSyncForUri:(NSString *)uri attribute:(NSString *)attribute
{
    if ([attribute isEqualToString:@"placeholder"])
    {
        NSDictionary *args = [TGStringUtils argumentDictionaryInUrlString:[uri substringFromIndex:@"map-thumbnail://?".length]];
        bool isFlat = [args[@"flat"] boolValue];
        int cornerRadius = [args[@"cornerRadius"] intValue];
        
        static NSMutableDictionary *placeholderBySize = nil;
        static dispatch_once_t onceToken;
        dispatch_once(&onceToken, ^
        {
            placeholderBySize = [[NSMutableDictionary alloc] init];
        });
        
        CGSize size = CGSizeZero;
        [TGLocationThumbnailDataSource mapAddressForUri:uri size:&size];
        NSString *sizeString = [[NSString alloc] initWithFormat:@"%@-%@", NSStringFromCGSize(size), isFlat ? @"flat" : @"normal"];
        UIImage *placeholder = placeholderBySize[sizeString];
        if (placeholder != nil)
            return placeholder;
        
        UIGraphicsBeginImageContextWithOptions(size, false, 0.0f);
        UIImage *image = nil;
        if (isFlat && (cornerRadius > 0 || cornerRadius == -1))
            image = TGAverageColorAttachmentWithCornerRadiusImage([UIColor whiteColor], !isFlat, cornerRadius == -1 ? 0 : cornerRadius);
        else
            image = TGAverageColorAttachmentImage([UIColor whiteColor], !isFlat);
        [image drawInRect:CGRectMake(0.0f, 0.0f, size.width, size.height) blendMode:kCGBlendModeCopy alpha:1.0f];
        CGRect imageRect = CGRectMake(0.0f, 0.0f, size.width, size.height);
        UIImage *pinImage = [UIImage imageNamed:@"ModernMessageLocationPin.png"];
        [pinImage drawInRect:CGRectMake(imageRect.origin.x + CGFloor((imageRect.size.width - pinImage.size.width) / 2.0f) + 1.0f, imageRect.origin.y + CGFloor((imageRect.size.height - pinImage.size.height) / 2.0f) + 6, pinImage.size.width, pinImage.size.height)];
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
    
    return [TGLocationThumbnailDataSource _performLoad:uri isCancelled:nil];
}

+ (bool)_isDataLocallyAvailableForUri:(NSString *)uri
{
    NSString *mapAddress = [self sourceMapIdentifierForUri:uri size:NULL];
    return [[[TGMediaStoreContext instance] temporaryFilesCache] containsValueForKey:[mapAddress dataUsingEncoding:NSUTF8StringEncoding]];
}

+ (TGDataResource *)_performLoad:(NSString *)uri isCancelled:(bool (^)())isCancelled
{
    if (isCancelled && isCancelled())
        return nil;
    
    CGSize size = CGSizeZero;
    NSString *imageUrl = [TGLocationThumbnailDataSource sourceMapIdentifierForUri:uri size:&size];
    
    NSData *thumbnailSourceData = [[[TGMediaStoreContext instance] temporaryFilesCache] getValueForKey:[imageUrl dataUsingEncoding:NSUTF8StringEncoding]];
    UIImage *image = [[UIImage alloc] initWithData:thumbnailSourceData];
    
    return [self _performLoad:uri image:image size:size isCancelled:isCancelled];
}

+ (TGDataResource *)_performLoad:(NSString *)uri image:(UIImage *)image size:(CGSize)size isCancelled:(bool (^)())isCancelled
{
    if (isCancelled && isCancelled())
        return nil;
    
    NSDictionary *args = [TGStringUtils argumentDictionaryInUrlString:[uri substringFromIndex:@"map-thumbnail://?".length]];
    
    UIGraphicsBeginImageContextWithOptions(size, true, 0.0f);
    
    CGRect imageRect = CGRectMake(0.0f, -12.0f, size.width + 1.0f, size.height + 24.0f);
    [image drawInRect:imageRect blendMode:kCGBlendModeCopy alpha:1.0f];
    
    UIImage *pinImage = [UIImage imageNamed:@"ModernMessageLocationPin.png"];
    [pinImage drawInRect:CGRectMake(imageRect.origin.x + CGFloor((imageRect.size.width - pinImage.size.width) / 2.0f) + 1.0f, imageRect.origin.y + CGFloor((imageRect.size.height - pinImage.size.height) / 2.0f) + 6, pinImage.size.width, pinImage.size.height)];
    
    image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    bool isFlat = [args[@"flat"] boolValue];
    int cornerRadius = [args[@"cornerRadius"] intValue];
    
    if (image != nil)
    {
        NSNumber *averageColor = [[TGMediaStoreContext instance] mediaImageAverageColor:uri];
        bool needsAverageColor = averageColor == nil;
        uint32_t averageColorValue = [averageColor intValue];
     
        uint32_t *averageColorPtr = needsAverageColor ? &averageColorValue : NULL;
        
        UIImage *thumbnailImage = nil;
        if (isFlat && (cornerRadius > 0 || cornerRadius == -1))
            thumbnailImage = TGLoadedAttachmentWithCornerRadiusImage(image, size, averageColorPtr, !isFlat, cornerRadius == -1 ? 0 : cornerRadius, 0);
        else
            thumbnailImage = TGLoadedAttachmentImage(image, size, averageColorPtr, !isFlat);
        
        if (thumbnailImage != nil)
        {
            [[TGMediaStoreContext instance] setMediaImageAverageColorForKey:uri averageColor:@(averageColorValue)];
            [[TGMediaStoreContext instance] setMediaImageForKey:uri image:thumbnailImage attributes:nil];
            
            return [[TGDataResource alloc] initWithImage:thumbnailImage decoded:true];
        }
    }
    
    return nil;
}

@end
