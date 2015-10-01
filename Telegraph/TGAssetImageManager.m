#import "TGAssetImageManager.h"

#import <Photos/Photos.h>
#import <AssetsLibrary/AssetsLibrary.h>
#import <MobileCoreServices/MobileCoreServices.h>

#import "ATQueue.h"
#import "TGImageUtils.h"
#import "TGPhotoEditorUtils.h"

#import "TGMediaPickerAsset.h"

const CGSize TGAssetImageManagerLegacySizeLimit = { 2048, 2048 };

@implementation TGAssetThumbnailsRequestCancelToken

@end

@implementation TGAssetImageManager

+ (NSUInteger)requestImageWithAsset:(TGMediaPickerAsset *)asset imageType:(TGAssetImageType)imageType size:(CGSize)size completionBlock:(void (^)(UIImage *, NSError *))completionBlock
{
    return [self requestImageWithAsset:asset imageType:imageType size:size synchronous:false progressBlock:nil completionBlock:completionBlock];
}

+ (NSUInteger)requestImageWithAsset:(TGMediaPickerAsset *)asset imageType:(TGAssetImageType)imageType size:(CGSize)size synchronous:(bool)synchronous progressBlock:(void (^)(CGFloat))progressBlock completionBlock:(void (^)(UIImage *, NSError *))completionBlock
{
    if (completionBlock == nil)
        return 0;
    
    if (asset.backingAsset != nil)
    {
        PHImageRequestOptions *options = [TGAssetImageManager _optionsForAssetImageType:imageType];
        options.synchronous = synchronous;

        if (progressBlock != nil)
        {
            options.progressHandler = ^(double progress, __unused NSError *error, __unused BOOL *stop, __unused NSDictionary *info)
            {
                progressBlock((CGFloat)progress);
            };
        }
        
        if (imageType == TGAssetImageTypeFullSize)
            size = PHImageManagerMaximumSize;
    
        PHImageContentMode contentMode = PHImageContentModeAspectFill;
        if (imageType == TGAssetImageTypeScreen)
            contentMode = PHImageContentModeAspectFit;
    
        PHImageRequestID loadToken = 0;
        if (asset.representsBurst && (imageType == TGAssetImageTypeScreen || imageType == TGAssetImageTypeFullSize))
        {
            loadToken = [[self imageManager] requestImageDataForAsset:asset.backingAsset
                                                              options:options
                                                        resultHandler:^(NSData *imageData,
                                                                        __unused NSString *dataUTI,
                                                                        __unused UIImageOrientation orientation,
                                                                        __unused NSDictionary *info)
            {
                UIImage *image = [UIImage imageWithData:imageData];
                
                if (imageType == TGAssetImageTypeFullSize)
                {
                    completionBlock(image, nil);
                }
                else
                {
                    [[ATQueue concurrentDefaultQueue] dispatch:^
                    {
                        CGSize fittedSize = TGFitSize(image.size, size);
                        UIImage *fittedImage = TGScaleImageToPixelSize(image, fittedSize);
 
                        TGDispatchOnMainThread(^
                        {
                            completionBlock(fittedImage, nil);
                        });
                    }];
                }
            }];
        }
        else if (asset.isVideo && asset.subtypes & TGMediaPickerAssetSubtypeVideoHighFrameRate && imageType == TGAssetImageTypeScreen)
        {
            AVAsset *avAsset = [TGAssetImageManager avAssetForVideoAsset:asset];
            AVAssetImageGenerator *imageGenerator = [[AVAssetImageGenerator alloc] initWithAsset:avAsset];
            imageGenerator.maximumSize = size;
            [imageGenerator generateCGImagesAsynchronouslyForTimes:@[ [NSValue valueWithCMTime:CMTimeMake(0, NSEC_PER_SEC)] ] completionHandler:^(__unused CMTime requestedTime, CGImageRef cgImage, __unused CMTime actualTime, __unused AVAssetImageGeneratorResult result, NSError *error)
            {
                UIImage *image = [UIImage imageWithCGImage:cgImage scale:1.0f orientation:[self videoOrientationOfAVAsset:avAsset]];
                TGDispatchOnMainThread(^
                {
                    completionBlock(image, error);
                });
            }];
        }
        else
        {
            loadToken = [[self imageManager] requestImageForAsset:asset.backingAsset
                                                       targetSize:size
                                                      contentMode:contentMode
                                                          options:options
                                                    resultHandler:^(UIImage *result, __unused NSDictionary *info)
            {
                completionBlock(result, nil);
            }];
        }
        
        return loadToken;
    }
    else if (asset.backingLegacyAsset != nil)
    {
        switch (imageType)
        {
            case TGAssetImageTypeThumbnail:
            {
                completionBlock([UIImage imageWithCGImage:asset.backingLegacyAsset.thumbnail], nil);
            }
                break;

            case TGAssetImageTypeAspectRatioThumbnail:
            {
                completionBlock([UIImage imageWithCGImage:asset.backingLegacyAsset.aspectRatioThumbnail], nil);
            }
                break;
                
            case TGAssetImageTypeScreen:
            case TGAssetImageTypeFullSize:
            {
                if (imageType == TGAssetImageTypeScreen && asset.isVideo)
                {
                    completionBlock([UIImage imageWithCGImage:asset.backingLegacyAsset.defaultRepresentation.fullScreenImage], nil);
                    return 0;
                }
                
                if (imageType == TGAssetImageTypeFullSize)
                    size = TGAssetImageManagerLegacySizeLimit;
                
                void (^requestBlock)(void) = ^
                {
                    ALAssetRepresentation *representation = asset.backingLegacyAsset.defaultRepresentation;
                    CGDataProviderDirectCallbacks callbacks =
                    {
                        .version = 0,
                        .getBytePointer = NULL,
                        .releaseBytePointer = NULL,
                        .getBytesAtPosition = TGGetAssetBytesCallback,
                        .releaseInfo = TGReleaseAssetCallback,
                    };
                    
                    CGDataProviderRef provider = CGDataProviderCreateDirect((void *)CFBridgingRetain(representation), representation.size, &callbacks);
                    CGImageSourceRef source = CGImageSourceCreateWithDataProvider(provider, NULL);
                    
                    CGImageRef imageRef = CGImageSourceCreateThumbnailAtIndex(source, 0, (__bridge CFDictionaryRef)
                    @{
                      (NSString *)kCGImageSourceCreateThumbnailFromImageAlways : @YES,
                      (NSString *)kCGImageSourceThumbnailMaxPixelSize : @((NSInteger)MAX(size.width, size.height)),
                      (NSString *)kCGImageSourceCreateThumbnailWithTransform : @YES
                    });
                    
                    CFRelease(source);
                    CFRelease(provider);
                    
                    UIImage *result = nil;
                    if (imageRef != nil)
                    {
                        result = [self _editedImageWithCGImage:imageRef representation:representation];
                        CFRelease(imageRef);
                    }
                    
                    completionBlock(result, nil);
                };
                
                if (synchronous)
                    requestBlock();
                else
                    [[self queue] dispatch:requestBlock];
            }
                break;
                
            default:
                break;
        }
    }
    else
    {
        completionBlock(nil, nil);
    }
    
    return 0;
}

