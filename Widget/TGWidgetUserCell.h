#import <UIKit/UIKit.h>

@class SSignal;
@class TGWidgetUser;

@interface TGWidgetUserCell : UICollectionViewCell

- (void)setUser:(TGWidgetUser *)user avatarSignal:(SSignal *)avatarSignal effectView:(UIVisualEffectView *)effectView;
- (void)setHidden:(bool)hidden animated:(bool)animated;

@end

extern NSString *const TGWidgetUserCellIdentifier;
extern const CGSize TGWidgetUserCellSize;
