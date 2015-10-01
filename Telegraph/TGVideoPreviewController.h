#import "TGOverlayController.h"

@class TGMediaPickerAsset;
@class TGLiveUploadActorData;

@interface TGVideoPreviewController : TGOverlayController

@property (nonatomic, readonly) TGMediaPickerAsset *asset;
@property (nonatomic, assign) bool fromCamera;

@property (nonatomic, copy) void (^videoPicked)(NSString *existingAssetId, NSString *tempFilePath, CGSize dimensions, NSTimeInterval duration, UIImage *thumbnail, TGLiveUploadActorData *liveUploadData);
@property (nonatomic) bool liveUpload;

@property (nonatomic, copy) void(^dismissBlock)(bool animated);

- (instancetype)initWithAsset:(TGMediaPickerAsset *)asset enableServerAssetCache:(bool)enableServerAssetCache;
- (instancetype)initWithItemAtURL:(NSURL *)url thumbnailImage:(UIImage *)thumbnailImage videoTransform:(CGAffineTransform)videoTransform enableServerAssetCached:(bool)enableServerAssetCache;

- (void)dismissAnimated:(bool)animated;

- (void)transitionInAnimated:(bool)animated completion:(void (^)(void))completion;
- (void)transitionOutAnimated:(bool)animated;

@end