+ (void)requestImageMetadataWithAsset:(TGMediaPickerAsset *)asset completionBlock:(void (^)(NSDictionary *, NSError *))completionBlock
{
    return;
    if (completionBlock == nil)
        return;
    
    if (asset.backingAsset != nil)
    {
        [asset.backingAsset requestContentEditingInputWithOptions:[[PHContentEditingInputRequestOptions alloc] init] completionHandler:^(PHContentEditingInput *contentEditingInput, __unused NSDictionary *info)
        {
            [[ATQueue concurrentDefaultQueue] dispatch:^
            {
                CIImage *image = [CIImage imageWithContentsOfURL:contentEditingInput.fullSizeImageURL];
                completionBlock(image.properties, nil);
            }];
        }];
    }
    else if (asset.backingLegacyAsset != nil)
    {
        ALAssetRepresentation *defaultRepresentation = asset.backingLegacyAsset.defaultRepresentation;
        completionBlock(defaultRepresentation.metadata, nil);
    }
}

+ (NSUInteger)requestFileAttributesForAsset:(TGMediaPickerAsset *)asset completion:(void (^)(NSString *, NSString *, CGSize, NSUInteger))completion
{
    if (completion == nil)
        return 0;
    
    __block PHImageRequestID loadToken = 0;
    if (asset.backingAsset != nil)
    {
        if (!asset.isVideo)
        {
            loadToken = [[PHImageManager defaultManager] requestImageDataForAsset:asset.backingAsset options:nil resultHandler:^(NSData *data,
                                                                                                                                 NSString *dataUTI,
                                                                                                                                 __unused UIImageOrientation orientation,
                                                                                                                                 NSDictionary *info)
            {
                NSURL *fileUrl = info[@"PHImageFileURLKey"];
                NSString *fileName = fileUrl.absoluteString.lastPathComponent;
                
                completion(fileName, dataUTI, asset.dimensions, data.length);
            }];
        }
        else
        {
            AVAsset *avAsset = [self avAssetForVideoAsset:asset];
            
            if ([avAsset isKindOfClass:[AVURLAsset class]])
            {
                NSNumber *size;
                NSURL *assetUrl = ((AVURLAsset *)avAsset).URL;
                [assetUrl getResourceValue:&size forKey:NSURLFileSizeKey error:nil];
                NSString *fileName = assetUrl.absoluteString.lastPathComponent;

                completion(fileName, nil, asset.dimensions, size.unsignedIntegerValue);
            }
            else
            {
                loadToken = [[PHImageManager defaultManager] requestImageDataForAsset:asset.backingAsset options:nil resultHandler:^(NSData *data,
                                                                                                                         __unused NSString *dataUTI,
                                                                                                                         __unused UIImageOrientation orientation,
                                                                                                                         NSDictionary *info)
                {
                    NSURL *fileUrl = info[@"PHImageFileURLKey"];
                    NSString *fileName = fileUrl.absoluteString.lastPathComponent;
                    
                    completion(fileName, dataUTI, asset.dimensions, data.length);
                }];
            }
        }
    }
    else if (asset.backingLegacyAsset != nil)
    {
        ALAssetRepresentation *representation = asset.backingLegacyAsset.defaultRepresentation;
        NSArray *fileNameComponents = [representation.url.absoluteString.lastPathComponent componentsSeparatedByString:@"?"];
        NSString *fileName = fileNameComponents.firstObject;

        completion(fileName, representation.UTI, representation.dimensions, (NSUInteger)representation.size);
    }
    
    return 0;
}

