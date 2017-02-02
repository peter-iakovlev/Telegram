#import "TGMediaAssetsPickerController.h"

@class TGMediaAssetMomentList;

@interface TGMediaAssetsMomentsController : TGMediaAssetsPickerController

- (instancetype)initWithAssetsLibrary:(TGMediaAssetsLibrary *)assetsLibrary momentList:(TGMediaAssetMomentList *)momentList intent:(TGMediaAssetsControllerIntent)intent selectionContext:(TGMediaSelectionContext *)selectionContext editingContext:(TGMediaEditingContext *)editingContext;

@end
