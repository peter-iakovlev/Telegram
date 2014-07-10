/*
 * This is the source code of Telegram for iOS v. 1.1
 * It is licensed under GNU GPL v. 2 or later.
 * You should have received a copy of the license in this archive (see LICENSE).
 *
 * Copyright Peter Iakovlev, 2013.
 */

#import <UIKit/UIKit.h>

#import "TGMessageRange.h"

#ifdef __cplusplus
#   import <vector>
#endif

@class TGMessageModernConversationItem;

typedef struct {
    int index;
    CGRect frame;
} TGDecorationViewAttrubutes;

#ifdef __cplusplus

struct TGDecorationViewAttrubutesComparator
{
    bool operator() (const TGDecorationViewAttrubutes &left, const TGDecorationViewAttrubutes &right)
    {
        return (left.frame.origin.y + left.frame.size.height) < (right.frame.origin.y + right.frame.size.height);
    }
};

#endif

@interface TGModernConversationViewLayout : UICollectionViewLayout

@property (nonatomic) bool animateLayout;

#ifdef __cplusplus
- (std::vector<TGDecorationViewAttrubutes> *)allDecorationViewAttributes;
- (NSArray *)layoutAttributesForItems:(NSArray *)items containerWidth:(CGFloat)containerWidth maxHeight:(CGFloat)maxHeight decorationViewAttributes:(std::vector<TGDecorationViewAttrubutes> *)decorationViewAttributes contentHeight:(CGFloat *)contentHeight;
+ (NSArray *)layoutAttributesForItems:(NSArray *)items containerWidth:(CGFloat)containerWidth maxHeight:(CGFloat)maxHeight dateOffset:(int)dateOffset decorationViewAttributes:(std::vector<TGDecorationViewAttrubutes> *)decorationViewAttributes contentHeight:(CGFloat *)contentHeight unreadMessageRange:(TGMessageRange)unreadMessageRange;
#endif

- (bool)hasLayoutAttributes;

@end

@protocol TGModernConversationViewLayoutDelegate <UICollectionViewDelegate>

- (NSArray *)items;

@end