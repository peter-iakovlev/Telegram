#import "TGPreviewPresentationHelper.h"

#import "TGAppDelegate.h"
#import "TGPresentation.h"

@implementation TGPreviewPresentationHelper

+ (void)stylePreviewActionSheet
{
    [self _stylePreviewActionSheet:0];
}

+ (void)_stylePreviewActionSheet:(int)iteration
{
    if (iteration > 3)
        return;
    
    UIView *containerView = [[[[[UIApplication sharedApplication] windows] firstObject] subviews] lastObject];
    if (containerView == TGAppDelegateInstance.rootController.view)
    {
        TGDispatchAfter(0.1, dispatch_get_main_queue(), ^
        {
            [self _stylePreviewActionSheet:iteration + 1];
        });
        return;
    }
    
    UIView *sheetView = nil;
    for (UIView *view in containerView.subviews)
    {
        NSString *viewClass = NSStringFromClass([view class]);
        if ([viewClass rangeOfString:@"SheetView"].location != NSNotFound)
        {
            sheetView = view;
            break;
        }
    }
    
    if (sheetView != nil)
    {
        TGPresentation *presentation = TGPresentation.current;
        NSArray *labels = [self findViewsOfKind:[UILabel class] inView:sheetView];
        for (UILabel *label in labels)
        {
            label.textColor = presentation.pallete.menuAccentColor;
            label.tintColor = presentation.pallete.menuAccentColor;
        }
        
        if (presentation.pallete.isDark)
        {
            NSArray *effectViews = [self findViewsOfKind:[UIVisualEffectView class] inView:sheetView];
            for (UIVisualEffectView *effectView in effectViews)
            {
                effectView.effect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleDark];
            }
        }
    }
    else
    {
        TGDispatchAfter(0.1, dispatch_get_main_queue(), ^
        {
            [self _stylePreviewActionSheet:iteration + 1];
        });
    }
}

+ (NSArray *)findViewsOfKind:(Class)viewClass inView:(UIView *)parentView
{
    if (parentView.subviews.count == 0)
        return nil;
    
    NSMutableArray *views = [[NSMutableArray alloc] init];
    for (UIView *subview in parentView.subviews)
    {
        if ([subview isKindOfClass:viewClass])
            [views addObject:subview];
        else
            [views addObjectsFromArray:[self findViewsOfKind:viewClass inView:subview]];
    }
    return views;
}

@end
