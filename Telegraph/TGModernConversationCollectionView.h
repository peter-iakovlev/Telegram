/*
 * This is the source code of Telegram for iOS v. 1.1
 * It is licensed under GNU GPL v. 2 or later.
 * You should have received a copy of the license in this archive (see LICENSE).
 *
 * Copyright Peter Iakovlev, 2013.
 */

#import <UIKit/UIKit.h>

#import "TGMessageRange.h"

@class TGModernViewStorage;

@interface TGModernConversationCollectionView : UICollectionView

@property (nonatomic) TGMessageRange unreadMessageRange;
@property (nonatomic, strong) UIView *headerView;

- (void)scrollToTopIfNeeded;

- (void)setDelayVisibleItemsUpdate:(bool)delay;
- (void)updateVisibleItemsNow;
- (bool)disableDecorationViewUpdates;
- (void)setDisableDecorationViewUpdates:(bool)disableDecorationViewUpdates;
- (bool)updateRelativeBounds;

- (UIView *)viewForDecorationAtIndex:(int)index;
- (NSArray *)visibleDecorations;
- (void)updateDecorationAssets;

- (bool)performBatchUpdates:(void (^)(void))updates completion:(void (^)(BOOL))completion beforeDecorations:(void (^)())beforeDecorations animated:(bool)animated animationFactor:(float)animationFactor;
- (bool)performBatchUpdates:(void (^)(void))updates completion:(void (^)(BOOL))completion beforeDecorations:(void (^)())beforeDecorations animated:(bool)animated animationFactor:(float)animationFactor insideAnimation:(void (^)())insideAnimation;

- (CGFloat)implicitTopInset;
- (void)updateHeaderView;

@end

@protocol TGModernConversationCollectionViewDelegate <UICollectionViewDelegate>

- (TGModernViewStorage *)viewStorage;

@end