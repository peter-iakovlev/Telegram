#import "TGSharedMediaSignals.h"

#import "TGImageInfo+Telegraph.h"
#import <libkern/OSAtomic.h>
#import "TL/TLMetaScheme.h"
#import <SSignalKit/SSignalKit.h>

#import "TGRemoteFileSignal.h"
#import "TGRemoteHttpLocationSignal.h"

#import "TGMemoryImageCache.h"
#import "TGListThumbnailSignals.h"
#import "TGImageBlur.h"
#import "TGImageUtils.h"
#import "TGModernCache.h"

#import "TGWebDocument.h"

#import "TGStringUtils.h"
#import "TGSharedMediaUtils.h"

@implementation TGSharedMediaImageData

- (instancetype)initWithData:(NSData *)data quality:(TGSharedMediaImageDataQuality)quality preBlurred:(bool)preBlurred
{
    self = [super init];
    if (self != nil)
    {
        _data = data;
        _quality = quality;
        _preBlurred = preBlurred;
    }
    return self;
}

@end

@interface TGSharedMediaSignals ()
{
    SMulticastSignalManager *_signalManager;
}

@end

@implementation TGSharedMediaImageProgress

- (instancetype)initWithHasProgress:(bool)hasProgress value:(CGFloat)value
{
    self = [super init];
    if (self != nil)
    {
        _hasProgress = hasProgress;
        _value = value;
    }
    return self;
}

@end

@implementation TGSharedMediaSignals

+ (TGSharedMediaSignals *)instance
{
    static TGSharedMediaSignals *singleton = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^
    {
        singleton = [[TGSharedMediaSignals alloc] init];
    });
    
    return singleton;
}

- (instancetype)init
{
    self = [super init];
    if (self != nil)
    {
        _signalManager = [[SMulticastSignalManager alloc] init];
    }
    return self;
}

+ (TLInputFileLocation *)inputFileLocationForImageUrl:(NSString *)imageUrl datacenterId:(NSInteger *)outDatacenterId
{
    int32_t datacenterId = 0;
    int64_t volumeId = 0;
    int32_t localId = 0;
    int64_t secret = 0;
    if (extractFileUrlComponents(imageUrl, &datacenterId, &volumeId, &localId, &secret))
    {
        TLInputFileLocation$inputFileLocation *location = [[TLInputFileLocation$inputFileLocation alloc] init];
        location.volume_id = volumeId;
        location.local_id = localId;
        location.secret = secret;
        
        if (outDatacenterId != NULL)
            *outDatacenterId = datacenterId;
        return location;
    }
    else
        return nil;
}

+ (TLInputWebFileLocation *)inputWebFileLocationForImageUrl:(NSString *)imageUrl datacenterId:(NSInteger *)outDatacenterId {
    TGWebDocumentReference *reference = [[TGWebDocumentReference alloc] initWithString:imageUrl];
    if (reference != nil) {
        TLInputWebFileLocation$inputWebFileLocation *location = [[TLInputWebFileLocation$inputWebFileLocation alloc] init];
        location.url = reference.url;
        location.access_hash = reference.accessHash;
        if (outDatacenterId) {
            *outDatacenterId = (NSInteger)reference.datacenterId;
        }
        return location;
    } else {
        return nil;
    }
}

- (NSString *)keyForLocation:(id)location
{
    if ([location isKindOfClass:[TLInputFileLocation$inputDocumentFileLocation class]])
    {
        return [[NSString alloc] initWithFormat:@"document-%" PRId64 "", ((TLInputFileLocation$inputDocumentFileLocation *)location).n_id];
    }
    else if ([location isKindOfClass:[TLInputFileLocation$inputEncryptedFileLocation class]])
    {
        return [[NSString alloc] initWithFormat:@"encrypted-%" PRId64 "", ((TLInputFileLocation$inputEncryptedFileLocation *)location).n_id];
    }
    else if ([location isKindOfClass:[TLInputFileLocation$inputFileLocation class]])
    {
        return [[NSString alloc] initWithFormat:@"image-%" PRId64 "_%" PRId32, ((TLInputFileLocation$inputFileLocation *)location).volume_id, ((TLInputFileLocation$inputFileLocation *)location).local_id];
    }
    else if ([location isKindOfClass:[TLInputWebFileLocation$inputWebFileLocation class]])
    {
        return [[NSString alloc] initWithFormat:@"web-%d", murMurHash32(((TLInputWebFileLocation$inputWebFileLocation *)location).url)];
    }
    
    return nil;
}

