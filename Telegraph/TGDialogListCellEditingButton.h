#import <UIKit/UIKit.h>

@interface TGDialogListCellEditingButton : UIButton

@property (nonatomic, assign) bool labelOnly;

- (void)setTitle:(NSString *)title image:(UIImage *)image;
- (void)setBackgroundColor:(UIColor *)backgroundColor force:(bool)force;

@end
