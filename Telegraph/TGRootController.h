#import "TGViewController.h"

#import <SSignalKit/SSignalKit.h>

@class TGDialogListController;
@class TGContactsController;
@class TGAccountSettingsController;
@class TGMainTabsController;

@interface TGRootController : TGViewController

@property (nonatomic, strong, readonly) TGMainTabsController *mainTabsController;
@property (nonatomic, strong, readonly) TGDialogListController *dialogListController;
@property (nonatomic, strong, readonly) TGContactsController *contactsController;
@property (nonatomic, strong) TGAccountSettingsController *accountSettingsController;

- (SSignal *)sizeClass;
- (bool)isSplitView;

- (void)pushContentController:(UIViewController *)contentController;
- (void)replaceContentController:(UIViewController *)contentController;
- (void)popToContentController:(UIViewController *)contentController;
- (void)clearContentControllers;
- (NSArray *)viewControllers;

- (void)localizationUpdated;

- (bool)isRTL;

@end
