#import <UIKit/UIKit.h>

#import "TGModernMediaListItemContentView.h"

@interface TGModernMediaListItemView : UICollectionViewCell

@property (nonatomic, copy) void (^recycleItemContentView)(TGModernMediaListItemContentView *);

@property (nonatomic, strong) TGModernMediaListItemContentView *itemContentView;

- (TGModernMediaListItemContentView *)_takeItemContentView;

@end
