/*
 * This is the source code of Telegram for iOS v. 1.1
 * It is licensed under GNU GPL v. 2 or later.
 * You should have received a copy of the license in this archive (see LICENSE).
 *
 * Copyright Peter Iakovlev, 2013.
 */

#import "TGModernView.h"
#import "TGModernButton.h"

@interface TGModernButtonView : TGModernButton <TGModernView>

- (void)setBackgroundImage:(UIImage *)backgroundImage;
- (void)setHighlightedBackgroundImage:(UIImage *)highlightedBackgroundImage;
- (void)setTitle:(NSString *)title;
- (void)setTitleFont:(UIFont *)titleFont;
- (void)setImage:(UIImage *)image;
- (void)setHighlightedImage:(UIImage *)highlightedImage;
- (void)setSupplementaryIcon:(UIImage *)supplementaryIcon;
- (void)setDisplayProgress:(bool)displayProgress animated:(bool)animated;

@end
