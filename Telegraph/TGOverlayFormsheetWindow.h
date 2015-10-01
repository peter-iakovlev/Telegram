#import <Foundation/Foundation.h>

@class TGViewController;

@interface TGOverlayFormsheetWindow : UIWindow

- (instancetype)initWithParentController:(TGViewController *)parentController contentController:(UIViewController *)contentController;

- (void)showAnimated:(bool)animated;
- (void)dismissAnimated:(bool)animated;

@end
