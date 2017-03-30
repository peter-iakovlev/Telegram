#import "TGPaymentAlertController.h"

#import "TGArchivedStickerPacksAlert.h"

#import "TGOverlayController.h"

#import "TGPaymentAlertView.h"

@interface TGPaymentAlertController : TGOverlayController {
    TGPaymentAlertView *_view;
}

@end

@implementation TGPaymentAlertController

- (instancetype)initWithView:(TGPaymentAlertView *)view {
    self = [super init];
    if (self != nil) {
        _view = view;
    }
    return self;
}

- (void)loadView
{
    [super loadView];
    
    _view.frame = self.view.bounds;
    _view.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    [self.view addSubview:_view];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    [_view animateAppear];
}

- (void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    [super willAnimateRotationToInterfaceOrientation:toInterfaceOrientation duration:duration];
    
    [self.view.window.layer removeAnimationForKey:@"backgroundColor"];
    [CATransaction begin];
    [CATransaction setDisableActions:true];
    self.view.window.layer.backgroundColor = [UIColor clearColor].CGColor;
    [CATransaction commit];
    
    for (UIView *view in self.view.window.subviews)
    {
        if (view != self.view)
        {
            [view removeFromSuperview];
            break;
        }
    }
}

@end

@implementation TGPaymentAlert

- (instancetype)initWithParentController:(TGViewController *)parentController text:(NSString *)text {
    TGPaymentAlertView *alertView = [[TGPaymentAlertView alloc] init];
    alertView.controller = parentController;
    
    self = [super initWithParentController:parentController contentController:[[TGPaymentAlertController alloc] initWithView:alertView]];
    if (self != nil)
    {
        _view = alertView;
    }
    return self;
}

@end
