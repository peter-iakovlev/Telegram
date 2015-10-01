#import "TGSharedPhotoSignals.h"

#import "TGSharedMediaSignals.h"

#import "TGImageMediaAttachment.h"
#import "TGImageUtils.h"

#import "TGImageInfo+Telegraph.h"
#import "TGRemoteImageView.h"

#import "TGAppDelegate.h"

@implementation TGSharedPhotoSignals

+ (NSString *)pathForPhotoDirectory:(TGImageMediaAttachment *)imageAttachment
{
    static NSString *filesDirectory = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^
    {
        filesDirectory = [[TGAppDelegate documentsPath] stringByAppendingPathComponent:@"files"];
    });
    
    NSString *photoDirectoryName = nil;
    if (imageAttachment.imageId != 0)
        photoDirectoryName = [[NSString alloc] initWithFormat:@"image-remote-%" PRIx64 "", imageAttachment.imageId];
    else
        photoDirectoryName = [[NSString alloc] initWithFormat:@"image-local-%" PRIx64 "", imageAttachment.localImageId];
    return [filesDirectory stringByAppendingPathComponent:photoDirectoryName];
}

+ (UIImage *)_localCachedImageForPhotoThumbnail:(TGImageMediaAttachment *)imageAttachment ofSize:(CGSize)size renderSize:(CGSize)renderSize lowQuality:(bool)lowQuality
{
    NSString *photoDirectoryPath = [self pathForPhotoDirectory:imageAttachment];
    NSString *cachedSizePath = [photoDirectoryPath stringByAppendingPathComponent:[[NSString alloc] initWithFormat:@"thumbnail-%dx%d-%dx%d%@.jpg", (int)size.width, (int)size.height, (int)renderSize.width, (int)renderSize.height, lowQuality ? @"-low" : @""]];
    UIImage *cachedSizeImage = [[UIImage alloc] initWithContentsOfFile:cachedSizePath];
    return cachedSizeImage;
}

+ (SSignal *)localCachedImageForPhotoThumbnail:(TGImageMediaAttachment *)imageAttachment ofSize:(CGSize)size renderSize:(CGSize)renderSize lowQuality:(bool)lowQuality
{
    return [[SSignal alloc] initWithGenerator:^id<SDisposable> (SSubscriber *subscriber)
    {
        UIImage *cachedSizeImage = [self _localCachedImageForPhotoThumbnail:imageAttachment ofSize:size renderSize:renderSize lowQuality:lowQuality];
        if (cachedSizeImage != nil)
        {
            [subscriber putNext:cachedSizeImage];
            [subscriber putCompletion];
        }
        else
            [subscriber putError:nil];
        
        return nil;
    }];
}

+ (SSignal *)localImageForLowQualityPhotoThumbnail:(TGImageMediaAttachment *)imageAttachment
{
    return [[SSignal alloc] initWithGenerator:^id<SDisposable> (SSubscriber *subscriber)
    {
        NSString *photoDirectoryPath = [self pathForPhotoDirectory:imageAttachment];
        
        NSString *genericThumbnailPath = [photoDirectoryPath stringByAppendingPathComponent:@"image-thumb.jpg"];
        UIImage *genericThumbnailImage = [[UIImage alloc] initWithContentsOfFile:genericThumbnailPath];
        if (genericThumbnailImage != nil)
        {
            [subscriber putNext:genericThumbnailImage];
            [subscriber putCompletion];
        }
        else
            [subscriber putError:nil];
        
        return nil;
    }];
}

