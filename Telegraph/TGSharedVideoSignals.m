#import "TGSharedVideoSignals.h"

#import "TGSharedMediaSignals.h"

#import "TGVideoMediaAttachment.h"
#import "TGImageUtils.h"

#import "TGImageInfo+Telegraph.h"
#import "TGRemoteImageView.h"

#import <AVFoundation/AVFoundation.h>

#import "TGAppDelegate.h"

@implementation TGSharedVideoSignals

+ (NSString *)pathForVideoDirectory:(TGVideoMediaAttachment *)videoAttachment
{
    static NSString *filesDirectory = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^
    {
        filesDirectory = [[TGAppDelegate documentsPath] stringByAppendingPathComponent:@"files"];
    });

    NSString *videoDirectoryName = nil;
    if (videoAttachment.videoId != 0)
        videoDirectoryName = [[NSString alloc] initWithFormat:@"video-remote-%" PRIx64 "", videoAttachment.videoId];
    else
        videoDirectoryName = [[NSString alloc] initWithFormat:@"video-local-%" PRIx64 "", videoAttachment.localVideoId];
    return [filesDirectory stringByAppendingPathComponent:videoDirectoryName];
}

+ (UIImage *)_localCachedImageForVideoThumbnail:(TGVideoMediaAttachment *)videoAttachment ofSize:(CGSize)size renderSize:(CGSize)renderSize lowQuality:(bool)lowQuality
{
    NSString *videoDirectoryPath = [self pathForVideoDirectory:videoAttachment];
    NSString *cachedSizePath = [videoDirectoryPath stringByAppendingPathComponent:[[NSString alloc] initWithFormat:@"thumbnail-%dx%d-%dx%d%@.jpg", (int)size.width, (int)size.height, (int)renderSize.width, (int)renderSize.height, lowQuality ? @"-low" : @""]];
    UIImage *cachedSizeImage = [[UIImage alloc] initWithContentsOfFile:cachedSizePath];
    return cachedSizeImage;
}

+ (SSignal *)localCachedImageForVideoThumbnail:(TGVideoMediaAttachment *)imageAttachment ofSize:(CGSize)size renderSize:(CGSize)renderSize lowQuality:(bool)lowQuality
{
    return [[SSignal alloc] initWithGenerator:^id<SDisposable> (SSubscriber *subscriber)
    {
        UIImage *cachedSizeImage = [self _localCachedImageForVideoThumbnail:imageAttachment ofSize:size renderSize:renderSize lowQuality:lowQuality];
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

+ (SSignal *)localImageForLowQualityVideoThumbnail:(TGVideoMediaAttachment *)videoAttachment
{
    return [[SSignal alloc] initWithGenerator:^id<SDisposable> (SSubscriber *subscriber)
    {
        NSString *videoDirectoryPath = [self pathForVideoDirectory:videoAttachment];
        
        NSString *genericThumbnailPath = [videoDirectoryPath stringByAppendingPathComponent:@"video-thumb.jpg"];
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

+ (SSignal *)localImageForFullSizeVideo:(TGVideoMediaAttachment *)videoAttachment
{
    return [[SSignal alloc] initWithGenerator:^id<SDisposable> (SSubscriber *subscriber)
    {
        NSString *videoDirectoryPath = [self pathForVideoDirectory:videoAttachment];
        NSString *videoPath = [videoDirectoryPath stringByAppendingPathComponent:@"video.mov"];
        
        UIImage *fullImage = nil;
        
        if ([[NSFileManager defaultManager] fileExistsAtPath:videoPath isDirectory:NULL])
        {
            AVAsset *asset = [AVAsset assetWithURL:[NSURL fileURLWithPath:videoPath]];
            
            AVAssetImageGenerator *imageGenerator = [[AVAssetImageGenerator alloc] initWithAsset:asset];
            imageGenerator.maximumSize = CGSizeMake(800, 800);
            imageGenerator.appliesPreferredTrackTransform = true;
            NSError *imageError = nil;
            CGImageRef imageRef = [imageGenerator copyCGImageAtTime:CMTimeMake(0, asset.duration.timescale) actualTime:NULL error:&imageError];
            fullImage = [[UIImage alloc] initWithCGImage:imageRef];
            if (imageRef != NULL)
                CGImageRelease(imageRef);
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

+ (SSignal *)squareVideoThumbnail:(TGVideoMediaAttachment *)videoAttachment ofSize:(CGSize)size threadPool:(SThreadPool *)threadPool memoryCache:(TGMemoryImageCache *)memoryCache pixelProcessingBlock:(void (^)(void *, int, int, int))pixelProcessingBlock
{
    CGSize imageSize = videoAttachment.dimensions;
    CGSize renderSize = TGScaleToFill(imageSize, size);
    
    NSString *photoDirectoryPath = [self pathForVideoDirectory:videoAttachment];
    NSString *cachedSizeLowPath = [photoDirectoryPath stringByAppendingPathComponent:[[NSString alloc] initWithFormat:@"thumbnail-%dx%d-%dx%d%@.jpg", (int)size.width, (int)size.height, (int)renderSize.width, (int)renderSize.height, @"-low"]];
    NSString *cachedSizePath = [photoDirectoryPath stringByAppendingPathComponent:[[NSString alloc] initWithFormat:@"thumbnail-%dx%d-%dx%d%@.jpg", (int)size.width, (int)size.height, (int)renderSize.width, (int)renderSize.height, @""]];
    
    NSString *genericThumbnailPath = [photoDirectoryPath stringByAppendingPathComponent:@"video-thumb.jpg"];
    
    return [TGSharedMediaSignals squareThumbnail:cachedSizeLowPath cachedSizePath:cachedSizePath ofSize:size renderSize:renderSize pixelProcessingBlock:pixelProcessingBlock fullSizeImageSignalGenerator:^SSignal *
    {
        return [self localImageForFullSizeVideo:videoAttachment];
    } lowQualityThumbnailSignalGenerator:^SSignal *
    {
        return [self localImageForLowQualityVideoThumbnail:videoAttachment];
    } localCachedImageSignalGenerator:^SSignal *(CGSize size, CGSize renderSize, bool lowQuality)
    {
        return [self localCachedImageForVideoThumbnail:videoAttachment ofSize:size renderSize:renderSize lowQuality:lowQuality];
    } lowQualityImagePath:genericThumbnailPath lowQualityImageUrl:[videoAttachment.thumbnailInfo closestImageUrlWithSize:CGSizeZero resultingSize:NULL] highQualityImageUrl:nil highQualityImageIdentifier:nil threadPool:threadPool memoryCache:memoryCache placeholder:nil blurLowQuality:size.width > 40 || size.height > 40];
}

@end