- (SSignal *)_memoizedDataSignalForRemoteLocation:(TLInputFileLocation *)location datacenterId:(NSInteger)datacenterId reportProgress:(bool)reportProgress mediaTypeTag:(TGNetworkMediaTypeTag)mediaTypeTag
{
    NSString *key = [self keyForLocation:location];
    if (key == nil)
        return nil;
    
    return [_signalManager multicastedSignalForKey:key producer:^SSignal *
    {
        return [TGRemoteFileSignal dataForLocation:location datacenterId:datacenterId size:0 reportProgress:reportProgress mediaTypeTag:mediaTypeTag];
    }];
}

- (SSignal *)_memoizedDataSignalForRemoteWebLocation:(TLInputWebFileLocation *)location datacenterId:(NSInteger)datacenterId reportProgress:(bool)reportProgress mediaTypeTag:(TGNetworkMediaTypeTag)mediaTypeTag
{
    NSString *key = [self keyForLocation:location];
    if (key == nil)
        return nil;
    
    return [_signalManager multicastedSignalForKey:key producer:^SSignal *
    {
        return [TGRemoteFileSignal dataForWebLocation:location datacenterId:datacenterId size:0 reportProgress:reportProgress mediaTypeTag:mediaTypeTag];
    }];
}

- (SSignal *)_memoizedDataSignalForHttpUrl:(NSString *)httpUrl
{
    NSString *key = httpUrl;
    if (key == nil)
        return nil;
    
    return [_signalManager multicastedSignalForKey:key producer:^SSignal *
    {
        return [TGRemoteHttpLocationSignal dataForHttpLocation:httpUrl];
    }];
}

+ (SSignal *)memoizedDataSignalForRemoteLocation:(TLInputFileLocation *)location datacenterId:(NSInteger)datacenterId reportProgress:(bool)reportProgress mediaTypeTag:(TGNetworkMediaTypeTag)mediaTypeTag
{
    return [[self instance] _memoizedDataSignalForRemoteLocation:location datacenterId:datacenterId reportProgress:reportProgress mediaTypeTag:mediaTypeTag];
}

+ (SSignal *)memoizedDataSignalForRemoteWebLocation:(TLInputWebFileLocation *)location datacenterId:(NSInteger)datacenterId reportProgress:(bool)reportProgress mediaTypeTag:(TGNetworkMediaTypeTag)mediaTypeTag {
    return [[self instance] _memoizedDataSignalForRemoteWebLocation:location datacenterId:datacenterId reportProgress:reportProgress mediaTypeTag:mediaTypeTag];
}

+ (SSignal *)memoizedDataSignalForHttpUrl:(NSString *)httpUrl
{
    return [[self instance] _memoizedDataSignalForHttpUrl:httpUrl];
}

