#import <UIKit/UIKit.h>

@interface TGProgressAlert : UIView

@property (nonatomic, strong) NSString *text;
@property (nonatomic) CGFloat progress;

@property (nonatomic, copy) void (^cancel)();

- (instancetype)initWithFrame:(CGRect)frame backgroundColor:(UIColor *)backgroundColor separatorColor:(UIColor *)separatorColor textColor:(UIColor *)textColor accentColor:(UIColor *)accentColor;

- (void)setProgress:(CGFloat)progress animated:(bool)animated;

@end