+ (NSUInteger)requestImageDataWithAsset:(TGMediaPickerAsset *)asset
                        completionBlock:(void (^)(NSData *data, NSString *fileName, NSString *dataUTI, NSError *error))completionBlock
{
    return [self requestImageDataWithAsset:asset synchronous:false completionBlock:completionBlock];
}

+ (NSUInteger)requestImageDataWithAsset:(TGMediaPickerAsset *)asset synchronous:(bool)synchronous
                        completionBlock:(void (^)(NSData *data, NSString *fileName, NSString *dataUTI, NSError *error))completionBlock
{
    if (completionBlock == nil)
        return 0;
    
    if (asset.backingAsset != nil)
    {
        PHImageRequestOptions *options = [TGAssetImageManager _optionsForAssetImageType:TGAssetImageTypeFullSize];
        options.synchronous = synchronous;
        PHImageRequestID loadToken;
        
        loadToken = [[self imageManager] requestImageDataForAsset:asset.backingAsset
                                                          options:options
                                                    resultHandler:^(NSData *imageData,
                                                                    NSString *dataUTI,
                                                                    __unused UIImageOrientation orientation,
                                                                    NSDictionary *info)
        {
            NSURL *fileUrl = info[@"PHImageFileURLKey"];
            NSString *fileName = fileUrl.absoluteString.lastPathComponent;
            NSString *fileExtension = fileName.pathExtension;
            if ([fileName isEqualToString:[NSString stringWithFormat:@"FullSizeRender.%@", fileExtension]])
            {
                NSArray *components = [fileUrl.absoluteString componentsSeparatedByString:@"/"];
                for (NSString *component in components)
                {
                    if ([component hasPrefix:@"IMG_"])
                    {
                        fileName = [NSString stringWithFormat:@"%@.%@", component, fileExtension];
                        break;
                    }
                }
            }
            
            completionBlock(imageData, fileName, dataUTI, nil);
        }];
        
        return loadToken;
    }
    else if (asset.backingLegacyAsset != nil)
    {
        ALAssetRepresentation *representation = asset.backingLegacyAsset.defaultRepresentation;
        NSUInteger size = (NSUInteger)representation.size;
        void *bytes = malloc(size);
        for (NSUInteger offset = 0; offset < size; )
        {
            NSError *error = nil;
            offset += [representation getBytes:bytes + offset fromOffset:(long long)offset length:256 * 1024 error:&error];
            if (error != nil)
            {
                completionBlock(nil, nil, nil, error);
                return 0;
            }
        }
        
        NSData *data = [[NSData alloc] initWithBytesNoCopy:bytes length:size freeWhenDone:true];
        NSArray *fileNameComponents = [representation.url.absoluteString.lastPathComponent componentsSeparatedByString:@"?"];
        NSString *fileName = fileNameComponents.firstObject;
        
        completionBlock(data, fileName, representation.UTI, nil);
    }
    
    return 0;
}

