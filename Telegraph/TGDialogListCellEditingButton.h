#import <UIKit/UIKit.h>

@interface TGDialogListCellEditingButton : UIButton

@property (nonatomic, assign) bool labelOnly;
@property (nonatomic, assign) bool smallLabel;
@property (nonatomic, assign) bool offsetLabel;

- (void)setTitle:(NSString *)title image:(UIImage *)image;
- (void)setBackgroundColor:(UIColor *)backgroundColor force:(bool)force;

@end
