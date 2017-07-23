/*
 * This is the source code of Telegram for iOS v. 1.1
 * It is licensed under GNU GPL v. 2 or later.
 * You should have received a copy of the license in this archive (see LICENSE).
 *
 * Copyright Peter Iakovlev, 2013.
 */

#import "TGCollectionItemView.h"

@interface TGVariantCollectionItemView : TGCollectionItemView

- (void)setTitle:(NSString *)title;
- (void)setVariant:(NSString *)variant variantColor:(UIColor *)variantColor;
- (void)setIcon:(UIImage *)icon;
- (void)setVariantIcon:(UIImage *)variantIcon;
- (void)setEnabled:(bool)enabled;
- (void)setHideArrow:(bool)hideArrow;
- (void)setMinLeftPadding:(CGFloat)minLeftPadding;
- (void)setFlexibleLayout:(bool)flexibleLayout;

@end
