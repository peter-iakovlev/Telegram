/*
 * This is the source code of Telegram for iOS v. 1.1
 * It is licensed under GNU GPL v. 2 or later.
 * You should have received a copy of the license in this archive (see LICENSE).
 *
 * Copyright Peter Iakovlev, 2013.
 */

#import "TGModernCollectionCell.h"

#import "TGModernViewStorage.h"

@class TGModernCollectionCell;
@class TGModernViewModel;

typedef enum {
    TGModernConversationItemCollapseTop = 1,
    TGModernConversationItemCollapseBottom = 2
} TGModernConversationItemCollapseFlags;

@interface TGModernConversationItem : NSObject
{
    int _collapseFlags;
}

@property (nonatomic) int collapseFlags;

- (bool)collapseWithItem:(TGModernConversationItem *)item forContainerSize:(CGSize)containerSize;

- (Class)cellClass;
- (TGModernCollectionCell *)dequeueCollectionCell:(UICollectionView *)collectionView registeredIdentifiers:(NSMutableSet *)registeredIdentifiers forIndexPath:(NSIndexPath *)indexPath;

- (void)bindCell:(TGModernCollectionCell *)cell viewStorage:(TGModernViewStorage *)viewStorage;
- (void)unbindCell:(TGModernViewStorage *)viewStorage;
- (void)moveToCell:(TGModernCollectionCell *)cell;
- (void)temporaryMoveToView:(UIView *)view;
- (TGModernCollectionCell *)boundCell;

- (TGModernViewModel *)viewModel;
- (void)bindSpecialViewsToContainer:(UIView *)container viewStorage:(TGModernViewStorage *)viewStorage atItemPosition:(CGPoint)itemPosition;
- (void)drawInContext:(CGContextRef)context;

- (CGSize)sizeForContainerSize:(CGSize)containerSize viewStorage:(TGModernViewStorage *)viewStorage;

- (void)updateToItem:(TGModernConversationItem *)updatedItem viewStorage:(TGModernViewStorage *)viewStorage sizeChanged:(bool *)sizeChanged delayAvailability:(bool)delayAvailability containerSize:(CGSize)containerSize;
- (void)updateProgress:(float)progress viewStorage:(TGModernViewStorage *)viewStorage animated:(bool)animated;
- (void)updateInlineMediaContext;
- (void)updateAnimationsEnabled;
- (void)stopInlineMedia:(int32_t)excludeMid;
- (void)resumeInlineMedia;

@end
