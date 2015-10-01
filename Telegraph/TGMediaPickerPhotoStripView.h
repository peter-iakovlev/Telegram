#import <UIKit/UIKit.h>

@class TGMediaPickerGallerySelectedItemsModel;

@interface TGMediaPickerPhotoStripView : UIView

@property (nonatomic, weak) TGMediaPickerGallerySelectedItemsModel *selectedItemsModel;
@property (nonatomic, assign) UIInterfaceOrientation interfaceOrientation;
@property (nonatomic, readonly) bool isAnimating;

@property (nonatomic, copy) void(^itemSelected)(NSInteger index);

- (void)setHidden:(bool)hidden animated:(bool)animated;

- (void)reloadData;
- (void)insertItemAtIndex:(NSInteger)index;
- (void)deleteItemAtIndex:(NSInteger)index;
- (void)updateItemAtIndex:(NSInteger)index;

- (void)updateSelectedItems;

@end
