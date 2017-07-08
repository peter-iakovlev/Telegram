#import "TGRootController.h"

#import "TGAppDelegate.h"
#import "TGImageUtils.h"

#import "TGTabletMainView.h"
#import "TGNavigationController.h"

#import "TGDialogListController.h"
#import "TGTelegraphDialogListCompanion.h"
#import "TGContactsController.h"
#import "TGAccountSettingsController.h"
#import "TGRecentCallsController.h"
#import "TGMainTabsController.h"

#import "TGCallStatusBarView.h"
#import "TGVolumeBarView.h"

@interface TGRootController ()
{
    TGTabletMainView *_mainView;
    
    TGNavigationController *_masterNavigationController;
    TGNavigationController *_detailNavigationController;
    
    UIUserInterfaceSizeClass _currentSizeClass;
    
    SVariable *_sizeClassVariable;
    SMetaDisposable *_callDisposable;
}

@end

@implementation TGRootController

- (instancetype)init
{
    self = [super init];
    if (self != nil)
    {
        [self setNavigationBarHidden:true animated:false];
        self.automaticallyManageScrollViewInsets = false;
        
        TGTelegraphDialogListCompanion *dialogListCompanion = [[TGTelegraphDialogListCompanion alloc] init];
        dialogListCompanion.showBroadcastsMenu = true;
        _dialogListController = [[TGDialogListController alloc] initWithCompanion:dialogListCompanion];
        
        _contactsController = [[TGContactsController alloc] initWithContactsMode:TGContactsModeMainContacts | TGContactsModeRegistered | TGContactsModePhonebook | TGContactsModeSortByLastSeen];
        
        _accountSettingsController = [[TGAccountSettingsController alloc] initWithUid:0];
        
        __weak TGRootController *weakSelf = self;
        _callsController = [[TGRecentCallsController alloc] init];
        _callsController.missedCountChanged = ^(NSInteger count)
        {
            __strong TGRootController *strongSelf = weakSelf;
            if (strongSelf != nil)
                [strongSelf->_mainTabsController setMissedCallsCount:(int)count];
        };
        
        _mainTabsController = [[TGMainTabsController alloc] init];
        [_mainTabsController setViewControllers:[NSArray arrayWithObjects:_contactsController, _callsController, _dialogListController, _accountSettingsController, nil]];
        [_mainTabsController setSelectedIndex:2];
        [_mainTabsController setCallsHidden:!TGAppDelegateInstance.showCallsTab animated:false];
        
        _masterNavigationController = [TGNavigationController navigationControllerWithControllers:@[]];
        _detailNavigationController = [TGNavigationController navigationControllerWithControllers:@[]];
        [_detailNavigationController setDisplayPlayer:true];
        
        if (iosMajorVersion() >= 8)
        {
            _currentSizeClass = UIUserInterfaceSizeClassCompact;
        }
        else
        {
            switch ([UIDevice currentDevice].userInterfaceIdiom)
            {
                case UIUserInterfaceIdiomPad:
                    _currentSizeClass = UIUserInterfaceSizeClassRegular;
                    break;
                    
                default:
                    _currentSizeClass = UIUserInterfaceSizeClassCompact;
                    break;
            }
        }
        
        _sizeClassVariable = [[SVariable alloc] init];
        [_sizeClassVariable set:[SSignal single:@(_currentSizeClass)]];
    }
    return self;
}

- (bool)shouldAutorotate {
    if (self.associatedWindowStack.count > 0) {
        return [[self.associatedWindowStack.lastObject rootViewController] shouldAutorotate];
    }
    return [(UIViewController *)[self viewControllers].lastObject shouldAutorotate];
}

- (void)loadView
{
    [super loadView];
    
    self.view.backgroundColor = UIColorRGBA(0xf2f2f5, 1.0f);
    
    _mainView = [[TGTabletMainView alloc] initWithFrame:self.view.bounds];
    _mainView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    [self.view addSubview:_mainView];
    
    [self updateSizeClass];
    
    if (_masterNavigationController.viewControllers.count != 0) {
        [self addMasterController];
    }
    
    if (_detailNavigationController.viewControllers.count != 0) {
        [self addDetailController];
    }
    
    __weak TGRootController *weakSelf = self;
    _callStatusBarView = [[TGCallStatusBarView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 40)];
    _callStatusBarView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    _callStatusBarView.hidden = true;
    _callStatusBarView.visiblilityChanged = ^(bool hidden)
    {
        __strong TGRootController *strongSelf = weakSelf;
        if (strongSelf != nil)
        {
            [strongSelf->_masterNavigationController setShowCallStatusBar:!hidden];
            [strongSelf->_detailNavigationController setShowCallStatusBar:!hidden];
        }
    };
    
    if (!TGIsPad())
    {
        _volumeBarView = [[TGVolumeBarView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 16.0f)];
        _volumeBarView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    }
}

