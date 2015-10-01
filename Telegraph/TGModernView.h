/*
 * This is the source code of Telegram for iOS v. 1.1
 * It is licensed under GNU GPL v. 2 or later.
 * You should have received a copy of the license in this archive (see LICENSE).
 *
 * Copyright Peter Iakovlev, 2013.
 */

#import <UIKit/UIKit.h>

@protocol TGModernView <NSObject>

- (CGRect)frame;
- (void)setFrame:(CGRect)frame;

- (CGFloat)alpha;
- (void)setAlpha:(CGFloat)alpha;

- (BOOL)hidden;
- (void)setHidden:(BOOL)hidden;

- (void)setViewIdentifier:(NSString *)viewIdentifier;
- (NSString *)viewIdentifier;
- (void)setViewStateIdentifier:(NSString *)viewStateIdentifier;
- (NSString *)viewStateIdentifier;

- (void)willBecomeRecycled;

@end

@interface UIView (TGModernView) <TGModernView>

@end