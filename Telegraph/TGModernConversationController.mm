#import "TGModernConversationController.h"

#import "FreedomUIKit.h"

#import "TGModernConversationCompanion.h"

#import "TGModernConversationCollectionView.h"
#import "TGModernConversationViewLayout.h"

#import "TGModernConversationItem.h"
#import "TGModernFlatteningViewModel.h"

#import "TGImageUtils.h"
#import "TGPhoneUtils.h"
#import "TGStringUtils.h"
#import "TGFont.h"
#import "TGHacks.h"
#import "TGObserverProxy.h"
#import "TGActionSheet.h"

#import "HPGrowingTextView.h"
#import "HPTextViewInternal.h"

#import "TGMessageModernConversationItem.h"
#import "TGMessage.h"

#import "TGAppDelegate.h"
#import "TGApplication.h"

#import "TGModernConversationTitleView.h"
#import "TGModernConversationAvatarButton.h"
#import "TGModernConversationInputTextPanel.h"
#import "TGModernConversationEditingPanel.h"
#import "TGModernConversationTitlePanel.h"
#import "TGModernConversationEmptyListPlaceholderView.h"

#import "TGOverlayControllerWindow.h"
#import "TGModernGalleryController.h"
#import "TGGenericPeerMediaGalleryModel.h"
#import "TGGroupAvatarGalleryModel.h"
#import "TGGroupAvatarGalleryItem.h"
#import "TGSecretPeerMediaGalleryModel.h"

#import "TGGenericPeerGalleryItem.h"
#import "TGModernGalleryVideoItemView.h"

#import "TGMapViewController.h"
#import "TGImagePickerController.h"
#import "TGImageSearchController.h"
#import "TGLegacyCameraController.h"
#import "TGMapViewController.h"
#import "TGDocumentController.h"
#import "TGForwardContactPickerController.h"
#import "TGAudioRecorder.h"
#import "TGModernConversationAudioPlayer.h"

#import "TGMediaFoldersController.h"
#import "TGModernMediaPickerController.h"

#import "TGMediaItem.h"
#import "TGDatabase.h"
#import "TGTelegraph.h"
#import "TGGenericModernConversationCompanion.h"

#import "TGModernConversationEmptyListPlaceholderView.h"

#import "TGRemoteImageView.h"

#import "TGMenuView.h"
#import "TGAlertView.h"

#import "TGWallpaperManager.h"

#import <CommonCrypto/CommonDigest.h>
#import <AVFoundation/AVFoundation.h>
#import <MobileCoreServices/MobileCoreServices.h>

#import "TGVideoConverter.h"

#if TARGET_IPHONE_SIMULATOR
NSInteger TGModernConversationControllerUnloadHistoryLimit = 500;
NSInteger TGModernConversationControllerUnloadHistoryThreshold = 200;
#else
NSInteger TGModernConversationControllerUnloadHistoryLimit = 500;
NSInteger TGModernConversationControllerUnloadHistoryThreshold = 200;
#endif

#define TGModernConversationControllerLogCellOperations false

typedef enum {
    TGModernConversationActivityChangeAuto = 0,
    TGModernConversationActivityChangeActive = 1,
    TGModernConversationActivityChangeInactive = 2
} TGModernConversationActivityChange;

typedef enum {
    TGModernConversationPanelAnimationNone = 0,
    TGModernConversationPanelAnimationSlide = 1,
    TGModernConversationPanelAnimationFade = 2
} TGModernConversationPanelAnimation;

@interface TGModernConversationController () <UICollectionViewDataSource, TGModernConversationViewLayoutDelegate, UIViewControllerTransitioningDelegate, HPGrowingTextViewDelegate, UIGestureRecognizerDelegate, TGImagePickerControllerDelegate, TGLegacyCameraControllerDelegate, TGModernConversationInputTextPanelDelegate, TGModernConversationEditingPanelDelegate, TGModernConversationTitleViewDelegate, TGForwardContactPickerControllerDelegate, TGModernConversationAudioPlayerDelegate, TGAudioRecorderDelegate>
{
    bool _alreadyHadWillAppear;
    bool _alreadyHadDidAppear;
    NSTimeInterval _willAppearTimestamp;
    bool _didDisappearBeforeAppearing;
    NSString *_initialInputText;
    
    bool _shouldHaveTitlePanelLoaded;
    
    bool _editingMode;
    
    NSMutableArray *_items;
    
    NSMutableSet *_collectionRegisteredIdentifiers;
    
    TGModernConversationCollectionView *_collectionView;
    TGModernConversationViewLayout *_collectionLayout;
    UIScrollView *_collectionViewScrollToTopProxy;
    
    TGModernViewStorage *_viewStorage;
    NSMutableArray *_itemsBoundToTemporaryContainer;
    bool _disableItemBinding;
    
    CGImageRef _snapshotImage;
    UIView *_snapshotBackgroundView;
    UIView *_snapshotImageView;
    
    UIImageView *_backgroundView;
    
    TGModernConversationInputTextPanel *_inputTextPanel;
    TGModernConversationInputPanel *_currentInputPanel;
    TGModernConversationInputPanel *_customInputPanel;
    
    UIView *_titlePanelWrappingView;
    TGModernConversationTitlePanel *_primaryTitlePanel;
    TGModernConversationTitlePanel *_secondaryTitlePanel;
    TGModernConversationTitlePanel *_currentTitlePanel;
    
    TGModernConversationEmptyListPlaceholderView *_emptyListPlaceholder;
    
    CGFloat _keyboardHeight;
    TGObserverProxy *_keyboardWillChangeFrameProxy;
    TGObserverProxy *_keyboardDidChangeFrameProxy;
    
    TGObserverProxy *_applicationWillResignActiveProxy;
    TGObserverProxy *_applicationDidEnterBackgroundProxy;
    TGObserverProxy *_applicationDidBecomeActiveProxy;
    
    CGPoint _collectionPanTouchContentOffset;
    bool _collectionPanStartedAtBottom;
    
    TGModernConversationTitleView *_titleView;
    TGModernConversationAvatarButton *_avatarButton;
    UIBarButtonItem *_avatarButtonItem;
    UIBarButtonItem *_infoButtonItem;
    
    TGMenuContainerView *_menuContainerView;
    
    UIButton *_unseenMessagesButton;
    
    std::set<int32_t> _checkedMessages;
    
    bool _disableScrollProcessing;
    
    bool _enableAboveHistoryRequests;
    bool _enableBelowHistoryRequests;
    
    bool _enableUnloadHistoryRequests;
    
    bool _canReadHistory;
    
    TGAudioRecorder *_currentAudioRecorder;
    TGModernConversationAudioPlayer *_currentAudioPlayer;
    int32_t _currentAudioPlayerMessageId;
    
    bool _streamAudioItems;
    int32_t _currentStreamingAudioMessageId;
}

@end

@implementation TGModernConversationController

- (instancetype)init
{
    self = [super init];
    if (self != nil)
    {
        _actionHandle = [[ASHandle alloc] initWithDelegate:self releaseOnMainThread:true];
        
        self.automaticallyManageScrollViewInsets = false;
        self.adjustControllerInsetWhenStartingRotation = true;
        
        _items = [[NSMutableArray alloc] init];
        
        _keyboardWillChangeFrameProxy = [[TGObserverProxy alloc] initWithTarget:self targetSelector:@selector(keyboardWillChangeFrame:) name:UIKeyboardWillChangeFrameNotification];
        _keyboardDidChangeFrameProxy = [[TGObserverProxy alloc] initWithTarget:self targetSelector:@selector(keyboardDidChangeFrame:) name:UIKeyboardDidChangeFrameNotification];
        
        _applicationWillResignActiveProxy = [[TGObserverProxy alloc] initWithTarget:self targetSelector:@selector(applicationWillResignActive:) name:UIApplicationWillResignActiveNotification];
        _applicationDidEnterBackgroundProxy = [[TGObserverProxy alloc] initWithTarget:self targetSelector:@selector(applicationDidEnterBackground:) name:UIApplicationDidEnterBackgroundNotification];
        _applicationDidBecomeActiveProxy = [[TGObserverProxy alloc] initWithTarget:self targetSelector:@selector(applicationDidBecomeActive:) name:UIApplicationDidBecomeActiveNotification];
        
        _titleView = [[TGModernConversationTitleView alloc] initWithFrame:CGRectMake(0, 0, 1, 1)];
        _titleView.delegate = self;
        [self setTitleView:_titleView];
        
        _avatarButton = [[TGModernConversationAvatarButton alloc] initWithFrame:CGRectMake(0, 0, 1, 1)];
        [_avatarButton addTarget:self action:@selector(avatarPressed) forControlEvents:UIControlEventTouchUpInside];
        _avatarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:_avatarButton];
        [self setRightBarButtonItem:[self defaultRightBarButtonItem]];
        [self setLeftBarButtonItem:[self defaultLeftBarButtonItem]];
        
        _canReadHistory = true;
        _enableUnloadHistoryRequests = true;
        
        self.dismissPresentedControllerWhenRemovedFromNavigationStack = true;
        
        _didDisappearBeforeAppearing = false;
        
        _streamAudioItems = TGAppDelegateInstance.autoPlayAudio;
    }
    return self;
}

- (void)dealloc
{
    [_actionHandle reset];
    
    _collectionView.delegate = nil;
    _collectionView.dataSource = nil;
    
    if (_snapshotImage != nil)
    {
        CGImageRelease(_snapshotImage);
        _snapshotImage = nil;
    }
    
    [_companion unbindController];
}

- (NSInteger)_indexForCollectionView
{
    return 1;
}

- (void)_resetCollectionView
{
    [self _resetCollectionView:false];
}

- (CGSize)collectionViewSizeForInterfaceOrientation:(UIInterfaceOrientation)orientation
{
    static bool isTablet = false;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^
    {
        isTablet = UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad;
    });
    
    if (isTablet)
    {
        CGSize screenSize = [TGViewController screenSizeForInterfaceOrientation:orientation];
        return CGSizeMake((screenSize.width - (screenSize.width >= (1024.0f - FLT_EPSILON) ? 389.0f : 320.0f)), screenSize.height);
    }
    else
    {
        return [TGViewController screenSizeForInterfaceOrientation:orientation];
    }
}

- (void)_resetCollectionView:(bool)resetPositioning
{
    if (_collectionView != nil)
    {
        _collectionView.delegate = nil;
        _collectionView.dataSource = nil;
        [_collectionView removeFromSuperview];
        
        UICollectionView *collectionView = _collectionView;
        
        dispatch_async(dispatch_get_main_queue(), ^
        {
            TGLog(@"***** replacing collection view %@", collectionView);
        });
    }
    
    if (_collectionViewScrollToTopProxy != nil)
    {
        _collectionViewScrollToTopProxy.delegate = nil;
        [_collectionViewScrollToTopProxy removeFromSuperview];
        _collectionViewScrollToTopProxy = nil;
    }
    
    _collectionRegisteredIdentifiers = [[NSMutableSet alloc] init];
    
    CGSize collectionViewSize = [self collectionViewSizeForInterfaceOrientation:self.interfaceOrientation];
    
    _collectionLayout = [[TGModernConversationViewLayout alloc] init];
    _collectionView = [[TGModernConversationCollectionView alloc] initWithFrame:CGRectMake(0, 0, collectionViewSize.width, collectionViewSize.height) collectionViewLayout:_collectionLayout];
    [_companion _setControllerWidthForItemCalculation:_collectionView.frame.size.width];
    _collectionView.transform = CGAffineTransformMakeRotation((CGFloat)M_PI);
    _collectionView.backgroundColor = nil;
    _collectionView.opaque = false;
    _collectionView.scrollsToTop = false;
    _collectionView.dataSource = self;
    _collectionView.delegate = self;
    _collectionView.delaysContentTouches = false;
    
    if (iosMajorVersion() >= 7)
    {
        UIPanGestureRecognizer *collectionPanRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(collectionViewPan:)];
        collectionPanRecognizer.delegate = self;
        [_collectionView addGestureRecognizer:collectionPanRecognizer];
    }
    
    _collectionView.unreadMessageRange = [_companion unreadMessageRange];
    
    _collectionView.alwaysBounceVertical = true;
    
    [_collectionView registerClass:[TGModernCollectionCell class] forCellWithReuseIdentifier:@"_empty"];
    
    UIEdgeInsets contentInset = _collectionView.contentInset;
    contentInset.top = _keyboardHeight + _currentInputPanel.frame.size.height;
    _collectionView.contentInset = contentInset;
    [self _adjustCollectionInset];
    
    [_emptyListPlaceholder adjustLayoutForOrientation:self.interfaceOrientation contentInsets:UIEdgeInsetsMake(_collectionView.contentInset.bottom, 0.0f, _collectionView.contentInset.top, 0.0f) duration:0.0f curve:0];
    
    [self.view insertSubview:_collectionView atIndex:[self _indexForCollectionView]];
    
    _collectionViewScrollToTopProxy = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 8)];
    _collectionViewScrollToTopProxy.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    _collectionViewScrollToTopProxy.delegate = self;
    _collectionViewScrollToTopProxy.scrollsToTop = true;
    _collectionViewScrollToTopProxy.contentSize = CGSizeMake(1, 16);
    _collectionViewScrollToTopProxy.contentOffset = CGPointMake(0, 8);
    [self.view insertSubview:_collectionViewScrollToTopProxy belowSubview:_collectionView];
    
    if (resetPositioning)
    {
        int32_t messageId = [_companion initialPositioningMessageId];
        TGInitialScrollPosition scrollPosition = [_companion initialPositioningScrollPosition];
        if (messageId != 0)
        {
            if (![_collectionLayout hasLayoutAttributes])
                [_collectionLayout prepareLayout];
            
            CGFloat contentOffsetY = _collectionView.contentOffset.y;
            
            int index = -1;
            for (TGMessageModernConversationItem *messageItem in _items)
            {
                index++;
                
                if (messageItem->_message.mid == messageId)
                {
                    if (index == 0)
                        break;
                    
                    UICollectionViewLayoutAttributes *attributes = [_collectionLayout layoutAttributesForItemAtIndexPath:[NSIndexPath indexPathForItem:index inSection:0]];
                    if (attributes != nil)
                    {
                        switch (scrollPosition)
                        {
                            case TGInitialScrollPositionTop:
                                contentOffsetY = CGRectGetMaxY(attributes.frame) + _collectionView.contentInset.bottom - _collectionView.frame.size.height + [_companion initialPositioningOverflowForScrollPosition:scrollPosition];
                                break;
                            case TGInitialScrollPositionCenter:
                            {
                                CGFloat visibleHeight = _collectionView.frame.size.height - _collectionView.contentInset.top - _collectionView.contentInset.bottom;
                                contentOffsetY = floorf(CGRectGetMidY(attributes.frame) - visibleHeight / 2.0f - _collectionView.contentInset.top);
                                break;
                            }
                            case TGInitialScrollPositionBottom:
                                contentOffsetY = attributes.frame.origin.y - _collectionView.contentInset.top - [_companion initialPositioningOverflowForScrollPosition:scrollPosition];
                                break;
                            default:
                                break;
                        }
                    }
                    
                    break;
                }
            }
            
            if (contentOffsetY > _collectionLayout.collectionViewContentSize.height + _collectionView.contentInset.bottom - _collectionView.frame.size.height)
                contentOffsetY = _collectionLayout.collectionViewContentSize.height + _collectionView.contentInset.bottom - _collectionView.frame.size.height;
            if (contentOffsetY < -_collectionView.contentInset.top)
                contentOffsetY = -_collectionView.contentInset.top;
            _collectionView.contentOffset = CGPointMake(0.0f, contentOffsetY);
        }
    }
    
    [_collectionView layoutSubviews];
}

- (void)setInitialSnapshot:(CGImageRef)image backgroundView:(UIView *)backgroundView viewStorage:(TGModernViewStorage *)viewStorage
{
    if (_viewStorage == nil && viewStorage != nil)
        _viewStorage = viewStorage;
    
    if (_snapshotImage != NULL)
    {
        CGImageRelease(_snapshotImage);
        _snapshotImage = nil;
    }
    
    if (_snapshotBackgroundView != nil)
    {
        [_snapshotBackgroundView removeFromSuperview];
        _snapshotBackgroundView = nil;
    }
    
    if (image != NULL)
        _snapshotImage = CGImageRetain(image);
    
    if (self.isViewLoaded)
    {
        if (_snapshotImage != NULL)
        {
            if (_snapshotImageView == nil)
            {
                _snapshotImageView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, CGImageGetWidth(_snapshotImage) * (TGIsRetina() ? 0.5f : 1.0f), CGImageGetHeight(_snapshotImage) * (TGIsRetina() ? 0.5f : 1.0f))];
                _snapshotImageView.userInteractionEnabled = false;
                _snapshotImageView.transform = CGAffineTransformMakeRotation((CGFloat)M_PI);
                [self.view insertSubview:_snapshotImageView atIndex:[self _indexForCollectionView]];
            }
            
            _snapshotBackgroundView = backgroundView;
            if (_snapshotBackgroundView != nil)
            {
                [self.view insertSubview:_snapshotBackgroundView belowSubview:_snapshotImageView];
            }
            
            _snapshotImageView.layer.contents = (__bridge id)_snapshotImage;
        }
        else
        {
            if (_snapshotImageView != nil)
            {
                [_snapshotImageView removeFromSuperview];
                _snapshotImageView = nil;
            }
            
            if (_collectionView == nil)
                [self _resetCollectionView:true];
        }
    }
}

- (UIBarButtonItem *)defaultLeftBarButtonItem
{
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone)
        return nil;
    
    return [[UIBarButtonItem alloc] initWithTitle:TGLocalized(@"Common.Close") style:UIBarButtonItemStylePlain target:self action:@selector(closeButtonPressed)];
}

- (UIBarButtonItem *)defaultRightBarButtonItem
{
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone)
        return _avatarButtonItem;
    else
    {
        if (_infoButtonItem == nil && _companion != nil)
        {
            _infoButtonItem = [[UIBarButtonItem alloc] initWithTitle:[_companion _controllerInfoButtonText] style:UIBarButtonItemStylePlain target:self action:@selector(infoButtonPressed)];
        }
        
        return _infoButtonItem;
    }
}

- (void)loadView
{
    [super loadView];
    
    self.view.backgroundColor = [UIColor whiteColor];
    
    _backgroundView = [[UIImageView alloc] initWithFrame:self.view.bounds];
    UIImage *wallpaperImage = [[TGWallpaperManager instance] currentWallpaperImage];
    _backgroundView.image = wallpaperImage;
    _backgroundView.clipsToBounds = true;
    _backgroundView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    _backgroundView.contentMode = UIViewContentModeScaleAspectFill;
    [self.view addSubview:_backgroundView];
    
    _inputTextPanel = [[TGModernConversationInputTextPanel alloc] initWithFrame:CGRectMake(0, self.view.frame.size.height - 45, self.view.frame.size.width, 45) accessoryView:[_companion _controllerInputTextPanelAccessoryView]];
    if (_initialInputText.length != 0)
    {
        [_inputTextPanel.inputField setText:_initialInputText];
        _initialInputText = nil;
    }
    
    _inputTextPanel.delegate = self;
    if (_customInputPanel != nil)
        [self setInputPanel:_customInputPanel animated:false];
    else
        [self setInputPanel:_inputTextPanel animated:false];
    
    [self.view insertSubview:_emptyListPlaceholder belowSubview:_currentInputPanel];
    
    if (![self _updateControllerInset:false])
        [self controllerInsetUpdated:UIEdgeInsetsZero];
    
    [_emptyListPlaceholder adjustLayoutForOrientation:self.interfaceOrientation contentInsets:UIEdgeInsetsMake(self.controllerInset.top, 0.0f, _currentInputPanel.frame.size.height, 0.0f) duration:0.0f curve:0];
}

