#import "TGViewController.h"

#import <SSignalKit/SSignalKit.h>

@class TGDialogListController;
@class TGContactsController;
@class TGAccountSettingsController;
@class TGRecentCallsController;
@class TGMainTabsController;
@class TGCallStatusBarView;

@interface TGRootController : TGViewController

@property (nonatomic, strong, readonly) TGMainTabsController *mainTabsController;
@property (nonatomic, strong, readonly) TGDialogListController *dialogListController;
@property (nonatomic, strong, readonly) TGContactsController *contactsController;
@property (nonatomic, strong) TGAccountSettingsController *accountSettingsController;
@property (nonatomic, strong, readonly) TGRecentCallsController *callsController;
@property (nonatomic, strong, readonly) TGCallStatusBarView *callStatusBarView;

- (SSignal *)sizeClass;
- (bool)isSplitView;
- (CGRect)applicationBounds;

- (bool)callStatusBarHidden;

- (void)pushContentController:(UIViewController *)contentController;
- (void)replaceContentController:(UIViewController *)contentController;
- (void)popToContentController:(UIViewController *)contentController;
- (void)clearContentControllers;
- (NSArray *)viewControllers;

- (void)localizationUpdated;

- (bool)isRTL;

@end
