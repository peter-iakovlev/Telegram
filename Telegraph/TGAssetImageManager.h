#import <Foundation/Foundation.h>

@class TGMediaPickerAsset;
@class AVPlayerItem;
@class AVAsset;

typedef enum {
    TGAssetImageTypeUndefined = 0,
    TGAssetImageTypeThumbnail,
    TGAssetImageTypeAspectRatioThumbnail,
    TGAssetImageTypeScreen,
    TGAssetImageTypeFullSize
} TGAssetImageType;

@interface TGAssetThumbnailsRequestCancelToken : NSObject

@property (nonatomic, assign) bool cancelled;

@end

@interface TGAssetImageManager : NSObject

+ (NSUInteger)requestImageWithAsset:(TGMediaPickerAsset *)asset
                          imageType:(TGAssetImageType)imageType
                               size:(CGSize)size
                    completionBlock:(void (^)(UIImage *image, NSError *error))completionBlock;

+ (NSUInteger)requestImageWithAsset:(TGMediaPickerAsset *)asset
                          imageType:(TGAssetImageType)imageType
                               size:(CGSize)size
                        synchronous:(bool)synchronous
                      progressBlock:(void (^)(CGFloat progress))progressBlock
                    completionBlock:(void (^)(UIImage *image, NSError *error))completionBlock;

+ (NSUInteger)requestImageDataWithAsset:(TGMediaPickerAsset *)asset
                        completionBlock:(void (^)(NSData *data, NSString *fileName, NSString *dataUTI, NSError *error))completionBlock;
+ (NSUInteger)requestImageDataWithAsset:(TGMediaPickerAsset *)asset synchronous:(bool)synchronous
                        completionBlock:(void (^)(NSData *data, NSString *fileName, NSString *dataUTI, NSError *error))completionBlock;

+ (void)requestImageMetadataWithAsset:(TGMediaPickerAsset *)asset
                      completionBlock:(void (^)(NSDictionary *metadata, NSError *error))completionBlock;

+ (NSUInteger)requestFileAttributesForAsset:(TGMediaPickerAsset *)asset
                                 completion:(void (^)(NSString *fileName, NSString *dataUTI, CGSize dimensions, NSUInteger fileSize))completion;

+ (void)cancelRequestWithToken:(NSUInteger)token;

+ (void)startCachingImagesForAssets:(NSArray *)assets
                               size:(CGSize)size
                          imageType:(TGAssetImageType)imageType;

+ (void)stopCachingImagesForAssets:(NSArray *)assets
                              size:(CGSize)size
                         imageType:(TGAssetImageType)imageType;

+ (void)stopCachingImagesForAllAssets;

+ (bool)usesLegacyAssetsLibrary;

+ (AVPlayerItem *)playerItemForVideoAsset:(TGMediaPickerAsset *)asset;
+ (AVAsset *)avAssetForVideoAsset:(TGMediaPickerAsset *)asset;
+ (UIImageOrientation)videoOrientationOfAVAsset:(AVAsset *)avAsset;

+ (bool)copyOriginalFileForAsset:(TGMediaPickerAsset *)asset toPath:(NSString *)path completion:(void (^)(NSString *filename))completion;

+ (TGAssetThumbnailsRequestCancelToken *)requestVideoThumbnailsForAsset:(TGMediaPickerAsset *)asset
                                                                   size:(CGSize)size
                                                             timestamps:(NSArray *)timestamps
                                                             completion:(void (^)(NSArray *images, bool cancelled))completion;

+ (TGAssetThumbnailsRequestCancelToken *)requestVideoThumbnailsForItemAtURL:(NSURL *)url
                                                                       size:(CGSize)size
                                                                 timestamps:(NSArray *)timestamps
                                                                 completion:(void (^)(NSArray *images, bool cancelled))completion;

+ (TGAssetThumbnailsRequestCancelToken *)requestVideoThumbnailsForAVAsset:(AVAsset *)asset
                                                                     size:(CGSize)size
                                                               timestamps:(NSArray *)timestamps
                                                               completion:(void (^)(NSArray *, bool))completion;

@end

extern const CGSize TGAssetImageManagerLegacySizeLimit;
