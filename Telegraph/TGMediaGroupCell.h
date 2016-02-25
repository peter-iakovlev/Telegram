#import <UIKit/UIKit.h>

@class TGMediaAssetGroup;

@interface TGMediaGroupCell : UITableViewCell

@property (nonatomic, readonly) TGMediaAssetGroup *assetGroup;

- (void)configureForAssetGroup:(TGMediaAssetGroup *)assetGroup;

@end

extern NSString *const TGMediaGroupCellKind;
extern const CGFloat TGMediaGroupCellHeight;
