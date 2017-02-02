#import "TGMediaSignals.h"

#import "TGTelegramNetworking.h"
#import "TGRemoteImageView.h"
#import "TGRemoteFileSignal.h"
#import "TGImageInfo+Telegraph.h"
#import "TGImageManager.h"
#import "TGStringUtils.h"
#import "TGImageMediaAttachment.h"
#import "TGVideoMediaAttachment.h"

#import "TGSharedPhotoSignals.h"
#import "TGSharedVideoSignals.h"
#import "TGImageInfo+Telegraph.h"

#import "TGSharedMediaUtils.h"
#import "TGRemoteFileSignal.h"

#import "TGImageBlur.h"
#import "TGImageUtils.h"

@implementation TGMediaSignals

+ (SSignal *)avatarPathWithReference:(TGImageFileReference *)reference
{
    TLInputFileLocation$inputFileLocation *inputFileLocation = [[TLInputFileLocation$inputFileLocation alloc] init];
    inputFileLocation.volume_id = reference.volumeId;
    inputFileLocation.local_id = reference.localId;
    inputFileLocation.secret = reference.secret;
    SSignal *remoteSignal = [TGRemoteFileSignal dataForLocation:inputFileLocation datacenterId:(NSUInteger)reference.datacenterId size:0 reportProgress:false mediaTypeTag:TGNetworkMediaTypeTagImage];
    
    TLFileLocation$fileLocation *fileLocation = [[TLFileLocation$fileLocation alloc] init];
    fileLocation.dc_id = reference.datacenterId;
    fileLocation.volume_id = reference.volumeId;
    fileLocation.local_id = reference.localId;
    fileLocation.secret = reference.secret;
    
    NSString *cacheKey = extractFileUrl(fileLocation);
    
    NSString *pathForCachedData = [[TGRemoteImageView sharedCache] pathForCachedData:cacheKey];
    SSignal *cachedSignal = [[SSignal alloc] initWithGenerator:^id<SDisposable>(SSubscriber *subscriber)
    {
        if (pathForCachedData == nil || ![[TGRemoteImageView sharedCache] diskCacheContainsSync:cacheKey])
        {
            [subscriber putError:nil];
        }
        else
        {
            [subscriber putNext:pathForCachedData];
            [subscriber putCompletion];
        }
        return nil;
    }];
    
    return [cachedSignal catch:^SSignal *(__unused id error)
    {
        return [remoteSignal mapToSignal:^SSignal *(NSData *data)
        {
            return [[SSignal alloc] initWithGenerator:^id<SDisposable>(SSubscriber *subscriber)
            {
                [[TGRemoteImageView sharedCache] cacheImage:nil withData:data url:cacheKey availability:TGCacheDisk completion:^
                {
                    [subscriber putNext:pathForCachedData];
                    [subscriber putCompletion];
                }];
                return nil;
            }];
        }];
    }];
}

+ (SSignal *)stickerPathWithDocumentId:(int64_t)documentId accessHash:(int64_t)accessHash legacyThumbnailUri:(NSString *)legacyThumbnailUri datacenterId:(int32_t)datacenterId size:(CGSize)size
{
    return [[SSignal alloc] initWithGenerator:^id<SDisposable>(SSubscriber *subscriber)
    {
        NSMutableString *uri = [[NSMutableString alloc] initWithString:@"sticker-preview://?"];
        if (documentId != 0)
            [uri appendFormat:@"documentId=%" PRId64 "", documentId];
        [uri appendFormat:@"&accessHash=%" PRId64 "", accessHash];
        [uri appendFormat:@"&datacenterId=%" PRId32 "", datacenterId];
        
        if (legacyThumbnailUri != nil)
        {
            [uri appendFormat:@"&legacyThumbnailUri=%@", [TGStringUtils stringByEscapingForURL:legacyThumbnailUri]];
        }
        
        [uri appendFormat:@"&width=%d&height=%d", (int)size.width, (int)size.height];
        [uri appendFormat:@"&highQuality=1"];
        
        id asyncTaskId = [[TGImageManager instance] beginLoadingImageAsyncWithUri:uri decode:true progress:nil partialCompletion:nil completion:^(UIImage *image)
        {
            if (image != nil)
            {
                CGSize targetSize = TGFitSize(image.size, size);
                UIImage *resizedImage = TGScaleAndRoundCorners(image, targetSize, targetSize, 0, nil, false, nil);
                [subscriber putNext:resizedImage];
                [subscriber putCompletion];
            }
            else
            {
                [subscriber putError:nil];
            }
        }];
        
        return [[SBlockDisposable alloc] initWithBlock:^
        {
            [[TGImageManager instance] cancelTaskWithId:asyncTaskId];
        }];
    }];
}

