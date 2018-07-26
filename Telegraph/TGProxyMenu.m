#import "TGProxyMenu.h"
#import "TGLegacyComponentsContext.h"
#import "TGProxyWindow.h"
#import <LegacyComponents/TGMenuSheetController.h>

#import "TGProxyInfoItemView.h"
#import "TGProxyButtonItemView.h"
#import "TGProxySignals.h"

@implementation TGProxyMenu

+ (TGMenuSheetController *)presentInParentController:(TGViewController *)parentController menuController:(TGMenuSheetController *)menuController proxy:(TGProxyItem *)proxy sourceView:(UIView *)sourceView sourceRect:(CGRect (^)(void))sourceRect
{
    TGMenuSheetController *controller = nil;
    if (menuController == nil)
    {
        controller = [[TGMenuSheetController alloc] initWithContext:[TGLegacyComponentsContext shared] dark:false];
        controller.dismissesByOutsideTap = true;
        controller.hasSwipeGesture = true;
        controller.narrowInLandscape = true;
    }
    else
    {
        controller = menuController;
        controller.followsKeyboard = true;
    }
    controller.permittedArrowDirections = 0;
    controller.sourceRect = sourceRect;
    
    __weak TGMenuSheetController *weakController = controller;
    NSMutableArray *itemViews = [[NSMutableArray alloc] init];
    
    bool inactive = false;
    TGProxyItem *currentProxy = [TGProxySignals currentProxy:&inactive];
    
    if (proxy.secret.length > 0)
    {
        TGMenuSheetTitleItemView *textItem = [[TGMenuSheetTitleItemView alloc] initWithTitle:nil subtitle:TGLocalized(@"SocksProxySetup.AdNoticeHelp")];
        [itemViews addObject:textItem];
    }
    
    TGProxyInfoItemView *proxyItem = [[TGProxyInfoItemView alloc] initWithProxy:proxy];
    [itemViews addObject:proxyItem];
    
    __block bool connecting = false;
    __block bool cancelled = false;
    __block bool failed = false;
    TGProxyButtonItemView *connectAndSaveItem = [[TGProxyButtonItemView alloc] initWithTitle:TGLocalized(@"SocksProxySetup.ConnectAndSave") action:^(TGProxyButtonItemView *button)
    {
        if (failed)
        {
            __strong TGMenuSheetController *strongController = weakController;
            [strongController dismissAnimated:true manual:true];
            
            return;
        }
        
        connecting = true;
        dispatch_async(dispatch_get_main_queue(), ^
        {
            [button setConnecting];
        });
        
        [[[[[[[SSignal complete] delay:0.1 onQueue:[SQueue mainQueue]] then:[TGProxySignals connectionStatus]] filter:^bool(NSNumber *value) {
            return value.integerValue == TGConnectionStateNormal || value.integerValue == TGConnectionStateTimedOut;
        }] take:1] deliverOn:[SQueue mainQueue]] startWithNext:^(NSNumber *next)
        {
            if (cancelled)
                return;
            
            TGConnectionState state = (TGConnectionState)next.integerValue;
            if (state == TGConnectionStateNormal)
            {
                connecting = false;
                
                __strong TGMenuSheetController *strongController = weakController;
                [strongController dismissAnimated:true manual:false];
                
                [[[TGProxyWindow alloc] init] dismissWithSuccess];
                [TGProxySignals saveProxy:proxy];
            }
            else
            {
                failed = true;
                [button setFailed];
            }
        }];
        [TGProxySignals applyProxy:proxy inactive:false];
    }];
    [itemViews addObject:connectAndSaveItem];
    
    TGMenuSheetButtonItemView *cancelButton = [[TGMenuSheetButtonItemView alloc] initWithTitle:TGLocalized(@"Common.Cancel") type:TGMenuSheetButtonTypeCancel action:^
    {
        __strong TGMenuSheetController *strongController = weakController;
        [strongController dismissAnimated:true manual:true];
    }];
    [itemViews addObject:cancelButton];
    
    controller.willDismiss = ^(__unused bool manual)
    {
        if (connecting || failed)
        {
            cancelled = true;
            [TGProxySignals applyProxy:currentProxy inactive:inactive];
        }
    };
    
    if (menuController == nil)
    {
        [controller setItemViews:itemViews];
        [controller presentInViewController:parentController sourceView:sourceView animated:true];
    }
    else
    {
        [controller setItemViews:itemViews animated:true];
    }
    
    return controller;
}

@end
