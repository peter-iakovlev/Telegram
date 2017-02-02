#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>

@class TGMediaPickerAsset;
@class TGLiveUploadActorData;
@class SSignal;
@class TGVideoEditAdjustments;

@interface TGVideoConverter : NSObject

- (void)processWithCompletion:(void (^)(NSString *tempFilePath, CGSize dimensions, NSTimeInterval duration, UIImage *previewImage, TGLiveUploadActorData *liveUploadData))completion progress:(void (^)(float progress))progress;
- (void)cancel;

+ (void)computeHashForVideoAsset:(id)asset hasTrimming:(bool)hasTrimming isCropped:(bool)isCropped highDefinition:(bool)highDefinition completion:(void (^)(NSString *hash))completion;

+ (SSignal *)convertSignalForAVAsset:(AVAsset *)avAsset adjustments:(TGVideoEditAdjustments *)adjustments liveUpload:(bool)liveUpload passthrough:(bool)passthrough;
+ (SSignal *)hashSignalForAVAsset:(AVAsset *)avAsset;

@end