static size_t TGGetAssetBytesCallback(void *info, void *buffer, off_t position, size_t count)
{
    ALAssetRepresentation *rep = (__bridge id)info;
    
    NSError *error = nil;
    size_t countRead = [rep getBytes:(uint8_t *)buffer fromOffset:position length:count error:&error];
    
    if (countRead == 0 && error)
        TGLog(@"error occured while reading an asset: %@", error);
    
    return countRead;
}

static void TGReleaseAssetCallback(void *info)
{
    CFRelease(info);
}

+ (void)cancelRequestWithToken:(NSUInteger)token
{
    if (iosMajorVersion() < 8)
        return;
    
    [[self imageManager] cancelImageRequest:(int32_t)token];
}

+ (void)startCachingImagesForAssets:(NSArray *)assets size:(CGSize)size imageType:(TGAssetImageType)imageType
{
    if (iosMajorVersion() < 8)
        return;
    
    PHImageRequestOptions *options = [TGAssetImageManager _optionsForAssetImageType:imageType];
    
    NSMutableArray *backingAssets = [NSMutableArray array];
    for (TGMediaPickerAsset *asset in assets)
    {
        if (asset.backingAsset != nil)
            [backingAssets addObject:asset.backingAsset];
    }
    
    [[self imageManager] startCachingImagesForAssets:backingAssets
                                          targetSize:size
                                         contentMode:PHImageContentModeAspectFill
                                             options:options];
}

+ (void)stopCachingImagesForAssets:(NSArray *)assets size:(CGSize)size imageType:(TGAssetImageType)imageType
{
    if (iosMajorVersion() < 8)
        return;
    
    PHImageRequestOptions *options = [TGAssetImageManager _optionsForAssetImageType:imageType];
    
    NSMutableArray *backingAssets = [NSMutableArray array];
    for (TGMediaPickerAsset *asset in assets)
    {
        if (asset.backingAsset != nil)
            [backingAssets addObject:asset.backingAsset];
    }

    [[self imageManager] stopCachingImagesForAssets:backingAssets
                                         targetSize:size
                                        contentMode:PHImageContentModeAspectFill
                                            options:options];
}

+ (void)stopCachingImagesForAllAssets
{
    if (iosMajorVersion() < 8)
        return;
    
    [[self imageManager] stopCachingImagesForAllAssets];
}

+ (PHImageRequestOptions *)_optionsForAssetImageType:(TGAssetImageType)imageType
{
    PHImageRequestOptions *options = [PHImageRequestOptions new];

    switch (imageType)
    {            
        case TGAssetImageTypeAspectRatioThumbnail:
        {
            options.deliveryMode = PHImageRequestOptionsDeliveryModeHighQualityFormat;
        }
            break;
            
        case TGAssetImageTypeScreen:
        {
            options.deliveryMode = PHImageRequestOptionsDeliveryModeHighQualityFormat;
            options.resizeMode = PHImageRequestOptionsResizeModeExact;
        }
            break;
            
        case TGAssetImageTypeFullSize:
        {
            options.deliveryMode = PHImageRequestOptionsDeliveryModeHighQualityFormat;
            options.resizeMode = PHImageRequestOptionsResizeModeNone;
        }
            break;
            
        default:
            break;
    }
    
    return options;
}

+ (PHCachingImageManager *)imageManager
{
    static dispatch_once_t onceToken;
    static PHCachingImageManager *imageManager;
    dispatch_once(&onceToken, ^
    {
        imageManager = [[PHCachingImageManager alloc] init];
    });
    return imageManager;
}

+ (ATQueue *)queue
{
    static dispatch_once_t onceToken;
    static ATQueue *queue;
    dispatch_once(&onceToken, ^
    {
        queue = [[ATQueue alloc] init];
    });
    return queue;
}

