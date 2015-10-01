#import "TGViewController.h"
#import "TGModernMediaPickerController.h"
#import "TGMediaPickerAssetsLibrary.h"

@class SSignal;
@class TGLiveUploadActorData;

@interface TGMediaFoldersController : TGViewController

@property (nonatomic, copy) void(^photosPicked)(TGModernMediaPickerController *sender);
@property (nonatomic, copy) void(^videoPicked)(NSString *existingAssetId, NSString *tempFilePath, CGSize dimensions, NSTimeInterval duration, UIImage *thumbnail, NSString *caption, TGLiveUploadActorData *liveUploadData);
@property (nonatomic, copy) void(^avatarCreated)(UIImage *image);

@property (nonatomic, copy) void(^dismiss)(void);

@property (nonatomic, copy) SSignal *(^userListSignal)(NSString *mention);
@property (nonatomic, copy) SSignal *(^hashtagListSignal)(NSString *hashtag);

@property (nonatomic) bool liveUpload;
@property (nonatomic) bool enableServerAssetCache;

@property (nonatomic, assign) bool disallowCaptions;

- (instancetype)initWithIntent:(TGModernMediaPickerControllerIntent)intent;

@end