- (void)viewWillAppear:(BOOL)animated
{
    [self setRightBarButtonItem:[self defaultRightBarButtonItem]];
    
    if (_didDisappearBeforeAppearing)
        _keyboardHeight = 0;
    
    _inputTextPanel.maybeInputField.internalTextView.enableFirstResponder = false;
    
    _willAppearTimestamp = CFAbsoluteTimeGetCurrent();
    
    if (_collectionView != nil)
    {
        CGSize collectionViewSize = [self collectionViewSizeForInterfaceOrientation:self.interfaceOrientation];
        
        if (ABS(collectionViewSize.width - _collectionView.frame.size.width) > FLT_EPSILON)
            [self _performOrientationChangesWithDuration:0.0 orientation:self.interfaceOrientation];
        else
        {
            [_currentInputPanel adjustForOrientation:self.interfaceOrientation keyboardHeight:_keyboardHeight duration:0.0 animationCurve:0];
            [self _adjustCollectionViewForOrientation:self.interfaceOrientation keyboardHeight:_keyboardHeight inputContainerHeight:_currentInputPanel.frame.size.height duration:0.0 animationCurve:0];
        }
    }
    else
        [_currentInputPanel adjustForOrientation:self.interfaceOrientation keyboardHeight:_keyboardHeight duration:0.0 animationCurve:0];
    
    [_titleView setOrientation:self.interfaceOrientation];
    [_titleView resumeAnimations];
    
    [_avatarButton setOrientation:self.interfaceOrientation];
    
    [super viewWillAppear:animated];
    
    bool beingAnimated = animated;
    if (_shouldIgnoreAppearAnimationOnce)
    {
        beingAnimated = false;
        _shouldIgnoreAppearAnimationOnce = false;
    }
    [_companion _controllerWillAppearAnimated:beingAnimated firstTime:!_alreadyHadWillAppear];
    _alreadyHadWillAppear = true;
}

- (void)viewDidAppear:(BOOL)animated
{
    if (animated && _didDisappearBeforeAppearing)
    {
        dispatch_async(dispatch_get_main_queue(), ^
        {
            _inputTextPanel.maybeInputField.internalTextView.enableFirstResponder = true;
        });
    }
    else
        _inputTextPanel.maybeInputField.internalTextView.enableFirstResponder = true;
    
    [_companion _controllerDidAppear:!_alreadyHadDidAppear];
    _alreadyHadDidAppear = true;
    
    [self _updateCanReadHistory:TGModernConversationActivityChangeActive];
    
    _companion.viewContext.animationsEnabled = true;
    [self _updateItemsAnimationsEnabled];
    
    [super viewDidAppear:animated];
}

- (void)applicationWillResignActive:(NSNotification *)__unused notification
{
    [self _updateCanReadHistory:TGModernConversationActivityChangeInactive];
    
    [self stopInlineMedia];
}

- (void)applicationDidEnterBackground:(NSNotification *)__unused notification
{
    [self _updateCanReadHistory:TGModernConversationActivityChangeInactive];
}

- (void)applicationDidBecomeActive:(NSNotification *)__unused notification
{
    [self _updateCanReadHistory:TGModernConversationActivityChangeAuto];
}

- (void)viewWillDisappear:(BOOL)animated
{
    _didDisappearBeforeAppearing = false;
    
    freedomUIKitTest4_1();
    
    [self stopInlineMediaIfPlaying];
    
    [_collectionView stopScrollingAnimation];
    
    [self _updateCanReadHistory:TGModernConversationActivityChangeInactive];
    
    [self stopInlineMedia];
    
    _companion.viewContext.animationsEnabled = false;
    [self _updateItemsAnimationsEnabled];
    
    [super viewWillDisappear:animated];
}

- (void)viewDidDisappear:(BOOL)animated
{
    _didDisappearBeforeAppearing = true;
    
    _keyboardHeight = 0.0f;
    
    [_currentInputPanel adjustForOrientation:self.interfaceOrientation keyboardHeight:_keyboardHeight duration:0.0 animationCurve:0];
    
    [self _adjustCollectionViewForOrientation:self.interfaceOrientation keyboardHeight:_keyboardHeight inputContainerHeight:_currentInputPanel.frame.size.height duration:0.0 animationCurve:0];
    
    [_inputTextPanel.maybeInputField.internalTextView resignFirstResponder];
    
    [_titleView suspendAnimations];
    
    [self _leaveEditingModeAnimated:false];
    
    [_companion updateControllerInputText:_inputTextPanel.maybeInputField.text];
    
    [super viewDidDisappear:animated];
}

- (BOOL)shouldAutorotate
{
    bool tracking = _collectionView.isTracking;
    return !tracking && [super shouldAutorotate] && _currentAudioRecorder == nil;
}

- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    [super willRotateToInterfaceOrientation:toInterfaceOrientation duration:duration];
    
    if (_keyboardHeight < FLT_EPSILON)
        [self _performOrientationChangesWithDuration:duration orientation:toInterfaceOrientation];
}

- (void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    [_titleView setOrientation:toInterfaceOrientation];
    [_avatarButton setOrientation:self.interfaceOrientation];
    
    [super willAnimateRotationToInterfaceOrientation:toInterfaceOrientation duration:duration];
}

- (void)controllerInsetUpdated:(UIEdgeInsets)previousInset
{
    [super controllerInsetUpdated:previousInset];
    
    if (![self viewControllerIsChangingInterfaceOrientation] && _collectionView != nil)
        [self _adjustCollectionInset];
    
    if (_menuContainerView != nil)
    {
        _menuContainerView.frame = CGRectMake(0, self.controllerInset.top, self.view.frame.size.width, [self collectionViewSizeForInterfaceOrientation:self.interfaceOrientation].height - self.controllerInset.top - self.controllerInset.bottom);
    }
    
    
    if (![self viewControllerIsChangingInterfaceOrientation])
    {
        if (_titlePanelWrappingView != nil)
        {
            _titlePanelWrappingView.frame = CGRectMake(0.0f, self.controllerInset.top, [self collectionViewSizeForInterfaceOrientation:self.interfaceOrientation].width, _titlePanelWrappingView.frame.size.height);
        }
    }
}

- (void)_adjustCollectionInset
{
    UIEdgeInsets contentInset = _collectionView.contentInset;
    if (ABS(contentInset.bottom - self.controllerInset.top) > FLT_EPSILON)
    {
        contentInset.bottom = self.controllerInset.top;
        _collectionView.contentInset = contentInset;
        [self _updateUnseenMessagesButton:self.interfaceOrientation];
        
        [_emptyListPlaceholder adjustLayoutForOrientation:self.interfaceOrientation contentInsets:UIEdgeInsetsMake(_collectionView.contentInset.bottom, 0.0f, _collectionView.contentInset.top, 0.0f) duration:0.0f curve:0];
    }
}

- (void)stopAudioRecording
{
    if (_currentAudioRecorder != nil)
    {
        _currentAudioRecorder.delegate = nil;
        [_currentAudioRecorder cancel];
        _currentAudioRecorder = nil;
        
        if ([self shouldAutorotate])
            [TGViewController attemptAutorotation];
    }
}

- (void)stopInlineMediaIfPlaying
{
    if (_currentAudioPlayer != nil)
    {
        [_currentAudioPlayer stop];
        _currentAudioPlayer = nil;
        _currentAudioPlayerMessageId = 0;
        
        _currentStreamingAudioMessageId = 0;
        
        [self updateInlineMediaContexts];
    }
}

- (void)touchedTableBackground
{
    if (_menuContainerView.isShowingMenu)
        return;
    
    if ([_inputTextPanel.maybeInputField.internalTextView isFirstResponder])
        [_inputTextPanel.maybeInputField.internalTextView resignFirstResponder];
}

- (void)navigationBarAction
{
    [_menuContainerView hideMenu];
}

- (void)avatarPressed
{
    [_companion _controllerAvatarPressed];
}

- (void)closeButtonPressed
{
    [_companion _dismissController];
}

- (void)infoButtonPressed
{
    [self avatarPressed];
}

- (void)setInputPanel:(TGModernConversationInputPanel *)panel animated:(bool)animated
{
    if (!self.isViewLoaded)
        return;
    
    if (panel == _currentInputPanel)
        return;
    
    if (animated)
    {
        TGModernConversationInputPanel *previousPanel = _currentInputPanel;
        _currentInputPanel = nil;
        
        int curve = iosMajorVersion() < 7 ? 0 : 7;
        
        _currentInputPanel = panel;
        
        if (_currentInputPanel != nil)
        {
            [self.view addSubview:_currentInputPanel];
            [_currentInputPanel adjustForOrientation:self.interfaceOrientation keyboardHeight:_keyboardHeight duration:0.0 animationCurve:0];
            _currentInputPanel.frame = CGRectMake(_currentInputPanel.frame.origin.x, [self collectionViewSizeForInterfaceOrientation:self.interfaceOrientation].height, _currentInputPanel.frame.size.width, _currentInputPanel.frame.size.height);
        }
        
        [_currentInputPanel adjustForOrientation:self.interfaceOrientation keyboardHeight:_keyboardHeight duration:0.3 animationCurve:curve];
        [self _adjustCollectionViewForOrientation:self.interfaceOrientation keyboardHeight:_keyboardHeight inputContainerHeight:_currentInputPanel.frame.size.height duration:0.3 animationCurve:curve];
        
        [previousPanel endEditing:true];
        
        [UIView animateWithDuration:0.22 delay:0.00 options:0 animations:^
        {
            previousPanel.frame = CGRectMake(0.0f, [self collectionViewSizeForInterfaceOrientation:self.interfaceOrientation].height, previousPanel.frame.size.width, previousPanel.frame.size.height);
        } completion:^(__unused BOOL finished)
        {
            [previousPanel removeFromSuperview];
        }];
    }
    else
    {
        [_currentInputPanel removeFromSuperview];
        _currentInputPanel = panel;
        
        if (_currentInputPanel != nil)
        {
            [self.view addSubview:_currentInputPanel];
            [_currentInputPanel adjustForOrientation:self.interfaceOrientation keyboardHeight:_keyboardHeight duration:0.0 animationCurve:0];
            
            [self _adjustCollectionViewForOrientation:self.interfaceOrientation keyboardHeight:_keyboardHeight inputContainerHeight:_currentInputPanel.frame.size.height duration:0.0 animationCurve:0];
        }
    }
}

#pragma mark -

- (NSArray *)items
{
    return _items;
}

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    if (collectionView == _collectionView)
        return 1;
    
    return 0;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    if (collectionView == _collectionView && section == 0)
        return _items.count;
    return 0;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0)
    {
        TGModernConversationItem *item = indexPath.row < (NSInteger)_items.count ? [_items objectAtIndex:indexPath.row] : nil;
        
        if (item != nil)
        {
            __block TGModernCollectionCell *cell = nil;
            [UIView performWithoutAnimation:^
            {
                cell = [item dequeueCollectionCell:collectionView registeredIdentifiers:_collectionRegisteredIdentifiers forIndexPath:indexPath];
                if (cell.boundItem != nil)
                {
                    TGModernConversationItem *item = cell.boundItem;
                    [item unbindCell:_viewStorage];
                }
                
                if (!_disableItemBinding)
                    [self _bindItem:item toCell:cell atIndexPath:indexPath];
            }];
            
            return cell;
        }
    }
    
    return [collectionView dequeueReusableCellWithReuseIdentifier:@"_empty" forIndexPath:indexPath];
}

- (void)_bindItem:(TGModernConversationItem *)item toCell:(TGModernCollectionCell *)cell atIndexPath:(NSIndexPath *)__unused indexPath
{
    bool movedFromTemporaryContainer = false;
    
    if (_itemsBoundToTemporaryContainer != nil && [_itemsBoundToTemporaryContainer containsObject:item])
    {
        [_itemsBoundToTemporaryContainer removeObject:item];
        [item moveToCell:cell];
        movedFromTemporaryContainer = true;
        
#if TGModernConversationControllerLogCellOperations
        TGLog(@"(restore item %d)", indexPath.item);
#endif
    }
    
    if (!movedFromTemporaryContainer)
    {
#if TGModernConversationControllerLogCellOperations
        TGLog(@"dequeue cell at %d (bind)", indexPath.item);
#endif
        
        if (item.boundCell != nil)
            [item unbindCell:_viewStorage];
        
        [item bindCell:cell viewStorage:_viewStorage];
    }
}

- (void)collectionView:(UICollectionView *)__unused collectionView didEndDisplayingCell:(TGModernCollectionCell *)cell forItemAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0)
    {
        if (cell.boundItem != nil)
        {
#if TGModernConversationControllerLogCellOperations
            TGLog(@"enqueue cell at %d (unbind)", indexPath.item);
#endif
            TGModernConversationItem *item = cell.boundItem;
            [item unbindCell:_viewStorage];
        }
        else
        {
#if TGModernConversationControllerLogCellOperations
            TGLog(@"enqueue cell at %d (clear)", indexPath.item);
#endif
        }
    }
}

#pragma mark -

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    if (scrollView == _collectionView)
    {
        //if (!_disableScrollProcessing)
        //    _disableScrollProcessing = false;
    }
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    if (scrollView == _collectionView)
    {
        if (_unseenMessagesButton != nil && _unseenMessagesButton.superview != nil && scrollView.contentOffset.y <= -scrollView.contentInset.top)
        {
            [self setHasUnseenMessagesBelow:false];
        }
        
        if (scrollView.contentSize.height > FLT_EPSILON && !_disableScrollProcessing)
        {
            if ((NSInteger)_items.count >= TGModernConversationControllerUnloadHistoryLimit + TGModernConversationControllerUnloadHistoryThreshold)
                [self _maybeUnloadHistory];
            
            if (_enableAboveHistoryRequests && scrollView.contentOffset.y > scrollView.contentSize.height - 800 * 2.0f && scrollView.contentSize.height > FLT_EPSILON)
                [_companion loadMoreMessagesAbove];
            
            if (_enableBelowHistoryRequests && scrollView.contentOffset.y < 600 * 2.0f)
                [_companion loadMoreMessagesBelow];
        }
    }
}

- (BOOL)scrollViewShouldScrollToTop:(UIScrollView *)scrollView
{
    if (scrollView == _collectionViewScrollToTopProxy)
    {
        [_collectionView scrollToTopIfNeeded];
        return false;
    }
    
    return false;
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)__unused gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)__unused otherGestureRecognizer
{
    return true;
}

static CGPoint locationForKeyboardWindowWithOffset(CGFloat offset, UIInterfaceOrientation orientation)
{
    switch (orientation)
    {
        case UIInterfaceOrientationPortrait:
            return CGPointMake(0.0f, offset);
    }
    
    return CGPointZero;
}

- (void)collectionViewPan:(UIPanGestureRecognizer *)recognizer
{
#ifndef DEBUG

#endif
    
        return;
    
    switch (recognizer.state)
    {
        case UIGestureRecognizerStateBegan:
        {
            _collectionPanTouchContentOffset = CGPointMake(_collectionView.contentOffset.x, _collectionView.contentOffset.y + ([recognizer locationInView:self.view].y - (_keyboardHeight + _currentInputPanel.frame.size.height)));
            _collectionPanStartedAtBottom = _collectionView.contentOffset.y < -_collectionView.contentInset.top + 10;
            
            break;
        }
        case UIGestureRecognizerStateChanged:
        {
            CGPoint currentTouchPoint = [recognizer locationInView:self.view];
            CGSize collectionViewSize = [self collectionViewSizeForInterfaceOrientation:self.interfaceOrientation];
            
            CGRect inputContainerFrame = _currentInputPanel.frame;
            CGFloat keyboardHeightWithOffset = MIN(_keyboardHeight, MAX(collectionViewSize.height - (currentTouchPoint.y + inputContainerFrame.size.height), 0.0f));
            inputContainerFrame.origin = CGPointMake(0.0f, collectionViewSize.height - inputContainerFrame.size.height - keyboardHeightWithOffset);
            _currentInputPanel.frame = inputContainerFrame;
            
            UIView *keyboardWindow = [TGHacks applicationKeyboardWindow];
            CGRect keyboardWindowFrame = keyboardWindow.frame;
            keyboardWindowFrame.origin = locationForKeyboardWindowWithOffset(_keyboardHeight - keyboardHeightWithOffset, self.interfaceOrientation);
            if (!CGRectEqualToRect(keyboardWindow.frame, keyboardWindowFrame))
                keyboardWindow.frame = keyboardWindowFrame;
            
            break;
        }
        case UIGestureRecognizerStateEnded:
        case UIGestureRecognizerStateCancelled:
        {
            dispatch_async(dispatch_get_main_queue(), ^
            {
                [_collectionView stopScrollingAnimation];
                
                CGSize collectionViewSize = [self collectionViewSizeForInterfaceOrientation:self.interfaceOrientation];
                
                [UIView animateWithDuration:0.2 animations:^
                {
                    CGRect inputContainerFrame = _currentInputPanel.frame;
                    inputContainerFrame.origin = CGPointMake(0.0f, collectionViewSize.height - inputContainerFrame.size.height - _keyboardHeight);
                    _currentInputPanel.frame = inputContainerFrame;
                    
                    UIView *keyboardWindow = [TGHacks applicationKeyboardWindow];
                    CGRect keyboardWindowFrame = keyboardWindow.frame;
                    keyboardWindowFrame.origin = locationForKeyboardWindowWithOffset(0.0f, self.interfaceOrientation);
                    if (!CGRectEqualToRect(keyboardWindow.frame, keyboardWindowFrame))
                        keyboardWindow.frame = keyboardWindowFrame;
                }];
                
                [self _adjustCollectionViewForOrientation:self.interfaceOrientation keyboardHeight:_keyboardHeight inputContainerHeight:_currentInputPanel.frame.size.height scrollToBottom:_collectionPanStartedAtBottom duration:0.2 animationCurve:0];
            });
            
            break;
        }
        default:
            break;
    }
}

#pragma mark -

- (void)replaceItems:(NSArray *)newItems
{
    [_items removeAllObjects];
    [_items addObjectsFromArray:newItems];
    
    if (self.isViewLoaded)
    {
        [_collectionView reloadData];
    }
}

- (void)replaceItemsWithFastScroll:(NSArray *)newItems intent:(TGModernConversationInsertItemIntent)intent
{
    NSMutableArray *storedCells = [[NSMutableArray alloc] init];
    for (TGModernCollectionCell *cell in _collectionView.visibleCells)
    {
        if (cell.boundItem != nil)
        {
            TGModernCollectionCell *cellCopy = [[TGModernCollectionCell alloc] initWithFrame:[_collectionView convertRect:cell.frame toView:self.view]];
            [(TGMessageModernConversationItem *)cell.boundItem moveToCell:cellCopy];
            [storedCells addObject:cellCopy];
        }
    }
    
    [_items removeAllObjects];
    [_collectionView reloadData];
    
    if (storedCells.count != 0)
    {
        if (intent == TGModernConversationInsertItemIntentSendTextMessage)
        {
            _inputTextPanel.maybeInputField.oneTimeLongAnimation = true;
            [_inputTextPanel.maybeInputField setText:@"" animated:true];
        }
        
        [_items addObjectsFromArray:newItems];
        
        [_collectionView reloadData];
        [_collectionView setContentOffset:CGPointMake(0.0f, -_collectionView.contentInset.top) animated:false];
        [_collectionView layoutSubviews];
        
        NSMutableArray *currentCellsWithFrames = [[NSMutableArray alloc] init];
        CGFloat minStoredCellY = CGFLOAT_MAX;
        for (TGModernCollectionCell *cell in storedCells)
        {
            cell.frame = [_collectionView convertRect:cell.frame fromView:self.view];
            minStoredCellY = MIN(minStoredCellY, cell.frame.origin.y);
            [_collectionView addSubview:cell];
        }

        CGFloat maxCurrentCellY = CGFLOAT_MIN;
        for (TGModernCollectionCell *cell in _collectionView.visibleCells)
        {
            maxCurrentCellY = MAX(maxCurrentCellY, CGRectGetMaxY(cell.frame));
        }
        
        CGFloat offsetDifference = minStoredCellY - maxCurrentCellY;
        
        for (TGModernCollectionCell *cell in _collectionView.visibleCells)
        {
            maxCurrentCellY = MAX(maxCurrentCellY, CGRectGetMaxY(cell.frame));
            
            [currentCellsWithFrames addObject:@[cell, [NSValue valueWithCGRect:cell.frame]]];
            cell.frame = CGRectOffset(cell.frame, 0.0f, offsetDifference);
        }
        
        NSMutableArray *currentDecorationsWithFrames = [[NSMutableArray alloc] init];
        for (UIView *decoration in [_collectionView visibleDecorations])
        {
            [currentDecorationsWithFrames addObject:@[decoration, [NSValue valueWithCGRect:decoration.frame]]];
            decoration.frame = CGRectOffset(decoration.frame, 0.0f, offsetDifference);
        }
        
        [UIView animateWithDuration:0.3 delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^
        {
            for (TGModernCollectionCell *cell in storedCells)
            {
                cell.frame = CGRectOffset(cell.frame, 0.0f, -offsetDifference);
            }
            
            for (NSArray *desc in currentCellsWithFrames)
            {
                TGModernCollectionCell *cell = desc[0];
                cell.frame = [(NSValue *)desc[1] CGRectValue];
            }
            
            for (NSArray *desc in currentDecorationsWithFrames)
            {
                UIView *decoration = desc[0];
                decoration.frame = [(NSValue *)desc[1] CGRectValue];
            }
        } completion:^(__unused BOOL finished)
        {
            for (TGModernCollectionCell *cell in storedCells)
            {
                [cell removeFromSuperview];
            }
        }];
    }
    else
    {
        if (intent == TGModernConversationInsertItemIntentSendTextMessage)
            [_inputTextPanel.maybeInputField setText:@"" animated:false];
        
        [_collectionView setContentOffset:CGPointMake(0.0f, -_collectionView.contentInset.top) animated:false];
    }
}

