#import "TGViewController.h"

@class TGLiveUploadActorData;

@interface TGVideoPreviewController : TGViewController

@property (nonatomic, copy) void (^videoPicked)(NSString *existingAssetId, NSString *tempFilePath, CGSize dimensions, NSTimeInterval duration, UIImage *thumbnail, TGLiveUploadActorData *liveUploadData);
@property (nonatomic) bool liveUpload;

- (instancetype)initWithAssetUrl:(NSURL *)assetUrl thumbnail:(UIImage *)thumbnail duration:(NSTimeInterval)duration enableServerAssetCache:(bool)enableServerAssetCache;

@end