+ (SSignal *)sharedMediaImageWithSize:(CGSize)size
                 pixelProcessingBlock:(void (^)(void *, int, int, int))pixelProcessingBlock
                             cacheKey:(NSString *)cacheKey
                 progressiveImageData:(SSignal *(^)())progressiveImageData
                       cacheImageData:(void (^)(UIImage *, TGSharedMediaImageDataQuality))cacheImageData
                           threadPool:(SThreadPool *)threadPool
                          memoryCache:(TGMemoryImageCache *)memoryCache
{
    SSignal *signal = nil;
    
    NSDictionary *cachedImageAttributes = nil;
    UIImage *cachedImage = [memoryCache imageForKey:cacheKey attributes:&cachedImageAttributes];
    if (cachedImage != nil)
        signal = [SSignal single:cachedImage];
    
    if (cachedImage == nil || [cachedImageAttributes[@"quality"] intValue] != TGSharedMediaImageDataQualityNormal)
    {
        SSignal *progressiveImageDataSignal = progressiveImageData();
        if (signal == nil)
            signal = progressiveImageDataSignal;
        else
            signal = [signal then:progressiveImageDataSignal];
        
        signal = [signal mapToQueue:^SSignal *(id next)
        {
            if ([next isKindOfClass:[TGSharedMediaImageData class]])
            {
                return [[[SSignal alloc] initWithGenerator:^id<SDisposable>(SSubscriber *subscriber)
                {
                    TGSharedMediaImageData *imageData = next;
                    UIImage *rawImage = [[UIImage alloc] initWithData:imageData.data];
                    
                    UIImage *image = [TGListThumbnailSignals listThumbnail:size image:rawImage blurImage:imageData.quality == TGSharedMediaImageDataQualityLow && !imageData.preBlurred averageColor:NULL pixelProcessingBlock:pixelProcessingBlock];
                    
                    [memoryCache setImage:image forKey:cacheKey attributes:@{@"quality": @(imageData.quality)}];
                    
                    if (cacheImageData)
                        cacheImageData(image, imageData.quality);
                    
                    [subscriber putNext:image];
                    if (imageData.quality == TGSharedMediaImageDataQualityNormal)
                        [subscriber putNext:@(2.0f)];
                    [subscriber putCompletion];
                    
                    return nil;
                }] startOnThreadPool:threadPool];
            }
            else
                return [SSignal single:next];
        }];
    }
    
    return signal;
}