- (void)replaceItems:(NSArray *)items atIndices:(NSIndexSet *)indices
{
    [_items replaceObjectsAtIndexes:indices withObjects:items];
    [_collectionView reloadData];
}

- (void)deleteItemsAtIndices:(NSIndexSet *)indexSet animated:(bool)animated
{
    [self _deleteItemsAtIndices:indexSet animated:animated animationFactor:0.7f];
}

- (void)_deleteItemsAtIndices:(NSIndexSet *)indexSet animated:(bool)animated animationFactor:(float)animationFactor
{
    NSMutableIndexSet *indexSetAnimated = [[NSMutableIndexSet alloc] initWithIndexSet:indexSet];
    
    if (true)
    {
        CGFloat referenceContentOffset = _collectionView.contentOffset.y;
        CGFloat referenceContentBoundsOffset = referenceContentOffset + _collectionView.bounds.size.height;
        
        NSUInteger lastVisibleOfCurrentIndices = NSNotFound;
        NSUInteger farthestVisibleOfCurrentIndices = NSNotFound;
        
        int currentItemCount = _items.count;
        for (int i = 0; i < currentItemCount; i++)
        {
            UICollectionViewLayoutAttributes *attributes = [_collectionLayout layoutAttributesForItemAtIndexPath:[NSIndexPath indexPathForItem:i inSection:0]];
            CGRect itemFrame = attributes.frame;
            
            if (CGRectGetMaxY(itemFrame) > referenceContentOffset + FLT_EPSILON)
            {
                if (i != 0 || itemFrame.origin.y < referenceContentOffset - FLT_EPSILON)
                    lastVisibleOfCurrentIndices = i;
                break;
            }
        }
        for (int i = currentItemCount - 1; i >= 0; i--)
        {
            UICollectionViewLayoutAttributes *attributes = [_collectionLayout layoutAttributesForItemAtIndexPath:[NSIndexPath indexPathForItem:i inSection:0]];
            CGRect itemFrame = attributes.frame;
            
            if (itemFrame.origin.y < referenceContentBoundsOffset + FLT_EPSILON)
            {
                if (i != currentItemCount - 1 || CGRectGetMaxY(itemFrame) > referenceContentBoundsOffset - FLT_EPSILON)
                    farthestVisibleOfCurrentIndices = i;
                break;
            }
        }
        
        if (lastVisibleOfCurrentIndices != NSNotFound)
        {
            bool partialReloadRequired = false;

            NSMutableIndexSet *indicesToRemoveWithoutAnimation = [[NSMutableIndexSet alloc] init];
            
            NSUInteger indexCount = indexSetAnimated.count;
            for (NSUInteger i = 0; i < indexCount; i++)
            {
                NSUInteger currentIndex = [indexSetAnimated firstIndex];
                if (currentIndex == NSNotFound || currentIndex >= lastVisibleOfCurrentIndices)
                    break;
                else
                {
                    [indicesToRemoveWithoutAnimation addIndex:currentIndex];
                    [indexSetAnimated removeIndex:currentIndex];
                    
                    partialReloadRequired = true;
                }
            }
            
            if (indicesToRemoveWithoutAnimation.count != 0)
            {
                [indexSetAnimated shiftIndexesStartingAtIndex:[indicesToRemoveWithoutAnimation firstIndex] by:-indicesToRemoveWithoutAnimation.count];
                [_items removeObjectsAtIndexes:indicesToRemoveWithoutAnimation];
            }
            
            if (partialReloadRequired)
            {
                CGFloat previousContentHeight = _collectionLayout.collectionViewContentSize.height;
                [_collectionLayout prepareLayout];
                CGFloat currentContentHeight = _collectionLayout.collectionViewContentSize.height;
                
                [self _beginReloadDataWithTemporaryContainer];
                _collectionView.contentOffset = CGPointMake(0.0f, _collectionView.contentOffset.y + (currentContentHeight - previousContentHeight));
                [self _endReloadDataWithTemporaryContainer];
                
                [_collectionView updateRelativeBounds];
            }
        }
        
        if (farthestVisibleOfCurrentIndices != NSNotFound)
        {
            bool partialReloadRequired = false;
            
            NSMutableIndexSet *indicesToRemoveWithoutAnimation = [[NSMutableIndexSet alloc] init];
            
            NSUInteger indexCount = indexSetAnimated.count;
            for (NSUInteger i = 0; i < indexCount; i++)
            {
                NSUInteger currentIndex = [indexSetAnimated lastIndex];
                if (currentIndex == NSNotFound || currentIndex <= farthestVisibleOfCurrentIndices)
                    break;
                else
                {
                    [indicesToRemoveWithoutAnimation addIndex:currentIndex];
                    [indexSetAnimated removeIndex:currentIndex];
                    
                    partialReloadRequired = true;
                }
            }
            
            if (indicesToRemoveWithoutAnimation.count != 0)
                [_items removeObjectsAtIndexes:indicesToRemoveWithoutAnimation];
            
            if (partialReloadRequired)
            {
                [self _beginReloadDataWithTemporaryContainer];
                [self _endReloadDataWithTemporaryContainer];
                
                [_collectionView updateRelativeBounds];
            }
        }
    }
    
    if (indexSetAnimated.count != 0)
    {
        [_items removeObjectsAtIndexes:indexSetAnimated];
        
        if (animated && indexSetAnimated.count < 100)
        {
            if (iosMajorVersion() >= 7)
                [TGHacks setSecondaryAnimationDurationFactor:animationFactor];
            else
                [TGHacks setAnimationDurationFactor:animationFactor];
            
#ifndef DEBUG
            @try
#endif
            {
                NSUInteger indexPathCount = indexSetAnimated.count;
                NSMutableArray *indexPaths = [[NSMutableArray alloc] initWithCapacity:indexPathCount];
                NSUInteger currentIndex = [indexSetAnimated firstIndex];
                for (NSUInteger i = 0; i < indexPathCount; i++)
                {
                    [indexPaths addObject:[NSIndexPath indexPathForItem:currentIndex inSection:0]];
                    currentIndex = [indexSetAnimated indexGreaterThanIndex:currentIndex];
                }
                
                [_collectionView performBatchUpdates:^
                {
                    [_collectionView deleteItemsAtIndexPaths:indexPaths];
                } completion:nil beforeDecorations:nil animated:true animationFactor:animationFactor];
            }
#ifndef DEBUG
            @catch (NSException *e)
            {
                TGLog(@"%@", e);
                [self _resetCollectionView];
            }
#endif
            [TGHacks setSecondaryAnimationDurationFactor:1.0f];
            [TGHacks setAnimationDurationFactor:1.0f];
            
            [_collectionView updateRelativeBounds];
        }
        else
        {
            [self _beginReloadDataWithTemporaryContainer];
            [self _endReloadDataWithTemporaryContainer];
            
            [_collectionView updateRelativeBounds];
        }
    }
}

- (void)moveItems:(NSArray *)moveIndexPairs
{
    NSMutableArray *movingItems = [[NSMutableArray alloc] init];
    
    for (NSArray *pair in moveIndexPairs)
    {
        id item = _items[[pair[0] intValue]];
        [movingItems addObject:item];
        [_items removeObjectAtIndex:[pair[0] intValue]];
    }
    
    int index = movingItems.count;
    for (NSArray *pair in moveIndexPairs.reverseObjectEnumerator)
    {
        index--;
        [_items insertObject:movingItems[index] atIndex:[pair[1] intValue]];
    }
    
#ifndef DEBUG
    @try
#endif
    {
        [_collectionView performBatchUpdates:^
        {
            for (NSArray *pair in moveIndexPairs)
            {
                [_collectionView moveItemAtIndexPath:[NSIndexPath indexPathForItem:[pair[0] intValue] inSection:0] toIndexPath:[NSIndexPath indexPathForItem:[pair[1] intValue] inSection:0]];
            }
        } completion:nil];
    }
#ifndef DEBUG
    @catch (NSException *e)
    {
        TGLog(@"%@", e);
        
        [self _resetCollectionView];
    }
#endif
    
    [_collectionView updateRelativeBounds];
}

- (void)insertItems:(NSArray *)itemsArray atIndices:(NSIndexSet *)indexSet animated:(bool)animated intent:(TGModernConversationInsertItemIntent)intent
{
    if (indexSet.count != itemsArray.count)
    {
        TGLog(@"***** %s:%s: indices.count != insertedItems.count", __FILE__, __PRETTY_FUNCTION__);
        return;
    }
    
    NSMutableArray *insertItemsAnimated = [[NSMutableArray alloc] initWithArray:itemsArray];
    NSMutableIndexSet *insertIndicesAnimated = [[NSMutableIndexSet alloc] initWithIndexSet:indexSet];
    
    if (true)
    {
        CGFloat referenceContentOffset = _collectionView.contentOffset.y + _collectionView.contentInset.top;
        
        NSUInteger lastVisibleOfCurrentIndices = NSNotFound;
        
        NSUInteger currentItemCount = _items.count;
        for (NSUInteger i = 0; i < currentItemCount; i++)
        {
            UICollectionViewLayoutAttributes *attributes = [_collectionLayout layoutAttributesForItemAtIndexPath:[NSIndexPath indexPathForItem:i inSection:0]];
            CGRect itemFrame = attributes.frame;
            if (CGRectGetMaxY(itemFrame) > referenceContentOffset + FLT_EPSILON)
            {
                if (i != 0 || itemFrame.origin.y < referenceContentOffset - FLT_EPSILON)
                    lastVisibleOfCurrentIndices = i;
                break;
            }
        }
        
        bool partialReloadRequired = false;
        
        if (lastVisibleOfCurrentIndices != NSNotFound || intent == TGModernConversationInsertItemIntentLoadMoreMessagesBelow)
        {
            bool hadIncomingUnread = false;
            
            NSUInteger modifiedLastVisibleOfCurrentIndices = lastVisibleOfCurrentIndices;
            NSUInteger insertedItems = 0;
            
            for (NSUInteger i = 0; i < insertItemsAnimated.count; i++)
            {
                NSUInteger currentIndex = [insertIndicesAnimated firstIndex];
                if ((intent != TGModernConversationInsertItemIntentLoadMoreMessagesBelow && currentIndex > modifiedLastVisibleOfCurrentIndices) || currentIndex == NSNotFound)
                    break;
                else
                {
                    [_items insertObject:insertItemsAnimated[i] atIndex:currentIndex];
                    insertedItems++;
                    
                    if (intent != TGModernConversationInsertItemIntentLoadMoreMessagesBelow)
                    {
                        TGMessageModernConversationItem *messageItem = insertItemsAnimated[i];
                        if (!messageItem->_message.outgoing && messageItem->_message.unread)
                            hadIncomingUnread = true;
                    }
                    
                    [insertIndicesAnimated removeIndex:currentIndex];
                    
                    if (modifiedLastVisibleOfCurrentIndices != NSNotFound)
                        modifiedLastVisibleOfCurrentIndices++;
                    
                    partialReloadRequired = true;
                }
            }
            
            if (insertedItems != 0)
                [insertItemsAnimated removeObjectsInRange:NSMakeRange(0, insertedItems)];
            
            if (hadIncomingUnread)
                [self setHasUnseenMessagesBelow:true];
        }
        
        if (partialReloadRequired)
        {
            CGFloat previousContentHeight = _collectionLayout.collectionViewContentSize.height;
            [_collectionLayout prepareLayout];
            CGFloat currentContentHeight = _collectionLayout.collectionViewContentSize.height;
            
            [self _beginReloadDataWithTemporaryContainer];
            _collectionView.contentOffset = CGPointMake(0.0f, _collectionView.contentOffset.y + (currentContentHeight - previousContentHeight));
            [self _endReloadDataWithTemporaryContainer];
        }
    }
    
    if (insertIndicesAnimated.count != 0)
    {
        [_items insertObjects:insertItemsAnimated atIndexes:insertIndicesAnimated];
        
        if (animated)
        {
            if (iosMajorVersion() >= 7)
                [TGHacks setSecondaryAnimationDurationFactor:0.7f];
            else
                [TGHacks setAnimationDurationFactor:0.7f];
        
#ifndef DEBUG
            @try
#endif
            {
                NSUInteger indexPathCount = insertIndicesAnimated.count;
                NSMutableArray *indexPaths = [[NSMutableArray alloc] initWithCapacity:indexPathCount];
                NSUInteger currentIndex = [insertIndicesAnimated firstIndex];
                for (NSUInteger i = 0; i < indexPathCount; i++)
                {
                    [indexPaths addObject:[NSIndexPath indexPathForItem:currentIndex inSection:0]];
                    currentIndex = [insertIndicesAnimated indexGreaterThanIndex:currentIndex];
                }
                
                [_collectionView performBatchUpdates:^
                {
                    [_collectionView insertItemsAtIndexPaths:indexPaths];
                } completion:nil beforeDecorations:^
                {
                    if (intent == TGModernConversationInsertItemIntentSendTextMessage || intent == TGModernConversationInsertItemIntentSendOtherMessage)
                    {
                        if (intent == TGModernConversationInsertItemIntentSendTextMessage)
                        {
                            _inputTextPanel.maybeInputField.oneTimeLongAnimation = true;
                            [_inputTextPanel.maybeInputField setText:@""];
                        }
                        
                        [_collectionView scrollRectToVisible:CGRectMake(0.0f, 0.0f, 1.0f, 1.0f) animated:true];
                    }
                } animated:true animationFactor:0.7f];
            }
#ifndef DEBUG
            @catch (NSException *e)
            {
                TGLog(@"%@", e);
                [self _resetCollectionView];
            }
#endif

            [TGHacks setSecondaryAnimationDurationFactor:1.0f];
            [TGHacks setAnimationDurationFactor:1.0f];
            
            [_collectionView updateRelativeBounds];
        }
        else
        {
            [self _beginReloadDataWithTemporaryContainer];
            [self _endReloadDataWithTemporaryContainer];
            [_collectionView updateRelativeBounds];
            
            if (intent == TGModernConversationInsertItemIntentSendTextMessage || intent == TGModernConversationInsertItemIntentSendOtherMessage)
            {
                if (intent == TGModernConversationInsertItemIntentSendTextMessage)
                {
                    _inputTextPanel.maybeInputField.oneTimeLongAnimation = true;
                    [_inputTextPanel.maybeInputField setText:@"" animated:true];
                }
                
                [_collectionView scrollRectToVisible:CGRectMake(0.0f, 0.0f, 1.0f, 1.0f) animated:true];
            }
        }
    }
    else if (intent == TGModernConversationInsertItemIntentSendTextMessage || intent == TGModernConversationInsertItemIntentSendOtherMessage)
    {
        if (intent == TGModernConversationInsertItemIntentSendTextMessage)
        {
            [_inputTextPanel.maybeInputField setText:@"" animated:false];
        }
        
        [_collectionView scrollRectToVisible:CGRectMake(0.0f, 0.0f, 1.0f, 1.0f) animated:true];
    }
    
    if (_enableUnloadHistoryRequests && (NSInteger)_items.count >= TGModernConversationControllerUnloadHistoryLimit + TGModernConversationControllerUnloadHistoryThreshold)
        [self _maybeUnloadHistory];
    
    if (intent == TGModernConversationInsertItemIntentGeneric && _items.count != 0 && _streamAudioItems && _currentStreamingAudioMessageId == 0)
    {
        for (TGMessageModernConversationItem *item in _items.reverseObjectEnumerator)
        {
            if (!item->_message.outgoing && [itemsArray containsObject:item])
            {
                for (id attachment in item->_message.mediaAttachments)
                {
                    if ([attachment isKindOfClass:[TGAudioMediaAttachment class]])
                    {
                        _currentStreamingAudioMessageId = item->_message.mid;
                        
                        if (item->_mediaAvailabilityStatus)
                            [self playAudioFromMessage:item->_message.mid media:attachment];
                        break;
                    }
                }
            }
        }
    }
}

- (void)updateItemAtIndex:(NSUInteger)index toItem:(TGModernConversationItem *)updatedItem
{
    [_items[index] updateToItem:updatedItem viewStorage:_viewStorage];
    
    TGMessageModernConversationItem *item = (TGMessageModernConversationItem *)updatedItem;
    if (_streamAudioItems && _currentStreamingAudioMessageId == item->_message.mid && item->_mediaAvailabilityStatus)
    {
        for (id attachment in item->_message.mediaAttachments)
        {
            if ([attachment isKindOfClass:[TGAudioMediaAttachment class]])
            {
                [self playAudioFromMessage:item->_message.mid media:attachment];
                break;
            }
        }
    }
}

- (void)updateItemProgressAtIndex:(NSUInteger)index toProgress:(float)progress
{
    [_items[index] updateProgress:progress viewStorage:_viewStorage];
}

- (void)imageDataInvalidated:(NSString *)imageUrl
{
    if (_collectionView != nil)
    {
        for (TGModernCollectionCell *cell in [_collectionView visibleCells])
        {
            [(TGMessageModernConversationItem *)cell.boundItem imageDataInvalidated:imageUrl];
        }
    }
    else
    {
        for (TGMessageModernConversationItem *messageItem in _items)
        {
            [messageItem imageDataInvalidated:imageUrl];
        }
    }
}

- (void)updateCheckedMessages
{
    if (_editingMode)
    {
        for (TGModernCollectionCell *cell in _collectionView.visibleCells)
        {
            [(TGMessageModernConversationItem *)cell.boundItem updateEditingState:_viewStorage animationDelay:0.0];
        }
        
        [self _updateEditingPanel];
    }
}

- (void)updateMessageAttributes:(int32_t)messageId
{
    for (TGMessageModernConversationItem *messageItem in _items)
    {
        if (messageItem->_message.mid == messageId)
        {
            [messageItem updateMessageAttributes];
            
            break;
        }
    }
}

- (void)setHasUnseenMessagesBelow:(bool)hasUnseenMessagesBelow
{
    if (!self.isViewLoaded)
        return;
    
    if (hasUnseenMessagesBelow)
    {
        if (_unseenMessagesButton == nil)
        {
            UIImage *image = [UIImage imageNamed:@"ModernConversationUnseenMessagesButton.png"];
            _unseenMessagesButton = [[UIButton alloc] initWithFrame:CGRectMake(0.0f, 0.0f, image.size.width, image.size.height)];
            [_unseenMessagesButton setImage:image forState:UIControlStateNormal];
            _unseenMessagesButton.adjustsImageWhenHighlighted = false;
            [_unseenMessagesButton addTarget:self action:@selector(unseenMessagesButtonPressed) forControlEvents:UIControlEventTouchUpInside];
        }
        
        if (_unseenMessagesButton.superview == nil)
        {
            [self.view insertSubview:_unseenMessagesButton aboveSubview:_collectionView];
            [self _updateUnseenMessagesButton:self.interfaceOrientation];
        }
    }
    else if (_unseenMessagesButton != nil)
    {
        [_unseenMessagesButton removeFromSuperview];
    }
}

