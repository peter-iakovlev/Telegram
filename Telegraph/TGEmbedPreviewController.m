#import "TGEmbedPreviewController.h"

#import "TGEmbedPreviewView.h"

@interface TGEmbedPreviewController ()
{
    TGWebPageMediaAttachment *_webPage;
    TGEmbedPreviewView *_view;
}

@end

@implementation TGEmbedPreviewController

- (instancetype)initWithWebPage:(TGWebPageMediaAttachment *)webPage
{
    self = [super init];
    if (self != nil)
    {
        _webPage = webPage;
    }
    return self;
}

- (void)loadView
{
    [super loadView];
    
    _view = [[TGEmbedPreviewView alloc] initWithFrame:self.view.bounds webPage:_webPage];
    __weak TGEmbedPreviewController *weakSelf = self;
    _view.dismiss = ^
    {
        __strong TGEmbedPreviewController *strongSelf = weakSelf;
        if (strongSelf != nil)
        {
            [strongSelf->_view animateOut:^
            {
                __strong TGEmbedPreviewController *strongSelf = weakSelf;
                [strongSelf dismiss];
            }];
        }
    };
    _view.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    [self.view addSubview:_view];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    [_view animateIn];
}

@end
