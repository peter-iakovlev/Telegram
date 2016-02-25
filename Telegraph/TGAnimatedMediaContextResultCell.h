#import <UIKit/UIKit.h>

#import "TGBotContextResult.h"

@interface TGAnimatedMediaContextResultCellContents : UIView

@property (nonatomic, strong, readonly) TGBotContextResult *result;

@end

@interface TGAnimatedMediaContextResultCell : UICollectionViewCell

- (void)setResult:(TGBotContextResult *)result;

- (TGAnimatedMediaContextResultCellContents *)_takeContent;
- (void)_putContent:(TGAnimatedMediaContextResultCellContents *)content;
- (bool)hasContent;

@end
