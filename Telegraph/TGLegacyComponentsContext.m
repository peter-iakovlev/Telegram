#import "TGLegacyComponentsContext.h"

#import "TGAppDelegate.h"
#import "TGApplication.h"

#import "TGImageDownloadActor.h"

#import "TGActionSheet.h"

@interface TGLegacyComponentsOverlayWindowManager : NSObject <LegacyComponentsOverlayWindowManager>

@end

@implementation TGLegacyComponentsOverlayWindowManager

- (id<LegacyComponentsContext>)context {
    return [TGLegacyComponentsContext shared];
}

- (void)bindController:(UIViewController *)__unused controller {
}

- (bool)managesWindow {
    return false;
}

- (void)setHidden:(bool)hidden window:(UIWindow *)window {
    window.hidden = hidden;
}

@end

@implementation TGLegacyComponentsContext

+ (TGLegacyComponentsContext *)shared {
    static TGLegacyComponentsContext *instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[TGLegacyComponentsContext alloc] init];
    });
    return instance;
}

- (CGRect)fullscreenBounds {
    return [TGAppDelegateInstance.rootController applicationBounds];
}

- (UIEdgeInsets)safeAreaInset {
    if (iosMajorVersion() >= 11)
        return [TGAppDelegateInstance.rootController.view safeAreaInsets];
    else
        return UIEdgeInsetsZero;
}

- (TGKeyCommandController *)keyCommandController {
    return TGAppDelegateInstance.keyCommandController;
}

- (CGRect)statusBarFrame {
    return [[UIApplication sharedApplication] statusBarFrame];
}

- (bool)isStatusBarHidden {
    return [[UIApplication sharedApplication] isStatusBarHidden];
}

- (void)setStatusBarHidden:(BOOL)hidden withAnimation:(UIStatusBarAnimation)animation {
    [[UIApplication sharedApplication] setStatusBarHidden:hidden withAnimation:animation];
}

- (UIStatusBarStyle)statusBarStyle {
    return [[UIApplication sharedApplication] statusBarStyle];
}

- (void)setStatusBarStyle:(UIStatusBarStyle)statusBarStyle animated:(BOOL)animated {
    [[UIApplication sharedApplication] setStatusBarStyle:statusBarStyle animated:animated];
}

- (void)forceSetStatusBarHidden:(BOOL)hidden withAnimation:(UIStatusBarAnimation)animation {
    [(TGApplication *)[UIApplication sharedApplication] forceSetStatusBarHidden:hidden withAnimation:animation];
}

- (void)forceStatusBarAppearanceUpdate {
    static void (*methodImpl)(id, SEL) = NULL;
    static dispatch_once_t onceToken;
    static SEL methodSelector = NULL;
    dispatch_once(&onceToken, ^{
        methodImpl = (void (*)(id, SEL))freedomImpl([UIApplication sharedApplication], 0xa7a8dd8a, NULL);
    });
    
    if (methodImpl != NULL)
        methodImpl([UIApplication sharedApplication], methodSelector);
}

- (bool)currentlyInSplitView {
    return TGAppDelegateInstance.rootController.isSplitView;
}

- (UIUserInterfaceSizeClass)currentSizeClass {
    return [TGAppDelegateInstance.rootController currentSizeClass];
}
- (UIUserInterfaceSizeClass)currentHorizontalSizeClass {
    return TGAppDelegateInstance.rootController.traitCollection.horizontalSizeClass;
}

- (UIUserInterfaceSizeClass)currentVerticalSizeClass {
    return TGAppDelegateInstance.rootController.traitCollection.verticalSizeClass;
}

- (SSignal *)sizeClassSignal {
    return [TGAppDelegateInstance.rootController sizeClass];
}

- (bool)canOpenURL:(NSURL *)url {
    return [[UIApplication sharedApplication] canOpenURL:url];
}

- (void)openURL:(NSURL *)url {
    [[UIApplication sharedApplication] openURL:url];
}

- (NSDictionary *)serverMediaDataForAssetUrl:(NSString *)url {
    return [TGImageDownloadActor serverMediaDataForAssetUrl:url];
}

- (void)presentActionSheet:(NSArray<LegacyComponentsActionSheetAction *> *)actions view:(UIView *)view completion:(void (^)(LegacyComponentsActionSheetAction *))completion {
    NSMutableArray *convertedActions = [[NSMutableArray alloc] init];
    for (LegacyComponentsActionSheetAction *action in actions) {
        TGActionSheetActionType type;
        switch (action.type) {
            case LegacyComponentsActionSheetActionTypeGeneric:
                type = TGActionSheetActionTypeGeneric;
                break;
            case LegacyComponentsActionSheetActionTypeCancel:
                type = TGActionSheetActionTypeCancel;
                break;
            case LegacyComponentsActionSheetActionTypeDestructive:
                type = TGActionSheetActionTypeDestructive;
                break;
        }
        [convertedActions addObject:[[TGActionSheetAction alloc] initWithTitle:action.title action:action.action type:type]];
    }
    
    [[[TGActionSheet alloc] initWithTitle:nil actions:convertedActions actionBlock:^(__unused id target, NSString *action) {
        if (completion) {
            completion([[LegacyComponentsActionSheetAction alloc] initWithTitle:nil action:action]);
        }
    } target:self] showInView:view];
}

- (bool)rootCallStatusBarHidden {
    return TGAppDelegateInstance.rootController.callStatusBarHidden;
}

- (CGFloat)applicationStatusBarAlpha {
    CGFloat alpha = 1.0f;
    
    UIWindow *window = [[LegacyComponentsGlobals provider] applicationStatusBarWindow];
    if (window != nil) {
        alpha = window.alpha;
    }
    
    return alpha;
}