+ (AVPlayerItem *)playerItemForVideoAsset:(TGMediaPickerAsset *)asset
{
    if (asset.backingAsset != nil)
    {
        __block NSConditionLock *syncLock = [[NSConditionLock alloc] initWithCondition:1];
        __block AVPlayerItem *avPlayerItem;
        
        [[self imageManager] requestPlayerItemForVideo:asset.backingAsset
                                               options:nil
                                         resultHandler:^(AVPlayerItem *playerItem, __unused NSDictionary *info)
        {
            avPlayerItem = playerItem;
            
            [syncLock lock];
            [syncLock unlockWithCondition:0];
        }];
        
        [syncLock lockWhenCondition:0];
        [syncLock unlock];
        
        return avPlayerItem;
    }
    else if (asset.backingLegacyAsset != nil)
    {
        AVPlayerItem *item = [AVPlayerItem playerItemWithURL:asset.url];
        return item;
    }
    
    return nil;
}

+ (AVAsset *)avAssetForVideoAsset:(TGMediaPickerAsset *)asset
{
    if (!asset.isVideo)
        return nil;
    
    if (asset.backingAsset != nil)
    {
        __block NSConditionLock *syncLock = [[NSConditionLock alloc] initWithCondition:1];
        __block AVAsset *avAsset;
        
        [[self imageManager] requestAVAssetForVideo:asset.backingAsset
                                            options:nil
                                      resultHandler:^(AVAsset *asset, __unused AVAudioMix *audioMix, __unused NSDictionary *info)
        {
            avAsset = asset;
            
            [syncLock lock];
            [syncLock unlockWithCondition:0];
        }];
        
        [syncLock lockWhenCondition:0];
        [syncLock unlock];
        
        return avAsset;
    }
    else if (asset.backingLegacyAsset != nil)
    {
        return [[AVURLAsset alloc] initWithURL:asset.url options:nil];
    }
    
    return nil;
}

+ (bool)copyOriginalFileForAsset:(TGMediaPickerAsset *)asset toPath:(NSString *)path completion:(void (^)(NSString *fileName))completion
{
    AVAsset *avAsset = nil;
    if (asset.isVideo)
        avAsset = [self avAssetForVideoAsset:asset];
    else
        return false;
    
    if (![avAsset isKindOfClass:[AVURLAsset class]])
        return false;
    
    if (iosMajorVersion() >= 8)
    {
        NSURL *assetUrl = ((AVURLAsset *)avAsset).URL;
        NSString *fileName = assetUrl.lastPathComponent;

        if (completion != nil)
            completion(fileName);
        
        return [[NSFileManager defaultManager] copyItemAtPath:assetUrl.path toPath:path error:NULL];
    }
    else
    {
        NSOutputStream *os = [[NSOutputStream alloc] initToFileAtPath:path append:false];
        [os open];
        
        ALAssetRepresentation *representation = asset.backingLegacyAsset.defaultRepresentation;
        long long size = representation.size;
        
        uint8_t buf[128 * 1024];
        for (long long offset = 0; offset < size; offset += 128 * 1024)
        {
            long long batchSize = MIN(128 * 1024, size - offset);
            NSUInteger readBytes = [representation getBytes:buf fromOffset:offset length:(NSUInteger)batchSize error:nil];
            [os write:buf maxLength:readBytes];
        }
        
        [os close];

        NSArray *fileNameComponents = [representation.url.absoluteString.lastPathComponent componentsSeparatedByString:@"?"];
        NSString *fileName = fileNameComponents.firstObject;
        
        if (completion != nil)
            completion(fileName);
        
        return true;
    }
}

+ (UIImageOrientation)videoOrientationOfAVAsset:(AVAsset *)avAsset
{
    NSArray *videoTracks = [avAsset tracksWithMediaType:AVMediaTypeVideo];
    if ([videoTracks count] == 0)
        return UIImageOrientationUp;
    
    AVAssetTrack* videoTrack = videoTracks.firstObject;
    CGAffineTransform transform = videoTrack.preferredTransform;
    CGFloat angle = TGRadiansToDegrees((CGFloat)atan2(transform.b, transform.a));
    
    UIImageOrientation orientation = 0;
    switch ((NSInteger)angle)
    {
        case 0:
            orientation = UIImageOrientationUp;
            break;
        case 90:
            orientation = UIImageOrientationRight;
            break;
        case 180:
            orientation = UIImageOrientationDown;
            break;
        case -90:
            orientation	= UIImageOrientationLeft;
            break;
        default:
            orientation = UIImageOrientationUp;
            break;
    }
    
    return orientation;
}

+ (TGAssetThumbnailsRequestCancelToken *)requestVideoThumbnailsForAsset:(TGMediaPickerAsset *)asset size:(CGSize)size timestamps:(NSArray *)timestamps completion:(void (^)(NSArray *, bool))completion
{
    return [self requestVideoThumbnailsForAVAsset:[self avAssetForVideoAsset:asset] size:size timestamps:timestamps completion:completion];
}

