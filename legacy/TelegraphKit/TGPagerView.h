/*
 * This is the source code of Telegram for iOS v. 1.1
 * It is licensed under GNU GPL v. 2 or later.
 * You should have received a copy of the license in this archive (see LICENSE).
 *
 * Copyright Peter Iakovlev, 2013.
 */

#import <UIKit/UIKit.h>

@interface TGPagerView : UIView

@property (nonatomic) CGFloat dotSpacing;

- (instancetype)initWithDotColors:(NSArray *)colors;
- (instancetype)initWithDotColors:(NSArray *)colors dotSize:(CGFloat)dotSize;

- (void)setPagesCount:(int)count;
- (void)setPage:(CGFloat)page;

@end
