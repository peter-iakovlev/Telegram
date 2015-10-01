#import "TGModernConversationController.h"

#import "FreedomUIKit.h"

#import "TGPeerIdAdapter.h"

#import "TGUpdateStateRequestBuilder.h"

#import "TGModernConversationCompanion.h"

#import "TGImagePickerController.h"

#import "TGModernConversationCollectionView.h"
#import "TGModernConversationViewLayout.h"

#import "TGModernConversationItem.h"
#import "TGModernFlatteningViewModel.h"
#import "TGModernTemporaryView.h"

#import "TGImageUtils.h"
#import "TGPhoneUtils.h"
#import "TGStringUtils.h"
#import "TGFileUtils.h"
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

#import "TGInterfaceManager.h"

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
#import "TGSecretInfiniteLifetimePeerMediaGalleryModel.h"

#import "TGGenericPeerGalleryItem.h"
#import "TGModernGalleryVideoItemView.h"

#import "TGDropboxHelper.h"
#import "TGICloudItem.h"
#import "TGGoogleDriveController.h"

#import "TGLocationViewController.h"
#import "TGLocationPickerController.h"
#import "TGMapViewController.h"
#import "TGWebSearchController.h"
#import "TGLegacyCameraController.h"
#import "TGDocumentController.h"
#import "TGForwardContactPickerController.h"
#import "TGAudioRecorder.h"
#import "TGModernConversationAudioPlayer.h"

#import "TGAttachmentSheetRecentCameraView.h"
#import "PGCamera.h"
#import "TGCameraPreviewView.h"
#import "TGCameraController.h"
#import "TGMediaFoldersController.h"
#import "TGModernMediaPickerController.h"
#import "TGMediaPickerAssetsLibrary.h"
#import "TGAssetImageManager.h"
#import "TGAccessChecker.h"
#import "UIDevice+PlatformInfo.h"

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

#import "TGGiphySearchResultItem.h"
#import "TGBingSearchResultItem.h"
#import "TGWebSearchInternalImageResult.h"
#import "TGWebSearchInternalGifResult.h"

#import "TGAttachmentSheetWindow.h"
#import "TGAttachmentSheetRecentItemView.h"
#import "TGAttachmentSheetButtonItemView.h"
#import "TGAttachmentSheetRecentControlledButtonItemView.h"
#import "TGAttachmentSheetFileInstructionItemView.h"

#import "ATQueue.h"

#import "TGAssetImageManager.h"

#import "TGProgressWindow.h"

#import "TGModernConversationControllerDynamicTypeSignals.h"
#import "TGMessageViewModel.h"

#import "TGModenConcersationReplyAssociatedPanel.h"
#import "TGStickerAssociatedInputPanel.h"
#import "TGModernConversationMentionsAssociatedPanel.h"
#import "TGModernConversationHashtagsAssociatedPanel.h"
#import "TGModernConversationForwardInputPanel.h"
#import "TGModernConversationWebPreviewInputPanel.h"

#import "TGExternalGalleryModel.h"

#import "TGStickersSignals.h"

#import "TGCommandKeyboardView.h"

#import "TGModernConversationCommandsAssociatedPanel.h"

#import "TGEmbedPreviewController.h"

#import "TGSearchBar.h"

#import "TGGlobalMessageSearchSignals.h"

#import "TGModernConversationSearchInputPanel.h"

#import "TGAttachmentSheetEmbedItemView.h"

#import "TGModernDateHeaderView.h"

#import "TGModernConversationControllerView.h"

#import <SafariServices/SafariServices.h>

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
    TGModernConversationPanelAnimationFade = 2,
    TGModernConversationPanelAnimationSlideFar = 3
} TGModernConversationPanelAnimation;

@interface TGModernConversationController () <UICollectionViewDataSource, TGModernConversationViewLayoutDelegate, UIViewControllerTransitioningDelegate, HPGrowingTextViewDelegate, UIGestureRecognizerDelegate, TGLegacyCameraControllerDelegate, TGModernConversationInputTextPanelDelegate, TGModernConversationEditingPanelDelegate, TGModernConversationTitleViewDelegate, TGForwardContactPickerControllerDelegate, TGModernConversationAudioPlayerDelegate, TGAudioRecorderDelegate, NSUserActivityDelegate, UIDocumentInteractionControllerDelegate, UIDocumentPickerDelegate, TGImagePickerControllerDelegate, TGSearchBarDelegate>
{
    bool _alreadyHadWillAppear;
    bool _alreadyHadDidAppear;
    NSTimeInterval _willAppearTimestamp;
    bool _receivedWillDisappear;
    bool _didDisappearBeforeAppearing;
    NSString *_initialInputText;
    NSArray *_initialForwardMessages;
    
    bool _shouldHaveTitlePanelLoaded;
    
    bool _editingMode;
    
    NSMutableArray *_items;
    
    NSMutableSet *_collectionRegisteredIdentifiers;
    
    TGModernConversationControllerView *_view;
    
    TGModernConversationCollectionView *_collectionView;
    TGModernConversationViewLayout *_collectionLayout;
    UIScrollView *_collectionViewScrollToTopProxy;
    
    TGModernViewStorage *_viewStorage;
    NSMutableArray *_itemsBoundToTemporaryContainer;
    bool _disableItemBinding;
    
    CGImageRef _snapshotImage;
    TGModernTemporaryView *_snapshotBackgroundView;
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
    
    bool _isRotating;
    CGFloat _keyboardHeight;
    CGFloat _halfTransitionKeyboardHeight;
    TGObserverProxy *_keyboardWillHideProxy;
    TGObserverProxy *_keyboardWillChangeFrameProxy;
    TGObserverProxy *_keyboardDidChangeFrameProxy;
    
    TGObserverProxy *_applicationWillResignActiveProxy;
    TGObserverProxy *_applicationDidEnterBackgroundProxy;
    TGObserverProxy *_applicationDidBecomeActiveProxy;
    
    TGObserverProxy *_screenshotProxy;
    
    TGObserverProxy *_dropboxProxy;
    
    CGPoint _collectionPanTouchContentOffset;
    bool _collectionPanStartedAtBottom;
    
    TGModernConversationTitleView *_titleView;
    TGModernConversationAvatarButton *_avatarButton;
    UIBarButtonItem *_avatarButtonItem;
    UIBarButtonItem *_infoButtonItem;
    
    TGMenuContainerView *_menuContainerView;
    
    UIButton *_unseenMessagesButton;
    
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
    
    NSUserActivity *_currentActivity;
    
    TGAttachmentSheetWindow *_attachmentSheetWindow;
    UIDocumentInteractionController *_interactionController;
    
    TGICloudItemRequest *_currentICloudItemRequest;
    
    SDisposableSet *_disposable;
    
    int32_t _temporaryHighlightMessageIdUponDisplay;
    bool _hasUnseenMessagesBelow;
    int32_t _scrollBackMessageId;
    bool _canCheckScrollBackMessageId;
    
    NSString *_currentLinkParseLink;
    SMetaDisposable *_currentLinkParseDisposable;
    
    bool _disableLinkPreviewsForMessage;
    
    TGBotReplyMarkup *_replyMarkup;
    bool _hasBots;
    bool _canBroadcast;
    bool _isBroadcasting;
    bool _isAlwaysBroadcasting;
    bool _inputDisabled;
    bool _isChannel;
    
    UIView *_conversationHeader;
    
    NSNumber *_scrollingToBottom;
    
    TGSearchBar *_searchBar;
    TGModernConversationSearchInputPanel *_searchPanel;
    
    NSString *_query;
    SMetaDisposable *_searchDisposable;
    NSArray *_searchResultsIds;
    NSUInteger _searchResultsOffset;
    
    int32_t _messageIdForVisibleHoleDirection;
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
        
        _keyboardWillHideProxy = [[TGObserverProxy alloc] initWithTarget:self targetSelector:@selector(keyboardWillHide:) name:@"UIDeviceOrientationDidChangeNotification"];
        _keyboardWillChangeFrameProxy = [[TGObserverProxy alloc] initWithTarget:self targetSelector:@selector(keyboardWillChangeFrame:) name:UIKeyboardWillChangeFrameNotification];
        _keyboardDidChangeFrameProxy = [[TGObserverProxy alloc] initWithTarget:self targetSelector:@selector(keyboardDidChangeFrame:) name:UIKeyboardDidChangeFrameNotification];
        
        _applicationWillResignActiveProxy = [[TGObserverProxy alloc] initWithTarget:self targetSelector:@selector(applicationWillResignActive:) name:UIApplicationWillResignActiveNotification];
        _applicationDidEnterBackgroundProxy = [[TGObserverProxy alloc] initWithTarget:self targetSelector:@selector(applicationDidEnterBackground:) name:UIApplicationDidEnterBackgroundNotification];
        _applicationDidBecomeActiveProxy = [[TGObserverProxy alloc] initWithTarget:self targetSelector:@selector(applicationDidBecomeActive:) name:UIApplicationDidBecomeActiveNotification];
        
        if (iosMajorVersion() >= 7)
        {
            _screenshotProxy = [[TGObserverProxy alloc] initWithTarget:self targetSelector:@selector(serviceNotificationReceived:) name:UIApplicationUserDidTakeScreenshotNotification];
        }
        
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
        
        _disposable = [[SDisposableSet alloc] init];
        
        if (iosMajorVersion() >= 7)
        {
            __weak TGModernConversationController *weakSelf = self;
            [_disposable add:[[TGModernConversationControllerDynamicTypeSignals dynamicTypeBaseFontPointSize] startWithNext:^(NSNumber *pointSize)
            {
                TGUpdateMessageViewModelLayoutConstants([pointSize floatValue]);
                
                __strong TGModernConversationController *strongSelf = weakSelf;
                if (strongSelf != nil)
                    [strongSelf refreshMetrics];
            } error:nil completed:nil]];
        }
    }
    return self;
}

- (void)dealloc
{
    [_disposable dispose];
    
    [_actionHandle reset];
    
    _collectionView.delegate = nil;
    _collectionView.dataSource = nil;
    
    if (_snapshotImage != nil)
    {
        CGImageRelease(_snapshotImage);
        _snapshotImage = nil;
    }
    
    [_companion unbindController];
    
    if (_attachmentSheetWindow != nil)
        _attachmentSheetWindow.rootViewController = nil;
}

- (NSInteger)_indexForCollectionView
{
    return 1;
}

- (void)_resetCollectionView
{
    [self _resetCollectionView:false];
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
    
    CGSize collectionViewSize = _view.bounds.size;
    
    _collectionLayout = [[TGModernConversationViewLayout alloc] init];
    _collectionView = [[TGModernConversationCollectionView alloc] initWithFrame:CGRectMake(0, -210.0f, collectionViewSize.width, collectionViewSize.height + 210.0f) collectionViewLayout:_collectionLayout];
    [_companion _setControllerWidthForItemCalculation:_collectionView.frame.size.width];
    _collectionView.headerView = _conversationHeader;
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
    contentInset.bottom = 210.0f + [_collectionView implicitTopInset];
    contentInset.top = _keyboardHeight + _currentInputPanel.frame.size.height;
    _collectionView.contentInset = contentInset;
    [self _adjustCollectionInset];
    
    [_emptyListPlaceholder adjustLayoutForSize:collectionViewSize contentInsets:UIEdgeInsetsMake(_collectionView.contentInset.bottom - 210.0f - [_collectionView implicitTopInset], 0.0f, _collectionView.contentInset.top, 0.0f) duration:0.0f curve:0];
    
    [_view insertSubview:_collectionView atIndex:[self _indexForCollectionView]];
    
    _collectionViewScrollToTopProxy = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, _view.frame.size.width, 8)];
    _collectionViewScrollToTopProxy.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    _collectionViewScrollToTopProxy.delegate = self;
    _collectionViewScrollToTopProxy.scrollsToTop = true;
    _collectionViewScrollToTopProxy.contentSize = CGSizeMake(1, 16);
    _collectionViewScrollToTopProxy.contentOffset = CGPointMake(0, 8);
    [_view insertSubview:_collectionViewScrollToTopProxy belowSubview:_collectionView];
    
    if (resetPositioning)
    {
        int32_t messageId = [_companion initialPositioningMessageId];
        TGInitialScrollPosition scrollPosition = [_companion initialPositioningScrollPosition];
        if (messageId != 0)
        {
            _collectionView.contentOffset = CGPointMake(0.0f, [self contentOffsetForMessageId:messageId scrollPosition:scrollPosition initial:true additionalOffset:0.0f]);
        }
    }
    
    [_collectionView layoutSubviews];
    [self _updateVisibleItemIndices:nil];
}

- (CGFloat)contentOffsetForMessageId:(int32_t)messageId scrollPosition:(TGInitialScrollPosition)scrollPosition initial:(bool)initial additionalOffset:(CGFloat)additionalOffset
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
            if (index == 0 && initial) {
                return -_collectionView.contentInset.top;
            }
            
            UICollectionViewLayoutAttributes *attributes = [_collectionLayout layoutAttributesForItemAtIndexPath:[NSIndexPath indexPathForItem:index inSection:0]];
            if (attributes != nil)
            {
                switch (scrollPosition)
                {
                    case TGInitialScrollPositionTop:
                        contentOffsetY = CGRectGetMaxY(attributes.frame) + _collectionView.contentInset.bottom - [_collectionView implicitTopInset] - _collectionView.frame.size.height + [_companion initialPositioningOverflowForScrollPosition:scrollPosition];
                        break;
                    case TGInitialScrollPositionCenter:
                    {
                        CGFloat visibleHeight = _collectionView.frame.size.height - _collectionView.contentInset.top - _collectionView.contentInset.bottom + [_collectionView implicitTopInset];
                        contentOffsetY = CGFloor(CGRectGetMidY(attributes.frame) - visibleHeight / 2.0f - _collectionView.contentInset.top);
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
    
    contentOffsetY += additionalOffset;
    
    if (contentOffsetY > _collectionLayout.collectionViewContentSize.height + _collectionView.contentInset.bottom - _collectionView.frame.size.height)
    {
        contentOffsetY = _collectionLayout.collectionViewContentSize.height + _collectionView.contentInset.bottom - _collectionView.frame.size.height;
    }
    if (contentOffsetY < -_collectionView.contentInset.top)
    {
        contentOffsetY = -_collectionView.contentInset.top;
    }
    
    return contentOffsetY;
}

- (void)setInitialSnapshot:(CGImageRef)image backgroundView:(TGModernTemporaryView *)backgroundView viewStorage:(TGModernViewStorage *)viewStorage topEdge:(CGFloat)topEdge
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
        [_snapshotBackgroundView unbindItems];
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
                [_view insertSubview:_snapshotImageView atIndex:[self _indexForCollectionView]];
            }
            
            _snapshotBackgroundView = backgroundView;
            if (_snapshotBackgroundView != nil)
            {
                [_view insertSubview:_snapshotBackgroundView belowSubview:_snapshotImageView];
            }
            
            _snapshotImageView.layer.contents = (__bridge id)_snapshotImage;
            
            if (_conversationHeader != nil)
            {
                [_view addSubview:_conversationHeader];
                CGRect headerFrame = _conversationHeader.frame;
                headerFrame.origin.x = CGFloor((_view.frame.size.width - headerFrame.size.width) / 2.0f);
                headerFrame.origin.y = _view.frame.size.height - _conversationHeader.frame.size.height - topEdge - 4.0f;
                CGFloat visibleHeight = _view.frame.size.height - self.controllerInset.top - self.controllerInset.bottom - 44.0f;
                headerFrame.origin.y = MIN(headerFrame.origin.y, self.controllerInset.top + CGFloor((visibleHeight - headerFrame.size.height) / 2.0f));
                _conversationHeader.frame = headerFrame;
            }
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
    
    if (self.isFirstInStack) {
        return [[UIBarButtonItem alloc] initWithTitle:TGLocalized(@"Common.Close") style:UIBarButtonItemStylePlain target:self action:@selector(closeButtonPressed)];
    }
    
    return nil;
}

- (void)setIsFirstInStack:(bool)isFirstInStack {
    if (isFirstInStack != self.isFirstInStack) {
        [super setIsFirstInStack:isFirstInStack];
        
        [self setLeftBarButtonItem:[self defaultLeftBarButtonItem] animated:false];
    }
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
    
    [self check3DTouch];
    
    _view = [[TGModernConversationControllerView alloc] initWithFrame:self.view.bounds];
    _view.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    __weak TGModernConversationController *weakSelf = self;
    _view.layoutForSize = ^(CGSize size) {
        __strong TGModernConversationController *strongSelf = weakSelf;
        if (strongSelf != nil) {
            if (strongSelf->_keyboardHeight < FLT_EPSILON) {
                [strongSelf _performSizeChangesWithDuration:strongSelf->_isRotating ? 0.3 : 0.0 size:size];
            }
        }
    };
    [self.view addSubview:_view];
    
    _view.clipsToBounds = true;
    _view.backgroundColor = [UIColor whiteColor];
    
    _backgroundView = [[UIImageView alloc] initWithFrame:_view.bounds];
    UIImage *wallpaperImage = [[TGWallpaperManager instance] currentWallpaperImage];
    _backgroundView.image = wallpaperImage;
    _backgroundView.clipsToBounds = true;
    _backgroundView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    _backgroundView.contentMode = UIViewContentModeScaleAspectFill;
    [_view addSubview:_backgroundView];
    
    _inputTextPanel = [[TGModernConversationInputTextPanel alloc] initWithFrame:CGRectMake(0, _view.frame.size.height - 45, _view.frame.size.width, 45) accessoryView:[_companion _controllerInputTextPanelAccessoryView]];

    if (_initialInputText.length != 0)
    {
        [_inputTextPanel.inputField setText:_initialInputText];
        _initialInputText = nil;
    }
    
    _inputTextPanel.delegate = self;
    [_inputTextPanel setReplyMarkup:_replyMarkup];
    [_inputTextPanel setHasBots:_hasBots];
    [_inputTextPanel setCanBroadcast:_canBroadcast];
    [_inputTextPanel setIsBroadcasting:_isBroadcasting];
    [_inputTextPanel setIsAlwaysBroadcasting:_isAlwaysBroadcasting];
    [_inputTextPanel setInputDisabled:_inputDisabled];
    [_inputTextPanel setIsChannel:_isChannel];
    
    if (_initialForwardMessages != nil)
    {
        TGModernConversationForwardInputPanel *panel = [[TGModernConversationForwardInputPanel alloc] initWithMessages:_initialForwardMessages];
        __weak TGModernConversationController *weakSelf = self;
        panel.dismiss = ^
        {
            __strong TGModernConversationController *strongSelf = weakSelf;
            if (strongSelf != nil)
            {
                [strongSelf->_inputTextPanel setPrimaryExtendedPanel:nil animated:true];
                [strongSelf->_inputTextPanel setSecondaryExtendedPanel:nil animated:true];
            }
        };
        [_inputTextPanel setPrimaryExtendedPanel:panel animated:true];
    }
    _initialForwardMessages = nil;
    
    if (_customInputPanel != nil)
        [self setInputPanel:_customInputPanel animated:false];
    else
        [self setInputPanel:[self defaultInputPanel] animated:false];
    
    if (_currentTitlePanel != nil)
    {
        id currentTitlePanel = _currentTitlePanel;
        _currentTitlePanel = nil;
        [self setCurrentTitlePanel:currentTitlePanel animation:TGModernConversationPanelAnimationNone];
    }
    
    [_view insertSubview:_emptyListPlaceholder belowSubview:_currentInputPanel];
    
    if (![self _updateControllerInset:false])
        [self controllerInsetUpdated:UIEdgeInsetsZero];
    
    [_emptyListPlaceholder adjustLayoutForSize:_view.bounds.size contentInsets:UIEdgeInsetsMake(self.controllerInset.top, 0.0f, _currentInputPanel.frame.size.height, 0.0f) duration:0.0f curve:0];
}

- (void)viewWillAppear:(BOOL)animated
{
    TGLog(@"willAppear");
    
    [self setRightBarButtonItem:[self defaultRightBarButtonItem]];
    
    if (self.navigationController.viewControllers.count >= 2)
    {
        UIViewController *previousController = [self.navigationController.viewControllers objectAtIndex:self.navigationController.viewControllers.count - 2];
        [_titleView setBackButtonTitle:previousController.navigationItem.backBarButtonItem.title.length == 0 ? TGLocalized(@"Common.Back") : previousController.navigationItem.backBarButtonItem.title];
    }
    
    if (_didDisappearBeforeAppearing)
        _keyboardHeight = 0;
    //else if (_receivedWillDisappear)
    //    _keyboardHeight = _halfTransitionKeyboardHeight;
    
    _receivedWillDisappear = false;
    
    _inputTextPanel.maybeInputField.internalTextView.enableFirstResponder = false;
    
    _willAppearTimestamp = CFAbsoluteTimeGetCurrent();
    
    CGSize collectionViewSize = _view.bounds.size;
    
    if (_collectionView != nil)
    {
        if (ABS(collectionViewSize.width - _collectionView.frame.size.width) > FLT_EPSILON)
            [self _performSizeChangesWithDuration:0.0f size:collectionViewSize];
        else
        {
            [_currentInputPanel adjustForSize:collectionViewSize keyboardHeight:_keyboardHeight duration:0.0 animationCurve:0];
            [self _adjustCollectionViewForSize:collectionViewSize keyboardHeight:_keyboardHeight inputContainerHeight:_currentInputPanel.frame.size.height duration:0.0 animationCurve:0];
        }
    }
    else
        [_currentInputPanel adjustForSize:collectionViewSize keyboardHeight:_keyboardHeight duration:0.0 animationCurve:0];
    
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
    if (_alreadyHadWillAppear)
    {
        [self _updateCanRegroupIncomingUnreadMessages];
    }
    _alreadyHadWillAppear = true;
    
    NSDictionary *userActivityData = [_companion userActivityData];
    if (false && iosMajorVersion() >= 8 && _currentActivity == nil && userActivityData != nil)
    {
        NSMutableDictionary *mutableUserActivityData = [[NSMutableDictionary alloc] initWithDictionary:userActivityData];
        if (_inputTextPanel.maybeInputField.text.length != 0)
            mutableUserActivityData[@"text"] = _inputTextPanel.maybeInputField.text;
        _currentActivity = [[NSUserActivity alloc] initWithActivityType:@"org.telegram.conversation"];
        _currentActivity.userInfo = mutableUserActivityData;
        _currentActivity.webpageURL = [NSURL URLWithString:@"https://telegram.org/dl"];
        _currentActivity.delegate = self;
        _currentActivity.supportsContinuationStreams = true;
        [_currentActivity becomeCurrent];
    }
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
    
    if (_shouldOpenKeyboardOnce)
    {
        _inputTextPanel.inputField.internalTextView.enableFirstResponder = true;
        _shouldOpenKeyboardOnce = false;
        [self openKeyboard];
    }
    
    _inputTextPanel.canShowKeyboardAutomatically = true;
    _inputTextPanel.enableKeyboard = true;
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
    [self _updateCanRegroupIncomingUnreadMessages];
    [self _updateCanReadHistory:TGModernConversationActivityChangeAuto];
}

- (void)serviceNotificationReceived:(NSNotification *)__unused notification
{
    if (self.navigationController.topViewController == self && self.presentedViewController == nil)
    {
        for (UIWindow *window in [[UIApplication sharedApplication] windows])
        {
            if ([window isKindOfClass:[TGOverlayControllerWindow class]])
            {
                TGOverlayControllerWindow *overlayControllerWindow = (TGOverlayControllerWindow *)window;
                if ([overlayControllerWindow.rootViewController isKindOfClass:[TGModernGalleryController class]])
                {
                    TGModernGalleryController *galleryController = (TGModernGalleryController *)overlayControllerWindow.rootViewController;
                    
                    if ([galleryController isFullyOpaque])
                        return;
                }
            }
        }
    }
    else
        return;
    
    NSMutableArray *messageIds = [[NSMutableArray alloc] init];
    for (TGModernCollectionCell *cell in _collectionView.visibleCells)
    {
        TGMessageModernConversationItem *item = cell.boundItem;
        if (item != nil)
            [messageIds addObject:@(item->_message.mid)];
    }
    
    [_companion serviceNotificationsForMessageIds:messageIds];
}

- (void)viewWillDisappear:(BOOL)animated
{
    _inputTextPanel.enableKeyboard = false;
    _inputTextPanel.canShowKeyboardAutomatically = true;
    
    _didDisappearBeforeAppearing = false;
    _receivedWillDisappear = true;
    
    freedomUIKitTest4_1();
    
    [self stopInlineMediaIfPlaying];
    
    [_collectionView stopScrollingAnimation];
    
    [self _updateCanReadHistory:TGModernConversationActivityChangeInactive];
    
    [self stopInlineMedia];
    
    _companion.viewContext.animationsEnabled = false;
    [self _updateItemsAnimationsEnabled];
    
    if (iosMajorVersion() >= 8)
    {
        [_currentActivity invalidate];
        _currentActivity = nil;
    }
    
    if (_attachmentSheetWindow != nil)
        [_attachmentSheetWindow dismissAnimated:animated completion:nil];
    
    _dropboxProxy = nil;
    
    [super viewWillDisappear:animated];
}

