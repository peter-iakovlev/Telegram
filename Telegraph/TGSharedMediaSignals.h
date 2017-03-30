#import <SSignalKit/SSignalKit.h>

#import "TGTelegramNetworking.h"

@class TLInputFileLocation;
@class TGMemoryImageCache;
@class TGModernCache;
@class TLInputWebFileLocation;

typedef enum {
    TGSharedMediaImageDataQualityLow,
    TGSharedMediaImageDataQualityNormal
} TGSharedMediaImageDataQuality;

@interface TGSharedMediaImageData : NSObject

@property (nonatomic, strong, readonly) NSData *data;
@property (nonatomic, readonly) TGSharedMediaImageDataQuality quality;
@property (nonatomic, readonly) bool preBlurred;

- (instancetype)initWithData:(NSData *)data quality:(TGSharedMediaImageDataQuality)quality preBlurred:(bool)preBlurred;

@end

@interface TGSharedMediaImageProgress : NSObject

@property (nonatomic, readonly) bool hasProgress;
@property (nonatomic, readonly) CGFloat value;

- (instancetype)initWithHasProgress:(bool)hasProgress value:(CGFloat)value;

@end

@interface TGSharedMediaSignals : NSObject

+ (TLInputFileLocation *)inputFileLocationForImageUrl:(NSString *)imageUrl datacenterId:(NSInteger *)outDatacenterId;
+ (TLInputWebFileLocation *)inputWebFileLocationForImageUrl:(NSString *)imageUrl datacenterId:(NSInteger *)outDatacenterId;
+ (SSignal *)memoizedDataSignalForRemoteLocation:(TLInputFileLocation *)location datacenterId:(NSInteger)datacenterId reportProgress:(bool)reportProgress mediaTypeTag:(TGNetworkMediaTypeTag)mediaTypeTag;
+ (SSignal *)memoizedDataSignalForRemoteWebLocation:(TLInputWebFileLocation *)location datacenterId:(NSInteger)datacenterId reportProgress:(bool)reportProgress mediaTypeTag:(TGNetworkMediaTypeTag)mediaTypeTag;
+ (SSignal *)memoizedDataSignalForHttpUrl:(NSString *)httpUrl;

+ (SSignal *)sharedMediaImageWithSize:(CGSize)size
                 pixelProcessingBlock:(void (^)(void *, int, int, int))pixelProcessingBlock
                             cacheKey:(NSString *)cacheKey
                 progressiveImageData:(SSignal *(^)())progressiveImageData
                        cacheImageData:(void (^)(UIImage *, TGSharedMediaImageDataQuality))cacheImageData
                           threadPool:(SThreadPool *)threadPool
                          memoryCache:(TGMemoryImageCache *)memoryCache;

+ (SSignal *)squareThumbnail:(NSString *)cachedSizeLowPath cachedSizePath:(NSString *)cachedSizePath ofSize:(CGSize)size renderSize:(CGSize)renderSize pixelProcessingBlock:(void (^)(void *, int, int, int))pixelProcessingBlock fullSizeImageSignalGenerator:(SSignal *(^)())fullSizeImageSignalGenerator lowQualityThumbnailSignalGenerator:(SSignal *(^)())lowQualityThumbnailSignalGenerator localCachedImageSignalGenerator:(SSignal *(^)(CGSize, CGSize, bool))localCachedImageSignalGenerator lowQualityImagePath:(NSString *)lowQualityImagePath lowQualityImageUrl:(NSString *)lowQualityImageUrl highQualityImageUrl:(NSString *)highQualityImageUrl highQualityImageIdentifier:(NSString *)highQualityImageIdentifier threadPool:(SThreadPool *)threadPool memoryCache:(TGMemoryImageCache *)memoryCache placeholder:(SSignal *)placeholder blurLowQuality:(bool)blurLowQuality;

+ (SSignal *)cachedRemoteThumbnailWithKey:(NSString *)key size:(CGSize)size pixelProcessingBlock:(void (^)(void *, int, int, int))pixelProcessingBlock fetchData:(SSignal *)fetchData originalImage:(SSignal *)originalImage threadPool:(SThreadPool *)threadPool memoryCache:(TGMemoryImageCache *)memoryCache diskCache:(TGModernCache *)diskCache;

+ (void (^)(void *, int, int, int))pixelProcessingBlockForRoundCornersOfRadius:(CGFloat)radius;

@end
