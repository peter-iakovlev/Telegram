#import "TGApplication.h"

#import "TGAppDelegate.h"
#import "TGWebController.h"
#import "TGViewController.h"

#import "TGHacks.h"

@interface TGApplication ()
{
}

@end

@implementation TGApplication

- (id)init
{
    self = [super init];
    if (self != nil)
    {
    }
    return self;
}

- (BOOL)openURL:(NSURL *)url forceNative:(BOOL)forceNative
{
    NSString *absoluteString = [url.absoluteString lowercaseString];
    if ([absoluteString hasPrefix:@"tel:"] || [absoluteString hasPrefix:@"facetime:"])
    {
        [TGAppDelegateInstance performPhoneCall:url];
        
        return true;
    }
    
    bool useNative = forceNative;
    if (![absoluteString hasPrefix:@"http://"] && ![absoluteString hasPrefix:@"https://"])
        useNative = true;
    
    useNative = true;
    
    if (useNative)
        return [super openURL:url];
    
    if ([self.delegate isKindOfClass:[TGAppDelegate class]])
    {
        TGWebController *webController = [[TGWebController alloc] initWithUrl:[url absoluteString]];
        [TGAppDelegateInstance.mainNavigationController pushViewController:webController animated:true];
        return true;
    }
    
    return false;
}

- (BOOL)openURL:(NSURL *)url
{
    return [self openURL:url forceNative:false];
}

- (void)setStatusBarStyle:(UIStatusBarStyle)statusBarStyle
{
    [self setStatusBarStyle:statusBarStyle animated:false];
}

- (void)setStatusBarStyle:(UIStatusBarStyle)__unused statusBarStyle animated:(BOOL)__unused animated
{
}

- (void)setStatusBarHidden:(BOOL)statusBarHidden
{
    [self setStatusBarHidden:statusBarHidden withAnimation:UIStatusBarAnimationNone];
}

- (void)setStatusBarHidden:(BOOL)hidden withAnimation:(UIStatusBarAnimation)animation
{
    if (_processStatusBarHiddenRequests)
    {
        /*if (animation != UIStatusBarAnimationNone)
        {
            [TGHacks animateApplicationStatusBarAppearance:hidden ? TGStatusBarAppearanceAnimationSlideUp : TGStatusBarAppearanceAnimationSlideUp duration:0.3 completion:^
            {
                if (hidden)
                    [TGHacks setApplicationStatusBarAlpha:0.0f];
            }];
            
            if (!hidden)
                [TGHacks setApplicationStatusBarAlpha:1.0f];
        }
        else
        {
            [TGHacks setApplicationStatusBarAlpha:hidden ? 0.0f : 1.0f];
        }*/
        
        [self forceSetStatusBarHidden:hidden withAnimation:animation];
    }
}

- (void)forceSetStatusBarStyle:(UIStatusBarStyle)statusBarStyle animated:(BOOL)animated
{
    [super setStatusBarStyle:statusBarStyle animated:animated];
}

- (void)forceSetStatusBarHidden:(BOOL)hidden withAnimation:(UIStatusBarAnimation)animation
{
    [super setStatusBarHidden:hidden withAnimation:animation];
}

@end
