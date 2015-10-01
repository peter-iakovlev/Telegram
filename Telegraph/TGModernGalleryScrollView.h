/*
 * This is the source code of Telegram for iOS v. 1.1
 * It is licensed under GNU GPL v. 2 or later.
 * You should have received a copy of the license in this archive (see LICENSE).
 *
 * Copyright Peter Iakovlev, 2013.
 */

#import <UIKit/UIKit.h>

@protocol TGModernGalleryScrollViewDelegate <NSObject>

- (bool)scrollViewShouldScrollWithTouchAtPoint:(CGPoint)point;
- (void)scrollViewBoundsChanged:(CGRect)bounds;

@end

@interface TGModernGalleryScrollView : UIScrollView

@property (nonatomic, weak) id<TGModernGalleryScrollViewDelegate> scrollDelegate;

- (void)setFrameAndBoundsInTransaction:(CGRect)frame bounds:(CGRect)bounds;

@end