- (void)viewDidDisappear:(BOOL)animated
{
    _receivedWillDisappear = false;
    _didDisappearBeforeAppearing = true;
    
    _keyboardHeight = 0.0f;
    
    [_currentInputPanel adjustForSize:_view.bounds.size keyboardHeight:_keyboardHeight duration:0.0 animationCurve:0];
    
    [self _adjustCollectionViewForSize:_view.bounds.size keyboardHeight:_keyboardHeight inputContainerHeight:_currentInputPanel.frame.size.height duration:0.0 animationCurve:0];
    
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
    
    _isRotating = true;
    
    if (_keyboardHeight < FLT_EPSILON) {
        //[self _performSizeChangesWithDuration:duration size:_view.bounds.size];
    }
}

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation {
    [super didRotateFromInterfaceOrientation:fromInterfaceOrientation];
    
    _isRotating = false;
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
        _menuContainerView.frame = CGRectMake(0, self.controllerInset.top, _view.frame.size.width, _view.frame.size.height - self.controllerInset.top - self.controllerInset.bottom);
    }
    
    
    if (![self viewControllerIsChangingInterfaceOrientation])
    {
        if (_titlePanelWrappingView != nil)
        {
            _titlePanelWrappingView.frame = CGRectMake(0.0f, self.controllerInset.top, _view.frame.size.width, _titlePanelWrappingView.frame.size.height);
        }
    }
}

- (void)_adjustCollectionInset
{
    UIEdgeInsets contentInset = _collectionView.contentInset;
    if (ABS(contentInset.bottom - self.controllerInset.top) > FLT_EPSILON)
    {
        contentInset.bottom = self.controllerInset.top + 210.0f + [_collectionView implicitTopInset];
        _collectionView.contentInset = contentInset;
        [self _updateUnseenMessagesButton];
        
        [_emptyListPlaceholder adjustLayoutForSize:_view.bounds.size contentInsets:UIEdgeInsetsMake(_collectionView.contentInset.bottom - 210.0f - [_collectionView implicitTopInset], 0.0f, _collectionView.contentInset.top, 0.0f) duration:0.0f curve:0];
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
    [_searchBar resignFirstResponder];
}

- (void)tableTouchesCancelled
{
    for (TGModernCollectionCell *cell in _collectionView.visibleCells)
    {
        TGMessageModernConversationItem *item = cell.boundItem;
        if (item != nil)
            [item clearHighlights];
    }
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
            [_view addSubview:_currentInputPanel];
            [_currentInputPanel adjustForSize:_view.bounds.size keyboardHeight:_keyboardHeight duration:0.0 animationCurve:0];
            _currentInputPanel.frame = CGRectMake(_currentInputPanel.frame.origin.x, _view.frame.size.height, _currentInputPanel.frame.size.width, _currentInputPanel.frame.size.height);
        }
        
        [_currentInputPanel adjustForSize:_view.bounds.size keyboardHeight:_keyboardHeight duration:0.3 animationCurve:curve];
        [self _adjustCollectionViewForSize:_view.bounds.size keyboardHeight:_keyboardHeight inputContainerHeight:_currentInputPanel.frame.size.height duration:0.3 animationCurve:curve];
        
        [previousPanel endEditing:true];
        
        [UIView animateWithDuration:0.22 delay:0.00 options:0 animations:^
        {
            previousPanel.frame = CGRectMake(0.0f, _view.frame.size.height, previousPanel.frame.size.width, previousPanel.frame.size.height);
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
            [_view addSubview:_currentInputPanel];
            [_currentInputPanel adjustForSize:_view.bounds.size keyboardHeight:_keyboardHeight duration:0.0 animationCurve:0];
            _currentInputPanel.frame = CGRectMake(_currentInputPanel.frame.origin.x, _view.frame.size.height - _currentInputPanel.frame.size.height, _currentInputPanel.frame.size.width, _currentInputPanel.frame.size.height);
            
            [self _adjustCollectionViewForSize:_view.bounds.size keyboardHeight:_keyboardHeight inputContainerHeight:_currentInputPanel.frame.size.height duration:0.0 animationCurve:0];
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

- (void)_updateVisibleItemIndices:(TGModernCollectionCell *)additionalCell
{
    if (!_disableScrollProcessing) {
        if (_messageIdForVisibleHoleDirection != 0 && !_enableBelowHistoryRequests && _collectionView.contentOffset.y <= -_collectionView.contentInset.top + 10.0f) {
            _messageIdForVisibleHoleDirection = 0;
        }
    }
    
    NSMutableArray *sortedHoles = nil;
    NSMutableArray *currentMessageIds = nil;
    
    for (TGModernCollectionCell *cell in [_collectionView visibleCells])
    {
        TGMessageModernConversationItem *item = cell.boundItem;
        if (item != nil)
        {
            if (item->_message.hole != nil) {
                if (sortedHoles == nil) {
                    sortedHoles = [[NSMutableArray alloc] init];
                }
                TGVisibleMessageHoleDirection direction = TGVisibleMessageHoleDirectionEarlier;
                int32_t sortDistance = 0;
                if (_messageIdForVisibleHoleDirection != 0 && _messageIdForVisibleHoleDirection <= ABS(item->_message.mid)) {
                    direction = TGVisibleMessageHoleDirectionLater;
                } else {
                    direction = TGVisibleMessageHoleDirectionEarlier;
                }
                
                if (_messageIdForVisibleHoleDirection != 0) {
                    sortDistance = ABS(_messageIdForVisibleHoleDirection - ABS(item->_message.mid));
                } else {
                    sortDistance = INT32_MAX - ABS(item->_message.mid);
                }
                
                NSInteger index = -1;
                bool added = false;
                for (TGVisibleMessageHole *currentHole in sortedHoles) {
                    index++;

                    int32_t currentDistance = 0;
                    if (_messageIdForVisibleHoleDirection != 0) {
                        currentDistance = ABS(_messageIdForVisibleHoleDirection - currentHole.hole.maxId);
                    } else {
                        currentDistance = INT32_MAX - currentHole.hole.maxId;
                    }
                    
                    if (currentDistance > sortDistance) {
                        [sortedHoles insertObject:[[TGVisibleMessageHole alloc] initWithHole:item->_message.hole direction:direction] atIndex:index];
                        added = true;
                        break;
                    }
                }
                if (!added) {
                    [sortedHoles addObject:[[TGVisibleMessageHole alloc] initWithHole:item->_message.hole direction:direction]];
                }
            }
            
            if (item->_message.viewCount != 0 && item->_message.mid < TGMessageLocalMidBaseline) {
                if (currentMessageIds == nil) {
                    currentMessageIds = [[NSMutableArray alloc] init];
                }
                [currentMessageIds addObject:@(item->_message.mid)];
            }
        }
    }
    
    if (additionalCell != nil) {
        TGMessageModernConversationItem *item = additionalCell.boundItem;
        if (item != nil)
        {
            if (item->_message.hole != nil) {
                if (sortedHoles == nil) {
                    sortedHoles = [[NSMutableArray alloc] init];
                }
                TGVisibleMessageHoleDirection direction = TGVisibleMessageHoleDirectionEarlier;
                int32_t sortDistance = 0;
                if (_messageIdForVisibleHoleDirection != 0 && _messageIdForVisibleHoleDirection <= ABS(item->_message.mid)) {
                    direction = TGVisibleMessageHoleDirectionLater;
                } else {
                    direction = TGVisibleMessageHoleDirectionEarlier;
                }
                
                if (_messageIdForVisibleHoleDirection != 0) {
                    sortDistance = ABS(_messageIdForVisibleHoleDirection - ABS(item->_message.mid));
                } else {
                    sortDistance = INT32_MAX - ABS(item->_message.mid);
                }
                
                NSInteger index = -1;
                bool added = false;
                for (TGVisibleMessageHole *currentHole in sortedHoles) {
                    index++;
                    
                    int32_t currentDistance = 0;
                    if (_messageIdForVisibleHoleDirection != 0) {
                        currentDistance = ABS(_messageIdForVisibleHoleDirection - currentHole.hole.maxId);
                    } else {
                        currentDistance = INT32_MAX - currentHole.hole.maxId;
                    }
                    
                    if (currentDistance > sortDistance) {
                        [sortedHoles insertObject:[[TGVisibleMessageHole alloc] initWithHole:item->_message.hole direction:direction] atIndex:index];
                        added = true;
                        break;
                    }
                }
                if (!added) {
                    [sortedHoles addObject:[[TGVisibleMessageHole alloc] initWithHole:item->_message.hole direction:direction]];
                }
            }
            if (item->_message.viewCount != 0 && item->_message.mid < TGMessageLocalMidBaseline) {
                if (currentMessageIds == nil) {
                    currentMessageIds = [[NSMutableArray alloc] init];
                }
                [currentMessageIds addObject:@(item->_message.mid)];
            }
        }
    }
    
    [_companion _controllerDidUpdateVisibleHoles:sortedHoles];
    if (currentMessageIds != nil) {
        [_companion _controllerDidUpdateVisibleUnseenMessageIds:currentMessageIds];
    }
    
    if (_collectionView.contentSize.height > FLT_EPSILON && !_disableScrollProcessing)
    {
        if ((NSInteger)_items.count >= TGModernConversationControllerUnloadHistoryLimit + TGModernConversationControllerUnloadHistoryThreshold)
            [self _maybeUnloadHistory];
        
        if (_enableAboveHistoryRequests && _collectionView.contentOffset.y > _collectionView.contentSize.height - 800 * 2.0f && _collectionView.contentSize.height > FLT_EPSILON)
            [_companion loadMoreMessagesAbove];
        
        if (_enableBelowHistoryRequests && _collectionView.contentOffset.y < 600 * 2.0f)
            [_companion loadMoreMessagesBelow];
    }
}

- (void)collectionView:(UICollectionView *)__unused collectionView willDisplayCell:(UICollectionViewCell *)cell forItemAtIndexPath:(NSIndexPath *)__unused indexPath
{
    if (_temporaryHighlightMessageIdUponDisplay != 0)
    {
        TGMessageModernConversationItem *item = [(TGModernCollectionCell *)cell boundItem];
        if (item->_message.mid == _temporaryHighlightMessageIdUponDisplay)
        {
            _temporaryHighlightMessageIdUponDisplay = 0;
            [item setTemporaryHighlighted:true viewStorage:_viewStorage];
            TGDispatchAfter(0.6, dispatch_get_main_queue(), ^
            {
                [item setTemporaryHighlighted:false viewStorage:_viewStorage];
            });
        }
    }
    
    [self _updateVisibleItemIndices:(TGModernCollectionCell *)cell];
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
    
    [self _updateVisibleItemIndices:nil];
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

- (void)_checkScrollBackMessage
{
    if (_scrollBackMessageId != 0 && _canCheckScrollBackMessageId)
    {
        bool found = false;
        for (TGModernCollectionCell *cell in _collectionView.visibleCells)
        {
            TGMessageModernConversationItem *item = cell.boundItem;
            if (item != nil && item->_message.mid == _scrollBackMessageId)
            {
                found = true;
                [self setScrollBackMessageId:0];
                break;
            }
        }
        
        if (!found)
            [self setScrollBackButtonVisible:true];
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
        
        if (_scrollBackMessageId != 0)
            [self _checkScrollBackMessage];
        
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

- (void)scrollViewDidEndScrollingAnimation:(UIScrollView *)__unused scrollView
{
    _scrollingToBottom = nil;
    _canCheckScrollBackMessageId = true;
    [self _checkScrollBackMessage];
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

- (void)collectionViewPan:(UIPanGestureRecognizer *)__unused recognizer
{
}

#pragma mark -

- (NSArray *)_currentItems {
    return _items;
}

- (void)replaceItems:(NSArray *)newItems
{
    _messageIdForVisibleHoleDirection = 0;
    
    [_items removeAllObjects];
    [_items addObjectsFromArray:newItems];
    
    if (self.isViewLoaded)
    {
        [_collectionView reloadData];
    }
}

- (void)addScaleAnimation:(CALayer *)layer delay:(NSTimeInterval)delay {
    CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"transform.scale"];
    animation.fromValue = @(0.95f);
    animation.toValue = @(1.0f);
    animation.duration = 0.35 * TGAnimationSpeedFactor();
    animation.beginTime = CACurrentMediaTime() + delay;
    animation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut];
    animation.removedOnCompletion = true;
    animation.fillMode = kCAFillModeBoth;
    [layer addAnimation:animation forKey:@"transform.scale"];
}

- (void)addAlphaAnimation:(CALayer *)layer delay:(NSTimeInterval)delay {
    CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"opacity"];
    animation.fromValue = @(0.0f);
    animation.toValue = @(1.0f);
    animation.duration = 0.31 * TGAnimationSpeedFactor();
    animation.beginTime = CACurrentMediaTime() + delay;
    animation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut];
    animation.removedOnCompletion = true;
    animation.fillMode = kCAFillModeBoth;
    [layer addAnimation:animation forKey:@"opacity"];
}

- (void)addOffsetAnimation:(CALayer *)layer delay:(NSTimeInterval)delay offset:(CGFloat)offset {
    CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"position"];
    animation.fromValue = [NSValue valueWithCGPoint:CGPointMake(layer.position.x, layer.position.y + offset)];
    animation.toValue = [NSValue valueWithCGPoint:layer.position];
    animation.duration = 0.31 * TGAnimationSpeedFactor();
    animation.beginTime = CACurrentMediaTime() + delay;
    animation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut];
    animation.removedOnCompletion = true;
    animation.fillMode = kCAFillModeBoth;
    [layer addAnimation:animation forKey:@"position"];
}

- (TGMessage *)latestVisibleMessage {
    TGMessage *latestMessage = nil;
    for (TGModernCollectionCell *cell in _collectionView.visibleCells) {
        TGMessageModernConversationItem *item = cell.boundItem;
        if (item != nil) {
            if (latestMessage == nil || (int32_t)item->_message.date > (int32_t)latestMessage.date || ((int32_t)item->_message.date == (int32_t)latestMessage.date && ABS(item->_message.mid) > ABS(latestMessage.mid))) {
                latestMessage = item->_message;
            }
        }
    }
    return latestMessage;
}

- (NSArray *)visibleMessageIds {
    NSMutableArray *messageIds = [[NSMutableArray alloc] init];
    for (TGModernCollectionCell *cell in _collectionView.visibleCells) {
        TGMessageModernConversationItem *item = cell.boundItem;
        if (item != nil) {
            [messageIds addObject:@(item->_message.mid)];
        }
    }
    return messageIds;
}

- (void)replaceItems:(NSArray *)newItems positionAtMessageId:(int32_t)positionAtMessageId expandAt:(int32_t)__unused expandMessageId jump:(bool)jump {
    _messageIdForVisibleHoleDirection = positionAtMessageId;
    
    NSMutableDictionary *storedViewFrames = [[NSMutableDictionary alloc] init];
    NSMutableDictionary *storedDecorationViewFrames = [[NSMutableDictionary alloc] init];
    
    NSMutableDictionary *storedViews = [[NSMutableDictionary alloc] init];
    NSMutableDictionary *storedDecorationViews = [[NSMutableDictionary alloc] init];
    
    NSMutableArray *previousGroups = [[NSMutableArray alloc] init];
    
    int32_t minVisiblePreviousMid = INT32_MAX;
    int32_t maxVisiblePreviousMid = 0;
    
    for (TGModernCollectionCell *cell in [_collectionView visibleCells]) {
        TGMessageModernConversationItem *item = [cell boundItem];
        if (item != nil) {
            if (item->_message.group != nil) {
                [previousGroups addObject:item->_message.group];
            }
            storedViewFrames[@(item->_message.mid)] = [NSValue valueWithCGRect:[_view convertRect:cell.frame fromView:_collectionView]];
            storedViews[@(item->_message.mid)] = [cell snapshotViewAfterScreenUpdates:false];
            
            minVisiblePreviousMid = MIN(minVisiblePreviousMid, ABS(item->_message.mid));
            maxVisiblePreviousMid = MAX(maxVisiblePreviousMid, ABS(item->_message.mid));
        }
    }
    
    for (UIView *decorationView in [_collectionView visibleDecorations]) {
        if ([decorationView isKindOfClass:[TGModernDateHeaderView class]]) {
            TGModernDateHeaderView *dateHeader = (TGModernDateHeaderView *)decorationView;
            storedDecorationViewFrames[@(dateHeader.date)] = [NSValue valueWithCGRect:[_view convertRect:dateHeader.frame fromView:_collectionView]];
            storedDecorationViews[@(dateHeader.date)] = [dateHeader snapshotViewAfterScreenUpdates:false];
        }
    }
    
    NSMutableDictionary *previousItemsByMessageId = [[NSMutableDictionary alloc] init];
    for (TGMessageModernConversationItem *item in _items) {
        previousItemsByMessageId[@(item->_message.mid)] = item;
    }
    
    [_items removeAllObjects];
    [_items addObjectsFromArray:newItems];
    
    for (NSUInteger i = 0; i < _items.count; i++) {
        TGMessageModernConversationItem *currentItem = _items[i];
        TGMessageModernConversationItem *previousItem = previousItemsByMessageId[@(currentItem->_message.mid)];
        if (previousItem != nil) {
            [_items replaceObjectAtIndex:i withObject:previousItem];
        }
    }
    
    if (self.isViewLoaded) {
        _disableScrollProcessing = true;
        
        [self _beginReloadDataWithTemporaryContainer];
        
        NSInteger index = -1;
        CGFloat offsetDifference = 0.0f;
        for (TGMessageModernConversationItem *item in _items) {
            index++;
            if (item->_message.mid == positionAtMessageId) {
                UICollectionViewLayoutAttributes *layoutAttributes = [_collectionLayout layoutAttributesForItemAtIndexPath:[NSIndexPath indexPathForItem:index inSection:0]];
                NSValue *previousFrame = storedViewFrames[@(item->_message.mid)];
                if (layoutAttributes != nil && previousFrame != nil) {
                    CGRect updatedFrame = [_view convertRect:layoutAttributes.frame fromView:_collectionView];
                    offsetDifference = updatedFrame.origin.y - [previousFrame CGRectValue].origin.y;
                }
                break;
            }
        }
        
        CGFloat contentOffsetY = _collectionView.contentOffset.y - offsetDifference;
        
        if (expandMessageId != 0) {
            TGMessageGroup *expandGroup = nil;
            for (TGMessageGroup *group in previousGroups) {
                if (ABS(expandMessageId) >= group.minId && ABS(expandMessageId) <= group.maxId) {
                    expandGroup = group;
                    break;
                }
            }
            
            if (expandGroup != nil) {
                CGFloat lastItemOffsetY = 0.0;
                for (TGMessageModernConversationItem *item in _items) {
                    if (item->_message.mid <= expandGroup.maxId) {
                        lastItemOffsetY = [self contentOffsetForMessageId:item->_message.mid scrollPosition:TGInitialScrollPositionBottom initial:true additionalOffset:0.0f];
                        break;
                    }
                }
                
                if (contentOffsetY > lastItemOffsetY) {
                    for (TGMessageModernConversationItem *item in _items.reverseObjectEnumerator) {
                        if (item->_message.mid >= expandGroup.minId) {
                            contentOffsetY = MIN(contentOffsetY, [self contentOffsetForMessageId:item->_message.mid scrollPosition:TGInitialScrollPositionTop initial:true additionalOffset:100.0f]);
                            break;
                        }
                    }
                }
            }
        }
        
        if (jump) {
            contentOffsetY = [self contentOffsetForMessageId:positionAtMessageId scrollPosition:TGInitialScrollPositionCenter initial:true additionalOffset:0.0f];
        }
        
        if (contentOffsetY > _collectionLayout.collectionViewContentSize.height + _collectionView.contentInset.bottom - _collectionView.frame.size.height) {
            contentOffsetY = _collectionLayout.collectionViewContentSize.height + _collectionView.contentInset.bottom - _collectionView.frame.size.height;
        }
        if (contentOffsetY < -_collectionView.contentInset.top) {
            contentOffsetY = -_collectionView.contentInset.top;
        }
        
        [_collectionView setContentOffset:CGPointMake(0.0f, contentOffsetY) animated:false];
        
        [_collectionView setNeedsLayout];
        [_collectionView layoutSubviews];
        [self _endReloadDataWithTemporaryContainer];
        _disableScrollProcessing = false;
        
        NSMutableArray *visibleMids = [[NSMutableArray alloc] init];
        
        CGFloat minY = 0.0;
        CGFloat maxY = 0.0;
        int32_t minVisibleMid = INT32_MAX;
        int32_t maxVisibleMid = 0;
        
        NSMutableArray *currentGroups = [[NSMutableArray alloc] init];
        
        for (TGModernCollectionCell *cell in [_collectionView visibleCells]) {
            TGMessageModernConversationItem *item = [cell boundItem];
            if (item != nil) {
                if (ABS(minY) < FLT_EPSILON || cell.frame.origin.y < minY) {
                    minY = cell.frame.origin.y;
                }
                if (ABS(maxY) < FLT_EPSILON || CGRectGetMaxY(cell.frame) > maxY) {
                    maxY = CGRectGetMaxY(cell.frame);
                }
                int32_t mid = item->_message.mid;
                minVisibleMid = MIN(minVisibleMid, ABS(mid));
                maxVisibleMid = MAX(maxVisibleMid, ABS(mid));
                if (item->_message.group != nil) {
                    [currentGroups addObject:item->_message.group];
                }
            }
        }
        
        for (TGModernCollectionCell *cell in [_collectionView visibleCells]) {
            TGMessageModernConversationItem *item = [cell boundItem];
            if (item != nil) {
                [visibleMids addObject:@(item->_message.mid)];
                
                NSValue *previousFrame = nil;
                
                int32_t mid = item->_message.mid;
                TGMessageGroup *group = nil;
                for (TGMessageGroup *currentGroup in previousGroups) {
                    if (mid >= currentGroup.minId && mid <= currentGroup.maxId) {
                        group = currentGroup;
                    }
                }
                
                bool grouped = false;
                if (group != nil && storedViewFrames[@(-group.maxId)] != nil) {
                    previousFrame = storedViewFrames[@(-group.maxId)];
                    grouped = true;
                } else {
                    previousFrame = storedViewFrames[@(item->_message.mid)];
                }
                
                if (previousFrame == nil && item->_message.group != nil) {
                    int32_t minId = item->_message.group.minId;
                    int32_t maxId = item->_message.group.maxId;
                    __block int32_t selectedId = 0;
                    __block NSValue *resultFrame = nil;
                    [storedViewFrames enumerateKeysAndObjectsUsingBlock:^(NSNumber *nMid, NSValue *nFrame, __unused BOOL *stop) {
                        int32_t mid = [nMid intValue];
                        if (mid >= minId && mid <= maxId) {
                            if (selectedId == 0 || mid > selectedId) {
                                selectedId = mid;
                                resultFrame = nFrame;
                            }
                        }
                    }];
                    previousFrame = resultFrame;
                }
                
                CGRect frame = cell.frame;
                if (previousFrame != nil) {
                    CGRect updatedFrame = [_view convertRect:[previousFrame CGRectValue] toView:_collectionView];
                    
                    if (!grouped) {
                        updatedFrame.size = frame.size;
                        cell.frame = updatedFrame;
                        
                        [UIView animateWithDuration:0.25 delay:0.0 options:7 << 16 animations:^{
                            cell.frame = frame;
                        } completion:nil];
                        if (item->_message.group != nil) {
                            [self addAlphaAnimation:cell.layer delay:0.0];
                        }
                    } else {
                        CGFloat distance = ABS(updatedFrame.origin.y - frame.origin.y) / _collectionView.frame.size.height;
                        NSTimeInterval delay = MIN(distance / 1.5f, 0.25);
                        [self addAlphaAnimation:cell.layer delay:delay];
                        [self addScaleAnimation:cell.layer delay:delay];
                        
                        if (ABS(updatedFrame.origin.y - frame.origin.y) > 5.0f) {
                            if (updatedFrame.origin.y < frame.origin.y) {
                                [self addOffsetAnimation:cell.layer delay:delay * 0.7 offset:-8.0f];
                            } else {
                                [self addOffsetAnimation:cell.layer delay:delay * 0.7 offset:8.0f];
                            }
                        }
                    }
                } else {
                    CGRect offsetFrame = cell.frame;
                    if (ABS(mid) < minVisiblePreviousMid) {
                        offsetFrame.origin.y = maxY + 1000.0f;
                    } else if (ABS(mid) > maxVisiblePreviousMid) {
                        offsetFrame.origin.y = minY - 1000.0f;
                    }
                    
                    cell.frame = offsetFrame;
                    
                    [UIView animateWithDuration:0.25 delay:0.0 options:7 << 16 animations:^{
                        cell.frame = frame;
                    } completion:nil];
                    
                    [self addAlphaAnimation:cell.layer delay:0.0];
                }
            }
        }
        
        [storedViews removeObjectsForKeys:visibleMids];
        [storedViews enumerateKeysAndObjectsUsingBlock:^(NSNumber *nMid, UIView *cell, __unused BOOL *stop) {
            NSValue *previousFrame = nil;
            int32_t mid = [nMid intValue];
            TGMessageGroup *group = nil;
            for (TGMessageGroup *currentGroup in currentGroups) {
                if (mid >= currentGroup.minId && mid <= currentGroup.maxId) {
                    group = currentGroup;
                }
            }
            previousFrame = storedViewFrames[@(mid)];
            
            if (previousFrame != nil) {
                CGRect updatedFrame = [_view convertRect:[previousFrame CGRectValue] toView:_collectionView];
                
                cell.frame = updatedFrame;
                [_collectionView insertSubview:cell atIndex:0];
                
                CGRect offsetFrame = updatedFrame;
                if (mid > 0 && group == nil) {
                    if (ABS(mid) < minVisibleMid) {
                        offsetFrame.origin.y = maxY + 1000.0f;
                    } else {
                        offsetFrame.origin.y = minY - 1000.0f;
                    }
                }
                
                [UIView animateWithDuration:0.2 delay:0.0 options:UIViewAnimationOptionCurveEaseOut animations:^{
                    cell.alpha = 0.0f;
                    cell.frame = offsetFrame;
                } completion:^(__unused BOOL finished){
                    [cell removeFromSuperview];
                }];
            }
        }];
        
        NSMutableArray *visibleDecorationViewIds = [[NSMutableArray alloc] init];
        for (UIView *decorationView in [_collectionView visibleDecorations]) {
            if ([decorationView isKindOfClass:[TGModernDateHeaderView class]]) {
                TGModernDateHeaderView *dateView = (TGModernDateHeaderView *)decorationView;
                NSValue *previousFrame = storedDecorationViewFrames[@(dateView.date)];
                CGRect frame = dateView.frame;
                if (previousFrame != nil) {
                    CGRect updatedFrame = [_view convertRect:[previousFrame CGRectValue] toView:_collectionView];
                    
                    updatedFrame.size = frame.size;
                    dateView.frame = updatedFrame;
                    
                    [UIView animateWithDuration:0.25 delay:0.0 options:7 << 16 animations:^{
                        dateView.frame = frame;
                    } completion:nil];
                }
            }
        }
        
        [storedDecorationViews removeObjectsForKeys:visibleDecorationViewIds];
        
        [self _updateVisibleItemIndices:nil];
    }
}

- (void)replaceItemsWithFastScroll:(NSArray *)newItems intent:(TGModernConversationInsertItemIntent)intent scrollToMessageId:(int32_t)scrollToMessageId scrollBackMessageId:(int32_t)scrollBackMessageId animated:(bool)animated
{
    bool scrollDown = true;
    if (scrollToMessageId != 0)
    {
        bool allMessagesAreBelow = true;
        for (TGMessageModernConversationItem *item in _items)
        {
            if (item->_message.mid > scrollToMessageId)
            {
                allMessagesAreBelow = false;
                break;
            }
        }
        scrollDown = allMessagesAreBelow;
    }
    
    NSMutableArray *storedCells = [[NSMutableArray alloc] init];
    for (TGModernCollectionCell *cell in _collectionView.visibleCells)
    {
        if (cell.boundItem != nil)
        {
            TGModernCollectionCell *cellCopy = [[TGModernCollectionCell alloc] initWithFrame:[_collectionView convertRect:cell.frame toView:_view]];
            [(TGMessageModernConversationItem *)cell.boundItem moveToCell:cellCopy];
            [storedCells addObject:cellCopy];
        }
    }
    
    if (animated)
        _temporaryHighlightMessageIdUponDisplay = scrollToMessageId;
    
    [_items removeAllObjects];
    [_collectionView reloadData];
    
    if (storedCells.count != 0)
    {
        if (intent == TGModernConversationInsertItemIntentSendTextMessage)
        {
            _inputTextPanel.maybeInputField.oneTimeLongAnimation = true;
            [_inputTextPanel setPrimaryExtendedPanel:nil animated:true skipHeightAnimation:_inputTextPanel.maybeInputField.text.length != 0];
            [_inputTextPanel setSecondaryExtendedPanel:nil animated:true skipHeightAnimation:_inputTextPanel.maybeInputField.text.length != 0];
            [_inputTextPanel.maybeInputField setText:@"" animated:true];
        }
        else if (intent == TGModernConversationInsertItemIntentSendOtherMessage)
        {
            if ([self currentReplyMessageId] != 0)
            {
                [_inputTextPanel setPrimaryExtendedPanel:nil animated:true skipHeightAnimation:false];
                [_inputTextPanel setSecondaryExtendedPanel:nil animated:true skipHeightAnimation:false];
            }
        }
        
        [_items addObjectsFromArray:newItems];
        
        [_collectionView reloadData];
        if (scrollToMessageId)
        {
            TGMessageModernConversationItem *selectedItem = nil;
            for (TGMessageModernConversationItem *messageItem in _items)
            {
                if (messageItem->_message.mid == scrollToMessageId)
                {
                    selectedItem = messageItem;
                    break;
                }
            }

            if (selectedItem != nil)
            {
                _scrollingToBottom = @false;
                [_collectionView setContentOffset:CGPointMake(0.0f, [self contentOffsetForMessageId:scrollToMessageId scrollPosition:TGInitialScrollPositionCenter initial:false additionalOffset:0.0f]) animated:false];
            }
            else
            {
                if (_collectionView.contentOffset.y > -_collectionView.contentInset.top)
                {
                    [_collectionView setContentOffset:CGPointMake(0.0f, -_collectionView.contentInset.top) animated:true];
                    _scrollingToBottom = @true;
                }
            }
        }
        else
        {
            _scrollingToBottom = nil;
            [_collectionView setContentOffset:CGPointMake(0.0f, -_collectionView.contentInset.top) animated:false];
        }
        
        NSMutableArray *currentCellsWithFrames = [[NSMutableArray alloc] init];
        CGFloat minStoredCellY = CGFLOAT_MAX;
        CGFloat maxStoredCellY = CGFLOAT_MIN;
        for (TGModernCollectionCell *cell in storedCells)
        {
            cell.frame = [_collectionView convertRect:cell.frame fromView:_view];
            minStoredCellY = MIN(minStoredCellY, cell.frame.origin.y);
            maxStoredCellY = MAX(maxStoredCellY, CGRectGetMaxY(cell.frame));
            [_collectionView addSubview:cell];
        }
        
        [_collectionView layoutSubviews];

        CGFloat maxCurrentCellY = CGFLOAT_MIN;
        CGFloat minCurrentCellY = CGFLOAT_MAX;
        for (TGModernCollectionCell *cell in _collectionView.visibleCells)
        {
            maxCurrentCellY = MAX(maxCurrentCellY, CGRectGetMaxY(cell.frame));
            minCurrentCellY = MIN(minCurrentCellY, cell.frame.origin.y);
        }
        
        CGFloat offsetDifference = 0.0f;
        if (scrollDown)
            offsetDifference = minStoredCellY - maxCurrentCellY;
        else
            offsetDifference = maxStoredCellY - minCurrentCellY;
        
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
        
        [UIView animateWithDuration:animated ? 0.3 : 0.0 delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^
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
        {
            [_inputTextPanel setPrimaryExtendedPanel:nil animated:true skipHeightAnimation:false];
            [_inputTextPanel setSecondaryExtendedPanel:nil animated:true skipHeightAnimation:false];
            [_inputTextPanel.maybeInputField setText:@"" animated:false];
        }
        else if (intent == TGModernConversationInsertItemIntentSendOtherMessage)
        {
            if ([self currentReplyMessageId] != 0)
            {
                [_inputTextPanel setPrimaryExtendedPanel:nil animated:true skipHeightAnimation:false];
                [_inputTextPanel setSecondaryExtendedPanel:nil animated:true skipHeightAnimation:false];
            }
        }
        
        _scrollingToBottom = nil;
        [_collectionView setContentOffset:CGPointMake(0.0f, -_collectionView.contentInset.top) animated:false];
    }
    
    [self setScrollBackMessageId:scrollBackMessageId];
    if (scrollBackMessageId != 0)
        [self setScrollBackButtonVisible:true];
    
    [self _updateVisibleItemIndices:nil];
}

- (void)replaceItems:(NSArray *)items atIndices:(NSIndexSet *)indices
{
    [_items replaceObjectsAtIndexes:indices withObjects:items];
    [_collectionView reloadData];
    [self _updateVisibleItemIndices:nil];
}

- (void)deleteItemsAtIndices:(NSIndexSet *)indexSet animated:(bool)animated
{
    [self _deleteItemsAtIndices:indexSet animated:animated animationFactor:0.7f];
}

- (void)_deleteItemsAtIndices:(NSIndexSet *)indexSet animated:(bool)animated animationFactor:(CGFloat)animationFactor
{
    NSMutableIndexSet *indexSetAnimated = [[NSMutableIndexSet alloc] initWithIndexSet:indexSet];
    
    if (true)
    {
        CGFloat referenceContentOffset = _collectionView.contentOffset.y;
        CGFloat referenceContentBoundsOffset = referenceContentOffset + _collectionView.bounds.size.height;
        
        NSUInteger lastVisibleOfCurrentIndices = NSNotFound;
        NSUInteger farthestVisibleOfCurrentIndices = NSNotFound;
        
        int currentItemCount = (int)_items.count;
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
                [TGHacks setSecondaryAnimationDurationFactor:(float)animationFactor];
            else
                [TGHacks setAnimationDurationFactor:(float)animationFactor];
            
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
                } completion:nil beforeDecorations:nil animated:true animationFactor:(float)animationFactor];
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
    
    [self _updateVisibleItemIndices:nil];
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
    
    int index = (int)movingItems.count;
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
    [self insertItems:itemsArray atIndices:indexSet animated:animated intent:intent removeAtIndices:nil];
}

- (void)insertItems:(NSArray *)itemsArray atIndices:(NSIndexSet *)indexSet animated:(bool)animated intent:(TGModernConversationInsertItemIntent)intent removeAtIndices:(NSIndexSet *)removeIndexSet
{
    if (removeIndexSet.count != 0) {
        [self _deleteItemsAtIndices:removeIndexSet animated:animated animationFactor:0.7f];
    }
    
    bool scrollToBottom = [_scrollingToBottom boolValue];
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
            if (intent == TGModernConversationInsertItemIntentLoadMoreMessagesBelow) {
                _collectionView.contentOffset = CGPointMake(0.0f, _collectionView.contentOffset.y + (currentContentHeight - previousContentHeight));
            } else {
                _collectionView.contentOffset = CGPointMake(0.0f, _collectionView.contentOffset.y + (currentContentHeight - previousContentHeight));
            }
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
                            [_inputTextPanel setPrimaryExtendedPanel:nil animated:true skipHeightAnimation:_inputTextPanel.maybeInputField.text.length != 0];
                            [_inputTextPanel setSecondaryExtendedPanel:nil animated:true skipHeightAnimation:_inputTextPanel.maybeInputField.text.length != 0];
                            [_inputTextPanel.maybeInputField setText:@""];
                        }
                        else if (intent == TGModernConversationInsertItemIntentSendOtherMessage)
                        {
                            if ([self currentReplyMessageId] != 0)
                            {
                                [_inputTextPanel setPrimaryExtendedPanel:nil animated:true skipHeightAnimation:false];
                                [_inputTextPanel setSecondaryExtendedPanel:nil animated:true skipHeightAnimation:false];
                            }
                        }
                        
                        if (_collectionView.contentOffset.y > -_collectionView.contentInset.top)
                        {
                            [_collectionView setContentOffset:CGPointMake(0.0f, -_collectionView.contentInset.top) animated:true];
                            _scrollingToBottom = @true;
                        }
                        
                        //[_collectionView scrollRectToVisible:CGRectMake(0.0f, 0.0f, 1.0f, 1.0f) animated:true];
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
            if (intent == TGModernConversationInsertItemIntentLoadMoreMessagesBelow) {
                
            }
            [_collectionView updateRelativeBounds];
            
            if (intent == TGModernConversationInsertItemIntentSendTextMessage || intent == TGModernConversationInsertItemIntentSendOtherMessage)
            {
                if (intent == TGModernConversationInsertItemIntentSendTextMessage)
                {
                    _inputTextPanel.maybeInputField.oneTimeLongAnimation = true;
                    [_inputTextPanel setPrimaryExtendedPanel:nil animated:true skipHeightAnimation:_inputTextPanel.maybeInputField.text.length != 0];
                    [_inputTextPanel setSecondaryExtendedPanel:nil animated:true skipHeightAnimation:_inputTextPanel.maybeInputField.text.length != 0];
                    [_inputTextPanel.maybeInputField setText:@"" animated:true];
                }
                else if (intent == TGModernConversationInsertItemIntentSendOtherMessage)
                {
                    if ([self currentReplyMessageId] != 0)
                    {
                        [_inputTextPanel setPrimaryExtendedPanel:nil animated:true skipHeightAnimation:false];
                        [_inputTextPanel setSecondaryExtendedPanel:nil animated:true skipHeightAnimation:false];
                    }
                }
                
                [_collectionView scrollRectToVisible:CGRectMake(0.0f, 0.0f, 1.0f, 1.0f) animated:true];
            }
        }
    }
    else if (intent == TGModernConversationInsertItemIntentSendTextMessage || intent == TGModernConversationInsertItemIntentSendOtherMessage)
    {
        if (intent == TGModernConversationInsertItemIntentSendTextMessage)
        {
            [_inputTextPanel setPrimaryExtendedPanel:nil animated:true skipHeightAnimation:false];
            [_inputTextPanel setSecondaryExtendedPanel:nil animated:true skipHeightAnimation:false];
            [_inputTextPanel.maybeInputField setText:@"" animated:false];
        }
        else if (intent == TGModernConversationInsertItemIntentSendOtherMessage)
        {
            if ([self currentReplyMessageId] != 0)
            {
                [_inputTextPanel setPrimaryExtendedPanel:nil animated:true skipHeightAnimation:false];
                [_inputTextPanel setSecondaryExtendedPanel:nil animated:true skipHeightAnimation:false];
            }
        }
        
        if (_collectionView.contentOffset.y > -_collectionView.contentInset.top)
        {
            [_collectionView setContentOffset:CGPointMake(0.0f, -_collectionView.contentInset.top) animated:true];
            _scrollingToBottom = @true;
        }
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
    
    if (scrollToBottom)
    {
        if (_collectionView.contentOffset.y > -_collectionView.contentInset.top)
        {
            [_collectionView setContentOffset:CGPointMake(0.0f, -_collectionView.contentInset.top) animated:true];
            _scrollingToBottom = @true;
        }
    }
    
    if ([self currentReplyMessageId] == 0 && intent == TGModernConversationInsertItemIntentGeneric)
    {
        for (TGMessageModernConversationItem *item in itemsArray)
        {
            if (item->_message.forceReply)
            {
                [self setReplyMessage:item->_message animated:true];
                break;
            }
        }
    }
    
    [self _updateVisibleItemIndices:nil];
}

