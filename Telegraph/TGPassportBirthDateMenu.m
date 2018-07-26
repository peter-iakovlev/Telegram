#import "TGPassportBirthDateMenu.h"

#import <LegacyComponents/TGMenuSheetController.h>

#import "TGPassportBirthDateItemView.h"

@implementation TGPassportBirthDateMenu

+ (TGMenuSheetController *)presentInParentController:(TGViewController *)parentController context:(id<LegacyComponentsContext>)context title:(NSString *)title value:(NSDate *)value minValue:(NSDate *)minValue maxValue:(NSDate *)maxValue optional:(bool)optional completed:(void (^)(NSDate *))completed dismissed:(void (^)(void))dismissed sourceView:(UIView *)sourceView sourceRect:(CGRect (^)(void))sourceRect
{
    TGMenuSheetController *controller = [[TGMenuSheetController alloc] initWithContext:context dark:false];
    controller.dismissesByOutsideTap = true;
    controller.hasSwipeGesture = true;
    controller.narrowInLandscape = true;
    controller.sourceRect = sourceRect;
    controller.permittedArrowDirections = (UIPopoverArrowDirectionUp | UIPopoverArrowDirectionDown);
    controller.willDismiss = ^(__unused bool manual)
    {
        if (dismissed != nil)
            dismissed();
    };
    
    NSMutableArray *itemViews = [[NSMutableArray alloc] init];
    
    if (title.length > 0)
    {
        TGMenuSheetTitleItemView *titleItem = [[TGMenuSheetTitleItemView alloc] initWithTitle:title subtitle:nil];
        [itemViews addObject:titleItem];
    }
    
    TGPassportBirthDateItemView *birthDateItem = [[TGPassportBirthDateItemView alloc] initWithValue:value minValue:minValue maxValue:maxValue];
    [itemViews addObject:birthDateItem];
    
    __weak TGMenuSheetController *weakController = controller;
    
    if (optional)
    {
        TGMenuSheetButtonItemView *optionalItem = [[TGMenuSheetButtonItemView alloc] initWithTitle:TGLocalized(@"Passport.Identity.DoesNotExpire") type:TGMenuSheetButtonTypeDefault action:^
        {
            completed(nil);
        
            __strong TGMenuSheetController *strongController = weakController;
            [strongController dismissAnimated:true];
        }];
         [itemViews addObject:optionalItem];
    }
    
    __weak TGPassportBirthDateItemView *weakBirthDateItem = birthDateItem;
    TGMenuSheetButtonItemView *doneItem = [[TGMenuSheetButtonItemView alloc] initWithTitle:TGLocalized(@"Common.Done") type:TGMenuSheetButtonTypeSend action:^
    {
        __strong TGPassportBirthDateItemView *strongBirthDateItem = weakBirthDateItem;
        if (strongBirthDateItem != nil)
        {
            NSDate *value = strongBirthDateItem.value;
            completed(value);
        }
        
        __strong TGMenuSheetController *strongController = weakController;
        [strongController dismissAnimated:true];
    }];
    [itemViews addObject:doneItem];
    
    [controller setItemViews:itemViews animated:false];
    [controller presentInViewController:(UIViewController *)parentController sourceView:sourceView animated:true];
    
    return controller;
}

@end
