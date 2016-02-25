#import "TGMediaAsset+TGMediaEditableItem.h"
#import "TGMediaAssetImageSignals.h"

#import "TGImageUtils.h"
#import "TGPhotoEditorUtils.h"

@implementation TGMediaAsset (TGMediaEditableItem)

- (NSString *)uniqueIdentifier
{
    return self.identifier;
}

- (CGSize)originalSize
{
    if (![TGMediaAssetImageSignals usesPhotoFramework])
        return TGFitSize(self.dimensions, TGMediaAssetImageLegacySizeLimit);
    
    return self.dimensions;
}

- (SSignal *)thumbnailImageSignal
{
    CGFloat scale = MIN(2.0f, TGScreenScaling());
    CGFloat thumbnailImageSide = TGPhotoThumbnailSizeForCurrentScreen().width * scale;
    
    return [TGMediaAssetImageSignals imageForAsset:self imageType:TGMediaAssetImageTypeAspectRatioThumbnail size:CGSizeMake(thumbnailImageSide, thumbnailImageSide)];
}

- (SSignal *)screenImageSignal
{
    return [TGMediaAssetImageSignals imageForAsset:self imageType:TGMediaAssetImageTypeScreen size:TGPhotoEditorScreenImageMaxSize()];
}

- (SSignal *)originalImageSignal
{
    return [[TGMediaAssetImageSignals imageForAsset:self imageType:TGMediaAssetImageTypeFullSize size:CGSizeZero] takeLast];
}

@end