+ (SSignal *)localImageForFullSizeImage:(TGImageMediaAttachment *)imageAttachment
{
    return [[SSignal alloc] initWithGenerator:^id<SDisposable> (SSubscriber *subscriber)
    {
        NSString *photoDirectoryPath = [self pathForPhotoDirectory:imageAttachment];
        
        NSString *fullImagePath = [photoDirectoryPath stringByAppendingPathComponent:@"image.jpg"];
        UIImage *fullImage = [[UIImage alloc] initWithContentsOfFile:fullImagePath];
        if (fullImage == nil)
        {
            NSString *imageUrl = [imageAttachment.imageInfo imageUrlForLargestSize:NULL];
            NSString *legacyFilePath = [[TGRemoteImageView sharedCache] pathForCachedData:imageUrl];
            fullImage = [[UIImage alloc] initWithContentsOfFile:legacyFilePath];
        }
        if (fullImage != nil)
        {
            [subscriber putNext:fullImage];
            [subscriber putCompletion];
        }
        else
            [subscriber putError:nil];
        
        return nil;
    }];
}

+ (NSString *)cachedThumbnailPathForDirectory:(NSString *)directory size:(CGSize)size renderSize:(CGSize)renderSize quality:(TGSharedMediaImageDataQuality)quality
{
    return [directory stringByAppendingPathComponent:[[NSString alloc] initWithFormat:@"thumbnail-%dx%d-%dx%d%@.jpg", (int)size.width, (int)size.height, (int)renderSize.width, (int)renderSize.height, quality == TGSharedMediaImageDataQualityLow ? @"-low" : @""]];
}

+ (SSignal *)cachedPhotoSizeData:(NSString *)directory size:(CGSize)size renderSize:(CGSize)renderSize
{
    return [[SSignal alloc] initWithGenerator:^id<SDisposable>(SSubscriber *subscriber)
    {
        NSArray *candidatePaths = @[
            @{@"path": [self cachedThumbnailPathForDirectory:directory size:size renderSize:renderSize quality:TGSharedMediaImageDataQualityNormal],
              @"quality": @(TGSharedMediaImageDataQualityNormal)},
            @{@"path": [self cachedThumbnailPathForDirectory:directory size:size renderSize:renderSize quality:TGSharedMediaImageDataQualityLow],
              @"quality": @(TGSharedMediaImageDataQualityLow)}
        ];
        for (NSDictionary *candidate in candidatePaths)
        {
            if ([[NSFileManager defaultManager] fileExistsAtPath:candidate[@"path"] isDirectory:NULL])
            {
                TGSharedMediaImageDataQuality quality = (TGSharedMediaImageDataQuality)[candidate[@"quality"] intValue];
                [subscriber putNext:[[TGSharedMediaImageData alloc] initWithData:[[NSData alloc] initWithContentsOfFile:candidate[@"path"]] quality:quality preBlurred:quality == TGSharedMediaImageDataQualityLow]];
                [subscriber putCompletion];
                return nil;
            }
        }
        
        [subscriber putError:nil];
        return nil;
    }];
}

+ (SSignal *)localImageData:(NSString *)directory size:(CGSize)size quality:(TGSharedMediaImageDataQuality)quality
{
    return [[SSignal alloc] initWithGenerator:^id<SDisposable>(SSubscriber *subscriber)
    {
        NSString *key = [[NSString alloc] initWithFormat:@"image-%dx%d", (int)size.width, (int)size.height];
        NSString *path = [directory stringByAppendingPathComponent:key];
        NSData *data = [[NSData alloc] initWithContentsOfFile:path];
        
        if (data != nil)
        {
            [subscriber putNext:[[TGSharedMediaImageData alloc] initWithData:data quality:quality preBlurred:false]];
            [subscriber putCompletion];
            return nil;
        }
        
        [subscriber putError:nil];
        return nil;
    }];
}