+ (TGAssetThumbnailsRequestCancelToken *)requestVideoThumbnailsForItemAtURL:(NSURL *)url size:(CGSize)size timestamps:(NSArray *)timestamps completion:(void (^)(NSArray *images, bool cancelled))completion
{
    return [self requestVideoThumbnailsForAVAsset:[AVAsset assetWithURL:url] size:size timestamps:timestamps completion:completion];
}

+ (TGAssetThumbnailsRequestCancelToken *)requestVideoThumbnailsForAVAsset:(AVAsset *)asset size:(CGSize)size timestamps:(NSArray *)timestamps completion:(void (^)(NSArray *, bool))completion
{
    if (completion == nil)
        return nil;
    
    AVAssetImageGenerator *generator = [AVAssetImageGenerator assetImageGeneratorWithAsset:asset];
    generator.appliesPreferredTrackTransform = true;
    generator.maximumSize = size;
    
    TGAssetThumbnailsRequestCancelToken *cancelToken = [[TGAssetThumbnailsRequestCancelToken alloc] init];
    
    [[ATQueue concurrentDefaultQueue] dispatch:^
    {
        NSMutableArray *images = [[NSMutableArray alloc] init];
        for (NSValue *timeValue in timestamps)
        {
            if (cancelToken.cancelled)
                break;
            
            NSError *error;
            CGImageRef imageRef = [generator copyCGImageAtTime:[timeValue CMTimeValue] actualTime:nil error:&error];
            
            if (error != nil)
                continue;
            
            UIImage *image = [UIImage imageWithCGImage:imageRef];
            if (image != nil)
                [images addObject:image];
        }
        
        completion(images, cancelToken.cancelled);
    }];
    
    return cancelToken;
}

+ (UIImage *)_editedImageWithCGImage:(CGImageRef)cgImage representation:(ALAssetRepresentation *)representation
{
    NSError *error = nil;
    CGSize originalImageSize = CGSizeMake([representation.metadata[@"PixelWidth"] floatValue],
                                          [representation.metadata[@"PixelHeight"] floatValue]);
    
    NSData *xmpData = [representation.metadata[@"AdjustmentXMP"] dataUsingEncoding:NSUTF8StringEncoding];

    CIContext *context = [CIContext contextWithOptions:nil];
    
    CIImage *img = [CIImage imageWithCGImage:cgImage];
    NSArray *filterArray = [CIFilter filterArrayFromSerializedXMP:xmpData
                                                 inputImageExtent:img.extent
                                                            error:&error];
    
    if ((originalImageSize.width != CGImageGetWidth(cgImage)) || (originalImageSize.height != CGImageGetHeight(cgImage)))
    {
        CGFloat zoom = MIN(originalImageSize.width / CGImageGetWidth(cgImage),
                           originalImageSize.height / CGImageGetHeight(cgImage));
        
        bool hasTranslation = false;
        bool hasCrop = false;
        
        for (CIFilter *filter in filterArray)
        {
            if ([filter.name isEqualToString:@"CIAffineTransform"] && !hasTranslation)
            {
                hasTranslation = true;
                CGAffineTransform t = [[filter valueForKey:@"inputTransform"] CGAffineTransformValue];
                t.tx /= zoom;
                t.ty /= zoom;
                [filter setValue:[NSValue valueWithCGAffineTransform:t] forKey:@"inputTransform"];
            }

            if ([filter.name isEqualToString:@"CICrop"] && !hasCrop)
            {
                hasCrop = true;
                CGRect r = [[filter valueForKey:@"inputRectangle"] CGRectValue];
                r.origin.x /= zoom;
                r.origin.y /= zoom;
                r.size.width /= zoom;
                r.size.height /= zoom;
                [filter setValue:[NSValue valueWithCGRect:r] forKey:@"inputRectangle"];
            }
        }
    }
    
    for (CIFilter *filter in filterArray)
    {
        [filter setValue:img forKey:kCIInputImageKey];
        img = [filter outputImage];
    }
    
    CGImageRef editedImage = [context createCGImage:img fromRect:img.extent];
    UIImage *resultImage = [UIImage imageWithCGImage:editedImage];
    
    CGImageRelease(editedImage);
    
    return resultImage;
}

+ (bool)usesLegacyAssetsLibrary
{
    return iosMajorVersion() < 8;
}

@end
