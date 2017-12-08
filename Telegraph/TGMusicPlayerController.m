#import "TGMusicPlayerController.h"

#import <LegacyComponents/LegacyComponents.h>
#import "TGLegacyComponentsContext.h"

#import "TGMusicPlayerFullView.h"
#import "TGTelegraph.h"

#import "TGPreparedLocalDocumentMessage.h"

#import "TGInterfaceManager.h"
#import "TGSharedMediaController.h"

#import "TGShareMenu.h"
#import "TGSendMessageSignals.h"

#import "TGAudioMediaAttachment+Telegraph.h"

@interface TGMusicPlayerController () <UIGestureRecognizerDelegate>
{
    TGMusicPlayerFullView *_view;
    SMetaDisposable *_statusDisposable;
}
@end

@implementation TGMusicPlayerController

- (instancetype)init
{
    self = [super init];
    if (self != nil)
    {
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
    
    self.view.backgroundColor = [UIColor clearColor];
    
    __weak TGMusicPlayerController *weakSelf = self;
    _view = [[TGMusicPlayerFullView alloc] initWithFrame:self.view.bounds context:[TGLegacyComponentsContext shared]];
    _view.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    _view.actionsPressed = ^
    {
        __strong TGMusicPlayerController *strongSelf = weakSelf;
        if (strongSelf != nil)
            [strongSelf sharePressed];
    };
    _view.dismissed = ^
    {
        __strong TGMusicPlayerController *strongSelf = weakSelf;
        if (strongSelf != nil)
            [strongSelf dismiss];
    };
    [self.view addSubview:_view];
    
    if (![self _updateControllerInset:false])
        [self controllerInsetUpdated:UIEdgeInsetsZero];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [_view layoutSubviews];
}

- (void)dismiss
{
    [self removeFromParentViewController];
    [self.view removeFromSuperview];
}

- (void)dismissAnimated:(bool)animated
{
    if (animated)
        [_view dismissAnimated:true completion:nil];
    else
        [self dismiss];
}

- (void)sharePressed
{
    __weak TGMusicPlayerController *weakSelf = self;
    [_statusDisposable setDisposable:[[[[TGTelegraphInstance.musicPlayer playingStatus] take:1] deliverOn:[SQueue mainQueue]] startWithNext:^(TGMusicPlayerStatus *status) {
        __strong TGMusicPlayerController *strongSelf = weakSelf;
        if (strongSelf == nil)
            return;
        
        NSString *path = nil;
        bool inSecretChat = false;
        if ([status.item.media isKindOfClass:[TGDocumentMediaAttachment class]])
        {
            TGDocumentMediaAttachment *document = status.item.media;
            inSecretChat = (document.documentId == 0 && document.accessHash == 0);
            if (document.documentId != 0)
            {
                path = [[TGPreparedLocalDocumentMessage localDocumentDirectoryForDocumentId:document.documentId version:document.version] stringByAppendingPathComponent:[document safeFileName]];
            }
            else
            {
                path = [[TGPreparedLocalDocumentMessage localDocumentDirectoryForLocalDocumentId:document.localDocumentId version:document.version] stringByAppendingPathComponent:[document safeFileName]];
            }
        }
        else if ([status.item.media isKindOfClass:[TGAudioMediaAttachment class]])
        {
            TGAudioMediaAttachment *audio = status.item.media;
            path = [audio localFilePath];
        }
        
        void (^shareAction)(NSArray *, NSString *) = ^(NSArray *peerIds, NSString *caption)
        {
            if (![status.item.media isKindOfClass:[TGDocumentMediaAttachment class]])
                return;
            
            TGDocumentMediaAttachment *document = (TGDocumentMediaAttachment *)status.item.media;
            [[TGShareSignals shareDocument:document toPeerIds:peerIds caption:caption] startWithNext:nil];
        };
        
        if (inSecretChat)
            shareAction = nil;
        
        SSignal *externalSignal = status.downloadedStatus.downloaded ? [SSignal single:[NSURL fileURLWithPath:path]] : nil;
    
        CGRect (^sourceRect)(void) = ^CGRect
        {
            return [strongSelf->_view.actionsButton convertRect:strongSelf->_view.actionsButton.bounds toView:strongSelf->_view];
        };
        
        [TGShareMenu presentInParentController:self menuController:nil buttonTitle:status.item.peerId != 0 ? TGLocalized(@"SharedMedia.ViewInChat") : nil buttonAction:^
        {
            if (![status.item.key isKindOfClass:[NSNumber class]])
                return;
            
            int32_t messageId = [(NSNumber *)status.item.key int32Value];
            [[TGInterfaceManager instance] navigateToConversationWithId:status.item.peerId conversation:nil performActions:nil atMessage:@{ @"mid": @(messageId), @"useExisting": @true } clearStack:true openKeyboard:false canOpenKeyboardWhileInTransition:false animated:true];
            
            __strong TGMusicPlayerController *strongSelf = weakSelf;
            if (strongSelf != nil)
                [strongSelf->_view dismissAnimated:true completion:nil];
        } shareAction:shareAction externalShareItemSignal:externalSignal sourceView:strongSelf->_view sourceRect:sourceRect barButtonItem:nil];
    }]];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    if (!TGIsPad())
        return interfaceOrientation == UIInterfaceOrientationPortrait;
    
    return [super shouldAutorotateToInterfaceOrientation:interfaceOrientation];
}

- (BOOL)shouldAutorotate
{
    if (!TGIsPad())
        return false;
    
    return [super shouldAutorotate];
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations
{
    if (!TGIsPad())
        return UIInterfaceOrientationMaskPortrait;
    
    return [super supportedInterfaceOrientations];
}

- (UIInterfaceOrientation)preferredInterfaceOrientationForPresentation
{
    if (!TGIsPad())
        return UIInterfaceOrientationPortrait;
    
    return [super preferredInterfaceOrientationForPresentation];
}

- (void)controllerInsetUpdated:(UIEdgeInsets)previousInset
{
    [super controllerInsetUpdated:previousInset];
    
    _view.safeAreaInset = self.controllerSafeAreaInset;
}

@end