- (void)updateItemAtIndex:(NSUInteger)index toItem:(TGModernConversationItem *)updatedItem
{
    CGFloat containerWidth = _collectionView == nil ? _view.frame.size.width : _collectionView.frame.size.width;
    
    bool sizeChanged = false;
    CGSize lastSize = [(TGMessageModernConversationItem *)_items[index] sizeForContainerSize:CGSizeMake(containerWidth, CGFLOAT_MAX)];
    [_items[index] updateToItem:updatedItem viewStorage:_viewStorage sizeChanged:&sizeChanged];
    CGSize updatedSize = lastSize;
    if (sizeChanged)
    {
        updatedSize = [(TGMessageModernConversationItem *)_items[index] sizeForContainerSize:CGSizeMake(containerWidth, CGFLOAT_MAX)];
    }
    
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
    
    if (sizeChanged && ABS(lastSize.height - updatedSize.height) != 0)
    {
        if (_collectionView.isDecelerating)
        {
            [_collectionLayout invalidateLayout];
            [_collectionView layoutSubviews];
        }
        else
        {
            std::vector<TGDecorationViewAttrubutes> decorationAttributes;
            NSArray *layoutAttributes = [_collectionLayout layoutAttributesForItems:_items containerWidth:containerWidth maxHeight:FLT_MAX decorationViewAttributes:&decorationAttributes contentHeight:NULL];
            
            [UIView animateWithDuration:0.25 delay:0 options:UIViewAnimationOptionBeginFromCurrentState animations:^
            {
                for (NSIndexPath *indexPath in _collectionView.indexPathsForVisibleItems)
                {
                    TGModernCollectionCell *cell = (TGModernCollectionCell *)[_collectionView cellForItemAtIndexPath:indexPath];
                    TGMessageModernConversationItem *cellItem = cell.boundItem;
                    if (cellItem != nil)
                    {
                        UICollectionViewLayoutAttributes *attributes = layoutAttributes[indexPath.row];
                        cell.frame = attributes.frame;
                    }
                }
            } completion:^(BOOL finished)
            {
                if (finished)
                    [_collectionLayout invalidateLayout];
            }];
            
            [_collectionView updateRelativeBounds];
        }
    }
}

- (void)updateItemProgressAtIndex:(NSUInteger)index toProgress:(CGFloat)progress animated:(bool)animated
{
    if (index > _items.count)
        return;
    
    [_items[index] updateProgress:(float)progress viewStorage:_viewStorage animated:animated];
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
    
    _hasUnseenMessagesBelow = hasUnseenMessagesBelow;
    
    [self setScrollBackButtonVisible:_hasUnseenMessagesBelow || _scrollBackMessageId != 0];
}

- (void)setUnreadMessageRangeIfAppropriate:(TGMessageRange)unreadMessageRange
{
    if (!TGMessageRangeEquals(_collectionView.unreadMessageRange, unreadMessageRange))
    {   
        _collectionView.unreadMessageRange = unreadMessageRange;
        [_collectionView reloadData];
        [_collectionView layoutSubviews];
        
        int32_t minMessageId = INT32_MAX;
        for (TGMessageModernConversationItem *item in _items)
        {
            if (item->_message.mid >= unreadMessageRange.firstMessageId)
            {
                if (item->_message.mid < minMessageId || minMessageId == INT32_MIN)
                {
                    minMessageId = item->_message.mid;
                }
            }
        }
        
        if (minMessageId != INT32_MAX)
        {
            CGFloat contentOffset = [self contentOffsetForMessageId:minMessageId scrollPosition:TGInitialScrollPositionTop initial:false additionalOffset:0.0f];
            [_collectionView setContentOffset:CGPointMake(0.0f, contentOffset) animated:false];
        }
    }
}

- (void)setScrollBackMessageId:(int32_t)scrollBackMessageId
{
    if (!self.isViewLoaded)
        return;
    
    _scrollBackMessageId = scrollBackMessageId;
}

- (void)setScrollBackButtonVisible:(bool)scrollBackButtonVisible
{
    if (scrollBackButtonVisible)
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
            [_view insertSubview:_unseenMessagesButton aboveSubview:_collectionView];
            [self _updateUnseenMessagesButton];
        }
    }
    else if (_unseenMessagesButton != nil)
    {
        [_unseenMessagesButton removeFromSuperview];
    }
}

