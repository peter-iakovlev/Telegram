#import "TGMusicPlayerController.h"

#import "TGMusicPlayerCompleteView.h"
#import "TGTelegraph.h"

#import "TGPreparedLocalDocumentMessage.h"

@interface TGMusicPlayerController ()
{
    TGMusicPlayerCompleteView *_view;
    UIBarButtonItem *_shareItem;
    
    SMetaDisposable *_statusDisposable;
}

@end

@implementation TGMusicPlayerController

- (instancetype)init
{
    self = [super init];
    if (self != nil)
    {
        [self setLeftBarButtonItem:[[UIBarButtonItem alloc] initWithTitle:TGLocalized(@"Common.Close") style:UIBarButtonItemStylePlain target:self action:@selector(closePressed)]];
        _shareItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAction target:self action:@selector(sharePressed)];
        [self setRightBarButtonItem:_shareItem];
        _shareItem.enabled = true;
        _statusDisposable = [[SMetaDisposable alloc] init];
    }
    return self;
}

- (void)dealloc {
    [_statusDisposable dispose];
}

- (void)loadView
{
    [super loadView];
    
    self.view.backgroundColor = [UIColor whiteColor];
    
    __weak TGMusicPlayerController *weakSelf = self;
    _view = [[TGMusicPlayerCompleteView alloc] initWithFrame:self.view.bounds setTitle:^(NSString *title)
    {
        __strong TGMusicPlayerController *strongSelf = weakSelf;
        if (strongSelf != nil)
            strongSelf.title = title;
    } actionsEnabled:^(bool enabled) {
        __strong TGMusicPlayerController *strongSelf = weakSelf;
        if (strongSelf != nil) {
            strongSelf->_shareItem.enabled = enabled;
        }
    }];
    _view.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    [self.view addSubview:_view];
    
    if (![self _updateControllerInset:false])
        [self controllerInsetUpdated:UIEdgeInsetsZero];
}

- (void)controllerInsetUpdated:(UIEdgeInsets)previousInset
{
    _view.topInset = self.controllerInset.top;
    
    [super controllerInsetUpdated:previousInset];
}

- (void)closePressed
{
    [self.presentingViewController dismissViewControllerAnimated:true completion:nil];
}
         
- (void)sharePressed {
    if (iosMajorVersion() >= 8) {
        __weak TGMusicPlayerController *weakSelf = self;
        [_statusDisposable setDisposable:[[[[TGTelegraphInstance.musicPlayer playingStatus] take:1] deliverOn:[SQueue mainQueue]] startWithNext:^(TGMusicPlayerStatus *status) {
            __strong TGMusicPlayerController *strongSelf = weakSelf;
            if (strongSelf != nil) {
                if (status.downloadedStatus.downloaded) {
                    NSString *path = nil;
                    if (status.item.document.documentId != 0) {
                        path = [[TGPreparedLocalDocumentMessage localDocumentDirectoryForDocumentId:status.item.document.documentId] stringByAppendingPathComponent:[status.item.document safeFileName]];
                    } else {
                        path = [[TGPreparedLocalDocumentMessage localDocumentDirectoryForLocalDocumentId:status.item.document.localDocumentId] stringByAppendingPathComponent:[status.item.document safeFileName]];
                    }
                    
                    if (path != nil && [[NSFileManager defaultManager] fileExistsAtPath:path]) {
                        NSURL *url = [NSURL fileURLWithPath:path];
                        NSArray *dataToShare = @[url];
                        UIActivityViewController *activityViewController = [[UIActivityViewController alloc] initWithActivityItems:dataToShare applicationActivities:nil];
                        if (iosMajorVersion() >= 7 && [UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPad)
                        {
                            //activityViewController.popoverPresentationController.sourceView = sourceView;
                            //activityViewController.popoverPresentationController.sourceRect = sourceView.bounds;
                            activityViewController.popoverPresentationController.barButtonItem = _shareItem;
                        }
                        [self presentViewController:activityViewController animated:YES completion:nil];
                    }
                }
            }
        }]];
    }
}

@end
