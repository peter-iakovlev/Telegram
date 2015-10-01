/*
 * This is the source code of Telegram for iOS v. 1.1
 * It is licensed under GNU GPL v. 2 or later.
 * You should have received a copy of the license in this archive (see LICENSE).
 *
 * Copyright Peter Iakovlev, 2013.
 */

#import <UIKit/UIKit.h>

#import "ASWatcher.h"

@interface TGTooltipView : UIView

@property (nonatomic, strong) ASHandle *watcherHandle;

@property (nonatomic, strong) UIImageView *leftView;
@property (nonatomic, strong) UIImageView *centerView;
@property (nonatomic, strong) UIImageView *centerUpView;
@property (nonatomic, strong) UIImageView *rightView;

@property (nonatomic) CGFloat minLeftWidth;
@property (nonatomic) CGFloat minRightWidth;

@property (nonatomic) CGPoint arrowLocation;

- (id)initWithLeftImage:(UIImage *)leftImage centerImage:(UIImage *)centerImage centerUpImage:(UIImage *)centerUpImage rightImage:(UIImage *)rightImage;

@end

@interface TGTooltipContainerView : UIView

@property (nonatomic, strong) TGTooltipView *tooltipView;

@property (nonatomic, readonly) bool isShowingTooltip;

- (void)showTooltipFromRect:(CGRect)rect;
- (void)hideTooltip;

@end