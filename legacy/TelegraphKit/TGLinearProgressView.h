/*
 * This is the source code of Telegram for iOS v. 1.1
 * It is licensed under GNU GPL v. 2 or later.
 * You should have received a copy of the license in this archive (see LICENSE).
 *
 * Copyright Peter Iakovlev, 2013.
 */

#import <UIKit/UIKit.h>

@interface TGLinearProgressView : UIView

@property (nonatomic) CGFloat progress;
@property (nonatomic) bool alwaysShowMinimum;

- (id)initWithBackgroundImage:(UIImage *)backgroundImage progressImage:(UIImage *)progressImage;

- (void)setProgress:(CGFloat)progress animationDuration:(NSTimeInterval)animationDuration;

@end
