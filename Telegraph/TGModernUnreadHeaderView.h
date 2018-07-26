/*
 * This is the source code of Telegram for iOS v. 1.1
 * It is licensed under GNU GPL v. 2 or later.
 * You should have received a copy of the license in this archive (see LICENSE).
 *
 * Copyright Peter Iakovlev, 2013.
 */

#import "TGModernView.h"

@class TGPresentation;

@interface TGModernUnreadHeaderView : UIView <TGModernView>

- (instancetype)initWithFrame:(CGRect)frame presentation:(TGPresentation *)presentation;
- (void)setPresentation:(TGPresentation *)presentation;

+ (void)drawHeaderForContainerWidth:(CGFloat)containerWidth inContext:(CGContextRef)context andBindBackgroundToContainer:(UIView *)backgroundContainer atPosition:(CGPoint)position presentation:(TGPresentation *)presentation;
- (void)updateAssets;

@end