- (void)_updateUnseenMessagesButton
{
    if (_unseenMessagesButton.superview != nil)
    {
        CGSize collectionViewSize = _view.bounds.size;
        
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
        [editingPanel setDeleteEnabled:[self canDeleteSelectedMessages]];
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
    
    _disableItemBinding = true;
    [_collectionView reloadData];
}

- (void)_endReloadDataWithTemporaryContainer
{
    [_collectionView updateVisibleItemsNow];
    [_collectionView layoutIfNeeded];
    _disableItemBinding = false;
    
    for (NSIndexPath *indexPath in _collectionView.indexPathsForVisibleItems)
    {
        TGModernCollectionCell *cell = (TGModernCollectionCell *)[_collectionView cellForItemAtIndexPath:indexPath];
        if (cell.boundItem == nil && indexPath.row < (NSInteger)_items.count)
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
    bool sizeChanged = false;
    for (NSNumber *nIndex in indices)
    {
        index++;
        [(TGModernConversationItem *)_items[[nIndex intValue]] updateToItem:updatedItems[index] viewStorage:_viewStorage sizeChanged:&sizeChanged];
    }
}

- (void)scrollToMessage:(int32_t)messageId sourceMessageId:(int32_t)sourceMessageId animated:(bool)animated
{
    TGMessageModernConversationItem *selectedItem = nil;
    for (TGMessageModernConversationItem *messageItem in _items)
    {
        if (messageItem->_message.mid == messageId)
        {
            selectedItem = messageItem;
            break;
        }
    }
    
    if (selectedItem != nil)
    {
        bool foundCell = false;
        for (TGModernCollectionCell *cell in _collectionView.visibleCells)
        {
            if (((TGMessageModernConversationItem *)cell.boundItem)->_message.mid == messageId)
            {
                foundCell = true;
                break;
            }
        }
        
        if (animated)
        {
            if (foundCell)
            {
                [selectedItem setTemporaryHighlighted:true viewStorage:_viewStorage];
                TGDispatchAfter(0.6, dispatch_get_main_queue(), ^
                {
                    [selectedItem setTemporaryHighlighted:false viewStorage:_viewStorage];
                });
            }
            else
                _temporaryHighlightMessageIdUponDisplay = messageId;
        }
        
        CGFloat contentOffset = [self contentOffsetForMessageId:messageId scrollPosition:TGInitialScrollPositionCenter initial:false additionalOffset:0.0f];
        if (ABS(contentOffset - _collectionView.contentOffset.y) > FLT_EPSILON)
        {
            _canCheckScrollBackMessageId = false;
            [self setScrollBackMessageId:sourceMessageId];
            
            [_collectionView setContentOffset:CGPointMake(0.0f, contentOffset) animated:animated];
        }
        else
        {
            [self setScrollBackMessageId:0];
            [self setScrollBackButtonVisible:false];
        }
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
        TGUser *author = nil;
        
        if (mediaMessageItem->_message.fromUid == 0) {
            author = [[TGUser alloc] init];
            author.uid = 0;
            author.firstName = _titleView.title;
        } else if (!TGPeerIdIsChannel(mediaMessageItem->_message.fromUid)) {
            author = [TGDatabaseInstance() loadUser:mediaMessageItem->_message.outgoing ? TGTelegraphInstance.clientUserId : (int32_t)mediaMessageItem->_message.fromUid];
        } else {
            author = [[TGUser alloc] init];
            author.uid = 0;
            author.firstName = _titleView.title;
        }
        
        if (author == nil)
            return;
        
        bool isGallery = false;
        bool isAvatar = false;
        TGImageInfo *avatarImageInfo = nil;
        TGWebPageMediaAttachment *webPage = nil;
        int32_t webPageMessageId = 0;
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
                case TGWebPageMediaAttachmentType:
                {
                    webPage = ((TGWebPageMediaAttachment *)attachment);
                    foundMedia = true;
                    webPageMessageId = mediaMessageItem->_message.mid;
                    
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
                    int64_t peerId = mediaMessageItem->_message.fromUid;
                    if (mediaMessageItem->_message.forwardPeerId != 0) {
                        peerId = mediaMessageItem->_message.forwardPeerId;
                    }
                    
                    TGLocationMediaAttachment *mapAttachment = (TGLocationMediaAttachment *)attachment;
                    
                    __weak TGModernConversationController *weakSelf = self;
                    
                    id peer = nil;
                    
                    if (TGPeerIdIsChannel(peerId)) {
                        peer = [TGDatabaseInstance() loadChannels:@[@(peerId)]][@(peerId)];
                    } else {
                        peer = [TGDatabaseInstance() loadUser:(int32_t)peerId];
                    }
                    
                    TGLocationViewController *controller = [[TGLocationViewController alloc] initWithCoordinate:CLLocationCoordinate2DMake(mapAttachment.latitude, mapAttachment.longitude) venue:mapAttachment.venue peer:peer];
                    controller.calloutPressed = ^
                    {
                        __strong TGModernConversationController *strongSelf = weakSelf;
                        if (strongSelf != nil) {
                            if ([peer isKindOfClass:[TGConversation class]]) {
                                __strong TGModernConversationController *strongSelf = weakSelf;
                                if (strongSelf != nil) {
                                    [strongSelf.navigationController popViewControllerAnimated:true];
                                }
                            } else if ([peer isKindOfClass:[TGUser class]]) {
                                [[TGInterfaceManager instance] navigateToProfileOfUser:((TGUser *)peer).uid];
                            }
                        }
                    };
                    if ([_companion allowMessageForwarding])
                    {
                        controller.forwardPressed = ^
                        {
                            __strong TGModernConversationController *strongSelf = weakSelf;
                            if (strongSelf != nil)
                                [strongSelf.companion controllerWantsToForwardMessages:@[@(mediaMessageItem->_message.mid)]];
                        };
                    }
                                        
                    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone)
                    {
                        [self.navigationController pushViewController:controller animated:true];
                    }
                    else
                    {
                        TGNavigationController *navigationController = [TGNavigationController navigationControllerWithControllers:@[controller]];
                        navigationController.presentationStyle = TGNavigationControllerPresentationStyleInFormSheet;
                        navigationController.modalPresentationStyle = UIModalPresentationFormSheet;
                        [self presentViewController:navigationController animated:true completion:nil];
                    }
                    
                    break;
                }
                case TGDocumentMediaAttachmentType:
                {
                    TGDocumentMediaAttachment *documentAttachment = (TGDocumentMediaAttachment *)attachment;
                    
                    /*if ([documentAttachment.mimeType isEqualToString:@"audio/mpeg"])
                    {
                        if (_currentAudioPlayerMessageId != messageId)
                            [self playAudioFromMessage:messageId media:documentAttachment];
                        else
                            [_currentAudioPlayer play];
                        
                        break;
                    }*/
                    
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
                                        TGAlertView *alertView = [[TGAlertView alloc] initWithTitle:nil message:[[NSString alloc] initWithFormat:@"Localization file is valid, but the following keys are missing: %@", missingKeysString] delegate:nil cancelButtonTitle:TGLocalized(@"Common.OK") otherButtonTitles:nil];
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
                                    
                                    TGAlertView *alertView = [[TGAlertView alloc] initWithTitle:nil message:[[NSString alloc] initWithFormat:@"Invalid localization file: %@", reasonString] delegate:nil cancelButtonTitle:TGLocalized(@"Common.OK") otherButtonTitles:nil];
                                    [alertView show];
                                }
                            }
                            else if ([action isEqualToString:@"open"])
                            {
                                TGDocumentController *documentController = [[TGDocumentController alloc] initWithURL:[controller.companion fileUrlForDocumentMedia:documentAttachment] messageId:mediaMessageItem->_message.mid];
                                
                                if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone)
                                    [controller.navigationController pushViewController:documentController animated:true];
                                else
                                {
                                    if (iosMajorVersion() >= 8)
                                    {
                                        documentController.modalPresentationStyle = UIModalPresentationFormSheet;
                                        [controller presentViewController:documentController animated:false completion:nil];
                                    }
                                    else
                                    {
                                        TGNavigationController *navigationController = [TGNavigationController navigationControllerWithControllers:@[documentController]];
                                        navigationController.presentationStyle = TGNavigationControllerPresentationStyleInFormSheet;
                                        navigationController.modalPresentationStyle = UIModalPresentationFormSheet;
                                        [controller presentViewController:navigationController animated:true completion:nil];
                                    }
                                }
                                
                                [controller.companion updateMediaAccessTimeForMessageId:messageId];
                            }
                        } target:self] showInView:_view];
                        
                        break;
                    }
                    
                    TGDocumentController *documentController = [[TGDocumentController alloc] initWithURL:[_companion fileUrlForDocumentMedia:documentAttachment] messageId:mediaMessageItem->_message.mid];
                    
                    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone)
                        [self.navigationController pushViewController:documentController animated:true];
                    else
                    {
                        if (iosMajorVersion() >= 8)
                        {
                            documentController.modalPresentationStyle = UIModalPresentationFormSheet;
                            [self presentViewController:documentController animated:false completion:nil];
                        }
                        else
                        {
                            TGNavigationController *navigationController = [TGNavigationController navigationControllerWithControllers:@[documentController]];
                            navigationController.presentationStyle = TGNavigationControllerPresentationStyleInFormSheet;
                            navigationController.modalPresentationStyle = UIModalPresentationFormSheet;
                            [self presentViewController:navigationController animated:true completion:nil];
                        }
                    }
                    
                    [_companion updateMediaAccessTimeForMessageId:messageId];
                    
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
        
        if (webPage != nil)
        {
            modernGallery.model = [[TGExternalGalleryModel alloc] initWithWebPage:webPage];
        }
        else if (isGallery)
        {
            if (mediaMessageItem->_message.messageLifetime > 0 && mediaMessageItem->_message.messageLifetime <= 60 && mediaMessageItem->_message.layer >= 17)
            {
                modernGallery.model = [[TGSecretPeerMediaGalleryModel alloc] initWithPeerId:((TGGenericModernConversationCompanion *)_companion).conversationId messageId:mediaMessageItem->_message.mid];
            }
            else if (!_companion.allowMessageForwarding)
            {
                modernGallery.model = [[TGSecretInfiniteLifetimePeerMediaGalleryModel alloc] initWithPeerId:((TGGenericModernConversationCompanion *)_companion).conversationId atMessageId:mediaMessageItem->_message.mid allowActions:_companion.allowMessageForwarding important:TGMessageSortKeySpace(mediaMessageItem->_message.sortKey) == TGMessageSpaceImportant];
            }
            else
            {
                modernGallery.model = [[TGGenericPeerMediaGalleryModel alloc] initWithPeerId:((TGGenericModernConversationCompanion *)_companion).conversationId atMessageId:mediaMessageItem->_message.mid allowActions:_companion.allowMessageForwarding important:TGMessageSortKeySpace(mediaMessageItem->_message.sortKey) == TGMessageSpaceImportant];
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
                else
                {
                    int32_t messageId = webPageMessageId;
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
                        if (cellItem != nil && cellItem->_message.mid == messageId)
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
                        if (cellItem != nil && cellItem->_message.mid == messageId)
                        {
                            return [cellItem referenceViewForImageTransition];
                        }
                    }
                }
                else
                {
                    int32_t messageId = webPageMessageId;
                    for (TGModernCollectionCell *cell in strongSelf->_collectionView.visibleCells)
                    {
                        TGMessageModernConversationItem *cellItem = [cell boundItem];
                        if (cellItem != nil && cellItem->_message.mid == messageId)
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
                        if (cellItem != nil && cellItem->_message.mid == messageId)
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
                        if (cellItem != nil && cellItem->_message.mid == messageId)
                        {
                            return [cellItem referenceViewForImageTransition];
                        }
                    }
                }
                else
                {
                    int32_t messageId = webPageMessageId;
                    for (TGModernCollectionCell *cell in strongSelf->_collectionView.visibleCells)
                    {
                        TGMessageModernConversationItem *cellItem = [cell boundItem];
                        if (cellItem != nil && cellItem->_message.mid == messageId)
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
        
        [self closeExistingMediaGallery];
        
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

- (void)playAudioFromMessage:(int32_t)messageId media:(id)media
{
    if (_currentAudioRecorder != nil)
        return;
    
    [self stopAudioRecording];
    [self stopInlineMediaIfPlaying];
    
    NSString *localFilePath = nil;
    if ([media isKindOfClass:[TGAudioMediaAttachment class]])
        localFilePath = ((TGAudioMediaAttachment *)media).localFilePath;
    else if ([media isKindOfClass:[TGDocumentMediaAttachment class]])
        localFilePath = [[_companion fileUrlForDocumentMedia:media] path];
    
    _currentAudioPlayer = [[TGModernConversationAudioPlayer alloc] initWithFilePath:localFilePath];
    _currentAudioPlayer.delegate = self;
    _currentAudioPlayerMessageId = messageId;
    [_currentAudioPlayer play:0.0f];
    
    [self updateInlineMediaContexts];
    
    _streamAudioItems = TGAppDelegateInstance.autoPlayAudio;
    if (_streamAudioItems)
        _currentStreamingAudioMessageId = messageId;
    else
        _currentStreamingAudioMessageId = 0;
    
    [_companion updateMediaAccessTimeForMessageId:messageId];
    
    [_companion markMessagesAsViewed:@[@(messageId)]];
}

- (void)closeExistingMediaGallery
{
    for (UIWindow *window in [self.associatedWindowStack copy])
    {
        if ([window isKindOfClass:[TGOverlayControllerWindow class]])
        {
            if ([window.rootViewController isKindOfClass:[TGModernGalleryController class]])
            {
                [((TGModernGalleryController *)window.rootViewController) dismiss];
            }
        }
    }
}

- (void)closeMediaFromMessage:(int32_t)__unused messageId instant:(bool)__unused instant
{
    [self closeExistingMediaGallery];
    
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
                [controller.companion controllerDeletedMessages:@[@(messageId)] completion:nil];
                
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
                [controller.companion controllerDeletedMessages:@[@(messageId)] completion:nil];
            }
        } target:self] showInView:_view];
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
            CGRect contentFrame = [[cell contentViewForBinding] convertRect:[messageItem effectiveContentFrame] toView:_view];
            if (CGRectIsNull(contentFrame) || CGRectIsEmpty(contentFrame))
                break;
            
            contentFrame = CGRectIntersection(contentFrame, CGRectMake(0, 0, _view.frame.size.width, _currentInputPanel == nil ? _view.frame.size.height : _currentInputPanel.frame.origin.y));
            if (CGRectIsNull(contentFrame) || CGRectIsEmpty(contentFrame))
                break;
            
            if (_menuContainerView == nil)
                _menuContainerView = [[TGMenuContainerView alloc] init];
            
            if (_menuContainerView.superview != _view)
                [_view addSubview:_menuContainerView];
            
            _menuContainerView.frame = CGRectMake(0, self.controllerInset.top, _view.frame.size.width, _view.frame.size.height - self.controllerInset.top - self.controllerInset.bottom);
            
            NSMutableArray *actions = [[NSMutableArray alloc] init];
            
            if ([_companion allowReplies] && messageItem->_message.mid < TGMessageLocalMidBaseline)
            {
                [actions addObject:[[NSDictionary alloc] initWithObjectsAndKeys:TGLocalized(@"Conversation.ContextMenuReply"), @"title", @"reply", @"action", nil]];
                
                if ([_companion canDeleteMessage:messageItem->_message] && messageItem->_message.actionInfo != nil)
                {
                    [actions addObject:[[NSDictionary alloc] initWithObjectsAndKeys:TGLocalized(@"Conversation.ContextMenuDelete"), @"title", @"delete", @"action", nil]];
                }
            }
            else
            {
                if ([_companion canDeleteMessage:messageItem->_message]) {
                    [actions addObject:[[NSDictionary alloc] initWithObjectsAndKeys:TGLocalized(@"Conversation.ContextMenuDelete"), @"title", @"delete", @"action", nil]];
                }
            }
            
        
            bool hasCaption = false;
            for (TGMediaAttachment *attachment in messageItem->_message.mediaAttachments)
            {
                if ([attachment isKindOfClass:[TGImageMediaAttachment class]])
                {
                    TGImageMediaAttachment *imageAttachment = (TGImageMediaAttachment *)attachment;
                    hasCaption = (imageAttachment.caption.length > 0);
                }
            }
            
            
            bool isDocument = false;
            id<TGStickerPackReference> stickerPackReference = nil;
            for (id attachment in messageItem->_message.mediaAttachments)
            {
                if ([attachment isKindOfClass:[TGDocumentMediaAttachment class]])
                {
                    NSString *localFilePath = [[_companion fileUrlForDocumentMedia:attachment] path];
                    if ([[NSFileManager defaultManager] fileExistsAtPath:localFilePath isDirectory:NULL])
                        isDocument = true;
                    for (id attribute in ((TGDocumentMediaAttachment *)attachment).attributes)
                    {
                        if ([attribute isKindOfClass:[TGDocumentAttributeSticker class]])
                        {
                            stickerPackReference = ((TGDocumentAttributeSticker *)attribute).packReference;
                            break;
                        }
                    }
                    break;
                }
            }
            
            bool addedForward = false;
            if (TGPeerIdIsChannel(messageItem->_message.fromUid) && [_companion allowReplies]) {
                addedForward = true;
            }
            
            if (!addedForward && TGPeerIdIsChannel(messageItem->_message.fromUid) && messageItem->_message.actionInfo == nil) {
                addedForward = true;
                [actions addObject:[[NSDictionary alloc] initWithObjectsAndKeys:TGLocalized(@"Conversation.ContextMenuForward"), @"title", @"forward", @"action", nil]];
            }
            
            if (messageItem->_message.text.length != 0 || hasCaption)
                [actions addObject:[[NSDictionary alloc] initWithObjectsAndKeys:TGLocalized(@"Conversation.ContextMenuCopy"), @"title", @"copy", @"action", nil]];
            else if (stickerPackReference != nil)
            {
                if ([TGStickersSignals isStickerPackInstalled:stickerPackReference])
                {
                    [actions addObject:[[NSDictionary alloc] initWithObjectsAndKeys:TGLocalized(@"Conversation.ContextMenuStickerPackInfo"), @"title", @"stickerPackInfo", @"action", nil]];
                }
                else
                {
                    [actions addObject:[[NSDictionary alloc] initWithObjectsAndKeys:TGLocalized(@"Conversation.ContextMenuStickerPackAdd"), @"title", @"stickerPackInfo", @"action", nil]];
                }
            }
            else if (messageItem->_message.actionInfo == nil && [_companion allowMessageForwarding] && !addedForward) {
                [actions addObject:[[NSDictionary alloc] initWithObjectsAndKeys:TGLocalized(@"Conversation.ContextMenuForward"), @"title", @"forward", @"action", nil]];
            }
            
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
            
            if (actions.count != 0) {
                [_menuContainerView.menuView setUserInfo:@{@"mid": @(messageId)}];
                [_menuContainerView.menuView setButtonsAndActions:actions watcherHandle:_actionHandle];
                [_menuContainerView.menuView sizeToFit];
                [_menuContainerView showMenuFromRect:[_menuContainerView convertRect:contentFrame fromView:_view]];
                
                highlightedItem = messageItem;
                [highlightedItem setTemporaryHighlighted:true viewStorage:_viewStorage];
            }
            
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

