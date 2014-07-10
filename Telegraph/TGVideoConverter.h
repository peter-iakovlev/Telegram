#import <Foundation/Foundation.h>

@class TGLiveUploadActorData;

@interface TGVideoConverter : NSObject

@property (nonatomic) bool liveUpload;

- (instancetype)initWithAssetUrl:(NSURL *)assetUrl liveUpload:(bool)liveUpload highDefinition:(bool)highDefinition;

- (void)convertWithCompletion:(void (^)(NSString *tempFilePath, CGSize dimensions, NSTimeInterval duration, TGLiveUploadActorData *liveUploadData))completion progress:(void (^)(float progress))progress;
- (void)cancel;

@end
