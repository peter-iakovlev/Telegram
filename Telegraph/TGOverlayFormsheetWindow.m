#import "TGOverlayFormsheetWindow.h"

#import "TGViewController.h"
#import "TGOverlayFormsheetController.h"

#import "TGAppDelegate.h"

@interface TGOverlayFormsheetWindow ()
{
    __weak TGViewController *_parentController;
    UIViewController *_contentController;
    
    SMetaDisposable *_sizeClassDisposable;
    UIUserInterfaceSizeClass _sizeClass;
}
@end

@implementation TGOverlayFormsheetWindow

- (instancetype)initWithParentController:(TGViewController *)parentController contentController:(UIViewController *)contentController
{
    self = [super initWithFrame:[UIScreen mainScreen].bounds];
    if (self != nil)
    {
        self.windowLevel = parentController.view.window.windowLevel + 0.0001f;
        self.backgroundColor = [UIColor clearColor];
        
        _parentController = parentController;
        [parentController.associatedWindowStack addObject:self];
        
        _contentController = contentController;
        
        if (iosMajorVersion() < 9)
            [self createControllerIfNeeded];
    }
    return self;
}

- (void)dealloc
{
    [_sizeClassDisposable dispose];
}

- (void)createControllerIfNeeded
{
    if (self.rootViewController != nil)
        return;
    
    TGOverlayFormsheetController *controller = [[TGOverlayFormsheetController alloc] initWithContentController:_contentController];
    controller.formSheetWindow = self;
    self.rootViewController = controller;
    
    _contentController = nil;
}

- (void)updateSizeClass:(UIUserInterfaceSizeClass)sizeClass animated:(bool)animated
{
    if (_sizeClass == sizeClass)
        return;
    
    _sizeClass = sizeClass;
    
    if (sizeClass == UIUserInterfaceSizeClassCompact)
    {
        if ([self contentController].parentViewController != _parentController)
        {
            [[self contentController] removeFromParentViewController];
            [[self.contentController view] removeFromSuperview];
            
            [_parentController presentViewController:[self contentController] animated:animated completion:nil];
            self.hidden = true;
        }
    }
    else
    {
        if ([self controller] == nil || [self contentController].parentViewController != [self controller])
        {
            [self createControllerIfNeeded];
            
            [self.contentController.presentingViewController dismissViewControllerAnimated:false completion:^
            {
                [[self controller] setContentController:[self contentController]];
                self.hidden = false;
            }];
        }
    }
}

- (void)showAnimated:(bool)animated
{
    if (iosMajorVersion() >= 9)
    {
        UIUserInterfaceSizeClass sizeClass = TGAppDelegateInstance.rootController.traitCollection.horizontalSizeClass;

        if (sizeClass == UIUserInterfaceSizeClassCompact)
        {
            [self updateSizeClass:sizeClass animated:true];
        }
        else
        {
            [self createControllerIfNeeded];
            
            self.hidden = false;
            
            if (animated)
                [[self controller] animateInWithCompletion:nil];
        }
        
        __weak TGOverlayFormsheetWindow *weakSelf = self;
        _sizeClassDisposable = [[SMetaDisposable alloc] init];
        [_sizeClassDisposable setDisposable:[[TGAppDelegateInstance rootController].sizeClass startWithNext:^(NSNumber *next)
        {
            __strong TGOverlayFormsheetWindow *strongSelf = weakSelf;
            if (strongSelf == nil)
                return;
            
            [strongSelf updateSizeClass:next.integerValue animated:false];
        }]];
    }
    else
    {
        self.hidden = false;
        
        if (animated)
            [[self controller] animateInWithCompletion:nil];
    }
}

- (void)_dismiss
{
    TGViewController *parentController = _parentController;
    [parentController.associatedWindowStack removeObject:self];
    self.hidden = true;
}

- (void)dismissAnimated:(bool)animated
{
    if (animated)
    {
        [[self controller] animateOutWithCompletion:^
        {
            [self _dismiss];
        }];
    }
    else
    {
        [self _dismiss];
    }
}

- (UIViewController *)contentController
{
    if ([self controller] != nil)
        return [self controller].viewController;
    else
        return _contentController;
}

- (TGOverlayFormsheetController *)controller
{
    return  (TGOverlayFormsheetController *)self.rootViewController;
}
         
@end
