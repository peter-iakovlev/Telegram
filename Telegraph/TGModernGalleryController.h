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

@interface TGModernGalleryController : TGOverlayController

@property (nonatomic, strong) TGModernGalleryModel *model;
@property (nonatomic) bool animateTransition;
@property (nonatomic) bool showInterface;

@property (nonatomic, copy) void (^itemFocused)(id<TGModernGalleryItem>);
@property (nonatomic, copy) UIView *(^beginTransitionIn)(id<TGModernGalleryItem>, TGModernGalleryItemView *);
@property (nonatomic, copy) void (^finishedTransitionIn)(id<TGModernGalleryItem>, TGModernGalleryItemView *);
@property (nonatomic, copy) UIView *(^beginTransitionOut)(id<TGModernGalleryItem>);
@property (nonatomic, copy) void (^completedTransitionOut)();

- (void)dismissWhenReady;

- (bool)isFullyOpaque;

@end
