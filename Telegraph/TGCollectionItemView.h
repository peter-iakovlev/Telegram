/*
 * This is the source code of Telegram for iOS v. 1.1
 * It is licensed under GNU GPL v. 2 or later.
 * You should have received a copy of the license in this archive (see LICENSE).
 *
 * Copyright Peter Iakovlev, 2013.
 */

#import <UIKit/UIKit.h>

#import "TGCollectionMenuSectionList.h"

typedef enum {
    TGCollectionItemViewPositionFirstInBlock = 1,
    TGCollectionItemViewPositionLastInBlock = 2,
    TGCollectionItemViewPositionMiddleInBlock = 4,
    TGCollectionItemViewPositionIncludeNextSeparator = 8
} TGCollectionItemViewPosition;

@class TGCollectionItem;
@class TGPresentation;

@interface TGCollectionItemView : UICollectionViewCell
{
    UIView *_topStripeView;
    UIView *_bottomStripeView;
    
    int _itemPosition;
}


@property (nonatomic) bool ignoreSeparatorInset;

@property (nonatomic) UIEdgeInsets safeAreaInset;
@property (nonatomic) CGFloat separatorInset;
@property (nonatomic) UIEdgeInsets selectionInsets;

@property (nonatomic, strong) TGCollectionItem *boundItem;
@property (nonatomic, strong) TGPresentation *presentation;

- (void)setItemPosition:(int)itemPosition;
- (void)setItemPosition:(int)itemPosition animated:(bool)animated;

@end
