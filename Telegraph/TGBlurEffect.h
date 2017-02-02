#import <UIKit/UIKit.h>

@interface UIBlurEffect (Radius)

@property (nonatomic, readonly) id effectSettings;

@end

@interface TGBlurEffect : UIBlurEffect

+ (instancetype)effectWithStyle:(UIBlurEffectStyle)style radius:(CGFloat)radius;

+ (instancetype)forceTouchBlurEffect;

+ (instancetype)cropBlurEffect;

+ (instancetype)callBlurEffect;

@end
