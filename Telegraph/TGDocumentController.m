/*
 * This is the source code of Telegram for iOS v. 1.1
 * It is licensed under GNU GPL v. 2 or later.
 * You should have received a copy of the license in this archive (see LICENSE).
 *
 * Copyright Peter Iakovlev, 2013.
 */

#import "TGDocumentController.h"

@interface TGFilePreviewItem : NSObject <QLPreviewItem>

@property (atomic, strong) NSURL *previewItemURL;
@property (atomic, strong) NSString *previewItemTitle;

@end

@implementation TGFilePreviewItem

@end

@interface TGDocumentController () <QLPreviewControllerDelegate, QLPreviewControllerDataSource>
{
    TGFilePreviewItem *_item;
    
    UIDocumentInteractionController *_interactionController;
}

@end

@implementation TGDocumentController

- (instancetype)initWithURL:(NSURL *)url
{
    self = [super init];
    if (self != nil)
    {
        self.delegate = self;
        self.dataSource = self;
        
        _item = [[TGFilePreviewItem alloc] init];
        _item.previewItemURL = url;
        _item.previewItemTitle = [url lastPathComponent];
        
        if (iosMajorVersion() < 7)
            self.wantsFullScreenLayout = false;
        
        if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad)
        {
            [self.navigationItem setLeftBarButtonItem:[[UIBarButtonItem alloc] initWithTitle:TGLocalized(@"Common.Done") style:UIBarButtonItemStyleDone target:self action:@selector(donePressed)]];
        }
    }
    return self;
}

- (void)donePressed
{
    if (iosMajorVersion() >= 8)
        [self.presentingViewController dismissViewControllerAnimated:false completion:nil];
    else
        [self.presentingViewController dismissViewControllerAnimated:true completion:nil];
}

- (void)viewDidLoad
{
    if ([TGViewController useExperimentalRTL])
        self.view.transform = CGAffineTransformMakeScale(-1.0f, 1.0f);
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
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

@end
