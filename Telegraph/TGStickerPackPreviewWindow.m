#import "TGStickerPackPreviewWindow.h"

#import "TGOverlayController.h"

@interface TGStickerPackPreviewController : TGOverlayController
{
    TGStickerPackPreviewView *_stickerPackPreviewView;
}

@end

@implementation TGStickerPackPreviewController

- (instancetype)initWithStickerPackPreviewView:(TGStickerPackPreviewView *)stickerPackPreviewView
{
    self = [super init];
    if (self != nil)
    {
        _stickerPackPreviewView = stickerPackPreviewView;
    }
    return self;
}

- (void)loadView
{
    [super loadView];
    
    _stickerPackPreviewView.frame = self.view.bounds;
    _stickerPackPreviewView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    [self.view addSubview:_stickerPackPreviewView];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    [_stickerPackPreviewView animateAppear];
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

@implementation TGStickerPackPreviewWindow

- (instancetype)initWithParentController:(TGViewController *)parentController stickerPack:(TGStickerPack *)stickerPack
{
    TGStickerPackPreviewView *stickerPackPreviewView = [[TGStickerPackPreviewView alloc] init];
    
    self = [super initWithParentController:parentController contentController:[[TGStickerPackPreviewController alloc] initWithStickerPackPreviewView:stickerPackPreviewView]];
    if (self != nil)
    {
        _view = stickerPackPreviewView;
        [_view setStickerPack:stickerPack];
    }
    return self;
}

@end
