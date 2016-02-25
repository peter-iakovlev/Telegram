#import "AVURLAsset+TGMediaItem.h"
#import "TGMediaAssetImageSignals.h"

#import "TGPhotoEditorUtils.h"

@implementation AVURLAsset (TGMediaItem)

- (NSString *)uniqueIdentifier
{
    return self.URL.absoluteString;
}

- (CGSize)originalSize
{
    AVAssetTrack *track = self.tracks.firstObject;
    return CGRectApplyAffineTransform((CGRect){ CGPointZero, track.naturalSize }, track.preferredTransform).size;
}

- (SSignal *)thumbnailImageSignal
{
    CGFloat thumbnailImageSide = TGPhotoThumbnailSizeForCurrentScreen().width;
    CGSize size = TGScaleToSize(self.originalSize, CGSizeMake(thumbnailImageSide, thumbnailImageSide));
    
    return [TGMediaAssetImageSignals videoThumbnailForAVAsset:self size:size timestamp:kCMTimeZero];
}

- (SSignal *)screenImageSignal
{
    return nil;
}

- (SSignal *)originalImageSignal
{
    return nil;
}

@end
