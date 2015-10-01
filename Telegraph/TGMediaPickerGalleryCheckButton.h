#import <UIKit/UIKit.h>

@interface TGMediaPickerGalleryCheckButton : UIButton

@property (nonatomic, strong) UIImageView *checkView;
@property (nonatomic, assign) bool checked;

- (void)setChecked:(bool)checked animated:(bool)animated;

@end
