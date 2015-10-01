#import <UIKit/UIKit.h>

@class TGMediaPickerAsset;
@class TGMediaPickerItem;
@protocol TGModernMediaListItem;

@interface TGAttachmentSheetRecentAssetCell : UICollectionViewCell

@property (nonatomic, strong, readonly) TGMediaPickerItem *item;

- (void)setItem:(TGMediaPickerItem *)item isItemSelected:(bool (^)(id<TGModernMediaListItem>))isItemSelected isItemHidden:(bool (^)(id<TGModernMediaListItem>))isItemHidden changeItemSelection:(void (^)(id<TGModernMediaListItem>))changeItemSelection openItem:(void (^)(TGMediaPickerItem *))openItem;
- (UIView *)referenceViewForAsset:(TGMediaPickerAsset *)asset;
- (UIImage *)imageForAsset:(TGMediaPickerAsset *)asset;
- (void)updateSelection;
- (void)updateHidden:(bool)animated;
- (void)updateItem;

@end
