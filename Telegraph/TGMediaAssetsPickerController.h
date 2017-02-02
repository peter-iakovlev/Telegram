#import "TGMediaPickerController.h"
#import "TGMediaAssetsController.h"

@class TGMediaAssetsPreheatMixin;
@class TGMediaPickerModernGalleryMixin;

@interface TGMediaAssetsPickerController : TGMediaPickerController
{
    TGMediaAssetsPreheatMixin *_preheatMixin;
}

@property (nonatomic, assign) bool liveVideoUploadEnabled;
@property (nonatomic, readonly) TGMediaAssetGroup *assetGroup;

- (instancetype)initWithAssetsLibrary:(TGMediaAssetsLibrary *)assetsLibrary assetGroup:(TGMediaAssetGroup *)assetGroup intent:(TGMediaAssetsControllerIntent)intent selectionContext:(TGMediaSelectionContext *)selectionContext editingContext:(TGMediaEditingContext *)editingContext;

@end
