#import <UIKit/UIKit.h>

@class SSignal;
@class TGLegacyUser;

@interface TGWidgetUserCell : UICollectionViewCell

- (void)setUser:(TGLegacyUser *)user avatarSignal:(SSignal *)avatarSignal unreadCount:(NSUInteger)unreadCount effectView:(UIVisualEffectView *)effectView;
- (void)setHidden:(bool)hidden animated:(bool)animated;

@end

extern NSString *const TGWidgetUserCellIdentifier;
extern const CGSize TGWidgetUserCellSize;
extern const CGSize TGWidgetSmallUserCellSize;
