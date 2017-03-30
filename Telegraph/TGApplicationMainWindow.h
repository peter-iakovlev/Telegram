#import <UIKit/UIKit.h>

@class TGViewController;

@interface TGApplicationMainWindow : UIWindow

- (void)presentOverlayController:(TGViewController * _Nonnull)controller;

@end
