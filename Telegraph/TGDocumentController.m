/*
 * This is the source code of Telegram for iOS v. 1.1
 * It is licensed under GNU GPL v. 2 or later.
 * You should have received a copy of the license in this archive (see LICENSE).
 *
 * Copyright Peter Iakovlev, 2013.
 */

#import "TGDocumentController.h"
#import "TGHacks.h"
#import "Freedom.h"
#import <MobileCoreServices/MobileCoreServices.h>
#import "TGMediaAssetsUtils.h"
#import "TGAppDelegate.h"

#import "TGShareMenu.h"

#import "TGMessage.h"

@interface TGFilePreviewItem : NSObject <QLPreviewItem>

@property (nonatomic, strong) NSURL *previewItemURL;
@property (nonatomic, strong) NSString *previewItemTitle;

@end

@implementation TGFilePreviewItem

@end

@interface QLPreviewController (Internal)

- (void)actionButtonTapped:(id)sender;

- (void)_setControlsOverlayVisible:(BOOL)arg1 adjustingStatusBar:(BOOL)arg2 duration:(double)arg3;

@end

@interface TGDocumentController () <QLPreviewControllerDelegate, QLPreviewControllerDataSource>
{
    TGFilePreviewItem *_item;
    int32_t _messageId;
    NSString *_uti;
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
        
        NSString *fileExtension = [url pathExtension];
        _uti = (__bridge_transfer NSString *)UTTypeCreatePreferredIdentifierForTag(kUTTagClassFilenameExtension, (__bridge CFStringRef)fileExtension, NULL);
        
        if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad && iosMajorVersion() < 9)
        {
            [self.navigationItem setLeftBarButtonItem:[[UIBarButtonItem alloc] initWithTitle:TGLocalized(@"Common.Done") style:UIBarButtonItemStyleDone target:self action:@selector(donePressed)]];
        }
    }
    return self;
}

- (void)actionButtonTapped:(id)sender
{
    if (self.useDefaultAction || self.shareAction == nil)
    {
        [super actionButtonTapped:sender];
        return;
    }
    
    if (UTTypeConformsTo((__bridge CFStringRef _Nonnull)(_uti), kUTTypeArchive))
    {
        [super actionButtonTapped:sender];
        return;
    }

    NSString *actionTitle = TGLocalized(@"Preview.SaveToCameraRoll");
    bool isVideo = false;
    
    if (!UTTypeConformsTo((__bridge CFStringRef _Nonnull)(_uti), kUTTypeImage))
    {
        if (UTTypeConformsTo((__bridge CFStringRef _Nonnull)(_uti), kUTTypeMovie))
            isVideo = true;
        else
            actionTitle = nil;
    }
    
    __weak TGDocumentController *weakSelf = self;
    [TGShareMenu presentInParentController:(TGViewController *)self menuController:nil buttonTitle:actionTitle buttonAction:^
    {
        if (!isVideo)
            [TGMediaAssetsSaveToCameraRoll saveImageAtURL:_item.previewItemURL];
        else
            [TGMediaAssetsSaveToCameraRoll saveVideoAtURL:_item.previewItemURL];
    } shareAction:^(NSArray *peerIds, NSString *caption) {
        __strong TGDocumentController *strongSelf = weakSelf;
        if (strongSelf != nil && strongSelf.shareAction != nil)
            strongSelf.shareAction(peerIds, caption);
    } externalShareItemSignal:[SSignal single:_item.previewItemURL] sourceView:self.view sourceRect:nil barButtonItem:sender];
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

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    [self.navigationController setToolbarHidden:true animated:animated];
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
    if (iosMajorVersion() >= 8)
    {
        NSDictionary *dict = @{@"url": [_item.previewItemURL absoluteString], @"messageId": @(_messageId)};
        NSData *data = [NSKeyedArchiver archivedDataWithRootObject:dict];
        
        NSString *groupName = [@"group." stringByAppendingString:[[NSBundle mainBundle] bundleIdentifier]];
        
        NSURL *groupURL = [[NSFileManager defaultManager] containerURLForSecurityApplicationGroupIdentifier:groupName];
        if (groupURL != nil)
        {
            NSURL *currentShareItemMetadataUrl = [groupURL URLByAppendingPathComponent:@"share-item-metadata" isDirectory:false];
            [data writeToURL:currentShareItemMetadataUrl atomically:true];
        }
    }
    
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

- (void)_setControlsOverlayVisible:(BOOL)visible adjustingStatusBar:(BOOL)adjusting duration:(double)duration
{
    [super _setControlsOverlayVisible:visible adjustingStatusBar:adjusting duration:duration];
    
    if (TGAppDelegateInstance.rootController.currentSizeClass == UIUserInterfaceSizeClassCompact)
    {
        [UIView animateWithDuration:0.2 animations:^
        {
            [TGHacks setApplicationStatusBarAlpha: visible ? 1.0f : 0.0f];        
        }];
    }
}

@end