- (void)temporaryHighlightMessage:(int32_t)messageId automatically:(bool)automatically
{
    for (TGMessageModernConversationItem *item in _items)
    {
        if (item->_message.mid == messageId)
        {
            _temporaryHighlightMessageIdUponDisplay = 0;
            [item setTemporaryHighlighted:true viewStorage:_viewStorage];
            if (automatically)
            {
                TGDispatchAfter(0.7, dispatch_get_main_queue(), ^
                {
                    [item setTemporaryHighlighted:false viewStorage:_viewStorage];
                });
            }
        }
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
        NSString *displayString = url;
        if ([url hasPrefix:@"hashtag://"])
            displayString = [@"#" stringByAppendingString:[url substringFromIndex:@"hashtag://".length]];
        else if ([url hasPrefix:@"mention://"])
            displayString = [@"@" stringByAppendingString:[url substringFromIndex:@"mention://".length]];
        
        TGActionSheet *actionSheet = [[TGActionSheet alloc] initWithTitle:displayString.length < 70 ? displayString : [[displayString substringToIndex:70] stringByAppendingString:@"..."] actions:@[
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
                    else if ([url hasPrefix:@"hashtag://"])
                        copyString = [@"#" stringByAppendingString:[url substringFromIndex:@"hashtag://".length]];
                    else if ([url hasPrefix:@"mention://"])
                        copyString = [@"@" stringByAppendingString:[url substringFromIndex:@"mention://".length]];
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

- (void)openKeyboard
{
    if (!_editingMode)
    {
        _inputTextPanel.inputField.internalTextView.enableFirstResponder = true;
        [_inputTextPanel.inputField becomeFirstResponder];
    }
}

- (void)hideTitlePanel
{
    [self setCurrentTitlePanel:nil animation:TGModernConversationPanelAnimationSlide];
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
    [_collectionView layoutSubviews];
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
            [_emptyListPlaceholder adjustLayoutForSize:_view.bounds.size contentInsets:UIEdgeInsetsMake(_collectionView.contentInset.bottom - 210.0f - [_collectionView implicitTopInset], 0.0f, _collectionView.contentInset.top, 0.0f) duration:0.0f curve:0];
        }
        else
        {
            [_emptyListPlaceholder adjustLayoutForSize:_view.bounds.size contentInsets:UIEdgeInsetsMake(self.controllerInset.top, 0.0f, _currentInputPanel.frame.size.height, 0.0f) duration:0.0f curve:0];
        }
    }
}

- (NSString *)inputText
{
    return _inputTextPanel == nil ? _initialInputText : _inputTextPanel.maybeInputField.text;
}

- (void)setReplyMessage:(TGMessage *)replyMessage animated:(bool)animated
{
    TGModenConcersationReplyAssociatedPanel *panel = [[TGModenConcersationReplyAssociatedPanel alloc] initWithMessage:replyMessage];
    __weak TGModernConversationController *weakSelf = self;
    panel.dismiss = ^
    {
        __strong TGModernConversationController *strongSelf = weakSelf;
        if (strongSelf != nil)
        {
            [strongSelf->_inputTextPanel setPrimaryExtendedPanel:nil animated:true];
            [strongSelf->_inputTextPanel setSecondaryExtendedPanel:nil animated:true];
        }
    };
    [_inputTextPanel setPrimaryExtendedPanel:panel animated:animated];
}

- (void)setForwardMessages:(NSArray *)forwardMessages animated:(bool)animated
{
    if (_inputTextPanel == nil)
        _initialForwardMessages = forwardMessages;
    else
    {
        TGModernConversationForwardInputPanel *panel = [[TGModernConversationForwardInputPanel alloc] initWithMessages:forwardMessages];
        __weak TGModernConversationController *weakSelf = self;
        panel.dismiss = ^
        {
            __strong TGModernConversationController *strongSelf = weakSelf;
            if (strongSelf != nil)
            {
                [strongSelf->_inputTextPanel setPrimaryExtendedPanel:nil animated:true];
                [strongSelf->_inputTextPanel setSecondaryExtendedPanel:nil animated:true];
            }
        };
        
        [_inputTextPanel setPrimaryExtendedPanel:panel animated:animated];
    }
}

- (void)setInlineStickerList:(NSArray *)inlineStickerList
{
    if (inlineStickerList.count == 0)
    {
        if ([[_inputTextPanel associatedPanel] isKindOfClass:[TGStickerAssociatedInputPanel class]])
            [_inputTextPanel setAssociatedPanel:nil animated:true];
    }
    else
    {
        __weak TGModernConversationController *weakSelf = self;
        [_inputTextPanel setAssociatedStickerList:inlineStickerList stickerSelected:^(TGDocumentMediaAttachment *document)
        {
            __strong TGModernConversationController *strongSelf = weakSelf;
            if (strongSelf != nil)
            {
                [[SQueue concurrentDefaultQueue] dispatch:^{
                    [TGStickersSignals addUseCountForDocumentId:document.documentId];
                }];
                [strongSelf->_inputTextPanel.maybeInputField setText:@"" animated:true];
                [strongSelf->_companion controllerWantsToSendRemoteDocument:document asReplyToMessageId:[strongSelf currentReplyMessageId]];
            }
        }];
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

- (void)setStatus:(NSString *)status accentColored:(bool)accentColored allowAnimation:(bool)allowAnimation toggleMode:(TGModernConversationControllerTitleToggle)toggleMode
{
    [_titleView setStatus:status animated:self.isViewLoaded && allowAnimation];
    [_titleView setStatusHasAccentColor:accentColored];
    [_titleView setToggleMode:toggleMode];
}

- (void)setAttributedStatus:(NSAttributedString *)status allowAnimation:(bool)allowAnimation
{
    [_titleView setAttributedStatus:status animated:self.isViewLoaded && allowAnimation];
    [_titleView setStatusHasAccentColor:false];
}

- (void)setTypingStatus:(NSString *)typingStatus activity:(int)activity
{
    [_titleView setTypingStatus:typingStatus activity:(TGModernConversationTitleViewActivity)activity animated:self.isViewLoaded];
}

- (void)setGlobalUnreadCount:(int)unreadCount
{
    [_titleView setUnreadCount:unreadCount];
}

- (TGModernConversationInputPanel *)defaultInputPanel {
    if ([_companion _controllerShouldHideInputTextByDefault]) {
        return nil;
    } else {
        return _inputTextPanel;
    }
}

- (void)setCustomInputPanel:(TGModernConversationInputPanel *)customInputPanel
{
    if (_customInputPanel != customInputPanel)
    {
        _customInputPanel = customInputPanel;
        if (!_editingMode)
        {
            [self setInputPanel:_customInputPanel != nil ? _customInputPanel : [self defaultInputPanel] animated:ABS(CFAbsoluteTimeGetCurrent() - _willAppearTimestamp) > 0.18];
        }
    }
}

- (TGModernConversationInputPanel *)customInputPanel {
    return _customInputPanel;
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
    [self setSecondaryTitlePanel:secondaryTitlePanel animated:true];
}

- (void)setSecondaryTitlePanel:(TGModernConversationTitlePanel *)secondaryTitlePanel animated:(bool)animated
{
    if (_secondaryTitlePanel != secondaryTitlePanel)
    {
        bool applyAsCurrent = _currentTitlePanel == nil || _currentTitlePanel == _secondaryTitlePanel;
        _secondaryTitlePanel = secondaryTitlePanel;
        
        if (applyAsCurrent)
        {
            NSTimeInterval appearTime = ABS(CFAbsoluteTimeGetCurrent() - _willAppearTimestamp);
            [self setCurrentTitlePanel:secondaryTitlePanel animation:(animated && appearTime > 0.1) ? (appearTime > 0.4 ? TGModernConversationPanelAnimationSlide : TGModernConversationPanelAnimationFade) : TGModernConversationPanelAnimationNone];
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
                else if (animation == TGModernConversationPanelAnimationSlideFar)
                {
                    _titlePanelWrappingView.clipsToBounds = false;
                    [UIView animateWithDuration:0.3 delay:0.0 options:0 animations:^
                    {
                        lastPanel.frame = CGRectOffset(lastPanel.frame, 0.0f, -lastPanel.frame.size.height - lastPanel.superview.frame.origin.y);
                    } completion:^(__unused BOOL finished)
                    {
                        [lastPanel removeFromSuperview];
                        _titlePanelWrappingView.clipsToBounds = true;
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
        
        if (_currentTitlePanel != nil && [self isViewLoaded])
        {
            if (_titlePanelWrappingView == nil)
            {
                _titlePanelWrappingView = [[UIView alloc] initWithFrame:CGRectMake(0.0f, self.controllerInset.top, _view.frame.size.width, 44.0f)];
                _titlePanelWrappingView.clipsToBounds = true;
                [_view addSubview:_titlePanelWrappingView];
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
            [_view insertSubview:_emptyListPlaceholder belowSubview:_currentInputPanel];
            
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
                [_emptyListPlaceholder adjustLayoutForSize:_view.bounds.size contentInsets:UIEdgeInsetsMake(_collectionView.contentInset.bottom - 210.0f - [_collectionView implicitTopInset], 0.0f, _collectionView.contentInset.top, 0.0f) duration:0.0f curve:0];
            }
            else
            {
                [_emptyListPlaceholder adjustLayoutForSize:_view.bounds.size contentInsets:UIEdgeInsetsMake(self.controllerInset.top, 0.0f, 45.0f, 0.0f) duration:0.0f curve:0];
            }
        }
    }
}

- (void)setConversationHeader:(UIView *)conversationHeader
{
    _conversationHeader = conversationHeader;
    
    if (_collectionView != nil)
    {
        _collectionView.headerView = conversationHeader;

        UIEdgeInsets inset = _collectionView.contentInset;
        inset.bottom = self.controllerInset.top + 210.0f + [_collectionView implicitTopInset];
        _collectionView.contentInset = inset;
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
        
        if ([UIApplication sharedApplication] == nil)
            canReadHistory = false;
    }
    
    if (_canReadHistory != canReadHistory)
    {
        _canReadHistory = canReadHistory;
        [_companion controllerCanReadHistoryUpdated];
    }
}

- (void)_updateCanRegroupIncomingUnreadMessages
{
    [_companion controllerCanRegroupUnreadIncomingMessages];
}

- (bool)canReadHistory
{
    return _canReadHistory || ([UIApplication sharedApplication] != nil && [UIApplication sharedApplication].applicationState == UIApplicationStateActive && self.navigationController.topViewController == self);
}

- (NSArray *)_items
{
    return _items;
}

- (int32_t)_currentReplyMessageId
{
    return [self currentReplyMessageId];
}

- (NSArray *)_currentForwardMessageDescs
{
    NSMutableArray *messageDescs = [[NSMutableArray alloc] init];
    for (TGMessage *message in [self currentForwardMessages])
    {
        [messageDescs addObject:@{@"peerId": @(message.toUid), @"messageId": @(message.mid)}];
    }
    return messageDescs;
}

- (void)setReplyMarkup:(TGBotReplyMarkup *)replyMarkup
{
    _replyMarkup = replyMarkup;
    [_inputTextPanel setReplyMarkup:_replyMarkup];
}

- (void)setHasBots:(bool)hasBots
{
    _hasBots = hasBots;
    [_inputTextPanel setHasBots:_hasBots];
}

- (void)setCanBroadcast:(bool)canBroadcast
{
    _canBroadcast = canBroadcast;
    [_inputTextPanel setCanBroadcast:canBroadcast];
}

- (void)setIsBroadcasting:(bool)isBroadcasting
{
    _isBroadcasting = isBroadcasting;
    [_inputTextPanel setIsBroadcasting:isBroadcasting];
}

- (void)setIsAlwaysBroadcasting:(bool)isAlwaysBroadcasting {
    _isAlwaysBroadcasting = isAlwaysBroadcasting;
    [_inputTextPanel setIsAlwaysBroadcasting:isAlwaysBroadcasting];
}

- (void)appendCommand:(NSString *)command
{
    NSString *currentText = self.inputText;
    NSString *currentNormalizedText = [currentText lowercaseString];
    
    if (currentText.length == 0)
        currentText = command;
    else
    {
        bool foundSuffix = false;
        for (NSInteger i = (NSInteger)command.length; i > 0; i--)
        {
            if ([currentNormalizedText hasSuffix:[[command lowercaseString] substringToIndex:i]])
            {
                currentText = [currentText stringByReplacingCharactersInRange:NSMakeRange(currentText.length - i, i) withString:command];
                //currentText = [currentText stringByAppendingString:[command substringFromIndex:i]];
                foundSuffix = true;
                break;
            }
        }
        
        if (!foundSuffix)
        {
            if ([currentText hasSuffix:@" "])
                currentText = [currentText stringByAppendingFormat:@" %@ ", command];
            else
                currentText = [currentText stringByAppendingFormat:@"%@ ", command];
        }
    }
    
    [self setInputText:currentText replace:true];
    [_inputTextPanel inputField].internalTextView.enableFirstResponder = true;
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
    
    if (_titleView.toggleMode != TGModernConversationControllerTitleToggleNone) {
        [_companion _toggleTitleMode];
    } else {
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

- (void)inputPanelTextChanged:(TGModernConversationInputTextPanel *)__unused inputTextPanel text:(NSString *)text
{
    if (iosMajorVersion() >= 8 && _currentActivity != nil)
    {
        [_currentActivity addUserInfoEntriesFromDictionary:@{@"text": text == nil ? @"" : text}];
        _currentActivity.needsSave = true;
    }
    
    [_companion controllerDidChangeInputText:text];
}

- (void)inputPanelMentionEntered:(TGModernConversationInputTextPanel *)__unused inputTextPanel mention:(NSString *)mention
{
    if (mention == nil)
    {
        if ([[_inputTextPanel associatedPanel] isKindOfClass:[TGModernConversationMentionsAssociatedPanel class]])
            [_inputTextPanel setAssociatedPanel:nil animated:true];
    }
    else
    {
        TGModernConversationMentionsAssociatedPanel *panel = nil;
        if ([[_inputTextPanel associatedPanel] isKindOfClass:[TGModernConversationMentionsAssociatedPanel class]])
            panel = (TGModernConversationMentionsAssociatedPanel *)[_inputTextPanel associatedPanel];
        else
        {
            panel = [[TGModernConversationMentionsAssociatedPanel alloc] init];
            __weak TGModernConversationController *weakSelf = self;
            panel.userSelected = ^(TGUser *user)
            {
                __strong TGModernConversationController *strongSelf = weakSelf;
                if (strongSelf != nil)
                {
                    if ([[strongSelf->_inputTextPanel associatedPanel] isKindOfClass:[TGModernConversationMentionsAssociatedPanel class]])
                    {
                        [strongSelf->_inputTextPanel setAssociatedPanel:nil animated:false];
                    }
                    
                    [strongSelf->_inputTextPanel replaceMention:user.userName];
                }
            };
            [_inputTextPanel setAssociatedPanel:panel animated:true];
        }
        
        [panel setUserListSignal:[_companion userListForMention:mention]];
    }
}

- (void)inputPanelHashtagEntered:(TGModernConversationInputTextPanel *)__unused inputTextPanel hashtag:(NSString *)hashtag
{
    if (hashtag == nil)
    {
        if ([[_inputTextPanel associatedPanel] isKindOfClass:[TGModernConversationHashtagsAssociatedPanel class]])
            [_inputTextPanel setAssociatedPanel:nil animated:true];
    }
    else
    {
        TGModernConversationHashtagsAssociatedPanel *panel = nil;
        if ([[_inputTextPanel associatedPanel] isKindOfClass:[TGModernConversationHashtagsAssociatedPanel class]])
            panel = (TGModernConversationHashtagsAssociatedPanel *)[_inputTextPanel associatedPanel];
        else
        {
            panel = [[TGModernConversationHashtagsAssociatedPanel alloc] init];
            __weak TGModernConversationController *weakSelf = self;
            panel.hashtagSelected = ^(NSString *hashtag)
            {
                __strong TGModernConversationController *strongSelf = weakSelf;
                if (strongSelf != nil)
                {
                    if ([[strongSelf->_inputTextPanel associatedPanel] isKindOfClass:[TGModernConversationHashtagsAssociatedPanel class]])
                    {
                        [strongSelf->_inputTextPanel setAssociatedPanel:nil animated:false];
                    }
                    
                    [strongSelf->_inputTextPanel replaceHashtag:hashtag];
                }
            };
            [_inputTextPanel setAssociatedPanel:panel animated:true];
        }
        
        [panel setHashtagListSignal:[_companion hashtagListForHashtag:hashtag]];
    }
}

- (void)inputPanelCommandEntered:(TGModernConversationInputTextPanel *)__unused inputTextPanel command:(NSString *)command
{
    if (command == nil)
    {
        if ([[_inputTextPanel associatedPanel] isKindOfClass:[TGModernConversationCommandsAssociatedPanel class]])
            [_inputTextPanel setAssociatedPanel:nil animated:true];
    }
    else
    {
        TGModernConversationCommandsAssociatedPanel *panel = nil;
        if ([[_inputTextPanel associatedPanel] isKindOfClass:[TGModernConversationCommandsAssociatedPanel class]])
            panel = ((TGModernConversationCommandsAssociatedPanel *)[_inputTextPanel associatedPanel]);
        else
        {
            panel = [[TGModernConversationCommandsAssociatedPanel alloc] init];
            __weak TGModernConversationController *weakSelf = self;
            panel.commandSelected = ^(TGBotComandInfo *command, TGUser *user)
            {
                __strong TGModernConversationController *strongSelf = weakSelf;
                if (strongSelf != nil)
                {
                    if ([[strongSelf->_inputTextPanel associatedPanel] isKindOfClass:[TGModernConversationCommandsAssociatedPanel class]])
                    {
                        [strongSelf->_inputTextPanel setAssociatedPanel:nil animated:false];
                    }
                    
                    NSString *commandText = command.command;
                    if (user != nil && ![strongSelf->_companion isASingleBotGroup])
                        commandText = [commandText stringByAppendingFormat:@"@%@", user.userName];
                    
                    [strongSelf->_companion controllerWantsToSendTextMessage:[@"/" stringByAppendingString:commandText] asReplyToMessageId:[strongSelf currentReplyMessageId] withAttachedMessages:@[] disableLinkPreviews:false];
                    
                    //[strongSelf appendCommand:commandText];
                }
            };
            [_inputTextPanel setAssociatedPanel:panel animated:true];
        }
        [panel setCommandListSignal:[_companion commandListForCommand:command]];
    }
}

- (void)inputPanelLinkParsed:(TGModernConversationInputTextPanel *)__unused inputTextPanel link:(NSString *)link probablyComplete:(bool)probablyComplete
{
    if (![_companion allowMessageForwarding])
        return;
    
    if (_currentLinkParseDisposable == nil)
        _currentLinkParseDisposable = [[SMetaDisposable alloc] init];
    
    if (!TGStringCompare(_currentLinkParseLink, link))
    {
        _disableLinkPreviewsForMessage = false;
        if (link.length == 0)
        {
            _currentLinkParseLink = link;
            [_currentLinkParseDisposable setDisposable:nil];
            
            if ([[_inputTextPanel secondaryExtendedPanel] isKindOfClass:[TGModernConversationWebPreviewInputPanel class]])
            {
                [_inputTextPanel setSecondaryExtendedPanel:nil animated:true];
            }
        }
        else
        {
            SSignal *parseLinkSignal = [TGUpdateStateRequestBuilder requestWebPageByText:link];
            if (!probablyComplete)
                parseLinkSignal = [parseLinkSignal delay:4.0 onQueue:[SQueue mainQueue]];
            
            __weak TGModernConversationController *weakSelf = self;
            
            if ([[_inputTextPanel secondaryExtendedPanel] isKindOfClass:[TGModernConversationWebPreviewInputPanel class]])
            {
                [_inputTextPanel setSecondaryExtendedPanel:nil animated:true];
            }

            _currentLinkParseLink = link;
            [_currentLinkParseDisposable setDisposable:[[parseLinkSignal deliverOn:[SQueue mainQueue]] startWithNext:^(TGWebPageMediaAttachment *webPage)
            {
                //TGLog(@"parsed link %@ to webpage (%@)", link, webPage.url == nil ? @"incomplete" : @"complete");
                __strong TGModernConversationController *strongSelf = weakSelf;
                if (strongSelf != nil)
                {
                    if (webPage == nil || (webPage.url == nil && webPage.pendingDate == -1))
                    {
                        if ([[strongSelf->_inputTextPanel secondaryExtendedPanel] isKindOfClass:[TGModernConversationWebPreviewInputPanel class]])
                        {
                            [strongSelf->_inputTextPanel setSecondaryExtendedPanel:nil animated:true];
                        }
                    }
                    else
                    {
                        TGModernConversationWebPreviewInputPanel *panel = nil;
                        if ([[strongSelf->_inputTextPanel secondaryExtendedPanel] isKindOfClass:[TGModernConversationWebPreviewInputPanel class]])
                        {
                            panel = (TGModernConversationWebPreviewInputPanel *)[strongSelf->_inputTextPanel secondaryExtendedPanel];
                        }
                        else
                        {
                            panel = [[TGModernConversationWebPreviewInputPanel alloc] init];
                            panel.dismiss = ^
                            {
                                __strong TGModernConversationController *strongSelf = weakSelf;
                                if (strongSelf != nil)
                                {
                                    [strongSelf->_inputTextPanel setSecondaryExtendedPanel:nil animated:true];
                                    strongSelf->_disableLinkPreviewsForMessage = true;
                                }
                            };
                            [strongSelf->_inputTextPanel setSecondaryExtendedPanel:panel animated:true];
                        }
                        
                        [panel setLink:link webPage:webPage];
                    }
                }
            }]];
        }
    }
}

- (bool)isInputPanelTextEnabled:(TGModernConversationInputTextPanel *)__unused inputTextPanel
{
    return [TGApplicationFeatures isTextMessageEnabledForPeerType:[_companion applicationFeaturePeerType] disabledMessage:NULL];
}

- (void)inputPanelFocused:(TGModernConversationInputTextPanel *)__unused inputTextPanel
{
    __autoreleasing NSString *disabledMessage = nil;
    if (![TGApplicationFeatures isTextMessageEnabledForPeerType:[_companion applicationFeaturePeerType] disabledMessage:&disabledMessage])
    {
        [[[TGAlertView alloc] initWithTitle:TGLocalized(@"FeatureDisabled.Oops") message:disabledMessage cancelButtonTitle:TGLocalized(@"Common.OK") okButtonTitle:nil completionBlock:nil] show];
    }
}

- (void)inputTextPanelHasCancelledTypingActivity:(TGModernConversationInputTextPanel *)__unused inputTextPanel
{
    [_companion controllerDidCancelTypingActivity];
}

- (int32_t)currentReplyMessageId
{
    int32_t replyMessageId = 0;
    id extendedPanel = [_inputTextPanel primaryExtendedPanel];
    if ([extendedPanel isKindOfClass:[TGModenConcersationReplyAssociatedPanel class]])
        replyMessageId = ((TGModenConcersationReplyAssociatedPanel *)extendedPanel).message.mid;
    return replyMessageId;
}

- (TGMessage *)currentReplyMessage
{
    id extendedPanel = [_inputTextPanel primaryExtendedPanel];
    if ([extendedPanel isKindOfClass:[TGModenConcersationReplyAssociatedPanel class]])
        return ((TGModenConcersationReplyAssociatedPanel *)extendedPanel).message;
    return nil;
}

- (NSArray *)currentForwardMessages
{
    id extendedPanel = [_inputTextPanel primaryExtendedPanel];
    if ([extendedPanel isKindOfClass:[TGModernConversationForwardInputPanel class]])
        return ((TGModernConversationForwardInputPanel *)extendedPanel).messages;
    return nil;
}

- (void)inputPanelRequestedSendMessage:(TGModernConversationInputTextPanel *)__unused inputTextPanel text:(NSString *)text
{
    [_companion controllerWantsToSendTextMessage:text asReplyToMessageId:[self currentReplyMessageId] withAttachedMessages:[self currentForwardMessages] disableLinkPreviews:_disableLinkPreviewsForMessage];
    _disableLinkPreviewsForMessage = false;
}

- (void)_asyncProcessMediaAssetSignals:(NSArray *)signals forIntent:(TGModernMediaPickerControllerIntent)intent
{
    TGProgressWindow *progressWindow = [[TGProgressWindow alloc] init];
    [progressWindow performSelector:@selector(showAnimated) withObject:nil afterDelay:0.5];
    
    SQueue *queue = [[SQueue alloc] init];
    
    __weak TGModernConversationController *weakSelf = self;
    SSignal *combinedSignal = nil;
    for (SSignal *signal in signals)
    {
        if (combinedSignal == nil)
            combinedSignal = [signal startOn:queue];
        else
            combinedSignal = [[combinedSignal then:signal] startOn:queue];
    }
    
    [[[combinedSignal reduceLeft:[[NSMutableArray alloc] init] with:^NSMutableArray *(NSMutableArray *itemDescriptions, id item)
    {
        [itemDescriptions addObject:item];
        return itemDescriptions;
    }] deliverOn:[SQueue mainQueue]] startWithNext:^(NSArray *itemDescriptions)
    {
        __strong TGModernConversationController *strongSelf = weakSelf;
        
        if (intent == TGModernMediaPickerControllerSendPhotoIntent)
            [strongSelf.companion controllerWantsToSendImagesWithDescriptions:itemDescriptions asReplyToMessageId:[strongSelf currentReplyMessageId]];
        else if (intent == TGModernMediaPickerControllerSendFileIntent)
            [strongSelf.companion controllerWantsToSendDocumentsWithDescriptions:itemDescriptions asReplyToMessageId:[strongSelf currentReplyMessageId]];
        
        [NSObject cancelPreviousPerformRequestsWithTarget:progressWindow selector:@selector(showAnimated) object:nil];
        [progressWindow dismiss:true];
    } error:^(__unused id error)
    {
        [NSObject cancelPreviousPerformRequestsWithTarget:progressWindow selector:@selector(showAnimated) object:nil];
        [progressWindow dismiss:true];
    } completed:^
    {
    }];
}

- (void)inputPanelRequestedAttachmentsMenu:(TGModernConversationInputTextPanel *)__unused inputTextPanel
{
    if (iosMajorVersion() >= 7 && !TGIsPad())
    {
        __weak TGModernConversationController *weakSelf = self;
        _attachmentSheetWindow = [[TGAttachmentSheetWindow alloc] init];
        _attachmentSheetWindow.dismissalBlock = ^
        {
            __strong TGModernConversationController *strongSelf = weakSelf;
            if (strongSelf == nil)
                return;
            
            strongSelf->_attachmentSheetWindow.rootViewController = nil;
            strongSelf->_attachmentSheetWindow = nil;
        };
        
        NSMutableArray *items = [[NSMutableArray alloc] init];
        
        TGAttachmentSheetRecentItemView *recentView = [[TGAttachmentSheetRecentItemView alloc] initWithParentController:self mode:TGAttachmentSheetItemViewSendPhotoMode];
        __weak TGAttachmentSheetRecentItemView *weakRecentView = recentView;
        recentView.disallowCaptions = ![_companion allowCaptionedMedia];
        recentView.done = ^
        {
            __strong TGModernConversationController *strongSelf = weakSelf;
            if (strongSelf != nil)
            {
                __strong TGAttachmentSheetRecentItemView *strongRecentView = weakRecentView;
                [strongSelf->_attachmentSheetWindow dismissAnimated:true completion:nil];
                
                if (strongRecentView != nil)
                {
                    [strongSelf _asyncProcessMediaAssetSignals:[strongRecentView selectedItemSignals:^id (UIImage *image, NSString *caption, NSString *maybeHash)
                    {
                        if (image != nil)
                        {
                            id description = [strongSelf.companion imageDescriptionFromImage:image caption:caption optionalAssetUrl:maybeHash == nil ? nil : [[NSString alloc] initWithFormat:@"image-%@", maybeHash]];
                            return description;
                        }
                        return nil;
                    }] forIntent:TGModernMediaPickerControllerSendPhotoIntent];
                }
            }
        };
        
        TGAttachmentSheetRecentControlledButtonItemView *multifunctionButtonView = [[TGAttachmentSheetRecentControlledButtonItemView alloc] initWithTitle:TGLocalized(@"Common.ChoosePhoto") pressed:^
        {
            __strong TGModernConversationController *strongSelf = weakSelf;
            if (strongSelf != nil)
            {
                [strongSelf.view endEditing:true];
                [strongSelf->_attachmentSheetWindow dismissAnimated:true completion:nil];
                [strongSelf _displayPhotoPicker];
            }
        } alternatePressed:^
        {
            TGProgressWindow *progressWindow = [[TGProgressWindow alloc] init];
            [progressWindow performSelector:@selector(showAnimated) withObject:nil afterDelay:0.5];
            
            __strong TGModernConversationController *strongSelf = weakSelf;
            if (strongSelf != nil)
            {
                __strong TGAttachmentSheetRecentItemView *strongRecentView = weakRecentView;
                [strongSelf->_attachmentSheetWindow dismissAnimated:true completion:nil];
                
                if (strongRecentView != nil)
                {
                    [strongSelf _asyncProcessMediaAssetSignals:[strongRecentView selectedItemSignals:^id (UIImage *image, NSString *caption, NSString *maybeHash)
                    {
                        if (image != nil)
                        {
                            id description = [strongSelf.companion imageDescriptionFromImage:image caption:caption optionalAssetUrl:maybeHash == nil ? nil : [[NSString alloc] initWithFormat:@"image-%@", maybeHash]];
                            return description;
                        }
                        return nil;
                    }] forIntent:TGModernMediaPickerControllerSendPhotoIntent];
                }
            }
        }];
        
        [recentView setMultifunctionButtonView:multifunctionButtonView];
        recentView.openCamera = ^(TGAttachmentSheetRecentCameraView *cameraView)
        {
            __strong TGModernConversationController *strongSelf = weakSelf;
            if (strongSelf != nil)
            {
                [strongSelf.view endEditing:true];
                [strongSelf _displayCameraWithView:cameraView];
            }
        };

        recentView.itemOpened = ^(void)
        {
            __strong TGModernConversationController *strongSelf = weakSelf;
            if (strongSelf != nil)
                [strongSelf.view endEditing:true];
        };
        
        recentView.userListSignal = ^SSignal *(NSString *mention)
        {
            __strong TGModernConversationController *strongSelf = weakSelf;
            if (strongSelf == nil)
                return nil;
            
            return [strongSelf->_companion userListForMention:mention];
        };
        
        recentView.hashtagListSignal = ^SSignal *(NSString *hashtag)
        {
            __strong TGModernConversationController *strongSelf = weakSelf;
            if (strongSelf == nil)
                return nil;
            
            return [strongSelf->_companion hashtagListForHashtag:hashtag];
        };
        
        [items addObject:recentView];
        [items addObject:multifunctionButtonView];
        [items addObject:[[TGAttachmentSheetButtonItemView alloc] initWithTitle:TGLocalized(@"Common.ChooseVideo") pressed:^
        {
            __strong TGModernConversationController *strongSelf = weakSelf;
            if (strongSelf != nil)
            {
                [strongSelf.view endEditing:true];
                [strongSelf->_attachmentSheetWindow dismissAnimated:true completion:nil];
                [strongSelf _displayVideoPicker];
            }
        }]];
        [items addObject:[[TGAttachmentSheetButtonItemView alloc] initWithTitle:TGLocalized(@"Conversation.SearchWebImages") pressed:^
        {
            __strong TGModernConversationController *strongSelf = weakSelf;
            if (strongSelf != nil)
            {
                [strongSelf.view endEditing:true];
                [strongSelf->_attachmentSheetWindow dismissAnimated:true completion:nil];
                [strongSelf _displayWebImagePicker];
            }
        }]];
        [items addObject:[[TGAttachmentSheetButtonItemView alloc] initWithTitle:TGLocalized(@"Conversation.Document") pressed:^
        {
            __strong TGModernConversationController *strongSelf = weakSelf;
            if (strongSelf != nil)
            {
                [strongSelf.view endEditing:true];
                [strongSelf _displaySendFileMenu];
            }
        }]];
        [items addObject:[[TGAttachmentSheetButtonItemView alloc] initWithTitle:TGLocalized(@"Conversation.Location") pressed:^
        {
            __strong TGModernConversationController *strongSelf = weakSelf;
            if (strongSelf != nil)
            {
                [strongSelf.view endEditing:true];
                [strongSelf->_attachmentSheetWindow dismissAnimated:true completion:nil];
                [strongSelf _displayLocationPicker];
            }
        }]];
        
        if ([_companion allowContactSharing])
        {
            [items addObject:[[TGAttachmentSheetButtonItemView alloc] initWithTitle:TGLocalized(@"Conversation.Contact") pressed:^
            {
                __strong TGModernConversationController *strongSelf = weakSelf;
                if (strongSelf != nil)
                {
                    [strongSelf.view endEditing:true];
                    [strongSelf->_attachmentSheetWindow dismissAnimated:true completion:nil];
                    [strongSelf _displayContactPicker];
                }
            }]];
        }
        
        TGAttachmentSheetButtonItemView *cancelItem =[[TGAttachmentSheetButtonItemView alloc] initWithTitle:TGLocalized(@"Common.Cancel") pressed:^
        {
            __strong TGModernConversationController *strongSelf = weakSelf;
            if (strongSelf != nil)
                [strongSelf->_attachmentSheetWindow dismissAnimated:true completion:nil];
        }];
        [cancelItem setBold:true];
        [items addObject:cancelItem];
        
        _attachmentSheetWindow.view.items = items;
        [_attachmentSheetWindow showAnimated:true completion:nil];
    }
    else
    {
        NSMutableArray *actions = [[NSMutableArray alloc] initWithArray:@[
            [[TGActionSheetAction alloc] initWithTitle:TGLocalized(@"Common.ChoosePhoto") action:@"choosePhoto"],
            [[TGActionSheetAction alloc] initWithTitle:TGLocalized(@"Common.ChooseVideo") action:@"chooseVideo"],
            [[TGActionSheetAction alloc] initWithTitle:TGLocalized(@"Conversation.SearchWebImages") action:@"searchWeb"],
            [[TGActionSheetAction alloc] initWithTitle:TGLocalized(@"Conversation.Document") action:@"document"],
            [[TGActionSheetAction alloc] initWithTitle:TGLocalized(@"Conversation.Location") action:@"chooseLocation"]
        ]];
        
        if ([_companion allowContactSharing])
            [actions addObject:[[TGActionSheetAction alloc] initWithTitle:TGLocalized(@"Conversation.Contact") action:@"contact"]];
        
        [actions insertObject:[[TGActionSheetAction alloc] initWithTitle:TGLocalized(@"Common.TakePhotoOrVideo") action:@"camera"] atIndex:0];
        
        [actions addObject:[[TGActionSheetAction alloc] initWithTitle:TGLocalized(@"Common.Cancel") action:@"cancel" type:TGActionSheetActionTypeCancel]];
        
        TGActionSheet *actionSheet = [[TGActionSheet alloc] initWithTitle:nil actions:actions actionBlock:^(TGModernConversationController *controller, NSString *action)
        {
            if (![action isEqualToString:@"cancel"])
            {
                [controller.view endEditing:true];
                
                if ([action isEqualToString:@"camera"])
                    [controller _displayCameraWithView:nil];
                if ([action isEqualToString:@"choosePhoto"])
                    [controller _displayPhotoPicker];
                else if ([action isEqualToString:@"searchWeb"])
                    [controller _displayWebImagePicker];
                else if ([action isEqualToString:@"chooseVideo"])
                    [controller _displayVideoPicker];
                else if ([action isEqualToString:@"chooseLocation"])
                    [controller _displayLocationPicker];
                else if ([action isEqualToString:@"document"])
                    [controller _displaySendFileMenu];
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
}

- (void)_displayLocationPicker
{
    __weak TGModernConversationController *weakSelf = self;
    
    TGLocationPickerControllerIntent intent = [_companion allowVenueSharing] ? TGLocationPickerControllerDefaultIntent : TGLocationPickerControllerCustomLocationIntent;
    TGLocationPickerController *controller = [[TGLocationPickerController alloc] initWithIntent:intent];
    controller.locationPicked = ^(CLLocationCoordinate2D coordinate, TGVenueAttachment *venue)
    {
        __strong TGModernConversationController *strongSelf = weakSelf;
        if (strongSelf == nil)
            return;
        
        [strongSelf->_companion controllerWantsToSendMapWithLatitude:coordinate.latitude longitude:coordinate.longitude venue:venue asReplyToMessageId:[strongSelf currentReplyMessageId]];
        [strongSelf dismissViewControllerAnimated:true completion:nil];
    };
    
    TGNavigationController *navigationController = [TGNavigationController navigationControllerWithControllers:@[controller]];
    navigationController.restrictLandscape = true;
    
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad)
    {
        navigationController.presentationStyle = TGNavigationControllerPresentationStyleInFormSheet;
        navigationController.modalPresentationStyle = UIModalPresentationFormSheet;
    }
    
    [self presentViewController:navigationController animated:true completion:nil];
}

- (void)_displayCameraWithView:(TGAttachmentSheetRecentCameraView *)cameraView
{
    __autoreleasing NSString *disabledMessage = nil;
    if (![TGApplicationFeatures isPhotoUploadEnabledForPeerType:[_companion applicationFeaturePeerType] disabledMessage:&disabledMessage])
    {
        [[[TGAlertView alloc] initWithTitle:TGLocalized(@"FeatureDisabled.Oops") message:disabledMessage cancelButtonTitle:TGLocalized(@"Common.OK") okButtonTitle:nil completionBlock:nil] show];
        return;
    }
    
    if (![TGAccessChecker checkCameraAuthorizationStatusWithAlertDismissComlpetion:nil])
        return;
    
    if (TGAppDelegateInstance.rootController.isSplitView)
        return;
    
    if (iosMajorVersion() < 7 || [UIDevice currentDevice].platformType == UIDevice4iPhone || [UIDevice currentDevice].platformType == UIDevice4GiPod)
    {
        [self _displayLegacyCamera];
        [self->_attachmentSheetWindow dismissAnimated:true completion:nil];
        return;
    }
    
    TGCameraController *controller = nil;
    CGSize screenSize = TGScreenSize();
    
    if (cameraView.previewView != nil)
        controller = [[TGCameraController alloc] initWithCamera:cameraView.previewView.camera previewView:cameraView.previewView intent:TGCameraControllerGenericIntent];
    else
        controller = [[TGCameraController alloc] init];
    
    controller.shouldStoreCapturedAssets = [_companion controllerShouldStoreCapturedAssets];
    controller.disallowCaptions = ![_companion allowCaptionedMedia];
    
    TGCameraControllerWindow *controllerWindow = [[TGCameraControllerWindow alloc] initWithParentController:self contentController:controller];
    if (_attachmentSheetWindow != nil)
        controllerWindow.windowLevel = _attachmentSheetWindow.windowLevel + 0.0001f;
    controllerWindow.hidden = false;
    controllerWindow.clipsToBounds = true;
    controllerWindow.frame = CGRectMake(0, 0, screenSize.width, screenSize.height);

    bool standalone = true;
    CGRect startFrame = CGRectMake(0, screenSize.height, screenSize.width, screenSize.height);
    if (cameraView != nil)
    {
        standalone = false;
        startFrame = [controller.view convertRect:cameraView.previewView.frame fromView:cameraView];
    }
    
    [cameraView detachPreviewView];
    [controller beginTransitionInFromRect:startFrame];
    
    __weak TGModernConversationController *weakSelf = self;
    __weak TGCameraController *weakCameraController = controller;
    __weak TGAttachmentSheetRecentCameraView *weakCameraView = cameraView;
    
    controller.beginTransitionOut = ^CGRect
    {
        __strong TGCameraController *strongCameraController = weakCameraController;
        if (strongCameraController == nil)
            return CGRectZero;
        
        if (!standalone)
        {
            __strong TGAttachmentSheetRecentCameraView *strongCameraView = weakCameraView;
            if (strongCameraView != nil)
                return [strongCameraController.view convertRect:strongCameraView.frame fromView:strongCameraView.superview];
        }

        return CGRectZero;
    };
    
    controller.finishedTransitionOut = ^
    {
        __strong TGAttachmentSheetRecentCameraView *strongCameraView = weakCameraView;
        if (strongCameraView == nil)
            return;
        
        [strongCameraView attachPreviewViewAnimated:true];
    };
    
    controller.finishedWithPhoto = ^(UIImage *resultImage, NSString *caption)
    {
        __strong TGModernConversationController *strongSelf = weakSelf;
        if (strongSelf == nil)
            return;
        
        __autoreleasing NSString *disabledMessage = nil;
        if (![TGApplicationFeatures isPhotoUploadEnabledForPeerType:[_companion applicationFeaturePeerType] disabledMessage:&disabledMessage])
        {
            [[[TGAlertView alloc] initWithTitle:TGLocalized(@"FeatureDisabled.Oops") message:disabledMessage cancelButtonTitle:TGLocalized(@"Common.OK") okButtonTitle:nil completionBlock:nil] show];
            return;
        }
        
        NSDictionary *imageDescription = [strongSelf->_companion imageDescriptionFromImage:resultImage caption:caption optionalAssetUrl:nil];
        NSMutableArray *descriptions = [[NSMutableArray alloc] init];
        if (imageDescription != nil)
            [descriptions addObject:imageDescription];
        [strongSelf->_companion controllerWantsToSendImagesWithDescriptions:descriptions asReplyToMessageId:[strongSelf currentReplyMessageId]];
        
        [strongSelf->_attachmentSheetWindow dismissAnimated:false completion:nil];
    };
    
    controller.finishedWithVideo = ^(NSString *existingAssetId, NSString *tempFilePath, NSUInteger fileSize, UIImage *previewImage, NSTimeInterval duration, CGSize dimensions, NSString *caption)
    {
        __strong TGModernConversationController *strongSelf = weakSelf;
        if (strongSelf == nil)
            return;
        
        __autoreleasing NSString *disabledMessage = nil;
        if (![TGApplicationFeatures isFileUploadEnabledForPeerType:[_companion applicationFeaturePeerType] disabledMessage:&disabledMessage])
        {
            [[[TGAlertView alloc] initWithTitle:TGLocalized(@"FeatureDisabled.Oops") message:disabledMessage cancelButtonTitle:TGLocalized(@"Common.OK") okButtonTitle:nil completionBlock:nil] show];
            return;
        }
        
        [strongSelf->_companion controllerWantsToSendLocalVideoWithTempFilePath:tempFilePath fileSize:(int32_t)fileSize previewImage:previewImage duration:duration dimensions:dimensions caption:caption assetUrl:existingAssetId liveUploadData:nil asReplyToMessageId:[strongSelf currentReplyMessageId]];
        
        [strongSelf->_attachmentSheetWindow dismissAnimated:false completion:nil];
    };
    
    controller.userListSignal = ^SSignal *(NSString *mention)
    {
        __strong TGModernConversationController *strongSelf = weakSelf;
        if (strongSelf == nil)
            return nil;
        
        return [strongSelf->_companion userListForMention:mention];
    };
    
    controller.hashtagListSignal = ^SSignal *(NSString *hashtag)
    {
        __strong TGModernConversationController *strongSelf = weakSelf;
        if (strongSelf == nil)
            return nil;
        
        return [strongSelf->_companion hashtagListForHashtag:hashtag];
    };
}

- (void)_displayLegacyCamera
{
    __autoreleasing NSString *disabledMessage = nil;
    if (![TGApplicationFeatures isPhotoUploadEnabledForPeerType:[_companion applicationFeaturePeerType] disabledMessage:&disabledMessage])
    {
        [[[TGAlertView alloc] initWithTitle:TGLocalized(@"FeatureDisabled.Oops") message:disabledMessage cancelButtonTitle:TGLocalized(@"Common.OK") okButtonTitle:nil completionBlock:nil] show];
        return;
    }

    TGLegacyCameraController *legacyCameraController = [[TGLegacyCameraController alloc] init];
    legacyCameraController.sourceType = UIImagePickerControllerSourceTypeCamera;
    legacyCameraController.mediaTypes = [[NSArray alloc] initWithObjects:(__bridge NSString *)kUTTypeImage, (__bridge NSString *)kUTTypeMovie, nil];
    
    legacyCameraController.storeCapturedAssets = [_companion controllerShouldStoreCapturedAssets];
    legacyCameraController.completionDelegate = self;
    
    legacyCameraController.videoMaximumDuration = 100 * 60 * 60;
    [legacyCameraController setVideoQuality:UIImagePickerControllerQualityTypeMedium];
    legacyCameraController.completionDelegate = self;
    
    [self presentViewController:legacyCameraController animated:true completion:nil];
}

- (void)_displayVideoPicker
{
    __autoreleasing NSString *disabledMessage = nil;
    if (![TGApplicationFeatures isFileUploadEnabledForPeerType:[_companion applicationFeaturePeerType] disabledMessage:&disabledMessage])
    {
        [[[TGAlertView alloc] initWithTitle:TGLocalized(@"FeatureDisabled.Oops") message:disabledMessage cancelButtonTitle:TGLocalized(@"Common.OK") okButtonTitle:nil completionBlock:nil] show];
        return;
    }
    
    if (![TGAccessChecker checkPhotoAuthorizationStatusForIntent:TGPhotoAccessIntentRead alertDismissCompletion:nil])
        return;
    
    __weak TGModernConversationController *weakSelf = self;
    void (^videoPicked)(NSString *, NSString *, CGSize , NSTimeInterval , UIImage *, NSString *, TGLiveUploadActorData *) = ^(NSString *videoAssetId, NSString *tempFilePath, CGSize dimensions, NSTimeInterval duration, UIImage *thumbnail, NSString *caption, TGLiveUploadActorData *liveUploadData)
    {
        TGDispatchOnMainThread(^
        {
            __strong TGModernConversationController *strongSelf = weakSelf;
            
            TGVideoMediaAttachment *videoAttachment = nil;
            if (videoAssetId != nil)
                videoAttachment = [strongSelf.companion serverCachedAssetWithId:videoAssetId];
            
            if (videoAttachment != nil)
            {
                videoAttachment.caption = caption;
                [strongSelf.companion controllerWantsToSendRemoteVideoWithMedia:videoAttachment asReplyToMessageId:[strongSelf currentReplyMessageId]];
            }
            else
            {
                int fileSize = [[[NSFileManager defaultManager] attributesOfItemAtPath:tempFilePath error:NULL][NSFileSize] intValue];
                if (fileSize != 0)
                {
                    [strongSelf.companion controllerWantsToSendLocalVideoWithTempFilePath:tempFilePath fileSize:(int32_t)fileSize previewImage:thumbnail duration:duration dimensions:dimensions caption:caption assetUrl:videoAssetId liveUploadData:liveUploadData asReplyToMessageId:[strongSelf currentReplyMessageId]];
                }
            }
        });
    };
    
    void(^dismiss)(void) = ^
    {
        __strong TGModernConversationController *strongSelf = weakSelf;
        if (strongSelf == nil)
            return;
        
        [strongSelf dismissViewControllerAnimated:true completion:nil];
    };
    
    void(^showMediaPicker)(TGMediaPickerAssetsGroup *) = ^(TGMediaPickerAssetsGroup *group)
    {
        __strong TGModernConversationController *strongSelf = weakSelf;
        if (strongSelf == nil)
            return;
        
        TGMediaFoldersController *mediaFoldersController = [[TGMediaFoldersController alloc] initWithIntent:TGModernMediaPickerControllerSendVideoIntent];
        mediaFoldersController.dismiss = dismiss;
        mediaFoldersController.videoPicked = videoPicked;
        mediaFoldersController.liveUpload = [strongSelf->_companion controllerShouldLiveUploadVideo];
        mediaFoldersController.enableServerAssetCache = [strongSelf->_companion controllerShouldCacheServerAssets];
        mediaFoldersController.disallowCaptions = ![strongSelf->_companion allowCaptionedMedia];
        
        TGModernMediaPickerController *mediaPickerController = [[TGModernMediaPickerController alloc] initWithAssetsGroup:group intent:TGModernMediaPickerControllerSendVideoIntent];
        mediaPickerController.dismiss = dismiss;
        mediaPickerController.videoPicked = videoPicked;
        mediaPickerController.liveUploadEnabled = [strongSelf->_companion controllerShouldLiveUploadVideo];
        mediaPickerController.serverAssetCacheEnabled = [strongSelf->_companion controllerShouldCacheServerAssets];
        mediaPickerController.disallowCaptions = ![strongSelf->_companion allowCaptionedMedia];
        TGNavigationController *navigationController = [TGNavigationController navigationControllerWithControllers:@[mediaFoldersController, mediaPickerController]];
        
        if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad)
        {
            navigationController.presentationStyle = TGNavigationControllerPresentationStyleInFormSheet;
            navigationController.modalPresentationStyle = UIModalPresentationFormSheet;
        }
        
        [strongSelf presentViewController:navigationController animated:true completion:nil];
    };
    
    if ([[TGMediaPickerAssetsLibrary sharedLibrary] authorizationStatus] == TGMediaPickerAuthorizationStatusNotDetermined)
    {
        [[TGMediaPickerAssetsLibrary sharedLibrary] fetchAssetsGroupsWithCompletionBlock:^(NSArray *groups, __unused TGMediaPickerAuthorizationStatus status, __unused NSError *error)
        {
            TGDispatchOnMainThread(^
            {
                if (![TGAccessChecker checkPhotoAuthorizationStatusForIntent:TGPhotoAccessIntentRead alertDismissCompletion:nil])
                    return;
                
                TGMediaPickerAssetsGroup *cameraRollGroup = nil;
                for (TGMediaPickerAssetsGroup *group in groups)
                {
                    if (group.isCameraRoll)
                    {
                        cameraRollGroup = group;
                        break;
                    }
                }
                
                showMediaPicker(cameraRollGroup);
            });
        }];
    }
    else
    {
        showMediaPicker(nil);
    }
}

- (void)_displayICloudDrivePicker
{
    NSArray *documentTypes = @[@"public.composite-content",
                               @"public.text",
                               @"public.image",
                               @"public.audio",
                               @"public.video",
                               @"public.movie",
                               @"public.font",
                               @"org.telegram.Telegram.webp",
                               @"com.apple.iwork.pages.pages",
                               @"com.apple.iwork.numbers.numbers",
                               @"com.apple.iwork.keynote.key"];
    
    UIDocumentPickerViewController *controller = [[UIDocumentPickerViewController alloc] initWithDocumentTypes:documentTypes inMode:UIDocumentPickerModeOpen];
    controller.view.backgroundColor = [UIColor whiteColor];
    controller.delegate = self;
    
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad)
        controller.modalPresentationStyle = UIModalPresentationFormSheet;
    
    [self presentViewController:controller animated:true completion:nil];
}

- (void)_displayDropboxPicker
{
    _dropboxProxy = [[TGObserverProxy alloc] initWithTarget:self targetSelector:@selector(dropboxFilesReceived:) name:TGDropboxFilesReceivedNotification];
    [TGDropboxHelper openExternalPicker];
}

- (void)_displayGoogleDrivePicker
{
    __weak TGModernConversationController *weakSelf = self;
    
    TGGoogleDriveController *controller = [[TGGoogleDriveController alloc] init];
    controller.dismiss = ^
    {
        __strong TGModernConversationController *strongSelf = weakSelf;
        if (strongSelf == nil)
            return;
        
        [strongSelf dismissViewControllerAnimated:true completion:nil];
    };
    controller.filePicked = ^(TGGoogleDriveItem *item)
    {
        __strong TGModernConversationController *strongSelf = weakSelf;
        if (strongSelf == nil)
            return;
        
        id description = [strongSelf.companion documentDescriptionFromGoogleDriveItem:item];
        [strongSelf.companion controllerWantsToSendCloudDocumentsWithDescriptions:@[description] asReplyToMessageId:[strongSelf currentReplyMessageId]];
    };
    
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad)
    {
        controller.presentationStyle = TGNavigationControllerPresentationStyleInFormSheet;
        controller.modalPresentationStyle = UIModalPresentationFormSheet;
    }
    
    [self presentViewController:controller animated:true completion:nil];
}

- (void)_displaySendFileMenu
{
    if ((iosMajorVersion() >= 8) || (iosMajorVersion() >= 7 && ([TGDropboxHelper isDropboxInstalled] || [TGGoogleDriveController isGoogleDriveInstalled])))
    {
        __weak TGModernConversationController *weakSelf = self;
        
        CGSize screenSize = TGScreenSize();
        bool stickToBottom = ABS(screenSize.height - 568.0f) < FLT_EPSILON && UIInterfaceOrientationIsPortrait(self.interfaceOrientation);
        
        if ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPhone)
        {
            TGAttachmentSheetView *fileSheetView = [[TGAttachmentSheetView alloc] init];
            
            NSMutableArray *items = [[NSMutableArray alloc] init];
            
            __weak TGAttachmentSheetView *weakFileSheetView = fileSheetView;
            TGAttachmentSheetFileInstructionItemView *instructionItemView = [[TGAttachmentSheetFileInstructionItemView alloc] init];
            instructionItemView.folded = [[[NSUserDefaults standardUserDefaults] objectForKey:@"didShowDocumentPickerTip_v2"] boolValue];

            if (!instructionItemView.folded)
                [[NSUserDefaults standardUserDefaults] setObject:@true forKey:@"didShowDocumentPickerTip_v2"];
            
            __weak TGAttachmentSheetFileInstructionItemView *weakInstructionItemView = instructionItemView;
            instructionItemView.pressed = ^
            {
                __strong TGAttachmentSheetView *strongFileSheetView = weakFileSheetView;
                if (strongFileSheetView == nil)
                    return;
                
                
                __strong TGAttachmentSheetFileInstructionItemView *strongInstructionItemView = weakInstructionItemView;
                if (strongInstructionItemView == nil)
                    return;
                
                [strongFileSheetView performAnimated:true updates:^
                {
                    strongInstructionItemView.folded = false;
                } stickToBottom:stickToBottom completion:nil];
            };
            [items addObject:instructionItemView];
            
            [items addObject:[[TGAttachmentSheetButtonItemView alloc] initWithTitle:TGLocalized(@"Conversation.FilePhotoOrVideo") pressed:^
            {
                __strong TGModernConversationController *strongSelf = weakSelf;
                if (strongSelf != nil)
                {
                    [strongSelf->_attachmentSheetWindow dismissAnimated:true completion:nil];
                    [strongSelf _displayPhotoVideoFilePickerFromFileMenu:true];
                }
            }]];
            
            if (iosMajorVersion() >= 8)
            {
                [items addObject:[[TGAttachmentSheetButtonItemView alloc] initWithTitle:TGLocalized(@"Conversation.FileICloudDrive") pressed:^
                {
                    __strong TGModernConversationController *strongSelf = weakSelf;
                    if (strongSelf != nil)
                    {
                        [strongSelf->_attachmentSheetWindow dismissAnimated:true completion:nil];
                        [strongSelf _displayICloudDrivePicker];
                    }
                }]];
            }
            
            if ([TGDropboxHelper isDropboxInstalled])
            {
                [items addObject:[[TGAttachmentSheetButtonItemView alloc] initWithTitle:TGLocalized(@"Conversation.FileDropbox") pressed:^
                {
                    __strong TGModernConversationController *strongSelf = weakSelf;
                    if (strongSelf != nil)
                    {
                        [strongSelf->_attachmentSheetWindow dismissAnimated:true completion:nil];
                        [strongSelf _displayDropboxPicker];
                    }
                }]];
            }
            
            if ([TGGoogleDriveController isGoogleDriveInstalled])
            {
                [items addObject:[[TGAttachmentSheetButtonItemView alloc] initWithTitle:TGLocalized(@"Conversation.FileGoogleDrive") pressed:^
                {
                    __strong TGModernConversationController *strongSelf = weakSelf;
                    if (strongSelf != nil)
                    {
                        [strongSelf->_attachmentSheetWindow dismissAnimated:true completion:nil];
                        [strongSelf _displayGoogleDrivePicker];
                    }
                }]];
            }
            
            TGAttachmentSheetButtonItemView *cancelItem = [[TGAttachmentSheetButtonItemView alloc] initWithTitle:TGLocalized(@"Common.Cancel") pressed:^
            {
                __strong TGModernConversationController *strongSelf = weakSelf;
                if (strongSelf != nil)
                    [strongSelf->_attachmentSheetWindow dismissAnimated:true completion:nil];
            }];
            [cancelItem setBold:true];
            [items addObject:cancelItem];
            
            fileSheetView.items = items;
            
            [_attachmentSheetWindow switchToSheetView:fileSheetView stickToBottom:stickToBottom];
        }
        else
        {
            NSMutableArray *actions = [[NSMutableArray alloc] init];
            
            [actions addObject:[[TGActionSheetAction alloc] initWithTitle:TGLocalized(@"Conversation.FilePhotoOrVideo") action:@"photoOrVideo"]];
            
            if (iosMajorVersion() >= 8)
                [actions addObject:[[TGActionSheetAction alloc] initWithTitle:TGLocalized(@"Conversation.FileICloudDrive") action:@"iCloudDrive"]];
            if ([TGDropboxHelper isDropboxInstalled])
                [actions addObject:[[TGActionSheetAction alloc] initWithTitle:TGLocalized(@"Conversation.FileDropbox") action:@"dropbox"]];
            if ([TGGoogleDriveController isGoogleDriveInstalled])
                [actions addObject:[[TGActionSheetAction alloc] initWithTitle:TGLocalized(@"Conversation.FileGoogleDrive") action:@"googleDrive"]];
            
            [actions addObject:[[TGActionSheetAction alloc] initWithTitle:TGLocalized(@"Common.Cancel") action:@"cancel" type:TGActionSheetActionTypeCancel]];
            
            TGActionSheet *actionSheet = [[TGActionSheet alloc] initWithTitle:nil actions:actions actionBlock:^(TGModernConversationController *controller, NSString *action)
            {
                if (![action isEqualToString:@"cancel"])
                {
                    [controller.view endEditing:true];
                    
                    if ([action isEqualToString:@"photoOrVideo"])
                        [controller _displayPhotoVideoFilePickerFromFileMenu:false];
                    if ([action isEqualToString:@"iCloudDrive"])
                        [controller _displayICloudDrivePicker];
                    else if ([action isEqualToString:@"dropbox"])
                        [controller _displayDropboxPicker];
                    else if ([action isEqualToString:@"googleDrive"])
                        [controller _displayGoogleDrivePicker];
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
    }
    else
    {
        [_attachmentSheetWindow dismissAnimated:true completion:nil];
        [self _displayPhotoVideoFilePickerFromFileMenu:false];
    }
}

- (void)dropboxFilesReceived:(NSNotification *)notification
{
    if (notification.object == nil && ![notification.object isKindOfClass:[NSArray class]] && _dropboxProxy != nil)
        return;
    
    NSArray *items = (NSArray *)notification.object;
    
    NSMutableArray *descriptions = [[NSMutableArray alloc] init];
    for (TGDropboxItem *item in items)
    {
        id description = [self.companion documentDescriptionFromDropboxItem:item];
        if (description != nil)
            [descriptions addObject:description];
    }
    
    [self.companion controllerWantsToSendCloudDocumentsWithDescriptions:descriptions asReplyToMessageId:[self currentReplyMessageId]];
}

- (void)documentPicker:(UIDocumentPickerViewController *)__unused controller didPickDocumentAtURL:(NSURL *)url
{
    __weak TGModernConversationController *weakSelf = self;
    _currentICloudItemRequest = [TGICloudItemRequest requestICloudItemWithUrl:url completion:^(TGICloudItem *item)
    {
        __strong TGModernConversationController *strongSelf = weakSelf;
        if (strongSelf == nil)
            return;
        
        strongSelf->_currentICloudItemRequest = nil;
        
        id description = [strongSelf.companion documentDescriptionFromICloudDriveItem:item];
        if (description != nil)
            [strongSelf.companion controllerWantsToSendCloudDocumentsWithDescriptions:@[description] asReplyToMessageId:[strongSelf currentReplyMessageId]];
    }];
}

- (void)_displayPhotoVideoFilePickerFromFileMenu:(bool)fromFileMenu
{
    if (![TGAccessChecker checkPhotoAuthorizationStatusForIntent:TGPhotoAccessIntentRead alertDismissCompletion:nil])
        return;
    
    __weak TGModernConversationController *weakSelf = self;
    void(^photosPicked)(TGModernMediaPickerController *) = ^(TGModernMediaPickerController *sender)
    {
        __strong TGModernConversationController *strongSelf = weakSelf;
        if (strongSelf == nil)
            return;
        
        [strongSelf _asyncProcessMediaAssetSignals:[sender selectedItemSignals:^id(id fileDict, __unused NSString *caption, __unused NSString *maybeHash)
        {
            if (fileDict != nil)
            {
                id description = [strongSelf.companion documentDescriptionFromFileAtTempUrl:fileDict[@"tempFileUrl"] fileName:fileDict[@"fileName"] mimeType:fileDict[@"mimeType"]];
                return description;
            }
            return nil;
        }] forIntent:TGModernMediaPickerControllerSendFileIntent];
    };
    
    void(^dismiss)(void) = ^
    {
        __strong TGModernConversationController *strongSelf = weakSelf;
        if (strongSelf == nil)
            return;
        
        [strongSelf dismissViewControllerAnimated:true completion:nil];
    };
    
    void (^showMediaPicker)(TGMediaPickerAssetsGroup *) = ^(TGMediaPickerAssetsGroup *group)
    {
        __strong TGModernConversationController *strongSelf = weakSelf;
        if (strongSelf == nil)
            return;
        
        TGMediaFoldersController *mediaFoldersController = [[TGMediaFoldersController alloc] initWithIntent:TGModernMediaPickerControllerSendFileIntent];
        mediaFoldersController.photosPicked = photosPicked;
        mediaFoldersController.dismiss = dismiss;
        
        TGModernMediaPickerController *mediaPickerController = [[TGModernMediaPickerController alloc] initWithAssetsGroup:group intent:TGModernMediaPickerControllerSendFileIntent];
        mediaPickerController.shouldShowFileTipIfNeeded = !fromFileMenu;
        mediaPickerController.photosPicked = photosPicked;
        mediaPickerController.dismiss = dismiss;
        
        TGNavigationController *navigationController = [TGNavigationController navigationControllerWithControllers:@[ mediaFoldersController, mediaPickerController ]];
        
        if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad)
        {
            navigationController.presentationStyle = TGNavigationControllerPresentationStyleInFormSheet;
            navigationController.modalPresentationStyle = UIModalPresentationFormSheet;
        }
        
        [strongSelf presentViewController:navigationController animated:true completion:nil];
    };
    
    if ([[TGMediaPickerAssetsLibrary sharedLibrary] authorizationStatus] == TGMediaPickerAuthorizationStatusNotDetermined)
    {
        [[TGMediaPickerAssetsLibrary sharedLibrary] fetchAssetsGroupsWithCompletionBlock:^(NSArray *groups, __unused TGMediaPickerAuthorizationStatus status, __unused NSError *error)
        {
            TGDispatchOnMainThread(^
            {
                if (![TGAccessChecker checkPhotoAuthorizationStatusForIntent:TGPhotoAccessIntentRead alertDismissCompletion:nil])
                    return;

                TGMediaPickerAssetsGroup *cameraRollGroup = nil;
                for (TGMediaPickerAssetsGroup *group in groups)
                {
                    if (group.isCameraRoll)
                    {
                        cameraRollGroup = group;
                        break;
                    }
                }

                showMediaPicker(cameraRollGroup);
            });
        }];
    }
    else
    {
        showMediaPicker(nil);
    }
}

- (void)imagePickerController:(TGImagePickerController *)__unused imagePicker didFinishPickingWithAssets:(NSArray *)assets
{
    NSMutableArray *imageDescriptions = [[NSMutableArray alloc] init];
    
    for (id abstractAsset in assets)
    {
        if ([abstractAsset isKindOfClass:[UIImage class]])
        {
            @autoreleasepool
            {
                NSDictionary *imageDescription = [_companion imageDescriptionFromImage:abstractAsset caption:nil optionalAssetUrl:nil];
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
                    NSDictionary *imageDescription = [_companion imageDescriptionFromImage:image caption:nil optionalAssetUrl:nil];
                    if (imageDescription != nil)
                        [imageDescriptions addObject:imageDescription];
                }
            }
        }
    }
    
    if (imageDescriptions.count != 0)
        [_companion controllerWantsToSendImagesWithDescriptions:imageDescriptions asReplyToMessageId:[self currentReplyMessageId]];
    
    [self dismissViewControllerAnimated:true completion:nil];
}


- (void)legacyCameraControllerCompletedWithDocument:(NSURL *)fileUrl fileName:(NSString *)fileName mimeType:(NSString *)mimeType
{
    [self dismissViewControllerAnimated:true completion:nil];
    
    [_companion controllerWantsToSendDocumentWithTempFileUrl:fileUrl fileName:fileName mimeType:mimeType asReplyToMessageId:[self currentReplyMessageId]];
}

- (void)_displayPhotoPicker
{
    if (![TGAccessChecker checkPhotoAuthorizationStatusForIntent:TGPhotoAccessIntentRead alertDismissCompletion:nil])
        return;
    
    __weak TGModernConversationController *weakSelf = self;
    void(^photosPicked)(TGModernMediaPickerController *) = ^(TGModernMediaPickerController *sender)
    {
        __strong TGModernConversationController *strongSelf = weakSelf;
        if (strongSelf == nil)
            return;
        
        [strongSelf _asyncProcessMediaAssetSignals:[sender selectedItemSignals:^id (UIImage *image, NSString *caption, NSString *maybeHash)
        {
            if (image != nil)
            {
                id description = [strongSelf.companion imageDescriptionFromImage:image caption:caption optionalAssetUrl:maybeHash == nil ? nil : [[NSString alloc] initWithFormat:@"image-%@", maybeHash]];
                return description;
            }
            return nil;
        }] forIntent:TGModernMediaPickerControllerSendPhotoIntent];
    };
    
    void(^dismiss)(void) = ^
    {
        __strong TGModernConversationController *strongSelf = weakSelf;
        if (strongSelf == nil)
            return;
        
        [strongSelf dismissViewControllerAnimated:true completion:nil];
    };
    
    SSignal *(^userListSignal)(NSString *) = ^SSignal *(NSString *mention)
    {
        __strong TGModernConversationController *strongSelf = weakSelf;
        if (strongSelf == nil)
            return nil;
        
        return [strongSelf->_companion userListForMention:mention];
    };
    
    SSignal *(^hashtagListSignal)(NSString *) = ^SSignal *(NSString *hashtag)
    {
        __strong TGModernConversationController *strongSelf = weakSelf;
        if (strongSelf == nil)
            return nil;
        
        return [strongSelf->_companion hashtagListForHashtag:hashtag];
    };
    
    void (^showMediaPicker)(TGMediaPickerAssetsGroup *) = ^(TGMediaPickerAssetsGroup *group)
    {
        __strong TGModernConversationController *strongSelf = weakSelf;
        if (strongSelf == nil)
            return;
        
        TGMediaFoldersController *mediaFoldersController = [[TGMediaFoldersController alloc] initWithIntent:TGModernMediaPickerControllerSendPhotoIntent];
        mediaFoldersController.photosPicked = photosPicked;
        mediaFoldersController.dismiss = dismiss;
        mediaFoldersController.userListSignal = userListSignal;
        mediaFoldersController.hashtagListSignal = hashtagListSignal;
        mediaFoldersController.disallowCaptions = ![strongSelf->_companion allowCaptionedMedia];
        
        TGModernMediaPickerController *mediaPickerController = [[TGModernMediaPickerController alloc] initWithAssetsGroup:group intent:TGModernMediaPickerControllerSendPhotoIntent];
        mediaPickerController.photosPicked = photosPicked;
        mediaPickerController.dismiss = dismiss;
        mediaPickerController.userListSignal = userListSignal;
        mediaPickerController.hashtagListSignal = hashtagListSignal;
        mediaPickerController.disallowCaptions = ![strongSelf->_companion allowCaptionedMedia];
        
        TGNavigationController *navigationController = [TGNavigationController navigationControllerWithControllers:@[ mediaFoldersController, mediaPickerController ]];
        
        if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad)
        {
            navigationController.presentationStyle = TGNavigationControllerPresentationStyleInFormSheet;
            navigationController.modalPresentationStyle = UIModalPresentationFormSheet;
        }
        
        [strongSelf presentViewController:navigationController animated:true completion:nil];
    };
    
    if ([[TGMediaPickerAssetsLibrary sharedLibrary] authorizationStatus] == TGMediaPickerAuthorizationStatusNotDetermined)
    {
        [[TGMediaPickerAssetsLibrary sharedLibrary] fetchAssetsGroupsWithCompletionBlock:^(NSArray *groups, __unused TGMediaPickerAuthorizationStatus status, __unused NSError *error)
        {
            TGDispatchOnMainThread(^
            {
                if (![TGAccessChecker checkPhotoAuthorizationStatusForIntent:TGPhotoAccessIntentRead alertDismissCompletion:nil])
                    return;
                
                TGMediaPickerAssetsGroup *cameraRollGroup = nil;
                for (TGMediaPickerAssetsGroup *group in groups)
                {
                    if (group.isCameraRoll)
                    {
                        cameraRollGroup = group;
                        break;
                    }
                }
                
                showMediaPicker(cameraRollGroup);
            });
        }];
    }
    else
    {
        showMediaPicker(nil);
    }
}

- (void)_displayWebImagePicker
{
    __weak TGModernConversationController *weakSelf = self;
    
    TGWebSearchController *searchController = [[TGWebSearchController alloc] init];
    searchController.disallowCaptions = ![_companion allowCaptionedMedia];
    searchController.dismiss = ^
    {
        __strong TGModernConversationController *strongSelf = weakSelf;
        if (strongSelf == nil)
            return;
        
        [strongSelf dismissViewControllerAnimated:true completion:nil];
    };
    searchController.completion = ^(TGWebSearchController *sender)
    {
        __strong TGModernConversationController *strongSelf = weakSelf;
        if (strongSelf == nil)
            return;
        
        [strongSelf _asyncProcessMediaAssetSignals:[sender selectedItemSignals:^id (id item, NSString *caption)
        {
            if (item != nil)
            {
                if ([item isKindOfClass:[TGBingSearchResultItem class]])
                {
                    id description = [strongSelf.companion imageDescriptionFromBingSearchResult:item caption:caption];
                    return description;
                }
                else if ([item isKindOfClass:[TGGiphySearchResultItem class]])
                {
                    id description = [strongSelf.companion documentDescriptionFromGiphySearchResult:item];
                    return description;
                }
                else if ([item isKindOfClass:[TGWebSearchInternalImageResult class]])
                {
                    id description = [strongSelf.companion imageDescriptionFromInternalSearchImageResult:item caption:caption];
                    return description;
                }
                else if ([item isKindOfClass:[TGWebSearchInternalGifResult class]])
                {
                    id description = [strongSelf.companion documentDescriptionFromInternalSearchResult:item];
                    return description;
                }
                else if ([item isKindOfClass:[UIImage class]])
                {
                    id description = [strongSelf.companion imageDescriptionFromImage:item caption:caption optionalAssetUrl:nil];
                    return description;
                }
            }
            return nil;
        }] forIntent:TGModernMediaPickerControllerSendPhotoIntent];
    };
    
    TGNavigationController *navigationController = [TGNavigationController navigationControllerWithControllers:@[ searchController ]];
    
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad)
    {
        navigationController.presentationStyle = TGNavigationControllerPresentationStyleInFormSheet;
        navigationController.modalPresentationStyle = UIModalPresentationFormSheet;
    }
    
    [self presentViewController:navigationController animated:true completion:nil];
}

- (void)legacyCameraControllerCapturedVideoWithTempFilePath:(NSString *)tempVideoFilePath fileSize:(int32_t)fileSize previewImage:(UIImage *)previewImage duration:(NSTimeInterval)duration dimensions:(CGSize)dimenstions assetUrl:(NSString *)assetUrl
{
    [self dismissViewControllerAnimated:true completion:nil];
    
    [_companion controllerWantsToSendLocalVideoWithTempFilePath:tempVideoFilePath fileSize:fileSize previewImage:previewImage duration:duration dimensions:dimenstions caption:nil assetUrl:assetUrl liveUploadData:nil asReplyToMessageId:[self currentReplyMessageId]];
}

- (void)legacyCameraControllerCompletedWithExistingMedia:(id)media
{
    [self dismissViewControllerAnimated:true completion:nil];
    
    if ([media isKindOfClass:[TGVideoMediaAttachment class]])
        [_companion controllerWantsToSendRemoteVideoWithMedia:media asReplyToMessageId:[self currentReplyMessageId]];
}

- (void)legacyCameraControllerCompletedWithNoResult
{
    [self dismissViewControllerAnimated:true completion:nil];
}

- (void)inputPanelRequestedSendImages:(TGModernConversationInputTextPanel *)__unused inputTextPanel images:(NSArray *)images
{
    __autoreleasing NSString *disabledMessage = nil;
    if (![TGApplicationFeatures isPhotoUploadEnabledForPeerType:[_companion applicationFeaturePeerType] disabledMessage:&disabledMessage])
    {
        [[[TGAlertView alloc] initWithTitle:TGLocalized(@"FeatureDisabled.Oops") message:disabledMessage cancelButtonTitle:TGLocalized(@"Common.OK") okButtonTitle:nil completionBlock:nil] show];
        return;
    }
    
    NSMutableArray *imageDescriptions = [[NSMutableArray alloc] init];
    
    for (id abstractAsset in images)
    {
        if ([abstractAsset isKindOfClass:[UIImage class]])
        {
            @autoreleasepool
            {
                NSDictionary *imageDescription = [_companion imageDescriptionFromImage:abstractAsset caption:nil optionalAssetUrl:nil];
                if (imageDescription != nil)
                    [imageDescriptions addObject:imageDescription];
            }
        }
    }
    
    if (imageDescriptions.count != 0)
        [_companion controllerWantsToSendImagesWithDescriptions:imageDescriptions asReplyToMessageId:[self currentReplyMessageId]];
}

- (void)inputPanelRequestedSendData:(TGModernConversationInputTextPanel *)__unused inputTextPanel data:(NSData *)data
{
    if (data != nil)
    {
        NSString *filePath = [NSTemporaryDirectory() stringByAppendingPathComponent:[[NSString alloc] initWithFormat:@"%x%x", (int)arc4random(), (int)arc4random()]];
        [data writeToFile:filePath atomically:true];
        
        [_companion controllerWantsToSendDocumentWithTempFileUrl:[NSURL fileURLWithPath:filePath] fileName:@"animation.gif" mimeType:@"image/gif" asReplyToMessageId:[self currentReplyMessageId]];
    }
}

- (void)inputPanelRequestedSendSticker:(TGModernConversationInputTextPanel *)__unused inputTextPanel sticker:(TGDocumentMediaAttachment *)sticker
{
    [self->_companion controllerWantsToSendRemoteDocument:sticker asReplyToMessageId:[self currentReplyMessageId]];
}

- (void)inputPanelRequestedActivateCommand:(TGModernConversationInputTextPanel *)__unused inputTextPanel command:(NSString *)command userId:(int32_t)__unused userId messageId:(int32_t)messageId
{
    int32_t replyMessageId = 0;
    if (((TGGenericModernConversationCompanion *)_companion).conversationId < 0)
        replyMessageId = messageId;
    if (_replyMarkup.hideKeyboardOnActivation && !_replyMarkup.alreadyActivated)
    {
        [self setReplyMarkup:[_replyMarkup activatedMarkup]];
        
        [TGDatabaseInstance() storeBotReplyMarkupActivated:_replyMarkup forPeerId:((TGGenericModernConversationCompanion *)_companion).conversationId];
    }
    [self->_companion controllerWantsToSendTextMessage:[[NSString alloc] initWithFormat:@"%@%@", @"", command] asReplyToMessageId:[self currentReplyMessageId] == 0 ? replyMessageId : [self currentReplyMessageId] withAttachedMessages:@[] disableLinkPreviews:false];
}

- (void)_displayContactPicker
{
    if (![TGAccessChecker checkAddressBookAuthorizationStatusWithAlertDismissComlpetion:nil])
        return;
    
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
    [_companion controllerWantsToSendContact:contactUser asReplyToMessageId:[self currentReplyMessageId]];
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

- (bool)inputPanelAudioRecordingEnabled:(TGModernConversationInputTextPanel *)__unused inputTextPanel
{
    __autoreleasing NSString *disabledMessage = nil;
    if (![TGApplicationFeatures isAudioUploadEnabledForPeerType:[_companion applicationFeaturePeerType] disabledMessage:&disabledMessage])
    {
        [[[TGAlertView alloc] initWithTitle:TGLocalized(@"FeatureDisabled.Oops") message:disabledMessage cancelButtonTitle:TGLocalized(@"Common.OK") okButtonTitle:nil completionBlock:nil] show];
        return false;
    }
    
    return true;
}

- (void)inputPanelAudioRecordingStart:(TGModernConversationInputTextPanel *)__unused inputTextPanel
{
    [self stopAudioRecording];
    [self stopInlineMediaIfPlaying];
    
    if (_currentAudioRecorder == nil)
    {
        _currentAudioRecorder = [[TGAudioRecorder alloc] initWithFileEncryption:[_companion encryptUploads]];
        _currentAudioRecorder.delegate = self;
        _currentAudioRecorder.activityHolder = [_companion acquireAudioRecordingActivityHolder];
        [_currentAudioRecorder start];
        
        [[UIApplication sharedApplication] setIdleTimerDisabled:true];
    }
}

- (void)inputPanelAudioRecordingCancel:(TGModernConversationInputTextPanel *)__unused inputTextPanel
{
    [self stopAudioRecording];
    [_inputTextPanel audioRecordingFinished];
    
    [[UIApplication sharedApplication] setIdleTimerDisabled:false];
}

- (void)inputPanelAudioRecordingComplete:(TGModernConversationInputTextPanel *)inputTextPanel
{
    if (_currentAudioRecorder != nil)
    {
        _currentAudioRecorder.delegate = nil;
        [_currentAudioRecorder finish:^(TGDataItem *dataItem, NSTimeInterval duration, TGLiveUploadActorData *liveData)
        {
            TGDispatchOnMainThread(^
            {
                if (dataItem != nil)
                {
                    [_companion controllerWantsToSendLocalAudioWithDataItem:dataItem duration:duration liveData:liveData asReplyToMessageId:[self currentReplyMessageId]];
                }
                else
                    [inputTextPanel shakeControls];
            });
        }];
        
        _currentAudioRecorder = nil;
        
        [_inputTextPanel audioRecordingFinished];
        
        if ([self shouldAutorotate])
            [TGViewController attemptAutorotation];
        
        [[UIApplication sharedApplication] setIdleTimerDisabled:false];
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

- (bool)inputPanelSendShouldBeAlwaysEnabled:(TGModernConversationInputTextPanel *)__unused inputTextPanel
{
    return [self currentForwardMessages].count != 0;
}

- (TGViewController *)inputPanelParentViewController:(TGModernConversationInputTextPanel *)__unused inputTextPanel
{
    return self;
}

- (void)inputPanelToggleBroadcastMode:(TGModernConversationInputTextPanel *)__unused inputTextPanel {
    [_companion _toggleBroadcastMode];
}

- (void)_enterEditingMode:(int32_t)animateFromMessageId
{
    if (!_editingMode)
    {
        [self setCurrentTitlePanel:nil animation:TGModernConversationPanelAnimationSlide];
        
        [_companion clearCheckedMessages];
        [_companion setMessageChecked:animateFromMessageId checked:true];
        
        for (TGModernCollectionCell *cell in _collectionView.visibleCells)
        {
            TGMessageModernConversationItem *messageItem = cell.boundItem;
            [messageItem setTemporaryHighlighted:false viewStorage:_viewStorage];
        }
        
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
        
        [self setLeftBarButtonItem:[[UIBarButtonItem alloc] initWithTitle:[_companion canDeleteAllMessages] ? TGLocalized(@"Conversation.ClearAll") : @"" style:UIBarButtonItemStylePlain target:self action:@selector(clearAllButtonPressed)] animated:true];
        [self setRightBarButtonItem:[[UIBarButtonItem alloc] initWithTitle:TGLocalized(@"Common.Cancel") style:UIBarButtonItemStylePlain target:self action:@selector(doneButtonPressed)] animated:true];
        
        TGModernConversationEditingPanel *editPanel = [[TGModernConversationEditingPanel alloc] initWithFrame:CGRectMake(0.0f, 0.0f, _view.frame.size.width, 0.0f)];
        editPanel.delegate = self;
        [editPanel setForwardingEnabled:[_companion allowMessageForwarding]];
        [editPanel setDeleteEnabled:[self canDeleteSelectedMessages]];
        [self setInputPanel:editPanel animated:true];
        [self _updateEditingPanel];
        
        [_titleView setEditingMode:true animated:true];
    }
}

- (bool)canDeleteSelectedMessages {
    if ([_companion canDeleteMessages]) {
        return true;
    }
    
    NSArray *checkedMessageIds = [_companion checkedMessageIds];
    
    for (TGMessageModernConversationItem *item in _items) {
        int32_t mid = item->_message.mid;
        for (NSNumber *nMid in checkedMessageIds) {
            if ([nMid intValue] == mid) {
                if (![_companion canDeleteMessage:item->_message]) {
                    return false;
                }
                
                break;
            }
        }
    }
    return true;
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
        
        [self setInputPanel:_customInputPanel != nil ? _customInputPanel : [self defaultInputPanel] animated:animated];
        
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
    if ([_companion canDeleteAllMessages]) {
        ASHandle *actionHandle = _actionHandle;
        [[[TGAlertView alloc] initWithTitle:nil message:TGLocalized(@"Conversation.ClearAllConfirmation") cancelButtonTitle:TGLocalized(@"Common.Cancel") okButtonTitle:TGLocalized(@"Common.OK") completionBlock:^(bool okButtonPressed)
        {
            if (okButtonPressed)
                [actionHandle requestAction:@"clearAllMessages" options:nil];
        }] show];
    }
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
    
    //[self _deleteItemsAtIndices:indexSet animated:true animationFactor:1.0f];
    //[self _leaveEditingModeAnimated:true];
    
    [_companion _deleteMessages:checkedMessageIds animated:true];
    
    __weak TGModernConversationController *weakSelf = self;
    [_companion controllerDeletedMessages:checkedMessageIds completion:^
    {
        __strong TGModernConversationController *strongSelf = weakSelf;
        if (strongSelf != nil)
        {
            [strongSelf _leaveEditingModeAnimated:true];
        }
    }];
}

- (void)doneButtonPressed
{
    [self _leaveEditingModeAnimated:true];
}

- (void)unseenMessagesButtonPressed
{
    if (_scrollBackMessageId != 0)
    {
        int32_t messageId = _scrollBackMessageId;
        _scrollBackMessageId = 0;
        _hasUnseenMessagesBelow = false;
        [self setScrollBackButtonVisible:false];
        
        [_companion navigateToMessageId:messageId scrollBackMessageId:0 animated:true];
    }
    else
    {
        if (_enableBelowHistoryRequests)
            [_companion _performFastScrollDown:false];
        else
        {
            if (_collectionView.contentOffset.y > -_collectionView.contentInset.top)
            {
                [_collectionView setContentOffset:CGPointMake(0.0f, -_collectionView.contentInset.top) animated:true];
                _scrollingToBottom = @true;
            }
        }
    }
}

#pragma mark -

- (void)inputPanelWillChangeHeight:(TGModernConversationInputPanel *)inputPanel height:(CGFloat)height duration:(NSTimeInterval)duration animationCurve:(int)animationCurve
{
    if (inputPanel == _currentInputPanel)
    {
        [_currentInputPanel adjustForSize:_view.bounds.size keyboardHeight:_keyboardHeight duration:duration animationCurve:animationCurve];
        [self _adjustCollectionViewForSize:_view.bounds.size keyboardHeight:_keyboardHeight inputContainerHeight:height duration:duration animationCurve:0];
    }
}

- (void)_adjustCollectionViewForSize:(CGSize)size keyboardHeight:(CGFloat)keyboardHeight inputContainerHeight:(CGFloat)inputContainerHeight duration:(NSTimeInterval)duration animationCurve:(int)animationCurve
{
    [self _adjustCollectionViewForSize:size keyboardHeight:keyboardHeight inputContainerHeight:inputContainerHeight scrollToBottom:false duration:duration animationCurve:animationCurve];
}

- (void)_adjustCollectionViewForSize:(CGSize)__unused size keyboardHeight:(CGFloat)keyboardHeight inputContainerHeight:(CGFloat)inputContainerHeight scrollToBottom:(bool)scrollToBottom duration:(NSTimeInterval)duration animationCurve:(int)animationCurve
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
        [UIView animateWithDuration:duration delay:0 options:(animationCurve << 16) | UIViewAnimationOptionBeginFromCurrentState animations:^
        {
            //[_collectionView setDelayVisibleItemsUpdate:originalInset.top < inset.top && (iosMajorVersion() < 7 || iosMajorVersion() >= 8)];
            bool decorationViewUpdatesWereDisabled = [_collectionView disableDecorationViewUpdates];
            [_collectionView setDisableDecorationViewUpdates:decorationViewUpdatesWereDisabled || originalInset.top < inset.top];
            
            _collectionView.contentInset = inset;
            if (!CGPointEqualToPoint(contentOffset, originalContentOffset))
            {
                [_collectionView setBounds:CGRectMake(0, contentOffset.y, _collectionView.frame.size.width, _collectionView.frame.size.height)];
            }

            [self _updateUnseenMessagesButton];
            [_collectionView setDelayVisibleItemsUpdate:false];
            [_collectionView setDisableDecorationViewUpdates:decorationViewUpdatesWereDisabled];
            
            if (!decorationViewUpdatesWereDisabled)
                [_collectionView updateHeaderView];
            
            [_emptyListPlaceholder adjustLayoutForSize:_view.bounds.size contentInsets:UIEdgeInsetsMake(_collectionView.contentInset.bottom - 210.0f - [_collectionView implicitTopInset], 0.0f, _collectionView.contentInset.top, 0.0f) duration:0.0 curve:0];
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
        _collectionView.contentInset = inset;
        if (!CGPointEqualToPoint(contentOffset, originalContentOffset))
            [_collectionView setBounds:CGRectMake(0, contentOffset.y, _collectionView.frame.size.width, _collectionView.frame.size.height)];
        
        [self _updateUnseenMessagesButton];
        
        [_emptyListPlaceholder adjustLayoutForSize:_view.bounds.size contentInsets:UIEdgeInsetsMake(_collectionView == nil ? self.controllerInset.top : (_collectionView.contentInset.bottom - 210.0f - [_collectionView implicitTopInset]), 0.0f, _collectionView == nil ? _currentInputPanel.frame.size.height : _collectionView.contentInset.top, 0.0f) duration:0.0 curve:0];
    }
}

- (void)keyboardWillHide:(NSNotification *)__unused notification
{
}

- (UIView *)keyboardView
{
    UIView *keyboardWindow = [TGHacks applicationKeyboardWindow];
    return keyboardWindow;
}

- (void)keyboardWillChangeFrame:(NSNotification *)notification
{
    if (_collectionView == nil)
        return;
    
    CGSize collectionViewSize = _view.frame.size;
    
    NSTimeInterval duration = notification.userInfo[UIKeyboardAnimationDurationUserInfoKey] == nil ? 0.3 : [notification.userInfo[UIKeyboardAnimationDurationUserInfoKey] doubleValue];
    int curve = [notification.userInfo[UIKeyboardAnimationCurveUserInfoKey] intValue];
    UIView *keyboardTransitionView = nil;
    if (_inputTextPanel.changingKeyboardMode)
    {
        keyboardTransitionView = [self keyboardView];
        duration = 0.2;
        curve = 7;
    }
    
    CGRect screenKeyboardFrame = [notification.userInfo[UIKeyboardFrameEndUserInfoKey] CGRectValue];
    CGRect keyboardFrame = [_view convertRect:screenKeyboardFrame fromView:nil];
    
    CGFloat keyboardHeight = (keyboardFrame.size.height <= FLT_EPSILON || keyboardFrame.size.width <= FLT_EPSILON) ? 0.0f :  (collectionViewSize.height - keyboardFrame.origin.y);
    
    _halfTransitionKeyboardHeight = keyboardFrame.size.height;
    
    if ((freedomUIKitTest3() && freedomUIKitTest3_1()) || [self viewControllerIsAnimatingAppearanceTransition] || [(TGNavigationController *)self.navigationController isInPopTransition] || [(TGNavigationController *)self.navigationController isInControllerTransition])
        return;
    
    if (_inputTextPanel.changingKeyboardMode && keyboardHeight < FLT_EPSILON)
        return;
    
    keyboardHeight = MAX(keyboardHeight, 0.0f);
    
    if (keyboardFrame.origin.y + keyboardFrame.size.height < collectionViewSize.height - FLT_EPSILON)
        keyboardHeight = 0.0f;
    
    if ( ABS(_keyboardHeight - keyboardHeight) < FLT_EPSILON && ABS(collectionViewSize.width - _collectionView.frame.size.width) < FLT_EPSILON)
        return;
    
    if (_inputTextPanel.changingKeyboardMode)
    {
        UIView *snapshotView = [keyboardTransitionView snapshotViewAfterScreenUpdates:false];
        [[TGHacks applicationKeyboardWindow] addSubview:snapshotView];
        
        CGFloat deltaHeight = keyboardHeight - _keyboardHeight;
        
        snapshotView.frame = CGRectOffset(snapshotView.frame, 0.0f, -deltaHeight);
        UIView *keyboardWindow = [TGHacks applicationKeyboardWindow];
        keyboardWindow.frame = CGRectOffset(keyboardWindow.frame, 0.0f, deltaHeight);
        
        [UIView animateWithDuration:0.2 delay:0.0 options:curve << 16 animations:^
        {
            snapshotView.alpha = 0.0f;
            keyboardWindow.frame = CGRectOffset(keyboardWindow.frame, 0.0f, -deltaHeight);
        } completion:^(__unused BOOL finished)
        {
            [snapshotView removeFromSuperview];
        }];
        
        if ([_inputTextPanel.maybeInputField.internalTextView.inputView isKindOfClass:[TGCommandKeyboardView class]])
        {
            //[(TGCommandKeyboardView *)_inputTextPanel.maybeInputField.internalTextView.inputView animateTransitionIn];
        }
    }
    
    if (ABS(_keyboardHeight - keyboardHeight) > FLT_EPSILON) {
        _keyboardHeight = keyboardHeight;
        
        if (ABS(collectionViewSize.width - _collectionView.frame.size.width) > FLT_EPSILON)
        {
            if (iosMajorVersion() >= 9) {
                [self _performSizeChangesWithDuration:0.3 size:_view.bounds.size];
            } else {
                dispatch_async(dispatch_get_main_queue(), ^
                {
                    [self _performSizeChangesWithDuration:0.3 size:_view.bounds.size];
                });
            }
        }
        else
        {
            [_currentInputPanel adjustForSize:_view.bounds.size keyboardHeight:keyboardHeight duration:duration animationCurve:curve];
            [self _adjustCollectionViewForSize:_view.bounds.size keyboardHeight:keyboardHeight inputContainerHeight:_currentInputPanel.frame.size.height duration:duration animationCurve:curve];
        }
    }
}

- (void)keyboardDidChangeFrame:(NSNotification *)notification
{
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad && notification.userInfo[UIKeyboardAnimationDurationUserInfoKey] == nil)
    {
        CGSize collectionViewSize = _view.frame.size;
        
        NSTimeInterval duration = 0.3;
        int curve = [notification.userInfo[UIKeyboardAnimationCurveUserInfoKey] intValue];
        CGRect screenKeyboardFrame = [notification.userInfo[UIKeyboardFrameEndUserInfoKey] CGRectValue];
        CGRect keyboardFrame = [_view convertRect:screenKeyboardFrame fromView:nil];
        
        CGFloat keyboardHeight = (keyboardFrame.size.height <= FLT_EPSILON || keyboardFrame.size.width <= FLT_EPSILON) ? 0.0f :  (collectionViewSize.height - keyboardFrame.origin.y);
        
        if (keyboardFrame.origin.y + keyboardFrame.size.height < collectionViewSize.height - FLT_EPSILON)
            keyboardHeight = 0.0f;
        
        _keyboardHeight = keyboardHeight;
        
        [_currentInputPanel adjustForSize:_view.bounds.size keyboardHeight:keyboardHeight duration:duration animationCurve:curve];
        [self _adjustCollectionViewForSize:_view.bounds.size keyboardHeight:keyboardHeight inputContainerHeight:_currentInputPanel.frame.size.height duration:duration animationCurve:curve];
    }
}

- (void)_performSizeChangesWithDuration:(NSTimeInterval)duration size:(CGSize)size
{
    bool animated = duration > DBL_EPSILON;
    CGSize collectionViewSize = size;
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
    
    [_currentInputPanel changeToSize:size keyboardHeight:keyboardHeight duration:duration];
    
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
    
    int collectionItemCount = (int)_items.count;
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
    
    _collectionView.frame = CGRectMake(0, -210.0f, collectionViewSize.width, collectionViewSize.height + 210.0f);
    [_companion _setControllerWidthForItemCalculation:_collectionView.frame.size.width];
    
    [_collectionLayout invalidateLayout];
    
    UIEdgeInsets originalInset = _collectionView.contentInset;
    UIEdgeInsets inset = originalInset;
    inset.top = keyboardHeight + _currentInputPanel.frame.size.height;
    inset.bottom = self.controllerInset.top + 210.0f + [_collectionView implicitTopInset];
    _collectionView.contentInset = inset;
    [self _updateUnseenMessagesButton];
    
    [_emptyListPlaceholder adjustLayoutForSize:size contentInsets:UIEdgeInsetsMake(_collectionView.contentInset.bottom - 210.0f - [_collectionView implicitTopInset], 0.0f, _collectionView.contentInset.top, 0.0f) duration:duration curve:0];
    
    CGFloat newContentHeight = 0.0f;
    std::vector<TGDecorationViewAttrubutes> newDecorationAttributes;
    NSArray *newLayoutAttributes = [_collectionLayout layoutAttributesForItems:_items containerWidth:_collectionView.frame.size.width maxHeight:FLT_MAX decorationViewAttributes:&newDecorationAttributes contentHeight:&newContentHeight];
    
    CGPoint newContentOffset = _collectionView.contentOffset;
    newContentOffset.y = - _collectionView.contentInset.top;
    if (anchorItemIndex >= 0 && anchorItemIndex < (int)newLayoutAttributes.count)
    {
        UICollectionViewLayoutAttributes *attributes = newLayoutAttributes[anchorItemIndex];
        newContentOffset.y += attributes.frame.origin.y - CGFloor(anchorItemRelativeOffset * attributes.frame.size.height);
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
        {
            [_companion controllerWantsToSendMapWithLatitude:[options[@"latitude"] doubleValue] longitude:[options[@"longitude"] doubleValue] venue:nil asReplyToMessageId:[self currentReplyMessageId]];
        }
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
                if (menuMessageItem != nil)
                {
                    NSString *text = nil;
                    if (menuMessageItem->_message.text.length != 0)
                    {
                        text = menuMessageItem->_message.text;
                    }
                    else
                    {
                        for (TGMediaAttachment *attachment in menuMessageItem->_message.mediaAttachments)
                        {
                            if ([attachment isKindOfClass:[TGImageMediaAttachment class]])
                            {
                                TGImageMediaAttachment *imageAttachment = (TGImageMediaAttachment *)attachment;
                                if (imageAttachment.caption.length != 0)
                                    text = imageAttachment.caption;
                            }
                        }
                    }
                    if (text.length > 0)
                    {
                        UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];
                        [pasteboard setString:text];
                    }
                }
            }
            else if ([menuAction isEqualToString:@"delete"])
            {
                if (menuMessageItem != nil && index >= 0)
                {
                    [_companion controllerDeletedMessages:@[@(mid)] completion:nil];
                }
            }
            else if ([menuAction isEqualToString:@"reply"])
            {
                if (menuMessageItem != nil)
                {
                    _inputTextPanel.inputField.internalTextView.enableFirstResponder = true;
                    [self setReplyMessage:menuMessageItem->_message animated:true];
                    if (_currentInputPanel == _inputTextPanel && menuMessageItem->_message.replyMarkup.rows.count == 0)
                        [self openKeyboard];
                }
            }
            else if ([menuAction isEqualToString:@"forward"])
                [_companion controllerWantsToForwardMessages:@[@(mid)]];
            else if ([menuAction isEqualToString:@"stickerPackInfo"])
            {
                id<TGStickerPackReference> packReference = nil;
                for (id attachment in menuMessageItem->_message.mediaAttachments)
                {
                    if ([attachment isKindOfClass:[TGDocumentMediaAttachment class]])
                    {
                        for (id attribute in ((TGDocumentMediaAttachment *)attachment).attributes)
                        {
                            if ([attribute isKindOfClass:[TGDocumentAttributeSticker class]])
                            {
                                packReference = ((TGDocumentAttributeSticker *)attribute).packReference;
                            }
                        }
                        break;
                    }
                }
                
                if (packReference != nil)
                {
                    TGProgressWindow *progressWindow = [[TGProgressWindow alloc] init];
                    [progressWindow show:true];
                    
                    SSignal *stickerPackInfo = [TGStickersSignals stickerPackInfo:packReference];
                    SSignal *currentStickerPacks = [[TGStickersSignals stickerPacks] take:1];
                    SSignal *combinedSignal = [SSignal combineSignals:@[stickerPackInfo, currentStickerPacks]];
                    
                    [[[combinedSignal deliverOn:[SQueue mainQueue]] onDispose:^
                    {
                        TGDispatchOnMainThread(^
                        {
                            [progressWindow dismiss:true];
                        });
                    }] startWithNext:^(NSArray *combined)
                    {
                        [TGAppDelegateInstance previewStickerPack:combined[0] currentStickerPacks:combined[1][@"packs"]];
                    } error:^(__unused id error)
                    {
                        
                    } completed:nil];
                }
            }
            else if ([menuAction isEqualToString:@"select"])
                [self _enterEditingMode:mid];
            else if ([menuAction isEqualToString:@"share"])
            {
                if (menuMessageItem != nil)
                {
                    NSURL *fileUrl = nil;
                    for (id attachment in menuMessageItem->_message.mediaAttachments)
                    {
                        if ([attachment isKindOfClass:[TGDocumentMediaAttachment class]])
                        {
                            NSString *localFilePath = [[_companion fileUrlForDocumentMedia:attachment] path];
                            if ([[NSFileManager defaultManager] fileExistsAtPath:localFilePath isDirectory:NULL])
                                fileUrl = [_companion fileUrlForDocumentMedia:attachment];
                            break;
                        }
                    }
                    
                    if (fileUrl != nil)
                    {
                        CGRect messageRect = CGRectZero;
                        
                        for (TGModernCollectionCell *cell in _collectionView.visibleCells)
                        {
                            TGMessageModernConversationItem *messageItem = cell.boundItem;
                            if (messageItem != nil && messageItem->_message.mid == mid)
                            {
                                CGRect contentFrame = [[cell contentViewForBinding] convertRect:[messageItem effectiveContentFrame] toView:_view];
                                if (CGRectIsNull(contentFrame) || CGRectIsEmpty(contentFrame))
                                    break;
                                
                                contentFrame = CGRectIntersection(contentFrame, CGRectMake(0, 0, _view.frame.size.width, _currentInputPanel.frame.origin.y));
                                if (CGRectIsNull(contentFrame) || CGRectIsEmpty(contentFrame))
                                    break;
                                
                                messageRect = contentFrame;
                            }
                        }
                        
                        _interactionController = [UIDocumentInteractionController interactionControllerWithURL:fileUrl];
                        _interactionController.delegate = self;
                        _interactionController.UTI = [self utiForFileExtension:[[fileUrl pathExtension] lowercaseString]];
                        [_interactionController presentOptionsMenuFromRect:messageRect inView:_view animated:true];
                    }
                }
            }
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

- (NSString *)utiForFileExtension:(NSString *)extension
{
    if ([extension isEqualToString:@"jpg"] || [extension isEqualToString:@"jpeg"])
        return @"public.jpeg";
    else if ([extension isEqualToString:@"png"])
        return @"public.png";
    return @"public.data";
}

- (void)userActivityWasContinued:(NSUserActivity *)userActivity
{
    TGDispatchOnMainThread(^
    {
        if (userActivity == _currentActivity)
        {
        }
    });
}

- (void)userActivity:(NSUserActivity *)userActivity didReceiveInputStream:(NSInputStream *)__unused inputStream outputStream:(NSOutputStream *)__unused outputStream
{
    TGDispatchOnMainThread(^
    {
        if (userActivity == _currentActivity)
        {
            [self setInputText:@"" replace:true];
        }
    });
}

- (void)openEmbed:(TGWebPageMediaAttachment *)webPage
{
    if ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPad) {
        return;
    }
    
    [self.view endEditing:true];
    
    __weak TGModernConversationController *weakSelf = self;
    _attachmentSheetWindow = [[TGAttachmentSheetWindow alloc] init];
    _attachmentSheetWindow.dismissalBlock = ^
    {
        __strong TGModernConversationController *strongSelf = weakSelf;
        if (strongSelf == nil)
            return;
        
        strongSelf->_attachmentSheetWindow.rootViewController = nil;
        strongSelf->_attachmentSheetWindow = nil;
    };
    
    NSMutableArray *items = [[NSMutableArray alloc] init];
    
    TGAttachmentSheetEmbedItemView *embedView = [[TGAttachmentSheetEmbedItemView alloc] initWithWebPage:webPage];
    [items addObject:embedView];
    
    [items addObject:[[TGAttachmentSheetButtonItemView alloc] initWithTitle:TGLocalized(@"Web.OpenExternal") pressed:^
    {
        __strong TGModernConversationController *strongSelf = weakSelf;
        if (strongSelf != nil)
        {
            [strongSelf->_attachmentSheetWindow dismissAnimated:true completion:nil];
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:webPage.url]];
        }
    }]];
    
    [items addObject:[[TGAttachmentSheetButtonItemView alloc] initWithTitle:TGLocalized(@"Web.CopyLink") pressed:^
    {
        __strong TGModernConversationController *strongSelf = weakSelf;
        if (strongSelf != nil)
        {
            [strongSelf->_attachmentSheetWindow dismissAnimated:true completion:nil];
            [[UIPasteboard generalPasteboard] setString:webPage.url];
        }
    }]];
    
    TGAttachmentSheetButtonItemView *cancelItem =[[TGAttachmentSheetButtonItemView alloc] initWithTitle:TGLocalized(@"Common.Cancel") pressed:^
    {
        __strong TGModernConversationController *strongSelf = weakSelf;
        if (strongSelf != nil)
            [strongSelf->_attachmentSheetWindow dismissAnimated:true completion:nil];
    }];
    
    [cancelItem setBold:true];
    [items addObject:cancelItem];
    
    _attachmentSheetWindow.view.items = items;
    _attachmentSheetWindow.windowLevel = UIWindowLevelNormal;
    [_attachmentSheetWindow showAnimated:true completion:nil];
    
    /*TGEmbedPreviewController *embedController = [[TGEmbedPreviewController alloc] initWithWebPage:webPage];
    TGOverlayControllerWindow *window = [[TGOverlayControllerWindow alloc] initWithParentController:self contentController:embedController];
    window.windowLevel = UIWindowLevelNormal;
    window.hidden = false;
    [self.view endEditing:true];*/
}

- (void)hideKeyboard
{
    [_inputTextPanel.maybeInputField resignFirstResponder];
}

- (void)activateSearch
{
    if (_searchBar == nil)
    {
        _searchBar = [[TGSearchBar alloc] initWithFrame:CGRectMake(0.0f, 20.0f, _view.frame.size.width, [TGSearchBar searchBarBaseHeight]) style:TGSearchBarStyleLight];
        _searchBar.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        _searchBar.delegate = self;
        [_searchBar setShowsCancelButton:true animated:false];
        [_searchBar setAlwaysExtended:true];
        _searchBar.placeholder = TGLocalized(@"Conversation.SearchPlaceholder");
        [_searchBar sizeToFit];
        _searchBar.delayActivity = false;
        [_view insertSubview:_searchBar aboveSubview:_collectionView];
        
        __weak TGModernConversationController *weakSelf = self;
        _searchPanel = [[TGModernConversationSearchInputPanel alloc] init];
        _searchPanel.next = ^
        {
            __strong TGModernConversationController *strongSelf = weakSelf;
            if (strongSelf != nil)
            {
                if (strongSelf->_searchResultsOffset + 1 < strongSelf->_searchResultsIds.count)
                    [strongSelf setSearchResultsOffset:strongSelf->_searchResultsOffset + 1];
            }
        };
        _searchPanel.previous = ^
        {
            __strong TGModernConversationController *strongSelf = weakSelf;
            if (strongSelf != nil)
            {
                if (strongSelf->_searchResultsIds.count != 0 && strongSelf->_searchResultsOffset > 0)
                    [strongSelf setSearchResultsOffset:strongSelf->_searchResultsOffset - 1];
            }
        };
        _searchPanel.done = ^
        {
            __strong TGModernConversationController *strongSelf = weakSelf;
            if (strongSelf != nil)
                [strongSelf searchBarCancelButtonClicked:(UISearchBar *)strongSelf->_searchBar];
        };
        _searchPanel.delegate = self;
    }
    _searchBar.hidden = false;
    
    [_searchPanel setInProgress:false];
    [_searchPanel setOffset:0 count:0];
    
    [self setCurrentTitlePanel:nil animation:TGModernConversationPanelAnimationSlideFar];
    [self setNavigationBarHidden:true withAnimation:TGViewControllerNavigationBarAnimationSlide];
    [self setCustomInputPanel:_searchPanel];
    
    [_searchBar becomeFirstResponder];
}

- (void)searchBar:(TGSearchBar *)__unused searchBar willChangeHeight:(CGFloat)__unused newHeight
{
}

- (void)searchBarCancelButtonClicked:(UISearchBar *)__unused searchBar
{
    _companion.viewContext.searchText = nil;
    for (TGMessageModernConversationItem *item in _items)
    {
        [item updateSearchText:true];
    }
    
    [_searchBar resignFirstResponder];
    [self setNavigationBarHidden:false withAnimation:TGViewControllerNavigationBarAnimationSlide];
    TGDispatchAfter(0.3, dispatch_get_main_queue(), ^
    {
        _searchBar.hidden = true;
        [_searchBar setText:@""];
    });
    
    [_searchPanel setInProgress:false];
    [self setCustomInputPanel:nil];
}

- (void)beginSearchWithQuery:(NSString *)query
{
    if (_searchDisposable == nil)
        _searchDisposable = [[SMetaDisposable alloc] init];
    
    _companion.viewContext.searchText = query.length == 0 ? nil : query;
    for (TGMessageModernConversationItem *item in _items)
    {
        [item updateSearchText:false];
    }
    
    _query = query;
    if (query.length == 0)
    {
        [_searchDisposable setDisposable:nil];
        [self setSearchResultsIds:nil];
        [_searchPanel setInProgress:false];
    }
    else
    {
        __weak TGModernConversationController *weakSelf = self;
        _searchBar.showActivity = true;
        [_searchPanel setInProgress:true];
        [_searchDisposable setDisposable:[[[[TGGlobalMessageSearchSignals searchMessages:query peerId:((TGGenericModernConversationCompanion *)_companion).conversationId accessHash:[_companion requestAccessHash] itemMapping:^id(id item)
        {
            if ([item isKindOfClass:[TGConversation class]])
            {
                TGConversation *conversation = item;
                return conversation;
            }
            return nil;
        }] deliverOn:[SQueue mainQueue]] onDispose:^
        {
            TGDispatchOnMainThread(^
            {
                __strong TGModernConversationController *strongSelf = weakSelf;
                if (strongSelf != nil)
                {
                    strongSelf->_searchBar.showActivity = false;
                    [strongSelf->_searchPanel setInProgress:false];
                }
            });
        }] startWithNext:^(id next)
        {
            __strong TGModernConversationController *strongSelf = weakSelf;
            if (strongSelf != nil)
            {
                NSMutableArray *searchResultsIds = [[NSMutableArray alloc] init];
                
                for (TGConversation *conversation in next)
                {
                    if (conversation.additionalProperties[@"searchMessageId"] != nil)
                    {
                        [searchResultsIds addObject:conversation.additionalProperties[@"searchMessageId"]];
                    }
                }
                [strongSelf setSearchResultsIds:searchResultsIds];
            }
        } error:^(__unused id error)
        {
        } completed:^
        {
        }]];
    }
    
    _searchPanel.isSearching = query.length != 0;
}

- (void)searchBar:(UISearchBar *)__unused searchBar textDidChange:(NSString *)searchText
{
    [self beginSearchWithQuery:searchText];
}

- (void)setSearchResultsIds:(NSArray *)searchResultIds
{
    bool previousHadResults = _searchResultsIds.count != 0;
    NSNumber *previousId = nil;
    if (_searchResultsIds.count != 0)
        previousId = _searchResultsIds[_searchResultsOffset];
    
    _searchResultsIds = searchResultIds;
    
    NSMutableSet *idsSet = [[NSMutableSet alloc] initWithArray:searchResultIds];
    
    NSUInteger offset = 0;
    
    if (_searchResultsIds.count != 0)
    {
        if (!previousHadResults)
            offset = 0;
        else if (previousId != nil && [idsSet containsObject:previousId])
            offset = [_searchResultsIds indexOfObject:previousId];
        else
        {
            NSArray *visibleCells = [_collectionView.visibleCells sortedArrayUsingComparator:^NSComparisonResult(UIView *view1, UIView *view2)
            {
                return view1.frame.origin.y > view2.frame.origin.y ? NSOrderedAscending : NSOrderedDescending;
            }];
            
            for (NSInteger topIndex = visibleCells.count / 2, bottomIndex = visibleCells.count / 2 + 1; topIndex >= 0 || bottomIndex < (NSInteger)visibleCells.count; topIndex--, bottomIndex++)
            {
                if (topIndex >= 0)
                {
                    TGMessageModernConversationItem *item = ((TGMessageModernConversationItem *)((TGModernCollectionCell *)visibleCells[topIndex]).boundItem);
                    if (item != nil)
                    {
                        NSNumber *nMid = @(item->_message.mid);
                        if ([idsSet containsObject:nMid])
                        {
                            offset = [searchResultIds indexOfObject:nMid];
                            break;
                        }
                    }
                }
                
                if (bottomIndex < (NSInteger)visibleCells.count)
                {
                    TGMessageModernConversationItem *item = ((TGMessageModernConversationItem *)((TGModernCollectionCell *)visibleCells[bottomIndex]).boundItem);
                    if (item != nil)
                    {
                        NSNumber *nMid = @(item->_message.mid);
                        if ([idsSet containsObject:nMid])
                        {
                            offset = [searchResultIds indexOfObject:nMid];
                            break;
                        }
                    }
                }
            }
        }
    }
    
    [self setSearchResultsOffset:offset];
}

- (void)setSearchResultsOffset:(NSUInteger)searchResultsOffset
{
    _searchResultsOffset = searchResultsOffset;
    if (_searchResultsIds.count != 0 && _searchResultsOffset < _searchResultsIds.count)
    {
        [_companion navigateToMessageId:[_searchResultsIds[_searchResultsOffset] intValue] scrollBackMessageId:0 animated:false];
    }
    
    [_searchPanel setOffset:_searchResultsOffset count:_searchResultsIds.count];
}

- (void)setInputDisabled:(bool)inputDisabled {
    _inputDisabled = inputDisabled;
    _inputTextPanel.inputDisabled = inputDisabled;
}

- (void)setIsChannel:(bool)isChannel {
    _isChannel = isChannel;
    _inputTextPanel.isChannel = isChannel;
}

- (void)updateControllerShouldHideInputTextByDefault {
    if (!_editingMode)
    {
        [self setInputPanel:_customInputPanel != nil ? _customInputPanel : [self defaultInputPanel] animated:ABS(CFAbsoluteTimeGetCurrent() - _willAppearTimestamp) > 0.18];
    }
}

- (BOOL)isEditing {
    return _editingMode;
}

- (void)check3DTouch {
    if (iosMajorVersion() >= 9) {
        if (self.traitCollection.forceTouchCapability == UIForceTouchCapabilityAvailable) {
            [self registerForPreviewingWithDelegate:(id)self sourceView:self.view];
        }
    }
}

- (UIViewController *)previewingContext:(id<UIViewControllerPreviewing>)__unused previewingContext viewControllerForLocation:(CGPoint)location {
    if (self.presentedViewController != nil) {
        return nil;
    }
    
    CGPoint collectionPoint = [self.view convertPoint:location toView:_collectionView];
    for (TGModernCollectionCell *cell in _collectionView.visibleCells) {
        if (CGRectContainsPoint(cell.frame, collectionPoint)) {
            TGMessageModernConversationItem *item = cell.boundItem;
            if (item != nil) {
                NSString *link = [(TGMessageViewModel *)item.viewModel linkAtPoint:[_collectionView convertPoint:collectionPoint toView:[cell contentViewForBinding]]];
                if ([link hasPrefix:@"http://"] || [link hasPrefix:@"https://"]) {
                    SFSafariViewController *controller = [[SFSafariViewController alloc] initWithURL:[NSURL URLWithString:link]];
                    return controller;
                }
            }
            
            break;
        }
    }
    
    return nil;
}

- (void)previewingContext:(id<UIViewControllerPreviewing>)__unused previewingContext commitViewController:(UIViewController *)viewControllerToCommit {
    [self presentViewController:viewControllerToCommit animated:true completion:nil];
}

@end
