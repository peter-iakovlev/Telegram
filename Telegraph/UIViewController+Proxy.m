#import "UIViewController+Proxy.h"

#import "TGHacks.h"
#import <objc/runtime.h>

static const void *TGProxyDismissControllerKey = &TGProxyDismissControllerKey;

@interface TGProxyPresentingController : UIViewController

@property (nonatomic, copy, readonly) void (^block)(bool);

@end

@implementation TGProxyPresentingController

- (instancetype)initWithBlock:(void (^)(bool))block {
    self = [super init];
    if (self != nil) {
        _block = [block copy];
    }
    return self;
}

- (void)dismissViewControllerAnimated:(BOOL)flag completion:(void (^)(void))completion {
    if (_block) {
        _block(flag);
        if (completion) {
            completion();
        }
    }
}

@end

@implementation UIViewController (Proxy)

+ (void)load {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        SwizzleInstanceMethod([UIViewController class], @selector(presentingViewController), @selector(_proxy_presentingViewController));
    });
}

- (void)setProxyDismissBlock:(void (^)(bool))block {
    objc_setAssociatedObject(self, TGProxyDismissControllerKey, [[TGProxyPresentingController alloc] initWithBlock:[block copy]], OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (UIViewController *)_proxy_presentingViewController {
    TGProxyPresentingController *controller = objc_getAssociatedObject(self, TGProxyDismissControllerKey);
    if (controller != nil) {
        return controller;
    }
    return [self _proxy_presentingViewController];
}

@end