- (void)_updateUnseenMessagesButton:(UIInterfaceOrientation)orientation
{
    if (_unseenMessagesButton.superview != nil)
    {
        CGSize collectionViewSize = [self collectionViewSizeForInterfaceOrientation:orientation];
        
        CGSize buttonSize = _unseenMessagesButton.frame.size;
        _unseenMessagesButton.frame = CGRectMake(collectionViewSize.width - buttonSize.width - 6, collectionViewSize.height - buttonSize.height - _collectionView.contentInset.top - 6, buttonSize.width, buttonSize.height);
    }
}

- (void)_updateEditingPanel
{
    if ([_currentInputPanel isKindOfClass:[TGModernConversationEditingPanel class]])
    {
        TGModernConversationEditingPanel *editingPanel = (TGModernConversationEditingPanel *)_currentInputPanel;
        [editingPanel setActionsEnabled:[_companion checkedMessageCount] != 0];
    }
}

- (void)_beginReloadDataWithTemporaryContainer
{
    _itemsBoundToTemporaryContainer = [[NSMutableArray alloc] init];
    
    UIView *tempContainer = [[UIView alloc] init];
    for (NSIndexPath *indexPath in [_collectionView indexPathsForVisibleItems])
    {
        TGModernCollectionCell *cell = (TGModernCollectionCell *)[_collectionView cellForItemAtIndexPath:indexPath];
        TGModernConversationItem *item = [cell boundItem];
        if (item != nil)
        {
            [item temporaryMoveToView:tempContainer];
            [_itemsBoundToTemporaryContainer addObject:item];
            
#if TGModernConversationControllerLogCellOperations
            TGLog(@"(store item %d)", indexPath.item);
#endif
        }
    }
    
    [_collectionView reloadData];
}

- (void)_endReloadDataWithTemporaryContainer
{
    [_collectionView updateVisibleItemsNow];
    
    for (NSIndexPath *indexPath in _collectionView.indexPathsForVisibleItems)
    {
        TGModernCollectionCell *cell = (TGModernCollectionCell *)[_collectionView cellForItemAtIndexPath:indexPath];
        if (cell.boundItem == nil)
        {
            [self _bindItem:_items[indexPath.row] toCell:cell atIndexPath:indexPath];
        }
    }
    
    for (TGModernConversationItem *item in _itemsBoundToTemporaryContainer)
    {
        [item unbindCell:_viewStorage];
    }
    
    _itemsBoundToTemporaryContainer = nil;
}

- (void)updateItems:(NSArray *)updatedItems atIndices:(NSArray *)indices
{
    if (indices.count == 0)
        return;
    
    if (indices.count != updatedItems.count)
    {
        TGLog(@"***** %s:%s: indices.count != updatedItems", __FILE__, __PRETTY_FUNCTION__);
        return;
    }
    
    int index = -1;
    for (NSNumber *nIndex in indices)
    {
        index++;
        [(TGModernConversationItem *)_items[[nIndex intValue]] updateToItem:updatedItems[index] viewStorage:_viewStorage];
    }
}

- (void)openMediaFromMessage:(int32_t)messageId instant:(bool)instant
{
    TGMessageModernConversationItem *mediaMessageItem = nil;
    TGModernCollectionCell *mediaItemCell = nil;
    
    int index = -1;
    for (TGMessageModernConversationItem *messageItem in _items)
    {
        index++;
        
        if (messageItem->_message.mid == messageId)
        {
            TGModernCollectionCell *cell = (TGModernCollectionCell *)[_collectionView cellForItemAtIndexPath:[NSIndexPath indexPathForItem:index inSection:0]];
            if (messageItem->_mediaAvailabilityStatus && cell != nil)
            {
                mediaMessageItem = messageItem;
                mediaItemCell = cell;
            }
            
            break;
        }
    }
    
    if (mediaMessageItem != nil && index >= 0)
    {
        TGUser *author = [TGDatabaseInstance() loadUser:mediaMessageItem->_message.outgoing ? TGTelegraphInstance.clientUserId : (int32_t)mediaMessageItem->_message.fromUid];
        if (author == nil)
            return;
        
        bool isGallery = false;
        bool isAvatar = false;
        TGImageInfo *avatarImageInfo = nil;
        bool foundMedia = false;
        
        for (TGMediaAttachment *attachment in mediaMessageItem->_message.mediaAttachments)
        {
            switch (attachment.type)
            {
                case TGVideoMediaAttachmentType:
                case TGImageMediaAttachmentType:
                {
                    foundMedia = true;
                    isGallery = true;
                    
                    break;
                }
                case TGActionMediaAttachmentType:
                {
                    TGActionMediaAttachment *actionAttachment = (TGActionMediaAttachment *)attachment;
                    switch (actionAttachment.actionType)
                    {
                        case TGMessageActionChatEditPhoto:
                        {
                            foundMedia = true;
                            
                            TGImageMediaAttachment *photo = actionAttachment.actionData[@"photo"];
                            
                            isAvatar = true;
                            avatarImageInfo = photo.imageInfo;
                            
                            break;
                        }
                        default:
                            break;
                    }
                    
                    break;
                }
                case TGLocationMediaAttachmentType:
                {
                    TGLocationMediaAttachment *mapAttachment = (TGLocationMediaAttachment *)attachment;
                    TGMapViewController *mapController = [[TGMapViewController alloc] initInMapModeWithLatitude:mapAttachment.latitude longitude:mapAttachment.longitude user:[TGDatabaseInstance() loadUser:(int32_t)mediaMessageItem->_message.fromUid]];
                    mapController.watcher = _companion.actionHandle;
                    if ([_companion allowMessageForwarding])
                        mapController.message = mediaMessageItem->_message;
                    
                    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone)
                        [self.navigationController pushViewController:mapController animated:true];
                    else
                    {
                        TGNavigationController *navigationController = [TGNavigationController navigationControllerWithControllers:@[mapController]];
                        navigationController.presentationStyle = TGNavigationControllerPresentationStyleInFormSheet;
                        navigationController.modalPresentationStyle = UIModalPresentationFormSheet;
                        [self presentViewController:navigationController animated:true completion:nil];
                    }
                    
                    break;
                }
                case TGDocumentMediaAttachmentType:
                {
                    TGDocumentMediaAttachment *documentAttachment = (TGDocumentMediaAttachment *)attachment;
                    
                    if ([[[documentAttachment.fileName pathExtension] lowercaseString] isEqualToString:@"strings"])
                    {
                        [[[TGActionSheet alloc] initWithTitle:nil actions:@[
                            [[TGActionSheetAction alloc] initWithTitle:TGLocalized(@"Conversation.ApplyLocalization") action:@"applyLocalization"],
                            [[TGActionSheetAction alloc] initWithTitle:TGLocalized(@"Conversation.OpenFile") action:@"open"],
                            [[TGActionSheetAction alloc] initWithTitle:TGLocalized(@"Common.Cancel") action:@"cancel" type:TGActionSheetActionTypeCancel],
                        ] actionBlock:^(TGModernConversationController *controller, NSString *action)
                        {
                            if ([action isEqualToString:@"applyLocalization"])
                            {
                                NSBundle *referenceBundle = [NSBundle bundleWithPath:[[NSBundle mainBundle] pathForResource:@"en" ofType:@"lproj"]];
                                NSDictionary *referenceDict = [NSDictionary dictionaryWithContentsOfFile:[referenceBundle pathForResource:@"Localizable" ofType:@"strings"]];
                                
                                NSDictionary *localizationDict = [NSDictionary dictionaryWithContentsOfFile:[_companion fileUrlForDocumentMedia:documentAttachment].path];
                                
                                __block bool valid = true;
                                NSMutableArray *missingKeys = [[NSMutableArray alloc] init];
                                NSMutableArray *invalidFormatKeys = [[NSMutableArray alloc] init];
                                NSString *invalidFileString = nil;
                                
                                if (localizationDict != nil && referenceDict != nil)
                                {
                                    [referenceDict enumerateKeysAndObjectsUsingBlock:^(NSString *key, NSString *sourceValue, __unused BOOL *stop)
                                    {
                                        NSString *targetValue = localizationDict[key];
                                        if (targetValue == nil)
                                        {
                                            [missingKeys addObject:key];
                                        }
                                        else
                                        {
                                            for (int i = 0; i < 2; i++)
                                            {
                                                NSString *firstValue = i == 0 ? sourceValue : targetValue;
                                                NSString *secondValue = i == 0 ? targetValue : sourceValue;
                                                
                                                NSRange firstRange = NSMakeRange(0, firstValue.length);
                                                NSRange secondRange = NSMakeRange(0, secondValue.length);
                                                
                                                while (firstRange.length != 0)
                                                {
                                                    NSRange range = [firstValue rangeOfString:@"%" options:0 range:firstRange];
                                                    if (range.location == NSNotFound || range.location == firstValue.length - 1)
                                                        break;
                                                    else
                                                    {
                                                        firstRange.location = range.location + range.length;
                                                        firstRange.length = firstValue.length - firstRange.location;
                                                        
                                                        NSString *findPositionalString = nil;
                                                        NSString *findFreeString = nil;
                                                        
                                                        unichar c = [firstValue characterAtIndex:range.location + 1];
                                                        if (c == 'd' || c == 'f')
                                                            findPositionalString = [[NSString alloc] initWithFormat:@"%%%c", (char)c];
                                                        else if (c >= '0' && c <= '9')
                                                        {
                                                            if (range.location + 3 < firstValue.length)
                                                            {
                                                                if ([firstValue characterAtIndex:range.location + 2] == '$')
                                                                {
                                                                    unichar formatChar = [firstValue characterAtIndex:range.location + 3];
                                                                    
                                                                    findFreeString = [[NSString alloc] initWithFormat:@"%%%c$%c", (char)c, (char)formatChar];
                                                                }
                                                            }
                                                        }
                                                        
                                                        if (findPositionalString != nil)
                                                        {
                                                            NSRange foundRange = [secondValue rangeOfString:findPositionalString options:0 range:secondRange];
                                                            if (foundRange.location != NSNotFound)
                                                            {
                                                                secondRange.location = foundRange.location + foundRange.length;
                                                                secondRange.length = secondValue.length - secondRange.location;
                                                            }
                                                            else
                                                            {
                                                                valid = false;
                                                                [invalidFormatKeys addObject:key];
                                                                
                                                                break;
                                                            }
                                                        }
                                                        else if (findFreeString != nil)
                                                        {
                                                            if ([secondValue rangeOfString:findFreeString].location == NSNotFound)
                                                            {
                                                                valid = false;
                                                                [invalidFormatKeys addObject:key];
                                                                
                                                                break;
                                                            }
                                                        }
                                                    }
                                                }
                                            }
                                        }
                                    }];
                                }
                                else
                                {
                                    valid = false;
                                    
                                    invalidFileString = @"invalid localization file format";
                                }
                                
                                if (valid)
                                {
                                    NSMutableString *missingKeysString = [[NSMutableString alloc] init];
                                    static const int maxKeys = 5;
                                    for (int i = 0; i < maxKeys && i < (int)missingKeys.count; i++)
                                    {
                                        if (missingKeysString.length != 0)
                                            [missingKeysString appendString:@", "];
                                        [missingKeysString appendString:missingKeys[i]];
                                        
                                        if (i == maxKeys - 1 && maxKeys < (int)missingKeys.count)
                                            [missingKeysString appendFormat:@" and %d more", (int)(missingKeys.count - maxKeys)];
                                    }
                                    
                                    if (missingKeysString.length != 0)
                                    {
                                        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:nil message:[[NSString alloc] initWithFormat:@"Localization file is valid, but the following keys are missing: %@", missingKeysString] delegate:nil cancelButtonTitle:TGLocalized(@"Common.OK") otherButtonTitles:nil];
                                        [alertView show];
                                    }
                                    
                                    [controller.companion controllerWantsToApplyLocalization:[_companion fileUrlForDocumentMedia:documentAttachment].path];
                                }
                                else
                                {
                                    NSString *reasonString = nil;
                                    
                                    if (invalidFileString.length != 0)
                                        reasonString = invalidFileString;
                                    else if (invalidFormatKeys.count != 0)
                                    {
                                        NSMutableString *invalidFormatKeysString = [[NSMutableString alloc] init];
                                        static const int maxKeys = 5;
                                        for (int i = 0; i < maxKeys && i < (int)invalidFormatKeys.count; i++)
                                        {
                                            if (invalidFormatKeysString.length != 0)
                                                [invalidFormatKeysString appendString:@", "];
                                            [invalidFormatKeysString appendString:invalidFormatKeys[i]];
                                            
                                            if (i == maxKeys - 1 && maxKeys < (int)invalidFormatKeys.count)
                                                [invalidFormatKeysString appendFormat:@" and %d more", (int)(invalidFormatKeys.count - maxKeys)];
                                        }
                                        reasonString = [[NSString alloc] initWithFormat:@"invalid value format for keys %@", invalidFormatKeysString];
                                    }
                                    
                                    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:nil message:[[NSString alloc] initWithFormat:@"Invalid localization file: %@", reasonString] delegate:nil cancelButtonTitle:TGLocalized(@"Common.OK") otherButtonTitles:nil];
                                    [alertView show];
                                }
                            }
                            else if ([action isEqualToString:@"open"])
                            {
                                TGDocumentController *documentController = [[TGDocumentController alloc] initWithURL:[controller.companion fileUrlForDocumentMedia:documentAttachment]];
                                
                                if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone)
                                    [controller.navigationController pushViewController:documentController animated:true];
                                else
                                {
                                    TGNavigationController *navigationController = [TGNavigationController navigationControllerWithControllers:@[documentController]];
                                    navigationController.presentationStyle = TGNavigationControllerPresentationStyleInFormSheet;
                                    navigationController.modalPresentationStyle = UIModalPresentationFormSheet;
                                    [controller presentViewController:navigationController animated:true completion:nil];
                                }
                            }
                        } target:self] showInView:self.view];
                        
                        break;
                    }
                    
                    TGDocumentController *documentController = [[TGDocumentController alloc] initWithURL:[_companion fileUrlForDocumentMedia:documentAttachment]];
                    
                    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone)
                        [self.navigationController pushViewController:documentController animated:true];
                    else
                    {
                        TGNavigationController *navigationController = [TGNavigationController navigationControllerWithControllers:@[documentController]];
                        navigationController.presentationStyle = TGNavigationControllerPresentationStyleInFormSheet;
                        navigationController.modalPresentationStyle = UIModalPresentationFormSheet;
                        [self presentViewController:navigationController animated:true completion:nil];
                    }
                    
                    break;
                }
                case TGAudioMediaAttachmentType:
                {
                    TGAudioMediaAttachment *audioAttachment = (TGAudioMediaAttachment *)attachment;
                    
                    if (_currentAudioPlayerMessageId != messageId)
                        [self playAudioFromMessage:messageId media:audioAttachment];
                    else
                        [_currentAudioPlayer play];
                    
                    break;
                }
                default:
                    break;
            }
            
            if (foundMedia)
                break;
        }
        
        if (!foundMedia)
            return;
        
        [self stopInlineMediaIfPlaying];
            
        TGModernGalleryController *modernGallery = [[TGModernGalleryController alloc] init];
        
        if (isGallery)
        {
            if (mediaMessageItem->_message.messageLifetime != 0)
            {
                modernGallery.model = [[TGSecretPeerMediaGalleryModel alloc] initWithPeerId:((TGGenericModernConversationCompanion *)_companion).conversationId messageId:mediaMessageItem->_message.mid];
            }
            else
            {
                modernGallery.model = [[TGGenericPeerMediaGalleryModel alloc] initWithPeerId:((TGGenericModernConversationCompanion *)_companion).conversationId atMessageId:mediaMessageItem->_message.mid allowActions:_companion.allowMessageForwarding];
            }
        }
        else if (isAvatar)
        {
            NSString *legacyThumbnailUrl = [avatarImageInfo closestImageUrlWithSize:CGSizeZero resultingSize:NULL];
            NSString *legacyUrl = [avatarImageInfo imageUrlForLargestSize:NULL];
            
            modernGallery.model = [[TGGroupAvatarGalleryModel alloc] initWithMessageId:mediaMessageItem->_message.mid legacyThumbnailUrl:legacyThumbnailUrl legacyUrl:legacyUrl imageSize:CGSizeMake(640.0f, 640.0f)];
        }
        
        __weak TGModernConversationController *weakSelf = self;
        
        modernGallery.itemFocused = ^(id<TGModernGalleryItem> item)
        {
            __strong TGModernConversationController *strongSelf = weakSelf;
            if (strongSelf != nil)
            {
                if ([item conformsToProtocol:@protocol(TGGenericPeerGalleryItem)])
                {
                    id<TGGenericPeerGalleryItem> concreteItem = (id<TGGenericPeerGalleryItem>)item;
                    int32_t messageId = [concreteItem messageId];
                    strongSelf.companion.mediaHiddenMessageId = messageId;
                    
                    for (TGModernCollectionCell *cell in strongSelf->_collectionView.visibleCells)
                    {
                        [(TGMessageModernConversationItem *)[cell boundItem] updateMediaVisibility];
                    }
                }
                else if ([item isKindOfClass:[TGGroupAvatarGalleryItem class]])
                {
                    int32_t messageId = ((TGGroupAvatarGalleryItem *)item).messageId;
                    strongSelf.companion.mediaHiddenMessageId = messageId;
                    
                    for (TGModernCollectionCell *cell in strongSelf->_collectionView.visibleCells)
                    {
                        [(TGMessageModernConversationItem *)[cell boundItem] updateMediaVisibility];
                    }
                }
            }
        };
        
        modernGallery.finishedTransitionIn = ^(__unused id<TGModernGalleryItem> item, TGModernGalleryItemView *itemView)
        {
            if ([itemView isKindOfClass:[TGModernGalleryVideoItemView class]])
            {
                [((TGModernGalleryVideoItemView *)itemView) play];
            }
        };
        
        modernGallery.beginTransitionIn = ^UIView *(id<TGModernGalleryItem> item, TGModernGalleryItemView *itemView)
        {
            __strong TGModernConversationController *strongSelf = weakSelf;
            if (strongSelf != nil)
            {
                if ([item conformsToProtocol:@protocol(TGGenericPeerGalleryItem)])
                {
                    if ([itemView isKindOfClass:[TGModernGalleryVideoItemView class]])
                    {
                        [((TGModernGalleryVideoItemView *)itemView) hidePlayButton];
                    }
                    
                    id<TGGenericPeerGalleryItem> concreteItem = (id<TGGenericPeerGalleryItem>)item;
                    int32_t messageId = [concreteItem messageId];
                    
                    for (TGModernCollectionCell *cell in strongSelf->_collectionView.visibleCells)
                    {
                        TGMessageModernConversationItem *cellItem = [cell boundItem];
                        if (cellItem->_message.mid == messageId)
                        {
                            return [cellItem referenceViewForImageTransition];
                        }
                    }
                }
                else if ([item isKindOfClass:[TGGroupAvatarGalleryItem class]])
                {
                    int32_t messageId = ((TGGroupAvatarGalleryItem *)item).messageId;
                    
                    for (TGModernCollectionCell *cell in strongSelf->_collectionView.visibleCells)
                    {
                        TGMessageModernConversationItem *cellItem = [cell boundItem];
                        if (cellItem->_message.mid == messageId)
                        {
                            return [cellItem referenceViewForImageTransition];
                        }
                    }
                }
            }
            
            return nil;
        };
        
        modernGallery.beginTransitionOut = ^UIView *(id<TGModernGalleryItem> item)
        {
            __strong TGModernConversationController *strongSelf = weakSelf;
            if (strongSelf != nil)
            {
                if ([item conformsToProtocol:@protocol(TGGenericPeerGalleryItem)])
                {
                    id<TGGenericPeerGalleryItem> concreteItem = (id<TGGenericPeerGalleryItem>)item;
                    int32_t messageId = [concreteItem messageId];
                    
                    for (TGModernCollectionCell *cell in strongSelf->_collectionView.visibleCells)
                    {
                        TGMessageModernConversationItem *cellItem = [cell boundItem];
                        if (cellItem->_message.mid == messageId)
                        {
                            return [cellItem referenceViewForImageTransition];
                        }
                    }
                }
                else if ([item isKindOfClass:[TGGroupAvatarGalleryItem class]])
                {
                    int32_t messageId = ((TGGroupAvatarGalleryItem *)item).messageId;
                    
                    for (TGModernCollectionCell *cell in strongSelf->_collectionView.visibleCells)
                    {
                        TGMessageModernConversationItem *cellItem = [cell boundItem];
                        if (cellItem->_message.mid == messageId)
                        {
                            return [cellItem referenceViewForImageTransition];
                        }
                    }
                }
            }
            
            return nil;
        };
        
        modernGallery.completedTransitionOut = ^
        {
            __strong TGModernConversationController *strongSelf = weakSelf;
            if (strongSelf != nil)
            {
                strongSelf.companion.mediaHiddenMessageId = 0;
                
                for (TGModernCollectionCell *cell in strongSelf->_collectionView.visibleCells)
                {
                    [(TGMessageModernConversationItem *)[cell boundItem] updateMediaVisibility];
                }
            }
        };
        
        modernGallery.animateTransition = !instant;
        modernGallery.showInterface = !instant;
        
        TGOverlayControllerWindow *controllerWindow = [[TGOverlayControllerWindow alloc] initWithParentController:self contentController:modernGallery];
        controllerWindow.hidden = false;
    }
}

