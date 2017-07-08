/*
 * This is the source code of Telegram for iOS v. 1.1
 * It is licensed under GNU GPL v. 2 or later.
 * You should have received a copy of the license in this archive (see LICENSE).
 *
 * Copyright Peter Iakovlev, 2013.
 */

#import <UIKit/UIKit.h>

typedef enum {
    TGNavigationControllerPresentationStyleDefault = 0,
    TGNavigationControllerPresentationStyleRootInPopover = 1,
    TGNavigationControllerPresentationStyleChildInPopover = 2,
    TGNavigationControllerPresentationStyleInFormSheet = 3
} TGNavigationControllerPresentationStyle;

@interface TGNavigationController : UINavigationController

@property (nonatomic) bool restrictLandscape;
@property (nonatomic) bool disableInteractiveKeyboardTransition;

@property (nonatomic) bool isInPopTransition;
@property (nonatomic) bool isInControllerTransition;

@property (nonatomic) TGNavigationControllerPresentationStyle presentationStyle;
@property (nonatomic) bool detachFromPresentingControllerInCompactMode;

@property (nonatomic, weak) UIPopoverController *parentPopoverController;

@property (nonatomic) bool displayPlayer;
@property (nonatomic) bool minimizePlayer;

@property (nonatomic) bool showCallStatusBar;

@property (nonatomic) CGFloat currentAdditionalNavigationBarHeight;

+ (TGNavigationController *)navigationControllerWithControllers:(NSArray *)controllers;
+ (TGNavigationController *)navigationControllerWithControllers:(NSArray *)controllers navigationBarClass:(Class)navigationBarClass;
+ (TGNavigationController *)navigationControllerWithRootController:(UIViewController *)controller;

- (void)setupNavigationBarForController:(UIViewController *)viewController animated:(bool)animated;

- (void)updateControllerLayout:(bool)animated;

- (void)acquireRotationLock;
- (void)releaseRotationLock;

@end

@protocol TGNavigationControllerItem <NSObject>

@required

- (bool)shouldBeRemovedFromNavigationAfterHiding;

@optional

- (bool)shouldRemoveAllPreviousControllers;

@end

@protocol TGBarItemSemantics <NSObject>

- (bool)backSemantics;

@optional

- (float)barButtonsOffset;

@end