- (void)pushContentController:(UIViewController *)contentController {
    if (_detailNavigationController.viewControllers.count == 0) {
        [_detailNavigationController setViewControllers:@[contentController] animated:false];
        
        [self addDetailController];
    } else {
        [_detailNavigationController pushViewController:contentController animated:true];
    }
}

- (void)replaceContentController:(UIViewController *)contentController {
    if (_currentSizeClass == UIUserInterfaceSizeClassCompact) {
        bool addDetail = _detailNavigationController.viewControllers.count == 0;
        [_detailNavigationController setViewControllers:@[_mainTabsController, contentController] animated:true];
        if (addDetail) {
            [self addDetailController];
        }
    } else {
        bool addDetail = _detailNavigationController.viewControllers.count == 0;
        [_detailNavigationController setViewControllers:@[contentController] animated:false];
        if (addDetail) {
            [self addDetailController];
        }
    }
}

- (void)popToContentController:(UIViewController *)contentController {
    [_detailNavigationController popToViewController:contentController animated:true];
}

- (void)clearContentControllers {
    if (_currentSizeClass == UIUserInterfaceSizeClassCompact) {
        [_detailNavigationController popToRootViewControllerAnimated:true];
    } else if (_detailNavigationController.viewControllers.count != 0) {
        [_detailNavigationController setViewControllers:@[] animated:false];
        [self removeDetailController];
    }
}

- (NSArray *)viewControllers {
    return [_masterNavigationController.viewControllers arrayByAddingObjectsFromArray:_detailNavigationController.viewControllers];
}

