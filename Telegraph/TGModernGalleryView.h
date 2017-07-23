/*
 * This is the source code of Telegram for iOS v. 1.1
 * It is licensed under GNU GPL v. 2 or later.
 * You should have received a copy of the license in this archive (see LICENSE).
 *
 * Copyright Peter Iakovlev, 2013.
 */

#import <UIKit/UIKit.h>

#import "TGModernGalleryInterfaceView.h"

@class TGModernGalleryScrollView;

@interface TGModernGalleryView : UIView

@property (nonatomic, copy) bool (^transitionOut)(CGFloat velocity);
@property (nonatomic, copy) void (^instantDismiss)();

@property (nonatomic, strong, readonly) UIView *overlayContainerView;

@property (nonatomic, strong, readonly) UIView<TGModernGalleryInterfaceView> *interfaceView;
@property (nonatomic, strong, readonly) TGModernGalleryScrollView *scrollView;

- (instancetype)initWithFrame:(CGRect)frame itemPadding:(CGFloat)itemPadding interfaceView:(UIView<TGModernGalleryInterfaceView> *)interfaceView previewMode:(bool)previewMode previewSize:(CGSize)previewSize;

- (bool)shouldAutorotate;

- (void)showHideInterface;
- (void)hideInterfaceAnimated;
- (void)updateInterfaceVisibility;

- (void)addItemHeaderView:(UIView *)itemHeaderView;
- (void)removeItemHeaderView:(UIView *)itemHeaderView;
- (void)addItemFooterView:(UIView *)itemFooterView;
- (void)removeItemFooterView:(UIView *)itemFooterView;

- (void)simpleTransitionOutWithVelocity:(CGFloat)velocity completion:(void (^)())completion;
- (void)transitionInWithDuration:(NSTimeInterval)duration;
- (void)transitionOutWithDuration:(NSTimeInterval)duration;

- (void)fadeOutWithDuration:(NSTimeInterval)duration completion:(void (^)(void))completion;

- (void)setScrollViewVerticalOffset:(CGFloat)offset;

- (void)setPreviewMode:(bool)previewMode;
- (void)enableInstantDismiss;

@end
