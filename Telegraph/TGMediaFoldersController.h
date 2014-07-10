#import "TGViewController.h"

@class TGLiveUploadActorData;

@interface TGMediaFoldersController : TGViewController

@property (nonatomic, copy) void (^videoPicked)(NSString *existingAssetId, NSString *tempFilePath, CGSize dimensions, NSTimeInterval duration, UIImage *thumbnail, TGLiveUploadActorData *liveUploadData);
@property (nonatomic) bool liveUpload;
@property (nonatomic) bool enableServerAssetCache;

@end
