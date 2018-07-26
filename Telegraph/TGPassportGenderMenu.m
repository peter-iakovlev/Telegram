#import "TGPassportGenderMenu.h"

#import <LegacyComponents/TGMenuSheetController.h>

#import "TGPassportGenderItemView.h"

@implementation TGPassportGenderMenu

+ (TGMenuSheetController *)presentInParentController:(TGViewController *)parentController context:(id<LegacyComponentsContext>)context value:(NSNumber *)value completed:(void (^)(NSNumber *))completed dismissed:(void (^)(void))dismissed sourceView:(UIView *)sourceView sourceRect:(CGRect (^)(void))sourceRect
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
    
    TGPassportGenderItemView *genderItem = [[TGPassportGenderItemView alloc] initWithValue:value];
    [itemViews addObject:genderItem];
    
    __weak TGMenuSheetController *weakController = controller;
    __weak TGPassportGenderItemView *weakGenderItem = genderItem;
    TGMenuSheetButtonItemView *doneItem = [[TGMenuSheetButtonItemView alloc] initWithTitle:TGLocalized(@"Common.Done") type:TGMenuSheetButtonTypeSend action:^
    {
        __strong TGPassportGenderItemView *strongGenderItem = weakGenderItem;
        if (strongGenderItem != nil)
        {
            NSNumber *value = strongGenderItem.value;
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
