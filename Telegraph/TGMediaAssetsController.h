#import "TGNavigationController.h"
#import "TGMediaAssetsLibrary.h"
#import "TGSuggestionContext.h"

@class TGMediaAssetsPickerController;

typedef enum
{
    TGMediaAssetsControllerSendMediaIntent,
    TGMediaAssetsControllerSendFileIntent,
    TGMediaAssetsControllerSetProfilePhotoIntent,
    TGMediaAssetsControllerSetCustomWallpaperIntent
} TGMediaAssetsControllerIntent;

@interface TGMediaAssetsController : TGNavigationController

@property (nonatomic, strong) TGSuggestionContext *suggestionContext;
@property (nonatomic, assign) bool localMediaCacheEnabled;
@property (nonatomic, assign) bool captionsEnabled;
@property (nonatomic, assign) bool inhibitDocumentCaptions;
@property (nonatomic, assign) bool shouldStoreAssets;

@property (nonatomic, assign) bool hasTimer;
@property (nonatomic, assign) bool liveVideoUploadEnabled;
@property (nonatomic, assign) bool shouldShowFileTipIfNeeded;

@property (nonatomic, strong) NSString *recipientName;

@property (nonatomic, copy) NSDictionary *(^descriptionGenerator)(id, NSString *, NSString *);
@property (nonatomic, copy) void (^avatarCompletionBlock)(UIImage *image);
@property (nonatomic, copy) void (^completionBlock)(NSArray *signals);
@property (nonatomic, copy) void (^dismissalBlock)(void);

@property (nonatomic, readonly) TGMediaAssetsPickerController *pickerController;

- (UIBarButtonItem *)rightBarButtonItem;

- (NSArray *)resultSignalsWithCurrentItem:(TGMediaAsset *)currentItem descriptionGenerator:(id (^)(id, NSString *, NSString *))descriptionGenerator;

- (void)completeWithAvatarImage:(UIImage *)image;
- (void)completeWithCurrentItem:(TGMediaAsset *)currentItem;

+ (instancetype)controllerWithAssetGroup:(TGMediaAssetGroup *)assetGroup intent:(TGMediaAssetsControllerIntent)intent recipientName:(NSString *)recipientName;

+ (TGMediaAssetType)assetTypeForIntent:(TGMediaAssetsControllerIntent)intent;

+ (NSArray *)resultSignalsForSelectionContext:(TGMediaSelectionContext *)selectionContext editingContext:(TGMediaEditingContext *)editingContext intent:(TGMediaAssetsControllerIntent)intent currentItem:(TGMediaAsset *)currentItem storeAssets:(bool)storeAssets useMediaCache:(bool)useMediaCache descriptionGenerator:(id (^)(id, NSString *, NSString *))descriptionGenerator;

@end
