#import "TGCustomActionSheet.h"

#import "TGLegacyComponentsContext.h"
#import "TGAppDelegate.h"
#import <LegacyComponents/LegacyComponents.h>

#define UIViewParentController(__view) ({ \
UIResponder *__responder = __view; \
while ([__responder isKindOfClass:[UIView class]]) \
__responder = [__responder nextResponder]; \
(UIViewController *)__responder; \
})

@interface TGCustomActionSheet ()
{
    bool _usingExistingController;
}
@end

@implementation TGCustomActionSheet

- (instancetype)initWithTitle:(NSString *)title actions:(NSArray *)actions actionBlock:(void (^)(id target, NSString *action))actionBlock target:(id)target
{
    self = [super init];
    if (self != nil)
    {
        [[UIApplication sharedApplication] sendAction:@selector(resignFirstResponder) to:nil from:nil forEvent:nil];
        
        TGMenuSheetController *controller = [[TGMenuSheetController alloc] initWithContext:[TGLegacyComponentsContext shared] dark:false];
        _controller = controller;
        
        controller.dismissesByOutsideTap = true;
        controller.hasSwipeGesture = true;
        controller.permittedArrowDirections = UIPopoverArrowDirectionAny;
        
        __weak TGMenuSheetController *weakController = controller;
        NSMutableArray *itemViews = [[NSMutableArray alloc] init];
        if (title.length > 0)
            [itemViews addObject:[[TGMenuSheetTitleItemView alloc] initWithTitle:nil subtitle:title]];
        
        for (TGActionSheetAction *action in actions)
        {
            TGMenuSheetButtonType buttonType = TGMenuSheetButtonTypeDefault;
            if (action.type == TGActionSheetActionTypeDestructive)
                buttonType = TGMenuSheetButtonTypeDestructive;
            else if (action.type == TGActionSheetActionTypeCancel)
                buttonType = TGMenuSheetButtonTypeCancel;
            
            __weak id weakTarget = target;
            [itemViews addObject:[[TGMenuSheetButtonItemView alloc] initWithTitle:action.title type:buttonType action:^
            {
                __strong TGMenuSheetController *strongController = weakController;
                if (strongController != nil && !action.disableAutomaticSheetDismiss)
                    [strongController dismissAnimated:true];
                
                __strong id strongTarget = weakTarget;
                if (strongTarget == nil)
                    return;
                
                if (actionBlock != nil)
                    actionBlock(strongTarget, action.action);
            }]];
        }
        
        [controller setItemViews:itemViews];
    }
    return self;
}

- (instancetype)initWithTitle:(NSString *)title actions:(NSArray *)actions menuController:(TGMenuSheetController *)existingController advancedActionBlock:(void (^)(TGMenuSheetController *controller, id target, NSString *action))actionBlock target:(id)target
{
    self = [super init];
    if (self != nil)
    {
        [[UIApplication sharedApplication] sendAction:@selector(resignFirstResponder) to:nil from:nil forEvent:nil];
        
        TGMenuSheetController *controller = nil;
        if (existingController != nil) {
            controller = existingController;
            controller.requiuresDimView = true;
        } else {
            controller = [[TGMenuSheetController alloc] initWithContext:[TGLegacyComponentsContext shared] dark:false];
        }
        controller.dismissesByOutsideTap = true;
        controller.hasSwipeGesture = true;
        controller.permittedArrowDirections = UIPopoverArrowDirectionAny;
        _controller = controller;
        
        __weak TGMenuSheetController *weakController = controller;
        NSMutableArray *itemViews = [[NSMutableArray alloc] init];
        if (title.length > 0)
            [itemViews addObject:[[TGMenuSheetTitleItemView alloc] initWithTitle:nil subtitle:title]];
        
        for (TGActionSheetAction *action in actions)
        {
            TGMenuSheetButtonType buttonType = TGMenuSheetButtonTypeDefault;
            if (action.type == TGActionSheetActionTypeDestructive)
                buttonType = TGMenuSheetButtonTypeDestructive;
            else if (action.type == TGActionSheetActionTypeCancel)
                buttonType = TGMenuSheetButtonTypeCancel;
            
            __weak id weakTarget = target;
            [itemViews addObject:[[TGMenuSheetButtonItemView alloc] initWithTitle:action.title type:buttonType action:^
            {
                __strong TGMenuSheetController *strongController = weakController;
                if (strongController != nil && !action.disableAutomaticSheetDismiss)
                    [strongController dismissAnimated:true];
                
                __strong id strongTarget = weakTarget;
                if (strongTarget == nil)
                    return;
                
                if (actionBlock != nil)
                    actionBlock(strongController, strongTarget, action.action);
            }]];
        }
        
        [controller setItemViews:itemViews animated:existingController != nil];
        _usingExistingController = existingController != nil;
    }
    return self;
}

- (void)showInView:(UIView *)view
{
    if (_usingExistingController)
        return;
    [_controller presentInViewController:UIViewParentController(view) sourceView:view animated:true];
}

- (void)showFromRect:(CGRect)rect inView:(UIView *)view animated:(bool)animated
{
    _controller.sourceRect = ^CGRect{
        return rect;
    };
    if (_usingExistingController)
        return;
    [_controller presentInViewController:UIViewParentController(view) sourceView:view animated:animated];
}

@end