+ (SSignal *)remoteImageData:(NSString *)directory size:(CGSize)size quality:(TGSharedMediaImageDataQuality)quality url:(NSString *)url reportProgress:(bool)reportProgress
{
    NSInteger datacenterId = 0;
    TLInputFileLocation *location = [TGSharedMediaSignals inputFileLocationForImageUrl:url datacenterId:&datacenterId];
    
    if (location != nil)
    {
        SSignal *signal = [[TGSharedMediaSignals memoizedDataSignalForRemoteLocation:location datacenterId:datacenterId reportProgress:reportProgress] map:^id (id next)
        {
            if ([next isKindOfClass:[NSData class]])
            {
                NSData *data = next;
                [[NSFileManager defaultManager] createDirectoryAtPath:directory withIntermediateDirectories:true attributes:NULL error:NULL];
                
                NSString *key = [[NSString alloc] initWithFormat:@"image-%dx%d", (int)size.width, (int)size.height];
                NSString *path = [directory stringByAppendingPathComponent:key];
                [data writeToFile:path atomically:true];
                
                return [[TGSharedMediaImageData alloc] initWithData:data quality:quality preBlurred:false];
            }
            else
                return next;
        }];
        
        if (reportProgress)
            signal = [[SSignal single:@(0.0f)] then:signal];
        
        return signal;
    }
    else
        return [SSignal fail:nil];
}

+ (SSignal *)sharedPhotoImage:(TGImageMediaAttachment *)imageAttachment
                         size:(CGSize)size
                   threadPool:(SThreadPool *)threadPool memoryCache:(TGMemoryImageCache *)memoryCache
         pixelProcessingBlock:(void (^)(void *, int, int, int))pixelProcessingBlock
                     cacheKey:(NSString *)cacheKey
{
    CGSize imageSize = CGSizeZero;
    [imageAttachment.imageInfo imageUrlForLargestSize:&imageSize];
    CGSize renderSize = TGScaleToFill(imageSize, size);
    
    CGSize pixelSize = renderSize;
    if (TGIsRetina())
    {
        pixelSize.width *= 2.0f;
        pixelSize.height *= 2.0f;
    }
    
    CGSize thumbnailSize = CGSizeZero;
    NSString *thumbnailSizeUrl = [imageAttachment.imageInfo closestImageUrlWithSize:CGSizeZero resultingSize:&thumbnailSize];
    
    CGSize requiredSize = CGSizeZero;
    NSString *requiredSizeUrl = [imageAttachment.imageInfo imageUrlForSizeLargerThanSize:pixelSize actualSize:&requiredSize];
    
    return [TGSharedMediaSignals sharedMediaImageWithSize:size pixelProcessingBlock:pixelProcessingBlock cacheKey:cacheKey progressiveImageData:^SSignal *
    {
        NSString *directory = [self pathForPhotoDirectory:imageAttachment];
        
        SSignal *signal = [self cachedPhotoSizeData:directory size:size renderSize:renderSize];
        
        SSignal *localImageDataSignal = [[self localImageData:directory size:requiredSize quality:TGSharedMediaImageDataQualityNormal] catch:^SSignal *(__unused id error)
        {
            return [self localImageData:directory size:thumbnailSize quality:TGSharedMediaImageDataQualityLow];
        }];
        
        bool useProgress = true;
        
        SSignal *remoteThumbnailDataSignal = [(useProgress ? [SSignal single:@(0.0f)] : [SSignal complete]) then:[self remoteImageData:directory size:thumbnailSize quality:TGSharedMediaImageDataQualityLow url:thumbnailSizeUrl reportProgress:false]];
        SSignal *remoteRequiredDataSignal = [self remoteImageData:directory size:requiredSize quality:TGSharedMediaImageDataQualityNormal url:requiredSizeUrl reportProgress:useProgress];
        
        signal = [[signal catch:^SSignal *(__unused id error)
        {
            return [localImageDataSignal catch:^SSignal *(__unused id error)
            {
                return remoteThumbnailDataSignal;
            }];
        }] mapToQueue:^SSignal *(id next)
        {
            if ([next isKindOfClass:[TGSharedMediaImageData class]])
            {
                TGSharedMediaImageData *imageData = next;
                if (imageData.quality == TGSharedMediaImageDataQualityLow)
                    return [[SSignal single:imageData] then:remoteRequiredDataSignal];
                else
                    return [SSignal single:imageData];
            }
            else
                return [SSignal single:next];
        }];
        
        return signal;
    } cacheImageData:^(UIImage *image, TGSharedMediaImageDataQuality quality)
    {
        [[SQueue concurrentBackgroundQueue] dispatch:^
        {
            if (image.size.width * image.scale < requiredSize.width - 60.0f || image.size.height * image.scale < requiredSize.height - 60.0f)
            {
                NSString *directory = [self pathForPhotoDirectory:imageAttachment];
                NSString *path = [self cachedThumbnailPathForDirectory:directory size:size renderSize:renderSize quality:quality];
                if (![[NSFileManager defaultManager] fileExistsAtPath:path])
                {
                    NSData *data = UIImageJPEGRepresentation(image, 0.7f);
                    [data writeToFile:path atomically:true];
                }
            }
        }];
    } threadPool:threadPool memoryCache:memoryCache];
}

