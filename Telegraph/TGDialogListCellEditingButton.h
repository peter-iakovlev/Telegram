#import <UIKit/UIKit.h>

@interface TGDialogListCellEditingButton : UIButton

@property (nonatomic, assign) bool labelOnly;
@property (nonatomic, assign) bool smallLabel;
@property (nonatomic, assign) bool offsetLabel;

@property (nonatomic, assign) CGFloat buttonWidth;

- (void)setTitle:(NSString *)title animationName:(NSString *)animationName;
- (void)playAnimation;
- (void)resetAnimation;
- (void)skipAnimation;

@property (nonatomic, assign) bool triggered;
- (void)setTriggered:(bool)triggered animated:(bool)animated;

- (void)setTitle:(NSString *)title image:(UIImage *)image;
- (void)setBackgroundColor:(UIColor *)backgroundColor force:(bool)force;

@end
