#import "TGViewController.h"
#import "TGSuggestionContext.h"

@class TGMediaPickerLayoutMetrics;
@class TGMediaSelectionContext;
@class TGMediaEditingContext;

@interface TGMediaPickerController : TGViewController
{
    TGMediaPickerLayoutMetrics *_layoutMetrics;
    UICollectionView *_collectionView;
}

@property (nonatomic, strong) TGSuggestionContext *suggestionContext;
@property (nonatomic, assign) bool localMediaCacheEnabled;
@property (nonatomic, assign) bool captionsEnabled;
@property (nonatomic, assign) bool shouldStoreAssets;

@property (nonatomic, readonly) TGMediaSelectionContext *selectionContext;
@property (nonatomic, readonly) TGMediaEditingContext *editingContext;

@property (nonatomic, copy) void (^catchToolbarView)(bool enabled);

- (instancetype)initWithSelectionContext:(TGMediaSelectionContext *)selectionContext editingContext:(TGMediaEditingContext *)editingContext;
- (NSArray *)resultSignals:(id (^)(id, NSString *, NSString *))descriptionGenerator;

- (NSInteger)_numberOfItems;
- (id)_itemAtIndexPath:(NSIndexPath *)indexPath;
- (SSignal *)_signalForItem:(id)item;
- (NSString *)_cellKindForItem:(id)item;

- (void)_hideCellForItem:(id)item animated:(bool)animated;
- (void)_adjustContentOffsetToBottom;

@end
