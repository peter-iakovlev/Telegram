#import "TGViewController.h"

@class TGLiveUploadActorData;

@interface TGModernMediaPickerController : TGViewController

@property (nonatomic, copy) void (^videoPicked)(NSString *existingAssetId, NSString *tempFilePath, CGSize dimensions, NSTimeInterval duration, UIImage *thumbnail, TGLiveUploadActorData *liveUploadData);
@property (nonatomic) bool liveUpload;
@property (nonatomic) bool enableServerAssetCache;

- (instancetype)init;
- (instancetype)initWithAssetsGroupPersistentId:(NSString *)assetsGroupPersistentId title:(NSString *)title;

@end
