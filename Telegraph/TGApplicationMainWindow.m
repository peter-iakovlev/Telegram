#import "TGApplicationMainWindow.h"

#import "TGViewController.h"

#import "UIViewController+Proxy.h"

#import <SSignalKit/SSignalKit.h>

@interface TGApplicationMainWindow () {
    NSMutableArray<TGViewController *> *_presentedControllers;
}

@end

@implementation TGApplicationMainWindow

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self != nil) {
        _presentedControllers = [[NSMutableArray alloc] init];
    }
    return self;
}

- (void)setBounds:(CGRect)bounds {
    [super setBounds:bounds];
}

- (void)presentOverlayController:(TGViewController * _Nonnull)controller {
    __weak TGApplicationMainWindow *weakSelf = self;
    __weak TGViewController *weakController = controller;
    [controller setProxyDismissBlock:^(__unused bool animated) {
        __strong TGApplicationMainWindow *strongSelf = weakSelf;
        __strong TGViewController *strongController = weakController;
        if (strongSelf != nil && strongController != nil) {
            NSUInteger index = [strongSelf->_presentedControllers indexOfObject:strongController];
            if (index != NSNotFound) {
                if ([strongController isViewLoaded]) {
                    [strongController viewWillDisappear:false];
                    [strongController.view removeFromSuperview];
                    [strongController viewDidDisappear:false];
                    [strongSelf->_presentedControllers removeObjectAtIndex:index];
                }
            }
        }
    }];
    [_presentedControllers addObject:controller];
    [self addSubview:controller.view];
    controller.view.frame = self.bounds;
    [controller viewWillAppear:false];
    [controller viewDidAppear:false];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    for (TGViewController *controller in _presentedControllers) {
        controller.view.frame = self.bounds;
    }
}

- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event {
    for (TGViewController *controller in _presentedControllers.reverseObjectEnumerator) {
        UIView *result = [controller.view hitTest:point withEvent:event];
        if (result != nil) {
            return result;
        }
    }
    return [super hitTest:point withEvent:event];
}

@end
