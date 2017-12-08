#import <UIKit/UIKit.h>

#import <LegacyComponents/LegacyComponents.h>

@class TGPresentation;

@interface TGMainTabsController : UITabBarController <TGViewControllerNavigationBarAppearance, TGNavigationControllerTabsController>

@property (nonatomic, copy) void (^debugReady)(void);
@property (nonatomic, copy) void (^onControllerInsetUpdated)(CGFloat);

- (instancetype)initWithPresentation:(TGPresentation *)presentation;
- (void)setPresentation:(TGPresentation *)presentation;

- (void)setIgnoreKeyboardFrameChange:(bool)ignore restoringFocus:(bool)restoringFocus;

- (void)setUnreadCount:(int)unreadCount;
- (void)setMissedCallsCount:(int)callsCount;

- (void)setCallsHidden:(bool)hidden animated:(bool)animated;

- (void)localizationUpdated;

- (CGRect)frameForRightmostTab;
- (UIView *)viewForRightmostTab;

- (void)controllerInsetUpdated:(UIEdgeInsets)newInset;

@end
