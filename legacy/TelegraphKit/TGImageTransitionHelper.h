/*
 * This is the source code of Telegram for iOS v. 1.1
 * It is licensed under GNU GPL v. 2 or later.
 * You should have received a copy of the license in this archive (see LICENSE).
 *
 * Copyright Peter Iakovlev, 2013.
 */

#import <UIKit/UIKit.h>

@interface TGImageTransitionHelper : NSObject

@property (nonatomic, strong) UIColor *fadingColor;

- (void)beginTransitionIn:(UIView *)imageView fromImage:(UIImage *)fromImage fromView:(UIView *)fromView transform:(CGAffineTransform)transform fromRectInWindowSpace:(CGRect)fromRectInWindowSpace aboveView:(UIView *)aboveView toView:(UIView *)toView toRectInWindowSpace:(CGRect)toRectInWindowSpace toInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation completion:(dispatch_block_t)completion keepAspect:(bool)keepAspect;
- (void)beginTransitionIn:(UIView *)imageView fromImage:(UIImage *)fromImage fromView:(UIView *)fromView transform:(CGAffineTransform)transform fromRectInWindowSpace:(CGRect)fromRectInWindowSpace aboveView:(UIView *)aboveView toView:(UIView *)toView toRectInWindowSpace:(CGRect)toRectInWindowSpace toInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation completion:(dispatch_block_t)completion keepAspect:(bool)keepAspect duration:(NSTimeInterval)duration;

- (void)beginTransitionOut:(UIView *)imageView fromView:(UIView *)fromView transform:(CGAffineTransform)transform toView:(UIView *)toView aboveView:(UIView *)aboveView interfaceOrientation:(UIInterfaceOrientation)interfaceOrientation toRectInWindowSpace:(CGRect)toRectInWindowSpace toImage:(UIImage *)toImage keepAspect:(bool)keepAspect swipeVelocity:(float)swipeVelocity completion:(dispatch_block_t)completion;
- (void)beginTransitionOut:(UIView *)imageView fromView:(UIView *)fromView transform:(CGAffineTransform)transform toView:(UIView *)toView aboveView:(UIView *)aboveView interfaceOrientation:(UIInterfaceOrientation)interfaceOrientation toRectInWindowSpace:(CGRect)toRectInWindowSpace toImage:(UIImage *)toImage keepAspect:(bool)keepAspect swipeVelocity:(float)swipeVelocity completion:(dispatch_block_t)completion duration:(NSTimeInterval)duration;

@end
