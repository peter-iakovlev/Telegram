/*
 * This is the source code of Telegram for iOS v. 1.1
 * It is licensed under GNU GPL v. 2 or later.
 * You should have received a copy of the license in this archive (see LICENSE).
 *
 * Copyright Peter Iakovlev, 2013.
 */

#import "TGOverlayController.h"

@class TGModernGalleryModel;
@protocol TGModernGalleryItem;
@class TGModernGalleryItemView;

typedef enum {
    TGModernGalleryScrollAnimationDirectionDefault,
    TGModernGalleryScrollAnimationDirectionLeft,
    TGModernGalleryScrollAnimationDirectionRight
} TGModernGalleryScrollAnimationDirection;

@interface TGModernGalleryController : TGOverlayController

@property (nonatomic) UIStatusBarStyle defaultStatusBarStyle;
@property (nonatomic) bool shouldAnimateStatusBarStyleTransition;

@property (nonatomic, strong) TGModernGalleryModel *model;
@property (nonatomic, assign) bool animateTransition;
@property (nonatomic, assign) bool asyncTransitionIn;
@property (nonatomic, assign) bool showInterface;
@property (nonatomic, assign) bool adjustsStatusBarVisibility;
@property (nonatomic, assign) bool hasFadeOutTransition;
@property (nonatomic, assign) bool previewMode;
 
@property (nonatomic, copy) void (^itemFocused)(id<TGModernGalleryItem>);
@property (nonatomic, copy) UIView *(^beginTransitionIn)(id<TGModernGalleryItem>, TGModernGalleryItemView *);
@property (nonatomic, copy) void (^startedTransitionIn)();
@property (nonatomic, copy) void (^finishedTransitionIn)(id<TGModernGalleryItem>, TGModernGalleryItemView *);
@property (nonatomic, copy) UIView *(^beginTransitionOut)(id<TGModernGalleryItem>, TGModernGalleryItemView *);
@property (nonatomic, copy) void (^completedTransitionOut)();

- (NSArray *)visibleItemViews;
- (TGModernGalleryItemView *)itemViewForItem:(id<TGModernGalleryItem>)item;
- (id<TGModernGalleryItem>)currentItem;

- (void)setCurrentItemIndex:(NSUInteger)index animated:(bool)animated;
- (void)setCurrentItemIndex:(NSUInteger)index direction:(TGModernGalleryScrollAnimationDirection)direction animated:(bool)animated;

- (void)dismissWhenReady;
- (void)dismissWhenReadyAnimated:(bool)animated;

- (bool)isFullyOpaque;

@end
