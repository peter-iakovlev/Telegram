#import <UIKit/UIKit.h>

#import "TGBotContextResult.h"

@interface TGAnimatedMediaContextResultCellContents : UIView

@property (nonatomic, strong, readonly) TGBotContextResult *result;

@end

@interface TGAnimatedMediaContextResultCell : UICollectionViewCell

@property (nonatomic, strong) TGBotContextResult *result;

- (TGAnimatedMediaContextResultCellContents *)_takeContent;
- (void)_putContent:(TGAnimatedMediaContextResultCellContents *)content;
- (bool)hasContent;

- (void)setHighlighted:(bool)highlighted animated:(bool)animated;

@end
