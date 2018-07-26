#import <UIKit/UIKit.h>

#import <LegacyComponents/TGOverlayControllerWindow.h>

@interface TGProxyWindowController : TGOverlayWindowViewController

@end

@interface TGProxyWindow : UIWindow

- (void)dismissWithSuccess;
+ (void)setDarkStyle:(bool)dark;

@end


