#import "TGAttachmentSheetItemView.h"

@interface TGAttachmentSheetButtonItemView : TGAttachmentSheetItemView

@property (nonatomic, copy) void (^pressed)();

- (instancetype)initWithTitle:(NSString *)title pressed:(void (^)())pressed;
- (void)setTitle:(NSString *)title;
- (void)setBold:(bool)bold;
- (void)setImage:(UIImage *)image;
- (void)setDisabled:(bool)disabled;
- (void)setDestructive:(bool)destructive;

- (void)_buttonPressed;

@end
