#import <SSignalKit/SSignalKit.h>

@class TGImageMediaAttachment;
@class TGDocumentMediaAttachment;
@class TGMemoryImageCache;
@class TGModernCache;
@class TGImageInfo;

@interface TGSharedPhotoSignals : NSObject

+ (SSignal *)sharedPhotoImage:(TGImageMediaAttachment *)imageAttachment
                         size:(CGSize)size
                   threadPool:(SThreadPool *)threadPool memoryCache:(TGMemoryImageCache *)memoryCache
         pixelProcessingBlock:(void (^)(void *, int, int, int))pixelProcessingBlock
                     cacheKey:(NSString *)cacheKey;

+ (SSignal *)squarePhotoThumbnail:(TGImageMediaAttachment *)imageAttachment ofSize:(CGSize)size threadPool:(SThreadPool *)threadPool memoryCache:(TGMemoryImageCache *)memoryCache pixelProcessingBlock:(void (^)(void *, int, int, int))pixelProcessingBlock downloadLargeImage:(bool)downloadLargeImage placeholder:(SSignal *)placeholder;

+ (SSignal *)squarePhotoThumbnail:(TGImageMediaAttachment *)imageAttachment ofSize:(CGSize)size threadPool:(SThreadPool *)threadPool memoryCache:(TGMemoryImageCache *)memoryCache pixelProcessingBlock:(void (^)(void *, int, int, int))pixelProcessingBlock downloadLargeImage:(bool)downloadLargeImage inhibitBlur:(bool)inhibitBlur placeholder:(SSignal *)placeholder;

+ (SSignal *)cachedRemoteThumbnail:(TGImageInfo *)imageInfo size:(CGSize)size pixelProcessingBlock:(void (^)(void *, int, int, int))pixelProcessingBlock cacheVariantKey:(NSString *)cacheVariantKey threadPool:(SThreadPool *)threadPool memoryCache:(TGMemoryImageCache *)memoryCache diskCache:(TGModernCache *)diskCache;
+ (SSignal *)cachedRemoteDocumentThumbnail:(TGDocumentMediaAttachment *)document size:(CGSize)size pixelProcessingBlock:(void (^)(void *, int, int, int))pixelProcessingBlock cacheVariantKey:(NSString *)cacheVariantKey threadPool:(SThreadPool *)threadPool memoryCache:(TGMemoryImageCache *)memoryCache diskCache:(TGModernCache *)diskCache;
+ (SSignal *)cachedExternalThumbnail:(NSString *)url size:(CGSize)size pixelProcessingBlock:(void (^)(void *, int, int, int))pixelProcessingBlock cacheVariantKey:(NSString *)cacheVariantKey threadPool:(SThreadPool *)threadPool memoryCache:(TGMemoryImageCache *)memoryCache diskCache:(TGModernCache *)diskCache;

+ (NSString *)pathForPhotoDirectory:(TGImageMediaAttachment *)imageAttachment;

@end
