#import "TGModernGalleryInterfaceView.h"
#import "TGModernGalleryItem.h"

#import "TGModernGalleryEditableItem.h"

#import "TGPhotoToolbarView.h"

@class TGMediaPickerGallerySelectedItemsModel;

@interface TGMediaPickerGalleryInterfaceView : UIView <TGModernGalleryInterfaceView>

@property (nonatomic, copy) void (^itemSelected)(id<TGModernGalleryItem>);
@property (nonatomic, copy) bool (^isItemSelected)(id<TGModernGalleryItem>);
@property (nonatomic, copy) void (^donePressed)(id<TGModernGalleryItem>);

@property (nonatomic, copy) void(^photoStripItemSelected)(NSInteger index);

@property (nonatomic, copy) void(^videoConversionCancelled)(void);

@property (nonatomic, readonly) bool hasCaptions;
@property (nonatomic, assign) bool allowsEditing;
@property (nonatomic, assign) bool usesSimpleLayout;
@property (nonatomic, assign) bool hasSwipeGesture;
@property (nonatomic, assign) bool usesFadeOutForDismissal;

- (instancetype)initWithFocusItem:(id<TGModernGalleryItem>)focusItem allowsSelection:(bool)allowsSelection availableTabs:(NSArray *)availableTabs;

- (void)setSelectedItemsModel:(TGMediaPickerGallerySelectedItemsModel *)selectedItemsModel;
- (void)setEditorTabPressed:(void (^)(TGPhotoEditorTab tab))editorTabPressed;

- (void)willRotateWithDuration:(NSTimeInterval)duration;

- (void)updateSelectionInterface:(NSUInteger)selectedCount counterVisible:(bool)counterVisible animated:(bool)animated;
- (void)updateSelectedPhotosView:(bool)reload incremental:(bool)incremental add:(bool)add index:(NSInteger)index;
- (void)setSelectionInterfaceHidden:(bool)hidden animated:(bool)animated;

- (void)updateEditedItem:(id<TGModernGalleryEditableItem>)item;

- (void)showVideoConversionProgressForItemsCount:(NSInteger)itemsCount;
- (void)updateVideoConversionActiveItemNumber:(NSInteger)itemNumber;
- (void)updateVideoConversionProgress:(CGFloat)progress cancelEnabled:(bool)cancelEnabled;

- (void)setToolbarsHidden:(bool)hidden animated:(bool)animated;

@end