- (void)audioPlayerDidFinish
{
    int32_t currentStreamingAudioMessageId = _currentStreamingAudioMessageId;
    
    [self stopInlineMediaIfPlaying];
    
    if (_streamAudioItems && currentStreamingAudioMessageId != 0)
    {
        int32_t lastIncomingAudioMessageId = 0;
        TGAudioMediaAttachment *lastIncomingAudioMessageMedia = nil;
        for (TGMessageModernConversationItem *item in _items)
        {
            if (item->_message.outgoing)
                continue;
            
            if (item->_message.mid <= currentStreamingAudioMessageId)
                break;
            
            for (id attachment in item->_message.mediaAttachments)
            {
                if ([attachment isKindOfClass:[TGAudioMediaAttachment class]])
                {
                    lastIncomingAudioMessageId = item->_message.mid;
                    if (item->_mediaAvailabilityStatus)
                        lastIncomingAudioMessageMedia = attachment;
                    
                    break;
                }
            }
        }
        
        if (lastIncomingAudioMessageId != 0)
        {
            _currentStreamingAudioMessageId = lastIncomingAudioMessageId;
            if (lastIncomingAudioMessageMedia != nil)
                [self playAudioFromMessage:lastIncomingAudioMessageId media:lastIncomingAudioMessageMedia];
        }
        else
            _currentStreamingAudioMessageId = 0;
    }
}

- (void)playAudioFromMessage:(int32_t)messageId media:(TGAudioMediaAttachment *)media
{
    [self stopAudioRecording];
    [self stopInlineMediaIfPlaying];
    
    _currentAudioPlayer = [[TGModernConversationAudioPlayer alloc] initWithFilePath:[media localFilePath]];
    _currentAudioPlayer.delegate = self;
    _currentAudioPlayerMessageId = messageId;
    [_currentAudioPlayer play:0.0f];
    
    [self updateInlineMediaContexts];
    
    _streamAudioItems = TGAppDelegateInstance.autoPlayAudio;
    if (_streamAudioItems)
        _currentStreamingAudioMessageId = messageId;
    else
        _currentStreamingAudioMessageId = 0;
}

- (void)closeMediaFromMessage:(int32_t)__unused messageId instant:(bool)__unused instant
{
    self.associatedWindowStack = nil;
    
    _companion.mediaHiddenMessageId = 0;
    
    for (TGModernCollectionCell *cell in _collectionView.visibleCells)
    {
        [(TGMessageModernConversationItem *)[cell boundItem] updateMediaVisibility];
    }
}

- (void)stopInlineMedia
{
    for (TGMessageModernConversationItem *item in _items)
    {
        [item stopInlineMedia];
    }
}

- (void)updateInlineMediaContexts
{
    for (TGMessageModernConversationItem *item in _items)
    {
        [item updateInlineMediaContext];
    }
}

- (void)openBrowserFromMessage:(int32_t)__unused messageId url:(NSString *)url
{
    [(TGApplication *)[TGApplication sharedApplication] openURL:[NSURL URLWithString:url] forceNative:true];
}

- (void)showActionsMenuForUnsentMessage:(int32_t)messageId
{
    TGMessageModernConversationItem *unsentMessageItem = nil;
    
    int unsentMessageCount = 0;
    
    for (TGMessageModernConversationItem *messageItem in _items)
    {
        if (messageItem->_message.mid == messageId)
            unsentMessageItem = messageItem;
        
        if (messageItem->_message.deliveryState == TGMessageDeliveryStateFailed)
            unsentMessageCount++;
    }
    
    if (unsentMessageItem != nil && unsentMessageCount != 0)
    {
        NSMutableArray *actions = [[NSMutableArray alloc] init];
        
        if (unsentMessageItem->_message.text.length != 0)
            [actions addObject:[[TGActionSheetAction alloc] initWithTitle:TGLocalized(@"Conversation.MessageDialogEdit") action:@"editMessage"]];
        
        [actions addObject:[[TGActionSheetAction alloc] initWithTitle:TGLocalized(@"Conversation.MessageDialogRetry") action:@"resendMessage"]];
        
        if (unsentMessageCount > 1)
            [actions addObject:[[TGActionSheetAction alloc] initWithTitle:[[NSString alloc] initWithFormat:TGLocalized(@"Conversation.MessageDialogRetryAll"), unsentMessageCount] action:@"resendAllMessages"]];
        
        [actions addObject:[[TGActionSheetAction alloc] initWithTitle:TGLocalized(@"Conversation.MessageDialogDelete") action:@"deleteMessage"]];
        
        [actions addObject:[[TGActionSheetAction alloc] initWithTitle:TGLocalized(@"Common.Cancel") action:@"cancel" type:TGActionSheetActionTypeCancel]];
        
        [[[TGActionSheet alloc] initWithTitle:TGLocalized(@"Conversation.MessageDeliveryFailed") actions:actions actionBlock:^(TGModernConversationController *controller, NSString *action)
        {
            if ([action isEqualToString:@"editMessage"])
            {
                [controller.companion _deleteMessages:@[@(messageId)] animated:true];
                [controller.companion controllerDeletedMessages:@[@(messageId)]];
                
                _inputTextPanel.inputField.text = unsentMessageItem->_message.text;
            }
            else if ([action isEqualToString:@"resendMessage"])
            {
                [controller.companion controllerWantsToResendMessages:@[@(messageId)]];
            }
            else if ([action isEqualToString:@"resendAllMessages"])
            {
                NSMutableArray *messageIds = [[NSMutableArray alloc] init];
                
                for (TGMessageModernConversationItem *messageItem in controller->_items.reverseObjectEnumerator)
                {
                    if (messageItem->_message.deliveryState == TGMessageDeliveryStateFailed)
                    {
                        [messageIds addObject:@(messageItem->_message.mid)];
                    }
                }
                
                [controller.companion controllerWantsToResendMessages:messageIds];
            }
            else if ([action isEqualToString:@"deleteMessage"])
            {
                [controller.companion _deleteMessages:@[@(messageId)] animated:true];
                [controller.companion controllerDeletedMessages:@[@(messageId)]];
            }
        } target:self] showInView:self.view];
    }
}

- (void)highlightAndShowActionsMenuForMessage:(int32_t)messageId
{
    TGMessageModernConversationItem *highlightedItem = nil;
    
    for (TGModernCollectionCell *cell in _collectionView.visibleCells)
    {
        TGMessageModernConversationItem *messageItem = cell.boundItem;
        if (messageItem != nil && messageItem->_message.mid == messageId)
        {
            CGRect contentFrame = [[cell contentViewForBinding] convertRect:[messageItem effectiveContentFrame] toView:self.view];
            if (CGRectIsNull(contentFrame) || CGRectIsEmpty(contentFrame))
                break;
            
            contentFrame = CGRectIntersection(contentFrame, CGRectMake(0, 0, self.view.frame.size.width, _currentInputPanel.frame.origin.y));
            if (CGRectIsNull(contentFrame) || CGRectIsEmpty(contentFrame))
                break;
            
            if (_menuContainerView == nil)
                _menuContainerView = [[TGMenuContainerView alloc] init];
            
            if (_menuContainerView.superview != self.view)
                [self.view addSubview:_menuContainerView];
            
            _menuContainerView.frame = CGRectMake(0, self.controllerInset.top, self.view.frame.size.width, [self collectionViewSizeForInterfaceOrientation:self.interfaceOrientation].height - self.controllerInset.top - self.controllerInset.bottom);
            
            NSMutableArray *actions = [[NSMutableArray alloc] init];
            if (messageItem->_message.text.length != 0)
                [actions addObject:[[NSDictionary alloc] initWithObjectsAndKeys:TGLocalized(@"Conversation.ContextMenuCopy"), @"title", @"copy", @"action", nil]];
            else if (messageItem->_message.actionInfo == nil && [_companion allowMessageForwarding])
                [actions addObject:[[NSDictionary alloc] initWithObjectsAndKeys:TGLocalized(@"Conversation.ContextMenuForward"), @"title", @"forward", @"action", nil]];
            
            [actions addObject:[[NSDictionary alloc] initWithObjectsAndKeys:TGLocalized(@"Conversation.ContextMenuDelete"), @"title", @"delete", @"action", nil]];
            if (messageItem->_message.actionInfo == nil)
                [actions addObject:[[NSDictionary alloc] initWithObjectsAndKeys:TGLocalized(@"Conversation.ContextMenuMore"), @"title", @"select", @"action", nil]];
            
            if (TGIsArabic())
            {
                NSMutableArray *reversedActions = [[NSMutableArray alloc] init];
                for (id item in actions.reverseObjectEnumerator)
                {
                    [reversedActions addObject:item];
                }
                actions = reversedActions;
            }
            
            [_menuContainerView.menuView setUserInfo:@{@"mid": @(messageId)}];
            [_menuContainerView.menuView setButtonsAndActions:actions watcherHandle:_actionHandle];
            [_menuContainerView.menuView sizeToFit];
            [_menuContainerView showMenuFromRect:[_menuContainerView convertRect:contentFrame fromView:self.view]];
            
            highlightedItem = messageItem;
            [highlightedItem setTemporaryHighlighted:true viewStorage:_viewStorage];
            
            break;
        }
    }
    
    for (TGModernCollectionCell *cell in _collectionView.visibleCells)
    {
        TGMessageModernConversationItem *messageItem = cell.boundItem;
        if (messageItem != highlightedItem)
            [messageItem setTemporaryHighlighted:false viewStorage:_viewStorage];
    }
}

- (void)showActionsMenuForLink:(NSString *)url
{
    if ([url hasPrefix:@"tel:"])
    {
        TGActionSheet *actionSheet = [[TGActionSheet alloc] initWithTitle:url.length < 70 ? url : [[url substringToIndex:70] stringByAppendingString:@"..."] actions:@[
            [[TGActionSheetAction alloc] initWithTitle:TGLocalized(@"Conversation.Call") action:@"call"],
            [[TGActionSheetAction alloc] initWithTitle:TGLocalized(@"Conversation.LinkDialogCopy") action:@"copy"],
            [[TGActionSheetAction alloc] initWithTitle:TGLocalized(@"Common.Cancel") action:@"cancel" type:TGActionSheetActionTypeCancel]
        ] actionBlock:^(__unused TGModernConversationController *controller, NSString *action)
        {
            if ([action isEqualToString:@"call"])
            {
                [TGAppDelegateInstance performPhoneCall:[NSURL URLWithString:url]];
            }
            else if ([action isEqualToString:@"copy"])
            {
                UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];
                if (pasteboard != nil)
                {
                    NSString *copyString = url;
                    if ([url hasPrefix:@"mailto:"])
                        copyString = [url substringFromIndex:7];
                    else if ([url hasPrefix:@"tel:"])
                        copyString = [url substringFromIndex:4];
                    [pasteboard setString:copyString];
                }
            }
        } target:self];
        [actionSheet showInView:self.view];
    }
    else
    {
        TGActionSheet *actionSheet = [[TGActionSheet alloc] initWithTitle:url.length < 70 ? url : [[url substringToIndex:70] stringByAppendingString:@"..."] actions:@[
            [[TGActionSheetAction alloc] initWithTitle:TGLocalized(@"Conversation.LinkDialogOpen") action:@"open"],
            [[TGActionSheetAction alloc] initWithTitle:TGLocalized(@"Conversation.LinkDialogCopy") action:@"copy"],
            [[TGActionSheetAction alloc] initWithTitle:TGLocalized(@"Common.Cancel") action:@"cancel" type:TGActionSheetActionTypeCancel]
        ] actionBlock:^(TGModernConversationController *controller, NSString *action)
        {
            if ([action isEqualToString:@"open"])
            {
                [controller openBrowserFromMessage:0 url:url];
            }
            else if ([action isEqualToString:@"copy"])
            {
                UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];
                if (pasteboard != nil)
                {
                    NSString *copyString = url;
                    if ([url hasPrefix:@"mailto:"])
                        copyString = [url substringFromIndex:7];
                    else if ([url hasPrefix:@"tel:"])
                        copyString = [url substringFromIndex:4];
                    [pasteboard setString:copyString];
                }
            }
        } target:self];
        [actionSheet showInView:self.view];
    }
}

- (void)showActionsMenuForContact:(TGUser *)contact isContact:(bool)isContact
{
    NSMutableArray *actions = [[NSMutableArray alloc] init];
    
    if (!isContact)
        [actions addObject:[[TGActionSheetAction alloc] initWithTitle:TGLocalized(@"Conversation.AddContact") action:@"addContact"]];
    
    if (contact.uid > 0)
        [actions addObject:[[TGActionSheetAction alloc] initWithTitle:TGLocalized(@"Conversation.SendMessage") action:@"sendMessage"]];
    
    [actions addObject:[[TGActionSheetAction alloc] initWithTitle:TGLocalized(@"Conversation.Call") action:@"call"]];
    [actions addObject:[[TGActionSheetAction alloc] initWithTitle:TGLocalized(@"Common.Cancel") action:@"cancel" type:TGActionSheetActionTypeCancel]];
    
    TGActionSheet *actionSheet = [[TGActionSheet alloc] initWithTitle:nil actions:actions actionBlock:^(TGModernConversationController *controller, NSString *action)
    {
        if ([action isEqualToString:@"addContact"])
            [controller showAddContactMenu:contact];
        else if ([action isEqualToString:@"sendMessage"])
            [controller.companion controllerRequestedNavigationToConversationWithUser:contact.uid];
        else if ([action isEqualToString:@"call"])
        {
            NSString *url = [[NSString alloc] initWithFormat:@"tel:%@", [TGPhoneUtils formatPhoneUrl:contact.phoneNumber]];
            [TGAppDelegateInstance performPhoneCall:[NSURL URLWithString:url]];
        }
    } target:self];
    [actionSheet showInView:self.view];
}

- (void)showAddContactMenu:(TGUser *)contact
{
    [[[TGActionSheet alloc] initWithTitle:nil actions:@[
        [[TGActionSheetAction alloc] initWithTitle:TGLocalized(@"Profile.CreateNewContact") action:@"createNewContact"],
        [[TGActionSheetAction alloc] initWithTitle:TGLocalized(@"Profile.AddToExisting") action:@"addToExisting"],
        [[TGActionSheetAction alloc] initWithTitle:TGLocalized(@"Common.Cancel") action:@"cancel" type:TGActionSheetActionTypeCancel]
    ] actionBlock:^(TGModernConversationController *controller, NSString *action)
    {
        if ([action isEqualToString:@"createNewContact"])
            [controller.companion controllerWantsToCreateContact:contact.uid firstName:contact.firstName lastName:contact.lastName phoneNumber:contact.phoneNumber];
        else if ([action isEqualToString:@"addToExisting"])
            [controller.companion controllerWantsToAddContactToExisting:contact.uid phoneNumber:contact.phoneNumber];
    } target:self] showInView:self.view];
}

- (void)showCallNumberMenu:(NSArray *)phoneNumbers
{
    NSMutableArray *actions = [[NSMutableArray alloc] init];
    for (NSArray *desc in phoneNumbers)
    {
        [actions addObject:[[TGActionSheetAction alloc] initWithTitle:((NSString *)desc[0]).length == 0 ? desc[2] : [[NSString alloc] initWithFormat:@"%@: %@", desc[0], desc[2]] action:desc[1]]];
    }
    
    [actions addObject:[[TGActionSheetAction alloc] initWithTitle:TGLocalized(@"Common.Cancel") action:@"cancel" type:TGActionSheetActionTypeCancel]];
    
    [[[TGActionSheet alloc] initWithTitle:nil actions:actions actionBlock:^(__unused id target, NSString *action)
    {
        if (![action isEqualToString:@"cancel"])
        {
            NSString *url = [[NSString alloc] initWithFormat:@"tel:%@", [TGPhoneUtils formatPhoneUrl:action]];
            [TGAppDelegateInstance performPhoneCall:[NSURL URLWithString:url]];
        }
    } target:self] showInView:self.view];
}

- (void)enterEditingMode
{
    [self _enterEditingMode:0];
}

- (void)leaveEditingMode
{
    [self _leaveEditingModeAnimated:false];
}

- (void)reloadBackground
{
    UIImageView *tempImageView = [[UIImageView alloc] initWithImage:_backgroundView.image];
    tempImageView.contentMode = _backgroundView.contentMode;
    tempImageView.frame = _backgroundView.frame;
    [_backgroundView.superview insertSubview:tempImageView aboveSubview:_backgroundView];
    _backgroundView.image = [[TGWallpaperManager instance] currentWallpaperImage];
    
    [UIView animateWithDuration:0.3 animations:^
    {
        tempImageView.alpha = 0.0f;
    } completion:^(__unused BOOL finished)
    {
        [tempImageView removeFromSuperview];
    }];
    
    for (TGMessageModernConversationItem *item in _items)
    {
        [item updateAssets];
    }
    
    [_collectionView updateDecorationAssets];
}

- (void)refreshMetrics
{
    for (TGMessageModernConversationItem *item in _items)
    {
        [item refreshMetrics];
    }
    
    [_collectionLayout invalidateLayout];
}

- (void)setInputText:(NSString *)inputText replace:(bool)replace
{
    if (_inputTextPanel == nil)
        _initialInputText = inputText;
    else if (TGStringCompare(_inputTextPanel.maybeInputField.text, @"") || replace)
    {
        [[_inputTextPanel inputField] setText:inputText animated:false];
        
        if (_collectionView != nil)
        {
            [_emptyListPlaceholder adjustLayoutForOrientation:self.interfaceOrientation contentInsets:UIEdgeInsetsMake(_collectionView.contentInset.bottom, 0.0f, _collectionView.contentInset.top, 0.0f) duration:0.0f curve:0];
        }
        else
        {
            [_emptyListPlaceholder adjustLayoutForOrientation:self.interfaceOrientation contentInsets:UIEdgeInsetsMake(self.controllerInset.top, 0.0f, _currentInputPanel.frame.size.height, 0.0f) duration:0.0f curve:0];
        }
    }
}

- (void)setTitle:(NSString *)title
{
    [_titleView setTitle:title];
}

- (void)setTitleIcons:(NSArray *)titleIcons
{
    [_titleView setIcons:titleIcons];
}

- (void)setTitleModalProgressStatus:(NSString *)titleModalProgressStatus
{
    [_titleView setModalProgressStatus:titleModalProgressStatus];
}

- (void)setAvatarConversationId:(int64_t)conversationId title:(NSString *)title icon:(UIImage *)icon
{
    [_avatarButton setAvatarConversationId:conversationId];
    [_avatarButton setAvatarTitle:title];
    [_avatarButton setAvatarIcon:icon];
}

- (void)setAvatarConversationId:(int64_t)conversationId firstName:(NSString *)firstName lastName:(NSString *)lastName
{
    [_avatarButton setAvatarConversationId:conversationId];
    [_avatarButton setAvatarFirstName:firstName lastName:lastName];
}

