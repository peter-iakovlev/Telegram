/*
 * This is the source code of Telegram for iOS v. 1.1
 * It is licensed under GNU GPL v. 2 or later.
 * You should have received a copy of the license in this archive (see LICENSE).
 *
 * Copyright Peter Iakovlev, 2013.
 */

#import <UIKit/UIKit.h>

@interface TGPagerView : UIView

@property (nonatomic) float dotSpacing;

- (instancetype)initWithDotColors:(NSArray *)colors;

- (void)setPagesCount:(int)count;
- (void)setPage:(float)page;

@end
