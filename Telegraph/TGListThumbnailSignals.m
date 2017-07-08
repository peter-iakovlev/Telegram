#import "TGListThumbnailSignals.h"

#import "TGImageUtils.h"
#import "TGImageBlur.h"

@implementation TGListThumbnailSignals

+ (UIImage *)listThumbnail:(CGSize)size image:(UIImage *)image blurImage:(bool)blurImage averageColor:(uint32_t *)averageColor pixelProcessingBlock:(void (^)(void *, int, int, int))pixelProcessingBlock
{
    CGSize pixelSize = size;
    pixelSize.width *= TGScreenScaling();
    pixelSize.height *= TGScreenScaling();
    
    CGSize renderSize = TGScaleToFill(image.size, pixelSize);
    
    UIImage *resultImage = nil;
    if (blurImage)
        resultImage = TGBlurredRectangularImage(image, pixelSize, renderSize, averageColor, pixelProcessingBlock);
    else
        resultImage = TGScaleAndCropImageToPixelSize(image, pixelSize, renderSize, averageColor, pixelProcessingBlock);
    return resultImage;
}

+ (SSignal *)signalForListThumbnail:(CGSize)size image:(UIImage *)image blurImage:(bool)blurImage pixelProcessingBlock:(void (^)(void *, int, int, int))pixelProcessingBlock calculateAverageColor:(bool)calculateAverageColor
{
    return [[SSignal alloc] initWithGenerator:^id<SDisposable> (SSubscriber *subscriber)
    {
        uint32_t averageColor = 0;
        UIImage *resultImage = [self listThumbnail:size image:image blurImage:blurImage averageColor:calculateAverageColor ? &averageColor : NULL pixelProcessingBlock:pixelProcessingBlock];
        if (resultImage != nil)
        {
            if (calculateAverageColor)
                [subscriber putNext:@(averageColor)];
            [subscriber putNext:resultImage];
        }
        [subscriber putCompletion];
        return nil;
    }];
}

@end