- (void)setAvatarUrl:(NSString *)avatarUrl
{
    [_avatarButton setAvatarUrl:avatarUrl];
}

- (void)setStatus:(id)status accentColored:(bool)accentColored allowAnimation:(bool)allowAnimation
{
    [_titleView setStatus:status animated:self.isViewLoaded && allowAnimation];
    [_titleView setStatusHasAccentColor:accentColored];
}

- (void)setAttributedStatus:(NSAttributedString *)status allowAnimation:(bool)allowAnimation
{
    [_titleView setAttributedStatus:status animated:self.isViewLoaded && allowAnimation];
    [_titleView setStatusHasAccentColor:false];
}

- (void)setTypingStatus:(NSString *)typingStatus
{
    [_titleView setTypingStatus:typingStatus animated:self.isViewLoaded];
}

- (void)setGlobalUnreadCount:(int)unreadCount
{
    [_titleView setUnreadCount:unreadCount];
}

- (void)setCustomInputPanel:(TGModernConversationInputPanel *)customInputPanel
{
    if (_customInputPanel != customInputPanel)
    {
        _customInputPanel = customInputPanel;
        if (!_editingMode)
        {
            [self setInputPanel:_customInputPanel != nil ? _customInputPanel : _inputTextPanel animated:ABS(CFAbsoluteTimeGetCurrent() - _willAppearTimestamp) > 0.18];
        }
    }
}

- (void)setPrimaryTitlePanel:(TGModernConversationTitlePanel *)titlePanel
{
    if (_primaryTitlePanel != titlePanel)
    {
        bool applyAsCurrent = _currentTitlePanel != nil && _currentTitlePanel == _primaryTitlePanel;
        _primaryTitlePanel = titlePanel;
        
        if (applyAsCurrent)
            [self setCurrentTitlePanel:titlePanel animation:ABS(CFAbsoluteTimeGetCurrent() - _willAppearTimestamp) > 0.18 ? TGModernConversationPanelAnimationSlide : TGModernConversationPanelAnimationNone];
    }
}

- (TGModernConversationTitlePanel *)primaryTitlePanel
{
    return _primaryTitlePanel;
}

- (void)setSecondaryTitlePanel:(TGModernConversationTitlePanel *)secondaryTitlePanel
{
    if (_secondaryTitlePanel != secondaryTitlePanel)
    {
        bool applyAsCurrent = _currentTitlePanel == nil || _currentTitlePanel == _secondaryTitlePanel;
        _secondaryTitlePanel = secondaryTitlePanel;
        
        if (applyAsCurrent)
        {
            NSTimeInterval appearTime = ABS(CFAbsoluteTimeGetCurrent() - _willAppearTimestamp);
            [self setCurrentTitlePanel:secondaryTitlePanel animation:appearTime > 0.1 ? (appearTime > 0.4 ? TGModernConversationPanelAnimationSlide : TGModernConversationPanelAnimationFade) : TGModernConversationPanelAnimationNone];
        }
    }
}

- (TGModernConversationTitlePanel *)secondaryTitlePanel
{
    return _secondaryTitlePanel;
}

- (void)setCurrentTitlePanel:(TGModernConversationTitlePanel *)currentTitlePanel animation:(TGModernConversationPanelAnimation)animation
{
    if (_currentTitlePanel != currentTitlePanel)
    {
        if (_currentTitlePanel != nil)
        {
            if (animation != TGModernConversationPanelAnimationNone)
            {
                TGModernConversationTitlePanel *lastPanel = _currentTitlePanel;
                
                if (animation == TGModernConversationPanelAnimationSlide)
                {
                    [UIView animateWithDuration:0.09 delay:0.0 options:iosMajorVersion() < 7 ? 0 : (7 << 16) animations:^
                    {
                        lastPanel.frame = CGRectOffset(lastPanel.frame, 0.0f, -lastPanel.frame.size.height);
                    } completion:^(__unused BOOL finished)
                    {
                        [lastPanel removeFromSuperview];
                    }];
                }
                else
                {
                    [UIView animateWithDuration:0.09 delay:0.0 options:iosMajorVersion() < 7 ? 0 : (7 << 16) animations:^
                    {
                        lastPanel.alpha = 0.0f;
                    } completion:^(__unused BOOL finished)
                    {
                        [lastPanel removeFromSuperview];
                        lastPanel.alpha = 1.0f;
                    }];
                }
            }
            else
                [_currentTitlePanel removeFromSuperview];
        }
        
        _currentTitlePanel = currentTitlePanel;
        
        if (_currentTitlePanel != nil)
        {
            if (_titlePanelWrappingView == nil)
            {
                _titlePanelWrappingView = [[UIView alloc] initWithFrame:CGRectMake(0.0f, self.controllerInset.top, self.view.frame.size.width, 44.0f)];
                _titlePanelWrappingView.clipsToBounds = true;
                [self.view addSubview:_titlePanelWrappingView];
            }
            
            _titlePanelWrappingView.userInteractionEnabled = true;
            
            [_titlePanelWrappingView addSubview:_currentTitlePanel];
            
            CGRect titlePanelFrame = CGRectMake(0.0f, 0.0f, _titlePanelWrappingView.frame.size.width, _currentTitlePanel.frame.size.height);
            
            if (animation != TGModernConversationPanelAnimationNone)
            {
                if (animation == TGModernConversationPanelAnimationSlide)
                {
                    _currentTitlePanel.frame = CGRectOffset(titlePanelFrame, 0.0f, -titlePanelFrame.size.height);
                    [UIView animateWithDuration:0.09 delay:0.0 options:iosMajorVersion() < 7 ? 0 : (7 << 16) animations:^
                    {
                        _currentTitlePanel.frame = titlePanelFrame;
                    } completion:nil];
                }
                else
                {
                    _currentTitlePanel.frame = titlePanelFrame;
                    _currentTitlePanel.alpha = 0.0f;
                    [UIView animateWithDuration:0.09 delay:0.0 options:iosMajorVersion() < 7 ? 0 : (7 << 16) animations:^
                    {
                        _currentTitlePanel.alpha = 1.0f;
                    } completion:nil];
                }
            }
            else
            {
                _currentTitlePanel.alpha = 1.0f;
                _currentTitlePanel.frame = titlePanelFrame;
            }
        }
        else
            _titlePanelWrappingView.userInteractionEnabled = false;
    }
}

- (void)setEmptyListPlaceholder:(TGModernConversationEmptyListPlaceholderView *)emptyListPlaceholder
{
    [self setEmptyListPlaceholder:emptyListPlaceholder animated:ABS(CFAbsoluteTimeGetCurrent() - _willAppearTimestamp) > 0.18];
}

- (void)setEmptyListPlaceholder:(TGModernConversationEmptyListPlaceholderView *)emptyListPlaceholder animated:(bool)animated
{
    if (_emptyListPlaceholder != emptyListPlaceholder)
    {
        if (_emptyListPlaceholder != nil)
        {
            if (animated)
            {
                UIView *currentView = _emptyListPlaceholder;
                _emptyListPlaceholder = nil;
                
                [UIView animateWithDuration:0.3 * 0.7 animations:^
                {
                    currentView.alpha = 0.0f;
                } completion:^(__unused BOOL finished)
                {
                    [currentView removeFromSuperview];
                }];
            }
            else
            {
                [_emptyListPlaceholder removeFromSuperview];
                _emptyListPlaceholder = nil;
            }
        }
        
        _emptyListPlaceholder = emptyListPlaceholder;
        
        if (self.isViewLoaded)
        {
            [self.view insertSubview:_emptyListPlaceholder belowSubview:_currentInputPanel];
            
            if (animated)
            {
                _emptyListPlaceholder.alpha = 0.0f;
                [UIView animateWithDuration:0.3 * 0.7 animations:^
                {
                    _emptyListPlaceholder.alpha = 1.0f;
                }];
            }
            else
                _emptyListPlaceholder.alpha = 1.0f;

            if (_collectionView != nil)
            {
                [_emptyListPlaceholder adjustLayoutForOrientation:self.interfaceOrientation contentInsets:UIEdgeInsetsMake(_collectionView.contentInset.bottom, 0.0f, _collectionView.contentInset.top, 0.0f) duration:0.0f curve:0];
            }
            else
            {
                [_emptyListPlaceholder adjustLayoutForOrientation:self.interfaceOrientation contentInsets:UIEdgeInsetsMake(self.controllerInset.top, 0.0f, 45.0f, 0.0f) duration:0.0f curve:0];
            }
        }
    }
}

#pragma mark -

- (void)setEnableAboveHistoryRequests:(bool)enableAboveHistoryRequests
{
    _enableAboveHistoryRequests = enableAboveHistoryRequests;
}

- (void)setEnableBelowHistoryRequests:(bool)enableBelowHistoryRequests
{
    _enableBelowHistoryRequests = enableBelowHistoryRequests;
}

- (void)setEnableSendButton:(bool)enableSendButton
{
    _inputTextPanel.sendButton.userInteractionEnabled = enableSendButton;
}

- (void)_updateCanReadHistory:(TGModernConversationActivityChange)change
{
    bool canReadHistory = true;
    
    if (change == TGModernConversationActivityChangeActive)
        canReadHistory = true;
    else if (change == TGModernConversationActivityChangeInactive)
        canReadHistory = false;
    else
    {
        if (canReadHistory && self.navigationController.topViewController != self)
            canReadHistory = false;
        
        if (canReadHistory && ([UIApplication sharedApplication].applicationState != UIApplicationStateActive && [UIApplication sharedApplication].applicationState != UIApplicationStateInactive))
            canReadHistory = false;
    }
    
    if (_canReadHistory != canReadHistory)
    {
        _canReadHistory = canReadHistory;
        [_companion controllerCanReadHistoryUpdated];
    }
}

- (bool)canReadHistory
{
    return _canReadHistory || ([UIApplication sharedApplication].applicationState == UIApplicationStateActive && self.navigationController.topViewController == self);
}

- (void)setEnableUnloadHistoryRequests:(bool)enableUnloadHistoryRequests
{
    _enableUnloadHistoryRequests = enableUnloadHistoryRequests;
}

- (void)_updateItemsAnimationsEnabled
{
    for (TGMessageModernConversationItem *item in _items)
    {
        [item updateAnimationsEnabled];
    }
}

- (TGModernViewInlineMediaContext *)inlineMediaContext:(int32_t)messageId
{
    if (_currentAudioPlayerMessageId == messageId && _currentAudioPlayer != nil)
    {
        return [_currentAudioPlayer inlineMediaContext];
    }
    
    return nil;
}

- (void)_maybeUnloadHistory
{
    if (_enableUnloadHistoryRequests && (NSInteger)_items.count >= TGModernConversationControllerUnloadHistoryLimit + TGModernConversationControllerUnloadHistoryThreshold)
    {
        NSIndexPath *indexPath = [_collectionView indexPathsForVisibleItems].firstObject;
        if (indexPath != nil)
        {
            if (indexPath.row < (int)(_items.count / 2))
                [_companion unloadMessagesAbove];
            else
                [_companion unloadMessagesBelow];
        }
    }
}

#pragma mark -

- (void)titleViewTapped:(TGModernConversationTitleView *)__unused titleView
{
    if (_editingMode)
        return;
    
    if (!_shouldHaveTitlePanelLoaded)
    {
        _shouldHaveTitlePanelLoaded = true;
        [_companion _loadControllerPrimaryTitlePanel];
    }
    
    if (_primaryTitlePanel != nil)
    {
        if (_currentTitlePanel != _primaryTitlePanel)
            [self setCurrentTitlePanel:_primaryTitlePanel animation:TGModernConversationPanelAnimationSlide];
        else
            [self setCurrentTitlePanel:_secondaryTitlePanel animation:TGModernConversationPanelAnimationSlide];
    }
}

- (void)editingPanelRequestedDeleteMessages:(TGModernConversationEditingPanel *)__unused editingPanel
{
    [[[TGActionSheet alloc] initWithTitle:nil actions:@[
        [[TGActionSheetAction alloc] initWithTitle:[_companion checkedMessageCount] == 1 ? TGLocalized(@"Conversation.DeleteOneMessage") : TGLocalized(@"Conversation.DeleteManyMessages") action:@"delete" type:TGActionSheetActionTypeDestructive],
        [[TGActionSheetAction alloc] initWithTitle:TGLocalized(@"Common.Cancel") action:@"cancel" type:TGActionSheetActionTypeCancel]
    ] actionBlock:^(TGModernConversationController *controller, NSString *action)
    {
        if ([action isEqualToString:@"delete"])
            [controller _commitDeleteCheckedMessages];
    } target:self] showInView:self.view];
}

- (void)editingPanelRequestedForwardMessages:(TGModernConversationEditingPanel *)__unused editingPanel
{
    [_companion controllerWantsToForwardMessages:[_companion checkedMessageIds]];
}

- (void)inputTextPanelHasIndicatedTypingActivity:(TGModernConversationInputTextPanel *)__unused inputTextPanel
{
    [_companion controllerDidUpdateTypingActivity];
}

- (void)inputPanelRequestedSendMessage:(TGModernConversationInputTextPanel *)__unused inputTextPanel text:(NSString *)text
{
    [_companion controllerWantsToSendTextMessage:text];
}

- (void)inputPanelRequestedAttachmentsMenu:(TGModernConversationInputTextPanel *)__unused inputTextPanel
{
    NSMutableArray *actions = [[NSMutableArray alloc] initWithArray:@[
        [[TGActionSheetAction alloc] initWithTitle:TGLocalized(@"Common.ChoosePhoto") action:@"choosePhoto"],
        [[TGActionSheetAction alloc] initWithTitle:TGLocalized(@"Conversation.SearchWebImages") action:@"searchWeb"],
        [[TGActionSheetAction alloc] initWithTitle:TGLocalized(@"Common.ChooseVideo") action:@"chooseVideo"],
        [[TGActionSheetAction alloc] initWithTitle:TGLocalized(@"Conversation.Location") action:@"chooseLocation"],
        [[TGActionSheetAction alloc] initWithTitle:TGLocalized(@"Conversation.Document") action:@"document"]
    ]];
    
    if ([_companion allowContactSharing])
        [actions addObject:[[TGActionSheetAction alloc] initWithTitle:TGLocalized(@"Conversation.Contact") action:@"contact"]];
    
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera])
        [actions insertObject:[[TGActionSheetAction alloc] initWithTitle:TGLocalized(@"Common.TakePhotoOrVideo") action:@"camera"] atIndex:0];
    
    [actions addObject:[[TGActionSheetAction alloc] initWithTitle:TGLocalized(@"Common.Cancel") action:@"cancel" type:TGActionSheetActionTypeCancel]];
    
    TGActionSheet *actionSheet = [[TGActionSheet alloc] initWithTitle:nil actions:actions actionBlock:^(TGModernConversationController *controller, NSString *action)
    {
        if (![action isEqualToString:@"cancel"])
        {
            [controller.view endEditing:true];
            
            if ([action isEqualToString:@"camera"])
                [controller _displayPhotoVideoPicker:false];
            if ([action isEqualToString:@"choosePhoto"])
                [controller _displayImagePicker:false];
            else if ([action isEqualToString:@"searchWeb"])
                [controller _displayImagePicker:true];
            else if ([action isEqualToString:@"chooseVideo"])
                [controller _displayPhotoVideoPicker:true];
            else if ([action isEqualToString:@"chooseLocation"])
            {
                TGMapViewController *mapController = [[TGMapViewController alloc] initInPickingMode];
                mapController.watcher = controller.actionHandle;
                TGNavigationController *navigationController = [TGNavigationController navigationControllerWithControllers:@[mapController]];
                
                if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad)
                {
                    navigationController.presentationStyle = TGNavigationControllerPresentationStyleInFormSheet;
                    navigationController.modalPresentationStyle = UIModalPresentationFormSheet;
                }
                
                [controller presentViewController:navigationController animated:true completion:nil];
            }
            else if ([action isEqualToString:@"document"])
                [controller _displayDocumentPicker];
            else if ([action isEqualToString:@"contact"])
                [controller _displayContactPicker];
        }
    } target:self];
    actionSheet.dismissBlock = ^(__unused TGModernConversationController *controller, NSString *action)
    {
        return ![action isEqualToString:@"cancel"];
    };
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone)
        [actionSheet showInView:self.view];
    else
        [actionSheet showFromRect:CGRectOffset([self.view convertRect:[_inputTextPanel attachmentButtonFrame] fromView:_inputTextPanel], 0.0f, -6.0f) inView:self.view animated:true];
}

- (void)_displayPhotoVideoPicker:(bool)videoGallery
{
    if (videoGallery)
    {
        __weak TGModernConversationController *weakSelf = self;
        void (^videoPicked)(NSString *videoAssetId, NSString *tempFilePath, CGSize dimensions, NSTimeInterval duration, UIImage *thumbnail, TGLiveUploadActorData *liveUploadData) = ^(NSString *videoAssetId, NSString *tempFilePath, CGSize dimensions, NSTimeInterval duration, UIImage *thumbnail, TGLiveUploadActorData *liveUploadData)
        {
            TGDispatchOnMainThread(^
            {
                __strong TGModernConversationController *strongSelf = weakSelf;
                
                TGVideoMediaAttachment *videoAttachment = nil;
                if (videoAssetId != nil)
                    videoAttachment = [strongSelf.companion serverCachedAssetWithId:videoAssetId];
                
                if (videoAttachment != nil)
                    [strongSelf.companion controllerWantsToSendRemoteVideoWithMedia:videoAttachment];
                else
                {
                    int fileSize = [[[NSFileManager defaultManager] attributesOfItemAtPath:tempFilePath error:NULL][NSFileSize] intValue];
                    if (fileSize != 0)
                    {
                        [strongSelf.companion controllerWantsToSendLocalVideoWithTempFilePath:tempFilePath fileSize:(int32_t)fileSize previewImage:thumbnail duration:duration dimensions:dimensions assetUrl:videoAssetId liveUploadData:liveUploadData];
                    }
                }
                
                [strongSelf dismissViewControllerAnimated:true completion:nil];
            });
        };
        
        TGMediaFoldersController *mediaFoldersController = [[TGMediaFoldersController alloc] init];
        mediaFoldersController.videoPicked = videoPicked;
        mediaFoldersController.liveUpload = [_companion controllerShouldLiveUploadVideo];
        mediaFoldersController.enableServerAssetCache = [_companion controllerShouldCacheServerAssets];
        
        TGModernMediaPickerController *mediaPickerController = [[TGModernMediaPickerController alloc] init];
        mediaPickerController.videoPicked = videoPicked;
        mediaPickerController.liveUpload = [_companion controllerShouldLiveUploadVideo];
        mediaPickerController.enableServerAssetCache = [_companion controllerShouldCacheServerAssets];
        TGNavigationController *navigationController = [TGNavigationController navigationControllerWithControllers:@[mediaFoldersController, mediaPickerController]];
        
        if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad)
        {
            navigationController.presentationStyle = TGNavigationControllerPresentationStyleInFormSheet;
            navigationController.modalPresentationStyle = UIModalPresentationFormSheet;
        }
        
        [self presentViewController:navigationController animated:true completion:nil];
    }
    else
    {
        TGLegacyCameraController *legacyCameraController = [[TGLegacyCameraController alloc] init];
        if (videoGallery)
        {
            legacyCameraController.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
            legacyCameraController.mediaTypes = [[NSArray alloc] initWithObjects:(__bridge NSString *)kUTTypeMovie, nil];
        }
        else
        {
            legacyCameraController.sourceType = UIImagePickerControllerSourceTypeCamera;
            legacyCameraController.mediaTypes = [[NSArray alloc] initWithObjects:(__bridge NSString *)kUTTypeImage, (__bridge NSString *)kUTTypeMovie, nil];
        }
        
        legacyCameraController.storeCapturedAssets = [_companion controllerShouldStoreCapturedAssets];
        legacyCameraController.completionDelegate = self;
        
        legacyCameraController.videoMaximumDuration = 100 * 60 * 60;
        [legacyCameraController setVideoQuality:UIImagePickerControllerQualityTypeMedium];
        
        if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad && videoGallery)
        {
            legacyCameraController.modalPresentationStyle = UIModalPresentationFormSheet;
        }
        
        [self presentViewController:legacyCameraController animated:true completion:nil];
    }
}

