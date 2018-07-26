#import <UIKit/UIKit.h>

@class TGPresentation;

@interface TGLockIconView : UIView

@property (nonatomic, strong) TGPresentation *presentation;

- (bool)isLocked;
- (void)setIsLocked:(bool)isLocked animated:(bool)animated;

@end
