#import "TGTabletMainViewController.h"

#import "TGTabletMainView.h"

@interface TGTabletMainViewController ()
{
    TGTabletMainView *_mainView;
}

@end

@implementation TGTabletMainViewController

- (instancetype)init
{
    self = [super init];
    if (self != nil)
    {
        [self setNavigationBarHidden:true animated:false];
        self.automaticallyManageScrollViewInsets = false;
    }
    return self;
}

- (void)loadView
{
    [super loadView];
    
    self.view.backgroundColor = UIColorRGBA(0xf2f2f5, 1.0f);
    
    _mainView = [[TGTabletMainView alloc] initWithFrame:self.view.bounds];
    _mainView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    [self.view addSubview:_mainView];
    
    if (_masterViewController != nil)
        [_mainView setMasterView:_masterViewController.view];
    
    if (_detailViewController != nil)
        [_mainView setDetailView:_detailViewController.view];
}

- (void)setMasterViewController:(TGViewController *)masterViewController
{
    if (_masterViewController != nil)
    {
        [_masterViewController willMoveToParentViewController:nil];
        if ([_masterViewController isViewLoaded])
            [_masterViewController.view removeFromSuperview];
        [_masterViewController removeFromParentViewController];
        [_masterViewController didMoveToParentViewController:nil];
    }
    
    _masterViewController = masterViewController;
    
    if (_masterViewController != nil)
    {
        [_masterViewController willMoveToParentViewController:self];
        [self addChildViewController:_masterViewController];
        if ([self isViewLoaded])
            [_mainView setMasterView:_masterViewController.view];
        [_masterViewController didMoveToParentViewController:self];
    }
}

- (void)setDetailViewController:(TGViewController *)detailViewController
{
    if (_detailViewController != nil)
    {
        [_detailViewController willMoveToParentViewController:nil];
        if ([_detailViewController isViewLoaded])
            [_detailViewController.view removeFromSuperview];
        [_detailViewController removeFromParentViewController];
        [_detailViewController didMoveToParentViewController:nil];
    }
    
    _detailViewController = detailViewController;
    
    if (_detailViewController != nil)
    {
        [_detailViewController willMoveToParentViewController:self];
        [self addChildViewController:_detailViewController];
        if ([self isViewLoaded])
            [_mainView setDetailView:_detailViewController.view];
        [_detailViewController didMoveToParentViewController:self];
    }
}

@end