- (void)_displayDocumentPicker
{
    TGLegacyCameraController *legacyCameraController = [[TGLegacyCameraController alloc] init];
    legacyCameraController.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    legacyCameraController.mediaTypes = [[NSArray alloc] initWithObjects:(__bridge NSString *)kUTTypeImage, (__bridge NSString *)kUTTypeMovie, nil];
    
    legacyCameraController.storeCapturedAssets = false;
    legacyCameraController.completionDelegate = self;
    legacyCameraController.isInDocumentMode = true;
    
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad)
    {
        legacyCameraController.modalPresentationStyle = UIModalPresentationFormSheet;
    }
    
    [self presentViewController:legacyCameraController animated:true completion:nil];
}

- (void)legacyCameraControllerCompletedWithDocument:(NSURL *)fileUrl fileName:(NSString *)fileName mimeType:(NSString *)mimeType
{
    [self dismissViewControllerAnimated:true completion:nil];
    
    [_companion controllerWantsToSendDocumentWithTempFileUrl:fileUrl fileName:fileName mimeType:mimeType];
}

- (void)_displayImagePicker:(bool)webImages
{
    NSMutableArray *controllerList = [[NSMutableArray alloc] init];
    
    TGImageSearchController *searchController = [[TGImageSearchController alloc] init];
    searchController.autoActivateSearch = webImages;
    searchController.delegate = self;
    [controllerList addObject:searchController];
    
    if (!webImages)
    {
        TGImagePickerController *imagePicker = [[TGImagePickerController alloc] initWithGroupUrl:nil groupTitle:nil avatarSelection:false];
        imagePicker.delegate = self;
        
        [controllerList addObject:imagePicker];
    }
    
    TGNavigationController *navigationController = [TGNavigationController navigationControllerWithControllers:controllerList];
    
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad)
    {
        navigationController.presentationStyle = TGNavigationControllerPresentationStyleInFormSheet;
        navigationController.modalPresentationStyle = UIModalPresentationFormSheet;
    }
    
    [self presentViewController:navigationController animated:true completion:nil];
}

- (void)imagePickerController:(TGImagePickerController *)__unused imagePicker didFinishPickingWithAssets:(NSArray *)assets
{
    NSMutableArray *imageDescriptions = [[NSMutableArray alloc] init];
    
    for (id abstractAsset in assets)
    {
        if ([abstractAsset isKindOfClass:[TGImagePickerAsset class]])
        {
            @autoreleasepool
            {
                TGImagePickerAsset *asset = abstractAsset;
                
                CC_MD5_CTX md5;
                CC_MD5_Init(&md5);
                
                NSData *metadataData = [[self _dictionaryString:asset.asset.defaultRepresentation.metadata] dataUsingEncoding:NSUTF8StringEncoding];
                CC_MD5_Update(&md5, [metadataData bytes], metadataData.length);
                
                NSData *uriData = [asset.assetUrl dataUsingEncoding:NSUTF8StringEncoding];
                CC_MD5_Update(&md5, [uriData bytes], uriData.length);
                
                int64_t size = asset.asset.defaultRepresentation.size;
                const int64_t batchSize = 4 * 1024;
                
                uint8_t *buf = (uint8_t *)malloc(batchSize);
                NSError *error = nil;
                for (int64_t offset = 0; offset < batchSize; offset += batchSize)
                {
                    NSUInteger length = [asset.asset.defaultRepresentation getBytes:buf fromOffset:offset length:((NSUInteger)(MIN(batchSize, size - offset))) error:&error];
                    CC_MD5_Update(&md5, buf, length);
                }
                free(buf);
                
                unsigned char md5Buffer[16];
                CC_MD5_Final(md5Buffer, &md5);
                NSString *hash = [[NSString alloc] initWithFormat:@"%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x", md5Buffer[0], md5Buffer[1], md5Buffer[2], md5Buffer[3], md5Buffer[4], md5Buffer[5], md5Buffer[6], md5Buffer[7], md5Buffer[8], md5Buffer[9], md5Buffer[10], md5Buffer[11], md5Buffer[12], md5Buffer[13], md5Buffer[14], md5Buffer[15]];

                UIImage *image = [[UIImage alloc] initWithCGImage:asset.asset.defaultRepresentation.fullScreenImage];
                
                if (image != nil)
                {
                    NSDictionary *imageDescription = [_companion imageDescriptionFromImage:image optionalAssetUrl:hash];
                    if (imageDescription != nil)
                        [imageDescriptions addObject:imageDescription];
                }
            }
        }
        else if ([abstractAsset isKindOfClass:[UIImage class]])
        {
            @autoreleasepool
            {
                NSDictionary *imageDescription = [_companion imageDescriptionFromImage:abstractAsset optionalAssetUrl:nil];
                if (imageDescription != nil)
                    [imageDescriptions addObject:imageDescription];
            }
        }
        else if ([abstractAsset isKindOfClass:[NSString class]])
        {
            @autoreleasepool
            {
                UIImage *image = [[TGRemoteImageView sharedCache] cachedImage:abstractAsset availability:TGCacheDisk];
                
                if (image != nil)
                {
                    NSDictionary *imageDescription = [_companion imageDescriptionFromImage:image optionalAssetUrl:nil];
                    if (imageDescription != nil)
                        [imageDescriptions addObject:imageDescription];
                }
            }
        }
    }
    
    if (imageDescriptions.count != 0)
        [_companion controllerWantsToSendImagesWithDescriptions:imageDescriptions];
    
    [self dismissViewControllerAnimated:true completion:nil];
}

- (void)legacyCameraControllerCapturedVideoWithTempFilePath:(NSString *)tempVideoFilePath fileSize:(int32_t)fileSize previewImage:(UIImage *)previewImage duration:(NSTimeInterval)duration dimensions:(CGSize)dimenstions assetUrl:(NSString *)assetUrl
{
    [self dismissViewControllerAnimated:true completion:nil];
    
    [_companion controllerWantsToSendLocalVideoWithTempFilePath:tempVideoFilePath fileSize:fileSize previewImage:previewImage duration:duration dimensions:dimenstions assetUrl:assetUrl liveUploadData:nil];
}

- (void)legacyCameraControllerCompletedWithExistingMedia:(id)media
{
    [self dismissViewControllerAnimated:true completion:nil];
    
    if ([media isKindOfClass:[TGVideoMediaAttachment class]])
        [_companion controllerWantsToSendRemoteVideoWithMedia:media];
}

- (void)legacyCameraControllerCompletedWithNoResult
{
    [self dismissViewControllerAnimated:true completion:nil];
}

- (void)inputPanelRequestedSendImages:(TGModernConversationInputTextPanel *)__unused inputTextPanel images:(NSArray *)images
{
    NSMutableArray *imageDescriptions = [[NSMutableArray alloc] init];
    
    for (id abstractAsset in images)
    {
        if ([abstractAsset isKindOfClass:[UIImage class]])
        {
            @autoreleasepool
            {
                NSDictionary *imageDescription = [_companion imageDescriptionFromImage:abstractAsset optionalAssetUrl:nil];
                if (imageDescription != nil)
                    [imageDescriptions addObject:imageDescription];
            }
        }
    }
    
    if (imageDescriptions.count != 0)
        [_companion controllerWantsToSendImagesWithDescriptions:imageDescriptions];
}

- (void)_displayContactPicker
{
    TGForwardContactPickerController *contactPickerController = [[TGForwardContactPickerController alloc] init];
    contactPickerController.delegate = self;
    
    TGNavigationController *navigationController = [TGNavigationController navigationControllerWithControllers:@[contactPickerController]];
    
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad)
    {
        navigationController.presentationStyle = TGNavigationControllerPresentationStyleInFormSheet;
        navigationController.modalPresentationStyle = UIModalPresentationFormSheet;
    }
    
    [self presentViewController:navigationController animated:true completion:nil];
}

- (void)forwardContactPickerController:(TGForwardContactPickerController *)__unused contactPicker didSelectContact:(TGUser *)contactUser
{
    [_companion controllerWantsToSendContact:contactUser];
}

- (NSString *)_dictionaryString:(NSDictionary *)dict
{
    NSMutableString *string = [[NSMutableString alloc] init];
    
    [dict enumerateKeysAndObjectsUsingBlock:^(id key, id value, __unused BOOL *stop)
     {
         if ([key isKindOfClass:[NSString class]])
             [string appendString:key];
         else if ([key isKindOfClass:[NSNumber class]])
             [string appendString:[key description]];
         [string appendString:@":"];
         
         if ([value isKindOfClass:[NSString class]])
             [string appendString:value];
         else if ([value isKindOfClass:[NSNumber class]])
             [string appendString:[value description]];
         else if ([value isKindOfClass:[NSDictionary class]])
         {
             [string appendString:@"{"];
             [string appendString:[self _dictionaryString:value]];
             [string appendString:@"}"];
         }
         
         [string appendString:@";"];
     }];
    
    return string;
}

- (void)inputPanelAudioRecordingStart:(TGModernConversationInputTextPanel *)__unused inputTextPanel
{
    [self stopAudioRecording];
    [self stopInlineMediaIfPlaying];
    
    if (_currentAudioRecorder == nil)
    {
        _currentAudioRecorder = [[TGAudioRecorder alloc] initWithFileEncryption:[_companion encryptUploads]];
        _currentAudioRecorder.delegate = self;
        [_currentAudioRecorder start];
    }
}

- (void)inputPanelAudioRecordingCancel:(TGModernConversationInputTextPanel *)__unused inputTextPanel
{
    [self stopAudioRecording];
    [_inputTextPanel audioRecordingFinished];
}

- (void)inputPanelAudioRecordingComplete:(TGModernConversationInputTextPanel *)inputTextPanel
{
    if (_currentAudioRecorder != nil)
    {
        _currentAudioRecorder.delegate = nil;
        [_currentAudioRecorder finish:^(NSString *tempFilePath, NSTimeInterval duration, TGLiveUploadActorData *liveData)
        {
            TGDispatchOnMainThread(^
            {
                if (tempFilePath != nil)
                {
                    [_companion controllerWantsToSendLocalAudioWithTempFileUrl:[NSURL fileURLWithPath:tempFilePath] duration:duration liveData:liveData];
                }
                else
                    [inputTextPanel shakeControls];
            });
        }];
        
        _currentAudioRecorder = nil;
        
        [_inputTextPanel audioRecordingFinished];
        
        if ([self shouldAutorotate])
            [TGViewController attemptAutorotation];
    }
}

- (NSTimeInterval)inputPanelAudioRecordingDuration:(TGModernConversationInputTextPanel *)__unused inputTextPanel
{
    if (_currentAudioRecorder != nil)
        return [_currentAudioRecorder currentDuration];
    
    return 0.0;
}

- (void)audioRecorderDidStartRecording:(TGAudioRecorder *)audioRecorder
{
    TGDispatchOnMainThread(^
    {
        if (audioRecorder == _currentAudioRecorder)
            [_inputTextPanel audioRecordingStarted];
    });
}

- (void)_enterEditingMode:(int32_t)animateFromMessageId
{
    if (!_editingMode)
    {
        [self setCurrentTitlePanel:nil animation:TGModernConversationPanelAnimationSlide];
        
        [_companion clearCheckedMessages];
        [_companion setMessageChecked:animateFromMessageId checked:true];
        
        _editingMode = true;
        
        NSArray *visibleCells = [_collectionView.visibleCells sortedArrayUsingComparator:^NSComparisonResult(TGModernCollectionCell *cell1, TGModernCollectionCell *cell2)
        {
            return cell1.frame.origin.y > cell2.frame.origin.y ? NSOrderedAscending : NSOrderedDescending;
        }];
        
        _companion.viewContext.editing = true;
        
        NSUInteger animateFromIndex = NSNotFound;
        for (NSUInteger i = 0; i < visibleCells.count; i++)
        {
            TGMessageModernConversationItem * item = ((TGModernCollectionCell *)visibleCells[i]).boundItem;
            if (item != nil && item->_message.mid == animateFromMessageId)
            {
                animateFromIndex = i;
                break;
            }
        }
        
        if (false && animateFromIndex != NSNotFound)
        {
            [(TGMessageModernConversationItem *)((TGModernCollectionCell *)visibleCells[animateFromIndex]).boundItem updateEditingState:_viewStorage animationDelay:0.0];
            
            NSTimeInterval upDelay = 0.01;
            for (int i = animateFromIndex + 1; i < (int)visibleCells.count; i++)
            {
                TGModernCollectionCell *cell = visibleCells[i];
                [(TGMessageModernConversationItem *)cell.boundItem updateEditingState:_viewStorage animationDelay:upDelay];
                upDelay += 0.008;
            }
            
            NSTimeInterval downDelay = 0.01;
            for (int i = animateFromIndex - 1; i >= 0; i--)
            {
                TGModernCollectionCell *cell = visibleCells[i];
                [(TGMessageModernConversationItem *)cell.boundItem updateEditingState:_viewStorage animationDelay:downDelay];
                downDelay += 0.008;
            }
        }
        else
        {
            NSTimeInterval delay = 0.0;
            for (TGModernCollectionCell *cell in visibleCells)
            {
                [(TGMessageModernConversationItem *)cell.boundItem updateEditingState:_viewStorage animationDelay:delay];
                delay += 0.006;
            }
        }
        
        [self setLeftBarButtonItem:[[UIBarButtonItem alloc] initWithTitle:TGLocalized(@"Conversation.ClearAll") style:UIBarButtonItemStylePlain target:self action:@selector(clearAllButtonPressed)] animated:true];
        [self setRightBarButtonItem:[[UIBarButtonItem alloc] initWithTitle:TGLocalized(@"Common.Cancel") style:UIBarButtonItemStylePlain target:self action:@selector(doneButtonPressed)] animated:true];
        
        TGModernConversationEditingPanel *editPanel = [[TGModernConversationEditingPanel alloc] initWithFrame:CGRectMake(0.0f, 0.0f, self.view.frame.size.width, 0.0f)];
        editPanel.delegate = self;
        [editPanel setForwardingEnabled:[_companion allowMessageForwarding]];
        [self setInputPanel:editPanel animated:true];
        [self _updateEditingPanel];
        
        [_titleView setEditingMode:true animated:true];
    }
}

static UIView *_findBackArrow(UIView *view)
{
    static Class backArrowClass = NSClassFromString(TGEncodeText(@"`VJObwjhbujpoCbsCbdlJoejdbupsWjfx", -1));
    
    if ([view isKindOfClass:backArrowClass])
        return view;
    
    for (UIView *subview in view.subviews)
    {
        UIView *result = _findBackArrow(subview);
        if (result != nil)
            return result;
    }
    
    return nil;
}

- (void)_leaveEditingModeAnimated:(bool)animated
{
    if (_editingMode)
    {
        [_companion clearCheckedMessages];
        
        _editingMode = false;
        
        NSArray *visibleCells = [_collectionView.visibleCells sortedArrayUsingComparator:^NSComparisonResult(TGModernCollectionCell *cell1, TGModernCollectionCell *cell2)
        {
            return cell1.frame.origin.y > cell2.frame.origin.y ? NSOrderedAscending : NSOrderedDescending;
        }];
        
        _companion.viewContext.editing = false;
        
        NSTimeInterval delay = 0.0;
        for (TGModernCollectionCell *cell in visibleCells)
        {
            [(TGMessageModernConversationItem *)cell.boundItem updateEditingState:_viewStorage animationDelay:delay];
            delay += 0.006;
        }
        
        [self setLeftBarButtonItem:[self defaultLeftBarButtonItem] animated:animated];
        [self setRightBarButtonItem:[self defaultRightBarButtonItem] animated:animated];
        
        [self setInputPanel:_customInputPanel != nil ? _customInputPanel : _inputTextPanel animated:animated];
        
        if (animated && iosMajorVersion() >= 7)
        {
            UIView *backArrow = _findBackArrow(self.navigationController.navigationBar);
            backArrow.alpha = 0.0f;
            [UIView animateWithDuration:0.3 delay:0.17 options:0 animations:^
            {
                backArrow.alpha = 1.0f;
            } completion:nil];
        }
        
        [_titleView setEditingMode:false animated:animated];
    }
}

- (void)clearAllButtonPressed
{
    ASHandle *actionHandle = _actionHandle;
    [[[TGAlertView alloc] initWithTitle:nil message:TGLocalized(@"Conversation.ClearAllConfirmation") cancelButtonTitle:TGLocalized(@"Common.Cancel") okButtonTitle:TGLocalized(@"Common.OK") completionBlock:^(bool okButtonPressed)
    {
        if (okButtonPressed)
            [actionHandle requestAction:@"clearAllMessages" options:nil];
    }] show];
}

- (void)_commitClearAllMessages
{
    [self _leaveEditingModeAnimated:true];
    [self deleteItemsAtIndices:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(0, _items.count)] animated:true];
    [_companion controllerClearedConversation];
}

- (void)_commitDeleteCheckedMessages
{
    NSArray *checkedMessageIds = [_companion checkedMessageIds];
    std::set<int32_t> messageIds;
    for (NSNumber *nMid in checkedMessageIds)
    {
        messageIds.insert([nMid int32Value]);
    }
    
    NSMutableIndexSet *indexSet = [[NSMutableIndexSet alloc] init];
    
    int index = -1;
    for (TGMessageModernConversationItem *messageItem in _items)
    {
        index++;
        if (messageIds.find(messageItem->_message.mid) != messageIds.end())
        {
            [indexSet addIndex:index];
        }
    }
    
    [self _deleteItemsAtIndices:indexSet animated:true animationFactor:1.0f];
    [self _leaveEditingModeAnimated:true];
    
    [_companion controllerDeletedMessages:checkedMessageIds];
}

- (void)doneButtonPressed
{
    [self _leaveEditingModeAnimated:true];
}

- (void)unseenMessagesButtonPressed
{
    if (_enableBelowHistoryRequests)
        [_companion _performFastScrollDown:false];
    else
        [_collectionView setContentOffset:CGPointMake(0.0f, -_collectionView.contentInset.top) animated:true];
}

#pragma mark -

- (void)inputPanelWillChangeHeight:(TGModernConversationInputPanel *)inputPanel height:(CGFloat)height duration:(NSTimeInterval)duration animationCurve:(int)animationCurve
{
    if (inputPanel == _currentInputPanel)
    {
        [_currentInputPanel adjustForOrientation:self.interfaceOrientation keyboardHeight:_keyboardHeight duration:duration animationCurve:animationCurve];
        [self _adjustCollectionViewForOrientation:self.interfaceOrientation keyboardHeight:_keyboardHeight inputContainerHeight:height duration:duration animationCurve:0];
    }
}

- (CGSize)messageAreaSizeForInterfaceOrientation:(UIInterfaceOrientation)orientation
{
    return [self collectionViewSizeForInterfaceOrientation:orientation];
}

- (void)_adjustCollectionViewForOrientation:(UIInterfaceOrientation)orientation keyboardHeight:(float)keyboardHeight inputContainerHeight:(float)inputContainerHeight duration:(NSTimeInterval)duration animationCurve:(int)animationCurve
{
    [self _adjustCollectionViewForOrientation:orientation keyboardHeight:keyboardHeight inputContainerHeight:inputContainerHeight scrollToBottom:false duration:duration animationCurve:animationCurve];
}

