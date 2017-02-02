/*
 * This is the source code of Telegram for iOS v. 1.1
 * It is licensed under GNU GPL v. 2 or later.
 * You should have received a copy of the license in this archive (see LICENSE).
 *
 * Copyright Peter Iakovlev, 2013.
 */

#import <UIKit/UIKit.h>

@interface TGApplication : UIApplication

@property (nonatomic) bool processStatusBarHiddenRequests;

@property (nonatomic, strong) NSMutableDictionary *gameShareDict;

- (BOOL)openURL:(NSURL *)url forceNative:(BOOL)forceNative;
- (BOOL)openURL:(NSURL *)url forceNative:(BOOL)forceNative keepStack:(bool)keepStack;

- (BOOL)nativeOpenURL:(NSURL *)url;

- (void)forceSetStatusBarStyle:(UIStatusBarStyle)statusBarStyle animated:(BOOL)animated;
- (void)forceSetStatusBarHidden:(BOOL)hidden withAnimation:(UIStatusBarAnimation)animation;

@end
