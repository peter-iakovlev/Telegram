/*
 * This is the source code of Telegram for iOS v. 1.1
 * It is licensed under GNU GPL v. 2 or later.
 * You should have received a copy of the license in this archive (see LICENSE).
 *
 * Copyright Peter Iakovlev, 2013.
 */

#import "TGViewController.h"

#import "TGCollectionMenuSectionList.h"
#import "TGCollectionMenuLayout.h"
#import "TGCollectionItemView.h"
#import "TGCollectionMenuView.h"

@interface TGCollectionMenuController : TGViewController

@property (nonatomic, strong) TGCollectionMenuSectionList *menuSections;

@property (nonatomic, strong) TGCollectionMenuView *collectionView;
@property (nonatomic, strong) TGCollectionMenuLayout *collectionLayout;
@property (nonatomic) bool enableItemReorderingGestures;

- (void)_resetCollectionView;
- (NSIndexPath *)indexPathForItem:(TGCollectionItem *)item;
- (NSUInteger)indexForSection:(TGCollectionMenuSection *)section;

- (void)enterEditingMode:(bool)animated;
- (void)leaveEditingMode:(bool)animated;

- (void)didEnterEditingMode:(bool)animated;
- (void)didLeaveEditingMode:(bool)animated;

- (void)updateItemPositions;

- (void)animateCollectionCrossfade;

- (void)loadMore;

- (void)willDisplayItem:(TGCollectionItem *)item;

@end
