#import "TGModernMediaListItemContentView.h"

@class TGMediaPickerItem;
@class TGAssetImageView;
@class TGMediaPickerAsset;
@class TGImagePickerCellCheckButton;

@interface TGMediaPickerAssetItemView : TGModernMediaListItemContentView
{
    TGImagePickerCellCheckButton *_checkButton;
    
    bool (^_isItemSelected)(id<TGModernMediaListItem>);
    bool (^_isItemHidden)(id<TGModernMediaListItem>);
    void (^_changeItemSelection)(id<TGModernMediaListItem>, bool);
}

@property (nonatomic, strong, readonly) TGAssetImageView *imageView;

- (void)setImage:(UIImage *)image;
- (void)setAsset:(TGMediaPickerAsset *)asset;
- (void)updateHiddenAnimated:(bool)animated;
- (void)updateSelectionAnimated:(bool)animated;

@end
