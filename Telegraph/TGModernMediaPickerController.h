#import "TGViewController.h"
#import "TGMediaPickerAssetsLibrary.h"

@class SSignal;
@class TGLiveUploadActorData;

typedef enum {
    TGModernMediaPickerControllerDefaultIntent,
    TGModernMediaPickerControllerSendPhotoIntent,
    TGModernMediaPickerControllerSendVideoIntent,
    TGModernMediaPickerControllerSendFileIntent,
    TGModernMediaPickerControllerSetProfilePhotoIntent,
    TGModernMediaPickerControllerSetCustomWallpaperIntent
} TGModernMediaPickerControllerIntent;

@interface TGModernMediaPickerController : TGViewController <UIGestureRecognizerDelegate>

@property (nonatomic, assign) bool liveUploadEnabled;
@property (nonatomic, assign) bool serverAssetCacheEnabled;

@property (nonatomic, assign) bool shouldShowFileTipIfNeeded;

@property (nonatomic, assign) bool disallowCaptions;

@property (nonatomic, copy) void(^photosPicked)(TGModernMediaPickerController *sender);
@property (nonatomic, copy) void(^videoPicked)(NSString *existingAssetId, NSString *tempFilePath, CGSize dimensions, NSTimeInterval duration, UIImage *thumbnail, NSString *caption, TGLiveUploadActorData *liveUploadData);
@property (nonatomic, copy) void(^avatarCreated)(UIImage *image);

@property (nonatomic, copy) void(^dismiss)(void);

@property (nonatomic, copy) SSignal *(^userListSignal)(NSString *mention);
@property (nonatomic, copy) SSignal *(^hashtagListSignal)(NSString *hashtag);

- (instancetype)initWithAssetsGroup:(TGMediaPickerAssetsGroup *)assetsGroup intent:(TGModernMediaPickerControllerIntent)intent;

- (NSArray *)selectedItemSignals:(id (^)(id, NSString *, NSString *))descriptionGenerator;

+ (TGMediaPickerAssetType)assetTypeForIntent:(TGModernMediaPickerControllerIntent)intent;

@end
