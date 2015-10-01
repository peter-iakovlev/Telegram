/*
 * This is the source code of Telegram for iOS v. 1.1
 * It is licensed under GNU GPL v. 2 or later.
 * You should have received a copy of the license in this archive (see LICENSE).
 *
 * Copyright Peter Iakovlev, 2013.
 */

#import "TGRTL.h"

#import "TGHacks.h"
#import "TGViewController.h"
#import "TGNavigationController.h"
#import "TGNavigationBar.h"

#import <objc/runtime.h>
#import <objc/message.h>

@interface TGNavigationItemView : UIView

@end

@implementation TGNavigationItemView

- (id)initWithTGFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self != nil)
    {
        self.layer.sublayerTransform = CATransform3DMakeScale(-1.0, 1.0f, 1.0f);
    }
    return self;
}

@end

@interface TGNavigationButton : UIButton

@end

@implementation TGNavigationButton

- (id)initWithTGValue:(id)arg1 arg2:(float)arg2 arg3:(int)arg3 arg4:(int)arg4 arg5:(id)arg5 arg6:(id)arg6 arg7:(id)arg7 arg8:(BOOL)arg8 arg9:(int)arg9
{
    static id (*impl)(id, SEL, id, float, int, int, id, id, id, BOOL, int) = NULL;
    static SEL selector = NULL;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^
    {
        selector = NSSelectorFromString(TGEncodeText(@"jojuXjuiWbmvf;xjeui;tuzmf;cbsTuzmf;qpttjcmfUjumft;qpttjcmfTztufnJufnt;ujouDpmps;bqqmzCf{fm;gpsCvuupoJufnTuzmf;", -1));
        Method method = class_getInstanceMethod([TGNavigationButton class], @selector(initWithTGValue:arg2:arg3:arg4:arg5:arg6:arg7:arg8:arg9:));
        if (method != NULL)
        impl = (id (*)(id, SEL, id, float, int, int, id, id, id, BOOL, int))method_getImplementation(method);
    });
    
    if (impl != NULL)
        self = impl(self, selector, arg1, arg2, arg3, arg4, arg5, arg6, arg7, arg8, arg9);
    
    if (self != nil)
    {
        self.layer.sublayerTransform = CATransform3DMakeScale(-1.0, 1.0f, 1.0f);
    }
    return self;
}

@end

@interface UINavigationController (TGRTL)

@end

@implementation UINavigationController (TGRTL)

- (id)initWithTGNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [self initWithTGNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self != nil)
    {
        if (![self isKindOfClass:[TGNavigationController class]])
        {
            SEL selector = NSSelectorFromString(@"setNavigationBarClass:");
            if ([self respondsToSelector:selector])
            {
                ((void(*)(id, SEL, id))objc_msgSend)(self, selector, [TGNavigationBar class]);
            }
        }
    }
    return self;
}

@end

@implementation TGRTL

+ (void)doMagic
{
    if (iosMajorVersion() >= 7 && [TGViewController useExperimentalRTL])
    {
        InjectInstanceMethodFromAnotherClass(NSClassFromString(TGEncodeText(@"VJObwjhbujpoJufnWjfx", -1)), [TGNavigationItemView class], @selector(initWithTGFrame:), @selector(initWithFrame:));
        
        SwizzleInstanceMethodWithAnotherClass(NSClassFromString(TGEncodeText(@"VJObwjhbujpoCvuupo", -1)), NSSelectorFromString(TGEncodeText(@"jojuXjuiWbmvf;xjeui;tuzmf;cbsTuzmf;qpttjcmfUjumft;qpttjcmfTztufnJufnt;ujouDpmps;bqqmzCf{fm;gpsCvuupoJufnTuzmf;", -1)), [TGNavigationButton class], @selector(initWithTGValue:arg2:arg3:arg4:arg5:arg6:arg7:arg8:arg9:));
        
        SwizzleInstanceMethod([UINavigationController class], @selector(initWithNibName:bundle:), @selector(initWithTGNibName:bundle:));
    }
}

@end
