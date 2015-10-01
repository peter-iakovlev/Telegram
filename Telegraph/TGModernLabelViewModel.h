/*
 * This is the source code of Telegram for iOS v. 1.1
 * It is licensed under GNU GPL v. 2 or later.
 * You should have received a copy of the license in this archive (see LICENSE).
 *
 * Copyright Peter Iakovlev, 2013.
 */

#import "TGModernViewModel.h"

#import <CoreText/CoreText.h>

@interface TGModernLabelViewModel : TGModernViewModel

@property (nonatomic, strong) UIColor *textColor;

- (instancetype)initWithText:(NSString *)text textColor:(UIColor *)textColor font:(CTFontRef)font maxWidth:(CGFloat)maxWidth;
- (instancetype)initWithText:(NSString *)text textColor:(UIColor *)textColor font:(CTFontRef)font maxWidth:(CGFloat)maxWidth truncateInTheMiddle:(bool)truncateInTheMiddle;

- (void)setText:(NSString *)text maxWidth:(CGFloat)maxWidth;
- (void)setText:(NSString *)text maxWidth:(CGFloat)maxWidth needsContentUpdate:(bool *)needsContentUpdate;
- (NSString *)text;
- (void)setMaxWidth:(CGFloat)maxWidth;

@end
