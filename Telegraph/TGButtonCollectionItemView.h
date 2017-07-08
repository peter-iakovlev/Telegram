/*
 * This is the source code of Telegram for iOS v. 1.1
 * It is licensed under GNU GPL v. 2 or later.
 * You should have received a copy of the license in this archive (see LICENSE).
 *
 * Copyright Peter Iakovlev, 2013.
 */

#import "TGCollectionItemView.h"

@interface TGButtonCollectionItemView : TGCollectionItemView

@property (nonatomic) CGFloat leftInset;
@property (nonatomic) CGFloat additionalSeparatorInset;

- (void)setTitle:(NSString *)title;
- (void)setTitleColor:(UIColor *)titleColor;
- (void)setTitleAlignment:(NSTextAlignment)alignment;
- (void)setEnabled:(bool)enabled;
- (void)setIcon:(UIImage *)icon;
- (void)setIconOffset:(CGPoint)iconOffset;

@end