+ (SSignal *)squareThumbnail:(NSString *)cachedSizeLowPath
            cachedSizePath:(NSString *)cachedSizePath ofSize:(CGSize)size renderSize:(CGSize)renderSize
            pixelProcessingBlock:(void (^)(void *, int, int, int))pixelProcessingBlock
            fullSizeImageSignalGenerator:(SSignal *(^)())fullSizeImageSignalGenerator
            lowQualityThumbnailSignalGenerator:(SSignal *(^)())lowQualityThumbnailSignalGenerator
            localCachedImageSignalGenerator:(SSignal *(^)(CGSize, CGSize, bool))localCachedImageSignalGenerator
            lowQualityImagePath:(NSString *)lowQualityImagePath
            lowQualityImageUrl:(NSString *)lowQualityImageUrl
            highQualityImageUrl:(NSString *)highQualityImageUrl
            highQualityImageIdentifier:(NSString *)__unused highQualityImageIdentifier
            threadPool:(SThreadPool *)threadPool
            memoryCache:(TGMemoryImageCache *)memoryCache
            placeholder:(SSignal *)__unused placeholder
            blurLowQuality:(bool)blurLowQuality
{
    __block bool lowQuality = false;
    __block bool alreadyBlurred = false;
    __block bool cacheResult = false;
    
    UIImage *cachedImage = [memoryCache imageForKey:cachedSizePath attributes:NULL];
    if (cachedImage != nil)
        return [SSignal single:cachedImage];
    
    cachedImage = [memoryCache imageForKey:cachedSizeLowPath attributes:NULL];
    if (cachedImage != nil)
    {
        SSignal *fetchFullSizeImageInBackground = [[fullSizeImageSignalGenerator() catch:^SSignal *(__unused id error)
        {
            if (highQualityImageUrl != nil)
            {
                NSInteger datacenterId = 0;
                TLInputFileLocation *location = [TGSharedMediaSignals inputFileLocationForImageUrl:highQualityImageUrl datacenterId:&datacenterId];
                
                if (location != nil)
                {
                    return [[TGSharedMediaSignals memoizedDataSignalForRemoteLocation:location datacenterId:datacenterId reportProgress:false mediaTypeTag:TGNetworkMediaTypeTagImage] mapToSignal:^SSignal *(NSData *data)
                    {
                        lowQuality = false;
                        cacheResult = true;
                        
                        //[data writeToFile:lowQualityImagePath atomically:true];
                        
                        UIImage *image = [[UIImage alloc] initWithData:data];
                        if (image == nil)
                            return [SSignal complete];
                        else
                            return [SSignal single:image];
                    }];
                }
            }
            
            return [SSignal complete];
        }] startOnThreadPool:threadPool];
        
        return [[SSignal single:cachedImage] then:[[fetchFullSizeImageInBackground mapToSignal:^SSignal *(UIImage *image)
        {
            CGSize optimizedSize = size;
            return [[TGListThumbnailSignals signalForListThumbnail:optimizedSize image:image blurImage:false pixelProcessingBlock:pixelProcessingBlock calculateAverageColor:false] filter:^bool (id next)
            {
                return [next isKindOfClass:[UIImage class]];
            }];
        }] map:^UIImage *(UIImage *image)
        {
            if (cacheResult)
            {
                dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^
                {
                    [UIImageJPEGRepresentation(image, 0.8f) writeToFile:lowQuality ? cachedSizeLowPath : cachedSizePath atomically:true];
                });
            }
            [memoryCache setImage:image forKey:cachedSizePath attributes:nil];
            return image;
        }]];
    }
    
    bool averageColorCalculated = false;
    uint32_t averageColor = 0;
    averageColorCalculated = [memoryCache averageColorForKey:cachedSizePath color:&averageColor];
    
    SSignal *signal = [[[[[[[localCachedImageSignalGenerator(size, renderSize, false) catch:^SSignal *(__unused id error)
    {
        cacheResult = true;
        return fullSizeImageSignalGenerator();
    }] catch:^SSignal *(__unused id error)
    {
        lowQuality = true;
        SSignal *nextSignal = [localCachedImageSignalGenerator(size, renderSize, true) map:^id (UIImage *image)
        {
            alreadyBlurred = true;
            lowQuality = true;
            cacheResult = false;
            return image;
        }];
        
        if (highQualityImageUrl != nil)
        {
            NSInteger datacenterId = 0;
            
            TLInputWebFileLocation *webLocation = [TGSharedMediaSignals inputWebFileLocationForImageUrl:highQualityImageUrl datacenterId:&datacenterId];
            if (webLocation != nil) {
                nextSignal = [nextSignal then:[[TGSharedMediaSignals memoizedDataSignalForRemoteWebLocation:webLocation datacenterId:datacenterId reportProgress:false mediaTypeTag:TGNetworkMediaTypeTagImage] mapToSignal:^SSignal *(NSData *data)
                {
                    lowQuality = false;
                    [[TGSharedMediaUtils sharedMediaTemporaryPersistentCache] setValue:data forKey:[highQualityImageUrl dataUsingEncoding:NSUTF8StringEncoding]];
                    //[data writeToFile:lowQualityImagePath atomically:true];
                    
                    UIImage *image = [[UIImage alloc] initWithData:data];
                    if (image == nil)
                        return [SSignal complete];
                    else
                        return [SSignal single:image];
                }]];
            } else {
                TLInputFileLocation *location = [TGSharedMediaSignals inputFileLocationForImageUrl:highQualityImageUrl datacenterId:&datacenterId];
                
                if (location != nil)
                {
                    nextSignal = [nextSignal then:[[TGSharedMediaSignals memoizedDataSignalForRemoteLocation:location datacenterId:datacenterId reportProgress:false mediaTypeTag:TGNetworkMediaTypeTagImage] mapToSignal:^SSignal *(NSData *data)
                    {
                        lowQuality = false;
                        //[data writeToFile:lowQualityImagePath atomically:true];
                        
                        UIImage *image = [[UIImage alloc] initWithData:data];
                        if (image == nil)
                            return [SSignal complete];
                        else
                            return [SSignal single:image];
                    }]];
                } else if ([highQualityImageUrl hasPrefix:@"https://"] || [highQualityImageUrl hasPrefix:@"http://"]) {
                    nextSignal = [nextSignal then:[[TGRemoteHttpLocationSignal dataForHttpLocation:highQualityImageUrl] mapToSignal:^SSignal *(NSData *data)
                    {
                        lowQuality = false;
                        //[data writeToFile:lowQualityImagePath atomically:true];
                        
                        UIImage *image = [[UIImage alloc] initWithData:data];
                        if (image == nil)
                            return [SSignal complete];
                        else
                            return [SSignal single:image];
                    }]];
                }
            }
        }
        
        return nextSignal;
    }] catch:^SSignal *(__unused id error)
    {
        SSignal *nextSignal = lowQualityThumbnailSignalGenerator();
        
        if (highQualityImageUrl != nil)
        {
            NSInteger datacenterId = 0;
            
            TLInputWebFileLocation *webLocation = [TGSharedMediaSignals inputWebFileLocationForImageUrl:highQualityImageUrl datacenterId:&datacenterId];
            if (webLocation != nil) {
                nextSignal = [nextSignal then:[[TGSharedMediaSignals memoizedDataSignalForRemoteWebLocation:webLocation datacenterId:datacenterId reportProgress:false mediaTypeTag:TGNetworkMediaTypeTagImage] mapToSignal:^SSignal *(NSData *data)
                {
                    lowQuality = false;
                    [[TGSharedMediaUtils sharedMediaTemporaryPersistentCache] setValue:data forKey:[highQualityImageUrl dataUsingEncoding:NSUTF8StringEncoding]];
                    //[data writeToFile:lowQualityImagePath atomically:true];
                    
                    UIImage *image = [[UIImage alloc] initWithData:data];
                    if (image == nil)
                        return [SSignal complete];
                    else
                        return [SSignal single:image];
                }]];
            } else {
                TLInputFileLocation *location = [TGSharedMediaSignals inputFileLocationForImageUrl:highQualityImageUrl datacenterId:&datacenterId];
                
                if (location != nil)
                {
                    nextSignal = [nextSignal then:[[TGSharedMediaSignals memoizedDataSignalForRemoteLocation:location datacenterId:datacenterId reportProgress:false mediaTypeTag:TGNetworkMediaTypeTagImage] mapToSignal:^SSignal *(NSData *data)
                    {
                        lowQuality = false;
                        //[data writeToFile:lowQualityImagePath atomically:true];
                        
                        UIImage *image = [[UIImage alloc] initWithData:data];
                        if (image == nil)
                            return [SSignal complete];
                        else
                            return [SSignal single:image];
                    }]];
                }
            }
        }
        
        return nextSignal;
    }] catch:^SSignal *(__unused id error)
    {
        NSInteger datacenterId = 0;
        TLInputFileLocation *location = [TGSharedMediaSignals inputFileLocationForImageUrl:lowQualityImageUrl datacenterId:&datacenterId];
        if (location == nil) {
            if (highQualityImageUrl != nil)
            {
                NSInteger datacenterId = 0;
                
                TLInputWebFileLocation *webLocation = [TGSharedMediaSignals inputWebFileLocationForImageUrl:highQualityImageUrl datacenterId:&datacenterId];
                if (webLocation != nil) {
                    return [[TGSharedMediaSignals memoizedDataSignalForRemoteWebLocation:webLocation datacenterId:datacenterId reportProgress:false mediaTypeTag:TGNetworkMediaTypeTagImage] mapToSignal:^SSignal *(NSData *data)
                    {
                        lowQuality = false;
                        [[TGSharedMediaUtils sharedMediaTemporaryPersistentCache] setValue:data forKey:[highQualityImageUrl dataUsingEncoding:NSUTF8StringEncoding]];
                        //[data writeToFile:lowQualityImagePath atomically:true];
                        
                        UIImage *image = [[UIImage alloc] initWithData:data];
                        if (image == nil)
                            return [SSignal complete];
                        else
                            return [SSignal single:image];
                    }];
                }
            }
            return [SSignal fail:nil];
        }
        else
        {
            return [[TGSharedMediaSignals memoizedDataSignalForRemoteLocation:location datacenterId:datacenterId reportProgress:false mediaTypeTag:TGNetworkMediaTypeTagImage] mapToSignal:^SSignal *(NSData *data)
            {
                NSString *directoryPath = [lowQualityImagePath substringToIndex:lowQualityImagePath.length - ((NSString *)[lowQualityImagePath pathComponents].lastObject).length];
                [[NSFileManager defaultManager] createDirectoryAtPath:directoryPath withIntermediateDirectories:true attributes:nil error:NULL];
                
                [data writeToFile:lowQualityImagePath atomically:true];
                
                SSignal *nextSignal = nil;
                
                UIImage *image = [[UIImage alloc] initWithData:data];
                if (image != nil)
                    nextSignal = [SSignal single:image];
                else
                    nextSignal = [SSignal fail:nil];
                
                if (highQualityImageUrl != nil)
                {
                    NSInteger datacenterId = 0;
                    TLInputFileLocation *location = [TGSharedMediaSignals inputFileLocationForImageUrl:highQualityImageUrl datacenterId:&datacenterId];
                    
                    if (location != nil)
                    {
                        nextSignal = [nextSignal then:[[TGSharedMediaSignals memoizedDataSignalForRemoteLocation:location datacenterId:datacenterId reportProgress:false mediaTypeTag:TGNetworkMediaTypeTagImage] mapToSignal:^SSignal *(NSData *data)
                        {
                            lowQuality = false;
                            //[data writeToFile:lowQualityImagePath atomically:true];
                            
                            UIImage *image = [[UIImage alloc] initWithData:data];
                            if (image == nil)
                                return [SSignal complete];
                            else
                                return [SSignal single:image];
                        }]];
                    }
                }
                
                return nextSignal;
            }];
        }
    }] mapToSignal:^SSignal *(UIImage *image)
    {
        CGSize optimizedSize = size;
        if (lowQuality && pixelProcessingBlock == nil)
            optimizedSize = TGFitSize(size, CGSizeMake(25.0f, 25.0f));
        return [[TGListThumbnailSignals signalForListThumbnail:optimizedSize image:image blurImage:lowQuality && !alreadyBlurred && blurLowQuality pixelProcessingBlock:pixelProcessingBlock calculateAverageColor:!averageColorCalculated] filter:^bool(id next)
        {
            if ([next isKindOfClass:[UIImage class]])
                return true;
            else
                [memoryCache setAverageColor:(uint32_t)[next unsignedIntValue] forKey:cachedSizePath];
            
            return false;
        }];
    }] map:^id (UIImage *image)
    {
        if (cacheResult)
        {
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^
            {
                NSData *data = UIImageJPEGRepresentation(image, 0.8f);
                NSString *path = lowQuality ? cachedSizeLowPath : cachedSizePath;
                [[NSFileManager defaultManager] createDirectoryAtPath:[path substringToIndex:path.length - [path lastPathComponent].length] withIntermediateDirectories:true attributes:nil error:nil];
                [data writeToFile:path atomically:true];
            });
        }
        [memoryCache setImage:image forKey:lowQuality ? cachedSizeLowPath : cachedSizePath attributes:nil];
        return image;
    }] startOnThreadPool:threadPool];
    
    if (averageColorCalculated && !pixelProcessingBlock)
        return [[SSignal single:TGAverageColorImage(UIColorRGB(averageColor))] then:signal];
    
    return signal;
}

