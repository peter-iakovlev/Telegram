/*
 * This is the source code of Telegram for iOS v. 1.1
 * It is licensed under GNU GPL v. 2 or later.
 * You should have received a copy of the license in this archive (see LICENSE).
 *
 * Copyright Peter Iakovlev, 2013.
 */

#import <UIKit/UIKit.h>

#import "TGOverlayControllerWindow.h"

@interface TGProgressWindowController : TGOverlayWindowViewController

- (instancetype)init:(bool)light;
- (void)show:(bool)animated;
- (void)dismiss:(bool)animated completion:(void (^)())completion;

@end

@interface TGProgressWindow : UIWindow

@property (nonatomic, assign) bool skipMakeKeyWindowOnDismiss;

- (void)show:(bool)animated;
- (void)showWithDelay:(NSTimeInterval)delay;

- (void)showAnimated;
- (void)dismiss:(bool)animated;
- (void)dismissWithSuccess;

+ (void)changeStyle;

@end

