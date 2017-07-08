/*
 * This is the source code of Telegram for iOS v. 1.1
 * It is licensed under GNU GPL v. 2 or later.
 * You should have received a copy of the license in this archive (see LICENSE).
 *
 * Copyright Peter Iakovlev, 2013.
 */

#import <UIKit/UIKit.h>

@class TGStaticBackdropAreaData;

@interface TGMessageImageAdditionalDataView : UIView

- (void)setTimestampColor:(UIColor *)timestampColor;
- (void)setBackdropArea:(TGStaticBackdropAreaData *)backdropArea transitionDuration:(NSTimeInterval)transitionDuration;
- (void)setText:(NSString *)text;
- (void)setTextAlignment:(NSTextAlignment)textAlignment;

@end