- (void)setApplicationStatusBarAlpha:(CGFloat)alpha {
    UIWindow *window = [[LegacyComponentsGlobals provider] applicationStatusBarWindow];
    window.alpha = alpha;
}

static UIView *findStatusBarView() {
    static Class viewClass = nil;
    static SEL selector = NULL;
    if (selector == NULL)
    {
        NSString *str1 = @"rs`str";
        NSString *str2 = @"A`qVhmcnv";
        
        selector = NSSelectorFromString([[NSString alloc] initWithFormat:@"%@%@", TGEncodeText(str1, 1), TGEncodeText(str2, 1)]);
        
        viewClass = NSClassFromString(TGEncodeText(@"VJTubuvtCbs", -1));
    }
    
    UIWindow *window = [[LegacyComponentsGlobals provider] applicationStatusBarWindow];
    
    for (UIView *subview in window.subviews)
    {
        if ([subview isKindOfClass:viewClass])
        {
            return subview;
        }
    }
    
    return nil;
}

- (void)animateApplicationStatusBarAppearance:(int)statusBarAnimation duration:(NSTimeInterval)duration completion:(void (^)())completion
{
    [self animateApplicationStatusBarAppearance:statusBarAnimation delay:0.0 duration:duration completion:completion];
}

- (void)animateApplicationStatusBarAppearance:(int)statusBarAnimation delay:(NSTimeInterval)delay duration:(NSTimeInterval)duration completion:(void (^)())completion
{
    UIView *view = findStatusBarView();
    
    if (view != nil)
    {
        if ((statusBarAnimation & TGStatusBarAppearanceAnimationSlideDown) || (statusBarAnimation & TGStatusBarAppearanceAnimationSlideUp))
        {
            CGPoint startPosition = view.layer.position;
            CGPoint position = view.layer.position;
            
            CGPoint normalPosition = CGPointMake(CGFloor(view.frame.size.width / 2), CGFloor(view.frame.size.height / 2));
            
            CGFloat viewHeight = view.frame.size.height;
            
            if (statusBarAnimation & TGStatusBarAppearanceAnimationSlideDown)
            {
                startPosition = CGPointMake(CGFloor(view.frame.size.width / 2), CGFloor(view.frame.size.height / 2) - viewHeight);
                position = CGPointMake(CGFloor(view.frame.size.width / 2), CGFloor(view.frame.size.height / 2));
            }
            else if (statusBarAnimation & TGStatusBarAppearanceAnimationSlideUp)
            {
                startPosition = CGPointMake(CGFloor(view.frame.size.width / 2), CGFloor(view.frame.size.height / 2));
                position = CGPointMake(CGFloor(view.frame.size.width / 2), CGFloor(view.frame.size.height / 2) - viewHeight);
            }
            
            CABasicAnimation *animation = [[CABasicAnimation alloc] init];
            animation.duration = duration;
            animation.fromValue = [NSValue valueWithCGPoint:startPosition];
            animation.toValue = [NSValue valueWithCGPoint:position];
            animation.removedOnCompletion = true;
            animation.fillMode = kCAFillModeForwards;
            animation.beginTime = delay;
            animation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
            
            TGAnimationBlockDelegate *delegate = [[TGAnimationBlockDelegate alloc] initWithLayer:view.layer];
            delegate.completion = ^(BOOL finished)
            {
                if (finished)
                    view.layer.position = normalPosition;
                if (completion)
                    completion();
            };
            animation.delegate = delegate;
            [view.layer addAnimation:animation forKey:@"position"];
            
            view.layer.position = position;
        }
        else if ((statusBarAnimation & TGStatusBarAppearanceAnimationFadeIn) || (statusBarAnimation & TGStatusBarAppearanceAnimationFadeOut))
        {
            float startOpacity = view.layer.opacity;
            float opacity = view.layer.opacity;
            
            if (statusBarAnimation & TGStatusBarAppearanceAnimationFadeIn)
            {
                startOpacity = 0.0f;
                opacity = 1.0f;
            }
            else if (statusBarAnimation & TGStatusBarAppearanceAnimationFadeOut)
            {
                startOpacity = 1.0f;
                opacity = 0.0f;
            }
            
            CABasicAnimation *animation = [[CABasicAnimation alloc] init];
            animation.duration = duration;
            animation.fromValue = @(startOpacity);
            animation.toValue = @(opacity);
            animation.removedOnCompletion = true;
            animation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
            TGAnimationBlockDelegate *delegate = [[TGAnimationBlockDelegate alloc] initWithLayer:view.layer];
            delegate.completion = ^(__unused BOOL finished)
            {
                if (completion)
                    completion();
            };
            animation.delegate = delegate;
            
            [view.layer addAnimation:animation forKey:@"opacity"];
        }
    }
    else
    {
        if (completion)
            completion();
    }
}

- (void)animateApplicationStatusBarStyleTransitionWithDuration:(NSTimeInterval)duration {
    UIView *view = findStatusBarView();
    
    if (view != nil)
    {
        UIView *snapshotView = [view snapshotViewAfterScreenUpdates:false];
        [view addSubview:snapshotView];
        
        [UIView animateWithDuration:duration animations:^
         {
             snapshotView.alpha = 0.0f;
         } completion:^(__unused BOOL finished)
         {
             [snapshotView removeFromSuperview];
         }];
    }
}

- (id<LegacyComponentsOverlayWindowManager>)makeOverlayWindowManager {
    return [[TGLegacyComponentsOverlayWindowManager alloc] init];
}

@end