+ (SSignal *)cachedRemoteThumbnailWithKey:(NSString *)key size:(CGSize)size pixelProcessingBlock:(void (^)(void *, int, int, int))pixelProcessingBlock fetchData:(SSignal *)fetchData originalImage:(SSignal *)originalImage threadPool:(SThreadPool *)threadPool memoryCache:(TGMemoryImageCache *)memoryCache diskCache:(TGModernCache *)diskCache {
    NSString *hdKey = [key stringByAppendingString:@"-hd"];
    NSString *ldKey = [key stringByAppendingString:@"-ld"];
    
    UIImage *cachedImage = [memoryCache imageForKey:hdKey attributes:NULL];
    if (cachedImage != nil) {
        return [SSignal single:cachedImage];
    }
    
    UIImage *(^processOriginal)(UIImage *, bool) = ^UIImage *(UIImage *sourceImage, bool blur) {
        return [TGListThumbnailSignals listThumbnail:size image:sourceImage blurImage:blur averageColor:NULL pixelProcessingBlock:pixelProcessingBlock];
    };
    
    SSignal *cachedOriginal = [[SSignal alloc] initWithGenerator:^id<SDisposable>(SSubscriber *subscriber) {
        [diskCache getValueForKey:[hdKey dataUsingEncoding:NSUTF8StringEncoding] completion:^(NSData *data) {
            UIImage *image = nil;
            if (data != nil) {
                UIImage *sourceImage = [[UIImage alloc] initWithData:data];
                if (sourceImage != nil) {
                    image = processOriginal(sourceImage, false);
                }
            }
            
            if (image != nil) {
                [memoryCache setImage:image forKey:hdKey attributes:nil];
                [subscriber putNext:image];
                [subscriber putCompletion];
            } else {
                [subscriber putError:nil];
            }
        }];
        
        return nil;
    }];
    
    SSignal *fetchOriginal = [SSignal defer:^SSignal *{
        return [cachedOriginal catch:^SSignal *(__unused id error) {
            return [[originalImage catch:^SSignal *(__unused id error) {
                return [SSignal fail:nil];
            }] mapToSignal:^SSignal *(UIImage *sourceImage) {
                return [[SSignal alloc] initWithGenerator:^id<SDisposable>(SSubscriber *subscriber) {
                    UIImage *image = processOriginal(sourceImage, false);
                    if (image != nil) {
                        [memoryCache setImage:image forKey:hdKey attributes:nil];
                        [diskCache setValue:UIImageJPEGRepresentation(image, 0.8f) forKey:[hdKey dataUsingEncoding:NSUTF8StringEncoding]];
                        [subscriber putNext:image];
                        [subscriber putCompletion];
                    } else {
                        [subscriber putError:nil];
                    }
                    
                    return nil;
                }];
            }];
        }];
    }];
    
    cachedImage = [memoryCache imageForKey:ldKey attributes:NULL];
    if (cachedImage != nil) {
        return [[SSignal single:cachedImage] then:[fetchOriginal catch:^SSignal *(__unused id error) {
            return [SSignal complete];
        }]];
    }
    
    return [fetchOriginal catch:^SSignal *(__unused id error) {
        return [[[[SSignal alloc] initWithGenerator:^id<SDisposable>(SSubscriber *subscriber) {
            [diskCache getValueForKey:[ldKey dataUsingEncoding:NSUTF8StringEncoding] completion:^(NSData *data) {
                if (data != nil) {
                    [subscriber putNext:data];
                    [subscriber putCompletion];
                } else {
                    [subscriber putError:nil];
                }
            }];
            
            return nil;
        }] catch:^SSignal *(__unused id error) {
            return [fetchData onNext:^(NSData *data) {
                if (data != nil) {
                    [diskCache setValue:data forKey:[ldKey dataUsingEncoding:NSUTF8StringEncoding]];
                }
            }];
        }] mapToSignal:^SSignal *(NSData *data) {
            return [[[SSignal alloc] initWithGenerator:^id<SDisposable>(SSubscriber *subscriber) {
                UIImage *sourceImage = [[UIImage alloc] initWithData:data];
                
                if (sourceImage == nil) {
                    [subscriber putError:nil];
                } else {
                    UIImage *image = processOriginal(sourceImage, false);
                    if (image != nil) {
                        [memoryCache setImage:image forKey:ldKey attributes:nil];
                        [subscriber putNext:image];
                        [subscriber putCompletion];
                    } else {
                        [subscriber putError:nil];
                    }
                }
                
                return nil;
            }] startOnThreadPool:threadPool];
        }];
    }];
}

+ (void (^)(void *, int, int, int))pixelProcessingBlockForRoundCornersOfRadius:(CGFloat)radius
{
    return ^(void *targetMemory, int width, int height, int stride)
    {
        TGAddImageCorners(targetMemory, width, height, stride, (int)radius);
    };
}

@end
