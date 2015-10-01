#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>

@class TGMediaPickerAsset;
@class TGLiveUploadActorData;

@interface TGVideoConverter : NSObject

@property (nonatomic, assign) bool liveUpload;
@property (nonatomic, assign) CMTimeRange trimRange;
@property (nonatomic, assign) CGRect cropRect;
@property (nonatomic, assign) UIImageOrientation cropOrientation;

- (instancetype)initForConvertationWithAsset:(TGMediaPickerAsset *)asset liveUpload:(bool)liveUpload highDefinition:(bool)highDefinition;
- (instancetype)initForPassthroughWithItemURL:(NSURL *)url liveUpload:(bool)liveUpload;

- (void)processWithCompletion:(void (^)(NSString *tempFilePath, CGSize dimensions, NSTimeInterval duration, UIImage *previewImage, TGLiveUploadActorData *liveUploadData))completion progress:(void (^)(float progress))progress;
- (void)cancel;

+ (void)computeHashForVideoAsset:(id)asset hasTrimming:(bool)hasTrimming isCropped:(bool)isCropped highDefinition:(bool)highDefinition completion:(void (^)(NSString *hash))completion;

@end
