#import <SSignalKit/SSignalKit.h>

@class TGImageMediaAttachment;
@class TGMemoryImageCache;

@interface TGSharedPhotoSignals : NSObject

+ (SSignal *)sharedPhotoImage:(TGImageMediaAttachment *)imageAttachment
                         size:(CGSize)size
                   threadPool:(SThreadPool *)threadPool memoryCache:(TGMemoryImageCache *)memoryCache
         pixelProcessingBlock:(void (^)(void *, int, int, int))pixelProcessingBlock
                     cacheKey:(NSString *)cacheKey;

+ (SSignal *)squarePhotoThumbnail:(TGImageMediaAttachment *)imageAttachment ofSize:(CGSize)size threadPool:(SThreadPool *)threadPool memoryCache:(TGMemoryImageCache *)memoryCache pixelProcessingBlock:(void (^)(void *, int, int, int))pixelProcessingBlock downloadLargeImage:(bool)downloadLargeImage placeholder:(SSignal *)placeholder;

+ (NSString *)pathForPhotoDirectory:(TGImageMediaAttachment *)imageAttachment;

@end
