/*
 * This is the source code of Telegram for iOS v. 1.1
 * It is licensed under GNU GPL v. 2 or later.
 * You should have received a copy of the license in this archive (see LICENSE).
 *
 * Copyright Peter Iakovlev, 2013.
 */

#import <Foundation/Foundation.h>

@class TGCollectionItemView;

@interface TGCollectionItem : NSObject

@property (nonatomic) bool highlightable;
@property (nonatomic) bool selectable;
@property (nonatomic) bool deselectAutomatically;
@property (nonatomic) bool transparent;
@property (nonatomic, copy) bool (^canBeMovedToSectionAtIndex)(NSUInteger, NSUInteger);

@property (nonatomic) TGCollectionItemView *view;

- (Class)itemViewClass;

- (TGCollectionItemView *)dequeueItemView:(UICollectionView *)collectionView registeredIdentifiers:(NSMutableSet *)registeredIdentifiers forIndexPath:(NSIndexPath *)indexPath;
- (CGSize)itemSizeForContainerSize:(CGSize)containerSize;

- (void)bindView:(TGCollectionItemView *)view;
- (void)unbindView;
- (TGCollectionItemView *)boundView;
- (void)itemSelected:(id)actionTarget;
- (bool)itemWantsMenu;
- (bool)itemCanPerformAction:(SEL)action;
- (void)itemPerformAction:(SEL)action;

@end
