#import <UIKit/UIKit.h>

@interface TGChatActionsView : UIView

- (instancetype)initWithAvatarSnapshotView:(UIView *)avatarSnapshotView;

- (void)initializeAppearWithRect:(CGRect)rect;
- (void)dismiss;

- (void)_performDismissalWithRect:(CGRect)rect;

- (void)setTransitionProgress:(CGFloat)progress;
- (void)commitTransition;

@end
