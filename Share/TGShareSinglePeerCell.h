#import <UIKit/UIKit.h>

@class TGUserModel;
@class TGShareContext;

@interface TGShareSinglePeerCell : UICollectionViewCell

- (void)setPeer:(TGUserModel *)peer shareContext:(TGShareContext *)shareContext;

- (void)setChecked:(bool)checked;
- (void)setChecked:(bool)checked animated:(bool)animated;

@end