+ (TGImageFileReference *)imageFileReferenceForLegacyUrl:(NSString *)legacyUrl
{
    int datacenterId = 0;
    int64_t volumeId = 0;
    int localId = 0;
    int64_t secret = 0;
    if (extractFileUrlComponents(legacyUrl, &datacenterId, &volumeId, &localId, &secret))
    {
        return [[TGImageFileReference alloc] initWithDatacenterId:datacenterId volumeId:volumeId localId:localId secret:secret];
    }
    else
        return nil;
}

+ (SSignal *)thumbnailPathWithDirectory:(NSString *)directory blur:(bool)blur targetSize:(CGSize)targetSize fileName:(NSString *)fileName imageFileReference:(TGImageFileReference *)imageFileReference
{
    NSString *filePath = [directory stringByAppendingPathComponent:fileName];
    return [[[SSignal alloc] initWithGenerator:^id<SDisposable>(SSubscriber *subscriber)
    {
        if ([[NSFileManager defaultManager] fileExistsAtPath:filePath])
        {
            [subscriber putNext:filePath];
            [subscriber putCompletion];
        }
        else
            [subscriber putError:nil];
        return nil;
    }] catch:^SSignal *(__unused id error)
    {
        TLInputFileLocation$inputFileLocation *inputLocation = [[TLInputFileLocation$inputFileLocation alloc] init];
        inputLocation.volume_id = imageFileReference.volumeId;
        inputLocation.local_id = imageFileReference.localId;
        inputLocation.secret = imageFileReference.secret;
        return [[TGRemoteFileSignal dataForLocation:inputLocation datacenterId:imageFileReference.datacenterId size:0 reportProgress:false mediaTypeTag:TGNetworkMediaTypeTagImage] map:^id(NSData *data)
        {
            [[NSFileManager defaultManager] createDirectoryAtPath:directory withIntermediateDirectories:true attributes:nil error:nil];
            UIImage *image = [[UIImage alloc] initWithData:data];
            CGSize renderSize = TGScaleToFill(image.size, targetSize);
            if (blur)
            {
                image = TGBlurredRectangularImage(image, renderSize, renderSize, NULL, NULL);
                NSData *blurredData = UIImageJPEGRepresentation(image, 0.4f);
                [blurredData writeToFile:filePath atomically:true];
            }
            else
            {
                image = TGScaleImage(image, renderSize);
                NSData *imageData = UIImageJPEGRepresentation(image, 0.4f);
                [imageData writeToFile:filePath atomically:true];
            }
            
            return filePath;
        }];
    }];
}

+ (SSignal *)photoThumbnailPathWithImageMedia:(TGImageMediaAttachment *)imageMedia targetSize:(CGSize)targetSize
{
    return [[SSignal single:nil] mapToSignal:^SSignal *(__unused id next)
    {
        CGSize thumbnailSize = CGSizeZero;
        NSString *imageUrl = [imageMedia.imageInfo closestImageUrlWithSize:CGSizeMake(320.0f, 320.0f) resultingSize:&thumbnailSize];
        TGImageFileReference *imageReference = [self imageFileReferenceForLegacyUrl:imageUrl];
        if (imageReference != nil)
        {
            NSString *directory = [TGSharedPhotoSignals pathForPhotoDirectory:imageMedia];
            NSString *fileName = [[NSString alloc] initWithFormat:@"thumbnail-%dx%d-%dx%d%@.jpg", (int)thumbnailSize.width, (int)thumbnailSize.height, (int)thumbnailSize.width, (int)thumbnailSize.height, @""];
            return [self thumbnailPathWithDirectory:directory blur:false targetSize:targetSize fileName:fileName imageFileReference:imageReference];
        }
        else
            return [SSignal fail:nil];
    }];
}

+ (SSignal *)videoThumbnailPathWithVideoMedia:(TGVideoMediaAttachment *)videoMedia targetSize:(CGSize)targetSize
{
    return [[SSignal single:nil] mapToSignal:^SSignal *(__unused id next)
    {
        CGSize thumbnailSize = CGSizeZero;
        NSString *imageUrl = [videoMedia.thumbnailInfo closestImageUrlWithSize:CGSizeMake(320.0f, 320.0f) resultingSize:&thumbnailSize];
        TGImageFileReference *imageReference = [self imageFileReferenceForLegacyUrl:imageUrl];
        if (imageReference != nil)
        {
            NSString *directory = [TGSharedVideoSignals pathForVideoDirectory:videoMedia];
            NSString *fileName = [[NSString alloc] initWithFormat:@"thumbnail-%@-%dx%d%@.jpg", imageUrl, (int)thumbnailSize.width, (int)thumbnailSize.height, @"low"];
            return [self thumbnailPathWithDirectory:directory blur:(thumbnailSize.width < 100.0f && thumbnailSize.height < 100.0f) targetSize:targetSize fileName:fileName imageFileReference:imageReference];
        }
        else
            return [SSignal fail:nil];
    }];
}

@end