+ (SSignal *)squarePhotoThumbnail:(TGImageMediaAttachment *)imageAttachment ofSize:(CGSize)size threadPool:(SThreadPool *)threadPool memoryCache:(TGMemoryImageCache *)memoryCache pixelProcessingBlock:(void (^)(void *, int, int, int))pixelProcessingBlock downloadLargeImage:(bool)downloadLargeImage placeholder:(SSignal *)__unused placeholder
{
    CGSize imageSize = CGSizeZero;
    [imageAttachment.imageInfo imageUrlForLargestSize:&imageSize];
    CGSize renderSize = TGScaleToFill(imageSize, size);
    
    NSString *photoDirectoryPath = [self pathForPhotoDirectory:imageAttachment];
    NSString *cachedSizeLowPath = [photoDirectoryPath stringByAppendingPathComponent:[[NSString alloc] initWithFormat:@"thumbnail-%dx%d-%dx%d%@.jpg", (int)size.width, (int)size.height, (int)renderSize.width, (int)renderSize.height, @"-low"]];
    NSString *cachedSizePath = [photoDirectoryPath stringByAppendingPathComponent:[[NSString alloc] initWithFormat:@"thumbnail-%dx%d-%dx%d%@.jpg", (int)size.width, (int)size.height, (int)renderSize.width, (int)renderSize.height, @""]];
    
    NSString *genericThumbnailPath = [photoDirectoryPath stringByAppendingPathComponent:@"image-thumb.jpg"];
    
    NSString *highQualityUrl = nil;
    NSString *highQualityIdentifier = nil;
    
    if (downloadLargeImage)
    {
        CGSize pixelSize = renderSize;
        if (TGIsRetina())
        {
            pixelSize.width *= 2.0f;
            pixelSize.height *= 2.0f;
        }
        CGSize highQualitySize = CGSizeZero;
        highQualityUrl = [imageAttachment.imageInfo closestImageUrlWithSize:pixelSize resultingSize:&highQualitySize];
        highQualityIdentifier = [[NSString alloc] initWithFormat:@"%dx%d", (int)highQualitySize.width, (int)highQualitySize.height];
    }
    
    return [TGSharedMediaSignals squareThumbnail:cachedSizeLowPath cachedSizePath:cachedSizePath ofSize:size renderSize:renderSize pixelProcessingBlock:pixelProcessingBlock fullSizeImageSignalGenerator:^SSignal *
    {
        return [self localImageForFullSizeImage:imageAttachment];
    } lowQualityThumbnailSignalGenerator:^SSignal *
    {
        return [self localImageForLowQualityPhotoThumbnail:imageAttachment];
    } localCachedImageSignalGenerator:^SSignal *(CGSize size, CGSize renderSize, bool lowQuality)
    {
        return [self localCachedImageForPhotoThumbnail:imageAttachment ofSize:size renderSize:renderSize lowQuality:lowQuality];
    } lowQualityImagePath:genericThumbnailPath lowQualityImageUrl:[imageAttachment.imageInfo closestImageUrlWithSize:CGSizeZero resultingSize:NULL] highQualityImageUrl:highQualityUrl highQualityImageIdentifier:highQualityIdentifier threadPool:threadPool memoryCache:memoryCache placeholder:nil];
}

@end
