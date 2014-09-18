/*
 * This is the source code of Telegram for iOS v. 1.1
 * It is licensed under GNU GPL v. 2 or later.
 * You should have received a copy of the license in this archive (see LICENSE).
 *
 * Copyright Peter Iakovlev, 2013.
 */

#import <Foundation/Foundation.h>

@protocol TGAppManager <NSObject>

@property (nonatomic) bool keyboardVisible;
@property (nonatomic) float keyboardHeight;

@property (nonatomic) CFAbsoluteTime enteredBackgroundTime;

- (void)presentContentController:(UIViewController *)controller;
- (void)dismissContentController;

- (void)openURLNative:(NSURL *)url;

@end

@protocol TGApplicationImpl <NSObject>

- (void)setProcessStatusBarHiddenRequests:(bool)processStatusBarHiddenRequests;

@end
