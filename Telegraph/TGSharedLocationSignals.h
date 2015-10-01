#import <SSignalKit/SSignalKit.h>

@class TGMemoryImageCache;
@class TGModernCache;

@interface TGSharedLocationSignals : NSObject

+ (SSignal *)squareLocationThumbnailForLatitude:(double)latitude longitude:(double)longitude ofSize:(CGSize)size threadPool:(SThreadPool *)threadPool memoryCache:(TGMemoryImageCache *)memoryCache persistentCache:(TGModernCache *)persistentCache pixelProcessingBlock:(void (^)(void *, int, int, int))pixelProcessingBlock;

@end
