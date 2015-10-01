#import <UIKit/UIKit.h>

@interface TGProgressAlert : UIView

@property (nonatomic, strong) NSString *text;
@property (nonatomic) CGFloat progress;

@property (nonatomic, copy) void (^cancel)();

- (void)setProgress:(CGFloat)progress animated:(bool)animated;

@end
