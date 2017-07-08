#import "TGMusicPlayerController.h"

#import "TGMusicPlayerCompleteView.h"
#import "TGTelegraph.h"
#import "TGImageUtils.h"

#import "TGPreparedLocalDocumentMessage.h"

#import "TGInterfaceManager.h"
#import "TGSharedMediaController.h"

#import "TGShareMenu.h"
#import "TGSendMessageSignals.h"

@interface TGMusicPlayerController () <UIGestureRecognizerDelegate>
{
    TGMusicPlayerCompleteView *_view;
    UIBarButtonItem *_shareItem;
    
    SMetaDisposable *_statusDisposable;
    
    UIPanGestureRecognizer *_gestureRecognizer;
    CGFloat _gestureStartPosition;
    
    bool _whiteOnBlackStatusBar;
    
    bool _appearing;
    bool _dismissing;
    bool _semiDismissed;
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
    
    UIView *tailView = [[UIView alloc] initWithFrame:self.view.bounds];
    tailView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleTopMargin;
    tailView.backgroundColor = self.view.backgroundColor;
    tailView.frame = CGRectOffset(tailView.frame, 0, tailView.frame.size.height);
    [self.view addSubview:tailView];
    
    __weak TGMusicPlayerController *weakSelf = self;
    _view = [[TGMusicPlayerCompleteView alloc] initWithFrame:self.view.bounds setTitle:^(NSString *title)
    {
        __strong TGMusicPlayerController *strongSelf = weakSelf;
        if (strongSelf != nil)
            strongSelf.title = title;
    } actionsEnabled:^(bool enabled) {
        __strong TGMusicPlayerController *strongSelf = weakSelf;
        if (strongSelf != nil)
            strongSelf->_shareItem.enabled = enabled;
    }];
    _view.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    _view.dismissPressed = ^
    {
        __strong TGMusicPlayerController *strongSelf = weakSelf;
        if (strongSelf != nil)
            [strongSelf closePressed];
    };
    _view.actionsPressed = ^
    {
        __strong TGMusicPlayerController *strongSelf = weakSelf;
        if (strongSelf != nil)
            [strongSelf sharePressed];
    };
    _view.playlistPressed = ^
    {
        __strong TGMusicPlayerController *strongSelf = weakSelf;
        if (strongSelf != nil)
            [strongSelf playlistPressed];
    };
    _view.statusBarStyleChange = ^(bool whiteOnBlack)
    {
        __strong TGMusicPlayerController *strongSelf = weakSelf;
        if (strongSelf == nil)
            return;
        
        strongSelf->_whiteOnBlackStatusBar = whiteOnBlack;
        [strongSelf updateStatusBarAppearanceAnimated:strongSelf->_appearing];
    };
    [self.view addSubview:_view];
    
    if (!TGIsPad() && iosMajorVersion() >= 8)
    {
        _gestureRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePan:)];
        _gestureRecognizer.delegate = self;
        [self.view addGestureRecognizer:_gestureRecognizer];
    }
    
    if (![self _updateControllerInset:false])
        [self controllerInsetUpdated:UIEdgeInsetsZero];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    _appearing = true;
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    _appearing = false;
}

- (UIStatusBarStyle)preferredStatusBarStyle
{
    if (_whiteOnBlackStatusBar && !_dismissing && !_semiDismissed)
        return UIStatusBarStyleLightContent;
    
    return UIStatusBarStyleDefault;
}

- (void)controllerInsetUpdated:(UIEdgeInsets)previousInset
{
    if (TGIsPad())
        _view.topInset = self.controllerInset.top;
    
    [super controllerInsetUpdated:previousInset];
}

- (void)closePressed
{
    [self dismissAnimated:true];
}

- (void)dismissAnimated:(bool)animated
{
    _dismissing = true;
    [self.presentingViewController dismissViewControllerAnimated:animated completion:nil];
}

- (void)sharePressed
{
    UIBarButtonItem *barButtonItem = self.navigationController != nil ? _shareItem : nil;
    
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
    
        CGRect (^sourceRect)(void) = nil;
        if (barButtonItem == nil)
        {
            sourceRect = ^CGRect
            {
                return CGRectZero;
            };
        }
        
        [TGShareMenu presentInParentController:self menuController:nil buttonTitle:nil buttonAction:nil shareAction:shareAction externalShareItemSignal:externalSignal sourceView:_view sourceRect:sourceRect barButtonItem:barButtonItem];
    }]];
}

- (void)playlistPressed
{
    _dismissing = true;
    self.view.backgroundColor = [UIColor clearColor];
    
    [[TGTelegraphInstance.musicPlayer.playingStatus take:1] startWithNext:^(TGMusicPlayerStatus *status)
    {
        if (status.item.peerId != 0) {
            [[TGInterfaceManager instance] navigateToSharedMediaOfConversationWithId:status.item.peerId mode:TGSharedMediaControllerModeAudio atMessage:nil];
        
            [self dismissAnimated:true];
        }
    }];
}