- (void)_adjustCollectionViewForOrientation:(UIInterfaceOrientation)__unused orientation keyboardHeight:(float)keyboardHeight inputContainerHeight:(float)inputContainerHeight scrollToBottom:(bool)scrollToBottom duration:(NSTimeInterval)duration animationCurve:(int)animationCurve
{
    bool stopScrolling = _collectionView.contentOffset.y >= -_collectionView.contentInset.top;
    
    CGFloat contentHeight =  _collectionView.contentSize.height;
    
    UIEdgeInsets originalInset = _collectionView.contentInset;
    UIEdgeInsets inset = originalInset;
    inset.top = keyboardHeight + inputContainerHeight;
    
    if (_snapshotBackgroundView != nil)
    {
        CGRect snapshotBackgroundFrame = _snapshotBackgroundView.frame;
        snapshotBackgroundFrame.origin.y = -inset.top + 45.0f;
        _snapshotBackgroundView.frame = snapshotBackgroundFrame;
    }
    
    if (_snapshotImageView != nil)
    {
        CGRect snapshotImageFrame = _snapshotImageView.frame;
        snapshotImageFrame.origin.y = -inset.top + 45.0f;
        _snapshotImageView.frame = snapshotImageFrame;
    }
    
    CGPoint originalContentOffset = _collectionView.contentOffset;
    CGPoint contentOffset = originalContentOffset;
    
    if (scrollToBottom)
        contentOffset = CGPointMake(0.0f, -_collectionView.contentInset.top);
    else
    {
        contentOffset.y += originalInset.top - inset.top;
        contentOffset.y = MIN(contentOffset.y, contentHeight - _collectionView.bounds.size.height + inset.bottom);
        contentOffset.y = MAX(contentOffset.y, -inset.top);
    }
    
    if (stopScrolling)
        [_collectionView stopScrollingAnimation];
    
    if (duration > DBL_EPSILON)
    {
        [UIView animateWithDuration:duration delay:0 options:animationCurve << 16 animations:^
        {
            [_collectionView setDelayVisibleItemsUpdate:originalInset.top < inset.top && iosMajorVersion() < 7];
            bool decorationViewUpdatesWereDisabled = [_collectionView disableDecorationViewUpdates];
            [_collectionView setDisableDecorationViewUpdates:decorationViewUpdatesWereDisabled || originalInset.top < inset.top];
            if (!CGPointEqualToPoint(contentOffset, originalContentOffset))
                [_collectionView setBounds:CGRectMake(0, contentOffset.y, _collectionView.frame.size.width, _collectionView.frame.size.height)];
            
            _collectionView.contentInset = inset;
            [self _updateUnseenMessagesButton:orientation];
            [_collectionView setDelayVisibleItemsUpdate:false];
            [_collectionView setDisableDecorationViewUpdates:decorationViewUpdatesWereDisabled];
            
            [_emptyListPlaceholder adjustLayoutForOrientation:self.interfaceOrientation contentInsets:UIEdgeInsetsMake(_collectionView.contentInset.bottom, 0.0f, _collectionView.contentInset.top, 0.0f) duration:0.0 curve:0];
        } completion:^(BOOL finished)
        {
            if (finished)
            {
                [_collectionView updateVisibleItemsNow];
            }
        }];
    }
    else
    {
        if (!CGPointEqualToPoint(contentOffset, originalContentOffset))
            [_collectionView setBounds:CGRectMake(0, contentOffset.y, _collectionView.frame.size.width, _collectionView.frame.size.height)];
        
        _collectionView.contentInset = inset;
        [self _updateUnseenMessagesButton:orientation];
        
        [_emptyListPlaceholder adjustLayoutForOrientation:self.interfaceOrientation contentInsets:UIEdgeInsetsMake(_collectionView == nil ? self.controllerInset.top : _collectionView.contentInset.bottom, 0.0f, _collectionView == nil ? _currentInputPanel.frame.size.height : _collectionView.contentInset.top, 0.0f) duration:0.0 curve:0];
    }
}

- (void)keyboardWillChangeFrame:(NSNotification *)notification
{
    if ((freedomUIKitTest3() && freedomUIKitTest3_1()) || [self viewControllerIsAnimatingAppearanceTransition] || [(TGNavigationController *)self.navigationController isInPopTransition] || [(TGNavigationController *)self.navigationController isInControllerTransition])
        return;
    
    UIInterfaceOrientation orientation = self.interfaceOrientation;
    CGSize collectionViewSize = [self collectionViewSizeForInterfaceOrientation:orientation];
    
    NSTimeInterval duration = notification.userInfo[UIKeyboardAnimationDurationUserInfoKey] == nil ? 0.3 : [notification.userInfo[UIKeyboardAnimationDurationUserInfoKey] doubleValue];
    int curve = [notification.userInfo[UIKeyboardAnimationCurveUserInfoKey] intValue];
    CGRect screenKeyboardFrame = [notification.userInfo[UIKeyboardFrameEndUserInfoKey] CGRectValue];
    CGRect keyboardFrame = [self.view convertRect:screenKeyboardFrame fromView:nil];
    
    CGFloat keyboardHeight = (keyboardFrame.size.height <= FLT_EPSILON || keyboardFrame.size.width <= FLT_EPSILON) ? 0.0f :  (collectionViewSize.height - keyboardFrame.origin.y);
    
    if (keyboardFrame.origin.y + keyboardFrame.size.height < collectionViewSize.height - FLT_EPSILON)
        keyboardHeight = 0.0f;
    
    _keyboardHeight = keyboardHeight;
    
    TGLog(@"keyboardWillChangeFrame: orientation: %d, screenSize: %@, keyboardFrame: %@, userInfo: %@", (int)orientation, NSStringFromCGSize(collectionViewSize), NSStringFromCGRect(keyboardFrame), notification.userInfo);
    
    if (ABS(collectionViewSize.width - _collectionView.frame.size.width) > FLT_EPSILON)
    {
        dispatch_async(dispatch_get_main_queue(), ^
        {
            [self _performOrientationChangesWithDuration:0.3 orientation:orientation];
        });
    }
    else
    {
        [_currentInputPanel adjustForOrientation:orientation keyboardHeight:keyboardHeight duration:duration animationCurve:curve];
        [self _adjustCollectionViewForOrientation:orientation keyboardHeight:keyboardHeight inputContainerHeight:_currentInputPanel.frame.size.height duration:duration animationCurve:curve];
    }
}

- (void)keyboardDidChangeFrame:(NSNotification *)notification
{
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad && notification.userInfo[UIKeyboardAnimationDurationUserInfoKey] == nil)
    {
        UIInterfaceOrientation orientation = self.interfaceOrientation;
        CGSize collectionViewSize = [self collectionViewSizeForInterfaceOrientation:orientation];
        
        NSTimeInterval duration = 0.3;
        int curve = [notification.userInfo[UIKeyboardAnimationCurveUserInfoKey] intValue];
        CGRect screenKeyboardFrame = [notification.userInfo[UIKeyboardFrameEndUserInfoKey] CGRectValue];
        CGRect keyboardFrame = [self.view convertRect:screenKeyboardFrame fromView:nil];
        
        CGFloat keyboardHeight = (keyboardFrame.size.height <= FLT_EPSILON || keyboardFrame.size.width <= FLT_EPSILON) ? 0.0f :  (collectionViewSize.height - keyboardFrame.origin.y);
        
        if (keyboardFrame.origin.y + keyboardFrame.size.height < collectionViewSize.height - FLT_EPSILON)
            keyboardHeight = 0.0f;
        
        _keyboardHeight = keyboardHeight;
        
        TGLog(@"keyboardDidChangeFrame: orientation: %d, screenSize: %@, keyboardFrame: %@, userInfo: %@", (int)orientation, NSStringFromCGSize(collectionViewSize), NSStringFromCGRect(keyboardFrame), notification.userInfo);
        
        [_currentInputPanel adjustForOrientation:orientation keyboardHeight:keyboardHeight duration:duration animationCurve:curve];
        [self _adjustCollectionViewForOrientation:orientation keyboardHeight:keyboardHeight inputContainerHeight:_currentInputPanel.frame.size.height duration:duration animationCurve:curve];
    }
}

- (void)_performOrientationChangesWithDuration:(NSTimeInterval)duration orientation:(UIInterfaceOrientation)orientation
{
    bool animated = duration > DBL_EPSILON;
    CGSize collectionViewSize = [self collectionViewSizeForInterfaceOrientation:orientation];
    CGFloat keyboardHeight = _keyboardHeight;
    
    if (_titlePanelWrappingView != nil)
    {
        CGRect titleWrapperFrame = CGRectMake(0.0f, self.controllerInset.top, collectionViewSize.width, _titlePanelWrappingView.frame.size.height);
        CGRect titlePanelFrame = CGRectMake(0.0f, 0.0f, titleWrapperFrame.size.width, _currentTitlePanel.frame.size.height);
        if (duration > DBL_EPSILON)
        {
            [UIView animateWithDuration:duration animations:^
            {
                _titlePanelWrappingView.frame = titleWrapperFrame;
                _currentTitlePanel.frame = titlePanelFrame;
            }];
        }
        else
        {
            _titlePanelWrappingView.frame = titleWrapperFrame;
            _currentTitlePanel.frame = titlePanelFrame;
        }
    }
    
    [_currentInputPanel changeOrientationToOrientation:orientation keyboardHeight:keyboardHeight duration:duration];
    
    CGFloat maxOriginY = _collectionView.contentOffset.y + _collectionView.contentInset.top;
    CGPoint previousContentOffset = _collectionView.contentOffset;
    CGRect previousCollectionFrame = _collectionView.frame;
    
    int anchorItemIndex = -1;
    CGFloat anchorItemOriginY = 0.0f;
    CGFloat anchorItemRelativeOffset = 0.0f;
    CGFloat anchorItemHeight = 0.0f;
    
    NSMutableArray *previousItemFrames = [[NSMutableArray alloc] init];
    CGRect previousVisibleBounds = CGRectMake(previousContentOffset.x, previousContentOffset.y, _collectionView.frame.size.width, _collectionView.frame.size.height);
    
    NSMutableSet *previousVisibleItemIndices = [[NSMutableSet alloc] init];
    
    std::vector<TGDecorationViewAttrubutes> previousDecorationAttributes;
    NSArray *previousLayoutAttributes = [_collectionLayout layoutAttributesForItems:_items containerWidth:previousCollectionFrame.size.width maxHeight:FLT_MAX decorationViewAttributes:&previousDecorationAttributes contentHeight:NULL];
    
    int collectionItemCount = _items.count;
    for (int i = 0; i < collectionItemCount; i++)
    {
        UICollectionViewLayoutAttributes *attributes = previousLayoutAttributes[i];
        CGRect itemFrame = attributes.frame;
        
        if (itemFrame.origin.y < maxOriginY)
        {
            anchorItemHeight = itemFrame.size.height;
            anchorItemIndex = i;
            anchorItemOriginY = itemFrame.origin.y;
        }
        
        if (!CGRectIsEmpty(CGRectIntersection(itemFrame, previousVisibleBounds)))
            [previousVisibleItemIndices addObject:@(i)];
        
        [previousItemFrames addObject:[NSValue valueWithCGRect:itemFrame]];
    }
    
    if (anchorItemIndex != -1)
    {
        if (anchorItemHeight > 1.0f)
            anchorItemRelativeOffset = (anchorItemOriginY - (_collectionView.contentOffset.y + _collectionView.contentInset.top)) / anchorItemHeight;
    }
    
    _collectionView.frame = CGRectMake(0, 0, collectionViewSize.width, collectionViewSize.height);
    [_companion _setControllerWidthForItemCalculation:_collectionView.frame.size.width];
    
    [_collectionLayout invalidateLayout];
    
    UIEdgeInsets originalInset = _collectionView.contentInset;
    UIEdgeInsets inset = originalInset;
    inset.top = keyboardHeight + _currentInputPanel.frame.size.height;
    inset.bottom = self.controllerInset.top;
    _collectionView.contentInset = inset;
    [self _updateUnseenMessagesButton:orientation];
    
    [_emptyListPlaceholder adjustLayoutForOrientation:orientation contentInsets:UIEdgeInsetsMake(_collectionView.contentInset.bottom, 0.0f, _collectionView.contentInset.top, 0.0f) duration:duration curve:0];
    
    CGFloat newContentHeight = 0.0f;
    std::vector<TGDecorationViewAttrubutes> newDecorationAttributes;
    NSArray *newLayoutAttributes = [_collectionLayout layoutAttributesForItems:_items containerWidth:_collectionView.frame.size.width maxHeight:FLT_MAX decorationViewAttributes:&newDecorationAttributes contentHeight:&newContentHeight];
    
    CGPoint newContentOffset = _collectionView.contentOffset;
    newContentOffset.y = - _collectionView.contentInset.top;
    if (anchorItemIndex >= 0 && anchorItemIndex < (int)newLayoutAttributes.count)
    {
        UICollectionViewLayoutAttributes *attributes = newLayoutAttributes[anchorItemIndex];
        newContentOffset.y += attributes.frame.origin.y - floorf(anchorItemRelativeOffset * attributes.frame.size.height);
    }
    if (newContentOffset.y > newContentHeight + _collectionView.contentInset.bottom - _collectionView.frame.size.height)
        newContentOffset.y = newContentHeight + _collectionView.contentInset.bottom - _collectionView.frame.size.height;
    if (newContentOffset.y < -_collectionView.contentInset.top)
        newContentOffset.y = -_collectionView.contentInset.top;
    
    NSMutableArray *transitiveItemIndicesWithFrames = [[NSMutableArray alloc] init];
    
    CGRect newVisibleBounds = CGRectMake(newContentOffset.x, newContentOffset.y, _collectionView.frame.size.width, _collectionView.frame.size.height);
    for (int i = 0; i < collectionItemCount; i++)
    {
        UICollectionViewLayoutAttributes *attributes = newLayoutAttributes[i];
        CGRect itemFrame = attributes.frame;
        
        if (CGRectIsEmpty(CGRectIntersection(itemFrame, newVisibleBounds)) && [previousVisibleItemIndices containsObject:@(i)])
            [transitiveItemIndicesWithFrames addObject:@[@(i), [NSValue valueWithCGRect:itemFrame]]];
    }
    
    NSMutableDictionary *transitiveCells = [[NSMutableDictionary alloc] init];
    
    if (animated && !_collectionView.decelerating && !_collectionView.dragging && !_collectionView.tracking)
    {
        for (NSArray *nDesc in transitiveItemIndicesWithFrames)
        {
            NSNumber *nIndex = nDesc[0];
            
            TGModernCollectionCell *currentCell = (TGModernCollectionCell *)[_collectionView cellForItemAtIndexPath:[NSIndexPath indexPathForItem:[nIndex intValue] inSection:0]];
            if (currentCell != nil)
            {
                TGModernCollectionCell *transitiveCell = [[TGModernCollectionCell alloc] initWithFrame:[nDesc[1] CGRectValue]];
                [(TGModernConversationItem *)_items[[nIndex intValue]] moveToCell:transitiveCell];
                
                transitiveCells[nIndex] = transitiveCell;
            }
        }
    }
    
    _collectionView.contentOffset = newContentOffset;
    
    [_collectionView updateVisibleItemsNow];
    [_collectionView layoutSubviews];
    
    if (animated)
    {
        _collectionView.clipsToBounds = false;
        
        CGFloat contentOffsetDifference = newContentOffset.y - previousContentOffset.y + (_collectionView.frame.size.height - previousCollectionFrame.size.height);
        CGFloat widthDifference = _collectionView.frame.size.width - previousCollectionFrame.size.width;
        
        NSMutableArray *itemFramesToRestore = [[NSMutableArray alloc] init];
        
        bool contentUpdatesWereDisabled = _companion.viewContext.contentUpdatesDisabled;
        _companion.viewContext.contentUpdatesDisabled = true;
        for (int i = 0; i < collectionItemCount; i++)
        {
            TGModernCollectionCell *cell = (TGModernCollectionCell *)[_collectionView cellForItemAtIndexPath:[NSIndexPath indexPathForRow:i inSection:0]];
            TGModernCollectionCell *transitiveCell = transitiveCells[@(i)];
            
            if (transitiveCell != nil)
            {
                if (cell == nil)
                {
                    cell = transitiveCell;
                    [_collectionView addSubview:transitiveCell];
                }
                else
                {
                    if ([_items[i] boundCell] == transitiveCell)
                        [_items[i] moveToCell:cell];
                    [transitiveCells removeObjectForKey:@(i)];
                }
            }
            
            if (cell != nil)
            {
                [itemFramesToRestore addObject:@[@(i), [NSValue valueWithCGRect:cell.frame]]];
                CGRect previousFrame = [previousItemFrames[i] CGRectValue];
                cell.frame = CGRectOffset(previousFrame, widthDifference, contentOffsetDifference);
                
                TGModernConversationItem *item = _items[i];
                [item sizeForContainerSize:CGSizeMake(previousFrame.size.width, 0.0f)];
            }
        }
        
        for (auto it = previousDecorationAttributes.begin(); it != previousDecorationAttributes.end(); it++)
        {
            UIView *decorationView = [_collectionView viewForDecorationAtIndex:it->index];
            decorationView.frame = CGRectOffset(it->frame, widthDifference, contentOffsetDifference);
            [decorationView layoutSubviews];
        }
        
        [UIView animateWithDuration:duration animations:^
        {
            for (NSArray *frameDesc in itemFramesToRestore)
            {
                UIView *cell = [_collectionView cellForItemAtIndexPath:[NSIndexPath indexPathForRow:[frameDesc[0] intValue] inSection:0]];
                if (cell == nil)
                    cell = transitiveCells[frameDesc[0]];
                cell.frame = [frameDesc[1] CGRectValue];
                
                TGModernConversationItem *item = _items[[frameDesc[0] intValue]];
                [item sizeForContainerSize:CGSizeMake(_collectionView.frame.size.width, 0.0f)];
            }
            
            for (auto it = newDecorationAttributes.begin(); it != newDecorationAttributes.end(); it++)
            {
                UIView *decorationView = [_collectionView viewForDecorationAtIndex:it->index];
                decorationView.frame = it->frame;
                [decorationView layoutSubviews];
            }
        } completion:^(BOOL finished)
        {
            if (finished)
            {
                _collectionView.clipsToBounds = true;
            }
            
            [transitiveCells enumerateKeysAndObjectsUsingBlock:^(NSNumber *nIndex, TGModernCollectionCell *cell, __unused BOOL *stop)
            {
                [(TGModernConversationItem *)_items[[nIndex intValue]] unbindCell:_viewStorage];
                [cell removeFromSuperview];
            }];
        }];
        _companion.viewContext.contentUpdatesDisabled = contentUpdatesWereDisabled;
        [_collectionView updateRelativeBounds];
    }
}

#pragma mark -

- (void)actionStageActionRequested:(NSString *)action options:(id)options
{
    if ([action isEqualToString:@"clearAllMessages"])
    {
        [self _commitClearAllMessages];
    }
    else if ([action isEqualToString:@"mapViewFinished"])
    {
        [self dismissViewControllerAnimated:true completion:nil];
        
        if (options[@"latitude"] != nil)
            [_companion controllerWantsToSendMapWithLatitude:[options[@"latitude"] doubleValue] longitude:[options[@"longitude"] doubleValue]];
    }
    else if ([action isEqualToString:@"menuAction"])
    {
        int32_t mid = [options[@"userInfo"][@"mid"] int32Value];
        if (mid != 0)
        {
            TGMessageModernConversationItem *menuMessageItem = nil;
            
            int index = -1;
            for (TGMessageModernConversationItem *messageItem in _items)
            {
                index++;
                if (messageItem->_message.mid == mid)
                {
                    menuMessageItem = messageItem;
                    break;
                }
            }
            
            NSString *menuAction = options[@"action"];
            if ([menuAction isEqualToString:@"copy"])
            {
                if (menuMessageItem != nil && menuMessageItem->_message.text.length != 0)
                {
                    UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];
                    [pasteboard setString:menuMessageItem->_message.text];
                }
            }
            else if ([menuAction isEqualToString:@"delete"])
            {
                if (menuMessageItem != nil && index >= 0)
                {
                    [self deleteItemsAtIndices:[NSIndexSet indexSetWithIndex:index] animated:true];
                    [_companion controllerDeletedMessages:@[@(mid)]];
                }
            }
            else if ([menuAction isEqualToString:@"forward"])
                [_companion controllerWantsToForwardMessages:@[@(mid)]];
            else if ([menuAction isEqualToString:@"select"])
                [self _enterEditingMode:mid];
        }
    }
    else if ([action isEqualToString:@"menuWillHide"])
    {
        for (TGModernCollectionCell *cell in _collectionView.visibleCells)
        {
            TGMessageModernConversationItem *messageItem = cell.boundItem;
            [messageItem setTemporaryHighlighted:false viewStorage:_viewStorage];
        }
    }
}

@end
