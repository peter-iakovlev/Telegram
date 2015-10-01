#import "TGSingleStickerPreviewWindow.h"

#import "TGOverlayController.h"

@interface TGSingleStickerPreviewController : TGOverlayController
{
    TGSingleStickerPreviewView *_stickerPreviewView;
}

@end

@implementation TGSingleStickerPreviewController

- (instancetype)initWithStickerPreviewView:(TGSingleStickerPreviewView *)stickerPreviewView
{
    self = [super init];
    if (self != nil)
    {
        _stickerPreviewView = stickerPreviewView;
    }
    return self;
}

- (void)loadView
{
    [super loadView];
    
    _stickerPreviewView.frame = self.view.bounds;
    _stickerPreviewView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    [self.view addSubview:_stickerPreviewView];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    [_stickerPreviewView animateAppear];
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

@interface TGSingleStickerPreviewWindow ()

@end

@implementation TGSingleStickerPreviewWindow

- (instancetype)initWithParentController:(TGViewController *)parentController
{
    TGSingleStickerPreviewView *stickerPreviewView = [[TGSingleStickerPreviewView alloc] init];
    
    self = [super initWithParentController:parentController contentController:[[TGSingleStickerPreviewController alloc] initWithStickerPreviewView:stickerPreviewView] keepKeyboard:true];
    if (self != nil)
    {
        _view = stickerPreviewView;
        self.windowLevel = 100000000.0f;
    }
    return self;
}

@end
