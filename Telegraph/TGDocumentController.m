#import "TGDocumentController.h"

#import <LegacyComponents/LegacyComponents.h>

#import <MobileCoreServices/MobileCoreServices.h>
#import <LegacyComponents/TGMediaAssetsUtils.h>
#import "TGAppDelegate.h"

#import "TGShareMenu.h"

#import "TGLegacyComponentsContext.h"


@interface TGFilePreviewItem : NSObject <QLPreviewItem>

@property (nonatomic, strong) NSURL *previewItemURL;
@property (nonatomic, strong) NSString *previewItemTitle;

@end

@implementation TGFilePreviewItem

@end

@interface TGDocumentController () <QLPreviewControllerDelegate, QLPreviewControllerDataSource>
{
    TGFilePreviewItem *_item;
    int32_t _messageId;
    SMetaDisposable *_fullscreenDisposable;
}

@end

@implementation TGDocumentController

- (instancetype)initWithURL:(NSURL *)url messageId:(int32_t)messageId
{
    self = [super init];
    if (self != nil)
    {
        self.delegate = self;
        self.dataSource = self;
        
        _messageId = messageId;
        
        _item = [[TGFilePreviewItem alloc] init];
        _item.previewItemURL = url;
        _item.previewItemTitle = [url lastPathComponent];
        
        if (iosMajorVersion() < 7)
            self.wantsFullScreenLayout = false;
        
        if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad && iosMajorVersion() < 9)
        {
            [self.navigationItem setLeftBarButtonItem:[[UIBarButtonItem alloc] initWithTitle:TGLocalized(@"Common.Done") style:UIBarButtonItemStyleDone target:self action:@selector(donePressed)]];
        }
        
        _fullscreenDisposable = [[SMetaDisposable alloc] init];
    }
    return self;
}

- (void)dealloc
{
    [_fullscreenDisposable dispose];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self.navigationController setNavigationBarHidden:false animated:animated];
    
    if (_previewMode)
    {
        UIView *view = [[[self.view.subviews lastObject] subviews] lastObject];
        if ([view isKindOfClass:[UINavigationBar class]])
            ((UINavigationBar *)view).hidden = true;
    }
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    __weak TGDocumentController *weakSelf = self;
    [_fullscreenDisposable setDisposable:[[(TGNavigationBar *)self.navigationController.navigationBar hiddenSignal] startWithNext:^(NSNumber *next)
    {
        __strong TGDocumentController *strongSelf = weakSelf;
        [strongSelf setStatusBarHidden:next.boolValue];
    }]];
}

- (void)setStatusBarHidden:(bool)hidden
{
    [UIView animateWithDuration:0.3 animations:^{
        [[TGLegacyComponentsContext shared] setApplicationStatusBarAlpha:hidden ? 0.0f : 1.0f];
    }];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    [self.navigationController setToolbarHidden:true animated:animated];
    
    [self setStatusBarHidden:false];
}

- (void)donePressed
{
    if (iosMajorVersion() >= 8)
        [self.presentingViewController dismissViewControllerAnimated:false completion:nil];
    else
        [self.presentingViewController dismissViewControllerAnimated:true completion:nil];
}

- (NSInteger)numberOfPreviewItemsInPreviewController:(QLPreviewController *)__unused controller
{
    return 1;
}

- (id<QLPreviewItem>)previewController:(QLPreviewController *)__unused controller previewItemAtIndex:(NSInteger)__unused index
{
    return _item;
}

- (UIViewController *)documentInteractionControllerViewControllerForPreview:(UIDocumentInteractionController *)__unused controller
{
    return self;
}

- (BOOL)prefersStatusBarHidden
{
    return true;
}

@end
