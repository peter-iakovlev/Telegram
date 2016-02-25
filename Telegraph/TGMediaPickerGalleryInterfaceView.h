#import "TGModernGalleryInterfaceView.h"
#import "TGModernGalleryItem.h"

#import "TGPhotoToolbarView.h"

@class TGMediaSelectionContext;
@class TGMediaEditingContext;
@class TGMediaPickerGallerySelectedItemsModel;

@interface TGMediaPickerGalleryInterfaceView : UIView <TGModernGalleryInterfaceView>

@property (nonatomic, copy) void (^donePressed)(id<TGModernGalleryItem>);

@property (nonatomic, copy) void (^photoStripItemSelected)(NSInteger index);

@property (nonatomic, copy) void(^videoConversionCancelled)(void);

@property (nonatomic, assign) bool hasCaptions;
@property (nonatomic, assign) bool usesSimpleLayout;
@property (nonatomic, assign) bool hasSwipeGesture;
@property (nonatomic, assign) bool usesFadeOutForDismissal;

@property (nonatomic, readonly) TGPhotoEditorTab currentTabs;

- (instancetype)initWithFocusItem:(id<TGModernGalleryItem>)focusItem selectionContext:(TGMediaSelectionContext *)selectionContext editingContext:(TGMediaEditingContext *)editingContext hasSelectionPanel:(bool)hasSelectionPanel;

- (void)setSelectedItemsModel:(TGMediaPickerGallerySelectedItemsModel *)selectedItemsModel;
- (void)setEditorTabPressed:(void (^)(TGPhotoEditorTab tab))editorTabPressed;

- (void)setThumbnailSignalForItem:(SSignal *(^)(id))thumbnailSignalForItem;

- (void)willRotateWithDuration:(NSTimeInterval)duration;

- (void)updateSelectionInterface:(NSUInteger)selectedCount counterVisible:(bool)counterVisible animated:(bool)animated;
- (void)updateSelectedPhotosView:(bool)reload incremental:(bool)incremental add:(bool)add index:(NSInteger)index;
- (void)setSelectionInterfaceHidden:(bool)hidden animated:(bool)animated;

- (void)showVideoConversionProgressForItemsCount:(NSInteger)itemsCount;
- (void)updateVideoConversionActiveItemNumber:(NSInteger)itemNumber;
- (void)updateVideoConversionProgress:(CGFloat)progress cancelEnabled:(bool)cancelEnabled;

- (void)setToolbarsHidden:(bool)hidden animated:(bool)animated;

- (void)setTabBarUserInteractionEnabled:(bool)enabled;

@end
