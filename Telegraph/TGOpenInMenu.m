#import "TGOpenInMenu.h"

#import "TGViewController.h"
#import "TGMenuSheetController.h"

#import "TGOpenInCarouselItemView.h"
#import "TGOpenInAppItem.h"

#import "TGWebPageMediaAttachment.h"
#import "TGLocationMediaAttachment.h"

@implementation TGOpenInMenu

+ (TGMenuSheetController *)presentInParentController:(TGViewController *)parentController menuController:(TGMenuSheetController *)menuController title:(NSString *)title url:(NSURL *)url buttonTitle:(NSString *)buttonTitle buttonAction:(void (^)(void))buttonAction sourceView:(UIView *)sourceView sourceRect:(CGRect (^)(void))sourceRect barButtonItem:(UIBarButtonItem *)barButtonItem
{
    TGWebPageMediaAttachment *attachment = [[TGWebPageMediaAttachment alloc] init];
    attachment.url = url.absoluteString;
    
    return [self presentInParentController:parentController menuController:menuController title:title webPageAttachment:attachment buttonTitle:buttonTitle buttonAction:buttonAction sourceView:sourceView sourceRect:sourceRect barButtonItem:barButtonItem];
}

+ (bool)hasThirdPartyAppsForURL:(NSURL *)url
{
    TGWebPageMediaAttachment *attachment = [[TGWebPageMediaAttachment alloc] init];
    attachment.url = url.absoluteString;
    
    return [self hasThirdPartyAppsForWebPageAttachment:attachment];
}

+ (TGMenuSheetController *)presentInParentController:(TGViewController *)parentController menuController:(TGMenuSheetController *)menuController title:(NSString *)title webPageAttachment:(TGWebPageMediaAttachment *)attachment buttonTitle:(NSString *)buttonTitle buttonAction:(void (^)(void))buttonAction sourceView:(UIView *)sourceView sourceRect:(CGRect (^)(void))sourceRect barButtonItem:(UIBarButtonItem *)barButtonItem
{
    return [self presentInParentController:parentController menuController:menuController title:title webPageAttachment:attachment locationAttachment:nil directions:false buttonTitle:buttonTitle buttonAction:buttonAction sourceView:sourceView sourceRect:sourceRect barButtonItem:barButtonItem];
}

+ (bool)hasThirdPartyAppsForWebPageAttachment:(TGWebPageMediaAttachment *)attachment
{
    return ([TGOpenInAppItem appItemsForWebPageAttachment:attachment].count > 1);
}

+ (TGMenuSheetController *)presentInParentController:(TGViewController *)parentController menuController:(TGMenuSheetController *)menuController title:(NSString *)title locationAttachment:(TGLocationMediaAttachment *)attachment directions:(bool)directions buttonTitle:(NSString *)buttonTitle buttonAction:(void (^)(void))buttonAction sourceView:(UIView *)sourceView sourceRect:(CGRect (^)(void))sourceRect barButtonItem:(UIBarButtonItem *)barButtonItem
{
    return [self presentInParentController:parentController menuController:menuController title:title webPageAttachment:nil locationAttachment:attachment directions:directions buttonTitle:buttonTitle buttonAction:buttonAction sourceView:sourceView sourceRect:sourceRect barButtonItem:barButtonItem];
}

+ (bool)hasThirdPartyAppsForLocationAttachment:(TGLocationMediaAttachment *)attachment directions:(bool)directions
{
    return ([TGOpenInAppItem appItemsForLocationAttachment:attachment directions:directions].count > 1);
}

+ (TGMenuSheetController *)presentInParentController:(TGViewController *)parentController menuController:(TGMenuSheetController *)menuController title:(NSString *)title webPageAttachment:(TGWebPageMediaAttachment *)webPage locationAttachment:(TGLocationMediaAttachment *)location directions:(bool)directions buttonTitle:(NSString *)buttonTitle buttonAction:(void (^)(void))buttonAction sourceView:(UIView *)sourceView sourceRect:(CGRect (^)(void))sourceRect barButtonItem:(UIBarButtonItem *)barButtonItem
{
    TGMenuSheetController *controller = nil;
    if (menuController == nil)
    {
        controller = [[TGMenuSheetController alloc] init];
        controller.dismissesByOutsideTap = true;
        controller.hasSwipeGesture = true;
        controller.narrowInLandscape = true;
        controller.barButtonItem = barButtonItem;
    }
    else
    {
        controller = menuController;
    }
    
    if (sourceRect == nil)
    {
        controller.permittedArrowDirections = 0;
        sourceRect = ^CGRect
        {
            return CGRectMake(CGRectGetMidX(sourceView.frame), CGRectGetMidY(sourceView.frame), 0, 0);
        };
    }
    controller.sourceRect = sourceRect;
    
    NSMutableArray *itemViews = [[NSMutableArray alloc] init];
    
    NSArray *appItems = nil;
    if (webPage != nil)
        appItems = [TGOpenInAppItem appItemsForWebPageAttachment:webPage];
    else if (location != nil)
        appItems = [TGOpenInAppItem appItemsForLocationAttachment:location directions:directions];
    
    __weak TGMenuSheetController *weakController = controller;
    TGOpenInCarouselItemView *carouselItem = [[TGOpenInCarouselItemView alloc] initWithAppItems:appItems title:title];
    carouselItem.itemPressed = ^
    {
        __strong TGMenuSheetController *strongController = weakController;
        [strongController dismissAnimated:true manual:true];
    };
    [itemViews addObject:carouselItem];
    
    if (buttonTitle.length > 0)
    {
        TGMenuSheetButtonItemView *actionButton = [[TGMenuSheetButtonItemView alloc] initWithTitle:buttonTitle type:TGMenuSheetButtonTypeDefault action:^
        {
            if (buttonAction != nil)
                buttonAction();
        }];
        [itemViews addObject:actionButton];
    }
    
    TGMenuSheetButtonItemView *cancelButton = [[TGMenuSheetButtonItemView alloc] initWithTitle:TGLocalized(@"Common.Cancel") type:TGMenuSheetButtonTypeCancel action:^
    {
        __strong TGMenuSheetController *strongController = weakController;
        [strongController dismissAnimated:true manual:true];
    }];
    [itemViews addObject:cancelButton];
    
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
