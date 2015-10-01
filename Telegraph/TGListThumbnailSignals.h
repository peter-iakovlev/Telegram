#import <SSignalKit/SSignalKit.h>

@interface TGListThumbnailSignals : SSignal

+ (UIImage *)listThumbnail:(CGSize)size image:(UIImage *)image blurImage:(bool)blurImage averageColor:(uint32_t *)averageColor pixelProcessingBlock:(void (^)(void *, int, int, int))pixelProcessingBlock;
+ (SSignal *)signalForListThumbnail:(CGSize)size image:(UIImage *)image blurImage:(bool)blurImage pixelProcessingBlock:(void (^)(void *, int, int, int))pixelProcessingBlock calculateAverageColor:(bool)calculateAverageColor;

@end
