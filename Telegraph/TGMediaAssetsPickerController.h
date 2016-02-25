#import "TGMediaPickerController.h"
#import "TGMediaAssetsController.h"

@interface TGMediaAssetsPickerController : TGMediaPickerController

@property (nonatomic, assign) bool liveVideoUploadEnabled;
@property (nonatomic, readonly) TGMediaAssetGroup *assetGroup;

- (instancetype)initWithAssetsLibrary:(TGMediaAssetsLibrary *)assetsLibrary assetGroup:(TGMediaAssetGroup *)assetGroup intent:(TGMediaAssetsControllerIntent)intent selectionContext:(TGMediaSelectionContext *)selectionContext editingContext:(TGMediaEditingContext *)editingContext;

@end
