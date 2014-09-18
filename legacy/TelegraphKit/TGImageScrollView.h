/*
 * This is the source code of Telegram for iOS v. 1.1
 * It is licensed under GNU GPL v. 2 or later.
 * You should have received a copy of the license in this archive (see LICENSE).
 *
 * Copyright Peter Iakovlev, 2013.
 */

#import <UIKit/UIKit.h>

@interface TGImageScrollView : UIScrollView

@property (nonatomic) float adjustedZoomScale;

- (void)updateZoomScale;
- (bool)isAdjustedToFill;

@end

@protocol TGImageScrollViewDelegate <NSObject>

- (void)scrollViewTapped;
- (bool)shouldChangeScalingMode;
- (void)scrollViewDoubleTapped:(CGPoint)point;
- (void)scrollViewLongPressed;
- (void)scalingModeChanged:(bool)scaleToFill;
- (bool)preferScaleToFill;
- (void)videoDimensionsAvailable:(CGSize)dimensions;
- (void)videoPlayerIsActive:(bool)active;
- (void)pageMediaPlaybackStateChanged:(bool)paused;
- (void)hideInterface;
- (void)updateProgressAlpha:(float)alpha progress:(float)progress animated:(bool)animated;

@end
