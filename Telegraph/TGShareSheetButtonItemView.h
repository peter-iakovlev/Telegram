#import "TGShareSheetItemView.h"

@interface TGShareSheetButtonItemView : TGShareSheetItemView

@property (nonatomic, copy) void (^pressed)();

- (instancetype)initWithTitle:(NSString *)title pressed:(void (^)())pressed;
- (void)setTitle:(NSString *)title;
- (void)setBold:(bool)bold;
- (void)setImage:(UIImage *)image;
- (void)setDestructive:(bool)destructive;
- (void)setEnabled:(bool)enabled;

- (void)_buttonPressed;

@end
