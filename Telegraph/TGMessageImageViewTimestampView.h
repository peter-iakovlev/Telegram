/*
 * This is the source code of Telegram for iOS v. 1.1
 * It is licensed under GNU GPL v. 2 or later.
 * You should have received a copy of the license in this archive (see LICENSE).
 *
 * Copyright Peter Iakovlev, 2013.
 */

#import <UIKit/UIKit.h>

@class TGStaticBackdropAreaData;

@interface TGMessageImageViewTimestampView : UIView

- (instancetype)initWithFrame:(CGRect)frame;

- (void)setBackdropArea:(TGStaticBackdropAreaData *)backdropArea transitionDuration:(NSTimeInterval)transitionDuration;
- (void)setTimestampColor:(UIColor *)timestampColor;
- (void)setTimestampString:(NSString *)timestampString displayCheckmarks:(bool)displayCheckmarks checkmarkValue:(int)checkmarkValue displayViews:(bool)displayViews viewsValue:(int)viewsValue animated:(bool)animated;
- (void)setDisplayProgress:(bool)displayProgress;
- (void)setIsBroadcast:(bool)setIsBroadcast;
- (void)setTransparent:(bool)transparent;
- (CGSize)currentSize;

@end