- (void)traitCollectionDidChange:(UITraitCollection *)previousTraitCollection {
    [super traitCollectionDidChange:previousTraitCollection];
    
    if (_currentSizeClass != self.traitCollection.horizontalSizeClass && [UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPad) {
        _currentSizeClass = self.traitCollection.horizontalSizeClass;
        [self updateSizeClass];
        [_sizeClassVariable set:[SSignal single:@(_currentSizeClass)]];
    }
    
    //[self setNeedsStatusBarAppearanceUpdate];
}

- (void)updateSizeClass {
    if (_currentSizeClass == UIUserInterfaceSizeClassCompact) {
        [self removeMasterController];
        
        NSMutableArray *viewControllers = [[NSMutableArray alloc] init];
        if (_masterNavigationController.viewControllers.count != 0) {
            [viewControllers addObject:_masterNavigationController.viewControllers[0]];
        } else {
            [viewControllers addObject:_mainTabsController];
        }
        for (UIViewController *controller in _detailNavigationController.viewControllers) {
            if (![viewControllers containsObject:controller]) {
                [viewControllers addObject:controller];
            }
        }
        if (_masterNavigationController.viewControllers.count > 1) {
            for (NSUInteger i = 1; i < _masterNavigationController.viewControllers.count - 1; i++) {
                [viewControllers addObject:_masterNavigationController.viewControllers[i]];
            }
        }
        [_masterNavigationController setViewControllers:@[] animated:false];
        
        for (UIViewController *controller in [[NSArray alloc] initWithArray:_masterNavigationController.viewControllers]) {
            [controller willMoveToParentViewController:nil];
            [controller.view removeFromSuperview];
            [controller removeFromParentViewController];
            [controller didMoveToParentViewController:nil];
        }
        bool addDetail = _detailNavigationController.viewControllers.count == 0;
        [_detailNavigationController setViewControllers:viewControllers animated:false];
        if (addDetail) {
            [self addDetailController];
        }
        
        [_mainView setFullScreenDetail:true];
    } else {
        [_mainTabsController willMoveToParentViewController:nil];
        [_mainTabsController.view removeFromSuperview];
        [_mainTabsController removeFromParentViewController];
        [_mainTabsController didMoveToParentViewController:nil];
        
        NSMutableArray *viewControllers = [[NSMutableArray alloc] initWithArray:_detailNavigationController.viewControllers];
        [viewControllers removeObject:_mainTabsController];
        [_detailNavigationController setViewControllers:viewControllers animated:false];
        [_masterNavigationController setViewControllers:@[_mainTabsController] animated:false];
        
        if (_masterNavigationController.viewControllers.count != 0) {
            [self addMasterController];
        }
        
        if (_detailNavigationController.viewControllers.count == 0) {
            [self removeDetailController];
        } else {
            [self addDetailController];
        }
        
        [_mainView setFullScreenDetail:false];
    }
}

- (void)localizationUpdated {
    [_mainTabsController localizationUpdated];
}

- (void)removeDetailController {
    if (_detailNavigationController.parentViewController != nil) {
        [_detailNavigationController willMoveToParentViewController:nil];
        [_detailNavigationController removeFromParentViewController];
        [_mainView setDetailView:nil];
        [_detailNavigationController didMoveToParentViewController:nil];
    }
}

- (void)addDetailController {
    if (_detailNavigationController.parentViewController != self) {
        [_detailNavigationController willMoveToParentViewController:self];
        [self addChildViewController:_detailNavigationController];
        [_mainView setDetailView:_detailNavigationController.view];
        [_detailNavigationController didMoveToParentViewController:self];
    }
}

- (void)removeMasterController {
    if (_masterNavigationController.parentViewController != nil) {
        [_masterNavigationController willMoveToParentViewController:nil];
        [_masterNavigationController removeFromParentViewController];
        [_mainView setMasterView:nil];
        [_masterNavigationController didMoveToParentViewController:nil];
    }
}

- (void)addMasterController {
    if (_masterNavigationController.parentViewController != self) {
        [_masterNavigationController willMoveToParentViewController:self];
        [self addChildViewController:_masterNavigationController];
        [_mainView setMasterView:_masterNavigationController.view];
        [_masterNavigationController didMoveToParentViewController:self];
    }
}

- (UIStatusBarStyle)preferredStatusBarStyle
{
    if (_mainTabsController.presentedViewController != nil)
        return [_mainTabsController.presentedViewController preferredStatusBarStyle];
    
    if (_detailNavigationController.topViewController != nil) {
        return [_detailNavigationController.topViewController preferredStatusBarStyle];
    } else if (_masterNavigationController.topViewController != nil) {
        return [_masterNavigationController.topViewController preferredStatusBarStyle];
    } else {
        return [super preferredStatusBarStyle];
    }
}

- (BOOL)prefersStatusBarHidden
{
    //if (!TGIsPad() && UIInterfaceOrientationIsLandscape([UIApplication sharedApplication].statusBarOrientation))
    //    return true;
    
    return [super prefersStatusBarHidden];
}

- (SSignal *)sizeClass {
    return [_sizeClassVariable signal];
}

- (bool)isSplitView {
    if (iosMajorVersion() < 9 || !TGIsPad())
        return false;
    
    if (self.traitCollection.horizontalSizeClass == UIUserInterfaceSizeClassCompact)
        return true;
    
    if (fabs(self.view.frame.size.width - [UIScreen mainScreen].bounds.size.width) > FLT_EPSILON)
        return true;
    
    return false;
}

- (CGRect)applicationBounds {
    CGSize screenSize = TGScreenSize();
    CGFloat min = MIN(screenSize.width, screenSize.height);
    CGFloat max = MAX(screenSize.width, screenSize.height);
    
    CGSize size = CGSizeZero;
    CGSize (^sizeByDeviceOrientation)(void) = ^CGSize {
        if (UIInterfaceOrientationIsPortrait([UIApplication sharedApplication].statusBarOrientation))
            return CGSizeMake(min, max);
        else
            return CGSizeMake(max, min);
    };
    
    if (![self isSplitView])
        size = sizeByDeviceOrientation();
    else
        size = self.view.frame.size;
    
    return (CGRect){ CGPointZero, size };
}

- (UIUserInterfaceSizeClass)currentSizeClass {
    return _currentSizeClass;
}

- (bool)isRTL {
    static bool value = false;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        if (iosMajorVersion() >= 9) {
            value = [UIView userInterfaceLayoutDirectionForSemanticContentAttribute:[self.view semanticContentAttribute]] == UIUserInterfaceLayoutDirectionRightToLeft;
        }
    });
    return value;
}

- (bool)callStatusBarHidden
{
    if (_callStatusBarView != nil)
        return _callStatusBarView.realHidden;
    return true;
}

@end
