/*
 * This is the source code of Telegram for iOS v. 1.1
 * It is licensed under GNU GPL v. 2 or later.
 * You should have received a copy of the license in this archive (see LICENSE).
 *
 * Copyright Peter Iakovlev, 2013.
 */

#import <UIKit/UIKit.h>

@class TGCollectionMenuView;

@protocol TGCollectionMenuViewDelegate <UICollectionViewDelegate>

@optional

- (void)collectionMenuViewDidEnterEditingMode:(TGCollectionMenuView *)collectionMenuView;
- (void)collectionMenuViewDidLeaveEditingMode:(TGCollectionMenuView *)collectionMenuView;

@end

@interface TGCollectionMenuView : UICollectionView

@property (nonatomic) bool editing;
@property (nonatomic) bool allowEditingCells;

@property (nonatomic, copy) void (^layoutForSize)(CGSize size);

- (void)setEditing:(bool)editing animated:(bool)animated;
- (void)setAllowEditingCells:(bool)allowEditingCells animated:(bool)animated;

- (void)_setEditingCell:(id)cell editing:(bool)editing;
- (void)_selectCell:(id)cell;
- (void)setupCellForEditing:(UICollectionViewCell *)cell;
- (void)updateVisibleItemsNow;

@end
