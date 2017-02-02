#import "TGArchivedStickerPacksAlert.h"

#import "TGOverlayController.h"

@interface TGArchivedStickerPacksAlertController : TGOverlayController {
    TGArchivedStickerPacksAlertView *_archivedStickerPacksAlertView;
}

@end

@implementation TGArchivedStickerPacksAlertController

- (instancetype)initWithArchivedStickerPacksAlertView:(TGArchivedStickerPacksAlertView *)archivedStickerPacksAlertView {
    self = [super init];
    if (self != nil) {
        _archivedStickerPacksAlertView = archivedStickerPacksAlertView;
    }
    return self;
}

- (void)loadView
{
    [super loadView];
    
    _archivedStickerPacksAlertView.frame = self.view.bounds;
    _archivedStickerPacksAlertView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    [self.view addSubview:_archivedStickerPacksAlertView];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    [_archivedStickerPacksAlertView animateAppear];
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

@implementation TGArchivedStickerPacksAlert

- (instancetype)initWithParentController:(TGViewController *)parentController stickerPacks:(NSArray *)stickerPacks {
    TGArchivedStickerPacksAlertView *alertView = [[TGArchivedStickerPacksAlertView alloc] init];
    alertView.controller = parentController;
    
    self = [super initWithParentController:parentController contentController:[[TGArchivedStickerPacksAlertController alloc] initWithArchivedStickerPacksAlertView:alertView]];
    if (self != nil)
    {
        _view = alertView;
        [_view setStickerPacks:stickerPacks];
    }
    return self;
}

@end