- (void)_updateDismissTransitionMovementWithDistance:(CGFloat)distance animated:(bool)animated
{
    UIViewController *rootController = self.navigationController ?: self;
    
    CGRect originalFrame = rootController.view.bounds;
    CGRect frame = (CGRect){ { originalFrame.origin.x, originalFrame.origin.y + distance }, originalFrame.size };
    if (animated)
    {
        [UIView animateWithDuration:0.3 animations:^
        {
            rootController.view.frame = frame;
        }];
    }
    else
    {
        rootController.view.frame = frame;
    }
}

- (CGFloat)swipeOffsetForOffset:(CGFloat)offset
{
    if (offset >= 0)
        return offset;
    
    static CGFloat c = 0.1f;
    static CGFloat d = 300.0f;
    
    return (1.0f - (1.0f / ((offset * c / d) + 1.0f))) * d;
}

- (CGFloat)clampVelocity:(CGFloat)velocity
{
    CGFloat value = velocity < 0.0f ? -velocity : velocity;
    value = MIN(30.0f, 0.0f);
    return velocity < 0.0f ? -value : value;
}

- (void)applyViewOffset:(CGFloat)offset
{
    UIViewController *rootController = self.navigationController ?: self;
    
    CGRect frame = rootController.view.frame;
    frame.origin.y = offset;
    rootController.view.frame = frame;
}

- (void)animateSheetViewToPosition:(CGFloat)position velocity:(CGFloat)velocity completion:(void (^)(void))completion
{
    CGFloat animationVelocity = position > 0 ? fabs(velocity) / fabs(position - self.view.frame.origin.y) : 0;
    
    void (^changeBlock)(void) = ^
    {
        [self applyViewOffset:position];
    };
    void (^completionBlock)(BOOL) = ^(__unused BOOL finished)
    {
        if (completion != nil)
            completion();
    };
    
    CGFloat duration = 0.25;

    if (iosMajorVersion() >= 7)
    {
        [UIView animateWithDuration:duration delay:0.0 usingSpringWithDamping:1.5 initialSpringVelocity:animationVelocity options:UIViewAnimationOptionCurveLinear | UIViewAnimationOptionAllowAnimatedContent animations:changeBlock completion:completionBlock];
    }
    else
    {
        [UIView animateWithDuration:duration delay:0.0 options:UIViewAnimationOptionCurveEaseInOut | UIViewAnimationOptionAllowAnimatedContent animations:changeBlock completion:completionBlock];
    }
}

- (void)handlePan:(UIPanGestureRecognizer *)gestureRecognizer
{
    CGFloat location = [gestureRecognizer locationInView:nil].y;
    CGFloat offset = location - _gestureStartPosition;
    
    switch (gestureRecognizer.state)
    {
        case UIGestureRecognizerStateBegan:
        {
            _gestureStartPosition = location;
        }
            break;
            
        case UIGestureRecognizerStateChanged:
        {
            CGFloat finalOffset = [self swipeOffsetForOffset:offset];
            [self applyViewOffset:finalOffset];
            
            bool semiDismissed = (finalOffset > 13.0f);
            if (semiDismissed != _semiDismissed)
            {
                _semiDismissed = semiDismissed;
                [self updateStatusBarAppearanceAnimated:true];
            }
        }
            break;
            
        case UIGestureRecognizerStateEnded:
        {
            CGFloat velocity = [gestureRecognizer velocityInView:nil].y;
            
            if (velocity > 200.0f || offset > self.view.bounds.size.height / 2.0f)
            {
                _dismissing = true;
                [self animateSheetViewToPosition:self.view.bounds.size.height velocity:velocity completion:^
                {
                    [self dismissAnimated:false];
                }];
                
                [self updateStatusBarAppearanceAnimated:true];
            }
            else
            {
                _semiDismissed = false;
                _dismissing = false;
                [self animateSheetViewToPosition:0 velocity:0 completion:nil];
                
                [self updateStatusBarAppearanceAnimated:true];
            }
        }
            break;
            
        case UIGestureRecognizerStateCancelled:
        {
            _semiDismissed = false;
            _dismissing = false;
            [self animateSheetViewToPosition:0 velocity:0 completion:nil];
            
            [self updateStatusBarAppearanceAnimated:true];
        }
            break;
            
        default:
            break;
    }
}

- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer
{
    return [_view isSwipeGestureAllowedAtPoint:[gestureRecognizer locationInView:_view]];
}

- (void)updateStatusBarAppearanceAnimated:(bool)animated
{
    if (iosMajorVersion() < 7)
        return;
    
    bool isDark = ([self preferredStatusBarStyle] == UIStatusBarStyleLightContent);
    
    if (animated)
    {
        NSTimeInterval delay = _appearing ? 0.2 : 0.0;
        [UIView animateWithDuration:0.2 delay:delay options:kNilOptions animations:^
        {
            [self.presentingViewController setNeedsStatusBarAppearanceUpdate];
            if (!_semiDismissed)
                [_view setGradientAlpha:isDark ? 1.0f : 0.0f];
        } completion:nil];
    }
    else
    {
        [self.presentingViewController setNeedsStatusBarAppearanceUpdate];
        [_view setGradientAlpha:isDark ? 1.0f : 0.0f];
    }
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

@end
