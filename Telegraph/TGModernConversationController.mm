#import "TGModernConversationController.h"
#import <LegacyComponents/TGLocationSignals.h>

#import <LegacyComponents/LegacyComponentsGlobals.h>

#import <LegacyComponents/FreedomUIKit.h>
#import <LegacyComponents/TGPeerIdAdapter.h>

#import "TGLegacyComponentsContext.h"

#import "TGUpdateStateRequestBuilder.h"

#import "TGModernConversationCompanion.h"

#import <LegacyComponents/TGImagePickerController.h>
#import <LegacyComponents/TGPhotoVideoEditor.h>

#import "TGModernConversationCollectionView.h"
#import "TGModernConversationViewLayout.h"

#import "TGModernConversationItem.h"
#import "TGModernFlatteningViewModel.h"
#import "TGModernTemporaryView.h"

#import <LegacyComponents/TGImageUtils.h>
#import <LegacyComponents/TGPhoneUtils.h>
#import <LegacyComponents/TGStringUtils.h>
#import <LegacyComponents/TGFileUtils.h>
#import <LegacyComponents/TGFont.h>
#import <LegacyComponents/TGHacks.h>
#import <LegacyComponents/TGObserverProxy.h>
#import "TGCustomActionSheet.h"

#import <LegacyComponents/HPGrowingTextView.h>
#import <LegacyComponents/HPTextViewInternal.h>

#import "TGMessageModernConversationItem.h"
#import <LegacyComponents/TGMessage.h>

#import "TGAppDelegate.h"
#import "TGApplication.h"

#import "TGInterfaceManager.h"
#import "TGPresentation.h"
#import "TGPreviewPresentationHelper.h"

#import "TGModernConversationTitleView.h"
#import "TGModernConversationAvatarButton.h"
#import "TGModernConversationBarButtonItem.h"
#import "TGModernConversationInputTextPanel.h"
#import "TGModernConversationEditingPanel.h"
#import "TGModernConversationTitlePanel.h"
#import "TGModernConversationEmptyListPlaceholderView.h"
#import "TGModernConversationGenericTitlePanel.h"

#import <LegacyComponents/TGOverlayControllerWindow.h>
#import <LegacyComponents/TGModernGalleryController.h>
#import "TGGenericPeerMediaGalleryModel.h"
#import "TGGroupAvatarGalleryModel.h"
#import "TGGroupAvatarGalleryItem.h"
#import "TGSecretPeerMediaGalleryModel.h"
#import "TGSecretInfiniteLifetimePeerMediaGalleryModel.h"

#import "TGGenericPeerGalleryItem.h"
#import "TGGenericPeerMediaGalleryImageItem.h"
#import "TGGenericPeerMediaGalleryVideoItem.h"
#import "TGModernGalleryVideoItemView.h"
#import "TGModernGalleryNewVideoItemView.h"
#import "TGGenericPeerMediaGalleryVideoItemView.h"

#import "TGDropboxHelper.h"
#import "TGICloudItem.h"

#import <LegacyComponents/TGLocationViewController.h>
#import <LegacyComponents/TGLocationPickerController.h>
#import "TGWebSearchController.h"
#import <LegacyComponents/TGLegacyCameraController.h>
#import "TGDocumentController.h"
#import "TGWebPageController.h"
#import "TGForwardContactPickerController.h"
#import "TGVCardUserInfoController.h"
#import "TGAudioRecorder.h"
#import "TGModernConversationAudioPlayer.h"

#import <LegacyComponents/PGCamera.h>
#import <LegacyComponents/TGCameraPreviewView.h>
#import <LegacyComponents/TGCameraController.h>
#import <LegacyComponents/UIDevice+PlatformInfo.h>

#import "TGImageDownloadActor.h"
#import "TGVideoDownloadActor.h"
#import "TGPreparedRemoteImageMessage.h"
#import "TGMediaItem.h"
#import "TGDatabase.h"
#import "TGTelegraph.h"
#import "TGGenericModernConversationCompanion.h"
#import "TGPrivateModernConversationCompanion.h"

#import "TGModernConversationEmptyListPlaceholderView.h"

#import <LegacyComponents/TGRemoteImageView.h>

#import <LegacyComponents/TGMenuView.h>
#import "TGCustomAlertView.h"

#import "TGWallpaperManager.h"

#import <CommonCrypto/CommonDigest.h>
#import <AVFoundation/AVFoundation.h>
#import <MobileCoreServices/MobileCoreServices.h>
#import <PassKit/PassKit.h>

#import "TGGiphySearchResultItem.h"
#import "TGBingSearchResultItem.h"
#import "TGWebSearchInternalImageResult.h"
#import "TGWebSearchInternalGifResult.h"

#import "TGExternalGifSearchResultItem.h"
#import "TGInternalGifSearchResultItem.h"

#import "TGAttachmentSheetWindow.h"
#import "TGAttachmentSheetButtonItemView.h"

#import "ATQueue.h"

#import <LegacyComponents/TGProgressWindow.h>

#import "TGModernConversationControllerDynamicTypeSignals.h"
#import "TGMessageViewModel.h"
#import "TGNotificationMessageViewModel.h"

#import "TGModenConcersationReplyAssociatedPanel.h"
#import "TGStickerAssociatedInputPanel.h"
#import <LegacyComponents/TGModernConversationMentionsAssociatedPanel.h>
#import <LegacyComponents/TGModernConversationHashtagsAssociatedPanel.h>
#import "TGModernConversationForwardInputPanel.h"
#import "TGModernConversationWebPreviewInputPanel.h"

#import "TGExternalGalleryModel.h"
#import "TGGifGalleryModel.h"

#import "TGStickersSignals.h"
#import "TGMaskStickersSignals.h"

#import "TGCommandKeyboardView.h"

#import "TGModernConversationCommandsAssociatedPanel.h"
#import <LegacyComponents/TGModernConversationAlphacodeAssociatedPanel.h>

#import "TGEmbedPreviewController.h"

#import <LegacyComponents/TGSearchBar.h>

#import "TGGlobalMessageSearchSignals.h"

#import "TGModernConversationSearchInputPanel.h"

#import "TGAttachmentSheetEmbedItemView.h"

#import "TGModernDateHeaderView.h"

#import "TGModernConversationControllerView.h"

#import <LegacyComponents/TGMenuSheetController.h>
#import <LegacyComponents/TGAttachmentCameraView.h>
#import <LegacyComponents/TGAttachmentCarouselItemView.h>
#import "TGLoadingItemView.h"
#import "TGAttachmentFileTipView.h"
#import <LegacyComponents/TGMediaAssetsController.h>
#import "TGTelegramNetworking.h"

#import <SafariServices/SafariServices.h>

#import "TGSendMessageSignals.h"

#import "TGShareSheetView.h"
#import "TGShareSheetWindow.h"
#import "TGShareSheetSharePeersItemView.h"

#import "TGPreparedForwardedMessage.h"

#import "TGRecentGifsSignal.h"
#import "TGRecentStickersSignal.h"
#import "TGFavoriteStickersSignal.h"

#import "TGBotContextResults.h"

#import "TGModernConversationGenericContextResultsAssociatedPanel.h"
#import "TGModernConversationMediaContextResultsAssociatedPanel.h"
#import "TGModernConversationRestrictedInlineAssociatedPanel.h"

#import <LegacyComponents/TGBotContextResultAttachment.h>

#import "TGRecentContextBotsSignal.h"

#import "TGStickerKeyboardView.h"

#import "TGExternalImageSearchResult.h"
#import "TGExternalGifSearchResult.h"

#import "TGProgressAlert.h"

#import "TGBotContextMediaResult.h"
#import "TGBotContextExternalResult.h"

#import "TGBotContextResultSendMessageAuto.h"
#import "TGBotContextResultSendMessageText.h"
#import "TGBotContextResultSendMessageGeo.h"
#import "TGBotContextResultSendMessageContact.h"

#import "TGRaiseToListenActivator.h"

#import "TGModernConversationAudioPreviewInputPanel.h"

#import <LegacyComponents/TGKeyCommandController.h>
#import <LegacyComponents/TGPopoverController.h>

#import "TGMessageSearchSignals.h"

#import "TGChannelConversationCompanion.h"

#import "TGShareSheetWindow.h"
#import "TGShareSheetButtonItemView.h"
#import "TGAttachmentSheetCheckmarkVariantItemView.h"

#import "TGEmbedMenu.h"
#import "TGStickersMenu.h"
#import "TGShareMenu.h"
#import "TGOpenInMenu.h"

#import "TGPreviewMenu.h"

#import "TGConversationScrollMessageStack.h"

#import "TGModernConversationMediaContextResultsAssociatedPanel.h"
#import "TGModernConversationComplexMediaContextResultsAssociatedPanel.h"

#import <LegacyComponents/TGNavigationBar.h>

#import "TGFastCameraController.h"
#import <LegacyComponents/TGVideoMessageCaptureController.h>

#import "TGModernConversationEditingMessageInputPanel.h"

#import "TGConversationScrollButtonContainer.h"

#import "TGRecentPeersSignals.h"

#import "TGBotSignals.h"
#import "TGPeerInfoSignals.h"

#import "TGExternalShareSignals.h"

#import "TGWebAppController.h"

#import "TGPickerSheet.h"

#import "TGMessageSearchSignals.h"

#import "TGEmbedPIPController.h"
#import "TGInstantPageController.h"
#import "TGSharedMediaController.h"

#import <LegacyComponents/TGTooltipView.h>

#import "TGAdminLogConversationCompanion.h"
#import "TGFeedConversationCompanion.h"

#import <LegacyComponents/TGLocalization.h>

#import <LegacyComponents/TGModernConversationInputMicButton.h>

#import "TGChannelManagementSignals.h"

#import "TGCallController.h"

#import "TGSecretPeerMediaGalleryImageItem.h"
#import "TGSecretPeerMediaGalleryVideoItem.h"

#import <LegacyComponents/TGClipboardMenu.h>

#import <LegacyComponents/TGAlphacode.h>

#import "TGDownloadMessagesSignal.h"
#import "TGDownloadAudioSignal.h"

#import "TGMediaLiveUploadWatcher.h"

#import "TGLiveLocationSignals.h"
#import "TGScreenCaptureSignals.h"
#import "TGProxySignals.h"

NSInteger TGModernConversationControllerUnloadHistoryLimit = 500;
NSInteger TGModernConversationControllerUnloadHistoryThreshold = 200;

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

@interface TGModernConversationController () <UICollectionViewDataSource, TGModernConversationViewLayoutDelegate, UIViewControllerTransitioningDelegate, HPGrowingTextViewDelegate, UIGestureRecognizerDelegate, TGLegacyCameraControllerDelegate, TGModernConversationInputTextPanelDelegate, TGModernConversationEditingPanelDelegate, TGModernConversationTitleViewDelegate, TGForwardContactPickerControllerDelegate, TGAudioRecorderDelegate, NSUserActivityDelegate, UIDocumentInteractionControllerDelegate, UIDocumentPickerDelegate, TGImagePickerControllerDelegate, TGSearchBarDelegate, TGKeyCommandResponder>
{
    bool _alreadyHadWillAppear;
    bool _alreadyHadDidAppear;
    NSTimeInterval _willAppearTimestamp;
    bool _receivedWillDisappear;
    bool _didDisappearBeforeAppearing;
    NSString *_initialInputText;
    NSRange _initialSelectRange;
    NSArray *_initialForwardMessages;
    NSSet *_initialCompleteGroups;
    TGMessageEditingContext *_initialMessageEdigingContext;
    
    bool _shouldHaveTitlePanelLoaded;
    
    bool _editingMode;
    
    bool _bannedStickers;
    bool _bannedMedia;
    
    NSMutableArray *_items;
    
    NSMutableSet *_collectionRegisteredIdentifiers;
    
    TGViewController *_secondaryController;
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
    TGModernConversationInputPanel *_defaultInputPanel;
    
    UIView *_titlePanelWrappingView;
    TGModernConversationTitlePanel *_primaryTitlePanel;
    TGModernConversationTitlePanel *_secondaryTitlePanel;
    TGModernConversationTitlePanel *_currentTitlePanel;
    
    TGModernConversationEmptyListPlaceholderView *_emptyListPlaceholder;
    
    bool _isRotating;
    CGFloat _keyboardHeight;
    bool _collectionViewIgnoresNextKeyboardHeightChange;
    NSInteger _collectionViewDontStopNextScrollAnimation;
    TGObserverProxy *_keyboardWillChangeFrameProxy;
    TGObserverProxy *_keyboardDidChangeFrameProxy;
    
    TGObserverProxy *_applicationWillResignActiveProxy;
    TGObserverProxy *_applicationDidEnterBackgroundProxy;
    TGObserverProxy *_applicationDidBecomeActiveProxy;
    
    TGObserverProxy *_dropboxProxy;
    
    TGModernConversationTitleView *_titleView;
    TGModernConversationAvatarButton *_avatarButton;
    UIBarButtonItem *_avatarButtonItem;
    UIBarButtonItem *_infoButtonItem;
    
    TGMenuContainerView *_menuContainerView;
    TGMenuContainerView *_tooltipContainerView;
    SMetaDisposable *_tooltipDismissDisposable;
    
    TGConversationScrollButtonContainer *_scrollButtons;
    
    bool _disableScrollProcessing;
    
    bool _enableAboveHistoryRequests;
    bool _enableBelowHistoryRequests;
    
    bool _enableUnloadHistoryRequests;
    
    bool _canReadHistory;
    
    TGAudioRecorder *_currentAudioRecorder;
    bool _currentAudioRecorderIsTouchInitiated;
    
    NSUserActivity *_currentActivity;
    
    TGShareSheetWindow *_shareSheetWindow;
    UIDocumentInteractionController *_interactionController;
    
    TGICloudItemRequest *_currentICloudItemRequest;
    
    SDisposableSet *_disposable;
    
    int32_t _temporaryHighlightMessageIdUponDisplay;
    bool _hasUnseenMessagesBelow;
    
    int32_t _openMediaForMessageIdUponDisplay;
    int64_t _openMediaForPeerIdUponDisplay;
    bool _openedMediaIsEmbed;
    bool _cancelPIPForOpenedMedia;
    
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
    TGModernConversationMentionsAssociatedPanel *_searchMentionsPanel;
    
    NSString *_query;
    SMetaDisposable *_searchDisposable;
    NSArray *_searchResults;
    NSUInteger _searchResultsTotalCount;
    NSUInteger _searchResultsOffset;
    bool _loadingMoreSearchResults;
    
    int32_t _messageIdForVisibleHoleDirection;
    
    bool _loadingMessages;
    TGProgressWindowController *_loadingMessagesController;
    
    SMetaDisposable *_mentionTextResultsDisposable;
    SMetaDisposable *_recentGifsDisposable;
    NSTimeInterval _mentionTextResultsRequestTimestamp;
    NSString *_mentionTextResultsRequestMention;
    
    SMetaDisposable *_processMediaDisposable;
    TGProgressAlert *_progressAlert;
    
    TGAttachmentSheetWindow *_attachmentSheetWindow;
    
    SMetaDisposable *_inputPlaceholderForTextDisposable;
    __weak TGMenuSheetController *_menuController;
    __weak TGMenuSheetController *_contextMenuController;
    
    TGRaiseToListenActivator *_raiseToListenActivator;
    STimer *_raiseToListenRecordAfterPlaybackTimer;
    id<SDisposable> _playlistFinishedDisposable;
    
    SMetaDisposable *_saveEditedMessageDisposable;
    SMetaDisposable *_editingContextDisposable;
    
    SVariable *_currentEditingMessageContext;
    
    TGConversationScrollMessageStack *_scrollStack;
    bool _ignoreStackOperations;
    
    SMetaDisposable *_currentMentionDisposable;
    SMetaDisposable *_musicPlayerStatusDisposable;
    
    TGNavigationBar *_previewNavigationBar;
    
    __weak TGFastCameraController *_fastCameraController;
    __weak TGVideoMessageCaptureController *_videoMessageCaptureController;
    
    bool _fastScrolling;
    
    bool _doNotIgnoreKeyboardChangeDuringAppearance;
    TGPickerSheet *_pickerSheet;
    
    SMetaDisposable *_requestDateJumpDisposable;
    
    SVariable *_viewVisible;
    SPipe *_bindingPipe;
    TGMessageIndex *_positionMonitoredForMessageWithMid;
    void (^_visibilityChanged)(bool visible);
    
    CFAbsoluteTime _lastScrollTime;
    TGMessageIndex *_scrollToMid;
    SPipe *_scrollToFinishedPipe;
    
    TGTooltipContainerView *_recordTooltipContainerView;
    TGTooltipContainerView *_bannedStickersTooltipContainerView;
    TGTooltipContainerView *_bannedMediaTooltipContainerView;
    
    bool _keepDim;
    bool _pushedContents;
    UIButton *_topDimView;
    UIButton *_leftDimView;
    UIButton *_bottomDimView;
    UIButton *_rightDimView;
    UIView *_selectionSnapshotview;
    UIImpactFeedbackGenerator *_feedbackGenerator;
    
    CGPoint _keyboardDismissSwipeStartPosition;
    CGFloat _keyboardDismissOffset;
    
    bool _isRecording;
    
    SMetaDisposable *_callInForegroundDisposable;
    __weak UINavigationController *_weakNavController;
    
    NSString *_searchQuery;
    bool _searchingByName;
    TGUser *_searchingByNameUser;
    
    int32_t _initialUnreadMentionCount;
    SMetaDisposable *_loadEarliestUnseenMentionIdDisposable;
    
    id<SDisposable> _automaticReadDisposable;
    bool _atBottom;
    
    NSMutableSet<NSNumber *> *_readMentionsMessageIds;
}

@end

@implementation TGModernConversationController

- (instancetype)init
{
    self = [super init];
    if (self != nil)
    {
        _actionHandle = [[ASHandle alloc] initWithDelegate:self releaseOnMainThread:true];
        _requestDateJumpDisposable = [[SMetaDisposable alloc] init];
        
        self.automaticallyManageScrollViewInsets = false;
        self.adjustControllerInsetWhenStartingRotation = true;
        
        self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:TGLocalized(@"Common.Back") style:UIBarButtonItemStylePlain target:self action:@selector(backPressed)];
        
        _items = [[NSMutableArray alloc] init];
        
        _keyboardWillChangeFrameProxy = [[TGObserverProxy alloc] initWithTarget:self targetSelector:@selector(keyboardWillChangeFrame:) name:UIKeyboardWillChangeFrameNotification];
        _keyboardDidChangeFrameProxy = [[TGObserverProxy alloc] initWithTarget:self targetSelector:@selector(keyboardDidChangeFrame:) name:UIKeyboardDidChangeFrameNotification];
        
        _applicationWillResignActiveProxy = [[TGObserverProxy alloc] initWithTarget:self targetSelector:@selector(applicationWillResignActive:) name:UIApplicationWillResignActiveNotification];
        _applicationDidEnterBackgroundProxy = [[TGObserverProxy alloc] initWithTarget:self targetSelector:@selector(applicationDidEnterBackground:) name:UIApplicationDidEnterBackgroundNotification];
        _applicationDidBecomeActiveProxy = [[TGObserverProxy alloc] initWithTarget:self targetSelector:@selector(applicationDidBecomeActive:) name:UIApplicationDidBecomeActiveNotification];
        
        _titleView = [[TGModernConversationTitleView alloc] initWithFrame:CGRectMake(0, 0, 1, 1)];
        _titleView.delegate = self;
        [super setTitleView:_titleView];
        
        _avatarButton = [[TGModernConversationAvatarButton alloc] initWithFrame:CGRectMake(0, 0, 1, 1)];
        [_avatarButton addTarget:self action:@selector(avatarPressed) forControlEvents:UIControlEventTouchUpInside];
        _avatarButtonItem = [[TGModernConversationBarButtonItem alloc] initWithCustomView:_avatarButton];
        
        _canReadHistory = true;
        _enableUnloadHistoryRequests = true;
        
        self.dismissPresentedControllerWhenRemovedFromNavigationStack = true;
        
        _didDisappearBeforeAppearing = false;
        
        __weak TGModernConversationController *weakSelf = self;
        _disposable = [[SDisposableSet alloc] init];
        [_disposable add:[[TGPresentation fontSizeSignal] startWithNext:^(NSNumber *pointSize)
        {
            TGUpdateMessageViewModelLayoutConstants([pointSize floatValue]);
            
            __strong TGModernConversationController *strongSelf = weakSelf;
            if (strongSelf != nil)
                [strongSelf refreshMetrics];
        } error:nil completed:nil]];
        
        _processMediaDisposable = [[SMetaDisposable alloc] init];
        _inputPlaceholderForTextDisposable = [[SMetaDisposable alloc] init];
        _musicPlayerStatusDisposable = [[SMetaDisposable alloc] init];
        _tooltipDismissDisposable = [[SMetaDisposable alloc] init];
        _callInForegroundDisposable = [[SMetaDisposable alloc] init];
        _loadEarliestUnseenMentionIdDisposable = [[SMetaDisposable alloc] init];
        
        _scrollStack = [[TGConversationScrollMessageStack alloc] init];
        
        _bindingPipe = [[SPipe alloc] init];
        _scrollToFinishedPipe = [[SPipe alloc] init];
        _viewVisible = [[SVariable alloc] init];
        
        _callInForegroundDisposable = [[SMetaDisposable alloc] init];
        [_callInForegroundDisposable setDisposable:[[[TGInterfaceManager instance] callControllerInForeground] startWithNext:^(__unused id next) {
            __strong TGModernConversationController *strongSelf = weakSelf;
            if (strongSelf != nil && strongSelf->_inputTextPanel.isCustomKeyboardExpanded)
                [strongSelf->_inputTextPanel setCustomKeyboardExpanded:false animated:true];
        }]];
        
        [[[TGFavoriteStickersSignal favoriteStickers] take:1] startWithNext:nil];
        
        if (iosMajorVersion() >= 10)
            _feedbackGenerator = [[UIImpactFeedbackGenerator alloc] initWithStyle:UIImpactFeedbackStyleLight];
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
    
    if (_shareSheetWindow != nil)
        _shareSheetWindow.rootViewController = nil;
    
    [_tooltipDismissDisposable dispose];
    [_musicPlayerStatusDisposable dispose];
    [_mentionTextResultsDisposable dispose];
    [_recentGifsDisposable dispose];
    [_inputPlaceholderForTextDisposable dispose];
    [_processMediaDisposable dispose];
    [_playlistFinishedDisposable dispose];
    [_saveEditedMessageDisposable dispose];
    [_editingContextDisposable dispose];
    [_tooltipDismissDisposable dispose];
    [_requestDateJumpDisposable dispose];
    [_callInForegroundDisposable dispose];
    [_automaticReadDisposable dispose];
    [_loadEarliestUnseenMentionIdDisposable dispose];
    
    if (iosMajorVersion() >= 7)
        _weakNavController.interactivePopGestureRecognizer.enabled = true;
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
    UIEdgeInsets safeAreaInset = [self calculatedSafeAreaInset];
    
    _collectionLayout = [[TGModernConversationViewLayout alloc] init];
    _collectionLayout.viewStorage = _viewStorage;
    _collectionView = [[TGModernConversationCollectionView alloc] initWithFrame:CGRectMake(safeAreaInset.left, -210.0f, collectionViewSize.width - safeAreaInset.left - safeAreaInset.right, collectionViewSize.height + 210.0f) collectionViewLayout:_collectionLayout];
    if (iosMajorVersion() >= 11)
        _collectionView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
    _collectionView.hidden = _loadingMessages;
    [_companion _setControllerWidthForItemCalculation:_collectionView.frame.size.width];
    _collectionView.headerView = _conversationHeader;
    _collectionView.transform = CGAffineTransformMakeRotation((CGFloat)M_PI);
    _collectionView.backgroundColor = nil;
    _collectionView.opaque = false;
    _collectionView.scrollsToTop = false;
    _collectionView.dataSource = self;
    _collectionView.delegate = self;
    _collectionView.delaysContentTouches = false;
    
    if (iosMajorVersion() >= 8 && !TGIsPad())
    {
        UIPanGestureRecognizer *collectionPanRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(collectionViewPan:)];
        collectionPanRecognizer.delegate = self;
        [self.view addGestureRecognizer:collectionPanRecognizer];
    }
    
    _collectionView.unreadMessageRange = [_companion unreadMessageRange];
    
    _collectionView.alwaysBounceVertical = true;
    
    [_collectionView registerClass:[TGModernCollectionCell class] forCellWithReuseIdentifier:@"_empty"];
    
    UIEdgeInsets contentInset = _collectionView.contentInset;
    contentInset.bottom = self.controllerInset.top + 210.0f + [_collectionView implicitTopInset];
    contentInset.top = _keyboardHeight + [_currentInputPanel currentHeight];
    _ignoreStackOperations = true;
    _collectionView.contentInset = contentInset;
    [self _adjustCollectionInset];
    
    [_emptyListPlaceholder adjustLayoutForSize:collectionViewSize contentInsets:UIEdgeInsetsMake(_collectionView.contentInset.bottom - 210.0f - [_collectionView implicitTopInset], 0.0f, _collectionView.contentInset.top, 0.0f) duration:0.0f curve:0];
    
    [_view insertSubview:_collectionView atIndex:[self _indexForCollectionView]];
    [_view insertSubview:_emptyListPlaceholder aboveSubview:_collectionView];
    
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
        int64_t peerId = [_companion initialPositioningPeerId];
        TGInitialScrollPosition scrollPosition = [_companion initialPositioningScrollPosition];
        CGFloat scrollOffset = [_companion initialPositioningScrollOffset];
        if (messageId != 0)
        {
            _collectionView.contentOffset = CGPointMake(0.0f, [self contentOffsetForMessageId:messageId peerId:peerId scrollPosition:scrollPosition initial:true additionalOffset:(_companion.previewMode ? self.controllerInset.top : 0.0f) + scrollOffset]);
        }
    }
    
    [_collectionView layoutSubviews];
    _ignoreStackOperations = false;
    [self _updateVisibleItemIndices:nil];
    
    [self check3DTouch];
}

- (CGFloat)contentOffsetForMessageId:(int32_t)messageId peerId:(int64_t)peerId scrollPosition:(TGInitialScrollPosition)scrollPosition initial:(bool)__unused initial additionalOffset:(CGFloat)additionalOffset
{
    if (![_collectionLayout hasLayoutAttributes])
        [_collectionLayout prepareLayout];
    
    CGFloat contentOffsetY = _collectionView.contentOffset.y;
    int index = -1;
    for (TGMessageModernConversationItem *messageItem in _items)
    {
        index++;
        
        if (messageItem->_message.mid == messageId && (peerId == 0 || messageItem->_message.fromUid == peerId))
        {
            /*if (false && index == 0 && initial) {
             return -_collectionView.contentInset.top;
             }*/
            
            UICollectionViewLayoutAttributes *attributes = [_collectionLayout layoutAttributesForItemAtIndexPath:[NSIndexPath indexPathForItem:index inSection:0]];
            if (attributes != nil)
            {
                switch (scrollPosition)
                {
                    case TGInitialScrollPositionTop:
                    {
                        contentOffsetY = CGRectGetMaxY(attributes.frame) + _collectionView.contentInset.bottom - [_collectionView implicitTopInset] - _collectionView.frame.size.height + [_companion initialPositioningOverflowForScrollPosition:scrollPosition];
                        break;
                    }
                    case TGInitialScrollPositionCenter:
                    {
                        CGFloat visibleHeight = _collectionView.frame.size.height - _collectionView.contentInset.top - _collectionView.contentInset.bottom + [_collectionView implicitTopInset];
                        if (attributes.frame.size.height > visibleHeight) {
                            contentOffsetY = CGFloor(CGRectGetMaxY(attributes.frame) - visibleHeight - _collectionView.contentInset.top);
                        } else {
                            contentOffsetY = CGFloor(CGRectGetMidY(attributes.frame) - visibleHeight / 2.0f - _collectionView.contentInset.top);
                        }
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

- (void)setInitialSnapshot:(CGImageRef)image backgroundView:(TGModernTemporaryView *)backgroundView viewStorage:(TGModernViewStorage *)viewStorage topEdge:(CGFloat)topEdge displayScrollDownButton:(bool)displayScrollDownButton
{
    if (_viewStorage == nil && viewStorage != nil) {
        _viewStorage = viewStorage;
        _collectionLayout.viewStorage = viewStorage;
    }
    
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
                _snapshotImageView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, CGImageGetWidth(_snapshotImage) * (TGScreenPixel), CGImageGetHeight(_snapshotImage) * (TGScreenPixel))];
                _snapshotImageView.userInteractionEnabled = false;
                _snapshotImageView.transform = CGAffineTransformMakeRotation((CGFloat)M_PI);
                _snapshotImageView.hidden = _loadingMessages;
                [_view insertSubview:_snapshotImageView atIndex:[self _indexForCollectionView]];
            }
            
            _snapshotBackgroundView = backgroundView;
            _snapshotBackgroundView.hidden = _loadingMessages;
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
            
            if (displayScrollDownButton) {
                [self setScrollBackButtonVisible:true];
                [self _updateUnseenMessagesButton];
            }
        }
        else
        {
            if (_snapshotImageView != nil)
            {
                [_snapshotImageView removeFromSuperview];
                _snapshotImageView = nil;
            }
            
            if (_collectionView == nil) {
                [self _resetCollectionView:true];
            }
            
            [self _updateVisibleItemIndices:nil];
        }
    }
}

- (UIBarButtonItem *)defaultLeftBarButtonItem
{
    /*if (_inputTextPanel.messageEditingContext != nil) {
     return [[UIBarButtonItem alloc] initWithTitle:TGLocalized(@"Common.Cancel") style:UIBarButtonItemStylePlain target:self action:@selector(messageEditingCancelPressed)];
     }*/
    
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
    if ([self isAdminLog] || [self isSavedMessages]) {
        if (_infoButtonItem == nil) {
            _infoButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemSearch target:self action:@selector(searchPressed)];
        }
        return _infoButtonItem;
    }
    else {
        return _avatarButtonItem;
    }
}

- (void)setPresentation:(TGPresentation *)presentation
{
    _presentation = presentation;
    [_titleView setPresentation:presentation];
    [_inputTextPanel setPresentation:presentation];
    if (_currentInputPanel != _inputTextPanel)
        _currentInputPanel.presentation = presentation;
    _emptyListPlaceholder.presentation = presentation;
    _primaryTitlePanel.presentation = presentation;
    _secondaryTitlePanel.presentation = presentation;
    _searchBar.pallete = presentation.searchBarPallete;
    _scrollButtons.presentation = presentation;
    
    [_collectionView updatePresentation];
    
    if (self.companion.viewContext.presentation != nil)
    {
        self.companion.viewContext.presentation = presentation;
        
        for (TGMessageModernConversationItem *item in _items)
        {
            [item resetViewModel];
        }
        
        [self.companion refreshItems:^
        {
            [_collectionLayout invalidateLayout];
            [_collectionView reloadData];
        }];
    }
}

- (void)loadView
{
    [super loadView];
    
    if ([self isAdminLog])
        [_titleView setShowStatus:false showArrow:true];
    
    _view = [[TGModernConversationControllerView alloc] initWithFrame:self.view.bounds];
    _view.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    __weak TGModernConversationController *weakSelf = self;
    _view.layoutForSize = ^(CGSize size) {
        __strong TGModernConversationController *strongSelf = weakSelf;
        if (strongSelf != nil) {
            bool keyboardShouldChangeSize = false;
            if (strongSelf->_keyboardHeight > FLT_EPSILON) {
                UIView *inputView = strongSelf->_inputTextPanel.inputField.internalTextView.inputView;
                if ([inputView isKindOfClass:[TGCommandKeyboardView class]] && (inputView.autoresizingMask & UIViewAutoresizingFlexibleHeight) == 0) {
                    keyboardShouldChangeSize = false;
                } else {
                    keyboardShouldChangeSize = true;
                }
            }
            if (!keyboardShouldChangeSize) {
                [strongSelf _performSizeChangesWithDuration:strongSelf->_isRotating ? 0.3 : 0.0 size:size];
            }
        }
    };
    [self.view addSubview:_view];
    
    _view.movedToWindow = ^{
        __strong TGModernConversationController *strongSelf = weakSelf;
        if (strongSelf != nil) {
            if (strongSelf->_shouldOpenKeyboardOnce) {
                strongSelf->_doNotIgnoreKeyboardChangeDuringAppearance = true;
                strongSelf->_shouldOpenKeyboardOnce = false;
                if (strongSelf->_inputTextPanel.replyMarkup != nil) {
                    strongSelf->_inputTextPanel.canShowKeyboardAutomatically = true;
                    strongSelf->_inputTextPanel.enableKeyboard = true;
                } else {
                    [strongSelf openKeyboard];
                }
                dispatch_async(dispatch_get_main_queue(), ^{
                    strongSelf->_doNotIgnoreKeyboardChangeDuringAppearance = false;
                });
            }
        }
    };
    
    _view.clipsToBounds = true;
    _view.backgroundColor = [UIColor whiteColor];
    
    _backgroundView = [[UIImageView alloc] initWithFrame:_view.bounds];
    UIImage *wallpaperImage = [[TGWallpaperManager instance] currentWallpaperImage];
    _backgroundView.image = wallpaperImage;
    _backgroundView.clipsToBounds = true;
    _backgroundView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    _backgroundView.contentMode = UIViewContentModeScaleAspectFill;
    [_view addSubview:_backgroundView];
    
    int64_t peerId = [self peerId];
    _inputTextPanel = [[TGModernConversationInputTextPanel alloc] initWithFrame:CGRectMake(0, _view.frame.size.height - 45, _view.frame.size.width, 45) accessoryView:[_companion _controllerInputTextPanelAccessoryView]];
    _inputTextPanel.presentation = self.presentation;
    _inputTextPanel.channelInfoSignal = [[TGDatabaseInstance() channelCachedData:peerId] mapToSignal:^SSignal *(TGCachedConversationData *conversationData) {
        return [[TGDatabaseInstance() existingChannel:peerId] map:^NSDictionary *(TGConversation *conversation) {
            NSMutableDictionary *dictionary = [[NSMutableDictionary alloc] init];
            dictionary[@"conversation"] = conversation;
            dictionary[@"data"] = conversationData;
            return dictionary;
        }];
    }];
    _inputTextPanel.canOpenStickersPanel = ^{
        __strong TGModernConversationController *strongSelf = weakSelf;
        if (strongSelf != nil) {
            NSNumber *banTimeout = [strongSelf->_companion stickerRestrictionTimeout];
            if (banTimeout != nil) {
                [strongSelf showBannedStickersTooltip:[banTimeout intValue]];
                return false;
            } else {
                return true;
            }
        } else {
            return false;
        }
    };
    
    _inputTextPanel.stickerButton.fadeDisabled = _bannedStickers;
    _inputTextPanel.micButton.fadeDisabled = _bannedMedia;
    
    bool videoMessage = false;
    if (_isChannel)
        videoMessage = ![[[NSUserDefaults standardUserDefaults] objectForKey:@"TG_lastChannelRecordModeIsAudio_v0"] boolValue];
    else
        videoMessage = [[[NSUserDefaults standardUserDefaults] objectForKey:@"TG_lastPrivateRecordModeIsVideo_v0"] boolValue];
    
    [_inputTextPanel setVideoMessage:videoMessage];
    [_inputTextPanel setVideoMessageAvailable:[_companion allowVideoMessages]];
    
    _inputTextPanel.delegate = self;
    
    if (_initialInputText.length != 0)
    {
        [_inputTextPanel.inputField setText:_initialInputText];
        [_inputTextPanel.inputField selectRange:_initialSelectRange force:false];
        _initialInputText = nil;
    }
    
    if (_initialMessageEdigingContext != nil) {
        [self setEditMessageWithText:_initialMessageEdigingContext.text entities:_initialMessageEdigingContext.entities messageId:_initialMessageEdigingContext.messageId animated:false];
        _initialMessageEdigingContext = nil;
    }
    
    [_inputTextPanel setReplyMarkup:_replyMarkup];
    [_inputTextPanel setHasBots:_hasBots];
    [_inputTextPanel setCanBroadcast:_canBroadcast];
    [_inputTextPanel setIsBroadcasting:_isBroadcasting];
    [_inputTextPanel setIsAlwaysBroadcasting:_isAlwaysBroadcasting];
    [_inputTextPanel setInputDisabled:_inputDisabled];
    [_inputTextPanel setIsChannel:_isChannel];
    
    if (_initialForwardMessages != nil)
    {
        TGModernConversationForwardInputPanel *panel = [[TGModernConversationForwardInputPanel alloc] initWithMessages:_initialForwardMessages completeGroups:_initialCompleteGroups];
        __weak TGModernConversationController *weakSelf = self;
        panel.dismiss = ^
        {
            __strong TGModernConversationController *strongSelf = weakSelf;
            if (strongSelf != nil)
            {
                [strongSelf setPrimaryExtendedPanel:nil animated:true];
                [strongSelf setSecondaryExtendedPanel:nil animated:true];
            }
        };
        [self setPrimaryExtendedPanel:panel animated:true];
    }
    _initialForwardMessages = nil;
    _initialCompleteGroups = nil;
    
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
    
    if (_collectionView != nil) {
        [_view insertSubview:_emptyListPlaceholder aboveSubview:_collectionView];
    }
    
    _scrollButtons = [[TGConversationScrollButtonContainer alloc] init];
    _scrollButtons.presentation = self.presentation;
    _scrollButtons.unseenMentionCount = _initialUnreadMentionCount;
    _scrollButtons.onDown = ^{
        __strong TGModernConversationController *strongSelf = weakSelf;
        if (strongSelf != nil) {
            [strongSelf unseenMessagesButtonPressed];
        }
    };
    _scrollButtons.onMentions = ^{
        __strong TGModernConversationController *strongSelf = weakSelf;
        if (strongSelf != nil) {
            [strongSelf unseenMentionsButtonPressed];
        }
    };
    _scrollButtons.onMentionsMenu = ^{
        __strong TGModernConversationController *strongSelf = weakSelf;
        if (strongSelf != nil) {
            [[[TGCustomActionSheet alloc] initWithTitle:nil actions:@[
                                                                [[TGActionSheetAction alloc] initWithTitle:TGLocalized(@"WebSearch.RecentSectionClear") action:@"clear"],
                                                                [[TGActionSheetAction alloc] initWithTitle:TGLocalized(@"Common.Cancel") action:@"cancel" type:TGActionSheetActionTypeCancel]
                                                                ] actionBlock:^(__unused id target, NSString *action) {
                                                                    if ([action isEqualToString:@"clear"]) {
                                                                        __strong TGModernConversationController *strongSelf = weakSelf;
                                                                        if (strongSelf != nil) {
                                                                            TGProgressWindow *progressWindow = [[TGProgressWindow alloc] init];
                                                                            [progressWindow show:true];
                                                                            [[[[TGDownloadMessagesSignal clearUnseenMentions:((TGGenericModernConversationCompanion *)strongSelf->_companion).conversationId] deliverOn:[SQueue mainQueue]] onDispose:^{
                                                                                TGDispatchOnMainThread(^{
                                                                                    [progressWindow dismiss:true];
                                                                                });
                                                                            }] startWithNext:nil error:nil completed:^{
                                                                                [progressWindow dismissWithSuccess];
                                                                            }];
                                                                        }
                                                                    }
                                                                } target:strongSelf] showInView:strongSelf.view];
        }
    };
    
    if (_collectionView != nil)
        [_view insertSubview:_scrollButtons aboveSubview:_collectionView];
    else
        [_view insertSubview:_scrollButtons belowSubview:_currentInputPanel];
    
    [self _updateUnseenMessagesButton];
    
    if (![self _updateControllerInset:false])
        [self controllerInsetUpdated:UIEdgeInsetsZero];
    
    [_emptyListPlaceholder adjustLayoutForSize:_view.bounds.size contentInsets:UIEdgeInsetsMake(self.controllerInset.top, 0.0f, [_currentInputPanel currentHeight], 0.0f) duration:0.0f curve:0];
    
    if (self.companion.previewMode)
    {
        _avatarButton.preview = true;
        
        _previewNavigationBar = [[TGNavigationBar alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 44.0f) barStyle:UIBarStyleDefault];
        [_previewNavigationBar setPallete:self.presentation.navigationBarPallete];
        _previewNavigationBar.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        [self.view addSubview:_previewNavigationBar];
        
        [_previewNavigationBar setItems:@[ [self navigationItem] ]];
        
        [_titleView disableUnreadCount];
    }
}

- (CGFloat)contentAreaHeight {
    return MAX(0.0f, self.view.frame.size.height - self.controllerInset.top - _keyboardHeight);
}

- (void)viewWillAppear:(BOOL)animated
{
    TGLog(@"willAppear");
    
    [self setLeftBarButtonItem:[self defaultLeftBarButtonItem]];
    if (!_editingMode && _titleView != nil && _secondaryController == nil && !(self.companion.previewMode && [self isSavedMessages]))
        [self setRightBarButtonItem:[self defaultRightBarButtonItem]];
    
    if (self.navigationController.viewControllers.count >= 2)
    {
        UIViewController *previousController = [self.navigationController.viewControllers objectAtIndex:self.navigationController.viewControllers.count - 2];
        [_titleView setBackButtonTitle:previousController.navigationItem.backBarButtonItem.title.length == 0 ? TGLocalized(@"Common.Back") : previousController.navigationItem.backBarButtonItem.title];
    }
    
    if (!_alreadyHadWillAppear) {
        _readMentionsMessageIds = [[NSMutableSet alloc] init];
    }
    
    if (!_alreadyHadWillAppear && _canOpenKeyboardWhileInTransition) {
        if (_inputTextPanel.replyMarkup != nil) {
            _shouldOpenKeyboardOnce = true;
        }
    }
    
    if (_didDisappearBeforeAppearing) {
        _keyboardHeight = 0;
    }
    
    _receivedWillDisappear = false;
    
    _inputTextPanel.maybeInputField.internalTextView.enableFirstResponder = false;
    
    _willAppearTimestamp = CFAbsoluteTimeGetCurrent();
    
    CGSize collectionViewSize = _view.bounds.size;
    
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
    
    if (_collectionView != nil)
    {
        if (ABS(collectionViewSize.width - _collectionView.frame.size.width) > FLT_EPSILON)
            [self _performSizeChangesWithDuration:0.0f size:collectionViewSize];
        else
        {
            [_currentInputPanel adjustForSize:collectionViewSize keyboardHeight:_keyboardHeight duration:0.0 animationCurve:0 contentAreaHeight:[self contentAreaHeight] safeAreaInset:[self calculatedSafeAreaInset]];
            [self _adjustCollectionViewForSize:collectionViewSize keyboardHeight:_keyboardHeight inputContainerHeight:[_currentInputPanel currentHeight] duration:0.0 animationCurve:0];
        }
    }
    else {
        [_currentInputPanel adjustForSize:collectionViewSize keyboardHeight:_keyboardHeight duration:0.0 animationCurve:0  contentAreaHeight:[self contentAreaHeight] safeAreaInset:[self calculatedSafeAreaInset]];
        [self _adjustCollectionViewForSize:collectionViewSize keyboardHeight:_keyboardHeight inputContainerHeight:[_currentInputPanel currentHeight] duration:0.0 animationCurve:0];
    }
    
    if (_alreadyHadWillAppear)
    {
        [self _updateCanRegroupIncomingUnreadMessages];
    }
    _alreadyHadWillAppear = true;
    
    if (!TGIsPad() && iosMajorVersion() >= 8 && _raiseToListenActivator == nil) {
        __weak TGModernConversationController *weakSelf = self;
        _raiseToListenActivator = [[TGRaiseToListenActivator alloc] initWithShouldActivate:^bool {
            __strong TGModernConversationController *strongSelf = weakSelf;
            if (strongSelf != nil) {
                if ([strongSelf.companion mediaRestrictionTimeout] != nil) {
                    return false;
                }
                if (strongSelf.associatedWindowStack.count != 0 || TGAppDelegateInstance.rootController.associatedWindowStack.count != 0) {
                    return false;
                }
                if (strongSelf->_shareSheetWindow != nil || strongSelf->_attachmentSheetWindow != nil) {
                    return false;
                }
                if (strongSelf->_inputDisabled) {
                    return false;
                }
                if (TGTelegraphInstance.callManager.hasActiveCall) {
                    return false;
                }
                if (strongSelf->_inputTextPanel.isCustomKeyboardExpanded) {
                    return false;
                }
                return true;
            }
            return false;
        } activate:^{
            __strong TGModernConversationController *strongSelf = weakSelf;
            if (strongSelf != nil) {
                [strongSelf updateRaiseToListen];
                if (strongSelf->_raiseToListenActivator.enabled) {
                    if ((TGTelegraphInstance.musicPlayer.playlistMetadata == nil || ![TGTelegraphInstance.musicPlayer.playlistMetadata isEqual:[strongSelf->_companion playlistMetadata:true]]) && strongSelf->_currentAudioRecorder == nil && [strongSelf inputText].length == 0) {
                        if (![strongSelf playNextUnseenIncomingAudio]) {
                            [strongSelf startAudioRecording:true completion:^{}];
                        }
                    }
                }
            }
        } deactivate:^{
            __strong TGModernConversationController *strongSelf = weakSelf;
            if (strongSelf != nil) {
                if (strongSelf->_currentAudioRecorder != nil) {
                    [strongSelf finishAudioRecording:true];
                }
            }
        }];
        _raiseToListenActivator.enabled = _currentInputPanel == _inputTextPanel;
        
        _playlistFinishedDisposable = [[[TGTelegraphInstance.musicPlayer playlistFinished] deliverOn:[SQueue mainQueue]] startWithNext:^(id metadata) {
            __strong TGModernConversationController *strongSelf = weakSelf;
            if (strongSelf != nil && [metadata isEqual:[strongSelf->_companion playlistMetadata:true]]) {
                [strongSelf->_raiseToListenRecordAfterPlaybackTimer invalidate];
                strongSelf->_raiseToListenRecordAfterPlaybackTimer = [[STimer alloc] initWithTimeout:1.0 repeat:false completion:^{
                    __strong TGModernConversationController *strongSelf = weakSelf;
                    if (strongSelf != nil) {
                        if (strongSelf->_raiseToListenActivator.activated && TGTelegraphInstance.musicPlayer.playlistMetadata == nil) {
                            [strongSelf startAudioRecording:true completion:^{}];
                        }
                    }
                } nativeQueue:dispatch_get_main_queue()];
                [strongSelf->_raiseToListenRecordAfterPlaybackTimer start];
            }
        }];
    }
    
    [_viewVisible set:[SSignal single:@true]];
    
    for (TGModernCollectionCell *cell in _collectionView.visibleCells)
    {
        TGMessageModernConversationItem *item = cell.boundItem;
        if (item != nil && item->_message.containsUnseenMention) {
            [_readMentionsMessageIds addObject:@(item->_message.mid)];
            [item setTemporaryHighlighted:true viewStorage:_viewStorage];
        }
    }
}

- (void)viewWillLayoutSubviews
{
    [super viewWillLayoutSubviews];
    
    if (!_alreadyHadDidAppear && self.onViewDidAppear != nil)
        self.onViewDidAppear();
}

- (void)viewDidAppear:(BOOL)animated
{
    if (!_alreadyHadDidAppear && self.onViewDidAppear != nil)
        self.onViewDidAppear();
    
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
    
    [_disposable add:[[TGRecentPeersSignals updateRecentPeers] startWithNext:nil]];
    
    if (!_didDisappearBeforeAppearing)
    {
        [self maybeShowRecordTooltip];
        
        __weak TGModernConversationController *weakSelf = self;
        [_disposable add:[[SSignal mergeSignals:@[[TGScreenCaptureSignals screenshotTakenSignal], [TGScreenCaptureSignals screenCapturedSignal]]] startWithNext:^(__unused id next)
        {
            __strong TGModernConversationController *strongSelf = weakSelf;
            if (strongSelf != nil)
                [strongSelf screenCaptured];
        }]];
    }
    
    __weak TGModernConversationController *weakSelf = self;
    [_musicPlayerStatusDisposable setDisposable:[[[[TGTelegraphInstance.musicPlayer.playingStatus map:^TGMusicPlayerItem *(TGMusicPlayerStatus *status) {
        return status.item;
    }] filter:^bool(TGMusicPlayerItem *item)
    {
        __strong TGModernConversationController *strongSelf = weakSelf;
        if (strongSelf == nil)
            return false;
        
        return (item.isVoice || item.isVideo) && item.conversationId == [strongSelf peerId];
    }] reduceLeftWithPassthrough:nil with:^id(TGMusicPlayerItem *current, TGMusicPlayerItem *next, void (^emit)(id))
    {
        bool isNext = next.conversationId != current.conversationId || ![next.key isEqual:current.key];
        if (current != nil && next != nil && isNext)
            emit(@{@"previous": current, @"next": next });
        
        return next;
    }] startWithNext:^(NSDictionary *value)
    {
        __strong TGModernConversationController *strongSelf = weakSelf;
        if (strongSelf == nil)
            return;
        
        CFAbsoluteTime currentTime = CFAbsoluteTimeGetCurrent();
        if (strongSelf->_collectionView.isTracking || strongSelf->_collectionView.isDragging || strongSelf->_collectionView.isDecelerating || fabs(currentTime - strongSelf->_lastScrollTime) < 1.0)
            return;
        
        TGMusicPlayerItem *previous = value[@"previous"];
        TGMusicPlayerItem *next = value[@"next"];
        
        int32_t previousMid = [(NSNumber *)previous.key int32Value];
        int64_t previousPeerId = previous.conversationId;
        
        int32_t nextMid = [(NSNumber *)next.key int32Value];
        int64_t nextPeerId = next.conversationId;
        
        [[SSignal combineSignals:@[[[strongSelf messageVisibleInViewportSignal:previousMid peerId:previousPeerId once:true wholeVisible:false] take:1], [[strongSelf messageVisibleInViewportSignal:nextMid peerId:nextPeerId once:true wholeVisible:true] take:1]]] startWithNext:^(NSArray *next)
        {
            __strong TGModernConversationController *strongSelf = weakSelf;
            if (strongSelf == nil)
                return;
            
            bool previousVisible = [next.firstObject boolValue];
            bool nextVisible = [next.lastObject boolValue];
            
            if (previousVisible && !nextVisible)
                [strongSelf scrollToMessage:nextMid peerId:nextPeerId sourceMessageId:0 highlight:false animated:true];
        }];
    }]];
    
    _weakNavController = self.navigationController;
    
    for (TGModernCollectionCell *cell in _collectionView.visibleCells)
    {
        TGMessageModernConversationItem *item = cell.boundItem;
        if (item != nil) {
            if ([_readMentionsMessageIds containsObject:@(item->_message.mid)]) {
                [item setTemporaryHighlighted:true viewStorage:_viewStorage];
                TGDispatchAfter(0.6, dispatch_get_main_queue(), ^
                {
                    [item setTemporaryHighlighted:false viewStorage:_viewStorage];
                });
            }
        }
    }
    
    _readMentionsMessageIds = nil;
    
    [self _updateVisibleItemIndices:nil];
    
    if (_collectionView != nil) {
        bool atBottom = _collectionView.contentOffset.y < FLT_EPSILON && !_hasUnseenMessagesBelow;
        if (_atBottom != atBottom) {
            _atBottom = atBottom;
            [self updateAutomaticReadAction];
        }
    }
    
    if (iosMajorVersion() >= 11)
    {
        UIGestureRecognizer *gr0 = self.view.window.gestureRecognizers[0];
        UIGestureRecognizer *gr1 = self.view.window.gestureRecognizers[1];
        gr0.delaysTouchesBegan = false;
        gr1.delaysTouchesBegan = false;
    }
}

- (void)previewAudioWithDataItem:(TGDataItem *)dataItem duration:(NSTimeInterval)duration liveUploadData:(TGLiveUploadActorData *)liveUploadData waveform:(TGAudioWaveform *)waveform {
    __weak TGModernConversationController *weakSelf = self;
    TGModernConversationAudioPreviewInputPanel *panel = [[TGModernConversationAudioPreviewInputPanel alloc] initWithDataItem:dataItem duration:duration liveUploadActorData:liveUploadData waveform:waveform cancel:^{
        __strong TGModernConversationController *strongSelf = weakSelf;
        if (strongSelf != nil) {
            [strongSelf setInputPanel:strongSelf->_customInputPanel != nil ? strongSelf->_customInputPanel : [strongSelf defaultInputPanel] animated:true];
        }
    } send:^(TGDataItem *dataItem, NSTimeInterval duration, TGLiveUploadActorData *liveUploadData, TGAudioWaveform *waveform) {
        __strong TGModernConversationController *strongSelf = weakSelf;
        if (strongSelf != nil) {
            [strongSelf setInputPanel:strongSelf->_customInputPanel != nil ? strongSelf->_customInputPanel : [strongSelf defaultInputPanel] animated:true];
            [strongSelf->_companion controllerWantsToSendLocalAudioWithDataItem:dataItem duration:duration liveData:liveUploadData waveform:waveform asReplyToMessageId:[strongSelf currentReplyMessageId] botReplyMarkup:nil];
        }
    }];
    panel.delegate = self;
    panel.playbackDidBegin = ^{
        __strong TGModernConversationController *strongSelf = weakSelf;
        if (strongSelf != nil) {
            [strongSelf stopAudioRecording];
            [strongSelf stopInlineMediaIfPlaying:false];
            [TGTelegraphInstance.musicPlayer controlPause];
        }
    };
    id inputPanel = [_inputTextPanel primaryExtendedPanel];
    if ([inputPanel isKindOfClass:[TGModernConversationForwardInputPanel class]]) {
        inputPanel = nil;
    }
    [panel setPrimaryExtendedPanel:inputPanel animated:false];
    [panel setSecondaryExtendedPanel:[_inputTextPanel secondaryExtendedPanel] animated:false];
    [self setInputPanel:panel animated:true];
}

- (void)applicationWillResignActive:(NSNotification *)__unused notification
{
    [self _updateCanReadHistory:TGModernConversationActivityChangeInactive];
    
    if (_currentAudioRecorder != nil) {
        [self finishAudioRecording:true];
    }
}

- (void)applicationDidEnterBackground:(NSNotification *)__unused notification
{
    [self _updateCanReadHistory:TGModernConversationActivityChangeInactive];
    
    __autoreleasing NSArray *entities = nil;
    NSString *text = [_inputTextPanel.maybeInputField textWithEntities:&entities];
    if ([text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]].length == 0) {
        text = @"";
    }
    [_companion updateControllerInputText:text entities:entities messageEditingContext:_inputTextPanel.messageEditingContext];
}

- (void)applicationDidBecomeActive:(NSNotification *)__unused notification
{
    [self _updateCanRegroupIncomingUnreadMessages];
    [self _updateCanReadHistory:TGModernConversationActivityChangeAuto];
    
    if (iosMajorVersion() >= 11 && _keyboardHeight > FLT_EPSILON)
    {
        [UIView performWithoutAnimation:^{
            [_inputTextPanel.maybeInputField resignFirstResponder];
            [_inputTextPanel.maybeInputField becomeFirstResponder];
        }];
    }
}

- (void)screenCaptured
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
    if (iosMajorVersion() >= 7)
    {
        if (self.transitionCoordinator.interactive)
            _inputTextPanel.keepInputPanel = true;
    }
    
    _inputTextPanel.enableKeyboard = false;
    _inputTextPanel.canShowKeyboardAutomatically = true;
    
    _didDisappearBeforeAppearing = false;
    _receivedWillDisappear = true;
    
    freedomUIKitTest4_1();
    
    [self stopInlineMediaIfPlaying];
    
    [_collectionView stopScrollingAnimation];
    
    [self _updateCanReadHistory:TGModernConversationActivityChangeInactive];
    
    [self stopInlineMedia:0];
    
    _companion.viewContext.animationsEnabled = false;
    [self _updateItemsAnimationsEnabled];
    
    if (iosMajorVersion() >= 8)
    {
        [_currentActivity invalidate];
        _currentActivity = nil;
    }
    
    if (_shareSheetWindow != nil)
        [_shareSheetWindow dismissAnimated:animated completion:nil];
    
    _dropboxProxy = nil;
    
    [_recentGifsDisposable setDisposable:nil];
    [_tooltipContainerView removeFromSuperview];
    _tooltipContainerView = nil;
    
    [_recordTooltipContainerView removeFromSuperview];
    _recordTooltipContainerView = nil;
    
    if (self.isMovingFromParentViewController && _menuController != nil)
        [_menuController dismissAnimated:false];
    
    if (_contextMenuController != nil)
        [_contextMenuController dismissAnimated:false];
    
    [_topDimView removeFromSuperview];
    [_bottomDimView removeFromSuperview];
    
    if (self.isMovingFromParentViewController) {
        __autoreleasing NSArray *entities = nil;
        NSString *text = [_inputTextPanel.maybeInputField textWithEntities:&entities];
        if ([text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]].length == 0) {
            text = @"";
        }
        if ([text isEqualToString:@"@gif "]) {
            text = @"";
        }
        [_companion updateControllerInputText:text entities:entities messageEditingContext:_inputTextPanel.messageEditingContext];
    }
    
    bool pop = ![self.navigationController.viewControllers containsObject:self];
    bool interactive = iosMajorVersion() >= 7 ? self.transitionCoordinator.interactive : false;
    [_viewVisible set:[SSignal single:pop && !interactive ? nil : @false]];
    
    if (iosMajorVersion() >= 7)
        _weakNavController.interactivePopGestureRecognizer.enabled = true;
    _weakNavController.navigationBar.userInteractionEnabled = true;
    
    [_inputTextPanel willDisappear];
    
    [_searchBar resignFirstResponder];
    
    [super viewWillDisappear:animated];
}

- (void)viewDidDisappear:(BOOL)animated
{
    _receivedWillDisappear = false;
    _didDisappearBeforeAppearing = true;
    
    _keyboardHeight = 0.0f;
    
    [self _updateCanReadHistory:TGModernConversationActivityChangeInactive];
    
    [_currentInputPanel adjustForSize:_view.bounds.size keyboardHeight:_keyboardHeight duration:0.0 animationCurve:0 contentAreaHeight:[self contentAreaHeight] safeAreaInset:self.controllerSafeAreaInset];
    
    [self _adjustCollectionViewForSize:_view.bounds.size keyboardHeight:_keyboardHeight inputContainerHeight:[_currentInputPanel currentHeight] duration:0.0 animationCurve:0];
    
    [_inputTextPanel.maybeInputField.internalTextView resignFirstResponder];
    [_searchBar resignFirstResponder];
    
    [_titleView suspendAnimations];
    
    [self _leaveEditingModeAnimated:false];
    
    __autoreleasing NSArray *entities = nil;
    NSString *text = [_inputTextPanel.maybeInputField textWithEntities:&entities];
    if ([text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]].length == 0) {
        text = @"";
    }
    if ([text isEqualToString:@"@gif "]) {
        text = @"";
    }
    [_companion updateControllerInputText:text entities:entities messageEditingContext:_inputTextPanel.messageEditingContext];
    
    if ([_currentTitlePanel isKindOfClass:[TGModernConversationGenericTitlePanel class]])
        [self hideTitlePanel];
    
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
    
    [_menuContainerView hideMenu];
    _menuContainerView = nil;
    
    [_tooltipContainerView removeFromSuperview];
    _tooltipContainerView = nil;
    
    [_recordTooltipContainerView removeFromSuperview];
    _recordTooltipContainerView = nil;
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
    
    [_currentInputPanel adjustForSize:_view.bounds.size keyboardHeight:_keyboardHeight duration:duration animationCurve:0 contentAreaHeight:[self contentAreaHeight] safeAreaInset:[TGViewController safeAreaInsetForOrientation:toInterfaceOrientation]];
    [self _adjustCollectionViewForSize:_view.bounds.size keyboardHeight:_keyboardHeight inputContainerHeight:[_currentInputPanel currentHeight] duration:duration animationCurve:0];
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
    
    if (_tooltipContainerView != nil) {
        _tooltipContainerView.frame = CGRectMake(0, self.controllerInset.top, _view.frame.size.width, _view.frame.size.height - self.controllerInset.top - self.controllerInset.bottom);
    }
    
    if (![self viewControllerIsChangingInterfaceOrientation])
    {
        if (_titlePanelWrappingView != nil)
        {
            _titlePanelWrappingView.frame = CGRectMake(0.0f, self.controllerInset.top, _view.frame.size.width, _titlePanelWrappingView.frame.size.height);
        }
    }
    
    if (_searchBar != nil)
    {
        _searchBar.safeAreaInset = self.controllerSafeAreaInset;
        
        CGFloat offset = self.controllerSafeAreaInset.top > 0 ? self.controllerSafeAreaInset.top : ([self shouldIgnoreStatusBar] ? 0.0f : 20.0f) + self.additionalStatusBarHeight;
        _searchBar.frame = CGRectMake(0, offset, _searchBar.frame.size.width, _searchBar.frame.size.height);
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
        
        if (_collectionView != nil) {
            [_currentInputPanel setContentAreaHeight:[self contentAreaHeight]];
        }
        
        if (_searchMentionsPanel != nil) {
            [self updatePanelLayouts:self.controllerInset size:_view.bounds.size];
        }
    }
}

- (void)updatePanelLayouts:(UIEdgeInsets)controllerInset size:(CGSize)size {
    UIEdgeInsets panelInsets = controllerInset;
    
    panelInsets.top += 44.0f;
    panelInsets.bottom += [_currentInputPanel currentHeight];
    _searchMentionsPanel.frame = CGRectMake(0.0f, panelInsets.top, size.width, size.height - panelInsets.top - panelInsets.bottom);
    [_searchMentionsPanel layoutSubviews];
}

- (void)stopAudioRecording
{
    if (_currentAudioRecorder != nil)
    {
        _currentAudioRecorder.delegate = nil;
        [_currentAudioRecorder cancel];
        _currentAudioRecorder = nil;
        _currentAudioRecorderIsTouchInitiated = false;
        
        if ([self shouldAutorotate])
            [TGViewController attemptAutorotation];
    }
    
    [_raiseToListenRecordAfterPlaybackTimer invalidate];
    _raiseToListenRecordAfterPlaybackTimer = nil;
    
    [self updateRaiseToListen];
}

- (void)stopInlineMediaIfPlaying {
    [self stopInlineMediaIfPlaying:true];
}

- (void)stopInlineMediaIfPlaying:(bool)stopPreview
{
    [_raiseToListenRecordAfterPlaybackTimer invalidate];
    _raiseToListenRecordAfterPlaybackTimer = nil;
    
    if (stopPreview && [_currentInputPanel isKindOfClass:[TGModernConversationAudioPreviewInputPanel class]]) {
        [(TGModernConversationAudioPreviewInputPanel *)_currentInputPanel stop];
    }
}

- (void)touchedTableBackground
{
    if (_menuContainerView.isShowingMenu || _menuController != nil)
        return;
    
    [self endEditing];
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
    [_tooltipContainerView hideMenu];
    [_recordTooltipContainerView hideTooltip];
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

- (void)setInputPanel:(TGModernConversationInputPanel *)panel animated:(bool)animated {
    [self setInputPanel:panel animated:animated setupResponder:nil];
}

- (void)setInputPanel:(TGModernConversationInputPanel *)panel animated:(bool)animated setupResponder:(void (^)())setupResponder
{
    if (!self.isViewLoaded || _companion.previewMode)
        return;
    
    if (panel == _currentInputPanel)
        return;
    
    panel.presentation = self.presentation;
    
    if (animated)
    {
        TGModernConversationInputPanel *previousPanel = _currentInputPanel;
        _currentInputPanel = nil;
        
        int curve = iosMajorVersion() < 7 ? 0 : 7;
        
        _currentInputPanel = panel;
        
        if (_currentInputPanel != nil)
        {
            [_view addSubview:_currentInputPanel];
            [_currentInputPanel adjustForSize:_view.bounds.size keyboardHeight:_keyboardHeight duration:0.0 animationCurve:0 contentAreaHeight:[self contentAreaHeight] safeAreaInset:self.controllerSafeAreaInset];
            _currentInputPanel.frame = CGRectMake(_currentInputPanel.frame.origin.x, _view.frame.size.height, _currentInputPanel.frame.size.width, _currentInputPanel.frame.size.height);
        }
        
        [_currentInputPanel adjustForSize:_view.bounds.size keyboardHeight:_keyboardHeight duration:0.3 animationCurve:curve contentAreaHeight:[self contentAreaHeight] safeAreaInset:self.controllerSafeAreaInset];
        [self _adjustCollectionViewForSize:_view.bounds.size keyboardHeight:_keyboardHeight inputContainerHeight:_currentInputPanel.frame.size.height duration:0.3 animationCurve:curve];
        
        if (setupResponder) {
            setupResponder();
        }
        
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
        if (setupResponder) {
            setupResponder();
        }
        
        [_currentInputPanel removeFromSuperview];
        _currentInputPanel = panel;
        
        if (_currentInputPanel != nil)
        {
            [_view addSubview:_currentInputPanel];
            [_currentInputPanel adjustForSize:_view.bounds.size keyboardHeight:_keyboardHeight duration:0.0 animationCurve:0 contentAreaHeight:[self contentAreaHeight] safeAreaInset:self.controllerSafeAreaInset];
            //_currentInputPanel.frame = CGRectMake(_currentInputPanel.frame.origin.x, _view.frame.size.height - _currentInputPanel.frame.size.height, _currentInputPanel.frame.size.width, _currentInputPanel.frame.size.height);
            
            [self _adjustCollectionViewForSize:_view.bounds.size keyboardHeight:_keyboardHeight inputContainerHeight:_currentInputPanel.frame.size.height duration:0.0 animationCurve:0];
        }
    }
    
    [self updateRaiseToListen];
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
        if (_messageIdForVisibleHoleDirection != 0 && !_enableBelowHistoryRequests && _collectionView.contentOffset.y <= -_collectionView.contentInset.top + 10.0f && [_collectionView visibleCells].count != 0) {
            _messageIdForVisibleHoleDirection = 0;
        }
    }
    
    NSMutableArray *sortedHoles = nil;
    NSMutableArray *currentMessageIds = nil;
    NSMutableArray *currentUnseenMentionIds = nil;
    int32_t maxMessageId = 0;
    TGMessage *maxMessage = nil;
    
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
            
            int32_t itemMid = item->_message.mid;
            int32_t itemDate = (int32_t)item->_message.date;
            
            if (item->_message.viewCount != 0 && itemMid < TGMessageLocalMidBaseline) {
                if (currentMessageIds == nil) {
                    currentMessageIds = [[NSMutableArray alloc] init];
                }
                [currentMessageIds addObject:@(itemMid)];
            }
            
            if (item->_message.containsUnseenMention) {
                if (![item->_message hasUnreadContent]) {
                    if (currentUnseenMentionIds == nil) {
                        currentUnseenMentionIds = [[NSMutableArray alloc] init];
                    }
                    [currentUnseenMentionIds addObject:@(itemMid)];
                    if (_readMentionsMessageIds != nil) {
                        [item setTemporaryHighlighted:true viewStorage:_viewStorage];
                    }
                }
            }
            
            if (itemMid < TGMessageLocalMidBaseline) {
                maxMessageId = MAX(itemMid, maxMessageId);
            }
            
            if (itemDate > maxMessage.date || (itemDate == maxMessage.date && itemMid > maxMessage.mid)) {
                maxMessage = item->_message;
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
            
            if (item->_message.containsUnseenMention) {
                if (![item->_message hasUnreadContent]) {
                    if (currentUnseenMentionIds == nil) {
                        currentUnseenMentionIds = [[NSMutableArray alloc] init];
                    }
                    [currentUnseenMentionIds addObject:@(item->_message.mid)];
                }
            }
        }
    }
    
    [_companion _controllerDidUpdateVisibleHoles:sortedHoles];
    if (currentMessageIds != nil) {
        [_companion _controllerDidUpdateVisibleUnseenMessageIds:currentMessageIds];
    }
    if (currentUnseenMentionIds != nil && _canReadHistory && !_companion.previewMode) {
        [_readMentionsMessageIds addObjectsFromArray:currentUnseenMentionIds];
        [_companion _controllerDidUpdateVisibleUnseenMentionMessageIds:currentUnseenMentionIds];
    }
    
    if (_collectionView.contentSize.height > FLT_EPSILON && !_disableScrollProcessing)
    {
        if ((NSInteger)_items.count >= TGModernConversationControllerUnloadHistoryLimit + TGModernConversationControllerUnloadHistoryThreshold)
            [self _maybeUnloadHistory];
        
        if (!_fastScrolling && _enableAboveHistoryRequests && _collectionView.contentOffset.y > _collectionView.contentSize.height - 800 * 2.0f && _collectionView.contentSize.height > FLT_EPSILON)
            [_companion loadMoreMessagesAbove];
        
        if (!_fastScrolling && _enableBelowHistoryRequests && _collectionView.contentOffset.y < 600 * 2.0f)
            [_companion loadMoreMessagesBelow];
    }
    
    if (maxMessageId != 0) {
        //[_scrollStack updateStack:maxMessageId];
    }
    
//    if (maxMessage != nil && [_companion supportsSequentialRead]) {
//        [_companion updateLatestVisibleMessageIndex:[TGMessageIndex indexWithPeerId:maxMessage.fromUid messageId:maxMessage.mid] date:(int32_t)maxMessage.date force:false];
//    }
    
    bool explicitelyShowUnseenMessagesButton = _collectionView.contentOffset.y > 200.0f || _hasUnseenMessagesBelow;
    [self setScrollBackButtonVisible:explicitelyShowUnseenMessagesButton];
}

- (void)updateAutomaticReadAction {
    bool read = _atBottom && _canReadHistory && !self.companion.previewMode;
    if (_automaticReadDisposable != nil) {
        if (!read) {
            [_automaticReadDisposable dispose];
            _automaticReadDisposable = nil;
        }
    } else if (read) {
        _automaticReadDisposable = [TGDatabaseInstance() installReadMessagesAutomaticallyAction:((TGGenericModernConversationCompanion *)_companion).conversationId];
    }
}

- (void)collectionView:(UICollectionView *)__unused collectionView willDisplayCell:(UICollectionViewCell *)cell forItemAtIndexPath:(NSIndexPath *)__unused indexPath
{
    TGModernConversationItem *item = indexPath.row < (NSInteger)_items.count ? [_items objectAtIndex:indexPath.row] : nil;
    
    if (item != nil && iosMajorVersion() >= 8)
    {
        TGModernCollectionCell *concreteCell = (TGModernCollectionCell *)cell;
        [UIView performWithoutAnimation:^{
            if (concreteCell.boundItem != nil) {
                TGModernConversationItem *item = concreteCell.boundItem;
                [item unbindCell:_viewStorage];
            }
            
            if (!_disableItemBinding)
                [self _bindItem:item toCell:concreteCell atIndexPath:indexPath];
        }];
    }
    
    if (_temporaryHighlightMessageIdUponDisplay != 0)
    {
        TGMessageModernConversationItem *item = [(TGModernCollectionCell *)cell boundItem];
        if (item != nil)
        {
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
                
                if (!_disableItemBinding && iosMajorVersion() <= 7) {
                    [self _bindItem:item toCell:cell atIndexPath:indexPath];
                }
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
    
    if (_openMediaForMessageIdUponDisplay != 0 && [item isKindOfClass:[TGMessageModernConversationItem class]] && ((TGMessageModernConversationItem *)item)->_message.mid == _openMediaForMessageIdUponDisplay)
    {
        [self _performOnItemDisplayAction];
    }
    
    if ([item isKindOfClass:[TGMessageModernConversationItem class]])
    {
        TGMessageModernConversationItem *messageItem = (TGMessageModernConversationItem *)item;
        _bindingPipe.sink(@{ @"type": @"bind", @"pair": [TGMessageIndex indexWithPeerId:messageItem->_message.fromUid messageId:messageItem->_message.mid] });
    }
}

- (void)_performOnItemDisplayAction
{
    int32_t messageId = _openMediaForMessageIdUponDisplay;
    int64_t peerId = _openMediaForPeerIdUponDisplay;
    bool cancelPIP = _cancelPIPForOpenedMedia;
    bool isEmbed = _openedMediaIsEmbed;
    
    dispatch_async(dispatch_get_main_queue(), ^
    {
        if (isEmbed)
            [self _openEmbedFromMessageId:messageId peerId:peerId cancelPIP:cancelPIP];
        else
            [self openMediaFromMessage:messageId peerId:peerId cancelPIP:cancelPIP];
    });
    
    _openMediaForMessageIdUponDisplay = 0;
    _cancelPIPForOpenedMedia = false;
    _openedMediaIsEmbed = false;
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
            
            if ([item isKindOfClass:[TGMessageModernConversationItem class]])
            {
                TGMessageModernConversationItem *messageItem = (TGMessageModernConversationItem *)item;
                _bindingPipe.sink(@{ @"type": @"unbind", @"pair": [TGMessageIndex indexWithPeerId:messageItem->_message.fromUid messageId:messageItem->_message.mid] });
            }
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
        if (_scrollToMid != nil)
        {
            _scrollToMid = nil;
            _scrollToFinishedPipe.sink(@true);
        }
        //if (!_disableScrollProcessing)
        //    _disableScrollProcessing = false;
    }
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    if (scrollView == _collectionView)
    {
        if (_scrollButtons != nil && (_scrollButtons.superview != nil && _scrollButtons.displayDownButton) && scrollView.contentOffset.y <= -scrollView.contentInset.top)
        {
            [self setHasUnseenMessagesBelow:false];
        }
        
        if (scrollView.contentSize.height > FLT_EPSILON && !_disableScrollProcessing)
        {
            if ((NSInteger)_items.count >= TGModernConversationControllerUnloadHistoryLimit + TGModernConversationControllerUnloadHistoryThreshold)
                [self _maybeUnloadHistory];
            
            if (!_fastScrolling && _enableAboveHistoryRequests && scrollView.contentOffset.y > scrollView.contentSize.height - 800 * 2.0f && scrollView.contentSize.height > FLT_EPSILON)
                [_companion loadMoreMessagesAbove];
            
            if (!_fastScrolling && _enableBelowHistoryRequests && scrollView.contentOffset.y < 600 * 2.0f)
                [_companion loadMoreMessagesBelow];
            
            bool atBottom = _collectionView.contentOffset.y < FLT_EPSILON && !_hasUnseenMessagesBelow;
            if (_atBottom != atBottom) {
                _atBottom = atBottom;
                [self updateAutomaticReadAction];
            }
        }
        
        if (!_ignoreStackOperations && scrollView.contentOffset.y <= -scrollView.contentInset.top + 4.0f) {
            [_scrollStack clearStack];
            _scrollButtons.unreadMessageCount = 0;
        }
        
        if (_scrollToMid == nil)
            [self updateMessageVisibilitySubscriber];
    }
}

- (void)updateMessageVisibilitySubscriber
{
    if (_positionMonitoredForMessageWithMid != nil)
    {
        for (TGModernCollectionCell *cell in _collectionView.visibleCells)
        {
            TGMessageModernConversationItem *messageItem = cell.boundItem;
            if (messageItem != nil && messageItem->_message.mid == _positionMonitoredForMessageWithMid.messageId && (_positionMonitoredForMessageWithMid.peerId == 0 || messageItem->_message.fromUid == _positionMonitoredForMessageWithMid.peerId))
            {
                CGRect rect = [_collectionView convertRect:cell.frame toView:self.view];
                if (_visibilityChanged != nil)
                {
                    TGNavigationController *navController = (TGNavigationController *)self.navigationController;
                    _visibilityChanged(rect.origin.y < _currentInputPanel.frame.origin.y && CGRectGetMaxY(rect) > CGRectGetMaxY(navController.navigationBar.frame) + navController.currentAdditionalNavigationBarHeight);
                }
                break;
            }
        }
    }
}

- (void)updateLastScrollTime
{
    CFAbsoluteTime currentTime = CFAbsoluteTimeGetCurrent();
    if (fabs(currentTime - _lastScrollTime) > 1.5)
        _lastScrollTime = currentTime;
}

- (void)scrollViewDidEndScrollingAnimation:(UIScrollView *)__unused scrollView
{
    _scrollingToBottom = nil;
    [self updateLastScrollTime];
    
    if (_scrollToMid != nil)
    {
        _scrollToMid = nil;
        _scrollToFinishedPipe.sink(@true);
    }
}

- (void)scrollViewDidEndDragging:(UIScrollView *)__unused scrollView willDecelerate:(BOOL)decelerate
{
    if (!decelerate)
        [self updateLastScrollTime];
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)__unused scrollView
{
    [self updateLastScrollTime];
}

- (BOOL)scrollViewShouldScrollToTop:(UIScrollView *)scrollView
{
    if (TGTelegraphInstance.callManager.hasActiveCall)
        return false;
    
    if (_topDimView != nil)
    {
        [_menuContainerView hideMenu];
        return false;
    }
    
    if (scrollView == _collectionViewScrollToTopProxy)
    {
        [_collectionView scrollToTopIfNeeded];
        return false;
    }
    
    return false;
}

#pragma mark - Swipte to dismiss keyboard

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)__unused gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)__unused otherGestureRecognizer
{
    return true;
}

- (void)collectionViewPan:(UIPanGestureRecognizer *)gestureRecognizer
{
    CGPoint location = [gestureRecognizer locationInView:self.view];
    CGPoint velocity = [gestureRecognizer velocityInView:self.view];
    
    switch (gestureRecognizer.state)
    {
        case UIGestureRecognizerStateBegan:
        {
            if (location.y > _inputTextPanel.frame.origin.y)
            {
                gestureRecognizer.enabled = false;
                gestureRecognizer.enabled = true;
            }
        }
            break;
            
        case UIGestureRecognizerStateChanged:
        {
            if (CGPointEqualToPoint(_keyboardDismissSwipeStartPosition, CGPointZero))
            {
                if (location.y >= _inputTextPanel.frame.origin.y)
                    _keyboardDismissSwipeStartPosition = CGPointMake(location.x, _inputTextPanel.frame.origin.y);
            }

            if (!CGPointEqualToPoint(_keyboardDismissSwipeStartPosition, CGPointZero))
            {
                CGFloat delta = MAX(0.0f, location.y - _keyboardDismissSwipeStartPosition.y);
                _keyboardDismissOffset = delta;
            
                [_currentInputPanel adjustForSize:_view.bounds.size keyboardHeight:_keyboardHeight duration:0.0 animationCurve:0 contentAreaHeight:[self contentAreaHeight] safeAreaInset:self.controllerSafeAreaInset dismissOffset:_keyboardDismissOffset];
                [self _adjustCollectionViewForSize:_view.bounds.size keyboardHeight:_keyboardHeight inputContainerHeight:[_currentInputPanel currentHeight] scrollToBottom:false dismissOffset:_keyboardDismissOffset duration:0 animationCurve:0];
                
                [TGHacks setApplicationKeyboardOffset:_keyboardDismissOffset];
            }
        }
            break;
            
        case UIGestureRecognizerStateEnded:
        case UIGestureRecognizerStateCancelled:
        {
            if (CGPointEqualToPoint(_keyboardDismissSwipeStartPosition, CGPointZero))
                return;
                
            CGFloat keyboardHeight = [TGHacks applicationKeyboardView].frame.size.height;
            
            CGFloat targetDismissOffset = 0.0f;
            bool scrollToBottom = false;
            bool dismiss = false;
            if (gestureRecognizer.state != UIGestureRecognizerStateCancelled && (velocity.y > 800.0f || _keyboardDismissOffset > keyboardHeight / 2.0f))
            {
                targetDismissOffset = _keyboardHeight > FLT_EPSILON ? _keyboardHeight : _inputTextPanel.customKeyboardHeight;
                dismiss = true;
                
                if (_collectionView.contentOffset.y < -_collectionView.contentInset.top + 100.0f)
                    scrollToBottom = true;
            }
            
            [_currentInputPanel adjustForSize:_view.bounds.size keyboardHeight:_keyboardHeight duration:0.3 animationCurve:7 contentAreaHeight:[self contentAreaHeight] safeAreaInset:self.controllerSafeAreaInset dismissOffset:targetDismissOffset];
            [self _adjustCollectionViewForSize:_view.bounds.size keyboardHeight:_keyboardHeight inputContainerHeight:[_currentInputPanel currentHeight] scrollToBottom:scrollToBottom stopScrolling:true dismissOffset:targetDismissOffset duration:0.3 animationCurve:7];
            
            [UIView animateWithDuration:0.3 delay:0.0 options:7 << 16 animations:^
            {
                [TGHacks setApplicationKeyboardOffset:targetDismissOffset];
            } completion:^(__unused BOOL finished)
            {
                if (targetDismissOffset > FLT_EPSILON)
                {
                    [_inputTextPanel resign];
                    [TGHacks setApplicationKeyboardOffset:0.0f];
                }
            }];
            
            _keyboardDismissSwipeStartPosition = CGPointZero;
            _keyboardDismissOffset = 0.0f;
        }
            break;
            
        default:
            break;
    }
}

- (BOOL)gestureRecognizerShouldBegin:(UIPanGestureRecognizer *)gestureRecognizer
{
    CGPoint velocity = [gestureRecognizer velocityInView:self.view];
    if (fabs(velocity.x) > fabs(velocity.y))
        return false;
    
    if (_currentInputPanel != _inputTextPanel)
        return false;
    
    if ([_inputTextPanel.associatedPanel isKindOfClass:[TGModernConversationGenericContextResultsAssociatedPanel class]] || [_inputTextPanel.associatedPanel isKindOfClass:[TGModernConversationMediaContextResultsAssociatedPanel class]] || [_inputTextPanel.associatedPanel isKindOfClass:[TGModernConversationComplexMediaContextResultsAssociatedPanel class]] || [_inputTextPanel.associatedPanel isKindOfClass:[TGModernConversationMentionsAssociatedPanel class]] || [_inputTextPanel.associatedPanel isKindOfClass:[TGModernConversationHashtagsAssociatedPanel class]] || [_inputTextPanel.associatedPanel isKindOfClass:[TGModernConversationAlphacodeAssociatedPanel class]])
        return false;

    if ((_keyboardHeight < FLT_EPSILON && _inputTextPanel.customKeyboardHeight < FLT_EPSILON) || _inputTextPanel.isCustomKeyboardExpanded)
        return false;
        
    return true;
}

#pragma mark -

- (NSArray *)_currentItems {
    return _items;
}

- (void)replaceItems:(NSArray *)newItems messageIdForVisibleHoleDirection:(int32_t)messageIdForVisibleHoleDirection
{
    _messageIdForVisibleHoleDirection = messageIdForVisibleHoleDirection;
    
    [_items removeAllObjects];
    [_items addObjectsFromArray:newItems];
    
    if (self.isViewLoaded)
    {
        _collectionView.unreadMessageRange = _companion.unreadMessageRange;
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

- (void)replaceItems:(NSArray *)newItems positionAtMessageId:(int32_t)positionAtMessageId peerId:(int64_t)positionAtPeerId expandAt:(int32_t)expandMessageId jump:(bool)jump top:(bool)top messageIdForVisibleHoleDirection:(int32_t)messageIdForVisibleHoleDirection scrollBackMessageId:(int32_t)scrollBackMessageId animated:(bool)animated {
    _messageIdForVisibleHoleDirection = positionAtMessageId;
    if (messageIdForVisibleHoleDirection != 0) {
        _messageIdForVisibleHoleDirection = messageIdForVisibleHoleDirection;
    }
    
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
        _collectionView.unreadMessageRange = _companion.unreadMessageRange;
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
                        lastItemOffsetY = [self contentOffsetForMessageId:item->_message.mid peerId:0 scrollPosition:TGInitialScrollPositionBottom initial:true additionalOffset:0.0f];
                        break;
                    }
                }
                
                if (contentOffsetY > lastItemOffsetY) {
                    for (TGMessageModernConversationItem *item in _items.reverseObjectEnumerator) {
                        if (item->_message.mid >= expandGroup.minId) {
                            contentOffsetY = MIN(contentOffsetY, [self contentOffsetForMessageId:item->_message.mid peerId:0 scrollPosition:TGInitialScrollPositionTop initial:true additionalOffset:100.0f]);
                            break;
                        }
                    }
                }
            }
        }
        
        if (jump) {
            contentOffsetY = [self contentOffsetForMessageId:positionAtMessageId peerId:positionAtPeerId scrollPosition:TGInitialScrollPositionCenter initial:true additionalOffset:0.0f];
        } else if (top) {
            contentOffsetY = [self contentOffsetForMessageId:positionAtMessageId peerId:positionAtPeerId scrollPosition:TGInitialScrollPositionTop initial:true additionalOffset:0.0f];
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
                        
                        if (animated) {
                            [UIView animateWithDuration:0.25 delay:0.0 options:7 << 16 animations:^{
                                cell.frame = frame;
                            } completion:nil];
                        } else {
                            cell.frame = frame;
                        }
                        
                        if (item->_message.group != nil && animated) {
                            [self addAlphaAnimation:cell.layer delay:0.0];
                        }
                    } else {
                        CGFloat distance = ABS(updatedFrame.origin.y - frame.origin.y) / _collectionView.frame.size.height;
                        NSTimeInterval delay = MIN(distance / 1.5f, 0.25);
                        
                        if (animated) {
                            [self addAlphaAnimation:cell.layer delay:delay];
                            [self addScaleAnimation:cell.layer delay:delay];
                        }
                        
                        if (ABS(updatedFrame.origin.y - frame.origin.y) > 5.0f && animated) {
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
                    
                    if (animated) {
                        [UIView animateWithDuration:0.25 delay:0.0 options:7 << 16 animations:^{
                            cell.frame = frame;
                        } completion:nil];
                        
                        [self addAlphaAnimation:cell.layer delay:0.0];
                    } else {
                        cell.frame = frame;
                    }
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
                
                if (animated) {
                    [UIView animateWithDuration:0.2 delay:0.0 options:UIViewAnimationOptionCurveEaseOut animations:^{
                        cell.alpha = 0.0f;
                        cell.frame = offsetFrame;
                    } completion:^(__unused BOOL finished){
                        [cell removeFromSuperview];
                    }];
                } else {
                    cell.alpha = 0.0f;
                    cell.frame = offsetFrame;
                    [cell removeFromSuperview];
                }
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
                    
                    if (animated) {
                        [UIView animateWithDuration:0.25 delay:0.0 options:7 << 16 animations:^{
                            dateView.frame = frame;
                        } completion:nil];
                    } else {
                        dateView.frame = frame;
                    }
                }
            }
        }
        
        [storedDecorationViews removeObjectsForKeys:visibleDecorationViewIds];
        
        [_scrollStack pushMessageId:scrollBackMessageId];
        [self _updateVisibleItemIndices:nil];
    }
}

- (void)replaceItemsWithFastScroll:(NSArray *)newItems intent:(TGModernConversationInsertItemIntent)intent scrollToMessageId:(int32_t)scrollToMessageId peerId:(int64_t)scrollToPeerId scrollBackMessageId:(int32_t)scrollBackMessageId animated:(bool)animated
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
    
    if (storedCells.count != 0 && animated) {
        _fastScrolling = true;
    }
    
    [_collectionView reloadData];
    
    if (storedCells.count != 0)
    {
        if (intent == TGModernConversationInsertItemIntentSendTextMessage)
        {
            _inputTextPanel.maybeInputField.oneTimeLongAnimation = true;
            [self setPrimaryExtendedPanel:nil animated:true skipHeightAnimation:_inputTextPanel.maybeInputField.text.length != 0];
            [self setSecondaryExtendedPanel:nil animated:true skipHeightAnimation:_inputTextPanel.maybeInputField.text.length != 0];
            [_inputTextPanel.maybeInputField setText:@"" animated:true];
        }
        else if (intent == TGModernConversationInsertItemIntentSendOtherMessage)
        {
            if ([self currentReplyMessageId] != 0)
            {
                [self setPrimaryExtendedPanel:nil animated:true skipHeightAnimation:false];
                [self setSecondaryExtendedPanel:nil animated:true skipHeightAnimation:false];
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
                [_collectionView setContentOffset:CGPointMake(0.0f, [self contentOffsetForMessageId:scrollToMessageId peerId:scrollToPeerId scrollPosition:TGInitialScrollPositionCenter initial:false additionalOffset:0.0f]) animated:false];
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
            
            //[currentCellsWithFrames addObject:@[cell, [NSValue valueWithCGRect:cell.frame]]];
            //cell.frame = CGRectOffset(cell.frame, 0.0f, offsetDifference);
            
            if (animated) {
                CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"transform.translation.y"];
                animation.duration = 0.3 * TGAnimationSpeedFactor();
                animation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut];
                animation.fromValue = @(offsetDifference);
                animation.toValue = @(0.0f);
                animation.removedOnCompletion = true;
                animation.additive = true;
                [cell.layer addAnimation:animation forKey:@"fastScrollOffset"];
            }
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
            
            /*for (NSArray *desc in currentCellsWithFrames)
             {
             TGModernCollectionCell *cell = desc[0];
             cell.frame = [(NSValue *)desc[1] CGRectValue];
             }*/
            
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
            _fastScrolling = false;
            [self scrollViewDidScroll:_collectionView];
        }];
    }
    else
    {
        if (intent == TGModernConversationInsertItemIntentSendTextMessage)
        {
            [self setPrimaryExtendedPanel:nil animated:true skipHeightAnimation:false];
            [self setSecondaryExtendedPanel:nil animated:true skipHeightAnimation:false];
            [_inputTextPanel.maybeInputField setText:@"" animated:false];
        }
        else if (intent == TGModernConversationInsertItemIntentSendOtherMessage)
        {
            if ([self currentReplyMessageId] != 0)
            {
                [self setPrimaryExtendedPanel:nil animated:true skipHeightAnimation:false];
                [self setSecondaryExtendedPanel:nil animated:true skipHeightAnimation:false];
            }
        }
        
        _scrollingToBottom = nil;
        [_collectionView setContentOffset:CGPointMake(0.0f, -_collectionView.contentInset.top) animated:false];
    }
    
    [_scrollStack pushMessageId:scrollBackMessageId];
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
                        if (!messageItem->_message.outgoing && [_companion.viewContext.conversation isMessageUnread:messageItem->_message]) {
                            hadIncomingUnread = true;
                        }
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
                            [self setPrimaryExtendedPanel:nil animated:true skipHeightAnimation:_inputTextPanel.maybeInputField.text.length != 0];
                            [self setSecondaryExtendedPanel:nil animated:true skipHeightAnimation:_inputTextPanel.maybeInputField.text.length != 0];
                            [_inputTextPanel updateModeButtonVisibility:true reset:true];
                            [_inputTextPanel.maybeInputField setText:@""];
                            [_inputTextPanel updateModeButtonVisibility:true reset:false];
                        }
                        else if (intent == TGModernConversationInsertItemIntentSendOtherMessage)
                        {
                            if ([self currentReplyMessageId] != 0)
                            {
                                [self setPrimaryExtendedPanel:nil animated:true skipHeightAnimation:false];
                                [self setSecondaryExtendedPanel:nil animated:true skipHeightAnimation:false];
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
                    [self setPrimaryExtendedPanel:nil animated:true skipHeightAnimation:_inputTextPanel.maybeInputField.text.length != 0];
                    [self setSecondaryExtendedPanel:nil animated:true skipHeightAnimation:_inputTextPanel.maybeInputField.text.length != 0];
                    [_inputTextPanel.maybeInputField setText:@"" animated:true];
                }
                else if (intent == TGModernConversationInsertItemIntentSendOtherMessage)
                {
                    if ([self currentReplyMessageId] != 0)
                    {
                        [self setPrimaryExtendedPanel:nil animated:true skipHeightAnimation:false];
                        [self setSecondaryExtendedPanel:nil animated:true skipHeightAnimation:false];
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
            [self setPrimaryExtendedPanel:nil animated:true skipHeightAnimation:false];
            [self setSecondaryExtendedPanel:nil animated:true skipHeightAnimation:false];
            [_inputTextPanel.maybeInputField setText:@"" animated:false];
        }
        else if (intent == TGModernConversationInsertItemIntentSendOtherMessage)
        {
            if ([self currentReplyMessageId] != 0)
            {
                [self setPrimaryExtendedPanel:nil animated:true skipHeightAnimation:false];
                [self setSecondaryExtendedPanel:nil animated:true skipHeightAnimation:false];
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

- (void)updateItemAtIndex:(NSUInteger)index toItem:(TGModernConversationItem *)updatedItem delayAvailability:(bool)delayAvailability {
    [self updateItemAtIndex:index toItem:updatedItem delayAvailability:delayAvailability animated:true animateTransition:false force:false];
}

- (void)updateItemAtIndex:(NSUInteger)index toItem:(TGModernConversationItem *)updatedItem delayAvailability:(bool)delayAvailability animated:(bool)animated animateTransition:(bool)__unused animateTransition force:(bool)force
{
    CGFloat containerWidth = _collectionView == nil ? _view.frame.size.width : _collectionView.frame.size.width;
    
    UICollectionViewLayoutAttributes *previousAttributes = [_collectionLayout layoutAttributesForItemAtIndexPath:[NSIndexPath indexPathForRow:index inSection:0]];
    
    if (_items.count <= index) {
        return;
    }
    
    bool sizeChanged = false;
    CGSize lastSize = [(TGMessageModernConversationItem *)_items[index] sizeForContainerSize:CGSizeMake(containerWidth, CGFLOAT_MAX) viewStorage:_viewStorage];
    [_items[index] updateToItem:updatedItem viewStorage:_viewStorage sizeChanged:&sizeChanged delayAvailability:delayAvailability containerSize:CGSizeMake(containerWidth, CGFLOAT_MAX) force:force];
    CGSize updatedSize = lastSize;
    if (sizeChanged)
    {
        updatedSize = [(TGMessageModernConversationItem *)_items[index] sizeForContainerSize:CGSizeMake(containerWidth, CGFLOAT_MAX) viewStorage:_viewStorage];
    }
    
    if ((sizeChanged && ABS(lastSize.height - updatedSize.height) > FLT_EPSILON))
    {
        if (_collectionView.isDecelerating)
        {
            [_collectionLayout invalidateLayout];
            [_collectionView layoutSubviews];
            [_collectionView updateRelativeBounds];
        }
        else
        {
            UICollectionViewCell *cell = [_collectionView cellForItemAtIndexPath:[NSIndexPath indexPathForRow:index inSection:0]];
            if (animated && cell != nil) {
                std::vector<TGDecorationViewAttrubutes> decorationAttributes;
                
                CGPoint contentOffset = _collectionView.contentOffset;
                if (contentOffset.y > -_collectionView.contentInset.top + 1.0f && previousAttributes.frame.origin.y < contentOffset.y + _collectionView.frame.size.height - _collectionView.contentInset.bottom) {
                    contentOffset.y += updatedSize.height - lastSize.height;
                }
                
                [_collectionView performBatchUpdates:^{
                } completion:nil beforeDecorations:nil animated:true animationFactor:1.0f insideAnimation:^{
                    [_collectionView setContentOffset:contentOffset animated:false];
                }];
                
                [_collectionView updateRelativeBounds];
            } else {
                CGPoint contentOffset = _collectionView.contentOffset;
                if (contentOffset.y > -_collectionView.contentInset.top + 1.0f && previousAttributes.frame.origin.y < contentOffset.y + _collectionView.frame.size.height - _collectionView.contentInset.bottom) {
                    contentOffset.y += updatedSize.height - lastSize.height;
                }
                [_collectionLayout invalidateLayout];
                _collectionView.contentOffset = contentOffset;
                [_collectionView layoutSubviews];
                [_collectionView updateRelativeBounds];
            }
        }
    } else {
        [_collectionView updateRelativeBounds];
    }
}

- (void)updateItemProgressAtIndex:(NSUInteger)index toProgress:(CGFloat)progress animated:(bool)animated
{
    if (index >= _items.count)
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

- (void)updateAllMessageAttributes
{
    for (TGMessageModernConversationItem *messageItem in _items) {
        [messageItem updateMessageAttributes];
    }
}

- (void)setHasUnseenMessagesBelow:(bool)hasUnseenMessagesBelow
{
    if (!self.isViewLoaded)
        return;
    
    _hasUnseenMessagesBelow = hasUnseenMessagesBelow;
    
    [self _updateVisibleItemIndices:nil];
}

- (void)setUnreadMessageRangeIfAppropriate:(TGMessageRange)unreadMessageRange
{
    if (!TGMessageRangeEquals(_collectionView.unreadMessageRange, unreadMessageRange))
    {
        _collectionView.unreadMessageRange = unreadMessageRange;
        [_collectionView reloadData];
        [_collectionView layoutSubviews];
        
        int32_t minMessageId = INT32_MAX;
        int64_t minPeerId = 0;
        for (TGMessageModernConversationItem *item in _items)
        {
            if (item->_message.mid >= unreadMessageRange.firstMessageId)
            {
                if (item->_message.mid < minMessageId || minMessageId == INT32_MIN)
                {
                    minMessageId = item->_message.mid;
                    if ([self isFeed])
                        minPeerId = item->_message.fromUid;
                }
            }
        }
        
        if (minMessageId != INT32_MAX)
        {
            CGFloat contentOffset = [self contentOffsetForMessageId:minMessageId peerId:minPeerId scrollPosition:TGInitialScrollPositionTop initial:false additionalOffset:0.0f];
            [_collectionView setContentOffset:CGPointMake(0.0f, contentOffset) animated:false];
        }
    }
}

- (void)setScrollBackButtonVisible:(bool)scrollBackButtonVisible
{
    if (self.companion.previewMode || _isRecording)
        return;
    
    _scrollButtons.displayDownButton = scrollBackButtonVisible;
}

- (void)_updateUnseenMessagesButton
{
    if (_scrollButtons.superview != nil)
    {
        CGSize collectionViewSize = _view.bounds.size;
        
        CGSize buttonSize = _scrollButtons.frame.size;
        CGFloat topInset = 0.0f;
        if (_collectionView != nil) {
            topInset = _collectionView.contentInset.top;
        } else {
            topInset = _keyboardHeight + [_currentInputPanel currentHeight];
        }
        UIEdgeInsets safeAreaInset = self.controllerSafeAreaInset;
        _scrollButtons.frame = CGRectMake(collectionViewSize.width - buttonSize.width - 6 - safeAreaInset.right, collectionViewSize.height - buttonSize.height - topInset - 6, buttonSize.width, buttonSize.height);
    }
}

- (void)_updateEditingPanel
{
    if ([_currentInputPanel isKindOfClass:[TGModernConversationEditingPanel class]])
    {
        TGModernConversationEditingPanel *editingPanel = (TGModernConversationEditingPanel *)_currentInputPanel;
        [editingPanel setActionsEnabled:[_companion checkedMessageCount] != 0];
        [editingPanel setDeleteEnabled:[self canDeleteSelectedMessages]];
        [editingPanel setReportingEnabled:[self canReportAllSelectedMessages]];
        [editingPanel setForwardingEnabled:[_companion allowMessageForwarding] && [self canForwardAllSelectedMessages]];
        [editingPanel setShareEnabled:[_companion allowMessageExternalSharing] && [self canShareAllSelectedMessages]];
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
        [(TGModernConversationItem *)_items[[nIndex intValue]] updateToItem:updatedItems[index] viewStorage:_viewStorage sizeChanged:&sizeChanged delayAvailability:false containerSize:_collectionView.bounds.size];
    }
}

- (void)scrollToMessage:(int32_t)messageId peerId:(int64_t)peerId sourceMessageId:(int32_t)sourceMessageId animated:(bool)animated
{
    [self scrollToMessage:messageId peerId:peerId sourceMessageId:sourceMessageId highlight:true animated:animated];
}

- (void)scrollToMessage:(int32_t)messageId peerId:(int64_t)peerId sourceMessageId:(int32_t)sourceMessageId highlight:(bool)highlight animated:(bool)animated
{
    if (animated && !highlight)
        _scrollToMid = [TGMessageIndex indexWithPeerId:peerId messageId:messageId];
    
    TGMessageModernConversationItem *selectedItem = nil;
    for (TGMessageModernConversationItem *messageItem in _items)
    {
        if (messageItem->_message.mid == messageId && (peerId == 0 || messageItem->_message.fromUid == peerId))
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
            TGMessageModernConversationItem *boundItem = (TGMessageModernConversationItem *)cell.boundItem;
            if (boundItem != nil && boundItem->_message.mid == messageId && (peerId == 0 || boundItem->_message.fromUid == peerId))
            {
                foundCell = true;
                break;
            }
        }
        
        if (animated && highlight)
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
        
        CGFloat contentOffset = [self contentOffsetForMessageId:messageId peerId:peerId scrollPosition:TGInitialScrollPositionCenter initial:false additionalOffset:0.0f];
        if (ABS(contentOffset - _collectionView.contentOffset.y) > FLT_EPSILON)
        {
            [_collectionView setContentOffset:CGPointMake(0.0f, contentOffset) animated:animated];
        }
        else
        {
            [self _updateVisibleItemIndices:nil];
        }
    }
    
    [_scrollStack pushMessageId:sourceMessageId];
}

- (int64_t)peerId {
    return ((TGGenericModernConversationCompanion *)_companion).conversationId;
}

- (int32_t)convertMessageId:(int32_t)messageId fromPeerId:(int64_t)peerId {
    if (peerId == [self peerId] || [self isFeed]) {
        return messageId;
    } else {
        return messageId + migratedMessageIdOffset;
    }
}

- (int32_t)convertMessageId:(int32_t)messageId toPeerId:(int64_t)peerId {
    if (peerId == [self peerId] || [self isFeed]) {
        return messageId;
    } else {
        return messageId - migratedMessageIdOffset;
    }
}

- (void)openMediaFromMessage:(int32_t)messageId peerId:(int64_t)peerId instant:(bool)instant
{
    [self openMediaFromMessage:messageId peerId:peerId instant:instant previewMode:false previewActions:NULL cancelPIP:false];
}

- (void)openMediaFromMessage:(int32_t)messageId peerId:(int64_t)peerId cancelPIP:(bool)cancelPIP
{
    bool foundCell = false;
    for (TGModernCollectionCell *cell in _collectionView.visibleCells)
    {
        TGMessageModernConversationItem *messageItem = (TGMessageModernConversationItem *)cell.boundItem;
        if (messageItem != nil && messageItem->_message.mid == messageId && (peerId == 0 || messageItem->_message.fromUid == peerId))
        {
            foundCell = true;
            break;
        }
    }
    
    if (foundCell)
    {
        [self openMediaFromMessage:messageId peerId:peerId instant:false previewMode:false previewActions:NULL cancelPIP:cancelPIP];
    }
    else
    {
        _openMediaForMessageIdUponDisplay = messageId;
        _openedMediaIsEmbed = false;
        _cancelPIPForOpenedMedia = cancelPIP;
    }
}

- (UIViewController *)openMediaFromMessage:(int32_t)messageId peerId:(int64_t)peerId instant:(bool)instant previewMode:(bool)previewMode previewActions:(NSArray **)__unused previewActions cancelPIP:(bool)cancelPIP
{
    TGMessageModernConversationItem *mediaMessageItem = nil;
    TGModernCollectionCell *mediaItemCell = nil;
    
    int index = -1;
    for (TGMessageModernConversationItem *messageItem in _items)
    {
        index++;
        
        if (messageItem->_message.mid == messageId && (peerId == 0 || messageItem->_message.fromUid == peerId))
        {
            TGModernCollectionCell *cell = (TGModernCollectionCell *)[_collectionView cellForItemAtIndexPath:[NSIndexPath indexPathForItem:index inSection:0]];
            bool forceOpen = false;
            for (TGMediaAttachment *attachment in messageItem->_message.mediaAttachments)
            {
                if (attachment.type == TGWebPageMediaAttachmentType)
                {
                    TGWebPageMediaAttachment *webPage = (TGWebPageMediaAttachment *)attachment;
                    NSString *siteName = [webPage.siteName lowercaseString];
                    bool galleryFromInstantPage = [siteName isEqualToString:@"instagram"] || [siteName isEqualToString:@"twitter"] || [webPage.pageType isEqualToString:@"telegram_album"];
                    if (galleryFromInstantPage && webPage.instantPage != nil)
                        forceOpen = true;
                    break;
                }
            }
            if ((messageItem->_mediaAvailabilityStatus || forceOpen) && cell != nil)
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
            return nil;
        
        bool isGallery = false;
        bool isAvatar = false;
        TGImageInfo *avatarImageInfo = nil;
        TGWebPageMediaAttachment *webPage = nil;
        TGDocumentMediaAttachment *animatedDocument = nil;
        int32_t webPageMessageId = 0;
        bool foundMedia = false;
        CGSize dimensions = CGSizeZero;
        
        for (TGMediaAttachment *attachment in mediaMessageItem->_message.mediaAttachments)
        {
            switch (attachment.type)
            {
                case TGVideoMediaAttachmentType:
                case TGImageMediaAttachmentType:
                {
                    foundMedia = true;
                    isGallery = true;
                    
                    if ([attachment isKindOfClass:[TGImageMediaAttachment class]])
                        [((TGImageMediaAttachment *)attachment).imageInfo imageUrlForLargestSize:&dimensions];
                    else if ([attachment isKindOfClass:[TGVideoMediaAttachment class]])
                        dimensions = ((TGVideoMediaAttachment *)attachment).dimensions;
                    
                    break;
                }
                case TGWebPageMediaAttachmentType:
                case TGInvoiceMediaAttachmentType:
                {
                    if (attachment.type == TGInvoiceMediaAttachmentType) {
                        webPage = [((TGInvoiceMediaAttachment *)attachment) webpage];
                    } else {
                        webPage = ((TGWebPageMediaAttachment *)attachment);
                    }
                    
                    bool isVideo = false;
                    for (id attribute in webPage.document.attributes) {
                        if ([attribute isKindOfClass:[TGDocumentAttributeVideo class]]) {
                            isVideo = true;
                        }
                    }
                    
                    if (webPage.document != nil && !isVideo) {
                        TGDocumentController *documentController = [[TGDocumentController alloc] initWithURL:[_companion fileUrlForDocumentMedia:webPage.document] messageId:mediaMessageItem->_message.mid];
                        documentController.useDefaultAction = [_companion encryptUploads];
                        
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
                    } else {
                        foundMedia = true;
                        webPageMessageId = mediaMessageItem->_message.mid;
                        if (webPage.photo != nil)
                            [webPage.photo.imageInfo imageUrlForLargestSize:&dimensions];
                    }
                    
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
                    [self openLocationFromMessage:mediaMessageItem->_message previewMode:previewMode zoomToFitAll:false];
                    break;
                }
                case TGDocumentMediaAttachmentType:
                {
                    TGDocumentMediaAttachment *documentAttachment = (TGDocumentMediaAttachment *)attachment;
                    
                    if ([[[documentAttachment.fileName pathExtension] lowercaseString] isEqualToString:@"pkpass"] || [documentAttachment.mimeType isEqualToString:@"application/vnd.apple.pkpass"])
                    {
                        NSData *passData = [[NSData alloc] initWithContentsOfFile:[_companion fileUrlForDocumentMedia:documentAttachment].path];
                        NSError *error;
                        PKPass *pass = [[PKPass alloc] initWithData:passData error:&error];
                        
                        if (error == nil)
                        {
                            [self presentViewController:[[PKAddPassesViewController alloc] initWithPass:pass] animated:true completion:nil];
                            return nil;
                        }
                    }
                    
                    if (documentAttachment.isVoice) {
                        break;
                    }
                    
                    if (documentAttachment.isAnimated) {
                        animatedDocument = documentAttachment;
                        dimensions = [animatedDocument pictureSize];
                        foundMedia = true;
                        break;
                    }
                    
                    if ([[[documentAttachment.fileName pathExtension] lowercaseString] isEqualToString:@"strings"])
                    {
                        [[[TGCustomActionSheet alloc] initWithTitle:nil actions:@[
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
                                          [TGCustomAlertView presentAlertWithTitle:nil message:[[NSString alloc] initWithFormat:@"Localization file is valid, but the following keys are missing: %@", missingKeysString] cancelButtonTitle:TGLocalized(@"Common.OK") okButtonTitle:nil completionBlock:nil];
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
                                      
                                      [TGCustomAlertView presentAlertWithTitle:nil message:[[NSString alloc] initWithFormat:@"Invalid localization file: %@", reasonString] cancelButtonTitle:TGLocalized(@"Common.OK") okButtonTitle:nil completionBlock:nil];
                                  }
                              }
                              else if ([action isEqualToString:@"open"])
                              {
                                  TGDocumentController *documentController = [[TGDocumentController alloc] initWithURL:[controller.companion fileUrlForDocumentMedia:documentAttachment] messageId:mediaMessageItem->_message.mid];
                                  documentController.useDefaultAction = [_companion encryptUploads];
                                  
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
                    
                    [_companion updateMediaAccessTimeForMessageId:messageId];
                    
                    if ([documentAttachment.mimeType rangeOfString:@"html"].location != NSNotFound)
                    {
                        TGWebPageController *webpageController = [[TGWebPageController alloc] initWithTitle:documentAttachment.fileName url:[_companion fileUrlForDocumentMedia:documentAttachment]];
                        webpageController.presentation = self.presentation;
                        [self.navigationController pushViewController:webpageController animated:true];
                        break;
                    }
                    
                    TGDocumentController *documentController = [[TGDocumentController alloc] initWithURL:[_companion fileUrlForDocumentMedia:documentAttachment] messageId:mediaMessageItem->_message.mid];
                    documentController.useDefaultAction = [_companion encryptUploads];
                    
                    if (!previewMode)
                    {
                        [self.navigationController pushViewController:documentController animated:true];
                    }
                    else
                    {
                        documentController.previewMode = true;
                        
                        NSString *extension = [documentAttachment.fileName.pathExtension lowercaseString];
                        if ([extension isEqualToString:@"jpg"] || [extension isEqualToString:@"jpeg"] || [extension isEqualToString:@"png"] || [extension isEqualToString:@"tiff"])
                        {
                            return documentController;
                        }
                    }
                    
                    break;
                }
                case TGAudioMediaAttachmentType:
                {
                    break;
                }
                default:
                    break;
            }
            
            if (foundMedia)
                break;
        }
        
        if (!foundMedia)
            return nil;
        
        [self stopInlineMediaIfPlaying];
        
        int64_t cid = mediaMessageItem->_message.cid;
        
        TGModernGalleryController *modernGallery = [[TGModernGalleryController alloc] initWithContext:[TGLegacyComponentsContext shared]];
        modernGallery.previewMode = previewMode;
        
        if (animatedDocument != nil)
        {
            modernGallery.model = [[TGGifGalleryModel alloc] initWithMessage:mediaMessageItem->_message];
            
            __weak TGModernConversationController *weakSelf = self;
            __weak TGModernGalleryController *weakGallery = modernGallery;
            ((TGGifGalleryModel *)modernGallery.model).openLinkRequested = ^(NSString *url)
            {
                __strong TGModernConversationController *strongSelf = weakSelf;
                if (strongSelf != nil)
                {
                    [strongSelf openBrowserFromMessage:0 url:url];
                    
                    __strong TGModernGalleryController *strongGallery = weakGallery;
                    if (strongGallery != nil)
                        [strongGallery dismissWhenReadyAnimated:true];
                }
            };
            ((TGGifGalleryModel *)modernGallery.model).shareAction = ^(TGMessage *message, NSArray *peerIds, NSString *caption)
            {
                __strong TGModernConversationController *strongSelf = weakSelf;
                if (strongSelf == nil)
                    return;
                
                NSMutableArray *finalPeerIds = [[NSMutableArray alloc] init];
                for (NSNumber *peerId in peerIds)
                {
                    if (peerId.int64Value == TGTelegraphInstance.clientUserId)
                    {
                        [strongSelf broadcastForwardMessages:@[ [TGMessageIndex indexWithPeerId:message.cid messageId:message.mid] ] caption:caption toPeerIds:@[ peerId ] grouped:false];
                        continue;
                    }
                    [finalPeerIds addObject:peerId];
                }
                
                if (!strongSelf->_isChannel)
                {
                    for (TGMediaAttachment *attachment in message.mediaAttachments)
                    {
                        if ([attachment isKindOfClass:[TGDocumentMediaAttachment class]])
                        {
                            [[TGShareSignals shareDocument:(TGDocumentMediaAttachment *)attachment toPeerIds:peerIds caption:caption] startWithNext:nil];
                            break;
                        }
                    }
                }
                else
                {
                    [strongSelf broadcastForwardMessages:@[ [TGMessageIndex indexWithPeerId:message.cid messageId:message.mid]] caption:caption toPeerIds:peerIds grouped:false];
                }
                
                [[[TGProgressWindow alloc] init] dismissWithSuccess];
            };
        }
        else if (webPage != nil)
        {
            modernGallery.model = [[TGExternalGalleryModel alloc] initWithWebPage:webPage peerId:cid messageId:messageId];
            
            __weak TGModernConversationController *weakSelf = self;
            __weak TGModernGalleryController *weakGallery = modernGallery;
            ((TGExternalGalleryModel *)modernGallery.model).openLinkRequested = ^(NSString *url)
            {
                __strong TGModernConversationController *strongSelf = weakSelf;
                if (strongSelf != nil)
                {
                    [strongSelf openBrowserFromMessage:0 url:url];
                    
                    __strong TGModernGalleryController *strongGallery = weakGallery;
                    if (strongGallery != nil)
                        [strongGallery dismissWhenReadyAnimated:true];
                }
            };
        }
        else if (isGallery)
        {
            if ([self isAdminLog]) {
                modernGallery.model = [[TGGenericPeerMediaGalleryModel alloc] initWithPeerId:mediaMessageItem->_message.cid allowActions:false messages:@[mediaMessageItem->_message] atMessageId:mediaMessageItem->_message.mid];
                ((TGGenericPeerMediaGalleryModel *)modernGallery.model).disableActions = true;
            } else if ([self isFeed]) {
                modernGallery.model = [[TGGenericPeerMediaGalleryModel alloc] initWithFeedId:[self peerId] atMessageId:mediaMessageItem->_message.mid atPeerId:mediaMessageItem->_message.fromUid allowActions:true];
                ((TGGenericPeerMediaGalleryModel *)modernGallery.model).disableDelete = true;
            } else if (mediaMessageItem->_message.messageLifetime > 0 && mediaMessageItem->_message.messageLifetime <= 60 && (mediaMessageItem->_message.layer >= 17 || _companion.allowMessageForwarding))
            {
                modernGallery.model = [[TGSecretPeerMediaGalleryModel alloc] initWithPeerId:((TGGenericModernConversationCompanion *)_companion).conversationId messageId:mediaMessageItem->_message.mid];
                modernGallery.isImportant = true;
            }
            else if (!_companion.allowMessageForwarding)
            {
                modernGallery.model = [[TGSecretInfiniteLifetimePeerMediaGalleryModel alloc] initWithPeerId:((TGGenericModernConversationCompanion *)_companion).conversationId atMessageId:mediaMessageItem->_message.mid allowActions:_companion.allowMessageForwarding important:TGMessageSortKeySpace(mediaMessageItem->_message.sortKey) == TGMessageSpaceImportant];
            }
            else
            {
                if (mediaMessageItem->_message.cid == [self peerId]) {
                    modernGallery.model = [[TGGenericPeerMediaGalleryModel alloc] initWithPeerId:[self peerId] atMessageId:mediaMessageItem->_message.mid allowActions:_companion.allowMessageForwarding important:TGMessageSortKeySpace(mediaMessageItem->_message.sortKey) == TGMessageSpaceImportant];
                    ((TGGenericPeerMediaGalleryModel *)modernGallery.model).disableDelete = ![_companion canDeleteMessages];
                } else {
                    modernGallery.model = [[TGGenericPeerMediaGalleryModel alloc] initWithPeerId:mediaMessageItem->_message.cid atMessageId:[self convertMessageId:mediaMessageItem->_message.mid toPeerId:cid] allowActions:_companion.allowMessageForwarding important:TGMessageSortKeySpace(mediaMessageItem->_message.sortKey) == TGMessageSpaceImportant];
                    ((TGGenericPeerMediaGalleryModel *)modernGallery.model).attachedPeerId = cid;
                    ((TGGenericPeerMediaGalleryModel *)modernGallery.model).disableDelete = ![_companion canDeleteMessages];
                }
            }
            
            if ([modernGallery.model isKindOfClass:[TGGenericPeerMediaGalleryModel class]] && ![self isAdminLog])
            {
                __weak TGModernConversationController *weakSelf = self;
                __weak TGModernGalleryController *weakGallery = modernGallery;
                ((TGGenericPeerMediaGalleryModel *)modernGallery.model).openLinkRequested = ^(NSString *url)
                {
                    __strong TGModernConversationController *strongSelf = weakSelf;
                    if (strongSelf != nil)
                    {
                        [strongSelf openBrowserFromMessage:0 url:url];
                        
                        __strong TGModernGalleryController *strongGallery = weakGallery;
                        if (strongGallery != nil)
                            [strongGallery dismissWhenReadyAnimated:true];
                    }
                };
                ((TGGenericPeerMediaGalleryModel *)modernGallery.model).shareAction = ^(NSArray *messageIds, int64_t fromPeerId, NSArray *peerIds, NSString *caption)
                {
                    __strong TGModernConversationController *strongSelf = weakSelf;
                    if (strongSelf == nil)
                        return;
                    
                    if (fromPeerId == 0)
                        fromPeerId = [strongSelf peerId];
                    
                    NSMutableArray *finalPeerIds = [[NSMutableArray alloc] init];
                    NSNumber *selfPeerId = nil;
                    for (NSNumber *peerId in peerIds)
                    {
                        if (peerId.int64Value == TGTelegraphInstance.clientUserId)
                        {
                            selfPeerId = peerId;
                            continue;
                        }
                        [finalPeerIds addObject:peerId];
                    }
                    
                    NSMutableArray *groupedItems = [[NSMutableArray alloc] init];
                    NSMutableArray *messageIndices = [[NSMutableArray alloc] init];
                    for (NSNumber *messageId in messageIds)
                    {
                        int32_t mid = messageId.int32Value;
                        TGMessage *message = [TGDatabaseInstance() loadMessageWithMid:mid peerId:fromPeerId];
                        [messageIndices addObject:[TGMessageIndex indexWithPeerId:message.cid messageId:message.mid]];
                        bool isInlineBotMessage = false;
                        for (TGDocumentMediaAttachment *attachment in message.mediaAttachments)
                        {
                            if (attachment.type == TGViaUserAttachmentType)
                            {
                                isInlineBotMessage = true;
                                break;
                            }
                        }
                        
                        if (messageIds.count > 1 && message.groupedId != 0)
                        {
                            [groupedItems addObject:message];
                        }
                        else
                        {
                            if (!strongSelf->_isChannel && !isInlineBotMessage)
                            {
                                for (TGMediaAttachment *attachment in message.mediaAttachments)
                                {
                                    if ([attachment isKindOfClass:[TGImageMediaAttachment class]])
                                    {
                                        [[TGShareSignals sharePhoto:(TGImageMediaAttachment *)attachment toPeerIds:finalPeerIds caption:caption] startWithNext:nil];
                                        break;
                                    }
                                    else if ([attachment isKindOfClass:[TGVideoMediaAttachment class]])
                                    {
                                        [[TGShareSignals shareVideo:(TGVideoMediaAttachment *)attachment toPeerIds:finalPeerIds caption:caption] startWithNext:nil];
                                        break;
                                    }
                                    else if ([attachment isKindOfClass:[TGDocumentMediaAttachment class]])
                                    {
                                        [[TGShareSignals shareDocument:(TGDocumentMediaAttachment *)attachment toPeerIds:finalPeerIds caption:caption] startWithNext:nil];
                                        break;
                                    }
                                }
                            }
                            else
                            {
                                [strongSelf broadcastForwardMessages:@[ [TGMessageIndex indexWithPeerId:message.cid messageId:message.mid]] caption:caption toPeerIds:finalPeerIds grouped:true];
                            }
                        }
                    }
                    
                    if (groupedItems.count > 0)
                        [[TGShareSignals shareMultiMedia:groupedItems toPeerIds:peerIds caption:caption] startWithNext:nil];
                    else if (selfPeerId != nil)
                        [strongSelf broadcastForwardMessages:messageIndices caption:caption toPeerIds:@[ selfPeerId ] grouped:true];
                    
                    [[[TGProgressWindow alloc] init] dismissWithSuccess];
                };
            }
        }
        else if (isAvatar)
        {
            NSString *legacyThumbnailUrl = [avatarImageInfo closestImageUrlWithSize:CGSizeZero resultingSize:NULL];
            NSString *legacyUrl = [avatarImageInfo imageUrlForLargestSize:NULL];
            
            modernGallery.model = [[TGGroupAvatarGalleryModel alloc] initWithPeerId:[_companion requestPeerId] accessHash:[_companion requestAccessHash] messageId:mediaMessageItem->_message.mid legacyThumbnailUrl:legacyThumbnailUrl legacyUrl:legacyUrl imageSize:CGSizeMake(640.0f, 640.0f)];
        }
        
        if (previewMode)
        {
            if (isAvatar)
            {
                CGFloat side = MIN(self.view.frame.size.width, self.view.frame.size.height);
                modernGallery.preferredContentSize = CGSizeMake(side, side);
            }
            else
            {
                CGSize screenSize = TGScreenSize();
                modernGallery.preferredContentSize = TGFitSize(dimensions, screenSize);
            }
        }
        
        __weak TGModernConversationController *weakSelf = self;
        __weak TGModernGalleryController *weakGallery = modernGallery;
        __block bool transitionedIn = false;
        modernGallery.itemFocused = ^(id<TGModernGalleryItem> item)
        {
            __strong TGModernConversationController *strongSelf = weakSelf;
            __strong TGModernGalleryController *strongGallery = weakGallery;
            if (strongSelf != nil)
            {
                if (strongGallery.previewMode)
                    return;
                
                if ([item conformsToProtocol:@protocol(TGGenericPeerGalleryItem)])
                {
                    id<TGGenericPeerGalleryItem> concreteItem = (id<TGGenericPeerGalleryItem>)item;
                    int32_t messageId = [strongSelf convertMessageId:[concreteItem messageId] fromPeerId:cid];
                    strongSelf.companion.mediaHiddenMessageIndex = [TGMessageIndex indexWithPeerId:peerId messageId:messageId];
                    
                    if (!transitionedIn && cancelPIP)
                    {
                        TGDispatchAfter(0.3, dispatch_get_main_queue(), ^
                        {
                            transitionedIn = true;
                            for (TGModernCollectionCell *cell in strongSelf->_collectionView.visibleCells)
                            {
                                [(TGMessageModernConversationItem *)[cell boundItem] updateMediaVisibility];
                            }
                        });
                    }
                    else
                    {
                        for (TGModernCollectionCell *cell in strongSelf->_collectionView.visibleCells)
                        {
                            [(TGMessageModernConversationItem *)[cell boundItem] updateMediaVisibility];
                        }
                    }
                }
                else if ([item isKindOfClass:[TGGroupAvatarGalleryItem class]])
                {
                    int32_t messageId = ((TGGroupAvatarGalleryItem *)item).messageId;
                    strongSelf.companion.mediaHiddenMessageIndex = [TGMessageIndex indexWithPeerId:peerId messageId:messageId];
                    
                    for (TGModernCollectionCell *cell in strongSelf->_collectionView.visibleCells)
                    {
                        [(TGMessageModernConversationItem *)[cell boundItem] updateMediaVisibility];
                    }
                }
                else if ([item isKindOfClass:[TGSecretPeerMediaGalleryImageItem class]]) {
                    TGSecretPeerMediaGalleryImageItem *concreteItem = (TGSecretPeerMediaGalleryImageItem *)item;
                    int32_t messageId = [strongSelf convertMessageId:[concreteItem messageId] fromPeerId:cid];
                    
                    strongSelf.companion.mediaHiddenMessageIndex = [TGMessageIndex indexWithPeerId:peerId messageId:messageId];
                    
                    for (TGModernCollectionCell *cell in strongSelf->_collectionView.visibleCells)
                    {
                        [(TGMessageModernConversationItem *)[cell boundItem] updateMediaVisibility];
                    }
                }
                else if ([item isKindOfClass:[TGSecretPeerMediaGalleryVideoItem class]]) {
                    TGSecretPeerMediaGalleryVideoItem *concreteItem = (TGSecretPeerMediaGalleryVideoItem *)item;
                    int32_t messageId = [strongSelf convertMessageId:[concreteItem messageId] fromPeerId:cid];
                    strongSelf.companion.mediaHiddenMessageIndex = [TGMessageIndex indexWithPeerId:peerId messageId:messageId];
                    
                    for (TGModernCollectionCell *cell in strongSelf->_collectionView.visibleCells)
                    {
                        [(TGMessageModernConversationItem *)[cell boundItem] updateMediaVisibility];
                    }
                }
                else
                {
                    int32_t messageId = webPageMessageId;
                    strongSelf.companion.mediaHiddenMessageIndex = [TGMessageIndex indexWithPeerId:peerId messageId:messageId];
                    
                    for (TGModernCollectionCell *cell in strongSelf->_collectionView.visibleCells)
                    {
                        [(TGMessageModernConversationItem *)[cell boundItem] updateMediaVisibility];
                    }
                }
            }
        };
        
        bool mediaAvailable = mediaMessageItem->_mediaAvailabilityStatus;
        modernGallery.finishedTransitionIn = ^(__unused id<TGModernGalleryItem> item, TGModernGalleryItemView *itemView)
        {
            __strong TGModernGalleryController *strongGallery = weakGallery;
            
            if ([itemView isKindOfClass:[TGModernGalleryNewVideoItemView class]])
            {
                if (strongGallery.previewMode)
                    [((TGModernGalleryNewVideoItemView *)itemView) loadAndPlay];
                else if (mediaAvailable)
                    [((TGModernGalleryNewVideoItemView *)itemView) play];
            }
            else if ([itemView isKindOfClass:[TGModernGalleryVideoItemView class]])
            {
                if (mediaAvailable)
                    [((TGModernGalleryNewVideoItemView *)itemView) play];
            }
        };
        
        modernGallery.beginTransitionIn = ^UIView *(id<TGModernGalleryItem> item, TGModernGalleryItemView *itemView)
        {
            __strong TGModernConversationController *strongSelf = weakSelf;
            __strong TGModernGalleryController *strongGallery = weakGallery;
            if (strongSelf != nil)
            {
                if (strongGallery.previewMode)
                    return nil;
                
                if ([item conformsToProtocol:@protocol(TGGenericPeerGalleryItem)])
                {
                    if (mediaAvailable)
                    {
                        if ([itemView isKindOfClass:[TGModernGalleryNewVideoItemView class]])
                            [((TGModernGalleryNewVideoItemView *)itemView) hidePlayButton];
                        else if ([itemView isKindOfClass:[TGModernGalleryVideoItemView class]])
                            [((TGModernGalleryVideoItemView *)itemView) hidePlayButton];
                    }
                    
                    if ([itemView isKindOfClass:[TGGenericPeerMediaGalleryVideoItemView class]] && cancelPIP)
                    {
                        [((TGGenericPeerMediaGalleryVideoItemView *)itemView) cancelPIP];
                        return nil;
                    }
                    
                    id<TGGenericPeerGalleryItem> concreteItem = (id<TGGenericPeerGalleryItem>)item;
                    int32_t messageId = [strongSelf convertMessageId:[concreteItem messageId] fromPeerId:cid];
                    
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
                else if ([item isKindOfClass:[TGSecretPeerMediaGalleryImageItem class]]) {
                    TGSecretPeerMediaGalleryImageItem *concreteItem = (TGSecretPeerMediaGalleryImageItem *)item;
                    int32_t messageId = [strongSelf convertMessageId:[concreteItem messageId] fromPeerId:cid];
                    
                    for (TGModernCollectionCell *cell in strongSelf->_collectionView.visibleCells)
                    {
                        TGMessageModernConversationItem *cellItem = [cell boundItem];
                        if (cellItem != nil && cellItem->_message.mid == messageId)
                        {
                            return [cellItem referenceViewForImageTransition];
                        }
                    }
                }
                else if ([item isKindOfClass:[TGSecretPeerMediaGalleryVideoItem class]]) {
                    TGSecretPeerMediaGalleryVideoItem *concreteItem = (TGSecretPeerMediaGalleryVideoItem *)item;
                    int32_t messageId = [strongSelf convertMessageId:[concreteItem messageId] fromPeerId:cid];
                    
                    [((TGModernGalleryVideoItemView *)itemView) hidePlayButton];
                    
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
        
        modernGallery.beginTransitionOut = ^UIView *(id<TGModernGalleryItem> item, TGModernGalleryItemView *itemView)
        {
            __strong TGModernConversationController *strongSelf = weakSelf;
            if (strongSelf != nil)
            {
                [strongSelf _dismissBannersForCurrentConversation];
                
                if ([itemView isKindOfClass:[TGModernGalleryNewVideoItemView class]])
                    [((TGModernGalleryNewVideoItemView *)itemView) stopForOutTransition];
                
                if ([item conformsToProtocol:@protocol(TGGenericPeerGalleryItem)])
                {
                    id<TGGenericPeerGalleryItem> concreteItem = (id<TGGenericPeerGalleryItem>)item;
                    int32_t messageId = [strongSelf convertMessageId:[concreteItem messageId] fromPeerId:cid];
                    
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
                else if ([item isKindOfClass:[TGSecretPeerMediaGalleryImageItem class]]) {
                    TGSecretPeerMediaGalleryImageItem *concreteItem = (TGSecretPeerMediaGalleryImageItem *)item;
                    int32_t messageId = [strongSelf convertMessageId:[concreteItem messageId] fromPeerId:cid];
                    
                    for (TGModernCollectionCell *cell in strongSelf->_collectionView.visibleCells)
                    {
                        TGMessageModernConversationItem *cellItem = [cell boundItem];
                        if (cellItem != nil && cellItem->_message.mid == messageId)
                        {
                            return [cellItem referenceViewForImageTransition];
                        }
                    }
                }
                else if ([item isKindOfClass:[TGSecretPeerMediaGalleryVideoItem class]]) {
                    TGSecretPeerMediaGalleryVideoItem *concreteItem = (TGSecretPeerMediaGalleryVideoItem *)item;
                    int32_t messageId = [strongSelf convertMessageId:[concreteItem messageId] fromPeerId:cid];
                    
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
                strongSelf.companion.mediaHiddenMessageIndex = nil;
                
                for (TGModernCollectionCell *cell in strongSelf->_collectionView.visibleCells)
                {
                    [(TGMessageModernConversationItem *)[cell boundItem] updateMediaVisibility];
                }
            }
        };
        
        modernGallery.animateTransition = true;
        modernGallery.showInterface = !previewMode;
        
        [self closeExistingMediaGallery];
        
        if (!previewMode)
        {
            TGOverlayControllerWindow *controllerWindow = [[TGOverlayControllerWindow alloc] initWithManager:[[TGLegacyComponentsContext shared] makeOverlayWindowManager] parentController:self contentController:modernGallery keepKeyboard:false];
            controllerWindow.hidden = false;
        }
        
        return modernGallery;
    }
    
    return nil;
}

- (void)openLocationFromMessage:(TGMessage *)message previewMode:(bool)previewMode zoomToFitAll:(bool)zoomToFitAll
{
    int64_t peerId = message.fromUid;
    if (message.forwardPeerId != 0)
        peerId = message.forwardPeerId;
    
    id peer = nil;
    if (TGPeerIdIsChannel(peerId))
        peer = [TGDatabaseInstance() loadChannels:@[@(peerId)]][@(peerId)];
    else
        peer = [TGDatabaseInstance() loadUser:(int32_t)peerId];
    
    int64_t conversationId = ((TGGenericModernConversationCompanion *)_companion).conversationId;
    TGConversation *chat = [TGDatabaseInstance() loadConversationWithId:peerId];
    bool isChannel = chat.isChannel && !chat.isChannelGroup;
    bool canPostMessages = [_companion canPostMessages];
    
    [[UIApplication sharedApplication] beginIgnoringInteractionEvents];
    
    TGLocationMediaAttachment *locationAttachment = message.locationAttachment;
    SSignal *sessionSignal = locationAttachment.isLiveLocation ? [[TGTelegraphInstance.liveLocationManager sessionForPeerId:conversationId] take:1] : [SSignal single:nil];
    [[sessionSignal deliverOn:[SQueue mainQueue]] startWithNext:^(TGLiveLocationSession *next)
    {
        __weak TGModernConversationController *weakSelf = self;
        TGLocationViewController *controller = nil;
        TGLiveLocation *initialLiveLocation = nil;
        if (locationAttachment.isLiveLocation)
        {
            int32_t currentTime = (int32_t)[[TGTelegramNetworking instance] globalTime];
            bool isOwnLocation = message.fromUid == TGTelegraphInstance.clientUserId || (isChannel && canPostMessages);
            initialLiveLocation = [[TGLiveLocation alloc] initWithMessage:message peer:peer hasOwnSession:message.mid == next.messageId isOwnLocation:isOwnLocation isExpired:currentTime >= message.date + locationAttachment.period];
            
            controller = [[TGLocationViewController alloc] initWithContext:[TGLegacyComponentsContext shared] liveLocation:initialLiveLocation];
        }
        else
        {
            controller = [[TGLocationViewController alloc] initWithContext:[TGLegacyComponentsContext shared] message:message peer:peer];
        }
        controller.pallete = self.presentation.locationPallete;
        controller.receivingPeer = TGPeerIdIsUser(message.cid) ? [TGDatabaseInstance() loadUser:(int32_t)message.cid] : [TGDatabaseInstance() loadConversationWithId:message.cid];
        controller.allowLiveLocationSharing = [self.companion allowLiveLocations];
        controller.zoomToFitAllLocationsOnScreen = zoomToFitAll;
        
        __weak TGLocationViewController *weakLocationController = controller;
        controller.presentShareMenu = ^bool(TGMenuSheetController *controller, CLLocationCoordinate2D coordinate)
        {
            __strong TGLocationViewController *strongLocationController = weakLocationController;
            if (strongLocationController == nil)
                return false;
            
            NSString *coordinatePair = [NSString stringWithFormat:@"%lf,%lf", coordinate.latitude, coordinate.longitude];
            NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"https://maps.apple.com/maps?ll=%@&q=%@&t=m", coordinatePair, coordinatePair]];
            
            [TGShareMenu presentInParentController:nil menuController:controller buttonTitle:TGLocalized(@"ShareMenu.CopyShareLink") buttonAction:^
            {
                [[UIPasteboard generalPasteboard] setString:url.absoluteString];
            } shareAction:^(NSArray *peerIds, NSString *caption)
            {
                __strong TGLocationViewController *strongLocationController = weakLocationController;
                if (strongLocationController == nil) {
                    return;
                }
                if (strongLocationController.shareAction != nil) {
                    strongLocationController.shareAction(peerIds, caption);
                }
            } externalShareItemSignal:[SSignal single:url] sourceView:strongLocationController.view sourceRect:nil barButtonItem:strongLocationController.navigationItem.rightBarButtonItem];
            
            return true;
        };
        controller.presentOpenInMenu = ^bool(TGLocationViewController *locationController, TGLocationMediaAttachment *locationAttachment, bool directions, void (^share)(TGMenuSheetController *)) {
            if ([TGOpenInMenu hasThirdPartyAppsForLocationAttachment:locationAttachment directions:directions])
            {
                CGRect (^sourceRect)(void) = ^CGRect
                {
                    return CGRectZero;
                };
                if (directions)
                {
                    sourceRect = ^CGRect
                    {
                        return [locationController.directionsButton convertRect:locationController.directionsButton.bounds toView:locationController.view];
                    };
                }
                
                [TGOpenInMenu presentInParentController:locationController menuController:nil title:directions ? TGLocalized(@"Map.GetDirections") : TGLocalized(@"Map.OpenIn") locationAttachment:locationAttachment directions:directions buttonTitle:directions ? nil : TGLocalized(@"Conversation.ContextMenuShare") buttonAction:^(TGMenuSheetController *controller)
                {
                    if (share && controller != nil) {
                        share(controller);
                    }
                } sourceView:locationController.view sourceRect:sourceRect barButtonItem:directions ? nil : locationController.navigationItem.rightBarButtonItem];
                return true;
            } else {
                return false;
            }
        };
        controller.shareAction = ^(NSArray *peerIds, NSString *caption)
        {
            __strong TGModernConversationController *strongSelf = weakSelf;
            if (strongSelf == nil)
                return;
            
            bool isInlineBotMessage = false;
            for (TGDocumentMediaAttachment *attachment in message.mediaAttachments)
            {
                if (attachment.type == TGViaUserAttachmentType)
                {
                    isInlineBotMessage = true;
                    break;
                }
            }
            
            NSMutableArray *finalPeerIds = [[NSMutableArray alloc] init];
            for (NSNumber *peerId in peerIds)
            {
                if (peerId.int64Value == TGTelegraphInstance.clientUserId)
                {
                    [strongSelf broadcastForwardMessages:@[ [TGMessageIndex indexWithPeerId:message.cid messageId:message.mid] ] caption:caption toPeerIds:@[ peerId ] grouped:false];
                    continue;
                }
                [finalPeerIds addObject:peerId];
            }
            
            if (strongSelf->_isChannel || isInlineBotMessage)
                [strongSelf broadcastForwardMessages:@[ [TGMessageIndex indexWithPeerId:message.cid messageId:message.mid] ] caption:caption toPeerIds:finalPeerIds grouped:false];
            else
                [[TGShareSignals shareLocation:locationAttachment toPeerIds:finalPeerIds caption:caption] startWithNext:nil];
            
            [[[TGProgressWindow alloc] init] dismissWithSuccess];
        };
        
        controller.liveLocationStarted = ^(CLLocationCoordinate2D coordinate, int32_t period)
        {
            __strong TGModernConversationController *strongSelf = weakSelf;
            if (strongSelf == nil)
                return;
            
            [strongSelf->_companion controllerWantsToSendMapWithLatitude:coordinate.latitude longitude:coordinate.longitude venue:nil period:period asReplyToMessageId:[strongSelf currentReplyMessageId] botContextResult:nil botReplyMarkup:nil];
        };
        
        controller.liveLocationStopped = ^
        {
            [TGTelegraphInstance.liveLocationManager stopWithPeerId:conversationId];
            
            __strong TGModernConversationController *strongSelf = weakSelf;
            if (strongSelf == nil)
                return;
            
            if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone)
                [strongSelf.navigationController popViewControllerAnimated:true];
            else
                [strongSelf dismissViewControllerAnimated:true completion:nil];
        };
        controller.remainingTimeForMessage = ^SSignal *(TGMessage *message)
        {
            return [TGLiveLocationSignals remainingTimeForMessage:message];
        };
        [controller setLiveLocationsSignal:[[[SSignal combineSignals:@[[[TGTelegraphInstance.liveLocationManager sessionForPeerId:conversationId] map:^id (TGLiveLocationSession *session)
        {
            if (session != nil)
            {
                TGUser *user = [TGDatabaseInstance() loadUser:TGTelegraphInstance.clientUserId];
                TGMessage *message = [TGDatabaseInstance() loadMessageWithMid:session.messageId peerId:session.peerId];
                return [[TGLiveLocation alloc] initWithMessage:message peer:user hasOwnSession:true isOwnLocation:true isExpired:false];
            }
            else
            {
                return [NSNull null];
            }
        }], [TGLiveLocationSignals liveLocationsForPeerId:conversationId includeExpired:false onlyLocal:isChannel]] withInitialStates:@[ initialLiveLocation.hasOwnSession ? initialLiveLocation : @0, @[] ]] filter:^bool(NSArray *results)
        {
            return ![results.firstObject isKindOfClass:[NSNumber class]];
        }] map:^id(NSArray *results)
        {
            TGLiveLocation *ownLiveLocation = ![results.firstObject isKindOfClass:[NSNull class]] ? results.firstObject : nil;
            NSArray *messages = results.lastObject;
            
            int32_t currentTime = (int32_t)[[TGTelegramNetworking instance] globalTime];
            
            NSMutableArray *liveLocations = [[NSMutableArray alloc] init];
            for (TGMessage *message in messages)
            {
                int32_t expires = (int32_t)message.date + message.locationAttachment.period;
                
                id peer = nil;
                int64_t peerId = message.fromUid;
                if (TGPeerIdIsChannel(peerId))
                    peer = [TGDatabaseInstance() loadChannels:@[@(peerId)]][@(peerId)];
                else
                    peer = [TGDatabaseInstance() loadUser:(int32_t)peerId];
                
                bool isOwnLocation = peerId == TGTelegraphInstance.clientUserId || (isChannel && canPostMessages);
                [liveLocations addObject:[[TGLiveLocation alloc] initWithMessage:message peer:peer hasOwnSession:ownLiveLocation.message.mid == message.mid isOwnLocation:isOwnLocation isExpired:currentTime > expires]];
            }
            
            return liveLocations;
        }]];
        controller.openLocation = ^(TGMessage *message)
        {
            __strong TGModernConversationController *strongSelf = weakSelf;
            if (strongSelf == nil)
                return;
            
            [strongSelf openLocationFromMessage:message previewMode:false zoomToFitAll:false];
        };
        controller.onViewDidAppear = ^
        {
            __strong TGLocationViewController *strongLocationController = weakLocationController;
            if (strongLocationController == nil)
                return;
            
            NSMutableArray *controllers = [NSMutableArray arrayWithArray:strongLocationController.navigationController.viewControllers];
            TGViewController *controllerToRemove = nil;
            for (UIViewController *controller in controllers)
            {
                if ([controller isKindOfClass:[TGLocationViewController class]] && controller != strongLocationController)
                {
                    controllerToRemove = (TGLocationViewController *)controller;
                    break;
                }
            }
            if (controllerToRemove != nil)
            {
                [controllers removeObject:controllerToRemove];
                strongLocationController.navigationController.viewControllers = controllers;
            }
        };
        
        if (!previewMode)
        {
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
        }
        else
        {
            controller.previewMode = true;
        }
        
        [[UIApplication sharedApplication] endIgnoringInteractionEvents];
    }];
}

- (bool)playNextUnseenIncomingAudio {
    for (TGMessageModernConversationItem *item in _items.reverseObjectEnumerator)
    {
        if (item->_message.outgoing)
            continue;
        
        bool isVoice = false;
        
        for (id attachment in item->_message.mediaAttachments)
        {
            if ([attachment isKindOfClass:[TGAudioMediaAttachment class]])
            {
                isVoice = true;
                
                break;
            }
            else if ([attachment isKindOfClass:[TGDocumentMediaAttachment class]]) {
                for (id attribute in ((TGDocumentMediaAttachment *)attachment).attributes) {
                    if ([attribute isKindOfClass:[TGDocumentAttributeAudio class]]) {
                        if (((TGDocumentAttributeAudio *)attribute).isVoice) {
                            isVoice = true;
                        }
                    }
                }
                break;
            }
            else if ([attachment isKindOfClass:[TGVideoMediaAttachment class]]) {
                if (((TGVideoMediaAttachment *)attachment).roundMessage) {
                    isVoice = true;
                }
                break;
            }
        }
        
        if (isVoice) {
            if (TGPeerIdIsSecretChat(item->_message.cid)) {
                if (![_companion _isSecretMessageViewed:item->_message.mid]) {
                    _companion.viewContext.playAudioMessageId(item->_message.mid);
                    return true;
                }
            } else {
                if (item->_message.contentProperties[@"contentsRead"] == nil) {
                    _companion.viewContext.playAudioMessageId(item->_message.mid);
                    return true;
                }
            }
        }
    }
    
    return false;
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

- (void)closeMediaFromMessage:(int32_t)__unused messageId peerId:(int64_t)__unused peerId instant:(bool)__unused instant
{
    [self closeExistingMediaGallery];
    
    self.associatedWindowStack = nil;
    
    _companion.mediaHiddenMessageIndex = nil;
    
    for (TGModernCollectionCell *cell in _collectionView.visibleCells)
    {
        [(TGMessageModernConversationItem *)[cell boundItem] updateMediaVisibility];
    }
}

- (void)stopInlineMedia:(int32_t)excludeMid
{
    for (TGMessageModernConversationItem *item in _items)
    {
        [item stopInlineMedia:excludeMid];
    }
}

- (void)resumeInlineMedia
{
    for (TGMessageModernConversationItem *item in _items)
    {
        [item resumeInlineMedia];
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

- (void)showActionsMenuForUnsentMessage:(int32_t)messageId edit:(bool)edit
{
    TGMessageModernConversationItem *unsentMessageItem = nil;
    
    int unsentMessageCount = 0;
    
    int64_t unsentGroupedId = 0;
    NSMutableDictionary *groupedMedia = [[NSMutableDictionary alloc] init];
    for (TGMessageModernConversationItem *messageItem in _items)
    {
        TGMessage *message = messageItem->_message;
        if (message.mid == messageId)
        {
            unsentMessageItem = messageItem;
            unsentGroupedId = message.groupedId;
        }
        
        
        if (message.deliveryState == TGMessageDeliveryStateFailed)
        {
            unsentMessageCount++;
            if (message.groupedId != 0)
            {
                NSMutableArray *groupedItems = groupedMedia[@(message.groupedId)];
                if (groupedItems == nil)
                {
                    groupedItems = [[NSMutableArray alloc] init];
                    groupedMedia[@(message.groupedId)] = groupedItems;
                }
                
                [groupedItems addObject:@(message.mid)];
            }
        }
    }
    
    NSArray *selectedMessageIds = @[ @(messageId) ];
    if (unsentGroupedId != 0)
        selectedMessageIds = [groupedMedia[@(unsentGroupedId)] sortedArrayUsingSelector:@selector(compare:)];
    
    if (unsentMessageItem != nil && unsentMessageCount != 0)
    {
        NSMutableArray *actions = [[NSMutableArray alloc] init];
        
        if (unsentMessageItem->_message.text.length != 0)
            [actions addObject:[[TGActionSheetAction alloc] initWithTitle:TGLocalized(@"Conversation.MessageDialogEdit") action:@"editMessage"]];
        
        [actions addObject:[[TGActionSheetAction alloc] initWithTitle:TGLocalized(@"Conversation.MessageDialogRetry") action:@"resendMessage"]];
        
        if (unsentMessageCount > 1)
            [actions addObject:[[TGActionSheetAction alloc] initWithTitle:[[NSString alloc] initWithFormat:TGLocalized(@"Conversation.MessageDialogRetryAll"), unsentMessageCount] action:@"resendAllMessages"]];
        
        [actions addObject:[[TGActionSheetAction alloc] initWithTitle:TGLocalized(@"Conversation.MessageDialogDelete") action:@"deleteMessage" type:TGActionSheetActionTypeDestructive]];
        
        [actions addObject:[[TGActionSheetAction alloc] initWithTitle:TGLocalized(@"Common.Cancel") action:@"cancel" type:TGActionSheetActionTypeCancel]];
        
        [[[TGCustomActionSheet alloc] initWithTitle:TGLocalized(@"Conversation.MessageDeliveryFailed") actions:actions actionBlock:^(TGModernConversationController *controller, NSString *action)
        {
            if ([action isEqualToString:@"editMessage"])
            {
                [controller.companion _deleteMessages:@[@(messageId)] animated:true];
                [controller.companion controllerDeletedMessages:@[@(messageId)] forEveryone:true completion:nil];
                
                _inputTextPanel.inputField.text = unsentMessageItem->_message.text;
                [self openKeyboard];
            }
            else if ([action isEqualToString:@"resendMessage"])
            {
                [controller.companion controllerWantsToResendMessages:selectedMessageIds];
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
                [controller.companion _deleteMessages:selectedMessageIds animated:true];
                [controller.companion controllerDeletedMessages:selectedMessageIds forEveryone:false completion:nil];
            }
        } target:self] showInView:_view];
    }
}

- (void)highlightAndShowActionsMenuForMessage:(int32_t)messageId peerId:(int64_t)peerId groupedId:(int64_t)groupedId
{
    if (_isRecording)
        return;
    
    TGMessageModernConversationItem *highlightedItem = nil;
    
    for (TGModernCollectionCell *cell in _collectionView.visibleCells)
    {
        TGMessageModernConversationItem *messageItem = cell.boundItem;
        if (messageItem != nil && messageItem->_message.mid == messageId && (peerId == 0 || messageItem->_message.fromUid == peerId))
        {
            CGRect cellFrame = CGRectNull;
            if ((messageItem->_positionFlags & TGMessageGroupPositionLeft && messageItem->_positionFlags & TGMessageGroupPositionTop) && groupedId == 0)
            {
                cellFrame = [[messageItem referenceViewForImageTransition].superview convertRect:[messageItem referenceViewForImageTransition].frame toView:self.view];
            }
            else
            {
                cellFrame = [[cell contentViewForBinding] convertRect:[messageItem fullContentFrame] toView:self.view];
            }
            
            if (CGRectIsNull(cellFrame) || CGRectIsEmpty(cellFrame))
                break;
            
            CGRect contentFrame = CGRectIntersection(cellFrame, CGRectMake(0, 0, _view.frame.size.width, _currentInputPanel == nil ? _view.frame.size.height : _currentInputPanel.frame.origin.y));
            if (CGRectIsNull(contentFrame) || CGRectIsEmpty(contentFrame))
                break;
            
            if (_menuContainerView != nil) {
                [_menuContainerView hideMenu];
                _menuContainerView = nil;
            }
            
            _menuContainerView = [[TGMenuContainerView alloc] init];
            
            if (_menuContainerView.superview != self.view)
                [self.view addSubview:_menuContainerView];
            
            TGActionMediaAttachment *actionInfo = messageItem->_message.actionInfo;
            bool canReply = true;
            if (![_companion allowMessageForwarding]) {
                canReply = actionInfo == nil;
            }
            
            if (actionInfo.actionType == TGMessageActionSecureValuesSent)
                canReply = false;
                
            if (_inputDisabled) {
                canReply = false;
            }
            
            if (_currentInputPanel != _inputTextPanel) {
                if (!([self defaultInputPanel] == _inputTextPanel && [_currentInputPanel isKindOfClass:[TGModernConversationSearchInputPanel class]])) {
                    canReply = false;
                }
            }
            
            bool canModerate = [_companion canModerateMessage:messageItem->_message];
            
            bool canPin = [_companion canPinMessage:messageItem->_message];
            
            bool unpin = false;
            if (canPin) {
                if ([_companion isMessagePinned:messageItem->_message.mid]) {
                    unpin = true;
                }
            }
            
            bool addedPin = false;
            
            TGConversation *conversation = [TGDatabaseInstance() loadConversationWithId:[self peerId]];
            bool canLink = [_companion canCreateLinksToMessages] && conversation.isChannelGroup && (conversation.channelRole == TGChannelRoleCreator || conversation.channelAdminRights.canChangeInviteLink);
            
            NSDictionary *replyAction = nil;
            NSDictionary *copyAction = nil;
            NSDictionary *saveAction = nil;
            NSDictionary *moreAction = nil;
            NSDictionary *editAction = nil;
            NSDictionary *deleteAction = nil;
            NSDictionary *forwardAction = nil;
            NSDictionary *pinAction = nil;
            NSDictionary *sendCallLogAction = nil;
            NSDictionary *banAction = nil;
            NSDictionary *faveAction = nil;
            NSDictionary *copyLinkAction = nil;
            NSDictionary *reportAction = nil;
            NSDictionary *stopLiveLocationAction = nil;
            
            if ([_companion canDeleteMessage:messageItem->_message])
            {
                deleteAction = [[NSDictionary alloc] initWithObjectsAndKeys:TGLocalized(@"Conversation.ContextMenuDelete"), @"title", canModerate ? @"moderate" : @"delete", @"action", @true, @"destructive", @(TGIsPad()), @"keepDim", nil];
            }
            
            if (messageItem->_message.actionInfo == nil && [self canForwardMessage:messageItem->_message])
            {
                forwardAction = [[NSDictionary alloc] initWithObjectsAndKeys:TGLocalized(@"Conversation.ContextMenuForward"), @"title", @"forward", @"action", nil];
            }
            
            if (messageItem->_message.fromUid != messageItem->_message.cid) {
                if ([self isAdminLog] && [((TGAdminLogConversationCompanion *)_companion) canBanUser:(int32_t)messageItem->_message.fromUid]) {
                    banAction = [[NSDictionary alloc] initWithObjectsAndKeys:TGLocalized(@"Conversation.ContextMenuBan"), @"title", @"ban", @"action", nil];
                }
            }
            
            if (canReply && [_companion allowReplies] && messageItem->_message.cid == [self peerId] && messageItem->_message.deliveryState != TGMessageDeliveryStateFailed && (messageItem->_message.mid < TGMessageLocalMidBaseline || ![_companion allowMessageForwarding]))
            {
                replyAction = [[NSDictionary alloc] initWithObjectsAndKeys:TGLocalized(@"Conversation.ContextMenuReply"), @"title", @"reply", @"action", nil];
                
                if ([_companion canEditMessage:messageItem->_message] && groupedId == 0) {
                    editAction = [[NSDictionary alloc] initWithObjectsAndKeys:TGLocalized(@"Conversation.Edit"), @"title", @"edit", @"action", nil];
                    
                    _currentEditingMessageContext = [[SVariable alloc] init];
                    [_currentEditingMessageContext set:[_companion editingContextForMessageWithId:messageItem->_message.mid]];
                }
            }
            else if (messageItem->_message.cid == [self peerId])
            {
                if ([_companion canEditMessage:messageItem->_message] && groupedId == 0) {
                    editAction = [[NSDictionary alloc] initWithObjectsAndKeys:TGLocalized(@"Conversation.Edit"), @"title", @"edit", @"action", nil];
                    
                    _currentEditingMessageContext = [[SVariable alloc] init];
                    [_currentEditingMessageContext set:[_companion editingContextForMessageWithId:messageItem->_message.mid]];
                }
            }
            
            bool hasCaption = messageItem->_message.caption.length > 0;
            bool isDocument = false;
            bool isAnimation = false;
            int64_t remoteDocumentId = 0;
            id<TGStickerPackReference> stickerPackReference = nil;
            TGDocumentMediaAttachment *document = nil;
            TGImageMediaAttachment *photo = nil;
            bool isLiveLocation = false;
            for (id attachment in messageItem->_message.mediaAttachments)
            {
                if ([attachment isKindOfClass:[TGDocumentMediaAttachment class]])
                {
                    document = attachment;
                    
                    remoteDocumentId = document.documentId;
                    
                    isAnimation = [document isAnimated] && ([document.mimeType isEqualToString:@"video/mp4"]);
                    
                    NSString *localFilePath = [[_companion fileUrlForDocumentMedia:attachment] path];
                    if ([[NSFileManager defaultManager] fileExistsAtPath:localFilePath isDirectory:NULL])
                        isDocument = true;
                    for (id attribute in ((TGDocumentMediaAttachment *)attachment).attributes)
                    {
                        if ([attribute isKindOfClass:[TGDocumentAttributeSticker class]]) {
                            stickerPackReference = ((TGDocumentAttributeSticker *)attribute).packReference;
                        }
                    }
                    break;
                }
                else if ([attachment isKindOfClass:[TGActionMediaAttachment class]])
                {
                    TGActionMediaAttachment *action = (TGActionMediaAttachment *)attachment;
                    TGCallDiscardReason reason = (TGCallDiscardReason)[action.actionData[@"reason"] intValue];
                    if (action.actionType == TGMessageActionPhoneCall && action.actionData[@"callId"] != nil && reason != TGCallDiscardReasonBusy && reason != TGCallDiscardReasonMissed)
                    {
                        NSString *path = [[TGAppDelegate documentsPath] stringByAppendingPathComponent:@"calls"];
                        NSMutableArray *logs = [[[NSFileManager defaultManager] contentsOfDirectoryAtPath:path error:nil] mutableCopy];
                        NSString *logPrefix = [NSString stringWithFormat:@"%lld-", [action.actionData[@"callId"] int64Value]];
                        for (NSString *log in logs)
                        {
                            if ([log hasPrefix:logPrefix])
                            {
                                NSString *accessHash = [log substringWithRange:NSMakeRange(logPrefix.length, log.length - logPrefix.length - 4)];
                                sendCallLogAction = [[NSDictionary alloc] initWithObjectsAndKeys:TGLocalized(@"Call.RateCall"), @"title", @"sendCallLog", @"action", @ {@"accessHash": @([accessHash integerValue]) }, @"userInfo", nil];
                                break;
                            }
                        }
                    }
                }
                else if ([attachment isKindOfClass:[TGLocationMediaAttachment class]])
                {
                    TGLocationMediaAttachment *location = (TGLocationMediaAttachment *)attachment;
                    if (location.period > 0)
                    {
                        isLiveLocation = true;
                        
                        if (messageItem->_message.fromUid == TGTelegraphInstance.clientUserId && [[TGTelegramNetworking instance] globalTime] < messageItem->_message.date + location.period)
                        {
                            stopLiveLocationAction = [[NSDictionary alloc] initWithObjectsAndKeys:TGLocalized(@"Conversation.StopLiveLocation"), @"title", @"stopLiveLocation", @"action", nil];
                        }
                    }
                    break;
                }
                else if ([attachment isKindOfClass:[TGImageMediaAttachment class]])
                {
                    photo = (TGImageMediaAttachment *)attachment;
                    break;
                }
            }
            
            bool addedForward = false;
            if (TGPeerIdIsChannel(messageItem->_message.fromUid) && [_companion allowReplies]) {
                addedForward = true;
            }
            
            if (!addedForward && TGPeerIdIsChannel(messageItem->_message.fromUid) && messageItem->_message.actionInfo == nil && messageItem->_message.messageLifetime == 0 && !isLiveLocation) {
                addedForward = true;
                copyAction = nil;
            }
            
            if (isAnimation && remoteDocumentId != 0) {
                if (iosMajorVersion() >= 8) {
                    saveAction = [[NSDictionary alloc] initWithObjectsAndKeys:TGLocalized(@"Preview.SaveGif"), @"title", @"saveGif", @"action", nil];
                }
            }
            
            if (!isLiveLocation)
            {
                if (messageItem->_message.text.length != 0 || hasCaption || (photo != nil && messageItem->_mediaAvailabilityStatus)) {
                    copyAction = [[NSDictionary alloc] initWithObjectsAndKeys:TGLocalized(@"Conversation.ContextMenuCopy"), @"title", @"copy", @"action", nil];
                } else if (stickerPackReference != nil)
                {
                    if ([TGStickersSignals isStickerPackInstalled:stickerPackReference])
                    {
                        saveAction = [[NSDictionary alloc] initWithObjectsAndKeys:TGLocalized(@"StickerPack.ViewPack"), @"title", @"stickerPackInfo", @"action", nil];
                    }
                    else if ([TGMaskStickersSignals isStickerPackInstalled:stickerPackReference])
                    {
                        saveAction = [[NSDictionary alloc] initWithObjectsAndKeys:TGLocalized(@"StickerPack.ViewPack"), @"title", @"stickerPackInfo", @"action", nil];
                    }
                    else
                    {
                        saveAction = [[NSDictionary alloc] initWithObjectsAndKeys:TGLocalized(@"Conversation.ContextMenuStickerPackAdd"), @"title", @"stickerPackInfo", @"action", nil];
                    }
                }
                else if (messageItem->_message.actionInfo == nil && [_companion allowMessageForwarding] && !addedForward && messageItem->_message.messageLifetime == 0) {
                    copyAction = nil;
                }
            }
            
            if (messageItem->_message.actionInfo == nil && ![self isAdminLog]) {
                moreAction = [[NSDictionary alloc] initWithObjectsAndKeys:TGLocalized(@"Conversation.ContextMenuMore"), @"title", @"select", @"action", nil];
            }
            
            if (!addedPin && messageItem->_message.actionInfo == nil && canPin) {
                pinAction = [[NSDictionary alloc] initWithObjectsAndKeys:unpin ? TGLocalized(@"Conversation.Unpin") : TGLocalized(@"Conversation.Pin"), @"title", unpin ? @"unpin" : @"pin", @"action", nil];
                addedPin = true;
            }
            
            if (canLink && messageItem->_message.actionInfo == nil) {
                copyLinkAction = [[NSDictionary alloc] initWithObjectsAndKeys:TGLocalized(@"Conversation.ContextMenuCopyLink"), @"title", @"copyLink", @"action", nil];
            }
            
            if ([_companion canReportMessage:messageItem->_message]) {
                reportAction = [[NSDictionary alloc] initWithObjectsAndKeys:TGLocalized(@"Conversation.ContextMenuReport"), @"title", @"report", @"action", nil];
            }
            
            NSMutableArray *actions = [[NSMutableArray alloc] init];
            NSMutableArray *menuActions = [[NSMutableArray alloc] init];
            
            if ([messageItem->_message hasExpiredMedia]) {
                replyAction = nil;
                copyAction = nil;
                saveAction = nil;
                moreAction = nil;
                editAction = nil;
                pinAction = nil;
                sendCallLogAction = nil;
                banAction = nil;
            }
            
            if (messageItem->_message.messageLifetime > 0 && messageItem->_message.messageLifetime <= 60) {
                copyAction = nil;
                saveAction = nil;
            }
            
            if (moreAction != nil) {
                NSMutableDictionary *updatedMoreAction = [[NSMutableDictionary alloc] initWithDictionary:moreAction];
                updatedMoreAction[@"trailing"] = @true;
                moreAction = updatedMoreAction;
                [actions addObject:moreAction];
            }
            
            if (faveAction != nil) {
                [menuActions addObject:faveAction];
            }
            
            if (replyAction != nil) {
                [actions addObject:replyAction];
            }
            
            if (stopLiveLocationAction != nil) {
                [menuActions addObject:stopLiveLocationAction];
            }
            
            if (copyAction != nil) {
                [actions addObject:copyAction];
            }
            
            if (saveAction != nil) {
                [menuActions addObject:saveAction];
            }
            
            if (pinAction != nil) {
                [menuActions addObject:pinAction];
            }
            
            if (editAction != nil) {
                [menuActions addObject:editAction];
            }
            
            if (sendCallLogAction != nil) {
                [menuActions addObject:sendCallLogAction];
            }
            
            if (copyLinkAction != nil) {
                [menuActions addObject:copyLinkAction];
            }
            
            if (forwardAction != nil) {
                [menuActions addObject:forwardAction];
            }
            
            if (reportAction != nil) {
                [menuActions addObject:reportAction];
            }
            
            if (deleteAction != nil) {
                if (messageItem->_message.actionInfo == nil && ![messageItem->_message hasExpiredMedia])
                    [menuActions addObject:deleteAction];
                else
                    [actions addObject:deleteAction];
            }
            
            if (banAction != nil) {
                [menuActions addObject:banAction];
            }
            
            if (TGIsArabic())
            {
                NSMutableArray *reversedActions = [[NSMutableArray alloc] init];
                for (id item in actions.reverseObjectEnumerator)
                {
                    [reversedActions addObject:item];
                }
                actions = reversedActions;
            }
            
            if (actions.count > 0 || menuActions.count > 0)
            {
                [_feedbackGenerator impactOccurred];
            
                if (self.willChangeDim != nil)
                    self.willChangeDim(true, [_inputTextPanel keyboardSnapshotView], false);
            }
            
            void (^displayBlock)(void) = ^
            {
                CGRect frame = [self.navigationController.navigationBar convertRect:self.navigationController.navigationBar.bounds toView:self.navigationController.view];
                if (frame.origin.y > FLT_EPSILON)
                    frame = CGRectMake(frame.origin.x, 0.0f, frame.size.width, frame.size.height + frame.origin.y);
                CGFloat additionalHeight = ((TGNavigationController *)self.navigationController).currentAdditionalNavigationBarHeight;
                if (_primaryTitlePanel.frame.origin.y > -FLT_EPSILON)
                    additionalHeight += _primaryTitlePanel.frame.size.height;
                if (_secondaryTitlePanel.frame.origin.y > -FLT_EPSILON)
                    additionalHeight += _secondaryTitlePanel.frame.size.height;
                CGFloat topHeight = frame.size.height + additionalHeight;
                
                CGRect cellFrame = CGRectNull;
                if ((messageItem->_positionFlags & TGMessageGroupPositionLeft && messageItem->_positionFlags & TGMessageGroupPositionTop) && groupedId == 0)
                    cellFrame = [[messageItem referenceViewForImageTransition].superview convertRect:[messageItem referenceViewForImageTransition].frame toView:self.view];
                else
                    cellFrame = [[cell contentViewForBinding] convertRect:[messageItem fullContentFrame] toView:self.view];
                CGRect contentFrame = CGRectIntersection(cellFrame, CGRectMake(0, 0, _view.frame.size.width, _currentInputPanel == nil ? _view.frame.size.height : _currentInputPanel.frame.origin.y));
                
                NSDictionary *userInfo = groupedId != 0 ? @{@"mid": @(messageId), @"peerId": @(peerId), @"groupedId": @(groupedId)} : @{@"mid": @(messageId), @"peerId": @(peerId)};
                
                CGFloat offset = 0.0f;
                CGFloat height = 0.0f;
                if (menuActions.count != 0)
                {
                    TGMenuSheetController *controller = [[TGMenuSheetController alloc] initWithContext:[TGLegacyComponentsContext shared] dark:false];
                    _contextMenuController = controller;
                    controller.requiuresDimView = actions.count == 0;
                    controller.dismissesByOutsideTap = actions.count == 0;
                    controller.inhibitPopoverPresentation = true;
                    controller.requiresShadow = true;
                    controller.stickWithSpecifiedParentController = TGIsPad();
                    
                    __weak TGModernConversationController *weakSelf = self;
                    NSMutableArray *itemViews = [[NSMutableArray alloc] init];
                    for (NSDictionary *action in menuActions)
                    {
                        TGMenuSheetButtonItemView *item = [[TGMenuSheetButtonItemView alloc] initWithTitle:action[@"title"] type:[action[@"destructive"] boolValue] ? TGMenuSheetButtonTypeDestructive : TGMenuSheetButtonTypeDefault action:^
                        {
                            __strong TGModernConversationController *strongSelf = weakSelf;
                            if (strongSelf == nil)
                                return;
                            
                            NSMutableDictionary *options = [[NSMutableDictionary alloc] init];
                            options[@"action"] = action[@"action"];
                            if (userInfo != nil)
                                options[@"userInfo"] = userInfo;
                            [strongSelf->_actionHandle requestAction:@"menuAction" options:options];
                            
                            if ([action[@"keepDim"] boolValue])
                                strongSelf->_keepDim = true;
                            
                            [strongSelf->_menuContainerView hideMenu];
                        }];
                        [itemViews addObject:item];
                    }
                    
                    [controller setItemViews:itemViews animated:false];
                    [controller presentInViewController:self sourceView:self.view animated:true];
                    
                    height = controller.menuHeight + controller.safeAreaInset.bottom;
                    CGFloat bottomEdge = MIN(CGRectGetMinY(_currentInputPanel.frame) - 6.0f, self.view.frame.size.height - height);
                    if (CGRectGetMaxY(cellFrame) > bottomEdge)
                    {
                        offset = MAX(0.0f, CGRectGetMaxY(cellFrame) - bottomEdge);
                        if (cellFrame.origin.y < topHeight)
                        {
                            offset = 0.0f;
                        }
                        else if (cellFrame.origin.y - offset < topHeight)
                        {
                            if (cellFrame.origin.y > bottomEdge)
                                offset = cellFrame.origin.y - bottomEdge + 88.0f;
                            else
                                offset = 0.0f;
                        }
                        
                        if (offset > FLT_EPSILON)
                        {
                            CGFloat appliedOffset = offset;
                            if (_keyboardHeight > FLT_EPSILON)
                            {
                                appliedOffset += _keyboardHeight;
                                _collectionViewIgnoresNextKeyboardHeightChange = true;
                            }
                            else if (_currentInputPanel == _inputTextPanel && _inputTextPanel.customKeyboardHeight < FLT_EPSILON)
                            {
                                appliedOffset += self.controllerSafeAreaInset.bottom;
                            }
                            
                            [self _adjustCollectionViewForSize:self.view.bounds.size keyboardHeight:appliedOffset inputContainerHeight:[_currentInputPanel currentHeight] duration:0.2 animationCurve:7];
                            _pushedContents = true;
                        }
                    }
                    
                    if (_currentInputPanel == _inputTextPanel)
                        [_inputTextPanel prepareForResultPreviewAppearance:false];
                }
                
                if (actions.count != 0)
                {
                    CGRect menuRect = contentFrame;
                    
                    _menuContainerView.frame = CGRectMake(0.0f, topHeight, _view.frame.size.width, _view.frame.size.height - topHeight - height);
                    [_menuContainerView.menuView setUserInfo:userInfo];
                    [_menuContainerView.menuView setButtonsAndActions:actions watcherHandle:_actionHandle];
                    [_menuContainerView.menuView sizeToFitToWidth:MIN(_view.frame.size.width, _view.frame.size.height)];
                    
                    void (^block)(void) = ^
                    {
                        CGRect rect = [_menuContainerView convertRect:menuRect fromView:self.view];
                        rect.origin.y += 8.0f - offset;
                        rect.size.height -= 18.0f;
                        [_menuContainerView showMenuFromRect:rect];
                    };
                    
                    if (fabs(offset) > FLT_EPSILON)
                        TGDispatchAfter(0.15, dispatch_get_main_queue(), block);
                    else
                        block();
                    
                    if (groupedId != 0)
                    {
                        NSMutableArray *messageItems = [[NSMutableArray alloc] init];
                        for (TGModernCollectionCell *cell in _collectionView.visibleCells)
                        {
                            TGMessageModernConversationItem *subMessageItem = cell.boundItem;
                            if (subMessageItem != nil && subMessageItem->_message.groupedId == groupedId)
                            {
                                [messageItems addObject:subMessageItem];
                            }
                        }
                        if (messageItems.count > 0)
                        {
                            [messageItems sortUsingComparator:^NSComparisonResult(TGMessageModernConversationItem *obj1, TGMessageModernConversationItem *obj2) {
                                if (obj1->_message.mid < obj2->_message.mid)
                                    return NSOrderedAscending;
                                else
                                    return NSOrderedDescending;
                            }];
                            [self focusOnMessages:messageItems animated:true];
                        }
                    }
                    else
                    {
                        _companion.focusedOnMessageIndex = [TGMessageIndex indexWithPeerId:peerId messageId:messageId];
                        for (TGModernCollectionCell *cell in _collectionView.visibleCells)
                        {
                            [(TGMessageModernConversationItem *)[cell boundItem] updateMessageFocus];
                        }
                        
                        [self focusOnMessages:@[messageItem] animated:true];
                    }
                    if (_contextMenuController.view.superview == self.view)
                        [self.view insertSubview:_menuContainerView belowSubview:_contextMenuController.view];
                    else
                        [self.view bringSubviewToFront:_menuContainerView];
                }
            };
            
            if (_searchBar.isFirstResponder)
            {
                [_searchBar resignFirstResponder];
                dispatch_async(dispatch_get_main_queue(), displayBlock);
            }
            else
            {
                displayBlock();
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

- (void)focusOnMessages:(NSArray *)messageItems animated:(bool)animated
{
    if (_topDimView == nil)
    {
        _topDimView = [[UIButton alloc] init];
        _topDimView.alpha = 0.0f;
        _topDimView.backgroundColor = [UIColor colorWithWhite:0.0f alpha:0.4f];
        [_topDimView addTarget:self action:@selector(dimViewPressed) forControlEvents:UIControlEventTouchDown];
        
        CGRect frame = [self.navigationController.navigationBar convertRect:self.navigationController.navigationBar.bounds toView:self.navigationController.view];
        if (frame.origin.y > FLT_EPSILON)
            frame = CGRectMake(frame.origin.x, 0.0f, frame.size.width, frame.size.height + frame.origin.y);
        CGFloat additionalHeight = ((TGNavigationController *)self.navigationController).currentAdditionalNavigationBarHeight;
        if (_primaryTitlePanel.frame.origin.y > -FLT_EPSILON)
            additionalHeight += _primaryTitlePanel.frame.size.height;
        if (_secondaryTitlePanel.frame.origin.y > -FLT_EPSILON)
            additionalHeight += _secondaryTitlePanel.frame.size.height;
        CGFloat topHeight = frame.size.height + additionalHeight;
        CGFloat safeAreaInset = self.controllerSafeAreaInset.top;
        CGRect topDimViewFrame = CGRectMake(frame.origin.x, frame.origin.y - safeAreaInset, frame.size.width, topHeight + safeAreaInset);
        
        CGRect searchBarRect = [_view convertRect:_searchBar.frame toView:self.navigationController.view];
        if (CGRectGetMaxY(searchBarRect) > CGRectGetMaxY(topDimViewFrame))
            topDimViewFrame.size.height += CGRectGetMaxY(searchBarRect) - CGRectGetMaxY(topDimViewFrame);
        
        _topDimView.frame = topDimViewFrame;
        [self.navigationController.view addSubview:_topDimView];
        
        _bottomDimView = [[UIButton alloc] init];
        _bottomDimView.alpha = 0.0f;
        _bottomDimView.backgroundColor = [UIColor colorWithWhite:0.0f alpha:0.4f];
        [_bottomDimView addTarget:self action:@selector(dimViewPressed) forControlEvents:UIControlEventTouchDown];
        
        frame = [_currentInputPanel convertRect:_currentInputPanel.bounds toView:self.view];
        _bottomDimView.frame = CGRectMake(frame.origin.x, frame.origin.y - TGScreenPixel, frame.size.width, _currentInputPanel.currentHeight + self.controllerSafeAreaInset.bottom + TGScreenPixel);
        
        if (!UIEdgeInsetsEqualToEdgeInsets(self.controllerSafeAreaInset, UIEdgeInsetsZero))
        {
            CGRect topDimViewFrame = [self.navigationController.view convertRect:_topDimView.frame toView:self.view];
            
            _leftDimView = [[UIButton alloc] init];
            _leftDimView.alpha = 0.0f;
            _leftDimView.backgroundColor = [UIColor colorWithWhite:0.0f alpha:0.4f];
            _leftDimView.frame = CGRectMake(-100.0f, CGRectGetMaxY(topDimViewFrame), 100.0f + _collectionView.frame.origin.x, CGRectGetMinY(_bottomDimView.frame) - CGRectGetMaxY(topDimViewFrame));
            [_leftDimView addTarget:self action:@selector(dimViewPressed) forControlEvents:UIControlEventTouchDown];
            [self.view addSubview:_leftDimView];
            
            _rightDimView = [[UIButton alloc] init];
            _rightDimView.alpha = 0.0f;
            _rightDimView.backgroundColor = [UIColor colorWithWhite:0.0f alpha:0.4f];
            _rightDimView.frame = CGRectMake(CGRectGetMaxX(_collectionView.frame), CGRectGetMaxY(topDimViewFrame), 100.0f + self.view.frame.size.width - CGRectGetMaxX(_collectionView.frame), CGRectGetMinY(_bottomDimView.frame) - CGRectGetMaxY(topDimViewFrame));
            [_rightDimView addTarget:self action:@selector(dimViewPressed) forControlEvents:UIControlEventTouchDown];
            [self.view addSubview:_rightDimView];
        }
        
        if (_contextMenuController.view.superview == self.view)
            [self.view insertSubview:_bottomDimView belowSubview:_contextMenuController.view];
        else
            [self.view addSubview:_bottomDimView];
    }
    
    if (messageItems.count > 1)
    {
        NSMutableArray *frontCells = [[NSMutableArray alloc] init];
        for (TGMessageModernConversationItem *item in messageItems)
        {
            if (item.boundCell != nil)
                [frontCells addObject:item.boundCell];
        }
        [_collectionView setDimmed:true frontCells:frontCells animated:animated];
    }
    else
    {
        TGMessageModernConversationItem *messageItem = messageItems.firstObject;
        if (messageItem->_positionFlags & TGMessageGroupPositionLeft && messageItem->_positionFlags & TGMessageGroupPositionTop)
        {
            [_collectionView setDimmed:true frontCells:nil animated:animated];
            UIView *referenceView = [messageItem referenceViewForImageTransition];
            _selectionSnapshotview = [referenceView snapshotViewAfterScreenUpdates:false];
            _selectionSnapshotview.frame = [referenceView.superview convertRect:referenceView.frame toView:_collectionView];
            _selectionSnapshotview.transform = referenceView.superview.transform;
            [_collectionView addSubview:_selectionSnapshotview];
        }
        else
        {
            [_collectionView setDimmed:true frontCells:@[messageItem.boundCell] animated:animated];
        }
    }
    
    void (^changeBlock)(void) = ^
    {
        _topDimView.alpha = 1.0f;
        _bottomDimView.alpha = _topDimView.alpha;
        _leftDimView.alpha = _topDimView.alpha;
        _rightDimView.alpha = _topDimView.alpha;
        _scrollButtons.alpha = 0.0f;
    };
    
    if (animated)
        [UIView animateWithDuration:0.2f animations:changeBlock];
    else
        changeBlock();
}

- (void)unfocusMessagesAnimated:(bool)animated
{
    if (_keepDim) {
        _keepDim = false;
        return;
    }
    UIView *topDimView = _topDimView;
    UIView *bottomDimView = _bottomDimView;
    UIView *leftDimView = _leftDimView;
    UIView *rightDimView = _rightDimView;
    
    _topDimView = nil;
    _bottomDimView = nil;
    _leftDimView = nil;
    _rightDimView = nil;
    
    void (^changeBlock)(void) = ^
    {
        topDimView.alpha = 0.0f;
        bottomDimView.alpha = topDimView.alpha;
        leftDimView.alpha = topDimView.alpha;
        rightDimView.alpha = topDimView.alpha;
        _selectionSnapshotview.alpha = 0.0f;
        _scrollButtons.alpha = 1.0f;
    };
    
    void (^completionBlock)(BOOL) = ^(__unused BOOL finished)
    {
        [topDimView removeFromSuperview];
        [bottomDimView removeFromSuperview];
        [leftDimView removeFromSuperview];
        [rightDimView removeFromSuperview];
        
        [_selectionSnapshotview removeFromSuperview];
        _selectionSnapshotview = nil;
    };
    
    if (animated)
    {
        [UIView animateWithDuration:0.2f animations:changeBlock completion:completionBlock];
    }
    else
    {
        changeBlock();
        completionBlock(true);
    }
    
    if (_contextMenuController != nil || _menuController != nil || _pushedContents)
    {
        [self _adjustCollectionViewForSize:self.view.bounds.size keyboardHeight:_keyboardHeight inputContainerHeight:[_currentInputPanel currentHeight] duration:0.2 animationCurve:7];
        
        if (_currentInputPanel == _inputTextPanel)
            [_inputTextPanel prepareForResultPreviewDismissal:true];
    }
    _pushedContents = false;
    
    if (self.willChangeDim != nil)
        self.willChangeDim(false, nil, [_inputTextPanel willRestoreFocus]);
    
    [_collectionView setDimmed:false frontCells:nil animated:animated];
    [_contextMenuController dismissAnimated:animated];
    
    _companion.focusedOnMessageIndex = nil;
    for (TGModernCollectionCell *cell in _collectionView.visibleCells)
    {
        [(TGMessageModernConversationItem *)[cell boundItem] updateMessageFocus];
    }
}

- (void)dimViewPressed
{
    [_menuContainerView hideMenu];
}

- (void)temporaryHighlightMessage:(int32_t)messageId automatically:(bool)automatically
{
    [self temporaryHighlightMessage:messageId grouped:false automatically:automatically];
}

- (void)temporaryHighlightMessage:(int32_t)messageId grouped:(bool)grouped automatically:(bool)automatically
{
    NSMutableDictionary *groupedItems = [[NSMutableDictionary alloc] init];
    
    for (TGMessageModernConversationItem *item in _items)
    {
        if (grouped && item->_message.groupedId != 0)
        {
            int64_t groupedId = item->_message.groupedId;
            NSMutableArray *items = groupedItems[@(groupedId)];
            if (items == nil)
            {
                items = [[NSMutableArray alloc] init];
                groupedItems[@(groupedId)] = items;
            }
            
            [items addObject:item];
        }
        
        if (item->_message.mid == messageId)
        {
            _temporaryHighlightMessageIdUponDisplay = 0;
            
            if (item->_message.groupedId != 0 && grouped)
            {
                NSArray *items = groupedItems[@(item->_message.groupedId)];
                for (TGMessageModernConversationItem *item in items)
                {
                    [item setTemporaryHighlighted:true viewStorage:_viewStorage];
                }
                
                if (automatically)
                {
                    TGDispatchAfter(0.7, dispatch_get_main_queue(), ^
                    {
                        for (TGMessageModernConversationItem *item in items)
                        {
                            [item setTemporaryHighlighted:false viewStorage:_viewStorage];
                        }
                    });
                }
            }
            else
            {
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
}

- (void)showActionsMenuForLink:(NSString *)url webPage:(TGWebPageMediaAttachment *)webPage
{
    if (url.length == 0)
        return;

    if ([url hasPrefix:@"tel:"])
    {
        TGCustomActionSheet *actionSheet = [[TGCustomActionSheet alloc] initWithTitle:url.length < 70 ? url : [[url substringToIndex:70] stringByAppendingString:@"..."] actions:@
                                      [
                                       [[TGActionSheetAction alloc] initWithTitle:TGLocalized(@"UserInfo.PhoneCall") action:@"call"],
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
        else if ([url hasPrefix:@"cashtag://"])
            displayString = [@"$" stringByAppendingString:[url substringFromIndex:@"cashtag://".length]];
        else if ([url hasPrefix:@"mention://"])
            displayString = [@"@" stringByAppendingString:[url substringFromIndex:@"mention://".length]];
        
        bool isProxyLink = false;
        NSURL *link = [NSURL URLWithString:url];
        if (link.scheme.length == 0)
            link = [NSURL URLWithString:[@"http://" stringByAppendingString:url]];
        
        if (([link.scheme isEqualToString:@"tg"] || [link.scheme isEqualToString:@"telegram"]) && ([link.host isEqualToString:@"socks"] || [link.host isEqualToString:@"proxy"]))
            isProxyLink = true;
        
        bool useOpenIn = false;
        bool isWeblink = false;
        if ([link.scheme isEqualToString:@"http"] || [link.scheme isEqualToString:@"https"])
        {
            isWeblink = true;
            if ([TGOpenInMenu hasThirdPartyAppsForURL:link])
                useOpenIn = true;
        }
        
        NSMutableArray *actions = [[NSMutableArray alloc] init];
        if (useOpenIn)
        {
            TGActionSheetAction *openInAction = [[TGActionSheetAction alloc] initWithTitle:TGLocalized(@"Conversation.FileOpenIn") action:@"openIn"];
            openInAction.disableAutomaticSheetDismiss = true;
            [actions addObject:openInAction];
        }
        else
        {
            [actions addObject:[[TGActionSheetAction alloc] initWithTitle:TGLocalized(@"Conversation.LinkDialogOpen") action:@"open"]];
        }
        [actions addObject:[[TGActionSheetAction alloc] initWithTitle:TGLocalized(@"Conversation.LinkDialogCopy") action:@"copy"]];
        
        if (isProxyLink)
            [actions addObject:[[TGActionSheetAction alloc] initWithTitle:TGLocalized(@"SocksProxySetup.SaveProxy") action:@"saveProxy"]];
    
        
        if (webPage != nil && webPage.document != nil && ([webPage.document.mimeType isEqualToString:@"video/mp4"]) && [webPage.document isAnimated]) {
            if (!TGIsPad() && iosMajorVersion() >= 8) {
                [actions addObject:[[TGActionSheetAction alloc] initWithTitle:TGLocalized(@"Conversation.LinkDialogSave") action:@"saveGif"]];
            }
        }
        
        if (isWeblink && iosMajorVersion() >= 7)
        {
            [actions addObject:[[TGActionSheetAction alloc] initWithTitle:TGLocalized(@"Conversation.AddToReadingList") action:@"addToReadingList"]];
        }
        
        [actions addObject:[[TGActionSheetAction alloc] initWithTitle:TGLocalized(@"Common.Cancel") action:@"cancel" type:TGActionSheetActionTypeCancel]];
        
        TGCustomActionSheet *actionSheet = [[TGCustomActionSheet alloc] initWithTitle:displayString.length < 70 ? displayString : [[displayString substringToIndex:70] stringByAppendingString:@"..."] actions:actions menuController:nil advancedActionBlock:^(TGMenuSheetController *menuController, TGModernConversationController *controller, NSString *action)
        {
            if ([action isEqualToString:@"open"])
            {
                [controller openBrowserFromMessage:0 url:url];
            }
            else if ([action isEqualToString:@"openIn"])
            {
                [TGOpenInMenu presentInParentController:self menuController:menuController title:TGLocalized(@"Map.OpenIn") url:link buttonTitle:nil buttonAction:nil sourceView:self.view sourceRect:nil barButtonItem:nil];
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
                    else if ([url hasPrefix:@"cashtag://"])
                        copyString = [@"$" stringByAppendingString:[url substringFromIndex:@"cashtag://".length]];
                    else if ([url hasPrefix:@"mention://"])
                        copyString = [@"@" stringByAppendingString:[url substringFromIndex:@"mention://".length]];
                    [pasteboard setString:copyString];
                }
            }
            else if ([action isEqualToString:@"addToReadingList"])
            {
                [[SSReadingList defaultReadingList] addReadingListItemWithURL:[NSURL URLWithString:url] title:webPage.title previewText:nil error:NULL];
            }
            else if ([action isEqualToString:@"saveGif"]) {
                [TGRecentGifsSignal addRecentGifFromDocument:webPage.document];
                [controller maybeDisplayGifTooltip];
            } else if ([action isEqualToString:@"saveProxy"]) {
                NSDictionary *dict = [TGStringUtils argumentDictionaryInUrlString:[link query]];
                if ([dict[@"server"] respondsToSelector:@selector(characterAtIndex:)] && [dict[@"port"] respondsToSelector:@selector(intValue)]) {
                    NSString *username = nil;
                    NSString *password = nil;
                    NSString *secret = nil;
                    
                    if ([dict[@"user"] respondsToSelector:@selector(characterAtIndex:)] && [dict[@"pass"] respondsToSelector:@selector(characterAtIndex:)]) {
                        username = dict[@"user"];
                        password = dict[@"pass"];
                    } else if ([dict[@"secret"] respondsToSelector:@selector(characterAtIndex:)]) {
                        secret = dict[@"secret"];
                    }
                    
                    TGProxyItem *proxy = [[TGProxyItem alloc] initWithServer:dict[@"server"] port:(uint16_t)[dict[@"port"] intValue] username:username password:password secret:secret];
                    [TGProxySignals saveProxy:proxy];
                    
                    [[[TGProgressWindow alloc] init] dismissWithSuccess];
                }
            }
        } target:self];
        [actionSheet showInView:self.view];
    }
}

- (void)showActionsMenuForContact:(TGUser *)contact isContact:(bool)isContact
{
    NSMutableArray *actions = [[NSMutableArray alloc] init];
    
    TGContactMediaAttachment *attachment = contact.customProperties[@"contact"];
    if (attachment.vcard.length > 0)
        [actions addObject:[[TGActionSheetAction alloc] initWithTitle:TGLocalized(@"Conversation.ViewContact") action:@"viewContact"]];
    
    if (!isContact)
        [actions addObject:[[TGActionSheetAction alloc] initWithTitle:TGLocalized(@"Conversation.AddContact") action:@"addContact"]];
    
    if (contact.uid > 0) {
        [actions addObject:[[TGActionSheetAction alloc] initWithTitle:TGLocalized(@"Conversation.SendMessage") action:@"sendMessage"]];
        [actions addObject:[[TGActionSheetAction alloc] initWithTitle:TGLocalized(@"UserInfo.TelegramCall") action:@"telegramCall"]];
    }
    
    [actions addObject:[[TGActionSheetAction alloc] initWithTitle:TGLocalized(@"UserInfo.PhoneCall") action:@"call"]];
    [actions addObject:[[TGActionSheetAction alloc] initWithTitle:TGLocalized(@"Common.Cancel") action:@"cancel" type:TGActionSheetActionTypeCancel]];
    
    TGCustomActionSheet *actionSheet = [[TGCustomActionSheet alloc] initWithTitle:nil actions:actions actionBlock:^(TGModernConversationController *controller, NSString *action)
    {
        if ([action isEqualToString:@"viewContact"])
            [controller openContactWithUser:contact contact:attachment];
        else if ([action isEqualToString:@"addContact"])
            [controller showAddContactMenu:contact];
        else if ([action isEqualToString:@"sendMessage"])
            [controller.companion controllerRequestedNavigationToConversationWithUser:contact.uid];
        else if ([action isEqualToString:@"call"])
        {
            NSString *url = [[NSString alloc] initWithFormat:@"tel:%@", [TGPhoneUtils formatPhoneUrl:contact.phoneNumber]];
            [TGAppDelegateInstance performPhoneCall:[NSURL URLWithString:url]];
        }
        else if ([action isEqualToString:@"telegramCall"])
        {
            [[TGInterfaceManager instance] callPeerWithId:contact.uid];
        }
    } target:self];
    [actionSheet showInView:self.view];
}

- (void)showAddContactMenu:(TGUser *)contact
{
    [[[TGCustomActionSheet alloc] initWithTitle:nil actions:@[
                                                        [[TGActionSheetAction alloc] initWithTitle:TGLocalized(@"Profile.CreateNewContact") action:@"createNewContact"],
                                                        [[TGActionSheetAction alloc] initWithTitle:TGLocalized(@"Profile.AddToExisting") action:@"addToExisting"],
                                                        [[TGActionSheetAction alloc] initWithTitle:TGLocalized(@"Common.Cancel") action:@"cancel" type:TGActionSheetActionTypeCancel]
                                                        ] actionBlock:^(TGModernConversationController *controller, NSString *action)
    {
        if ([action isEqualToString:@"createNewContact"])
            [controller.companion controllerWantsToCreateContact:contact.uid firstName:contact.firstName lastName:contact.lastName phoneNumber:contact.phoneNumber attachment:contact.customProperties[@"contact"]];
        else if ([action isEqualToString:@"addToExisting"])
            [controller.companion controllerWantsToAddContactToExisting:contact.uid phoneNumber:contact.phoneNumber attachment:contact.customProperties[@"contact"]];
    } target:self] showInView:self.view];
}

- (void)openContactWithUser:(TGUser *)user contact:(TGContactMediaAttachment *)contact
{
    TGVCard *vcard = [[TGVCard alloc] initWithString:contact.vcard];
    TGVCardUserInfoController *controller = [[TGVCardUserInfoController alloc] initWithUser:user vcard:vcard];
    [self.navigationController pushViewController:controller animated:true];
}

- (void)showCallNumberMenu:(NSArray *)phoneNumbers
{
    NSMutableArray *actions = [[NSMutableArray alloc] init];
    for (NSArray *desc in phoneNumbers)
    {
        [actions addObject:[[TGActionSheetAction alloc] initWithTitle:((NSString *)desc[0]).length == 0 ? desc[2] : [[NSString alloc] initWithFormat:@"%@: %@", desc[0], desc[2]] action:desc[1]]];
    }
    
    [actions addObject:[[TGActionSheetAction alloc] initWithTitle:TGLocalized(@"Common.Cancel") action:@"cancel" type:TGActionSheetActionTypeCancel]];
    
    [[[TGCustomActionSheet alloc] initWithTitle:nil actions:actions actionBlock:^(__unused id target, NSString *action)
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
    [self _enterEditingMode:nil];
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
        if (!_inputTextPanel.isCustomKeyboardActive && _inputTextPanel.customKeyboardHeight > FLT_EPSILON)
        {
            [UIView performWithoutAnimation:^
            {
                [_inputTextPanel.inputField becomeFirstResponder];
            }];
        }
        else
        {
            if ([TGHacks isKeyboardVisible] && _keyboardHeight < FLT_EPSILON)
            {
                NSMutableDictionary *userInfo = [[NSMutableDictionary alloc] init];
                userInfo[UIKeyboardAnimationDurationUserInfoKey] = @0;
                
                CGRect keyboardFrame = [TGHacks applicationKeyboardView].frame;
                userInfo[UIKeyboardFrameEndUserInfoKey] = [NSValue valueWithCGRect:keyboardFrame];
                
                NSNotification *notification = [[NSNotification alloc] initWithName:UIKeyboardWillChangeFrameNotification object:nil userInfo:userInfo];
                [self keyboardWillChangeFrame:notification];
            }
            [_inputTextPanel.inputField becomeFirstResponder];
        }
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
    [_collectionView updateRelativeBounds];
}

- (void)setMessageEditingContext:(TGMessageEditingContext *)messageEditingContext {
    if (_inputTextPanel == nil) {
        _initialMessageEdigingContext = messageEditingContext;
    } else {
        [self setEditMessageWithText:messageEditingContext.text entities:messageEditingContext.entities messageId:messageEditingContext.messageId animated:false];
    }
}

- (void)setInputText:(NSString *)inputText replace:(bool)replace selectRange:(NSRange)selectRange {
    [self setInputText:inputText entities:nil replace:replace replaceIfPrefix:false selectRange:selectRange forceSelectRange:false];
}

- (void)setInputText:(NSString *)inputText entities:(NSArray *)entities replace:(bool)replace replaceIfPrefix:(bool)replaceIfPrefix selectRange:(NSRange)selectRange forceSelectRange:(bool)forceSelectRange
{
    if (_inputTextPanel == nil) {
        _initialInputText = inputText;
        _initialSelectRange = selectRange;
    }
    else if (TGStringCompare(_inputTextPanel.maybeInputField.text, @"") || replace || (replaceIfPrefix && [inputText hasPrefix:_inputTextPanel.maybeInputField.text]))
    {
        [[_inputTextPanel inputField] setAttributedText:[TGMessageEditingContext attributedStringForText:inputText entities:entities fontSize:[_inputTextPanel fontSize]] animated:false];
        [[_inputTextPanel inputField] selectRange:selectRange force:forceSelectRange];
        
        if (_collectionView != nil)
        {
            [_emptyListPlaceholder adjustLayoutForSize:_view.bounds.size contentInsets:UIEdgeInsetsMake(_collectionView.contentInset.bottom - 210.0f - [_collectionView implicitTopInset], 0.0f, _collectionView.contentInset.top, 0.0f) duration:0.0f curve:0];
        }
        else
        {
            [_emptyListPlaceholder adjustLayoutForSize:_view.bounds.size contentInsets:UIEdgeInsetsMake(self.controllerInset.top, 0.0f, [_currentInputPanel currentHeight], 0.0f) duration:0.0f curve:0];
        }
    }
}

- (NSString *)inputText
{
    return _inputTextPanel == nil ? _initialInputText : _inputTextPanel.maybeInputField.text;
}

- (void)updateWebpageLinks {
    [_inputTextPanel.inputField setText:[self inputText] animated:false];
}

- (void)setReplyMessage:(TGMessage *)replyMessage animated:(bool)animated
{
    [self setReplyMessage:replyMessage openKeyboard:false animated:animated];
}

- (void)setReplyMessage:(TGMessage *)replyMessage openKeyboard:(bool)openKeyboard animated:(bool)animated
{
    [self endMessageEditing:false];
    
    TGModenConcersationReplyAssociatedPanel *panel = [[TGModenConcersationReplyAssociatedPanel alloc] initWithMessage:replyMessage];
    __weak TGModernConversationController *weakSelf = self;
    panel.pressed = ^{
        __strong TGModernConversationController *strongSelf = weakSelf;
        if (strongSelf != nil)
        {
            [strongSelf scrollToMessage:replyMessage.mid peerId:0 sourceMessageId:0 animated:true];
        }
    };
    panel.dismiss = ^
    {
        __strong TGModernConversationController *strongSelf = weakSelf;
        if (strongSelf != nil)
        {
            [strongSelf setPrimaryExtendedPanel:nil animated:true];
            [strongSelf setSecondaryExtendedPanel:nil animated:true];
        }
    };
    [self setPrimaryExtendedPanel:panel animated:animated];
    
    if (openKeyboard && _currentInputPanel == _inputTextPanel && (replyMessage.replyMarkup.isInline || replyMessage.replyMarkup.rows.count == 0))
        [self openKeyboard];
}

- (void)displayMediaEditingOptions:(TGMessage *)message
{
    [self endEditing];
    
    bool showLegacyMenu = ((TGIsPad() && iosMajorVersion() < 8) || iosMajorVersion() < 7);
    
    bool asFile = false;
    NSString *editTitle = nil;
    TGMediaAttachment *mediaAttachment = nil;
    for (TGMediaAttachment *attachment in message.mediaAttachments)
    {
        if ([attachment isKindOfClass:[TGImageMediaAttachment class]]) {
            editTitle = TGLocalized(@"Conversation.EditingMessageMediaEditCurrentPhoto");
            mediaAttachment = attachment;
        } else if ([attachment isKindOfClass:[TGVideoMediaAttachment class]]) {
            editTitle = TGLocalized(@"Conversation.EditingMessageMediaEditCurrentVideo");
            mediaAttachment = attachment;
        }
        else if ([attachment isKindOfClass:[TGDocumentMediaAttachment class]]) {
            asFile = !((TGDocumentMediaAttachment *)attachment).isAnimated;
            mediaAttachment = attachment;
        }
    }
    
    NSArray *entities;
    NSString *text = [_inputTextPanel.maybeInputField textWithEntities:&entities];
    
    TGMenuSheetController *controller = [[TGMenuSheetController alloc] initWithContext:[TGLegacyComponentsContext shared] dark:false];
    controller.dismissesByOutsideTap = true;
    controller.hasSwipeGesture = true;
    
    __weak TGModernConversationController *weakSelf = self;
    __weak TGMenuSheetController *weakController = controller;
    
    NSMutableArray *itemViews = [[NSMutableArray alloc] init];
    
    __weak TGAttachmentCarouselItemView *weakCarouselItem = nil;
    if (!showLegacyMenu)
    {
        TGAttachmentCarouselItemView *carouselItem = [[TGAttachmentCarouselItemView alloc] initWithContext:[TGLegacyComponentsContext shared] camera:[PGCamera cameraAvailable] && !asFile && ![TGCameraController useLegacyCamera] selfPortrait:false forProfilePhoto:false assetType:TGMediaAssetAnyType saveEditedPhotos:TGAppDelegateInstance.saveEditedPhotos allowGrouping:false allowSelection:false allowEditing:!asFile document:false];
        carouselItem.parentController = self;
        carouselItem.allowCaptions = [_companion allowCaptionedMedia];
        carouselItem.allowCaptionEntities = [_companion allowCaptionEntities];
        carouselItem.hasTimer = false;
        carouselItem.asFile = asFile;
        carouselItem.inhibitMute = true;
        carouselItem.inhibitDocumentCaptions = ![_companion allowCaptionedDocuments];
        carouselItem.recipientName = [_companion title];
        [carouselItem.editingContext setForcedCaption:text entities:entities];
        
        weakCarouselItem = carouselItem;
        carouselItem.suggestionContext = [self _suggestionContext];
        carouselItem.cameraPressed = ^(TGAttachmentCameraView *cameraView)
        {
            __strong TGModernConversationController *strongSelf = weakSelf;
            if (strongSelf == nil)
                return;
            
            __strong TGMenuSheetController *strongController = weakController;
            if (strongController == nil)
                return;
            
            [strongSelf _displayCameraWithView:cameraView menuController:strongController message:message];
        };
        carouselItem.sendPressed = ^(TGMediaAsset *currentItem, bool asFiles)
        {
            __strong TGModernConversationController *strongSelf = weakSelf;
            if (strongSelf == nil)
                return;
            
            __strong TGMenuSheetController *strongController = weakController;
            if (strongController == nil)
                return;
            
            __strong TGAttachmentCarouselItemView *strongCarouselItem = weakCarouselItem;
            if (strongCarouselItem == nil)
                return;
            
            [strongController dismissAnimated:true];
            
            bool allowRemoteCache = [strongSelf->_companion controllerShouldCacheServerAssets];
            TGMediaAssetsControllerIntent intent = asFiles ? TGMediaAssetsControllerSendFileIntent : TGMediaAssetsControllerSendMediaIntent;
            [strongSelf _asyncProcessMediaAssetSignals:[TGMediaAssetsController resultSignalsForSelectionContext:strongCarouselItem.selectionContext editingContext:strongCarouselItem.editingContext intent:intent currentItem:currentItem storeAssets:[strongSelf->_companion controllerShouldStoreCapturedAssets] useMediaCache:[strongSelf->_companion controllerShouldCacheServerAssets] descriptionGenerator:^id(id result, NSString *caption, NSArray *entities, NSString *hash) {
                __strong TGModernConversationController *strongSelf = weakSelf;
                if (strongSelf == nil)
                    return nil;

                NSDictionary *desc = [strongSelf _descriptionForItem:result caption:caption entities:entities hash:hash allowRemoteCache:allowRemoteCache];
                return [strongSelf _descriptionForReplacingMedia:desc message:message];
            } saveEditedPhotos:TGAppDelegateInstance.saveEditedPhotos]];
            [strongSelf endMessageEditing:true];
        };
        carouselItem.editorOpened = ^
        {
            __strong TGModernConversationController *strongSelf = weakSelf;
            if (strongSelf == nil)
                return;
            
            [strongSelf _updateCanReadHistory:TGModernConversationActivityChangeInactive];
        };
        carouselItem.editorClosed = ^
        {
            __strong TGModernConversationController *strongSelf = weakSelf;
            if (strongSelf == nil)
                return;
            
            [strongSelf _updateCanReadHistory:TGModernConversationActivityChangeActive];
        };
        [itemViews addObject:carouselItem];
    }
    
    TGMenuSheetButtonItemView *galleryItem = [[TGMenuSheetButtonItemView alloc] initWithTitle:TGLocalized(@"Conversation.EditingMessageMediaChange") type:TGMenuSheetButtonTypeDefault action:^
    {
        __strong TGModernConversationController *strongSelf = weakSelf;
        if (strongSelf == nil)
            return;
        
        __strong TGMenuSheetController *strongController = weakController;
        if (strongController == nil)
            return;
        
        [strongController dismissAnimated:true];
        [strongSelf _displayMediaPicker:asFile fromFileMenu:false message:message];
    }];
    [itemViews addObject:galleryItem];
    
    __weak TGMenuSheetButtonItemView *weakGalleryItem = galleryItem;
    TGMenuSheetButtonItemView *editItem = nil;
    if (editTitle != nil)
    {
        TGLoadingItemView *loadItem = [[TGLoadingItemView alloc] init];
        [itemViews insertObject:loadItem atIndex:0];
        
        editItem = [[TGMenuSheetButtonItemView alloc] initWithTitle:editTitle type:TGMenuSheetButtonTypeDefault action:nil];
        __weak TGMenuSheetButtonItemView *weakEditItem = editItem;
        __weak TGLoadingItemView *weakLoadItem = loadItem;
        editItem.action = ^
        {
            __strong TGModernConversationController *strongSelf = weakSelf;
            if (strongSelf == nil)
                return;
            
            __strong TGMenuSheetController *strongController = weakController;
            if (strongController == nil)
                return;
            
            __strong TGAttachmentCarouselItemView *strongCarouselItem = weakCarouselItem;
            if (strongCarouselItem == nil)
                return;
            
            __strong TGMenuSheetButtonItemView *strongGalleryItem = weakGalleryItem;
            if (strongGalleryItem == nil)
                return;
            
            __strong TGMenuSheetButtonItemView *strongEditItem = weakEditItem;
            if (strongEditItem == nil)
                return;
            
            __strong TGLoadingItemView *strongLoadItem = weakLoadItem;
            if (strongLoadItem == nil)
                return;
            
            bool downloaded = false;
            NSFileManager *fileManager = [NSFileManager defaultManager];
            if ([mediaAttachment isKindOfClass:[TGImageMediaAttachment class]])
            {
                NSString *path = [TGPreparedRemoteImageMessage filePathForRemoteImageId:((TGImageMediaAttachment *)mediaAttachment).imageId];
                downloaded = [fileManager fileExistsAtPath:path];
            }
            else if ([mediaAttachment isKindOfClass:[TGVideoMediaAttachment class]])
            {
                NSString *url = [((TGVideoMediaAttachment *)mediaAttachment).videoInfo urlWithQuality:0 actualQuality:NULL actualSize:NULL];
                downloaded = [TGVideoDownloadActor isVideoDownloaded:fileManager url:url];
            }
            
            void (^openEditor)(void) = ^
            {
                [strongController.disposables add:[[[TGExternalShareSignals shareItemsForMessages:@[message]] deliverOn:[SQueue mainQueue]] startWithNext:^(NSArray *next)
                {
                    __strong TGMenuSheetController *strongController = weakController;
                    [strongController dismissAnimated:true];
                    
                    id <TGMediaEditableItem, TGMediaSelectableItem> item = nil;
                    if ([next.firstObject isKindOfClass:[UIImage class]])
                        item = [[TGCameraCapturedPhoto alloc] initWithExistingImage:next.firstObject];
                    else
                        item = [[TGCameraCapturedVideo alloc] initWithURL:next.firstObject];
                
                    bool allowRemoteCache = [strongSelf->_companion controllerShouldCacheServerAssets];
                    [TGPhotoVideoEditor presentWithContext:[TGLegacyComponentsContext shared] controller:strongSelf caption:text entities:entities withItem:item recipientName:[strongSelf->_companion title] completion:^(id result, TGMediaEditingContext *editingContext)
                    {
                        [strongSelf _asyncProcessMediaAssetSignals:[TGCameraController resultSignalsForSelectionContext:nil editingContext:editingContext currentItem:result storeAssets:false saveEditedPhotos:false descriptionGenerator:^id(id result, NSString *caption, NSArray *entities, NSString *hash)
                        {
                            __strong TGModernConversationController *strongSelf = weakSelf;
                            if (strongSelf == nil)
                                return nil;
                            
                            NSDictionary *desc = [strongSelf _descriptionForItem:result caption:caption entities:entities hash:hash allowRemoteCache:allowRemoteCache];
                            return [strongSelf _descriptionForReplacingMedia:desc message:message];
                        }]];
                        [strongSelf endMessageEditing:true];
                    }];
                }]];
            };
            
            if (!downloaded)
            {
                strongCarouselItem.collapsed = true;
                strongGalleryItem.collapsed = true;
                strongEditItem.collapsed = true;
                [strongLoadItem start];
                                
                [strongController.disposables add:[[[TGDownloadAudioSignal downloadMediaWithAttachment:mediaAttachment conversationId:message.cid messageId:message.mid] deliverOn:[SQueue mainQueue]] startWithNext:^(__unused id next)
                {
                    if (next != nil)
                        openEditor();
                }]];
            }
            else
            {
                openEditor();
            }
        };
        [itemViews addObject:editItem];
    }
    
    if (asFile)
    {
        if (iosMajorVersion() >= 8)
        {
            TGMenuSheetButtonItemView *iCloudItem = [[TGMenuSheetButtonItemView alloc] initWithTitle:TGLocalized(@"Conversation.FileICloudDrive") type:TGMenuSheetButtonTypeDefault action:^
            {
                __strong TGModernConversationController *strongSelf = weakSelf;
                if (strongSelf == nil)
                    return;
                
                __strong TGMenuSheetController *strongController = weakController;
                if (strongController == nil)
                    return;
                
                [strongController dismissAnimated:true];
                [strongSelf _displayICloudDrivePicker];
            }];
            [itemViews addObject:iCloudItem];
        }
        
        if ([TGDropboxHelper isDropboxInstalled])
        {
            TGMenuSheetButtonItemView *dropboxItem = [[TGMenuSheetButtonItemView alloc] initWithTitle:TGLocalized(@"Conversation.FileDropbox") type:TGMenuSheetButtonTypeDefault action:^
            {
                __strong TGModernConversationController *strongSelf = weakSelf;
                if (strongSelf == nil)
                    return;
                
                __strong TGMenuSheetController *strongController = weakController;
                if (strongController == nil)
                    return;
                
                [strongController dismissAnimated:true];
                [strongSelf _displayDropboxPicker];
            }];
            [itemViews addObject:dropboxItem];
        }
    }
    
    TGMenuSheetButtonItemView *cancelItem = [[TGMenuSheetButtonItemView alloc] initWithTitle:TGLocalized(@"Common.Cancel") type:TGMenuSheetButtonTypeCancel action:^
    {
        __strong TGMenuSheetController *strongController = weakController;
        [strongController dismissAnimated:true];
    }];
    
    [itemViews addObject:cancelItem];
    
    [controller setItemViews:itemViews];
    [controller presentInViewController:self sourceView:_inputTextPanel animated:true];
}

- (void)setEditMessageWithText:(NSString *)text entities:(NSArray *)entities messageId:(int32_t)messageId animated:(bool)animated {
    TGMessage *message = [TGDatabaseInstance() loadMessageWithMid:messageId peerId:[_companion requestPeerId]];
    
    bool hasMedia = false;
    if (message.messageLifetime == 0)
    {
        for (TGMediaAttachment *attachment in message.mediaAttachments)
        {
            if ([attachment isKindOfClass:[TGImageMediaAttachment class]] || [attachment isKindOfClass:[TGVideoMediaAttachment class]])
            {
                hasMedia = true;
                break;
            }
            else if ([attachment isKindOfClass:[TGDocumentMediaAttachment class]])
            {
                hasMedia = !((TGDocumentMediaAttachment *)attachment).isVoice;
                break;
            }
        }
    }
        
    TGModernConversationEditingMessageInputPanel *panel = [[TGModernConversationEditingMessageInputPanel alloc] initWithMessage:message];
    __weak TGModernConversationController *weakSelf = self;
    panel.dismiss = ^{
        __strong TGModernConversationController *strongSelf = weakSelf;
        if (strongSelf != nil) {
            [strongSelf endMessageEditing:true];
        }
    };
    panel.tap = ^{
        __strong TGModernConversationController *strongSelf = weakSelf;
        if (strongSelf != nil) {
            [strongSelf.companion navigateToMessageId:messageId scrollBackMessageId:0 forceUnseenMention:false animated:true];
        }
    };
    [self setInputPanel:_inputTextPanel animated:true];
    [self setPrimaryExtendedPanel:panel animated:true];
    [self setSecondaryExtendedPanel:nil animated:true];
    [_inputTextPanel setAssociatedPanel:nil animated:true];
    [_mentionTextResultsDisposable setDisposable:nil];
    [_currentMentionDisposable setDisposable:nil];
    
    [_inputTextPanel setMessageEditingContext:[[TGMessageEditingContext alloc] initWithText:text entities:entities isCaption:hasMedia hasMedia:hasMedia cid:[self peerId] messageId:messageId] animated:animated];
}

- (void)endMessageEditing:(bool)animated {
    [_inputTextPanel setMessageEditingContext:nil animated:animated];
    [self setPrimaryExtendedPanel:nil animated:true];
    [_saveEditedMessageDisposable setDisposable:nil];
    [self setCustomInputPanel:nil force:true setupResponder:nil];
}

- (void)setForwardMessages:(NSArray *)forwardMessages completeGroups:(NSSet *)completeGroups animated:(bool)animated
{
    if (_inputTextPanel == nil)
    {
        _initialForwardMessages = forwardMessages;
        _initialCompleteGroups = completeGroups;
    }
    else
    {
        TGModernConversationForwardInputPanel *panel = [[TGModernConversationForwardInputPanel alloc] initWithMessages:forwardMessages completeGroups:completeGroups];
        __weak TGModernConversationController *weakSelf = self;
        panel.dismiss = ^
        {
            __strong TGModernConversationController *strongSelf = weakSelf;
            if (strongSelf != nil)
            {
                [strongSelf setPrimaryExtendedPanel:nil animated:true];
                [strongSelf setSecondaryExtendedPanel:nil animated:true];
            }
        };
        
        [self setPrimaryExtendedPanel:panel animated:animated];
    }
}

- (void)setInlineStickerList:(NSDictionary *)dictionary
{
    NSArray *documents = dictionary[@"documents"];
    if (documents.count == 0 || _inputTextPanel.messageEditingContext != nil)
    {
        if ([[_inputTextPanel associatedPanel] isKindOfClass:[TGStickerAssociatedInputPanel class]])
            [_inputTextPanel setAssociatedPanel:nil animated:true];
    }
    else
    {
        __weak TGModernConversationController *weakSelf = self;
        [_inputTextPanel setAssociatedStickerList:dictionary stickerSelected:^(TGDocumentMediaAttachment *document)
        {
            __strong TGModernConversationController *strongSelf = weakSelf;
            if (strongSelf != nil)
            {
                [[SQueue concurrentDefaultQueue] dispatch:^{
                    [TGStickersSignals addUseCountForDocumentId:document.documentId];
                }];
                [strongSelf->_inputTextPanel.maybeInputField setText:@"" animated:true];
                [strongSelf->_companion controllerWantsToSendRemoteDocument:document asReplyToMessageId:[strongSelf currentReplyMessageId] text:nil entities:nil botContextResult:nil botReplyMarkup:nil];
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

- (void)setAvatarConversationIds:(NSArray *)conversationIds titles:(NSArray *)titles
{
    [_avatarButton setAvatarConversationIds:conversationIds];
    [_avatarButton setAvatarTitles:titles];
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

- (void)setAvatarUrls:(NSArray *)avatarUrls
{
    [_avatarButton setAvatarUrls:avatarUrls];
}

- (void)setStatus:(NSString *)status accentColored:(bool)accentColored allowAnimation:(bool)allowAnimation toggleMode:(TGModernConversationControllerTitleToggle)toggleMode
{
    if (status.length == 0)
    {
        [_titleView setShowStatus:false showArrow:false];
    }
    else
    {
        [_titleView setStatus:status animated:self.isViewLoaded && allowAnimation];
        [_titleView setStatusHasAccentColor:accentColored];
        [_titleView setToggleMode:toggleMode];
    }
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

- (void)setUnreadMentionCount:(int32_t)unreadMentionCount {
    _initialUnreadMentionCount = unreadMentionCount;
    _scrollButtons.unseenMentionCount = unreadMentionCount;
}

- (TGModernConversationInputPanel *)defaultInputPanel {
    if (_companion.previewMode || [_companion _controllerShouldHideInputTextByDefault]) {
        return nil;
    } else {
        if (_defaultInputPanel != nil) {
            return _defaultInputPanel;
        } else {
            return _inputTextPanel;
        }
    }
}

- (void)setCustomInputPanel:(TGModernConversationInputPanel *)customInputPanel {
    [self setCustomInputPanel:customInputPanel force:false setupResponder:nil];
}

- (void)setCustomInputPanel:(TGModernConversationInputPanel *)customInputPanel force:(bool)force setupResponder:(void (^)())setupResponder
{
    if (_customInputPanel != customInputPanel || force)
    {
        _customInputPanel = customInputPanel;
        if (!_editingMode)
        {
            [self setInputPanel:_customInputPanel != nil ? _customInputPanel : [self defaultInputPanel] animated:ABS(CFAbsoluteTimeGetCurrent() - _willAppearTimestamp) > 0.18 setupResponder:setupResponder];
        }
    }
}

- (void)setDefaultInputPanel:(TGModernConversationInputPanel *)defaultInputPanel {
    _defaultInputPanel = defaultInputPanel;
    if (_searchPanel == nil) {
        [self setCustomInputPanel:nil force:true setupResponder:nil];
    }
}

- (bool)hasNonTextInputPanel {
    return _currentInputPanel != _inputTextPanel;
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
        bool applyAsCurrent = (_currentTitlePanel == nil || _currentTitlePanel == _secondaryTitlePanel) && !_editingMode && !self.navigationBarShouldBeHidden;
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
    if (_companion.previewMode || _inputTextPanel.isCustomKeyboardExpanded) {
        return;
    }
    
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
                     } completion:^(BOOL finished)
                     {
                         if (finished) {
                             [lastPanel removeFromSuperview];
                         }
                     }];
                }
                else if (animation == TGModernConversationPanelAnimationSlideFar)
                {
                    _titlePanelWrappingView.clipsToBounds = false;
                    [UIView animateWithDuration:0.3 delay:0.0 options:0 animations:^
                     {
                         lastPanel.frame = CGRectOffset(lastPanel.frame, 0.0f, -lastPanel.frame.size.height - lastPanel.superview.frame.origin.y);
                     } completion:^(BOOL finished)
                     {
                         if (finished) {
                             [lastPanel removeFromSuperview];
                         }
                         _titlePanelWrappingView.clipsToBounds = true;
                     }];
                }
                else
                {
                    [UIView animateWithDuration:0.09 delay:0.0 options:iosMajorVersion() < 7 ? 0 : (7 << 16) animations:^
                     {
                         lastPanel.alpha = 0.0f;
                     } completion:^(BOOL finished)
                     {
                         if (finished) {
                             [lastPanel removeFromSuperview];
                             lastPanel.alpha = 1.0f;
                         }
                     }];
                }
            }
            else
                [_currentTitlePanel removeFromSuperview];
        }
        
        _currentTitlePanel = currentTitlePanel;
        currentTitlePanel.safeAreaInset = [self calculatedSafeAreaInset];
        currentTitlePanel.presentation = self.presentation;
        
        if (_currentTitlePanel != nil && [self isViewLoaded])
        {
            if (_titlePanelWrappingView == nil)
            {
                _titlePanelWrappingView = [[UIView alloc] initWithFrame:CGRectMake(0.0f, self.controllerInset.top, _view.frame.size.width, 44.0f)];
                _titlePanelWrappingView.clipsToBounds = true;
                
                if (_currentInputPanel != nil)
                    [_view insertSubview:_titlePanelWrappingView belowSubview:_currentInputPanel];
                else
                    [_view addSubview:_titlePanelWrappingView];
            }
            
            _titlePanelWrappingView.userInteractionEnabled = true;
            
            CGRect titlePanelWrappingFrame = _titlePanelWrappingView.frame;
            titlePanelWrappingFrame.size.height = MAX(44.0f, _currentTitlePanel.frame.size.height);
            _titlePanelWrappingView.frame = titlePanelWrappingFrame;
            
            [_titlePanelWrappingView addSubview:_currentTitlePanel];
            
            CGRect titlePanelFrame = CGRectMake(0.0f, 0.0f, _titlePanelWrappingView.frame.size.width, _currentTitlePanel.frame.size.height);
            
            [_currentTitlePanel.layer removeAllAnimations];
            
            if (animation != TGModernConversationPanelAnimationNone)
            {
                if (animation == TGModernConversationPanelAnimationSlide)
                {
                    _currentTitlePanel.frame = CGRectOffset(titlePanelFrame, 0.0f, -titlePanelFrame.size.height);
                    [UIView animateWithDuration:0.09 delay:0.0 options:(iosMajorVersion() < 7 ? 0 : (7 << 16)) | UIViewAnimationOptionAllowUserInteraction animations:^
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
    if (_collectionView != nil) {
        [self _updateVisibleItemIndices:nil];
    }
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
    
#ifdef TGModernConversationControllerDisableReadHistory
    canReadHistory = false;
#endif
    
    if (_canReadHistory != canReadHistory)
    {
        if (canReadHistory) {
            [self resumeInlineMedia];
        } else {
            [self stopInlineMedia:0];
        }
        
        _canReadHistory = canReadHistory;
        [_companion controllerCanReadHistoryUpdated];
        [self updateAutomaticReadAction];
    }
    
    [self updateRaiseToListen];
}

- (bool)raiseToListenEnabled {
    return _canReadHistory && _currentInputPanel == _inputTextPanel && (_currentAudioRecorder == nil || !_currentAudioRecorderIsTouchInitiated) && _attachmentSheetWindow == nil && _menuController == nil && !_inputDisabled;
}

- (void)updateRaiseToListen {
    _raiseToListenActivator.enabled = [self raiseToListenEnabled];
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

- (TGConversationScrollState *)_currentScrollState {
    if (_collectionView != nil) {
        NSIndexPath *indexPath = nil;
        CGPoint point = CGPointMake(0.0f, _collectionView.contentOffset.y + _collectionView.contentInset.top + 5.0f);
        CGFloat offset = 0.0f;
        
        for (NSIndexPath *maybeIndexPath in [_collectionView indexPathsForVisibleItems]) {
            UIView *cell = [_collectionView cellForItemAtIndexPath:maybeIndexPath];
            if (cell != nil && CGRectContainsPoint(cell.frame, point)) {
                indexPath = maybeIndexPath;
                offset = point.y - 4.0 - cell.frame.origin.y;
                break;
            }
        }
        if (indexPath != nil && indexPath.item != 0) {
            for (NSInteger index = indexPath.item; index >= 0; index--) {
                TGMessageModernConversationItem *item = _items[index];
                if (item->_message.hole == nil && item->_message.group == nil) {
                    return [[TGConversationScrollState alloc] initWithPeerId:([self isFeed] ? item->_message.fromUid : 0) messageId:item->_message.mid messageOffset:(int32_t)offset];
                }
            }
        }
    }
    return nil;
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
    
    [self setInputText:currentText replace:true selectRange:NSMakeRange(0, 0)];
    [_inputTextPanel inputField].internalTextView.enableFirstResponder = true;
}

- (void)appendAlphacode:(NSString *)alphacode
{
    NSString *currentText = self.inputText;
    NSRange selectRange = NSMakeRange(0, 0);
    
    if (currentText.length == 0)
        currentText = alphacode;
    else
    {
        NSInteger caretIndex = [_inputTextPanel textCaretPosition];
        
        for (NSInteger i = caretIndex - 1; i >= 0; i--)
        {
            if ([currentText characterAtIndex:i] == ':') {
                currentText = [currentText stringByReplacingCharactersInRange:NSMakeRange(i, caretIndex - i) withString:alphacode];
                selectRange = NSMakeRange(i + alphacode.length, 0);
                break;
            }
        }
    }
    
    [self setInputText:currentText entities:nil replace:true replaceIfPrefix:false selectRange:selectRange forceSelectRange:true];
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
    
    if ([self isSavedMessages]) {
        [self.navigationController pushViewController:[[TGSharedMediaController alloc] initWithPeerId:[self peerId] accessHash:0 important:true] animated:true];
        return;
    }
    
    if ([self isAdminLog]) {
        [(TGAdminLogConversationCompanion *)_companion presentFilterController];
        return;
    }
    
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

- (void)editingPanelRequestedReportMessages:(TGModernConversationEditingPanel *)__unused editingPanel
{
    [_companion reportMessageIndices:[_companion checkedMessageIndices] menuController:nil];
    [self _leaveEditingModeAnimated:true];
}

- (void)editingPanelRequestedDeleteMessages:(TGModernConversationEditingPanel *)__unused editingPanel
{
    NSArray *checkedMessageIndices = [_companion checkedMessageIndices];
    std::set<int32_t> messageIds;
    for (TGMessageIndex *messageIndex in checkedMessageIndices)
    {
        messageIds.insert(messageIndex.messageId);
    }
    
    TGUser *moderateUser = [_companion checkedMessageModerateUser];
    if (moderateUser != nil) {
        SSignal *memberSignal = [TGChannelManagementSignals channelRole:[_companion requestPeerId] accessHash:[_companion requestAccessHash] user:moderateUser];
        TGProgressWindow *progressWindow = [[TGProgressWindow alloc] init];
        [progressWindow showWithDelay:0.15];
        __weak TGModernConversationController *weakSelf = self;
        [[[memberSignal deliverOn:[SQueue mainQueue]] onDispose:^{
            TGDispatchOnMainThread(^{
                [progressWindow dismiss:true];
            });
        }] startWithNext:^(TGCachedConversationMember *member) {
            __strong TGModernConversationController *strongSelf = weakSelf;
            if (strongSelf != nil) {
                if (member.isCreator || [member.adminRights hasAnyRights]) {
                    [strongSelf _showDeleteMessagesMenuForMessageIds:messageIds];
                } else {
                    [strongSelf _showModerateSheetForMessageIndices:[strongSelf->_companion checkedMessageIndices] author:moderateUser];
                }
            }
        }];
    } else {
        [self _showDeleteMessagesMenuForMessageIds:messageIds];
    }
}

- (void)_showDeleteMessagesMenuForMessageIds:(std::set<int32_t>)messageIds {
    [self endEditing];
    
    int64_t peerId = ((TGGenericModernConversationCompanion *)_companion).conversationId;
    
    bool canDeleteForEveryone = true;
    
    if (TGPeerIdIsUser(peerId) || TGPeerIdIsGroup(peerId)) {
        int index = -1;
        for (TGMessageModernConversationItem *messageItem in _items)
        {
            index++;
            if (messageIds.find(messageItem->_message.mid) != messageIds.end())
            {
                if (![_companion canDeleteMessageForEveryone:messageItem->_message])
                    canDeleteForEveryone = false;
            }
        }
    }
    
    int64_t conversationId = ((TGGenericModernConversationCompanion *)_companion).conversationId;
    
    NSString *basicDeleteTitle = TGLocalized(@"Common.Delete");
    if (TGPeerIdIsSecretChat(conversationId)) {
        TGUser *user = [TGDatabaseInstance() loadUser:((TGPrivateModernConversationCompanion *)_companion)->_uid];
        if (user != nil) {
            basicDeleteTitle = [NSString stringWithFormat:TGLocalized(@"Conversation.DeleteMessagesFor"), user.displayFirstName];
        }
    } else if (TGPeerIdIsChannel(conversationId)) {
        basicDeleteTitle = TGLocalized(@"Conversation.DeleteMessagesForEveryone");
    }

    __weak TGModernConversationController *weakSelf = self;
    TGMenuSheetController *controller = _contextMenuController ?: [[TGMenuSheetController alloc] initWithContext:[TGLegacyComponentsContext shared] dark:false];
    controller.dismissesByOutsideTap = true;
    controller.inhibitPopoverPresentation = true;
    controller.requiresShadow = true;
    controller.requiuresDimView = !TGIsPad();
    controller.stickWithSpecifiedParentController = TGIsPad();
    controller.willDismiss = ^(__unused bool manual)
    {
        __strong TGModernConversationController *strongSelf = weakSelf;
        if (strongSelf != nil && TGIsPad()) {
            strongSelf->_contextMenuController = nil;
            [strongSelf unfocusMessagesAnimated:true];
        }
    };
    
     __weak TGMenuSheetController *weakController = controller;
    NSMutableArray *itemViews = [[NSMutableArray alloc] init];
    TGMenuSheetButtonItemView *item = [[TGMenuSheetButtonItemView alloc] initWithTitle:(TGPeerIdIsSecretChat(conversationId) || TGPeerIdIsChannel(conversationId) || conversationId == TGTelegraphInstance.clientUserId) ? basicDeleteTitle : TGLocalized(@"Conversation.DeleteMessagesForMe") type:TGMenuSheetButtonTypeDestructive action:^
    {
        __strong TGModernConversationController *strongSelf = weakSelf;
        if (strongSelf != nil)
            [strongSelf _commitDeleteMessages:messageIds forEveryone:false];
        
        __strong TGMenuSheetController *strongController = weakController;
        [strongController dismissAnimated:true];
    }];
    [itemViews addObject:item];

    if (!TGPeerIdIsSecretChat(conversationId) && !TGPeerIdIsChannel(conversationId) && conversationId != TGTelegraphInstance.clientUserId && canDeleteForEveryone)
    {
        NSString *title = TGLocalized(@"Conversation.DeleteMessagesForEveryone");
        if (TGPeerIdIsUser(conversationId)) {
            TGUser *user = [TGDatabaseInstance() loadUser:(int)conversationId];
            if (user != nil) {
                title = [NSString stringWithFormat:TGLocalized(@"Conversation.DeleteMessagesFor"), user.displayFirstName];
            }
        }
        
        TGMenuSheetButtonItemView *item = [[TGMenuSheetButtonItemView alloc] initWithTitle:title type:TGMenuSheetButtonTypeDestructive action:^
        {
            __strong TGModernConversationController *strongSelf = weakSelf;
            if (strongSelf != nil)
                [strongSelf _commitDeleteMessages:messageIds forEveryone:true];
            
            __strong TGMenuSheetController *strongController = weakController;
            [strongController dismissAnimated:true];
        }];
        [itemViews addObject:item];
    }
    
    TGMenuSheetButtonItemView *cancelItem = [[TGMenuSheetButtonItemView alloc] initWithTitle:TGLocalized(@"Common.Cancel") type:TGMenuSheetButtonTypeCancel action:^
    {
        __strong TGMenuSheetController *strongController = weakController;
        [strongController dismissAnimated:true];
    }];
    [itemViews addObject:cancelItem];
    
    if (_contextMenuController != nil)
    {
        [controller setItemViews:itemViews animated:true];
    }
    else
    {
        [controller setItemViews:itemViews animated:false];
        [controller presentInViewController:self sourceView:self.view animated:true];
    }
}

- (void)editingPanelRequestedForwardMessages:(TGModernConversationEditingPanel *)__unused editingPanel
{
    [self forwardMessages:[_companion checkedMessageIndices] fastForward:false grouped:false];
}

- (void)editingPanelRequestedShareMessages:(TGModernConversationEditingPanel *)__unused editingPanel
{
    TGProgressWindow *progressWindow = [[TGProgressWindow alloc] init];
    [progressWindow showWithDelay:0.2];
    
    NSMutableArray *updatedMessageIndices = [[_companion checkedMessageIndices] mutableCopy];
    
    NSMutableArray *messages = [[NSMutableArray alloc] init];
    for (TGMessageModernConversationItem *item in _items) {
        [updatedMessageIndices enumerateObjectsUsingBlock:^(TGMessageIndex *messageIndex, NSUInteger index, BOOL *stop)
        {
            if (item->_message.mid == messageIndex.messageId && item->_message.fromUid == messageIndex.peerId)
            {
                [updatedMessageIndices removeObjectAtIndex:index];
                *stop = true;
                
                [messages addObject:item->_message];
            }
        }];
        
        if (updatedMessageIndices.count == 0)
            break;
    }
    
    [messages sortUsingComparator:^NSComparisonResult(TGMessage *message1, TGMessage *message2)
    {
        if (ABS(message1.date - message2.date) < DBL_EPSILON)
            return message1.mid > message2.mid ? NSOrderedAscending : NSOrderedDescending;
        return message1.date > message2.date ? NSOrderedAscending : NSOrderedDescending;
    }];
    
    __weak TGModernConversationController *weakSelf = self;
    [[[TGExternalShareSignals shareItemsForMessages:messages] onDispose:^
    {
        [progressWindow dismiss:true];
    }] startWithNext:^(id next)
    {
        __strong TGModernConversationController *strongSelf = weakSelf;
        if (next == nil || strongSelf == nil)
            return;
        
        UIActivityViewController *activityController = [[UIActivityViewController alloc] initWithActivityItems:next applicationActivities:nil];
        [strongSelf presentViewController:activityController animated:true completion:^{
            __strong TGModernConversationController *strongSelf = weakSelf;
            if (strongSelf != nil)
                [strongSelf _leaveEditingModeAnimated:true];
        }];
        if (iosMajorVersion() >= 8 && [UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPad)
        {
            activityController.popoverPresentationController.sourceView = strongSelf.view;
            activityController.popoverPresentationController.sourceRect = strongSelf.view.bounds;
            activityController.popoverPresentationController.permittedArrowDirections = 0;
        }
        [progressWindow dismiss:true];
    }];
}

- (void)inputTextPanelHasIndicatedTypingActivity:(TGModernConversationInputTextPanel *)__unused inputTextPanel
{
    if (_inputTextPanel.messageEditingContext == nil) {
        [_companion controllerDidUpdateTypingActivity];
    }
}

- (void)inputPanelTextChanged:(TGModernConversationInputTextPanel *)__unused inputTextPanel text:(NSString *)text
{
    if (iosMajorVersion() >= 8 && _currentActivity != nil)
    {
        [_currentActivity addUserInfoEntriesFromDictionary:@{@"text": text == nil ? @"" : text}];
        _currentActivity.needsSave = true;
    }
    
    [_companion controllerDidChangeInputText:text];
    
    if (_inputPlaceholderForTextDisposable == nil) {
        _inputPlaceholderForTextDisposable = [[SMetaDisposable alloc] init];
    }
    
    [_inputTextPanel setContextPlaceholder:nil];
    
    if (_inputTextPanel.messageEditingContext != nil) {
        [_inputPlaceholderForTextDisposable setDisposable:nil];
        [_inputTextPanel setContextPlaceholder:nil];
        [_inputTextPanel setContextBotMode:nil];
    } else {
        __weak TGModernConversationController *weakSelf = self;
        [_inputPlaceholderForTextDisposable setDisposable:[[[_companion contextBotInfoForText:text] deliverOn:[SQueue mainQueue]] startWithNext:^(NSDictionary *info) {
            __strong TGModernConversationController *strongSelf = weakSelf;
            if (strongSelf != nil) {
                [strongSelf->_inputTextPanel setContextPlaceholder:info[@"placeholder"]];
                [strongSelf->_inputTextPanel setContextBotMode:info[@"user"]];
            }
        }]];
    }
}

- (void)inputPanelMentionEntered:(TGModernConversationInputTextPanel *)__unused inputTextPanel mention:(NSString *)mention startOfLine:(bool)startOfLine
{
    [_inputTextPanel setContextBotInputMode:mention != nil && startOfLine];
    
    if (_currentMentionDisposable != nil) {
        _currentMentionDisposable = [[SMetaDisposable alloc] init];
    }
    
    if (mention == nil)
    {
        [_currentMentionDisposable setDisposable:nil];
        if ([[_inputTextPanel associatedPanel] isKindOfClass:[TGModernConversationMentionsAssociatedPanel class]])
            [_inputTextPanel setAssociatedPanel:nil animated:true];
    }
    else
    {
        bool canBeContextBot = startOfLine && _inputTextPanel.messageEditingContext == nil;
        __weak TGModernConversationController *weakSelf = self;
        [_currentMentionDisposable setDisposable:[[[[_companion userListForMention:mention canBeContextBot:canBeContextBot includeSelf:false] take:1] deliverOn:[SQueue mainQueue]] startWithNext:^(NSArray *array) {
            __strong TGModernConversationController *strongSelf = weakSelf;
            if (strongSelf != nil) {
                if (array.count == 0) {
                    if ([[strongSelf->_inputTextPanel associatedPanel] isKindOfClass:[TGModernConversationMentionsAssociatedPanel class]]) {
                        [strongSelf->_inputTextPanel setAssociatedPanel:nil animated:true];
                    }
                } else {
                    TGModernConversationMentionsAssociatedPanel *panel = nil;
                    if ([[strongSelf->_inputTextPanel associatedPanel] isKindOfClass:[TGModernConversationMentionsAssociatedPanel class]])
                        panel = (TGModernConversationMentionsAssociatedPanel *)[strongSelf->_inputTextPanel associatedPanel];
                    else
                    {
                        panel = [[TGModernConversationMentionsAssociatedPanel alloc] init];
                        panel.userSelected = ^(TGUser *user)
                        {
                            __strong TGModernConversationController *strongSelf = weakSelf;
                            if (strongSelf != nil)
                            {
                                if ([[strongSelf->_inputTextPanel associatedPanel] isKindOfClass:[TGModernConversationMentionsAssociatedPanel class]])
                                {
                                    [strongSelf->_inputTextPanel setAssociatedPanel:nil animated:false];
                                }
                                
                                if (user.userName.length == 0) {
                                    [strongSelf->_inputTextPanel replaceMention:[[NSString alloc] initWithFormat:@"%@", user.displayFirstName] username:false userId:user.uid];
                                } else {
                                    [strongSelf->_inputTextPanel replaceMention:[[NSString alloc] initWithFormat:@"%@", user.userName] username:true userId:user.uid];
                                }
                            }
                        };
                        [strongSelf->_inputTextPanel setAssociatedPanel:panel animated:true];
                    }
                    
                    
                    //canBeContextBot = false;
                    [panel setUserListSignal:[SSignal single:array]];
                    
                    [strongSelf->_inputTextPanel setAssociatedPanel:panel animated:true];
                }
            }
        }]];
    }
}

- (void)inputPanelMentionTextEntered:(TGModernConversationInputTextPanel *)__unused inputTextPanel mention:(NSString *)mention text:(NSString *)text {
    [_mentionTextResultsDisposable setDisposable:nil];
    
    if (_inputTextPanel.messageEditingContext != nil) {
        return;
    }
    
    [_inputTextPanel setMentionTextMode:text != nil ? mention : nil];
    
    if (mention.length != 0 && text != nil) {
        CFAbsoluteTime delay = 0.4;
        NSTimeInterval currentTime = CFAbsoluteTimeGetCurrent();
        if (text.length == 0) {
            delay = 0.0;
        }
        if (currentTime > _mentionTextResultsRequestTimestamp + 5.0) {
            delay = 0.0;
        }
        if (!TGStringCompare(_mentionTextResultsRequestMention, mention)) {
            delay = 0.0;
        }
        _mentionTextResultsRequestTimestamp = currentTime;
        _mentionTextResultsRequestMention = mention;
        
        if (_mentionTextResultsDisposable == nil) {
            _mentionTextResultsDisposable = [[SMetaDisposable alloc] init];
        }
        
        SSignal *signal = [[_companion inlineResultForMentionText:mention text:text] deliverOn:[SQueue mainQueue]];
        
        if (signal != nil) {
            if (delay > DBL_EPSILON) {
                signal = [[[SSignal complete] delay:delay onQueue:[SQueue mainQueue]] then:signal];
            }
        }
        
        __weak TGModernConversationController *weakSelf = self;
        [_mentionTextResultsDisposable setDisposable:[[signal onDispose:^{
            TGDispatchOnMainThread(^{
                __strong TGModernConversationController *strongSelf = weakSelf;
                if (strongSelf != nil) {
                    [strongSelf->_inputTextPanel setDisplayProgress:false];
                }
            });
        }] startWithNext:^(id next) {
            __strong TGModernConversationController *strongSelf = weakSelf;
            if (strongSelf != nil) {
                if ([next respondsToSelector:@selector(boolValue)]) {
                    [strongSelf->_inputTextPanel setDisplayProgress:[next boolValue]];
                } else {
                    void (^resultSelected)(TGBotContextResults *, TGBotContextResult *) = ^(TGBotContextResults *results, TGBotContextResult *result) {
                        __strong TGModernConversationController *strongSelf = weakSelf;
                        if (strongSelf != nil) {
                            TGUser *user = [TGDatabaseInstance() loadUser:results.userId];
                            if (user != nil) {
                                [TGRecentContextBotsSignal addRecentBot:results.userId];
                            }
                            
                            TGBotContextResultAttachment *botContextResult = [[TGBotContextResultAttachment alloc] initWithUserId:results.userId resultId:result.resultId queryId:result.queryId];
                            
                            if ([result.sendMessage isKindOfClass:[TGBotContextResultSendMessageAuto class]]) {
                                TGBotContextResultSendMessageAuto *concreteMessage = (TGBotContextResultSendMessageAuto *)result.sendMessage;
                                if ([result isKindOfClass:[TGBotContextMediaResult class]]) {
                                    TGBotContextMediaResult *concreteResult = (TGBotContextMediaResult *)result;
                                    if ([concreteResult.type isEqualToString:@"game"]) {
                                        TGGameMediaAttachment *gameMedia = [[TGGameMediaAttachment alloc] initWithGameId:0 accessHash:0 shortName:nil title:concreteResult.title gameDescription:concreteResult.resultDescription photo:concreteResult.photo document:concreteResult.document];
                                        [strongSelf->_companion controllerWantsToSendGame:gameMedia asReplyToMessageId:[strongSelf currentReplyMessageId] botContextResult:botContextResult botReplyMarkup:concreteMessage.replyMarkup];
                                        [strongSelf->_inputTextPanel.inputField setText:@"" animated:true];
                                    } else if (concreteResult.document != nil) {
                                        TGDocumentAttributeVideo *video = nil;
                                        bool isAnimated = false;
                                        for (id attribute in concreteResult.document.attributes) {
                                            if ([attribute isKindOfClass:[TGDocumentAttributeVideo class]]) {
                                                video = attribute;
                                            } else if ([attribute isKindOfClass:[TGDocumentAttributeAnimated class]]) {
                                                isAnimated = true;
                                            }
                                        }
                                        
                                        if (video != nil && !isAnimated) {
                                            TGVideoMediaAttachment *videoMedia = [[TGVideoMediaAttachment alloc] init];
                                            videoMedia = [[TGVideoMediaAttachment alloc] init];
                                            videoMedia.videoId = concreteResult.document.documentId;
                                            videoMedia.accessHash = concreteResult.document.accessHash;
                                            videoMedia.duration = video.duration;
                                            videoMedia.dimensions = video.size;
                                            videoMedia.thumbnailInfo = concreteResult.document.thumbnailInfo;
                                            TGVideoInfo *videoInfo = [[TGVideoInfo alloc] init];
                                            [videoInfo addVideoWithQuality:1 url:[[NSString alloc] initWithFormat:@"video:%lld:%lld:%d:%d", videoMedia.videoId, videoMedia.accessHash, concreteResult.document.datacenterId, concreteResult.document.size] size:concreteResult.document.size];
                                            videoMedia.videoInfo = videoInfo;
                                            [strongSelf->_companion controllerWantsToSendRemoteVideoWithMedia:videoMedia asReplyToMessageId:[strongSelf currentReplyMessageId] text:concreteMessage.text entities:concreteMessage.entities botContextResult:botContextResult botReplyMarkup:concreteMessage.replyMarkup];
                                        } else {
                                            [strongSelf->_companion controllerWantsToSendRemoteDocument:concreteResult.document asReplyToMessageId:[strongSelf currentReplyMessageId] text:concreteMessage.text entities:concreteMessage.entities botContextResult:botContextResult botReplyMarkup:concreteMessage.replyMarkup];
                                        }
                                        [strongSelf->_inputTextPanel.inputField setText:@"" animated:true];
                                    } else if (concreteResult.photo != nil) {
                                        [strongSelf->_companion controllerWantsToSendRemoteImage:concreteResult.photo text:concreteMessage.text entities:concreteMessage.entities asReplyToMessageId:[strongSelf currentReplyMessageId] botContextResult:botContextResult botReplyMarkup:concreteMessage.replyMarkup];
                                        [strongSelf->_inputTextPanel.inputField setText:@"" animated:true];
                                    }
                                } else if ([result isKindOfClass:[TGBotContextExternalResult class]]) {
                                    TGBotContextExternalResult *concreteResult = (TGBotContextExternalResult *)result;
                                    if ([concreteResult.type isEqualToString:@"game"]) {
                                        TGGameMediaAttachment *gameMedia = [[TGGameMediaAttachment alloc] initWithGameId:0 accessHash:0 shortName:nil title:concreteResult.title gameDescription:concreteResult.pageDescription photo:nil document:nil];
                                        [strongSelf->_companion controllerWantsToSendGame:gameMedia asReplyToMessageId:[strongSelf currentReplyMessageId] botContextResult:botContextResult botReplyMarkup:concreteMessage.replyMarkup];
                                        [strongSelf->_inputTextPanel.inputField setText:@"" animated:true];
                                    } else if ([concreteResult.type isEqualToString:@"gif"]) {
                                        TGExternalGifSearchResult *externalGifSearchResult = [[TGExternalGifSearchResult alloc] initWithUrl:concreteResult.url originalUrl:concreteResult.originalUrl thumbnailUrl:concreteResult.thumbUrl size:concreteResult.size];
                                        id description = [strongSelf->_companion documentDescriptionFromExternalGifSearchResult:externalGifSearchResult text:concreteMessage.text entities:concreteMessage.entities botContextResult:botContextResult];
                                        if (description != nil) {
                                            [strongSelf->_companion controllerWantsToSendImagesWithDescriptions:@[description] asReplyToMessageId:[strongSelf currentReplyMessageId] botReplyMarkup:concreteMessage.replyMarkup];
                                            [strongSelf->_inputTextPanel.inputField setText:@"" animated:true];
                                            [TGRecentContextBotsSignal addRecentBot:results.userId];
                                        }
                                    } else if ([concreteResult.type isEqualToString:@"photo"]) {
                                        TGExternalImageSearchResult *externalImageSearchResult = [[TGExternalImageSearchResult alloc] initWithUrl:concreteResult.url originalUrl:concreteResult.originalUrl thumbnailUrl:concreteResult.thumbUrl title:concreteResult.title size:concreteResult.size];
                                        id description = [strongSelf->_companion imageDescriptionFromExternalImageSearchResult:externalImageSearchResult text:concreteMessage.text entities:concreteMessage.entities botContextResult:botContextResult];
                                        if (description != nil) {
                                            [strongSelf->_companion controllerWantsToSendImagesWithDescriptions:@[description] asReplyToMessageId:[strongSelf currentReplyMessageId] botReplyMarkup:concreteMessage.replyMarkup];
                                            [strongSelf->_inputTextPanel.inputField setText:@"" animated:true];
                                            [TGRecentContextBotsSignal addRecentBot:results.userId];
                                        }
                                    } else if ([concreteResult.type isEqualToString:@"audio"] || [concreteResult.type isEqualToString:@"voice"] || [concreteResult.type isEqualToString:@"file"]) {
                                        id description = [strongSelf->_companion documentDescriptionFromBotContextResult:concreteResult text:concreteMessage.text entities:concreteMessage.entities botContextResult:botContextResult];
                                        if (description != nil) {
                                            [strongSelf->_companion controllerWantsToSendImagesWithDescriptions:@[description] asReplyToMessageId:[strongSelf currentReplyMessageId] botReplyMarkup:concreteMessage.replyMarkup];
                                            [strongSelf->_inputTextPanel.inputField setText:@"" animated:true];
                                            [TGRecentContextBotsSignal addRecentBot:results.userId];
                                        }
                                    } else {
                                        if (![strongSelf->_companion allowMessageForwarding] && !TGAppDelegateInstance.allowSecretWebpages) {
                                            for (id result in [TGMessage textCheckingResultsForText:concreteMessage.text highlightMentionsAndTags:false highlightCommands:false entities:nil]) {
                                                if ([result isKindOfClass:[NSTextCheckingResult class]] && ((NSTextCheckingResult *)result).resultType == NSTextCheckingTypeLink) {
                                                    [strongSelf->_companion maybeAskForSecretWebpages];
                                                    return;
                                                }
                                            }
                                        }
                                        
                                        [strongSelf->_companion controllerWantsToSendTextMessage:concreteMessage.text entities:@[] asReplyToMessageId:[strongSelf currentReplyMessageId] withAttachedMessages:[strongSelf currentForwardMessages] completeGroups:[strongSelf currentForwardCompleteGroups] disableLinkPreviews:false botContextResult:botContextResult botReplyMarkup:concreteMessage.replyMarkup];
                                    }
                                }
                            } else if ([result.sendMessage isKindOfClass:[TGBotContextResultSendMessageText class]]) {
                                TGBotContextResultSendMessageText *concreteMessage = (TGBotContextResultSendMessageText *)result.sendMessage;
                                
                                if (![strongSelf->_companion allowMessageForwarding] && !TGAppDelegateInstance.allowSecretWebpages) {
                                    for (id result in [TGMessage textCheckingResultsForText:concreteMessage.message highlightMentionsAndTags:false highlightCommands:false entities:nil]) {
                                        if ([result isKindOfClass:[NSTextCheckingResult class]] && ((NSTextCheckingResult *)result).resultType == NSTextCheckingTypeLink) {
                                            [strongSelf->_companion maybeAskForSecretWebpages];
                                            return;
                                        }
                                    }
                                }
                                
                                [strongSelf->_companion controllerWantsToSendTextMessage:concreteMessage.message entities:concreteMessage.entities asReplyToMessageId:[strongSelf currentReplyMessageId] withAttachedMessages:[strongSelf currentForwardMessages] completeGroups:[strongSelf currentForwardCompleteGroups] disableLinkPreviews:false botContextResult:botContextResult botReplyMarkup:concreteMessage.replyMarkup];
                            } else if ([result.sendMessage isKindOfClass:[TGBotContextResultSendMessageGeo class]]) {
                                TGBotContextResultSendMessageGeo *concreteMessage = (TGBotContextResultSendMessageGeo *)result.sendMessage;
                                [strongSelf->_companion controllerWantsToSendMapWithLatitude:concreteMessage.location.latitude longitude:concreteMessage.location.longitude venue:concreteMessage.location.venue period:0 asReplyToMessageId:[strongSelf currentReplyMessageId] botContextResult:botContextResult botReplyMarkup:concreteMessage.replyMarkup];
                                [strongSelf->_inputTextPanel.inputField setText:@"" animated:true];
                            } else if ([result.sendMessage isKindOfClass:[TGBotContextResultSendMessageContact class]]) {
                                TGBotContextResultSendMessageContact *concreteMessage = (TGBotContextResultSendMessageContact *)result.sendMessage;
                                TGUser *contactUser = [[TGUser alloc] init];
                                contactUser.firstName = concreteMessage.contact.firstName;
                                contactUser.lastName = concreteMessage.contact.lastName;
                                contactUser.phoneNumber = concreteMessage.contact.phoneNumber;
                                [strongSelf->_companion controllerWantsToSendContact:contactUser asReplyToMessageId:[strongSelf currentReplyMessageId] botContextResult:botContextResult botReplyMarkup:concreteMessage.replyMarkup];
                                [strongSelf->_inputTextPanel.inputField setText:@"" animated:true];
                            }
                        }
                    };
                    
                    NSNumber *banTimeout = [strongSelf->_companion inlineMediaRestrictionTimeout];
                    if (banTimeout != nil) {
                        TGModernConversationRestrictedInlineAssociatedPanel *panel = nil;
                        if ([[strongSelf->_inputTextPanel associatedPanel] isKindOfClass:[TGModernConversationRestrictedInlineAssociatedPanel class]]) {
                            TGModernConversationRestrictedInlineAssociatedPanel *currentPanel = (TGModernConversationRestrictedInlineAssociatedPanel *)[strongSelf->_inputTextPanel associatedPanel];
                            panel = currentPanel;
                        }
                        
                        if (panel == nil) {
                            panel = [[TGModernConversationRestrictedInlineAssociatedPanel alloc] initWithStyle:TGModernConversationAssociatedInputPanelDefaultStyle];
                            [strongSelf->_inputTextPanel setAssociatedPanel:panel animated:true];
                        }
                        panel.timeout = [banTimeout intValue];
                    } else {
                        TGBotContextResults *results = next;
                        if (results.results.count == 0 && results.switchPm == nil) {
                            [strongSelf->_inputTextPanel setDisplayProgress:false];
                            if ([[strongSelf->_inputTextPanel associatedPanel] isKindOfClass:[TGModernConversationGenericContextResultsAssociatedPanel class]] || [[strongSelf->_inputTextPanel associatedPanel] isKindOfClass:[TGModernConversationComplexMediaContextResultsAssociatedPanel class]] || [[strongSelf->_inputTextPanel associatedPanel] isKindOfClass:[TGModernConversationMediaContextResultsAssociatedPanel class]]) {
                                [strongSelf->_inputTextPanel setAssociatedPanel:nil animated:true];
                            }
                            
                            [strongSelf->_tooltipContainerView removeFromSuperview];
                            strongSelf->_tooltipContainerView = nil;
                        } else if (results.isMedia) {
                            TGModernConversationMediaContextResultsAssociatedPanel *panel = nil;
                            if ([[strongSelf->_inputTextPanel associatedPanel] isKindOfClass:[TGModernConversationMediaContextResultsAssociatedPanel class]]) {
                                TGModernConversationMediaContextResultsAssociatedPanel *currentPanel = (TGModernConversationMediaContextResultsAssociatedPanel *)[strongSelf->_inputTextPanel associatedPanel];
                                if (currentPanel.botId == results.userId) {
                                    panel = currentPanel;
                                }
                            }
                            
                            if (panel == nil) {
                                panel = [[TGModernConversationMediaContextResultsAssociatedPanel alloc] initWithStyle:TGModernConversationAssociatedInputPanelDefaultStyle];
                                panel.botId = results.userId;
                                panel.controller = strongSelf;
                                panel.resultSelected = resultSelected;
                                int64_t peerId = ((TGGenericModernConversationCompanion *)strongSelf->_companion).conversationId;
                                panel.activateSwitchPm = ^(NSString *startParam) {
                                    if (startParam != nil) {
                                        __strong TGModernConversationController *strongSelf = weakSelf;
                                        if (strongSelf != nil) {
                                            if (results.userId == peerId) {
                                                [strongSelf setInputText:@"" replace:true selectRange:NSMakeRange(0, 0)];
                                                [strongSelf->_companion performBotAutostart:startParam];
                                            } else {
                                                [[TGInterfaceManager instance] navigateToConversationWithId:results.userId conversation:nil performActions:@{@"botAutostartPayload": startParam, @"contextPeerId": @(peerId)}];
                                            }
                                        }
                                    }
                                };
                                
                                [strongSelf->_inputTextPanel setAssociatedPanel:panel animated:true];
                            }
                            
                            [panel setResults:results reload:true];
                        } else {
                            TGModernConversationGenericContextResultsAssociatedPanel *panel = nil;
                            if ([[strongSelf->_inputTextPanel associatedPanel] isKindOfClass:[TGModernConversationGenericContextResultsAssociatedPanel class]]) {
                                TGModernConversationGenericContextResultsAssociatedPanel *currentPanel = (TGModernConversationGenericContextResultsAssociatedPanel *)[strongSelf->_inputTextPanel associatedPanel];
                                if (currentPanel.botId == results.userId) {
                                    panel = currentPanel;
                                }
                            }
                            
                            if (panel == nil) {
                                panel = [[TGModernConversationGenericContextResultsAssociatedPanel alloc] initWithStyle:TGModernConversationAssociatedInputPanelDefaultStyle];
                                panel.botId = results.userId;
                                panel.controller = strongSelf;
                                panel.resultSelected = resultSelected;
                                int64_t peerId = ((TGGenericModernConversationCompanion *)strongSelf->_companion).conversationId;
                                panel.activateSwitchPm = ^(NSString *startParam) {
                                    __strong TGModernConversationController *strongSelf = weakSelf;
                                    if (strongSelf != nil) {
                                        if (startParam != nil) {
                                            if (results.userId == ((TGGenericModernConversationCompanion *)strongSelf->_companion).conversationId) {
                                                [strongSelf setInputText:@"" replace:true selectRange:NSMakeRange(0, 0)];
                                                [strongSelf->_companion performBotAutostart:startParam];
                                            } else {
                                                [[TGInterfaceManager instance] navigateToConversationWithId:results.userId conversation:nil performActions:@{@"botAutostartPayload": startParam, @"contextPeerId": @(peerId)}];
                                            }
                                        }
                                    }
                                };
                                [strongSelf->_inputTextPanel setAssociatedPanel:panel animated:true];
                            }
                            
                            [panel setResults:results];
                        }
                    }
                }
            }
        } error:^(__unused id error) {
            
        } completed:nil]];
    } else {
        [_inputTextPanel setDisplayProgress:false];
        if ([[_inputTextPanel associatedPanel] isKindOfClass:[TGModernConversationGenericContextResultsAssociatedPanel class]] || [[_inputTextPanel associatedPanel] isKindOfClass:[TGModernConversationComplexMediaContextResultsAssociatedPanel class]] || [[_inputTextPanel associatedPanel] isKindOfClass:[TGModernConversationMediaContextResultsAssociatedPanel class]] || [[_inputTextPanel associatedPanel] isKindOfClass:[TGModernConversationRestrictedInlineAssociatedPanel class]]) {
            [_inputTextPanel setAssociatedPanel:nil animated:true];
        }
        
        [_tooltipContainerView removeFromSuperview];
        _tooltipContainerView = nil;
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
            panel.commandSelected = ^(TGBotComandInfo *command, TGUser *user, bool substitute)
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
                    
                    if (substitute) {
                        [strongSelf appendCommand:commandText];
                        [strongSelf openKeyboard];
                    } else {
                        [strongSelf->_companion controllerWantsToSendTextMessage:[@"/" stringByAppendingString:commandText] entities:nil asReplyToMessageId:[strongSelf currentReplyMessageId] withAttachedMessages:@[] completeGroups:nil disableLinkPreviews:false botContextResult:nil botReplyMarkup:nil];
                    }
                }
            };
            [_inputTextPanel setAssociatedPanel:panel animated:true];
        }
        [panel setCommandListSignal:[_companion commandListForCommand:command]];
    }
}

- (void)inputPanelAlphacodeEntered:(TGModernConversationInputTextPanel *)__unused inputTextPanel alphacode:(NSString *)alphacode {
    if (alphacode == nil)
    {
        if ([[_inputTextPanel associatedPanel] isKindOfClass:[TGModernConversationAlphacodeAssociatedPanel class]])
            [_inputTextPanel setAssociatedPanel:nil animated:true];
    }
    else
    {
        TGModernConversationAlphacodeAssociatedPanel *panel = nil;
        if ([[_inputTextPanel associatedPanel] isKindOfClass:[TGModernConversationAlphacodeAssociatedPanel class]])
            panel = ((TGModernConversationAlphacodeAssociatedPanel *)[_inputTextPanel associatedPanel]);
        else
        {
            panel = [[TGModernConversationAlphacodeAssociatedPanel alloc] initWithStyle:TGModernConversationAssociatedInputPanelDefaultStyle];
            __weak TGModernConversationController *weakSelf = self;
            panel.alphacodeSelected = ^(TGAlphacodeEntry *entry)
            {
                __strong TGModernConversationController *strongSelf = weakSelf;
                if (strongSelf != nil)
                {
                    if ([[strongSelf->_inputTextPanel associatedPanel] isKindOfClass:[TGModernConversationAlphacodeAssociatedPanel class]])
                    {
                        [strongSelf->_inputTextPanel setAssociatedPanel:nil animated:false];
                    }
                    
                    NSString *codeText = entry.emoji;
                    
                    [strongSelf appendAlphacode:[codeText stringByAppendingString:@""]];
                }
            };
            [_inputTextPanel setAssociatedPanel:panel animated:true];
        }
        [panel setAlphacodeListSignal:[_companion alphacodeListForQuery:alphacode]];
    }
}

- (void)inputPanelLinkParsed:(TGModernConversationInputTextPanel *)__unused inputTextPanel link:(NSString *)link probablyComplete:(bool)probablyComplete
{
    if (link.length != 0 && ![_companion allowMessageForwarding] && !TGAppDelegateInstance.allowSecretWebpages) {
        [_companion maybeAskForSecretWebpages];
        return;
    }
    
    if (![_companion canAttachLinkPreviews]) {
        return;
    }
    
    if (![_companion allowExternalContent])
        return;
    
    if (_inputTextPanel.messageEditingContext != nil && _inputTextPanel.messageEditingContext.isCaption) {
        return;
    }
    
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
                parseLinkSignal = [parseLinkSignal delay:1.4 onQueue:[SQueue mainQueue]];
            
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
        [TGCustomAlertView presentAlertWithTitle:TGLocalized(@"FeatureDisabled.Oops") message:disabledMessage cancelButtonTitle:TGLocalized(@"Common.OK") okButtonTitle:nil completionBlock:nil];
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

- (NSSet *)currentForwardCompleteGroups
{
    id extendedPanel = [_inputTextPanel primaryExtendedPanel];
    if ([extendedPanel isKindOfClass:[TGModernConversationForwardInputPanel class]])
        return ((TGModernConversationForwardInputPanel *)extendedPanel).completeGroups;
    return nil;
}

- (void)inputPanelRequestedSendMessage:(TGModernConversationInputTextPanel *)inputTextPanel text:(NSString *)text {
    [self inputPanelRequestedSendMessage:inputTextPanel text:text entities:nil media:nil preparedMessage:nil];
}

- (void)inputPanelRequestedSendMessage:(TGModernConversationInputTextPanel *)__unused inputTextPanel text:(NSString *)text entities:(NSArray *)entities {
    [self inputPanelRequestedSendMessage:inputTextPanel text:text entities:entities media:nil preparedMessage:nil];
}

- (void)inputPanelRequestedSendMessage:(TGModernConversationInputTextPanel *)__unused inputTextPanel text:(NSString *)text entities:(NSArray *)entities media:(TLInputMedia *)media preparedMessage:(TGPreparedMessage *)preparedMessage
{
    if (_inputTextPanel.messageEditingContext != nil) {
        __weak TGModernConversationController *weakSelf = self;
        if (_saveEditedMessageDisposable == nil) {
            _saveEditedMessageDisposable = [[SMetaDisposable alloc] init];
        }
        
        __autoreleasing NSArray *entities = nil;
        NSString *text = [_inputTextPanel.inputField textWithEntities:&entities];
        
        [_saveEditedMessageDisposable setDisposable:nil];
        if ([_inputTextPanel.primaryExtendedPanel isKindOfClass:[TGModernConversationEditingMessageInputPanel class]]) {
            ((TGModernConversationEditingMessageInputPanel *)_inputTextPanel.primaryExtendedPanel).displayProgress = true;
        }
        [_saveEditedMessageDisposable setDisposable:[[[[[_companion saveEditedMessageWithId:_inputTextPanel.messageEditingContext.messageId text:text entities:entities disableLinkPreviews:_disableLinkPreviewsForMessage] timeout:30.0 onQueue:[SQueue mainQueue] orSignal:[SSignal fail:@"timeout"]] deliverOn:[SQueue mainQueue]] onDispose:^{
            __strong TGModernConversationController *strongSelf = weakSelf;
            if (strongSelf != nil) {
                if ([strongSelf->_inputTextPanel.primaryExtendedPanel isKindOfClass:[TGModernConversationEditingMessageInputPanel class]]) {
                    ((TGModernConversationEditingMessageInputPanel *)strongSelf->_inputTextPanel.primaryExtendedPanel).displayProgress = false;
                }
            }
        }] startWithNext:nil error:^(id error) {
            NSString *errorType = [[TGTelegramNetworking instance] extractNetworkErrorType:error];
            if ([errorType isEqual:@"MESSAGE_NOT_MODIFIED"]) {
                __strong TGModernConversationController *strongSelf = weakSelf;
                if (strongSelf != nil) {
                    [strongSelf endMessageEditing:true];
                }
            } else {
                NSString *errorText = TGLocalized(@"Login.UnknownError");
                if (![error isEqual:@"timeout"]) {
                    errorText = TGLocalized(@"Channel.EditMessageErrorGeneric");
                }
                [TGCustomAlertView presentAlertWithTitle:nil message:errorText cancelButtonTitle:TGLocalized(@"Common.OK") okButtonTitle:nil completionBlock:nil];
            }
        } completed:^{
            __strong TGModernConversationController *strongSelf = weakSelf;
            if (strongSelf != nil) {
                [strongSelf endMessageEditing:true];
            }
        }]];
        _disableLinkPreviewsForMessage = false;
    } else {
        [_companion controllerWantsToSendTextMessage:text entities:entities asReplyToMessageId:[self currentReplyMessageId] withAttachedMessages:[self currentForwardMessages] completeGroups:[self currentForwardCompleteGroups] disableLinkPreviews:_disableLinkPreviewsForMessage botContextResult:nil botReplyMarkup:nil];
        _disableLinkPreviewsForMessage = false;
    }
}

- (void)_asyncProcessMediaAssetSignals:(NSArray *)signals
{
    SQueue *queue = [[SQueue alloc] init];
    
    SSignal *combinedSignal = nil;
    for (SSignal *signal in signals)
    {
        if (combinedSignal == nil)
            combinedSignal = [signal startOn:queue];
        else
            combinedSignal = [[combinedSignal then:signal] startOn:queue];
    }
    
    __weak TGModernConversationController *weakSelf = self;
    [_processMediaDisposable setDisposable:[[[combinedSignal reduceLeft:[[NSMutableArray alloc] init] with:^NSMutableArray *(NSMutableArray *itemDescriptions, id item)
    {
        if ([item isKindOfClass:[NSDictionary class]])
            [itemDescriptions addObject:item];
        
        return itemDescriptions;
    }] deliverOn:[SQueue mainQueue]] startWithNext:^(NSArray *itemDescriptions)
    {
        __strong TGModernConversationController *strongSelf = weakSelf;
        
        NSMutableArray *mediaDescriptions = [[NSMutableArray alloc] init];
        NSMutableArray *fileDescriptions = [[NSMutableArray alloc] init];
        
        for (NSDictionary *description in itemDescriptions)
        {
            if (description[@"localImage"] || description[@"remoteImage"] || description[@"downloadImage"]
                || description[@"downloadDocument"] || description[@"downloadExternalGif"]
                || description[@"downloadExternalImage"] || description[@"remoteDocument"]
                || description[@"remoteCachedDocument"] || description[@"assetImage"] || description[@"assetVideo"] || description[@"cameraVideo"])
            {
                [mediaDescriptions addObject:description];
            }
            else
            {
                [fileDescriptions addObject:description];
            }
        }
        
        if (mediaDescriptions.count > 0)
            [strongSelf.companion controllerWantsToSendImagesWithDescriptions:mediaDescriptions asReplyToMessageId:[strongSelf currentReplyMessageId] botReplyMarkup:nil];
        
        if (fileDescriptions.count > 0)
            [strongSelf.companion controllerWantsToSendDocumentsWithDescriptions:fileDescriptions asReplyToMessageId:[strongSelf currentReplyMessageId]];
    }]];
}

- (NSDictionary *)_descriptionForReplacingMedia:(NSDictionary *)description message:(TGMessage *)message
{
    NSMutableDictionary *newDescription = [description mutableCopy];
    NSDictionary *messageDesc = @{ @"cid": @(message.cid), @"mid": @(message.mid) };
    newDescription[@"message"] = messageDesc;
    return newDescription;
}

- (NSDictionary *)_descriptionForItem:(id)item caption:(NSString *)caption entities:(NSArray *)entities hash:(NSString *)hash allowRemoteCache:(bool)allowRemoteCache
{
    if (item == nil)
        return nil;
    
    if ([item isKindOfClass:[UIImage class]])
    {
        return [self.companion imageDescriptionFromImage:(UIImage *)item stickers:nil caption:caption entities:entities optionalAssetUrl:hash != nil ? [[NSString alloc] initWithFormat:@"image-%@", hash] : nil allowRemoteCache:allowRemoteCache timer:0];
    }
    else if ([item isKindOfClass:[NSDictionary class]])
    {
        NSDictionary *dict = (NSDictionary *)item;
        NSString *type = dict[@"type"];
        
        int32_t timer = [dict[@"timer"] intValue];
        if (timer > 0) {
            allowRemoteCache = false;
        }
        
        NSDictionary *description = nil;
        if ([type isEqualToString:@"editedPhoto"]) {
            description = [self.companion imageDescriptionFromImage:dict[@"image"] stickers:dict[@"stickers"] caption:caption entities:entities optionalAssetUrl:hash != nil ? [[NSString alloc] initWithFormat:@"image-%@", hash] : nil allowRemoteCache:allowRemoteCache timer:[dict[@"timer"] intValue]];
        }
        else if ([type isEqualToString:@"cloudPhoto"])
        {
            if ([dict[@"livePhoto"] boolValue])
            {
                description = [self.companion videoDescriptionFromMediaAsset:dict[@"asset"] previewImage:dict[@"previewImage"] dimensions:[dict[@"dimensions"] CGSizeValue] duration:[dict[@"duration"] doubleValue] adjustments:dict[@"adjustments"] document:false fileName:dict[@"fileName"] stickers:dict[@"stickers"] caption:caption entities:entities timer:timer];
            }
            else
            {
                description = [self.companion imageDescriptionFromMediaAsset:dict[@"asset"] previewImage:dict[@"previewImage"] document:[dict[@"document"] boolValue] fileName:dict[@"fileName"] caption:caption entities:entities allowRemoteCache:allowRemoteCache];
            }
        }
        else if ([type isEqualToString:@"video"])
        {
            description = [self.companion videoDescriptionFromMediaAsset:dict[@"asset"] previewImage:dict[@"previewImage"] dimensions:[dict[@"dimensions"] CGSizeValue] duration:[dict[@"duration"] doubleValue] adjustments:dict[@"adjustments"] document:[dict[@"document"] boolValue] fileName:dict[@"fileName"] stickers:dict[@"stickers"] caption:caption entities:entities timer:timer];
        }
        else if ([type isEqualToString:@"file"])
        {
            description = [self.companion documentDescriptionFromFileAtTempUrl:dict[@"tempFileUrl"] fileName:dict[@"fileName"] mimeType:dict[@"mimeType"] isAnimation:dict[@"isAnimation"] caption:caption entities:entities];
        }
        else if ([type isEqualToString:@"webPhoto"])
        {
            description = [self.companion imageDescriptionFromImage:dict[@"image"] stickers:dict[@"stickers"] caption:caption entities:entities optionalAssetUrl:nil allowRemoteCache:allowRemoteCache && timer == 0 timer:timer];
        }
        else if ([type isEqualToString:@"cameraVideo"])
        {
            description = [self.companion videoDescriptionFromVideoURL:dict[@"url"] previewImage:dict[@"previewImage"] dimensions:[dict[@"dimensions"] CGSizeValue] duration:[dict[@"duration"] doubleValue] adjustments:dict[@"adjustments"] stickers:dict[@"stickers"] caption:caption entities:entities roundMessage:false liveUploadData:nil timer:timer];
        }
        
        if (dict[@"timer"] != nil || dict[@"groupedId"] != nil)
        {
            NSMutableDictionary *timedDescription = [description mutableCopy];
            if (dict[@"timer"] != nil)
                timedDescription[@"timer"] = dict[@"timer"];
            if (dict[@"groupedId"] != nil)
                timedDescription[@"groupedId"] = dict[@"groupedId"];
            description = timedDescription;
        }
        
        return description;
    }
    if ([item isKindOfClass:[TGBingSearchResultItem class]])
    {
        id description = [self.companion imageDescriptionFromBingSearchResult:item caption:caption entities:entities];
        return description;
    }
    else if ([item isKindOfClass:[TGGiphySearchResultItem class]])
    {
        id description = [self.companion documentDescriptionFromGiphySearchResult:item caption:caption entities:entities];
        return description;
    }
    else if ([item isKindOfClass:[TGExternalGifSearchResult class]]) {
        return [self.companion documentDescriptionFromExternalGifSearchResult:item text:caption entities:entities botContextResult:nil];
    }
    else if ([item isKindOfClass:[TGInternalGifSearchResult class]]) {
        return [self.companion documentDescriptionFromRemoteDocument:((TGInternalGifSearchResult *)item).document caption:caption entities:entities];
    }
    else if ([item isKindOfClass:[TGWebSearchInternalImageResult class]])
    {
        id description = [self.companion imageDescriptionFromInternalSearchImageResult:item caption:caption entities:entities];
        return description;
    }
    else if ([item isKindOfClass:[TGWebSearchInternalGifResult class]])
    {
        id description = [self.companion documentDescriptionFromInternalSearchResult:item caption:caption entities:entities];
        return description;
    }
    
    return nil;
}

- (void)_dismissBannersForCurrentConversation
{
    [[TGInterfaceManager instance] dismissBannerForConversationId:[self peerId]];
}

- (void)inputPanelExpandedKeyboard:(TGModernConversationInputTextPanel *)__unused inputTextPanel expanded:(bool)expanded
{
    if (iosMajorVersion() >= 7)
        self.navigationController.interactivePopGestureRecognizer.enabled = !expanded;
    
    self.navigationController.navigationBar.userInteractionEnabled = !expanded;
    
    if (TGIsPad() && self.willChangeDim != nil)
        self.willChangeDim(expanded, nil, false);
}

- (void)inputPanelRequestedFastCamera:(TGModernConversationInputTextPanel *)inputTextPanel
{
    if (iosMajorVersion() < 8 || TGIsPad() || ![PGCamera cameraAvailable] || !UIInterfaceOrientationIsPortrait(self.interfaceOrientation))
        return;
    
    if (_inputTextPanel.isCustomKeyboardExpanded)
        return;
    
    if (_inputTextPanel.messageEditingContext != nil)
        return;
    
    if (![[[LegacyComponentsGlobals provider] accessChecker] checkCameraAuthorizationStatusForIntent:TGCameraAccessIntentDefault alertDismissCompletion:nil])
        return;
    
    CGRect attachmentButtonFrame = [inputTextPanel convertRect:[inputTextPanel attachmentButtonFrame] toView:nil];
    TGFastCameraController *controller = [[TGFastCameraController alloc] initWithParentController:self attachmentButtonFrame:attachmentButtonFrame saveCapturedMedia:TGAppDelegateInstance.saveCapturedMedia saveEditedPhotos:TGAppDelegateInstance.saveEditedPhotos];
    controller.shouldStoreCapturedAssets = [_companion controllerShouldStoreCapturedAssets];
    controller.allowCaptions = [_companion allowCaptionedMedia];
    controller.allowCaptionEntities = [_companion allowCaptionEntities];
    controller.inhibitDocumentCaptions = ![_companion allowCaptionedDocuments];
    controller.suggestionContext = [self _suggestionContext];
    controller.recipientName = [_companion title];
    controller.hasTimer = [_companion allowSelfDescructingMedia];
    
    _fastCameraController = controller;
    
    __weak TGModernConversationController *weakSelf = self;
    controller.finishedWithPhoto = ^(UIImage *resultImage, NSString *caption, NSArray *entities, NSArray *stickers, NSNumber *timer)
    {
        __strong TGModernConversationController *strongSelf = weakSelf;
        if (strongSelf == nil)
            return;
        
        __autoreleasing NSString *disabledMessage = nil;
        if (![TGApplicationFeatures isPhotoUploadEnabledForPeerType:[strongSelf->_companion applicationFeaturePeerType] disabledMessage:&disabledMessage])
        {
            [TGCustomAlertView presentAlertWithTitle:TGLocalized(@"FeatureDisabled.Oops") message:disabledMessage cancelButtonTitle:TGLocalized(@"Common.OK") okButtonTitle:nil completionBlock:nil];
            return;
        }
        
        NSDictionary *imageDescription = [strongSelf->_companion imageDescriptionFromImage:resultImage stickers:stickers caption:caption entities:entities optionalAssetUrl:nil allowRemoteCache:false timer:[timer intValue]];
        if (timer != nil)
        {
            NSMutableDictionary *timedDescription = [imageDescription mutableCopy];
            timedDescription[@"timer"] = timer;
            imageDescription = timedDescription;
        }
        
        NSMutableArray *descriptions = [[NSMutableArray alloc] init];
        if (imageDescription != nil)
            [descriptions addObject:imageDescription];
        [strongSelf->_companion controllerWantsToSendImagesWithDescriptions:descriptions asReplyToMessageId:[strongSelf currentReplyMessageId] botReplyMarkup:nil];
    };
    
    controller.finishedWithVideo = ^(NSURL *videoURL, UIImage *previewImage, NSTimeInterval duration, CGSize dimensions, TGVideoEditAdjustments *adjustments, NSString *caption, NSArray *entities, NSArray *stickers, NSNumber *timer)
    {
        __strong TGModernConversationController *strongSelf = weakSelf;
        if (strongSelf == nil)
            return;
        
        __autoreleasing NSString *disabledMessage = nil;
        if (![TGApplicationFeatures isFileUploadEnabledForPeerType:[strongSelf->_companion applicationFeaturePeerType] disabledMessage:&disabledMessage])
        {
            [TGCustomAlertView presentAlertWithTitle:TGLocalized(@"FeatureDisabled.Oops") message:disabledMessage cancelButtonTitle:TGLocalized(@"Common.OK") okButtonTitle:nil completionBlock:nil];
            return;
        }
        
        NSDictionary *desc = [strongSelf->_companion videoDescriptionFromVideoURL:videoURL previewImage:previewImage dimensions:dimensions duration:duration adjustments:adjustments stickers:stickers caption:caption entities:entities roundMessage:false liveUploadData:nil timer:[timer intValue]];
        if (timer != nil)
        {
            NSMutableDictionary *timedDescription = [desc mutableCopy];
            timedDescription[@"timer"] = timer;
            desc = timedDescription;
        }
        
        [strongSelf->_companion controllerWantsToSendImagesWithDescriptions:@[ desc ] asReplyToMessageId:[strongSelf currentReplyMessageId] botReplyMarkup:nil];
    };
    
    
    bool dismissingKeyboard = false;
    if (_currentInputPanel == _inputTextPanel)
    {
        if (!_inputTextPanel.isCustomKeyboardActive)
        {
            [_inputTextPanel prepareForResultPreviewAppearance:true];
            dismissingKeyboard = true;
        }
    }
    
    controller.transitionedIn = ^
    {
        __strong TGModernConversationController *strongSelf = weakSelf;
        if (strongSelf == nil)
            return;
        
        if (dismissingKeyboard)
            [_inputTextPanel prepareForResultPreviewDismissal:false];
    };
}

- (void)inputPanelPannedFastCamera:(TGModernConversationInputTextPanel *)__unused inputTextPanel location:(CGPoint)location
{
    [_fastCameraController handlePanAt:location];
}

- (void)inputPanelReleasedFastCamera:(TGModernConversationInputTextPanel *)__unused inputTextPanel location:(CGPoint)location
{
    [_fastCameraController handleReleaseAt:location];
}

- (void)inputPanelRequestedAttachmentsMenu:(TGModernConversationInputTextPanel *)__unused inputTextPanel
{
    if (_inputTextPanel.messageEditingContext != nil)
    {
        TGMessage *message = [TGDatabaseInstance() loadMessageWithMid:_inputTextPanel.messageEditingContext.messageId peerId:_inputTextPanel.messageEditingContext.cid];
        [self displayMediaEditingOptions:message];
        return;
    }
    
    bool showLegacyMenu = ((TGIsPad() && iosMajorVersion() < 8) || iosMajorVersion() < 7);
    if (!showLegacyMenu)
        [self _displayAttachmentsMenu];
    else
        [self _displayLegacyAttachmentsMenu];
}

- (void)_displayAttachmentsMenu
{
    __weak TGModernConversationController *weakSelf = self;
    
    NSNumber *banTimeout = [_companion mediaRestrictionTimeout];
    if (banTimeout != nil) {
        NSString *text = @"";
        
        if (banTimeout.intValue == 0 || banTimeout.intValue == INT32_MAX) {
            text = TGLocalized(@"Conversation.RestrictedMedia");
        } else {
            NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
            [formatter setDateFormat:@"E, d MMM HH:mm"];
            formatter.locale = [NSLocale localeWithLocaleIdentifier:effectiveLocalization().code];
            NSString *dateStringPlain = [formatter stringFromDate:[NSDate dateWithTimeIntervalSince1970:banTimeout.intValue]];
            
            text = [NSString stringWithFormat:TGLocalized(@"Conversation.RestrictedMediaTimed"), dateStringPlain];
        }
        
        [[[TGCustomActionSheet alloc] initWithTitle:text actions:@[
           [[TGActionSheetAction alloc] initWithTitle:TGLocalized(@"Conversation.Location") action:@"location"],
           [[TGActionSheetAction alloc] initWithTitle:TGLocalized(@"Conversation.Contact") action:@"contact"],
           [[TGActionSheetAction alloc] initWithTitle:TGLocalized(@"Common.Cancel") action:@"cancel" type:TGActionSheetActionTypeCancel]
           ] actionBlock:^(__unused id target, NSString *action) {
               __strong TGModernConversationController *strongSelf = weakSelf;
               if (strongSelf == nil)
                   return;
               
               if ([action isEqualToString:@"location"]) {
                   [strongSelf _displayLocationPicker];
               } else if ([action isEqualToString:@"contact"]) {
                   [strongSelf _displayContactPicker];
               }
        } target:self] showInView:self.view];
        
        return;
    }
    
    TGMenuSheetController *controller = [[TGMenuSheetController alloc] initWithContext:[TGLegacyComponentsContext shared] dark:false];
    controller.dismissesByOutsideTap = true;
    controller.hasSwipeGesture = true;
    controller.maxHeight = 445.0f;
    
    __weak TGMenuSheetController *weakController = controller;
    
    NSMutableArray *itemViews = [[NSMutableArray alloc] init];
    
    bool hasContactItem = [self.companion allowContactSharing];
    
    TGAttachmentCarouselItemView *carouselItem = [[TGAttachmentCarouselItemView alloc] initWithContext:[TGLegacyComponentsContext shared] camera:[PGCamera cameraAvailable] selfPortrait:false forProfilePhoto:false assetType:TGMediaAssetAnyType saveEditedPhotos:TGAppDelegateInstance.saveEditedPhotos allowGrouping:[_companion allowMediaGrouping]];
    carouselItem.condensed = !hasContactItem;
    carouselItem.parentController = self;
    carouselItem.allowCaptions = [_companion allowCaptionedMedia];
    carouselItem.allowCaptionEntities = [_companion allowCaptionEntities];
    carouselItem.hasTimer = [_companion allowSelfDescructingMedia];
    carouselItem.inhibitDocumentCaptions = ![_companion allowCaptionedDocuments];
    carouselItem.recipientName = [_companion title];
    
    __weak TGAttachmentCarouselItemView *weakCarouselItem = carouselItem;
    carouselItem.suggestionContext = [self _suggestionContext];
    carouselItem.cameraPressed = ^(TGAttachmentCameraView *cameraView)
    {
        __strong TGModernConversationController *strongSelf = weakSelf;
        if (strongSelf == nil)
            return;
        
        __strong TGMenuSheetController *strongController = weakController;
        if (strongController == nil)
            return;
        
        [strongSelf _displayCameraWithView:cameraView menuController:strongController];
    };
    carouselItem.sendPressed = ^(TGMediaAsset *currentItem, bool asFiles)
    {
        __strong TGModernConversationController *strongSelf = weakSelf;
        if (strongSelf == nil)
            return;
        
        __strong TGMenuSheetController *strongController = weakController;
        if (strongController == nil)
            return;
        
        __strong TGAttachmentCarouselItemView *strongCarouselItem = weakCarouselItem;
        if (strongController == nil)
            return;
        
        [strongController dismissAnimated:true];
        
        bool allowRemoteCache = [strongSelf->_companion controllerShouldCacheServerAssets];
        TGMediaAssetsControllerIntent intent = asFiles ? TGMediaAssetsControllerSendFileIntent : TGMediaAssetsControllerSendMediaIntent;
        [strongSelf _asyncProcessMediaAssetSignals:[TGMediaAssetsController resultSignalsForSelectionContext:strongCarouselItem.selectionContext editingContext:strongCarouselItem.editingContext intent:intent currentItem:currentItem storeAssets:[strongSelf->_companion controllerShouldStoreCapturedAssets] useMediaCache:[strongSelf->_companion controllerShouldCacheServerAssets] descriptionGenerator:^id(id result, NSString *caption, NSArray *entities, NSString *hash) {
            __strong TGModernConversationController *strongSelf = weakSelf;
            if (strongSelf == nil)
                return nil;
            
            return [strongSelf _descriptionForItem:result caption:caption entities:entities hash:hash allowRemoteCache:allowRemoteCache];
        } saveEditedPhotos:TGAppDelegateInstance.saveEditedPhotos]];
    };
    carouselItem.editorOpened = ^
    {
        __strong TGModernConversationController *strongSelf = weakSelf;
        if (strongSelf == nil)
            return;
        
        [strongSelf _updateCanReadHistory:TGModernConversationActivityChangeInactive];
    };
    carouselItem.editorClosed = ^
    {
        __strong TGModernConversationController *strongSelf = weakSelf;
        if (strongSelf == nil)
            return;
        
        [strongSelf _updateCanReadHistory:TGModernConversationActivityChangeActive];
    };
    [itemViews addObject:carouselItem];
    
    TGMenuSheetButtonItemView *galleryItem = [[TGMenuSheetButtonItemView alloc] initWithTitle:TGLocalized(@"AttachmentMenu.PhotoOrVideo") type:TGMenuSheetButtonTypeDefault action:^
    {
        __strong TGModernConversationController *strongSelf = weakSelf;
        if (strongSelf == nil)
            return;
        
        __strong TGMenuSheetController *strongController = weakController;
        if (strongController == nil)
            return;
        
        [strongController dismissAnimated:true];
        [strongSelf _displayMediaPicker:false fromFileMenu:false];
    }];
    galleryItem.longPressAction = ^
    {
        __strong TGModernConversationController *strongSelf = weakSelf;
        if (strongSelf == nil)
            return;
        
        __strong TGMenuSheetController *strongController = weakController;
        if (strongController == nil)
            return;
        
        [strongController dismissAnimated:true];
        [strongSelf _displayWebImagePicker];
    };
    [itemViews addObject:galleryItem];
    
    TGMenuSheetButtonItemView *fileItem = [[TGMenuSheetButtonItemView alloc] initWithTitle:TGLocalized(@"AttachmentMenu.File") type:TGMenuSheetButtonTypeDefault action:^
    {
        __strong TGModernConversationController *strongSelf = weakSelf;
        if (strongSelf == nil)
            return;
        
        __strong TGMenuSheetController *strongController = weakController;
        if (strongController == nil)
            return;
        
        [strongSelf _displayFileMenuWithController:strongController];
    }];
    fileItem.longPressAction = ^
    {
        __strong TGModernConversationController *strongSelf = weakSelf;
        if (strongSelf == nil)
            return;
        
        __strong TGMenuSheetController *strongController = weakController;
        if (strongController == nil)
            return;
        
        [strongController dismissAnimated:true];
        [strongSelf _displayMediaPicker:true fromFileMenu:false];
    };
    [itemViews addObject:fileItem];
    
    carouselItem.underlyingViews = @[ galleryItem, fileItem ];
    
    TGMenuSheetButtonItemView *locationItem = [[TGMenuSheetButtonItemView alloc] initWithTitle:TGLocalized(@"Conversation.Location") type:TGMenuSheetButtonTypeDefault action:^
    {
        __strong TGModernConversationController *strongSelf = weakSelf;
        if (strongSelf == nil)
            return;
        
        __strong TGMenuSheetController *strongController = weakController;
        if (strongController == nil)
            return;
        
        [strongController dismissAnimated:true];
        [strongSelf _displayLocationPicker];
    }];
    [itemViews addObject:locationItem];
    
    if (hasContactItem)
    {
        TGMenuSheetButtonItemView *contactItem = [[TGMenuSheetButtonItemView alloc] initWithTitle:TGLocalized(@"Conversation.Contact")  type:TGMenuSheetButtonTypeDefault action:^
        {
            __strong TGModernConversationController *strongSelf = weakSelf;
            if (strongSelf == nil)
                return;
            
            __strong TGMenuSheetController *strongController = weakController;
            if (strongController == nil)
                return;
            
            [strongController dismissAnimated:true];
            [strongSelf _displayContactPicker];
        }];
        contactItem.requiresDivider = !TGIsPad();
        [itemViews addObject:contactItem];
    }
    else
    {
        locationItem.requiresDivider = !TGIsPad();
    }
    
    if (!TGIsPad()) {
        NSArray<TGUser *> *inlineBots = [TGDatabaseInstance() _syncCachedRecentInlineBots:0.14f];
        NSUInteger counter = 0;
        for (TGUser *user in inlineBots) {
            if (user.userName.length == 0)
                continue;
            
            TGMenuSheetButtonItemView *botItem = [[TGMenuSheetButtonItemView alloc] initWithTitle:[@"@" stringByAppendingString:user.userName] type:TGMenuSheetButtonTypeDefault action:^
            {
                __strong TGModernConversationController *strongSelf = weakSelf;
                if (strongSelf == nil)
                    return;
                
                __strong TGMenuSheetController *strongController = weakController;
                if (strongController == nil)
                    return;
                
                [strongController dismissAnimated:true];
                strongSelf->_inputTextPanel.inputField.userInteractionEnabled = true;
                [strongSelf->_inputTextPanel.inputField setText:[NSString stringWithFormat:@"@%@ ", user.userName]];
                [strongSelf openKeyboard];
            }];
            botItem.overflow = true;
            [itemViews addObject:botItem];
            counter++;
            if (counter == 20) {
                break;
            }
        }
    }
    
    carouselItem.remainingHeight = TGMenuSheetButtonItemViewHeight * (itemViews.count - 1);
    
    TGMenuSheetButtonItemView *cancelItem = [[TGMenuSheetButtonItemView alloc] initWithTitle:TGLocalized(@"Common.Cancel") type:TGMenuSheetButtonTypeCancel action:^
    {
        __strong TGModernConversationController *strongSelf = weakSelf;
        if (strongSelf == nil)
            return;
        
        __strong TGMenuSheetController *strongController = weakController;
        if (strongController == nil)
            return;
        
        [strongController dismissAnimated:true];
    }];
    [itemViews addObject:cancelItem];
    
    [controller setItemViews:itemViews];
    
    [self endEditing];
    [controller presentInViewController:self sourceView:_inputTextPanel.attachButton animated:true];
    
    _menuController = controller;
}

- (void)_displayLegacyAttachmentsMenu
{
    NSMutableArray *actions = [[NSMutableArray alloc] initWithArray:@
                               [
                                [[TGActionSheetAction alloc] initWithTitle:TGLocalized(@"AttachmentMenu.PhotoOrVideo") action:@"photoOrVideo"],
                                [[TGActionSheetAction alloc] initWithTitle:TGLocalized(@"AttachmentMenu.File") action:@"document"],
                                [[TGActionSheetAction alloc] initWithTitle:TGLocalized(@"Conversation.Location") action:@"chooseLocation"]
                                ]];
    
    if ([_companion allowContactSharing])
        [actions addObject:[[TGActionSheetAction alloc] initWithTitle:TGLocalized(@"Conversation.Contact") action:@"contact"]];
    
    if ([PGCamera cameraAvailable])
        [actions insertObject:[[TGActionSheetAction alloc] initWithTitle:TGLocalized(@"Common.TakePhotoOrVideo") action:@"camera"] atIndex:0];
    
    [actions addObject:[[TGActionSheetAction alloc] initWithTitle:TGLocalized(@"Common.Cancel") action:@"cancel" type:TGActionSheetActionTypeCancel]];
    
    TGCustomActionSheet *actionSheet = [[TGCustomActionSheet alloc] initWithTitle:nil actions:actions actionBlock:^(TGModernConversationController *controller, NSString *action)
    {
        if ([action isEqualToString:@"cancel"])
            return;
        
        [controller endEditing];
        
        if ([action isEqualToString:@"camera"])
            [controller _displayCameraWithView:nil menuController:nil];
        if ([action isEqualToString:@"photoOrVideo"])
            [controller _displayMediaPicker:false fromFileMenu:false];
        else if ([action isEqualToString:@"searchWeb"])
            [controller _displayWebImagePicker];
        else if ([action isEqualToString:@"chooseLocation"])
            [controller _displayLocationPicker];
        else if ([action isEqualToString:@"document"])
            [controller _displayMediaPicker:true fromFileMenu:false];
        else if ([action isEqualToString:@"contact"])
            [controller _displayContactPicker];
    } target:self];
    
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone)
        [actionSheet showInView:self.view];
    else
        [actionSheet showFromRect:CGRectOffset([self.view convertRect:[_inputTextPanel attachmentButtonFrame] fromView:_inputTextPanel], 0.0f, -6.0f) inView:self.view animated:true];
}

- (TGSuggestionContext *)_suggestionContext
{
    __weak TGModernConversationController *weakSelf = self;
    
    TGSuggestionContext *suggestionContext = [[TGSuggestionContext alloc] init];
    suggestionContext.userListSignal = ^SSignal *(NSString *mention)
    {
        __strong TGModernConversationController *strongSelf = weakSelf;
        if (strongSelf == nil)
            return nil;
        
        return [[strongSelf->_companion userListForMention:mention canBeContextBot:false includeSelf:false] map:^id(NSArray *users) {
            NSMutableArray *filteredUsers = [[NSMutableArray alloc] init];
            for (TGUser *user in users) {
                if (strongSelf->_companion.allowCaptionEntities || user.userName.length != 0) {
                    [filteredUsers addObject:user];
                }
            }
            return filteredUsers;
        }];
    };
    
    suggestionContext.hashtagListSignal = ^SSignal *(NSString *hashtag)
    {
        __strong TGModernConversationController *strongSelf = weakSelf;
        if (strongSelf == nil)
            return nil;
        
        return [strongSelf->_companion hashtagListForHashtag:hashtag];
    };
    
    suggestionContext.alphacodeSignal = ^SSignal *(NSString *alphacode)
    {
        __strong TGModernConversationController *strongSelf = weakSelf;
        if (strongSelf == nil)
            return nil;
        
        return [strongSelf->_companion alphacodeListForQuery:alphacode];
    };
    
    return suggestionContext;
}

- (void)_displayMediaPicker:(bool)file fromFileMenu:(bool)fromFileMenu
{
    [self _displayMediaPicker:file fromFileMenu:fromFileMenu message:nil];
}

- (void)_displayMediaPicker:(bool)file fromFileMenu:(bool)fromFileMenu message:(TGMessage *)messageToEdit
{
    if (![[[LegacyComponentsGlobals provider] accessChecker] checkPhotoAuthorizationStatusForIntent:TGPhotoAccessIntentRead alertDismissCompletion:nil])
        return;
    
    __weak TGModernConversationController *weakSelf = self;
    void (^dismissalBlock)(void) = ^
    {
        __strong TGModernConversationController *strongSelf = weakSelf;
        if (strongSelf == nil)
            return;
        
        [strongSelf dismissViewControllerAnimated:true completion:nil];
        [strongSelf _dismissBannersForCurrentConversation];
    };
    
    void (^showMediaPicker)(TGMediaAssetGroup *) = ^(TGMediaAssetGroup *group)
    {
        __strong TGModernConversationController *strongSelf = weakSelf;
        if (strongSelf == nil)
            return;
        
        TGMediaAssetsControllerIntent intent = file ? TGMediaAssetsControllerSendFileIntent : TGMediaAssetsControllerSendMediaIntent;
        TGMediaAssetsController *assetsController = [TGMediaAssetsController controllerWithContext:[TGLegacyComponentsContext shared] assetGroup:group intent:intent recipientName:[strongSelf->_companion title] saveEditedPhotos:TGAppDelegateInstance.saveEditedPhotos allowGrouping:messageToEdit == nil ? [_companion allowMediaGrouping] : false inhibitSelection:messageToEdit != nil];
        assetsController.captionsEnabled = [strongSelf->_companion allowCaptionedMedia];
        assetsController.allowCaptionEntities = [strongSelf->_companion allowCaptionEntities];
        assetsController.inhibitDocumentCaptions = ![strongSelf->_companion allowCaptionedDocuments];
        assetsController.suggestionContext = [strongSelf _suggestionContext];
        assetsController.dismissalBlock = dismissalBlock;
        assetsController.localMediaCacheEnabled = [strongSelf->_companion controllerShouldCacheServerAssets];
        assetsController.shouldStoreAssets = [strongSelf->_companion controllerShouldStoreCapturedAssets];
        assetsController.shouldShowFileTipIfNeeded = (file && !fromFileMenu);
        bool allowRemoteCache = [strongSelf->_companion controllerShouldCacheServerAssets];
        assetsController.hasTimer = messageToEdit == nil ? [strongSelf->_companion allowSelfDescructingMedia] : false;
        assetsController.inhibitMute = messageToEdit != nil;
        assetsController.descriptionGenerator = ^NSDictionary *(id result, NSString *caption, NSArray *entities, NSString *hash)
        {
            __strong TGModernConversationController *strongSelf = weakSelf;
            if (strongSelf == nil)
                return nil;
            
            NSDictionary *desc = [strongSelf _descriptionForItem:result caption:caption entities:entities hash:hash allowRemoteCache:allowRemoteCache];
            if (messageToEdit != nil)
                desc = [strongSelf _descriptionForReplacingMedia:desc message:messageToEdit];
            
            return desc;
        };
        assetsController.completionBlock = ^(NSArray *signals)
        {
            __strong TGModernConversationController *strongSelf = weakSelf;
            if (strongSelf == nil)
                return;
            
            dismissalBlock();
            [strongSelf _asyncProcessMediaAssetSignals:signals];
            if (messageToEdit != nil)
                [strongSelf endMessageEditing:true];
        };
        __weak TGMediaAssetsController *weakAssetsController = assetsController;
        if (messageToEdit == nil) {
            assetsController.requestSearchController = ^TGViewController *{
                __strong TGModernConversationController *strongSelf = weakSelf;
                if (strongSelf == nil)
                    return nil;
                
                __strong TGMediaAssetsController *strongAssetsController = weakAssetsController;
                if (strongAssetsController == nil)
                    return nil;
                
                TGWebSearchController *searchController = [[TGWebSearchController alloc] initWithContext:[TGLegacyComponentsContext shared] forAvatarSelection:false embedded:true allowGrouping:strongAssetsController.allowGrouping];
                searchController.presentation = strongSelf.presentation;
                searchController.captionsEnabled = strongAssetsController.captionsEnabled;
                searchController.allowCaptionEntities = [strongAssetsController allowCaptionEntities];
                searchController.suggestionContext = strongAssetsController.suggestionContext;
                
                __weak TGWebSearchController *weakController = searchController;
                searchController.completionBlock = ^(__unused TGWebSearchController *sender)
                {
                    __strong TGMediaAssetsController *strongAssetsController = weakAssetsController;
                    if (strongSelf == nil || strongAssetsController.completionBlock == nil)
                        return;
                    
                    __strong TGWebSearchController *strongController = weakController;
                    if (strongController == nil)
                        return;
                    
                    NSDictionary *(^descriptionGenerator)(id, NSString *, NSArray *) = ^(id result, NSString *caption, NSArray *entities)
                    {
                        return strongAssetsController.descriptionGenerator(result, caption, entities, nil);
                    };
                    
                    strongAssetsController.completionBlock([strongController selectedItemSignals:descriptionGenerator]);
                };
                searchController.dismiss = ^
                {
                    __strong TGWebSearchController *strongController = weakController;
                    if (strongController == nil)
                        return;
                    
                    [strongController dismissEmbeddedAnimated:true];
                };
                searchController.parentNavigationController = strongAssetsController;
                [searchController presentEmbeddedInController:strongAssetsController animated:true];
                
                return searchController;
            };
        }
        else
        {
            NSArray *entities;
            NSString *text = [_inputTextPanel.maybeInputField textWithEntities:&entities];
            [assetsController.editingContext setForcedCaption:text entities:entities];
        }
        if (TGIsPad())
        {
            assetsController.presentationStyle = TGNavigationControllerPresentationStyleInFormSheet;
            assetsController.modalPresentationStyle = UIModalPresentationFormSheet;
        }
        [strongSelf presentViewController:assetsController animated:true completion:nil];
    };
    
    if ([TGMediaAssetsLibrary authorizationStatus] == TGMediaLibraryAuthorizationStatusNotDetermined)
    {
        [TGMediaAssetsLibrary requestAuthorizationForAssetType:TGMediaAssetAnyType completion:^(__unused TGMediaLibraryAuthorizationStatus status, TGMediaAssetGroup *cameraRollGroup)
        {
            if (![[[LegacyComponentsGlobals provider] accessChecker] checkPhotoAuthorizationStatusForIntent:TGPhotoAccessIntentRead alertDismissCompletion:nil])
                return;
            
            showMediaPicker(cameraRollGroup);
        }];
    }
    else
    {
        showMediaPicker(nil);
    }
}

- (void)_displayCameraWithView:(TGAttachmentCameraView *)cameraView menuController:(TGMenuSheetController *)menuController
{
    [self _displayCameraWithView:cameraView menuController:menuController message:nil];
}

- (void)_displayCameraWithView:(TGAttachmentCameraView *)cameraView menuController:(TGMenuSheetController *)menuController message:(TGMessage *)messageToEdit
{
    __autoreleasing NSString *disabledMessage = nil;
    if (![TGApplicationFeatures isPhotoUploadEnabledForPeerType:[_companion applicationFeaturePeerType] disabledMessage:&disabledMessage])
    {
        [TGCustomAlertView presentAlertWithTitle:TGLocalized(@"FeatureDisabled.Oops") message:disabledMessage cancelButtonTitle:TGLocalized(@"Common.OK") okButtonTitle:nil completionBlock:nil];
        return;
    }
    
    if (![[[LegacyComponentsGlobals provider] accessChecker] checkCameraAuthorizationStatusForIntent:TGCameraAccessIntentDefault alertDismissCompletion:nil])
        return;
    
    if (TGAppDelegateInstance.rootController.isSplitView)
        return;
    
    if ([TGCameraController useLegacyCamera])
    {
        [self _displayLegacyCamera];
        [menuController dismissAnimated:true];
        return;
    }
    
    TGCameraController *controller = nil;
    CGSize screenSize = TGScreenSize();
    
    if (cameraView.previewView != nil)
    {
        controller = [[TGCameraController alloc] initWithContext:[TGLegacyComponentsContext shared] saveEditedPhotos:TGAppDelegateInstance.saveEditedPhotos saveCapturedMedia:TGAppDelegateInstance.saveCapturedMedia camera:cameraView.previewView.camera previewView:cameraView.previewView intent:TGCameraControllerGenericIntent];
    }
    else
    {
        controller = [[TGCameraController alloc] initWithContext:[TGLegacyComponentsContext shared] saveEditedPhotos:TGAppDelegateInstance.saveEditedPhotos saveCapturedMedia:TGAppDelegateInstance.saveCapturedMedia];
    }
    
    controller.isImportant = true;
    controller.shouldStoreCapturedAssets = [_companion controllerShouldStoreCapturedAssets];
    controller.allowGrouping = messageToEdit == nil ? [_companion allowMediaGrouping] : false;
    controller.allowCaptions = [_companion allowCaptionedMedia];
    controller.allowCaptionEntities = [_companion allowCaptionEntities];
    controller.inhibitDocumentCaptions = ![_companion allowCaptionedDocuments];
    controller.inhibitMultipleCapture = messageToEdit != nil;
    controller.suggestionContext = [self _suggestionContext];
    controller.recipientName = [_companion title];
    controller.hasTimer = messageToEdit == nil ? [_companion allowSelfDescructingMedia] : false;
    controller.inhibitMute = messageToEdit != nil;
    
    if (messageToEdit != nil)
    {
        NSArray *entities;
        NSString *text = [_inputTextPanel.maybeInputField textWithEntities:&entities];
        controller.forcedCaption = text;
        controller.forcedEntities = entities;
    }
    
    TGCameraControllerWindow *controllerWindow = [[TGCameraControllerWindow alloc] initWithManager:[[TGLegacyComponentsContext shared] makeOverlayWindowManager] parentController:self contentController:controller];
    controllerWindow.hidden = false;
    
    if ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPhone)
        controllerWindow.frame = CGRectMake(0, 0, screenSize.width, screenSize.height);
    
    bool standalone = true;
    CGRect startFrame = CGRectMake(0, screenSize.height, screenSize.width, screenSize.height);
    if (cameraView != nil)
    {
        standalone = false;
        if (TGIsPad())
            startFrame = CGRectZero;
        else
            startFrame = [controller.view convertRect:cameraView.previewView.frame fromView:cameraView];
    }
    
    [cameraView detachPreviewView];
    [controller beginTransitionInFromRect:startFrame];
    
    __weak TGModernConversationController *weakSelf = self;
    __weak TGCameraController *weakCameraController = controller;
    __weak TGAttachmentCameraView *weakCameraView = cameraView;
    
    controller.beginTransitionOut = ^CGRect
    {
        __strong TGCameraController *strongCameraController = weakCameraController;
        if (strongCameraController == nil)
            return CGRectZero;
        
        __strong TGAttachmentCameraView *strongCameraView = weakCameraView;
        if (strongCameraView != nil)
        {
            [strongCameraView willAttachPreviewView];
            if (TGIsPad())
                return CGRectZero;
            
            return [strongCameraController.view convertRect:strongCameraView.frame fromView:strongCameraView.superview];
        }
        
        return CGRectZero;
    };
    
    controller.finishedTransitionOut = ^
    {
        __strong TGAttachmentCameraView *strongCameraView = weakCameraView;
        if (strongCameraView == nil)
            return;
        
        [strongCameraView attachPreviewViewAnimated:true];
    };
    
    controller.finishedWithResults = ^(__unused TGOverlayController *controller, TGMediaSelectionContext *selectionContext, TGMediaEditingContext *editingContext, id<TGMediaSelectableItem> currentItem)
    {
        __strong TGModernConversationController *strongSelf = weakSelf;
        if (strongSelf == nil)
            return;
        
        [menuController dismissAnimated:false];
        
        __autoreleasing NSString *disabledMessage = nil;
        if (![TGApplicationFeatures isPhotoUploadEnabledForPeerType:[strongSelf->_companion applicationFeaturePeerType] disabledMessage:&disabledMessage])
        {
            [TGCustomAlertView presentAlertWithTitle:TGLocalized(@"FeatureDisabled.Oops") message:disabledMessage cancelButtonTitle:TGLocalized(@"Common.OK") okButtonTitle:nil completionBlock:nil];
            return;
        }
        
        [strongSelf _asyncProcessMediaAssetSignals:[TGCameraController resultSignalsForSelectionContext:selectionContext editingContext:editingContext currentItem:currentItem storeAssets:[strongSelf->_companion controllerShouldStoreCapturedAssets] saveEditedPhotos:TGAppDelegateInstance.saveEditedPhotos descriptionGenerator:^id(id result, NSString *caption, NSArray *entities, NSString *hash) {
            __strong TGModernConversationController *strongSelf = weakSelf;
            if (strongSelf == nil)
                return nil;

            NSDictionary *desc = [strongSelf _descriptionForItem:result caption:caption entities:entities hash:hash allowRemoteCache:false];
            if (messageToEdit != nil)
                desc = [strongSelf _descriptionForReplacingMedia:desc message:messageToEdit];
            return desc;
        }]];
        if (messageToEdit != nil)
            [strongSelf endMessageEditing:true];
    };
}

- (void)_displayLegacyCamera
{
    __autoreleasing NSString *disabledMessage = nil;
    if (![TGApplicationFeatures isPhotoUploadEnabledForPeerType:[_companion applicationFeaturePeerType] disabledMessage:&disabledMessage])
    {
        [TGCustomAlertView presentAlertWithTitle:TGLocalized(@"FeatureDisabled.Oops") message:disabledMessage cancelButtonTitle:TGLocalized(@"Common.OK") okButtonTitle:nil completionBlock:nil];
        return;
    }
    
    TGLegacyCameraController *legacyCameraController = [[TGLegacyCameraController alloc] initWithContext:[TGLegacyComponentsContext shared]];
    legacyCameraController.sourceType = UIImagePickerControllerSourceTypeCamera;
    legacyCameraController.mediaTypes = [[NSArray alloc] initWithObjects:(__bridge NSString *)kUTTypeImage, (__bridge NSString *)kUTTypeMovie, nil];
    
    legacyCameraController.storeCapturedAssets = [_companion controllerShouldStoreCapturedAssets];
    
    legacyCameraController.videoMaximumDuration = 100 * 60 * 60;
    [legacyCameraController setVideoQuality:UIImagePickerControllerQualityTypeMedium];
    legacyCameraController.completionDelegate = self;
    
    [self presentViewController:legacyCameraController animated:true completion:nil];
}

- (void)_displayICloudDrivePicker
{
    NSArray *documentTypes = @
    [
     @"public.composite-content",
     @"public.text",
     @"public.image",
     @"public.audio",
     @"public.video",
     @"public.movie",
     @"public.font",
     @"org.telegram.Telegram.webp",
     @"com.apple.iwork.pages.pages",
     @"com.apple.iwork.numbers.numbers",
     @"com.apple.iwork.keynote.key"
     ];
    
    UIDocumentPickerViewController *controller = [[UIDocumentPickerViewController alloc] initWithDocumentTypes:documentTypes inMode:UIDocumentPickerModeOpen];
    controller.view.backgroundColor = [UIColor whiteColor];
    controller.delegate = self;
    
    if (TGIsPad())
        controller.modalPresentationStyle = UIModalPresentationFormSheet;
    
    [self presentViewController:controller animated:true completion:nil];
}

- (void)_displayDropboxPicker
{
    _dropboxProxy = [[TGObserverProxy alloc] initWithTarget:self targetSelector:@selector(dropboxFilesReceived:) name:TGDropboxFilesReceivedNotification];
    [TGDropboxHelper openExternalPicker];
}

- (void)_displayFileMenuWithController:(TGMenuSheetController *)menuController
{
    if ((iosMajorVersion() >= 8) || (iosMajorVersion() >= 7 && ([TGDropboxHelper isDropboxInstalled])))
    {
        NSMutableArray *itemViews = [[NSMutableArray alloc] init];
        menuController.maxHeight = 0;
        
        __weak TGModernConversationController *weakSelf = self;
        __weak TGMenuSheetController *weakController = menuController;
        
        bool tipViewClosed = [[[NSUserDefaults standardUserDefaults] objectForKey:@"didShowDocumentPickerTip_v2"] boolValue];
        if (!tipViewClosed)
        {
            TGAttachmentFileTipView *fileTipItem = [[TGAttachmentFileTipView alloc] init];
            fileTipItem.didClose = ^
            {
                __strong TGModernConversationController *strongSelf = weakSelf;
                if (strongSelf == nil)
                    return;
                
                __strong TGMenuSheetController *strongController = weakController;
                if (strongController == nil)
                    return;
                
                [[NSUserDefaults standardUserDefaults] setObject:@true forKey:@"didShowDocumentPickerTip_v2"];
                
                NSMutableArray *itemViews = [strongController.itemViews mutableCopy];
                [itemViews removeObjectAtIndex:0];
                [strongController setItemViews:itemViews];
            };
            [itemViews addObject:fileTipItem];
        }
        
        TGMenuSheetButtonItemView *photoOrVideoItem = [[TGMenuSheetButtonItemView alloc] initWithTitle:TGLocalized(@"AttachmentMenu.PhotoOrVideo") type:TGMenuSheetButtonTypeDefault action:^
        {
            __strong TGModernConversationController *strongSelf = weakSelf;
            if (strongSelf == nil)
                return;
            
            __strong TGMenuSheetController *strongController = weakController;
            if (strongController == nil)
                return;
            
            [strongController dismissAnimated:true];
            [strongSelf _displayMediaPicker:true fromFileMenu:true];
        }];
        [itemViews addObject:photoOrVideoItem];
        
        if (iosMajorVersion() >= 8)
        {
            TGMenuSheetButtonItemView *iCloudItem = [[TGMenuSheetButtonItemView alloc] initWithTitle:TGLocalized(@"Conversation.FileICloudDrive") type:TGMenuSheetButtonTypeDefault action:^
            {
                __strong TGModernConversationController *strongSelf = weakSelf;
                if (strongSelf == nil)
                    return;
                
                __strong TGMenuSheetController *strongController = weakController;
                if (strongController == nil)
                    return;
                
                [strongController dismissAnimated:true];
                [strongSelf _displayICloudDrivePicker];
            }];
            [itemViews addObject:iCloudItem];
        }
        
        if ([TGDropboxHelper isDropboxInstalled])
        {
            TGMenuSheetButtonItemView *dropboxItem = [[TGMenuSheetButtonItemView alloc] initWithTitle:TGLocalized(@"Conversation.FileDropbox") type:TGMenuSheetButtonTypeDefault action:^
            {
                __strong TGModernConversationController *strongSelf = weakSelf;
                if (strongSelf == nil)
                    return;
                
                __strong TGMenuSheetController *strongController = weakController;
                if (strongController == nil)
                    return;
                
                [strongController dismissAnimated:true];
                [strongSelf _displayDropboxPicker];
            }];
            [itemViews addObject:dropboxItem];
        }
        
        TGMenuSheetButtonItemView *cancelItem = [[TGMenuSheetButtonItemView alloc] initWithTitle:TGLocalized(@"Common.Cancel") type:TGMenuSheetButtonTypeCancel action:^
        {
            __strong TGModernConversationController *strongSelf = weakSelf;
            if (strongSelf == nil)
                return;
            
            __strong TGMenuSheetController *strongController = weakController;
            if (strongController == nil)
                return;
            
            [strongController dismissAnimated:true];
        }];
        [itemViews addObject:cancelItem];
        
        [menuController setItemViews:itemViews animated:true];
    }
    else
    {
        [menuController dismissAnimated:true];
        [self _displayMediaPicker:true fromFileMenu:false];
    }
}

- (void)dropboxFilesReceived:(NSNotification *)notification
{
    if (notification.object == nil && ![notification.object isKindOfClass:[NSArray class]] && _dropboxProxy != nil)
        return;
    
    NSArray *items = (NSArray *)notification.object;
    
    bool endEditing = false;
    NSMutableArray *descriptions = [[NSMutableArray alloc] init];
    for (TGDropboxItem *item in items)
    {
        id description = [self.companion documentDescriptionFromDropboxItem:item];
        if (_inputTextPanel.messageEditingContext.messageId != 0) {
            TGMessage *message = [TGDatabaseInstance() loadMessageWithMid:_inputTextPanel.messageEditingContext.messageId peerId:_inputTextPanel.messageEditingContext.cid];
            description = [self _descriptionForReplacingMedia:description message:message];
            endEditing = true;
        }
        if (description != nil)
            [descriptions addObject:description];
    }
    
    [self.companion controllerWantsToSendCloudDocumentsWithDescriptions:descriptions asReplyToMessageId:[self currentReplyMessageId]];
    
    if (endEditing)
        [self endMessageEditing:true];
}

- (void)documentPicker:(UIDocumentPickerViewController *)__unused controller didPickDocumentAtURL:(NSURL *)url
{
    TGMessage *message = nil;
    if (_inputTextPanel.messageEditingContext.messageId != 0)
        message = [TGDatabaseInstance() loadMessageWithMid:_inputTextPanel.messageEditingContext.messageId peerId:_inputTextPanel.messageEditingContext.cid];
    
    __weak TGModernConversationController *weakSelf = self;
    _currentICloudItemRequest = [TGICloudItemRequest requestICloudItemWithUrl:url completion:^(TGICloudItem *item)
    {
        __strong TGModernConversationController *strongSelf = weakSelf;
        if (strongSelf == nil)
            return;
        
        strongSelf->_currentICloudItemRequest = nil;
        
        id description = [strongSelf.companion documentDescriptionFromICloudDriveItem:item];
        if (message != nil)
            description = [strongSelf _descriptionForReplacingMedia:description message:message];
        if (description != nil)
            [strongSelf.companion controllerWantsToSendCloudDocumentsWithDescriptions:@[description] asReplyToMessageId:[strongSelf currentReplyMessageId]];
    }];
    
    if (message != nil)
        [self endMessageEditing:false];
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
                NSDictionary *imageDescription = [_companion imageDescriptionFromImage:abstractAsset stickers:nil caption:nil entities:nil optionalAssetUrl:nil allowRemoteCache:false timer:0];
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
                    NSDictionary *imageDescription = [_companion imageDescriptionFromImage:image stickers:nil caption:nil entities:nil optionalAssetUrl:nil allowRemoteCache:false timer:0];
                    if (imageDescription != nil)
                        [imageDescriptions addObject:imageDescription];
                }
            }
        }
    }
    
    if (imageDescriptions.count != 0)
        [_companion controllerWantsToSendImagesWithDescriptions:imageDescriptions asReplyToMessageId:[self currentReplyMessageId] botReplyMarkup:nil];
    
    [self dismissViewControllerAnimated:true completion:nil];
}


- (void)legacyCameraControllerCompletedWithDocument:(NSURL *)fileUrl fileName:(NSString *)fileName mimeType:(NSString *)mimeType
{
    [self dismissViewControllerAnimated:true completion:nil];
    
    [_companion controllerWantsToSendDocumentWithTempFileUrl:fileUrl fileName:fileName mimeType:mimeType asReplyToMessageId:[self currentReplyMessageId]];
}

- (void)_displayWebImagePicker
{
    __weak TGModernConversationController *weakSelf = self;
    
    TGWebSearchController *searchController = [[TGWebSearchController alloc] initWithContext:[TGLegacyComponentsContext shared] forAvatarSelection:false embedded:false allowGrouping:[_companion allowMediaGrouping]];
    searchController.presentation = self.presentation;
    searchController.captionsEnabled = [_companion allowCaptionedMedia];
    searchController.suggestionContext = [self _suggestionContext];
    searchController.recipientName = [_companion title];
    searchController.dismiss = ^
    {
        __strong TGModernConversationController *strongSelf = weakSelf;
        if (strongSelf == nil)
            return;
        
        [strongSelf dismissViewControllerAnimated:true completion:nil];
        [strongSelf _dismissBannersForCurrentConversation];
    };
    searchController.completionBlock = ^(TGWebSearchController *sender)
    {
        __strong TGModernConversationController *strongSelf = weakSelf;
        if (strongSelf == nil)
            return;
        
        bool allowRemoteCache = [strongSelf->_companion controllerShouldCacheServerAssets];
        [strongSelf _asyncProcessMediaAssetSignals:[sender selectedItemSignals:^id (id item, NSString *caption, NSArray *entities)
        {
            if (item == nil)
                return nil;
            
            return [strongSelf _descriptionForItem:item caption:caption entities:entities hash:nil allowRemoteCache:allowRemoteCache];
        }]];
    };
    
    TGNavigationController *navigationController = [TGNavigationController navigationControllerWithControllers:@[ searchController ]];
    
    if (TGIsPad())
    {
        navigationController.presentationStyle = TGNavigationControllerPresentationStyleInFormSheet;
        navigationController.modalPresentationStyle = UIModalPresentationFormSheet;
    }
    
    [self presentViewController:navigationController animated:true completion:nil];
}

- (void)legacyCameraControllerCapturedVideoWithTempFilePath:(NSString *)tempVideoFilePath fileSize:(int32_t)fileSize previewImage:(UIImage *)previewImage duration:(NSTimeInterval)duration dimensions:(CGSize)dimenstions assetUrl:(NSString *)assetUrl
{
    [self dismissViewControllerAnimated:true completion:nil];
    
    [_companion controllerWantsToSendLocalVideoWithTempFilePath:tempVideoFilePath fileSize:fileSize previewImage:previewImage duration:duration dimensions:dimenstions caption:nil entities:nil assetUrl:assetUrl liveUploadData:nil asReplyToMessageId:[self currentReplyMessageId] botReplyMarkup:nil];
}

- (void)legacyCameraControllerCompletedWithExistingMedia:(id)media
{
    [self dismissViewControllerAnimated:true completion:nil];
    
    if ([media isKindOfClass:[TGVideoMediaAttachment class]])
        [_companion controllerWantsToSendRemoteVideoWithMedia:media asReplyToMessageId:[self currentReplyMessageId] text:nil entities:nil botContextResult:nil botReplyMarkup:nil];
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
        [TGCustomAlertView presentAlertWithTitle:TGLocalized(@"FeatureDisabled.Oops") message:disabledMessage cancelButtonTitle:TGLocalized(@"Common.OK") okButtonTitle:nil completionBlock:nil];
        return;
    }
    
    __weak TGModernConversationController *weakSelf = self;
    [TGClipboardMenu presentInParentController:self context:[TGLegacyComponentsContext shared] images:images hasCaption:[_companion allowCaptionedMedia] hasTimer:[_companion allowSelfDescructingMedia] recipientName:[_companion title] completed:^(TGMediaSelectionContext *selectionContext, TGMediaEditingContext *editingContext, id<TGMediaSelectableItem> currentItem)
    {
        __strong TGModernConversationController *strongSelf = weakSelf;
        if (strongSelf == nil)
            return;
        
        [strongSelf _asyncProcessMediaAssetSignals:[TGClipboardMenu resultSignalsForSelectionContext:selectionContext editingContext:editingContext currentItem:currentItem descriptionGenerator:^id(id result, NSString *caption, NSArray *entities, NSString *hash) {
            __strong TGModernConversationController *strongSelf = weakSelf;
            if (strongSelf == nil)
                return nil;
            
            return [strongSelf _descriptionForItem:result caption:caption entities:entities hash:hash allowRemoteCache:false];
        }]];
    } dismissed:nil sourceView:self.view sourceRect:nil];
    
    [self endEditing];
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
    [self->_companion controllerWantsToSendRemoteDocument:sticker asReplyToMessageId:[self currentReplyMessageId] text:nil entities:nil botContextResult:nil botReplyMarkup:nil];
}

- (void)inputPanelRequestedSendGif:(TGModernConversationInputTextPanel *)__unused inputTextPanel document:(TGDocumentMediaAttachment *)document {
    [self->_companion controllerWantsToSendRemoteDocument:document asReplyToMessageId:[self currentReplyMessageId] text:nil entities:nil botContextResult:nil botReplyMarkup:nil];
}

- (void)inputPanelRequestedActivateCommand:(TGModernConversationInputTextPanel *)__unused inputTextPanel button:(TGBotReplyMarkupButton *)button userId:(int32_t)__unused userId messageId:(int32_t)messageId
{
    if (button.action == nil) {
        int32_t replyMessageId = 0;
        if (((TGGenericModernConversationCompanion *)_companion).conversationId < 0)
            replyMessageId = messageId;
        if (_replyMarkup.hideKeyboardOnActivation && !_replyMarkup.alreadyActivated)
        {
            [self setReplyMarkup:[_replyMarkup activatedMarkup]];
            
            [TGDatabaseInstance() storeBotReplyMarkupActivated:_replyMarkup forPeerId:((TGGenericModernConversationCompanion *)_companion).conversationId];
        }
        [self->_companion controllerWantsToSendTextMessage:[[NSString alloc] initWithFormat:@"%@%@", @"", button.text] entities:nil asReplyToMessageId:[self currentReplyMessageId] == 0 ? replyMessageId : [self currentReplyMessageId] withAttachedMessages:@[] completeGroups:nil disableLinkPreviews:false botContextResult:nil botReplyMarkup:nil];
    } else {
        NSMutableDictionary *dict = [[NSMutableDictionary alloc] initWithDictionary:@{@"mid": @(messageId), @"command": button.text}];
        if (button.action != nil) {
            dict[@"action"] = button.action;
        }
        [self->_companion actionStageActionRequested:@"activateCommand" options:dict];
    }
}

- (void)inputPanelRequestedToggleCommandKeyboard:(TGModernConversationInputTextPanel *)__unused inputTextPanel showCommandKeyboard:(bool)showCommandKeyboard {
    if (_replyMarkup.manuallyHidden != !showCommandKeyboard) {
        TGBotReplyMarkup *replyMarkup = !showCommandKeyboard ? [_replyMarkup manuallyHide] : [_replyMarkup manuallyUnhide];
        [self setReplyMarkup:replyMarkup];
        
        [TGDatabaseInstance() storeBotReplyMarkupManuallyHidden:_replyMarkup forPeerId:((TGGenericModernConversationCompanion *)_companion).conversationId manuallyHidden:!showCommandKeyboard];
    }
}

- (void)_displayLocationPicker
{
    __weak TGModernConversationController *weakSelf = self;
    
    int64_t peerId = ((TGGenericModernConversationCompanion *)_companion).conversationId;
    TGConversation *chat = [TGDatabaseInstance() loadConversationWithId:peerId];
    bool isChannel = chat.isChannel && !chat.isChannelGroup;
    
    TGLocationPickerControllerIntent intent = [_companion allowVenueSharing] ? TGLocationPickerControllerDefaultIntent : TGLocationPickerControllerCustomLocationIntent;
    TGLocationPickerController *controller = [[TGLocationPickerController alloc] initWithContext:[TGLegacyComponentsContext shared] intent:intent];
    controller.pallete = self.presentation.locationPallete;
    controller.peer = isChannel ? chat : [TGDatabaseInstance() loadUser:TGTelegraphInstance.clientUserId];
    controller.receivingPeer = TGPeerIdIsUser(peerId) ? [TGDatabaseInstance() loadUser:(int32_t)peerId] : [TGDatabaseInstance() loadConversationWithId:peerId];
    controller.allowLiveLocationSharing = self.companion.allowLiveLocations;
    [controller setLiveLocationsSignal:[[SSignal combineSignals:@[[[TGTelegraphInstance.liveLocationManager sessionForPeerId:peerId] map:^id (TGLiveLocationSession *session)
    {
        if (session != nil)
        {
            TGUser *user = [TGDatabaseInstance() loadUser:TGTelegraphInstance.clientUserId];
            TGMessage *message = [TGDatabaseInstance() loadMessageWithMid:session.messageId peerId:session.peerId];
            return [[TGLiveLocation alloc] initWithMessage:message peer:user hasOwnSession:true isOwnLocation:true isExpired:false];
        }
        else
        {
            return [NSNull null];
        }
    }], [TGLiveLocationSignals liveLocationsForPeerId:peerId includeExpired:false onlyLocal:isChannel]] withInitialStates:@[ [NSNull null], @[] ]] map:^id(NSArray *results)
    {
        TGLiveLocation *ownLiveLocation = ![results.firstObject isKindOfClass:[NSNull class]] ? results.firstObject : nil;
        if (ownLiveLocation == nil)
            return nil;
        
        NSArray *messages = results.lastObject;
        int32_t currentTime = (int32_t)[[TGTelegramNetworking instance] globalTime];
        for (TGMessage *message in messages)
        {
            int32_t expires = (int32_t)message.date + message.locationAttachment.period;
            if (message.mid == ownLiveLocation.message.mid)
                return [[TGLiveLocation alloc] initWithMessage:message peer:ownLiveLocation.peer hasOwnSession:true isOwnLocation:true isExpired:currentTime > expires];
        }
        
        return nil;
    }]];
    controller.remainingTimeForMessage = ^SSignal *(TGMessage *message)
    {
        return [TGLiveLocationSignals remainingTimeForMessage:message];
    };
    controller.locationPicked = ^(CLLocationCoordinate2D coordinate, TGVenueAttachment *venue)
    {
        __strong TGModernConversationController *strongSelf = weakSelf;
        if (strongSelf == nil)
            return;
        
        [strongSelf->_companion controllerWantsToSendMapWithLatitude:coordinate.latitude longitude:coordinate.longitude venue:venue period:0 asReplyToMessageId:[strongSelf currentReplyMessageId] botContextResult:nil botReplyMarkup:nil];
        [strongSelf dismissViewControllerAnimated:true completion:nil];
    };
    controller.liveLocationStarted = ^(CLLocationCoordinate2D coordinate, int32_t period)
    {
        __strong TGModernConversationController *strongSelf = weakSelf;
        if (strongSelf == nil)
            return;
        
        [strongSelf->_companion controllerWantsToSendMapWithLatitude:coordinate.latitude longitude:coordinate.longitude venue:nil period:period asReplyToMessageId:[strongSelf currentReplyMessageId] botContextResult:nil botReplyMarkup:nil];
        [strongSelf dismissViewControllerAnimated:true completion:nil];
    };
    controller.liveLocationStopped = ^
    {
        __strong TGModernConversationController *strongSelf = weakSelf;
        if (strongSelf == nil)
            return;
        
        [TGTelegraphInstance.liveLocationManager stopWithPeerId:peerId];
        [strongSelf dismissViewControllerAnimated:true completion:nil];
    };
    controller.nearbyPlacesSignal = ^SSignal *(NSString *query, CLLocation *location)
    {
        NSData *venueSearchUsernameData = [TGDatabaseInstance() customProperty:@"venueSearchUsername"];
        if (venueSearchUsernameData == nil) {
            return [SSignal fail:nil];
        } else {
            NSString *venueSearchUsername = [[NSString alloc] initWithData:venueSearchUsernameData encoding:NSUTF8StringEncoding];
            return [[TGPeerInfoSignals resolveBotDomain:venueSearchUsername] mapToSignal:^SSignal *(id peer) {
                if ([peer isKindOfClass:[TGUser class]])
                {
                    return [[TGBotSignals botContextResultForUserId:((TGUser *)peer).uid peerId:[_companion requestPeerId] accessHash:[_companion requestAccessHash] query:query geoPoint:[SSignal single:location] offset:@"" forceAllowLocation:true] map:^id(TGBotContextResults *result)
                    {
                        NSMutableArray *venues = [[NSMutableArray alloc] init];
                        for (TGBotContextExternalResult *item in result.results)
                        {
                            if ([item isKindOfClass:[TGBotContextExternalResult class]])
                            {
                                TGBotContextExternalResult *concreteResult = (TGBotContextExternalResult *)item;
                                if ([concreteResult.sendMessage isKindOfClass:[TGBotContextResultSendMessageGeo class]])
                                {
                                    TGBotContextResultSendMessageGeo *concreteMessage = (TGBotContextResultSendMessageGeo *)concreteResult.sendMessage;
                                    TGLocationVenue *locationVenue = [TGLocationVenue venueWithLocationAttachment:concreteMessage.location];
                                    if (locationVenue != nil)
                                        [venues addObject:locationVenue];
                                }
                            }
                        }
                        return venues;
                    }];
                }
                else
                {
                    return [SSignal fail:nil];
                };
            }];
        }
    };
    
    TGNavigationController *navigationController = [TGNavigationController navigationControllerWithControllers:@[controller]];
    navigationController.restrictLandscape = true;
    
    if (TGIsPad())
    {
        navigationController.presentationStyle = TGNavigationControllerPresentationStyleInFormSheet;
        navigationController.modalPresentationStyle = UIModalPresentationFormSheet;
    }
    
    [self presentViewController:navigationController animated:true completion:nil];
}

- (void)_displayContactPicker
{
    if (![[[LegacyComponentsGlobals provider] accessChecker] checkAddressBookAuthorizationStatusWithAlertDismissComlpetion:nil])
        return;
    
    TGForwardContactPickerController *contactPickerController = [[TGForwardContactPickerController alloc] init];
    contactPickerController.sendImmediately = [_companion encryptUploads];
    contactPickerController.delegate = self;
    
    TGNavigationController *navigationController = [TGNavigationController navigationControllerWithControllers:@[contactPickerController]];
    
    if (TGIsPad())
    {
        navigationController.presentationStyle = TGNavigationControllerPresentationStyleInFormSheet;
        navigationController.modalPresentationStyle = UIModalPresentationFormSheet;
    }
    
    [self presentViewController:navigationController animated:true completion:nil];
}

- (void)forwardContactPickerController:(TGForwardContactPickerController *)__unused contactPicker didSelectContact:(TGUser *)contactUser
{
    [_companion controllerWantsToSendContact:contactUser asReplyToMessageId:[self currentReplyMessageId] botContextResult:nil botReplyMarkup:nil];
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

- (void)startVideoMessageWithCompletion:(void (^)(void))completion
{
    bool (^checkAuthorizationStatus)(void) = ^bool
    {
        if (![[[LegacyComponentsGlobals provider] accessChecker] checkCameraAuthorizationStatusForIntent:TGCameraAccessIntentVideoMessage alertDismissCompletion:nil])
            return false;
        
        if (![[[LegacyComponentsGlobals provider] accessChecker] checkMicrophoneAuthorizationStatusForIntent:TGMicrophoneAccessIntentVideoMessage alertDismissCompletion:nil])
            return false;
        
        return true;
    };
    
    if (!checkAuthorizationStatus())
        return;
    
    __block bool shouldSkip = false;
    
    [TGVideoMessageCaptureController requestCameraAccess:^(bool granted, bool wasNotDetermined)
    {
        if (granted)
        {
            shouldSkip = wasNotDetermined;
            
            [TGVideoMessageCaptureController requestMicrophoneAccess:^(bool granted, bool wasNotDetermined)
            {
                if (granted)
                    shouldSkip = shouldSkip || wasNotDetermined;
                
                if (granted && !shouldSkip)
                {
                    [self stopInlineMedia:0];
                    
                    CGRect controlsFrame = [_inputTextPanel convertRect:_inputTextPanel.bounds toView:nil];
                    
                    if (TGTelegraphInstance.musicPlayer != nil)
                        [TGTelegraphInstance.musicPlayer controlPause];
                    
                    [TGEmbedPIPController dismissPictureInPicture];
                    
                    __weak TGModernConversationController *weakSelf = self;
                    TGVideoMessageCaptureController *controller = [[TGVideoMessageCaptureController alloc] initWithContext:[TGLegacyComponentsContext shared] assets:[[TGVideoMessageCaptureControllerAssets alloc] initWithSendImage:self.presentation.images.chatInputSendIcon slideToCancelImage:TGTintedImage(TGComponentsImageNamed(@"ModernConversationAudioSlideToCancel.png"), self.presentation.pallete.secondaryTextColor) actionDelete:TGTintedImage(TGImageNamed(@"ModernConversationActionDelete.png"), self.presentation.pallete.accentColor)] transitionInView:^UIView *{
                        return TGAppDelegateInstance.rootController.view;
                    } parentController:self controlsFrame:controlsFrame isAlreadyLocked:^bool{
                        __strong TGModernConversationController *strongSelf = weakSelf;
                        if (strongSelf == nil)
                            return false;
                        
                        return strongSelf->_inputTextPanel.isLocked;
                    } liveUploadInterface:[[TGMediaLiveUploadWatcher alloc] init] pallete:self.presentation.micButtonPallete];
                    controller.finishedWithVideo = ^(NSURL *videoURL, UIImage *previewImage, __unused NSUInteger fileSize, NSTimeInterval duration, CGSize dimensions, TGLiveUploadActorData *liveUploadData, TGVideoEditAdjustments *adjustments)
                    {
                        __strong TGModernConversationController *strongSelf = weakSelf;
                        if (strongSelf != nil)
                        {
                            NSDictionary *desc = [strongSelf->_companion videoDescriptionFromVideoURL:videoURL previewImage:previewImage dimensions:dimensions duration:duration adjustments:adjustments stickers:nil caption:nil entities:nil roundMessage:true liveUploadData:liveUploadData timer:0];
                            [strongSelf->_companion controllerWantsToSendImagesWithDescriptions:@[ desc ] asReplyToMessageId:[strongSelf currentReplyMessageId] botReplyMarkup:nil];
                        }
                    };
                    controller.micLevel = ^(CGFloat level)
                    {
                        __strong TGModernConversationController *strongSelf = weakSelf;
                        if (strongSelf != nil)
                            [strongSelf->_inputTextPanel addMicLevel:level];
                    };
                    controller.requestActivityHolder = ^id
                    {
                        __strong TGModernConversationController *strongSelf = weakSelf;
                        if (strongSelf != nil) {
                            return [strongSelf->_companion acquireVideoMessageRecordingActivityHolder];
                        }
                        return nil;
                    };
                    controller.onDismiss = ^(bool isAuto)
                    {
                        __strong TGModernConversationController *strongSelf = weakSelf;
                        if (strongSelf != nil)
                        {
                            strongSelf->_isRecording = false;
                            [strongSelf resumeInlineMedia];
                            
                            if (isAuto)
                                [strongSelf->_inputTextPanel recordingFinished];
                        }
                    };
                    controller.onStop = ^
                    {
                        __strong TGModernConversationController *strongSelf = weakSelf;
                        if (strongSelf != nil)
                        {
                            if (!strongSelf->_inputTextPanel.isLocked)
                                strongSelf->_inputTextPanel.ignoreNextMicButtonEvent = true;
                            
                            [strongSelf->_inputTextPanel recordingStopped];
                        }
                    };
                    controller.onCancel = ^
                    {
                        __strong TGModernConversationController *strongSelf = weakSelf;
                        if (strongSelf != nil)
                        {
                            [strongSelf inputPanelAudioRecordingCancel:strongSelf->_inputTextPanel];
                        }
                    };
                    
                    _videoMessageCaptureController = controller;
                    if (completion != nil)
                        completion();
                    
                    if (_inputTextPanel.isLocked)
                        [_videoMessageCaptureController setLocked];
                }
                else
                {
                    checkAuthorizationStatus();
                }
            }];
        }
        else
        {
            checkAuthorizationStatus();
        }
    }];
}

- (bool)maybeShowDiscardRecordingAlert
{
    if (!_isRecording)
        return false;
    
    __weak TGModernConversationController *weakSelf = self;
    [TGCustomAlertView presentAlertWithTitle:TGLocalized(@"Conversation.DiscardVoiceMessageTitle") message:TGLocalized(@"Conversation.DiscardVoiceMessageDescription") customView:nil cancelButtonTitle:TGLocalized(@"Common.Cancel") doneButtonTitle:TGLocalized(@"Conversation.DiscardVoiceMessageAction") completionBlock:^(bool done)
    {
        __strong TGModernConversationController *strongSelf = weakSelf;
        if (strongSelf == nil)
            return;
        
        if (done)
        {
            [strongSelf inputPanelAudioRecordingCancel:strongSelf->_inputTextPanel];
            [strongSelf->_inputTextPanel recordingFinished];
        }
    }];
    
    return true;
}

- (void)inputPanelAudioButtonInteractionUpdate:(TGModernConversationInputTextPanel *)__unused inputTextPanel value:(CGPoint)value
{
    [_videoMessageCaptureController buttonInteractionUpdate:value];
}

- (bool)inputPanelAudioRecordingEnabled:(TGModernConversationInputTextPanel *)__unused inputTextPanel
{
    NSNumber *banTimeout = [self->_companion mediaRestrictionTimeout];
    if (banTimeout != nil) {
        [self showBannedMediaTooltip:[banTimeout intValue]];
        return false;
    }
    
    __autoreleasing NSString *disabledMessage = nil;
    if (![TGApplicationFeatures isAudioUploadEnabledForPeerType:[_companion applicationFeaturePeerType] disabledMessage:&disabledMessage])
    {
        [TGCustomAlertView presentAlertWithTitle:TGLocalized(@"FeatureDisabled.Oops") message:disabledMessage cancelButtonTitle:TGLocalized(@"Common.OK") okButtonTitle:nil completionBlock:nil];
        return false;
    }
    
    if (TGTelegraphInstance.callManager.hasActiveCall)
    {
        [TGCustomAlertView presentAlertWithTitle:TGLocalized(@"Call.CallInProgressTitle") message:TGLocalized(@"Call.RecordingDisabledMessage") cancelButtonTitle:TGLocalized(@"Common.OK") okButtonTitle:nil completionBlock:nil];
        return false;
    }
    
    return true;
}

- (void)inputPanelAudioRecordingStart:(TGModernConversationInputTextPanel *)inputTextPanel video:(bool)video completion:(void (^)())completion
{
    [_recordTooltipContainerView removeFromSuperview];
    _recordTooltipContainerView = nil;
    
    if (video)
    {
        [self startVideoMessageWithCompletion:completion];
        
        CGSize screenSize = TGScreenSize();
        if ((TGIsPad() || UIInterfaceOrientationIsLandscape(self.interfaceOrientation) || (int)screenSize.height == 480) && inputTextPanel.isActive)
        {
            [self endEditing];
            inputTextPanel.lockImmediately = true;
        }
    }
    else
    {
        [self startAudioRecording:false completion:completion];
    }
    
    [self setScrollBackButtonVisible:false];
    _isRecording = true;
    
    if (iosMajorVersion() >= 7 && !video)
        self.navigationController.interactivePopGestureRecognizer.enabled = false;
}

- (void)inputPanelAudioRecordingCancel:(TGModernConversationInputTextPanel *)__unused inputTextPanel
{
    _isRecording = false;
    
    if (_videoMessageCaptureController != nil)
    {
        [_videoMessageCaptureController dismiss];
    }
    else
    {
        [self stopAudioRecording];
        [_inputTextPanel audioRecordingFinished];
        
        [[UIApplication sharedApplication] setIdleTimerDisabled:false];
    }
    
    if (iosMajorVersion() >= 7)
        self.navigationController.interactivePopGestureRecognizer.enabled = true;
}

- (void)inputPanelAudioRecordingComplete:(TGModernConversationInputTextPanel *)__unused inputTextPanel
{
    _isRecording = false;
    
    if (iosMajorVersion() >= 7)
        self.navigationController.interactivePopGestureRecognizer.enabled = true;
    
    if (_videoMessageCaptureController != nil)
    {
        [_videoMessageCaptureController complete];
    }
    else
    {
#if TARGET_IPHONE_SIMULATOR
        if (true) {
            [self finishAudioRecording:true];
            return;
        }
#endif
        [self finishAudioRecording:false];
    }
}

- (void)inputPanelRecordingModeChanged:(TGModernConversationInputTextPanel *)__unused inputTextPanel video:(bool)video
{
    [self showRecordButtonTooltip:video duration:2.0];
    
    if (_isChannel)
    {
        [[NSUserDefaults standardUserDefaults] setObject:@(!video) forKey:@"TG_lastChannelRecordModeIsAudio_v0"];
        if (!video)
            [[NSUserDefaults standardUserDefaults] setObject:@true forKey:@"TG_displayedChannelRecordModeTooltip_v0"];
        else
            [[NSUserDefaults standardUserDefaults] setObject:@true forKey:@"TG_displayedChannelRevertRecordModeTooltip_v0"];
    }
    else
    {
        [[NSUserDefaults standardUserDefaults] setObject:@(video) forKey:@"TG_lastPrivateRecordModeIsVideo_v0"];
        if (video)
            [[NSUserDefaults standardUserDefaults] setObject:@true forKey:@"TG_displayedPrivateRecordModeTooltip_v0"];
        else
            [[NSUserDefaults standardUserDefaults] setObject:@true forKey:@"TG_displayedPrivateRevertRecordModeTooltip_v0"];
    }
}

- (void)inputPanelRecordingLocked:(TGModernConversationInputTextPanel *)__unused inputTextPanel video:(bool)video
{
    if (video)
        [_videoMessageCaptureController setLocked];
    else
        [self endEditing];
}

- (void)inputPanelRecordingRequestedLockedAction:(TGModernConversationInputTextPanel *)__unused inputTextPanel
{
    [self maybeShowDiscardRecordingAlert];
}

- (void)inputPanelRecordingStopped:(TGModernConversationInputTextPanel *)__unused inputTextPanel
{
    if (_videoMessageCaptureController != nil)
    {
        [_videoMessageCaptureController stop];
    }
    else
    {
        _isRecording = false;
        [self finishAudioRecording:true];
    }
}

- (void)startAudioRecording:(bool)speaker completion:(void (^)())completion {
    TGLog(@"before start");
    
    [self stopAudioRecording];
    [self stopInlineMediaIfPlaying];
    
    __weak TGModernConversationController *weakSelf = self;
    void (^block)() = ^{
        __strong TGModernConversationController *strongSelf = weakSelf;
        if (strongSelf != nil) {
            if (strongSelf->_currentAudioRecorder == nil)
            {
                strongSelf->_currentAudioRecorder = [[TGAudioRecorder alloc] initWithFileEncryption:[_companion encryptUploads]];
                if (!speaker) {
                    strongSelf->_currentAudioRecorder.micLevel = ^(CGFloat level){
                        TGDispatchOnMainThread(^{
                            __strong TGModernConversationController *strongSelf = weakSelf;
                            if (strongSelf != nil) {
                                [strongSelf->_inputTextPanel addMicLevel:level];
                            }
                        });
                    };
                }
                strongSelf->_currentAudioRecorderIsTouchInitiated = !speaker;
                strongSelf->_currentAudioRecorder.pauseRecording = ^{
                    __strong TGModernConversationController *strongSelf = weakSelf;
                    if (strongSelf != nil) {
                        [strongSelf finishAudioRecording:true];
                    }
                };
                strongSelf->_currentAudioRecorder.delegate = self;
                strongSelf->_currentAudioRecorder.requestActivityHolder = ^id {
                    __strong TGModernConversationController *strongSelf = weakSelf;
                    if (strongSelf != nil) {
                        return [strongSelf->_companion acquireAudioRecordingActivityHolder];
                    }
                    return nil;
                };
                [strongSelf->_currentAudioRecorder startWithSpeaker:speaker completion:^{
                    if (completion) {
                        TGDispatchOnMainThread(completion);
                    }
                }];
                
                [[UIApplication sharedApplication] setIdleTimerDisabled:true];
            }
            
            [strongSelf updateRaiseToListen];
        }
    };
    
    if (TGTelegraphInstance.musicPlayer != nil) {
        [TGTelegraphInstance.musicPlayer controlPause:^{
            TGDispatchOnMainThread(^{
                block();
            });
        }];
    } else {
        block();
    }
}

- (void)finishAudioRecording:(bool)preview {
    dispatch_block_t block = ^{
        if (_currentAudioRecorder != nil)
        {
            _currentAudioRecorder.delegate = nil;
            [_currentAudioRecorder finish:^(TGDataItem *dataItem, NSTimeInterval duration, TGLiveUploadActorData *liveData, TGAudioWaveform *waveform)
            {
                TGDispatchOnMainThread(^
                {
                    if (dataItem != nil)
                    {
                        if (preview) {
                            self->_isRecording = false;
                            [self previewAudioWithDataItem:dataItem duration:duration liveUploadData:liveData waveform:waveform];
                            [_inputTextPanel recordingFinished];
                        } else {
                            [_companion controllerWantsToSendLocalAudioWithDataItem:dataItem duration:duration liveData:liveData waveform:waveform asReplyToMessageId:[self currentReplyMessageId] botReplyMarkup:nil];
                        }
                    }
                    else if (!_companion.allowVideoMessages)
                    {
                        [_inputTextPanel shakeControls];
                        
                        if (!preview && [self->_inputTextPanel micButtonFrame].size.width > FLT_EPSILON)
                        {
                            [self->_tooltipContainerView removeFromSuperview];
                            
                            self->_tooltipContainerView = [[TGMenuContainerView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, self.view.frame.size.width, self.view.frame.size.height)];
                            [self.view addSubview:self->_tooltipContainerView];
                            
                            NSMutableArray *actions = [[NSMutableArray alloc] init];
                            [actions addObject:[[NSDictionary alloc] initWithObjectsAndKeys:TGLocalized(@"Conversation.TapAndHoldToRecord"), @"title", nil]];
                            
                            [self->_tooltipContainerView.menuView setButtonsAndActions:actions watcherHandle:nil];
                            [self->_tooltipContainerView.menuView sizeToFit];
                            self->_tooltipContainerView.menuView.userInteractionEnabled = false;
                            CGRect titleLockIconViewFrame = [self->_inputTextPanel convertRect:[self->_inputTextPanel micButtonFrame] toView:self->_tooltipContainerView];
                            titleLockIconViewFrame.origin.y += 15.0f;
                            [self->_tooltipContainerView showMenuFromRect:titleLockIconViewFrame animated:false];
                            
                            __weak TGMenuContainerView *weakContainerView = _tooltipContainerView;
                            [_tooltipDismissDisposable setDisposable:[[[SSignal complete] delay:3.0 onQueue:[SQueue mainQueue]] startWithNext:nil completed:^{
                                __strong TGMenuContainerView *strongContainerView = weakContainerView;
                                if (strongContainerView != nil) {
                                    [strongContainerView hideMenu];
                                }
                            }]];
                        }
                    }
                    
                });
            }];
            
            _currentAudioRecorder = nil;
            _currentAudioRecorderIsTouchInitiated = false;
            
            [_inputTextPanel audioRecordingFinished];
            
            if ([self shouldAutorotate])
                [TGViewController attemptAutorotation];
            
            [[UIApplication sharedApplication] setIdleTimerDisabled:false];
        }
        
        [self updateRaiseToListen];
    };
    
    
    if (TGTelegraphInstance.musicPlayer != nil) {
        [TGTelegraphInstance.musicPlayer _dispatch:^{
            TGDispatchOnMainThread(^{
                block();
            });
        }];
    } else {
        block();
    }
    
    TGDispatchOnMainThread(^
                           {
                               if (iosMajorVersion() >= 7)
                                   self.navigationController.interactivePopGestureRecognizer.enabled = true;
                           });
}

- (void)maybeShowRecordTooltip
{
    if ([self hasNonTextInputPanel] || !self.companion.canPostMessages || _inputTextPanel.primaryExtendedPanel != nil || _inputTextPanel.secondaryExtendedPanel != nil || _inputTextPanel.maybeInputField.text.length > 0) {
        return;
    }
    
    bool video = _inputTextPanel.videoMessage;
    
    NSString *key = nil;
    if (video)
        key = _isChannel ? @"TG_displayedChannelRevertRecordModeTooltip_v0" : @"TG_displayedPrivateRevertRecordModeTooltip_v0";
    else
        key = _isChannel ? @"TG_displayedChannelRecordModeTooltip_v0" : @"TG_displayedPrivateRecordModeTooltip_v0";
    
    bool alreadyDisplayed = [[[NSUserDefaults standardUserDefaults] objectForKey:key] boolValue];
    bool available = (_customInputPanel == nil) && [_companion allowVideoMessages];
    
    if (alreadyDisplayed || !available)
        return;
    
    CGFloat value = arc4random() / (CGFloat)UINT32_MAX;
    if (value < 0.2)
    {
        [self showRecordButtonTooltip:_inputTextPanel.videoMessage duration:4.0];
        [[NSUserDefaults standardUserDefaults] setObject:@true forKey:key];
    }
}

- (void)showBannedStickersTooltip:(int32_t)timeout
{
    if ([_inputTextPanel micButtonFrame].size.width < FLT_EPSILON)
        return;
    
    if ([self hasNonTextInputPanel]) {
        return;
    }
    
    NSString *text = @"";
    
    if (timeout == 0 || timeout == INT32_MAX) {
        text = TGLocalized(@"Conversation.RestrictedStickers");
    } else {
        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
        [formatter setDateFormat:@"E, d MMM HH:mm"];
        formatter.locale = [NSLocale localeWithLocaleIdentifier:effectiveLocalization().code];
        NSString *dateStringPlain = [formatter stringFromDate:[NSDate dateWithTimeIntervalSince1970:timeout]];
        
        text = [NSString stringWithFormat:TGLocalized(@"Conversation.RestrictedStickersTimed"), dateStringPlain];
    }
    
    if (_bannedStickersTooltipContainerView.isShowingTooltip)
    {
        [_bannedStickersTooltipContainerView.tooltipView setText:text animated:true];
    }
    else
    {
        [_tooltipContainerView removeFromSuperview];
        [_bannedStickersTooltipContainerView removeFromSuperview];
        
        _bannedStickersTooltipContainerView = [[TGTooltipContainerView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, self.view.frame.size.width, self.view.frame.size.height)];
        _bannedStickersTooltipContainerView.tooltipView.numberOfLines = 0;
        [self.view addSubview:_bannedStickersTooltipContainerView];
        
        [_bannedStickersTooltipContainerView.tooltipView setText:text animated:false];
        _bannedStickersTooltipContainerView.tooltipView.sourceView = _inputTextPanel.stickerButton;
        
        CGRect recordButtonFrame = [_inputTextPanel convertRect:[_inputTextPanel stickerButtonFrame] toView:_bannedStickersTooltipContainerView];
        recordButtonFrame.origin.y += 8.0f;
        [_bannedStickersTooltipContainerView showTooltipFromRect:recordButtonFrame animated:false];
    }
    
    __weak TGTooltipContainerView *weakContainerView = _bannedStickersTooltipContainerView;
    [_tooltipDismissDisposable setDisposable:[[[SSignal complete] delay:5.0 onQueue:[SQueue mainQueue]] startWithNext:nil completed:^{
        __strong TGTooltipContainerView *strongContainerView = weakContainerView;
        if (strongContainerView != nil)
            [strongContainerView hideTooltip];
    }]];
}

- (void)showBannedMediaTooltip:(int32_t)timeout
{
    if ([_inputTextPanel micButtonFrame].size.width < FLT_EPSILON)
        return;
    
    if ([self hasNonTextInputPanel]) {
        return;
    }
    
    NSString *text = @"";
    
    if (timeout == 0 || timeout == INT32_MAX) {
        text = TGLocalized(@"Conversation.RestrictedMedia");
    } else {
        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
        [formatter setDateFormat:@"E, d MMM HH:mm"];
        formatter.locale = [NSLocale localeWithLocaleIdentifier:effectiveLocalization().code];
        NSString *dateStringPlain = [formatter stringFromDate:[NSDate dateWithTimeIntervalSince1970:timeout]];
        
        text = [NSString stringWithFormat:TGLocalized(@"Conversation.RestrictedMediaTimed"), dateStringPlain];
    }
    
    if (_bannedMediaTooltipContainerView.isShowingTooltip)
    {
        [_bannedMediaTooltipContainerView.tooltipView setText:text animated:true];
    }
    else
    {
        [_tooltipContainerView removeFromSuperview];
        [_bannedMediaTooltipContainerView removeFromSuperview];
        
        _bannedMediaTooltipContainerView = [[TGTooltipContainerView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, self.view.frame.size.width, self.view.frame.size.height)];
        _bannedMediaTooltipContainerView.tooltipView.numberOfLines = 0;
        [self.view addSubview:_bannedMediaTooltipContainerView];
        
        [_bannedMediaTooltipContainerView.tooltipView setText:text animated:false];
        _bannedMediaTooltipContainerView.tooltipView.sourceView = _inputTextPanel.micButton;
        
        CGRect recordButtonFrame = [_inputTextPanel convertRect:[_inputTextPanel micButtonFrame] toView:_recordTooltipContainerView];
        recordButtonFrame.origin.y += 15.0f;
        [_bannedMediaTooltipContainerView showTooltipFromRect:recordButtonFrame animated:false];
    }
    
    __weak TGTooltipContainerView *weakContainerView = _bannedMediaTooltipContainerView;
    [_tooltipDismissDisposable setDisposable:[[[SSignal complete] delay:5.0 onQueue:[SQueue mainQueue]] startWithNext:nil completed:^{
        __strong TGTooltipContainerView *strongContainerView = weakContainerView;
        if (strongContainerView != nil)
            [strongContainerView hideTooltip];
    }]];
}

- (void)showRecordButtonTooltip:(bool)video duration:(NSTimeInterval)duration
{
    if ([self hasNonTextInputPanel]) {
        return;
    }
    
    if ([_inputTextPanel micButtonFrame].size.width < FLT_EPSILON)
        return;
    
    NSString *tooltipText = TGLocalized(video ? @"Conversation.HoldForVideo" : @"Conversation.HoldForAudio");
    
    if (_recordTooltipContainerView.isShowingTooltip && _recordTooltipContainerView.tooltipView.sourceView == _inputTextPanel.micButton)
    {
        [_recordTooltipContainerView.tooltipView setText:tooltipText animated:true];
    }
    else
    {
        [_tooltipContainerView removeFromSuperview];
        [_recordTooltipContainerView removeFromSuperview];
        
        _recordTooltipContainerView = [[TGTooltipContainerView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, self.view.frame.size.width, self.view.frame.size.height)];
        [self.view addSubview:_recordTooltipContainerView];
        
        [_recordTooltipContainerView.tooltipView setText:tooltipText animated:false];
        _recordTooltipContainerView.tooltipView.sourceView = _inputTextPanel.micButton;
        
        CGRect recordButtonFrame = [_inputTextPanel convertRect:[_inputTextPanel micButtonFrame] toView:_recordTooltipContainerView];
        recordButtonFrame.origin.y += 15.0f;
        [_recordTooltipContainerView showTooltipFromRect:recordButtonFrame animated:false];
    }
    
    __weak TGTooltipContainerView *weakContainerView = _recordTooltipContainerView;
    [_tooltipDismissDisposable setDisposable:[[[SSignal complete] delay:duration onQueue:[SQueue mainQueue]] startWithNext:nil completed:^{
        __strong TGTooltipContainerView *strongContainerView = weakContainerView;
        if (strongContainerView != nil)
            [strongContainerView hideTooltip];
    }]];
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
    if ([self hasNonTextInputPanel]) {
        return;
    }
    
    [_companion _toggleBroadcastMode];
    
    [_tooltipContainerView removeFromSuperview];
    _tooltipContainerView = nil;
    
    NSString *tooltipText = !_inputTextPanel.isBroadcasting ? TGLocalized(@"Conversation.SilentBroadcastTooltipOff") : TGLocalized(@"Conversation.SilentBroadcastTooltipOn")
    ;
    if (_recordTooltipContainerView.isShowingTooltip && _recordTooltipContainerView.tooltipView.sourceView == _inputTextPanel.broadcastButton)
    {
        [_recordTooltipContainerView.tooltipView setText:tooltipText animated:true];
    }
    else
    {
        [_tooltipContainerView removeFromSuperview];
        [_recordTooltipContainerView removeFromSuperview];
        
        _recordTooltipContainerView = [[TGTooltipContainerView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, self.view.frame.size.width, self.view.frame.size.height)];
        [self.view addSubview:_recordTooltipContainerView];
        
        [_recordTooltipContainerView.tooltipView setText:tooltipText animated:false];
        _recordTooltipContainerView.tooltipView.sourceView = _inputTextPanel.broadcastButton;
        
        CGRect buttonFrame = [_inputTextPanel convertRect:[_inputTextPanel broadcastModeButtonFrame] toView:_tooltipContainerView];
        buttonFrame.origin.y += 12.0f;
        [_recordTooltipContainerView showTooltipFromRect:buttonFrame animated:false];
    }
    
    __weak TGTooltipContainerView *weakContainerView = _recordTooltipContainerView;
    [_tooltipDismissDisposable setDisposable:[[[SSignal complete] delay:2.0 onQueue:[SQueue mainQueue]] startWithNext:nil completed:^{
        __strong TGTooltipContainerView *strongContainerView = weakContainerView;
        if (strongContainerView != nil)
            [strongContainerView hideTooltip];
    }]];
}

- (void)_enterEditingMode:(NSArray *)messageIndices
{
    if (!_editingMode)
    {
        [self endEditing];
        [self setCurrentTitlePanel:nil animation:TGModernConversationPanelAnimationSlide];
        
        [_companion clearCheckedMessages];
        for (TGMessageIndex *messageIndex in messageIndices)
        {
            [_companion setMessageChecked:messageIndex checked:true];
        }
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
        if (messageIndices.count == 1)
        {
            TGMessageIndex *animateFromMessageIndex = [messageIndices firstObject];
            for (NSUInteger i = 0; i < visibleCells.count; i++)
            {
                TGMessageModernConversationItem * item = ((TGModernCollectionCell *)visibleCells[i]).boundItem;
                if (item != nil && item->_message.mid == animateFromMessageIndex.messageId && item->_message.fromUid == animateFromMessageIndex.peerId)
                {
                    animateFromIndex = i;
                    break;
                }
            }
        }
        
        if (false && animateFromIndex != NSNotFound)
        {
            [(TGMessageModernConversationItem *)((TGModernCollectionCell *)visibleCells[animateFromIndex]).boundItem updateEditingState:_viewStorage animationDelay:0.0];
            
            NSTimeInterval upDelay = 0.01;
            for (NSInteger i = animateFromIndex + 1; i < (NSInteger)visibleCells.count; i++)
            {
                TGModernCollectionCell *cell = visibleCells[i];
                [(TGMessageModernConversationItem *)cell.boundItem updateEditingState:_viewStorage animationDelay:upDelay];
                
                upDelay += 0.008;
            }
            
            NSTimeInterval downDelay = 0.01;
            for (NSInteger i = animateFromIndex - 1; i >= 0; i--)
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
                TGMessageModernConversationItem *item = (TGMessageModernConversationItem *)cell.boundItem;
                if (item != nil)
                {
                    [item updateEditingState:_viewStorage animationDelay:delay];
                    
                    if (item->_message.groupedId == 0)
                        delay += 0.006;
                }
            }
        }
        
        [self setLeftBarButtonItem:[[UIBarButtonItem alloc] initWithTitle:[_companion canDeleteAllMessages] ? TGLocalized(@"Conversation.ClearAll") : @"" style:UIBarButtonItemStylePlain target:self action:@selector(clearAllButtonPressed)] animated:true];
        [self setRightBarButtonItem:[[UIBarButtonItem alloc] initWithTitle:TGLocalized(@"Common.Cancel") style:UIBarButtonItemStylePlain target:self action:@selector(doneButtonPressed)] animated:true];
        
        TGModernConversationEditingPanel *editPanel = [[TGModernConversationEditingPanel alloc] initWithFrame:CGRectMake(0.0f, 0.0f, _view.frame.size.width, 0.0f)];
        editPanel.delegate = self;
        [editPanel setForwardingEnabled:[_companion allowMessageForwarding]];
        [editPanel setDeleteEnabled:[self canDeleteSelectedMessages]];
        [editPanel setReportingEnabled:[self canReportAllSelectedMessages]];
        [editPanel setShareEnabled:[_companion allowMessageExternalSharing]];
        [self setInputPanel:editPanel animated:true];
        [self _updateEditingPanel];
        
        [_titleView setEditingMode:true animated:true];
        [_collectionView updateRelativeBounds];
        
        if (iosMajorVersion() >= 7)
            self.navigationController.interactivePopGestureRecognizer.enabled = false;
    }
}
- (bool)canReportAllSelectedMessages {
    NSArray *checkedMessageIndices = [_companion checkedMessageIndices];
    if (checkedMessageIndices.count == 0)
        return false;
    
    NSMutableDictionary *checkedMessageIdsByPeers = [[NSMutableDictionary alloc] init];
    for (TGMessageIndex *messageIndex in checkedMessageIndices) {
        NSMutableSet *checkedMessageIds = checkedMessageIdsByPeers[@(messageIndex.peerId)];
        if (checkedMessageIds == nil) {
            checkedMessageIds = [[NSMutableSet alloc] init];
            checkedMessageIdsByPeers[@(messageIndex.peerId)] = checkedMessageIds;
        }
        [checkedMessageIds addObject:@(messageIndex.messageId)];
    }
    
    for (TGMessageModernConversationItem *item in _items) {
        int64_t peerId = item->_message.fromUid;
        int32_t mid = item->_message.mid;
        if ([checkedMessageIdsByPeers[@(peerId)] containsObject:@(mid)]) {
            if (![_companion canReportMessage:item->_message]) {
                return false;
            }
        }
    }
    return true;
}

- (bool)canDeleteSelectedMessages {
    if ([_companion canDeleteMessages]) {
        return true;
    }
    
    NSArray *checkedMessageIndices = [_companion checkedMessageIndices];
    NSMutableSet *checkedMessageIds = [[NSMutableSet alloc] init];
    for (TGMessageIndex *messageIndex in checkedMessageIndices) {
        [checkedMessageIds addObject:@(messageIndex.messageId)];
    }
    
    for (TGMessageModernConversationItem *item in _items) {
        int32_t mid = item->_message.mid;
        if ([checkedMessageIds containsObject:@(mid)]) {
            if (![_companion canDeleteMessage:item->_message]) {
                return false;
            }
        }
    }
    return true;
}

- (bool)canForwardMessage:(TGMessage *)message
{
    if (message.deliveryState == TGMessageDeliveryStateFailed) {
        return false;
    }
    if (message.actionInfo.actionType == TGMessageActionPhoneCall) {
        return false;
    }
    if (message.messageLifetime != 0) {
        return false;
    }
    if (message.locationAttachment.period > 0) {
        return false;
    }
    
    return [_companion allowMessageForwarding];
}

- (bool)canForwardAllSelectedMessages {
    NSArray *checkedMessageIndices = [_companion checkedMessageIndices];
    NSMutableDictionary *checkedMessageIdsByPeers = [[NSMutableDictionary alloc] init];
    for (TGMessageIndex *messageIndex in checkedMessageIndices) {
        NSMutableSet *checkedMessageIds = checkedMessageIdsByPeers[@(messageIndex.peerId)];
        if (checkedMessageIds == nil) {
            checkedMessageIds = [[NSMutableSet alloc] init];
            checkedMessageIdsByPeers[@(messageIndex.peerId)] = checkedMessageIds;
        }
        [checkedMessageIds addObject:@(messageIndex.messageId)];
    }
    
    for (TGMessageModernConversationItem *item in _items) {
        int64_t peerId = item->_message.fromUid;
        int32_t mid = item->_message.mid;
        if ([checkedMessageIdsByPeers[@(peerId)] containsObject:@(mid)]) {
            if (![self canForwardMessage:item->_message]) {
                return false;
            }
        }
    }
    return true;
}

- (bool)canShareAllSelectedMessages {
    NSArray *checkedMessageIndices = [_companion checkedMessageIndices];
    NSMutableDictionary *checkedMessageIdsByPeers = [[NSMutableDictionary alloc] init];
    for (TGMessageIndex *messageIndex in checkedMessageIndices) {
        NSMutableSet *checkedMessageIds = checkedMessageIdsByPeers[@(messageIndex.peerId)];
        if (checkedMessageIds == nil) {
            checkedMessageIds = [[NSMutableSet alloc] init];
            checkedMessageIdsByPeers[@(messageIndex.peerId)] = checkedMessageIds;
        }
        [checkedMessageIds addObject:@(messageIndex.messageId)];
    }
    
    for (TGMessageModernConversationItem *item in _items) {
        int64_t peerId = item->_message.fromUid;
        int32_t mid = item->_message.mid;
        if ([checkedMessageIdsByPeers[@(peerId)] containsObject:@(mid)]) {
            TGMessage *message = item->_message;
            if (message.actionInfo.actionType == TGMessageActionPhoneCall)
                return false;
            if (message.messageLifetime != 0)
                return false;
            if (message.locationAttachment.period > 0)
                return false;
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
            TGMessageModernConversationItem *item = (TGMessageModernConversationItem *)cell.boundItem;
            if (item != nil)
            {
                [item updateEditingState:_viewStorage animationDelay:delay];
                
                if (item->_message.groupedId == 0)
                    delay += 0.006;
            }
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
        
        if (_secondaryTitlePanel != nil) {
            [self setCurrentTitlePanel:_secondaryTitlePanel animation:TGModernConversationPanelAnimationSlide];
        }
        
        [_collectionView updateRelativeBounds];
        
        if (iosMajorVersion() >= 7)
            self.navigationController.interactivePopGestureRecognizer.enabled = true;
    }
}

- (void)clearAllButtonPressed
{
    if ([_companion canDeleteAllMessages]) {
        ASHandle *actionHandle = _actionHandle;
        
        int64_t peerId = ((TGGenericModernConversationCompanion *)_companion).conversationId;
        
        bool isGroup = TGPeerIdIsGroup(peerId) || TGPeerIdIsChannel(peerId);
        NSString *text = TGLocalized(@"Conversation.ClearPrivateHistory");
        if (peerId == TGTelegraphInstance.clientUserId)
            text = TGLocalized(@"Conversation.ClearSelfHistory");
        else if (isGroup)
            text = TGLocalized(@"Conversation.ClearGroupHistory");
        else if (TGPeerIdIsSecretChat(peerId))
            text = TGLocalized(@"Conversation.ClearSecretHistory");
    
        [TGCustomAlertView presentAlertWithTitle:TGLocalized(@"DialogList.ClearHistoryConfirmation") message:text cancelButtonTitle:TGLocalized(@"Common.Cancel") okButtonTitle:TGLocalized(@"Common.OK") completionBlock:^(bool okButtonPressed)
        {
            if (okButtonPressed)
                [actionHandle requestAction:@"clearAllMessages" options:nil];
        }];
    }
}

- (void)_commitClearAllMessages
{
    [self _leaveEditingModeAnimated:true];
    [_companion controllerClearedConversation];
}

- (void)_commitDeleteMessages:(std::set<int32_t>)messageIds forEveryone:(bool)forEveryone
{
    NSMutableIndexSet *indexSet = [[NSMutableIndexSet alloc] init];
    NSMutableArray *checkedMessageIds = [[NSMutableArray alloc] init];
    for (std::set<int32_t>::iterator it = messageIds.begin(); it != messageIds.end(); ++it)
    {
        [checkedMessageIds addObject:@(*it)];
    }
    
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
    [_companion controllerDeletedMessages:checkedMessageIds forEveryone:forEveryone completion:^
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
    int32_t scrollBackMessageId = [_scrollStack popMessageId];
    if (scrollBackMessageId != 0)
    {
        int32_t messageId = scrollBackMessageId;
        scrollBackMessageId = 0;
        _hasUnseenMessagesBelow = false;
        
        [_companion navigateToMessageId:messageId scrollBackMessageId:0 forceUnseenMention:false animated:true];
    }
    else
    {
        _scrollButtons.unreadMessageCount = 0;
        if (_enableBelowHistoryRequests)
            [_companion _performFastScrollDown:false becauseOfNavigation:true];
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

- (void)unseenMentionsButtonPressed {
    __weak TGModernConversationController *weakSelf = self;
    [_loadEarliestUnseenMentionIdDisposable setDisposable:[[[TGDownloadMessagesSignal earliestUnseenMentionMessageId:[_companion requestPeerId] accessHash:[_companion requestAccessHash]] deliverOn:[SQueue mainQueue]] startWithNext:^(NSNumber *nMessageId) {
        __strong TGModernConversationController *strongSelf = weakSelf;
        if (strongSelf != nil) {
            if ([nMessageId intValue] != 0) {
                [strongSelf->_companion navigateToMessageId:[nMessageId intValue] scrollBackMessageId:0 forceUnseenMention:true animated:true];
            }
        }
    }]];
}

#pragma mark -

- (void)inputPanelWillChangeHeight:(TGModernConversationInputPanel *)inputPanel height:(CGFloat)height duration:(NSTimeInterval)duration animationCurve:(int)animationCurve
{
    if (inputPanel == _currentInputPanel)
    {
        [_currentInputPanel adjustForSize:_view.bounds.size keyboardHeight:_keyboardHeight duration:duration animationCurve:animationCurve contentAreaHeight:[self contentAreaHeight] safeAreaInset:self.controllerSafeAreaInset];
        [self _adjustCollectionViewForSize:_view.bounds.size keyboardHeight:_keyboardHeight inputContainerHeight:height duration:duration animationCurve:animationCurve];
    }
}

- (void)_adjustCollectionViewForSize:(CGSize)size keyboardHeight:(CGFloat)keyboardHeight inputContainerHeight:(CGFloat)inputContainerHeight duration:(NSTimeInterval)duration animationCurve:(int)animationCurve
{
    [self _adjustCollectionViewForSize:size keyboardHeight:keyboardHeight inputContainerHeight:inputContainerHeight scrollToBottom:false dismissOffset:0.0f duration:duration animationCurve:animationCurve];
}

- (void)_adjustCollectionViewForSize:(CGSize)__unused size keyboardHeight:(CGFloat)keyboardHeight inputContainerHeight:(CGFloat)inputContainerHeight scrollToBottom:(bool)scrollToBottom dismissOffset:(CGFloat)dismissOffset duration:(NSTimeInterval)duration animationCurve:(int)animationCurve
{
    bool stopScrolling = _collectionView.contentOffset.y >= -_collectionView.contentInset.top;
    [self _adjustCollectionViewForSize:size keyboardHeight:keyboardHeight inputContainerHeight:inputContainerHeight scrollToBottom:scrollToBottom stopScrolling:stopScrolling dismissOffset:dismissOffset duration:duration animationCurve:animationCurve];
}

- (void)_adjustCollectionViewForSize:(CGSize)__unused size keyboardHeight:(CGFloat)keyboardHeight inputContainerHeight:(CGFloat)inputContainerHeight scrollToBottom:(bool)scrollToBottom stopScrolling:(bool)stopScrolling dismissOffset:(CGFloat)dismissOffset duration:(NSTimeInterval)duration animationCurve:(int)animationCurve
{
    CGFloat contentHeight =  _collectionView.contentSize.height;
    
    UIEdgeInsets originalInset = _collectionView.contentInset;
    UIEdgeInsets inset = originalInset;
    inset.top = keyboardHeight + inputContainerHeight;
    
    bool isAnimatedDismissal = (dismissOffset > FLT_EPSILON && duration > DBL_EPSILON);
    if ((keyboardHeight < FLT_EPSILON || isAnimatedDismissal) && ((_currentInputPanel == _inputTextPanel && ((!_inputTextPanel.isCustomKeyboardActive && _inputTextPanel.customKeyboardHeight < FLT_EPSILON) || isAnimatedDismissal)) || _currentInputPanel == _searchPanel) && !_companion.previewMode)
        inset.top += self.controllerSafeAreaInset.bottom;
    
    inset.top -= dismissOffset;
    
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
    
    CGRect bottomDimFrame = [_currentInputPanel convertRect:_currentInputPanel.bounds toView:self.view];;
    if (duration > DBL_EPSILON)
    {
        [UIView animateWithDuration:duration delay:0 options:(animationCurve << 16) | UIViewAnimationOptionBeginFromCurrentState | UIViewAnimationOptionAllowUserInteraction animations:^
        {
            bool decorationViewUpdatesWereDisabled = [_collectionView disableDecorationViewUpdates];
            [_collectionView setDisableDecorationViewUpdates:decorationViewUpdatesWereDisabled || originalInset.top < inset.top];
            
            _collectionView.contentInset = inset;
            if (!CGPointEqualToPoint(contentOffset, originalContentOffset))
            {
                [_collectionView setBounds:CGRectMake(0, contentOffset.y, _collectionView.frame.size.width, _collectionView.frame.size.height)];
            }
            
            [self _updateUnseenMessagesButton];
            [_collectionView setDisableDecorationViewUpdates:decorationViewUpdatesWereDisabled];
            
            if (!decorationViewUpdatesWereDisabled)
                [_collectionView updateHeaderView];
            
            [_emptyListPlaceholder adjustLayoutForSize:_view.bounds.size contentInsets:UIEdgeInsetsMake(_collectionView.contentInset.bottom - 210.0f - [_collectionView implicitTopInset], 0.0f, _collectionView.contentInset.top, 0.0f) duration:0.0 curve:0];
            
            _bottomDimView.frame = CGRectMake(bottomDimFrame.origin.x, bottomDimFrame.origin.y, bottomDimFrame.size.width, _currentInputPanel.currentHeight + self.controllerSafeAreaInset.bottom);
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
        
        [_emptyListPlaceholder adjustLayoutForSize:_view.bounds.size contentInsets:UIEdgeInsetsMake(_collectionView == nil ? self.controllerInset.top : (_collectionView.contentInset.bottom - 210.0f - [_collectionView implicitTopInset]), 0.0f, _collectionView == nil ? [_currentInputPanel currentHeight] : _collectionView.contentInset.top, 0.0f) duration:0.0 curve:0];
        
        
        _bottomDimView.frame = CGRectMake(bottomDimFrame.origin.x, bottomDimFrame.origin.y, bottomDimFrame.size.width, _currentInputPanel.currentHeight + self.controllerSafeAreaInset.bottom);
    }
}

- (void)keyboardWillChangeFrame:(NSNotification *)notification
{
    if (_collectionView == nil)
        return;
    
    if (_inputTextPanel.isCustomKeyboardExpanded)
        return;
    
    CGSize collectionViewSize = _view.frame.size;
    
    NSTimeInterval duration = notification.userInfo[UIKeyboardAnimationDurationUserInfoKey] == nil ? 0.3 : [notification.userInfo[UIKeyboardAnimationDurationUserInfoKey] doubleValue];
    int curve = [notification.userInfo[UIKeyboardAnimationCurveUserInfoKey] intValue] << 16;
    
    CGRect screenKeyboardFrame = [notification.userInfo[UIKeyboardFrameEndUserInfoKey] CGRectValue];
    CGRect keyboardFrame = [_view convertRect:screenKeyboardFrame fromView:nil];
    
    CGFloat keyboardHeight = (keyboardFrame.size.height <= FLT_EPSILON || keyboardFrame.size.width <= FLT_EPSILON) ? 0.0f : (collectionViewSize.height - keyboardFrame.origin.y);
    
    if (!_doNotIgnoreKeyboardChangeDuringAppearance) {
        if ((freedomUIKitTest3() && freedomUIKitTest3_1()) || [self viewControllerIsAnimatingAppearanceTransition] || [(TGNavigationController *)self.navigationController isInPopTransition] || [(TGNavigationController *)self.navigationController isInControllerTransition]) {
            return;
        }
    } else {
        duration = 0.0;
        curve = 0;
    }
    
    if (_inputTextPanel.changingKeyboardMode && keyboardHeight < FLT_EPSILON)
        return;
    
    keyboardHeight = MAX(keyboardHeight, 0.0f);
    
    bool isSlideOver = TGAppDelegateInstance.rootController.isSlideOver;
    if (keyboardFrame.origin.y + keyboardFrame.size.height < collectionViewSize.height - FLT_EPSILON - (isSlideOver ? 20.0f : 0.0))
        keyboardHeight = 0.0f;
    
    if (isSlideOver && fabs(keyboardHeight - 55.0f) < FLT_EPSILON)
        keyboardHeight = 35.0f;
    
    if (ABS(_keyboardHeight - keyboardHeight) < FLT_EPSILON && ABS(collectionViewSize.width - _collectionView.frame.size.width) < FLT_EPSILON)
        return;
    
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
            dispatch_block_t block = ^{
                [_currentInputPanel adjustForSize:_view.bounds.size keyboardHeight:keyboardHeight duration:duration animationCurve:curve contentAreaHeight:[self contentAreaHeight] safeAreaInset:self.controllerSafeAreaInset];
                
                if (_collectionViewIgnoresNextKeyboardHeightChange)
                {
                    _collectionViewIgnoresNextKeyboardHeightChange = false;
                    return;
                }
                
                [self _adjustCollectionViewForSize:_view.bounds.size keyboardHeight:keyboardHeight inputContainerHeight:[_currentInputPanel currentHeight] duration:duration animationCurve:curve];
            };
            
            if (duration < DBL_EPSILON) {
                [UIView performWithoutAnimation:block];
            } else {
                block();
            }
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
        
        [_currentInputPanel adjustForSize:_view.bounds.size keyboardHeight:keyboardHeight duration:duration animationCurve:curve contentAreaHeight:[self contentAreaHeight] safeAreaInset:self.controllerSafeAreaInset];
        [self _adjustCollectionViewForSize:_view.bounds.size keyboardHeight:keyboardHeight inputContainerHeight:[_currentInputPanel currentHeight] duration:duration animationCurve:curve];
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
        _currentTitlePanel.safeAreaInset = [self calculatedSafeAreaInset];
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
    
    [_currentInputPanel changeToSize:size keyboardHeight:keyboardHeight duration:duration contentAreaHeight:[self contentAreaHeight] safeAreaInset:self.controllerSafeAreaInset];
    
    [self updatePanelLayouts:self.controllerInset size:size];
    
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
    NSArray *previousLayoutAttributes = [_collectionLayout layoutAttributesForItems:_items containerWidth:previousCollectionFrame.size.width maxHeight:FLT_MAX decorationViewAttributes:&previousDecorationAttributes contentHeight:NULL viewStorage:_viewStorage];
    
    int collectionItemCount = _items.count > previousLayoutAttributes.count ? (int)previousLayoutAttributes.count : (int)_items.count;
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
    
    UIEdgeInsets safeAreaInset = [self calculatedSafeAreaInset];;
    _collectionView.frame = CGRectMake(safeAreaInset.left, -210.0f, collectionViewSize.width - safeAreaInset.left - safeAreaInset.right, collectionViewSize.height + 210.0f);
    [_companion _setControllerWidthForItemCalculation:_collectionView.frame.size.width];
    
    [_collectionLayout invalidateLayout];
    
    UIEdgeInsets originalInset = _collectionView.contentInset;
    UIEdgeInsets inset = originalInset;
    inset.top = keyboardHeight + [_currentInputPanel currentHeight];
    if (_keyboardHeight < FLT_EPSILON && ((_currentInputPanel == _inputTextPanel && !_inputTextPanel.isCustomKeyboardActive && _inputTextPanel.customKeyboardHeight < FLT_EPSILON) || _currentInputPanel == _searchPanel) && !_companion.previewMode)
        inset.top += safeAreaInset.bottom;
    inset.bottom = self.controllerInset.top + 210.0f + [_collectionView implicitTopInset];
    _collectionView.contentInset = inset;
    [self _updateUnseenMessagesButton];
    
    [_emptyListPlaceholder adjustLayoutForSize:size contentInsets:UIEdgeInsetsMake(_collectionView.contentInset.bottom - 210.0f - [_collectionView implicitTopInset], 0.0f, _collectionView.contentInset.top, 0.0f) duration:duration curve:0];
    
    CGFloat newContentHeight = 0.0f;
    std::vector<TGDecorationViewAttrubutes> newDecorationAttributes;
    NSArray *newLayoutAttributes = [_collectionLayout layoutAttributesForItems:_items containerWidth:_collectionView.frame.size.width maxHeight:FLT_MAX decorationViewAttributes:&newDecorationAttributes contentHeight:&newContentHeight viewStorage:_viewStorage];
    
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
    collectionItemCount = _items.count > newLayoutAttributes.count ? (int)newLayoutAttributes.count : (int)_items.count;
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
            if (cell == nil)
                continue;
            
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
                [item sizeForContainerSize:CGSizeMake(previousFrame.size.width, 0.0f) viewStorage:_viewStorage];
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
                [item sizeForContainerSize:CGSizeMake(_collectionView.frame.size.width, 0.0f) viewStorage:_viewStorage];
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
    else if ([action isEqualToString:@"menuAction"])
    {
        int32_t mid = [options[@"userInfo"][@"mid"] int32Value];
        int64_t peerId = [options[@"userInfo"][@"peerId"] int64Value];
        int64_t groupedId = [options[@"userInfo"][@"groupedId"] int64Value];
        if (mid != 0)
        {
            NSMutableArray *groupMessageItems = groupedId != 0 ? [[NSMutableArray alloc] init] : nil;
            TGMessageModernConversationItem *menuMessageItem = nil;
            
            int index = -1;
            for (TGMessageModernConversationItem *messageItem in _items)
            {
                index++;
                if (messageItem->_message.mid == mid)
                {
                    menuMessageItem = messageItem;
                    
                    if (groupedId == 0)
                        break;
                }
                
                if (groupedId != 0 && groupedId == messageItem->_message.groupedId)
                    [groupMessageItems addObject:messageItem];
                
                if (groupMessageItems.count == 10 && menuMessageItem != nil)
                    break;
                
            }
            
            if (groupMessageItems.count > 0)
            {
                [groupMessageItems sortUsingComparator:^NSComparisonResult(TGMessageModernConversationItem *obj1, TGMessageModernConversationItem *obj2)
                {
                    if (obj1->_message.mid > obj2->_message.mid)
                        return NSOrderedAscending;
                    else
                        return NSOrderedDescending;
                }];
            }
            
            NSString *menuAction = options[@"action"];
            if ([menuAction isEqualToString:@"copy"])
            {
                if (menuMessageItem != nil)
                {
                    NSString *text = nil;
                    bool hasImage = false;
                    if (menuMessageItem->_message.caption.length != 0)
                        text = menuMessageItem->_message.caption;
                    else if (menuMessageItem->_message.text.length != 0)
                        text = menuMessageItem->_message.text;
                    
                    for (TGMediaAttachment *attachment in menuMessageItem->_message.mediaAttachments)
                    {
                        if ([attachment isKindOfClass:[TGImageMediaAttachment class]])
                        {
                            hasImage = true;
                            break;
                        }
                    }

                    if (hasImage && text.length == 0)
                    {
                        [[TGExternalShareSignals shareItemsForMessages:@[menuMessageItem->_message]] startWithNext:^(NSArray *next)
                        {
                            UIImage *image = next.firstObject;
                            if (image != nil)
                            {
                                if (text.length > 0)
                                    [UIPasteboard generalPasteboard].items = @[ @{(NSString *)kUTTypePNG: image}, @{(NSString *)kUTTypeUTF8PlainText: text} ];
                                else
                                    [[UIPasteboard generalPasteboard] setImage:image];
                            }
                        }];
                    }
                    else if (text.length > 0)
                        [[UIPasteboard generalPasteboard] setString:text];
                }
            }
            else if ([menuAction isEqualToString:@"copyLink"])
            {
                SSignal *linkSignal = [[[[TGMessageSearchSignals shareLinkForChannelMessage:[_companion requestPeerId] accessHash:[_companion requestAccessHash] messageId:mid grouped:false] catch:^SSignal *(__unused id error) {
                    return [SSignal single:nil];
                }] take:1] deliverOn:[SQueue mainQueue]];
                
                [linkSignal startWithNext:^(NSString *next) {
                    if (next.length > 0) {
                        UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];
                        [pasteboard setString:next];
                    }
                }];
                
            }
            else if ([menuAction isEqualToString:@"saveGif"])
            {
                if (menuMessageItem != nil)
                {
                    for (id attachment in menuMessageItem->_message.mediaAttachments) {
                        if ([attachment isKindOfClass:[TGDocumentMediaAttachment class]]) {
                            if ([(TGDocumentMediaAttachment *)attachment isAnimated]) {
                                [TGRecentGifsSignal addRecentGifFromDocument:attachment];
                            }
                            
                            break;
                        }
                    }
                }
                
                [self maybeDisplayGifTooltip];
            }
            else if ([menuAction isEqualToString:@"faveSticker"] || [menuAction isEqualToString:@"unfaveSticker"])
            {
                if (menuMessageItem != nil)
                {
                    for (id attachment in menuMessageItem->_message.mediaAttachments) {
                        if ([attachment isKindOfClass:[TGDocumentMediaAttachment class]]) {
                            [TGFavoriteStickersSignal setSticker:attachment faved:[menuAction isEqualToString:@"faveSticker"]];
                            break;
                        }
                    }
                }
            }
            else if ([menuAction isEqualToString:@"delete"])
            {
                if (menuMessageItem != nil && index >= 0)
                {
                    if (!TGIsPad())
                        _contextMenuController.ignoreNextDismissal = true;
                    
                    std::set<int32_t> messageIds;
                    if (groupMessageItems.count > 0)
                    {
                        for (TGMessageModernConversationItem *item in groupMessageItems)
                        {
                            messageIds.insert(item->_message.mid);
                        }
                    }
                    else
                    {
                        messageIds.insert(mid);
                    }
                    [self _showDeleteMessagesMenuForMessageIds:messageIds];
                }
            }
            else if ([menuAction isEqualToString:@"moderate"]) {
                TGUser *user = [TGDatabaseInstance() loadUser:(int32_t)menuMessageItem->_message.fromUid];
                if (user != nil) {
                    [self _showModerateSheetForMessageIndices:@[[TGMessageIndex indexWithPeerId:menuMessageItem->_message.fromUid messageId:menuMessageItem->_message.mid]] author:user];
                }
            }
            else if ([menuAction isEqualToString:@"ban"]) {
                TGUser *user = [TGDatabaseInstance() loadUser:(int32_t)menuMessageItem->_message.fromUid];
                if (user != nil && [self isAdminLog]) {
                    [((TGAdminLogConversationCompanion *)_companion) banUser:user];
                }
            }
            else if ([menuAction isEqualToString:@"reply"])
            {
                if (_searchBar != nil && !_searchBar.hidden) {
                    [self searchBarCancelButtonClicked:(UISearchBar *)_searchBar];
                }
                
                if (menuMessageItem != nil)
                {
                    _inputTextPanel.inputField.internalTextView.enableFirstResponder = true;
                    [self setReplyMessage:menuMessageItem->_message animated:true];
                    if (_currentInputPanel == _inputTextPanel && (menuMessageItem->_message.replyMarkup.isInline ||  menuMessageItem->_message.replyMarkup.rows.count == 0))
                        [self openKeyboard];
                }
            }
            else if ([menuAction isEqualToString:@"edit"]) {
                if (_searchPanel != nil && _currentInputPanel == _searchPanel) {
                    [self searchBarCancelButtonClicked:(UISearchBar *)_searchBar];
                }
                [self endMessageEditing:false];
                
                if (menuMessageItem != nil) {
                    bool isCaption = false;
                    NSString *messageText = nil;
                    if (menuMessageItem->_message.caption.length != 0)
                    {
                        messageText = menuMessageItem->_message.caption;
                        isCaption = true;
                    }
                    else if (menuMessageItem->_message.text.length != 0)
                    {
                        messageText = menuMessageItem->_message.text;
                    }
                    
                    NSArray *messageEntities = menuMessageItem->_message.entities;
                    
                    if (_editingContextDisposable == nil) {
                        _editingContextDisposable = [[SMetaDisposable alloc] init];
                    }
                    
                    __strong TGModernConversationController *strongSelf = self;
                    if (strongSelf != nil) {
                        [self setEditMessageWithText:messageText entities:messageEntities messageId:menuMessageItem->_message.mid animated:true];
                        if (_currentInputPanel == _inputTextPanel && menuMessageItem->_message.replyMarkup.rows.count == 0) {
                            [self openKeyboard];
                        }
                    }
                }
            }
            else if ([menuAction isEqualToString:@"pin"]) {
                [self endEditing];
                
                __weak TGModernConversationController *weakSelf = self;
                [[[[_companion updatePinnedMessage:menuMessageItem->_message.mid] deliverOn:[SQueue mainQueue]] onDispose:^{
                }] startWithNext:nil error:^(__unused id error) {
                    __strong TGModernConversationController *strongSelf = weakSelf;
                    if (strongSelf != nil) {
                        NSString *errorText = TGLocalized(@"Login.UnknownError");
                        [TGCustomAlertView presentAlertWithTitle:nil message:errorText cancelButtonTitle:TGLocalized(@"Common.OK") okButtonTitle:nil completionBlock:nil];
                    }
                } completed:^{
                }];
            } else if ([menuAction isEqualToString:@"unpin"]) {
                [self endEditing];
                
                __weak TGModernConversationController *weakSelf = self;
                [[[[_companion updatePinnedMessage:0] deliverOn:[SQueue mainQueue]] onDispose:^{
                }] startWithNext:nil error:^(__unused id error) {
                    __strong TGModernConversationController *strongSelf = weakSelf;
                    if (strongSelf != nil) {
                        NSString *errorText = TGLocalized(@"Login.UnknownError");
                        [TGCustomAlertView presentAlertWithTitle:nil message:errorText cancelButtonTitle:TGLocalized(@"Common.OK") okButtonTitle:nil completionBlock:nil];
                    }
                } completed:^{
                }];
            } else if ([menuAction isEqualToString:@"report"]) {
                _contextMenuController.ignoreNextDismissal = true;
                [_companion reportMessageIndices:@[[TGMessageIndex indexWithPeerId:menuMessageItem->_message.cid messageId:menuMessageItem->_message.mid] ] menuController:_contextMenuController];
            } else if ([menuAction isEqualToString:@"forward"]) {
                NSMutableArray *messageIndices = [[NSMutableArray alloc] init];
                if (groupMessageItems.count > 0)
                {
                    for (TGMessageModernConversationItem *item in groupMessageItems)
                    {
                        [messageIndices addObject:[TGMessageIndex indexWithPeerId:item->_message.fromUid messageId:item->_message.mid]];
                    }
                }
                else
                {
                    [messageIndices addObject:[TGMessageIndex indexWithPeerId:peerId messageId:mid]];
                }
                
                [self forwardMessages:messageIndices fastForward:false grouped:groupedId != 0];
            }
            else if ([menuAction isEqualToString:@"stickerPackInfo"]) {
                [self openStickerPackForMessageId:mid peerId:peerId];
            }
            else if ([menuAction isEqualToString:@"select"]) {
                NSMutableArray *messageIndices = [[NSMutableArray alloc] init];
                if (groupMessageItems.count > 0)
                {
                    for (TGMessageModernConversationItem *item in groupMessageItems)
                    {
                        [messageIndices addObject:[TGMessageIndex indexWithPeerId:item->_message.fromUid messageId:item->_message.mid]];
                    }
                }
                else
                {
                    [messageIndices addObject:[TGMessageIndex indexWithPeerId:peerId messageId:mid]];
                }
                [self _enterEditingMode:messageIndices];
            }
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
            else if ([menuAction isEqualToString:@"sendCallLog"])
            {
                [self endEditing];
                
                for (id attachment in menuMessageItem->_message.mediaAttachments)
                {
                    if ([attachment isKindOfClass:[TGActionMediaAttachment class]])
                    {
                        TGActionMediaAttachment *action = (TGActionMediaAttachment *)attachment;
                        if (action.actionType == TGMessageActionPhoneCall)
                        {
                            int64_t callId = [action.actionData[@"callId"] int64Value];
                            int64_t accessHash = 0;
                            
                            NSString *path = [[TGAppDelegate documentsPath] stringByAppendingPathComponent:@"calls"];
                            NSMutableArray *logs = [[[NSFileManager defaultManager] contentsOfDirectoryAtPath:path error:nil] mutableCopy];
                            NSString *logPrefix = [NSString stringWithFormat:@"%lld-", callId];
                            for (NSString *log in logs)
                            {
                                if ([log hasPrefix:logPrefix])
                                {
                                    NSString *accessHashString = [log substringWithRange:NSMakeRange(logPrefix.length, log.length - logPrefix.length - 4)];
                                    accessHash = [accessHashString integerValue];
                                    break;
                                }
                            }
                            
                            if (callId != 0 && accessHash != 0)
                                [TGCallController presentRatingAlertView:callId accessHash:accessHash presentTabAlert:false];
                        }
                        break;
                    }
                }
            }
            else if ([menuAction isEqualToString:@"stopLiveLocation"])
            {
                [[TGLiveLocationSignals stopLiveLocationWithPeerId:[self peerId] messageId:menuMessageItem->_message.mid] startWithNext:nil];
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
        
        [self unfocusMessagesAnimated:true];
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
            [self setInputText:@"" replace:true selectRange:NSMakeRange(0, 0)];
        }
    });
}

- (CGRect)sourceRectForMessageId:(int32_t)messageId peerId:(int64_t)peerId
{
    for (TGModernCollectionCell *cell in _collectionView.visibleCells)
    {
        TGMessageModernConversationItem *messageItem = cell.boundItem;
        if (messageItem != nil && messageItem->_message.mid == messageId && (peerId == 0 || messageItem->_message.fromUid == peerId))
        {
            CGRect contentFrame = [[cell contentViewForBinding] convertRect:[messageItem effectiveContentFrame] toView:_view];
            if (CGRectIsNull(contentFrame) || CGRectIsEmpty(contentFrame))
                break;
            
            contentFrame = CGRectIntersection(contentFrame, CGRectMake(0, 0, _view.frame.size.width, _currentInputPanel == nil ? _view.frame.size.height : _currentInputPanel.frame.origin.y));
            if (CGRectIsNull(contentFrame) || CGRectIsEmpty(contentFrame))
                break;
            
            return contentFrame;
        }
    }
    
    return CGRectZero;
}

- (void)_openEmbedFromMessageId:(int32_t)messageId peerId:(int64_t)peerId cancelPIP:(bool)cancelPIP
{
    TGMessage *message = nil;
    
    int index = -1;
    for (TGMessageModernConversationItem *messageItem in _items)
    {
        index++;
        
        if (messageItem->_message.mid == messageId && (peerId == 0 || messageItem->_message.fromUid == peerId))
        {
            message = messageItem->_message;
            break;
        }
    }
    
    if (message == nil)
        return;
    
    for (TGMediaAttachment *attachment in message.mediaAttachments)
    {
        if (attachment.type == TGWebPageMediaAttachmentType)
        {
            [self openEmbed:(TGWebPageMediaAttachment *)attachment forMessageId:messageId peerId:peerId cancelPIP:cancelPIP];
            break;
        }
    }
}

- (void)openEmbedFromMessageId:(int32_t)messageId peerId:(int64_t)peerId cancelPIP:(bool)cancelPIP
{
    if ([TGEmbedMenu isEmbedMenuController:_menuController])
        [_menuController dismissAnimated:false];
    
    bool foundCell = false;
    for (TGModernCollectionCell *cell in _collectionView.visibleCells)
    {
        TGMessageModernConversationItem *messageItem = (TGMessageModernConversationItem *)cell.boundItem;
        if (messageItem != nil && messageItem->_message.mid == messageId && (peerId == 0 || messageItem->_message.fromUid == peerId))
        {
            foundCell = true;
            break;
        }
    }
    
    if (foundCell)
    {
        [self _openEmbedFromMessageId:messageId peerId:peerId cancelPIP:cancelPIP];
    }
    else
    {
        _openMediaForMessageIdUponDisplay = messageId;
        _openMediaForPeerIdUponDisplay = peerId;
        _openedMediaIsEmbed = true;
        _cancelPIPForOpenedMedia = cancelPIP;
    }
}

- (void)openEmbed:(TGWebPageMediaAttachment *)webPage forMessageId:(int32_t)messageId peerId:(int64_t)peerId
{
    [self openEmbed:webPage forMessageId:messageId peerId:peerId cancelPIP:false];
}

- (void)openEmbed:(TGWebPageMediaAttachment *)webPage forMessageId:(int32_t)messageId peerId:(int64_t)peerId cancelPIP:(bool)cancelPIP
{
    CGRect (^sourceRect)(void) = ^CGRect
    {
        return [self sourceRectForMessageId:messageId peerId:peerId];
    };
    
    if (webPage.url.length == 0)
        return;
    
    [self endEditing];
    
    _menuController = [TGEmbedMenu presentInParentController:self attachment:webPage peerId:_companion.requestPeerId messageId:messageId cancelPIP:cancelPIP sourceView:_view sourceRect:sourceRect];
}

- (void)openEmbed:(TGWebPageMediaAttachment *)webPage sourceRectSource:(CGRect (^)(void))sourceRectSource
{
    if (webPage.url.length == 0)
        return;
    
    [self endEditing];
    
    _menuController = [TGEmbedMenu presentInParentController:self attachment:webPage peerId:0 messageId:0 cancelPIP:false sourceView:_view sourceRect:sourceRectSource];
}

- (bool)openPIPSourceLocation:(TGPIPSourceLocation *)location
{
    if (location.webPage == nil)
    {
        if (location.embed)
            [self openEmbedFromMessageId:location.messageId peerId:0 cancelPIP:true];
        else
            [self openMediaFromMessage:location.messageId peerId:0 cancelPIP:true];
        
        return false;
    }
    else
    {
        for (UIViewController *viewController in TGAppDelegateInstance.rootController.viewControllers)
        {
            if ([viewController isKindOfClass:[TGInstantPageController class]])
            {
                TGInstantPageController *pageController = (TGInstantPageController *)viewController;
                if (pageController.webPage.webPageId == location.webPage.webPageId) {
                    
                    [self.navigationController popToViewController:pageController animated:true];
                    [pageController scrollToPIPLocation:location];
                    return true;
                }
            }
        }
        
        TGInstantPageController *pageController = [[TGInstantPageController alloc] initWithWebPage:location.webPage anchor:nil peerId:location.conversationId messageId:location.messageId];
        [pageController scrollToPIPLocation:location];
        [self.navigationController pushViewController:pageController animated:true];
        
        return true;
    }
}

- (void)openStickerPackForMessageId:(int32_t)messageId peerId:(int64_t)peerId
{
    TGMessageModernConversationItem *stickerMessageItem = nil;
    
    for (TGMessageModernConversationItem *messageItem in _items)
    {
        if (messageItem->_message.mid == messageId && (peerId == 0 || messageItem->_message.fromUid))
        {
            stickerMessageItem = messageItem;
            break;
        }
    }
    
    if (stickerMessageItem == nil)
        return;
    
    id<TGStickerPackReference> packReference = nil;
    for (id attachment in stickerMessageItem->_message.mediaAttachments)
    {
        if ([attachment isKindOfClass:[TGDocumentMediaAttachment class]])
        {
            for (id attribute in ((TGDocumentMediaAttachment *)attachment).attributes)
            {
                if ([attribute isKindOfClass:[TGDocumentAttributeSticker class]])
                    packReference = ((TGDocumentAttributeSticker *)attribute).packReference;
            }
            break;
        }
    }
    
    if (packReference == nil)
        return;
    
    [self endEditing];
    
    __weak TGModernConversationController *weakSelf = self;
    void (^sendSticker)(TGDocumentMediaAttachment *) = ^(TGDocumentMediaAttachment *sticker)
    {
        __strong TGModernConversationController *strongSelf = weakSelf;
        if (strongSelf != nil)
            [strongSelf->_companion controllerWantsToSendRemoteDocument:sticker asReplyToMessageId:[strongSelf currentReplyMessageId] text:nil entities:nil botContextResult:nil botReplyMarkup:nil];
    };
    
    if (_isChannel)
        sendSticker = nil;
    
    TGMenuSheetController *existingController = !TGIsPad() ? _contextMenuController : nil;
    if (existingController != nil)
    {
        existingController.requiresShadow = false;
        _contextMenuController = nil;
    }
    _menuController = [TGStickersMenu presentWithParentController:self packReference:packReference stickerPack:nil showShareAction:false sendSticker:sendSticker stickerPackRemoved:nil stickerPackAdded:nil stickerPackHidden:nil linkOpened:nil stickerPackArchived:false stickerPackIsMask:false sourceView:_view sourceRect:^CGRect
    {
        __strong TGModernConversationController *strongSelf = weakSelf;
        if (strongSelf == nil)
            return CGRectZero;
        
        return [strongSelf sourceRectForMessageId:messageId peerId:peerId];
    } centered:false existingController:existingController expanded:false];
}

- (void)openStickerPackForReference:(id<TGStickerPackReference>)packReference
{
    [self endEditing];
    
    __weak TGModernConversationController *weakSelf = self;
    void (^sendSticker)(TGDocumentMediaAttachment *) = ^(TGDocumentMediaAttachment *sticker)
    {
        __strong TGModernConversationController *strongSelf = weakSelf;
        if (strongSelf != nil)
            [strongSelf->_companion controllerWantsToSendRemoteDocument:sticker asReplyToMessageId:[strongSelf currentReplyMessageId] text:nil entities:nil botContextResult:nil botReplyMarkup:nil];
    };
    
    if (_isChannel)
        sendSticker = nil;
    
    _menuController = [TGStickersMenu presentInParentController:self stickerPackReference:packReference showShareAction:false sendSticker:sendSticker stickerPackRemoved:nil stickerPackHidden:nil sourceView:_view sourceRect:^CGRect
    {
        return CGRectZero;
    }];
}

- (void)activateSearch
{
    if (_searchBar == nil)
    {
        CGFloat offset = self.controllerSafeAreaInset.top > 0 ? self.controllerSafeAreaInset.top : ([self shouldIgnoreStatusBar] ? 0.0f : 20.0f) + self.additionalStatusBarHeight;
        _searchBar = [[TGSearchBar alloc] initWithFrame:CGRectMake(0.0f, offset, _view.frame.size.width, [TGSearchBar searchBarBaseHeight]) style:TGSearchBarStyleLight];
        [_searchBar setPallete:self.presentation.searchBarPallete];
        _searchBar.safeAreaInset = self.controllerSafeAreaInset;
        _searchBar.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        _searchBar.delegate = self;
        [_searchBar setShowsCancelButton:true animated:false];
        [_searchBar setAlwaysExtended:true];
        _searchBar.placeholder = [self isAdminLog] ? TGLocalized(@"Common.Search") : TGLocalized(@"Conversation.SearchPlaceholder");
        [_searchBar sizeToFit];
        _searchBar.delayActivity = false;
        __weak TGModernConversationController *weakSelf = self;
        _searchBar.clearPrefix = ^(bool complete) {
            __strong TGModernConversationController *strongSelf = weakSelf;
            if (strongSelf != nil) {
                [strongSelf clearSearchBarPrefix:complete];
            }
        };
        [_view insertSubview:_searchBar aboveSubview:_collectionView];
        
        _searchPanel = [[TGModernConversationSearchInputPanel alloc] init];
        _searchPanel.enableCalendar = [_companion messageSearchByDateAvailable];
        _searchPanel.enableSearchByName = [_companion messageSearchByUserAvailable];
        _searchPanel.next = ^
        {
            __strong TGModernConversationController *strongSelf = weakSelf;
            if (strongSelf != nil)
            {
                if (strongSelf->_searchResultsOffset + 1 < strongSelf->_searchResults.count) {
                    [strongSelf setSearchResultsOffset:strongSelf->_searchResultsOffset + 1 totalCount:strongSelf->_searchResultsTotalCount];
                }
                
                if (strongSelf->_searchResultsOffset + 1 >= strongSelf->_searchResults.count - 5) {
                    if (strongSelf->_searchResults.count < strongSelf->_searchResultsTotalCount && !strongSelf->_loadingMoreSearchResults) {
                        [strongSelf loadMoreSearchResults:false];
                    }
                }
            }
        };
        _searchPanel.previous = ^
        {
            __strong TGModernConversationController *strongSelf = weakSelf;
            if (strongSelf != nil)
            {
                if (strongSelf->_searchResults.count != 0 && strongSelf->_searchResultsOffset > 0)
                    [strongSelf setSearchResultsOffset:strongSelf->_searchResultsOffset - 1 totalCount:strongSelf->_searchResultsTotalCount];
            }
        };
        _searchPanel.done = ^
        {
            __strong TGModernConversationController *strongSelf = weakSelf;
            if (strongSelf != nil)
                [strongSelf searchBarCancelButtonClicked:(UISearchBar *)strongSelf->_searchBar];
        };
        _searchPanel.calendar = ^{
            __strong TGModernConversationController *strongSelf = weakSelf;
            if (strongSelf != nil)
                [strongSelf searchBarCalendarPressed];
        };
        _searchPanel.searchByName = ^{
            __strong TGModernConversationController *strongSelf = weakSelf;
            if (strongSelf != nil)
                [strongSelf searchBarSearchByNamePressed];
        };
        if ([self isAdminLog]) {
            [_searchPanel setNone];
        }
        _searchPanel.delegate = self;
    }
    _searchBar.hidden = false;
    
    [_searchPanel setInProgress:false];
    [_searchPanel setOffset:0 count:0];
    
    [self setCurrentTitlePanel:nil animation:TGModernConversationPanelAnimationSlideFar];
    [self setNavigationBarHidden:true withAnimation:TGViewControllerNavigationBarAnimationSlide];
    _searchBar.userInteractionEnabled = false;
    TGDispatchAfter(0.3, dispatch_get_main_queue(), ^{
        _searchBar.userInteractionEnabled = true;
    });
    TGSearchBar *searchBar = _searchBar;
    [self setCustomInputPanel:_searchPanel force:false setupResponder:^{
        [searchBar becomeFirstResponder];
    }];
}

- (void)setExclusiveSearchQuery:(NSString *)query
{
    __weak TGModernConversationController *weakSelf = self;
    
    _searchPanel = [[TGModernConversationSearchInputPanel alloc] init];
    _searchPanel.enableCalendar = [_companion messageSearchByDateAvailable];
    _searchPanel.enableSearchByName = false;
    _searchPanel.next = ^
    {
        __strong TGModernConversationController *strongSelf = weakSelf;
        if (strongSelf != nil)
        {
            if (strongSelf->_searchResultsOffset + 1 < strongSelf->_searchResults.count) {
                [strongSelf setSearchResultsOffset:strongSelf->_searchResultsOffset + 1 totalCount:strongSelf->_searchResultsTotalCount];
            }
            
            if (strongSelf->_searchResultsOffset + 1 >= strongSelf->_searchResults.count - 5) {
                if (strongSelf->_searchResults.count < strongSelf->_searchResultsTotalCount && !strongSelf->_loadingMoreSearchResults) {
                    [strongSelf loadMoreSearchResults:false];
                }
            }
        }
    };
    _searchPanel.previous = ^
    {
        __strong TGModernConversationController *strongSelf = weakSelf;
        if (strongSelf != nil)
        {
            if (strongSelf->_searchResults.count != 0 && strongSelf->_searchResultsOffset > 0)
                [strongSelf setSearchResultsOffset:strongSelf->_searchResultsOffset - 1 totalCount:strongSelf->_searchResultsTotalCount];
        }
    };
    _searchPanel.done = ^
    {
        __strong TGModernConversationController *strongSelf = weakSelf;
        if (strongSelf != nil)
            [strongSelf searchBarCancelButtonClicked:(UISearchBar *)strongSelf->_searchBar];
    };
    _searchPanel.calendar = ^{
        __strong TGModernConversationController *strongSelf = weakSelf;
        if (strongSelf != nil)
            [strongSelf searchBarCalendarPressed];
    };
    _searchPanel.searchByName = ^{
        __strong TGModernConversationController *strongSelf = weakSelf;
        if (strongSelf != nil)
            [strongSelf searchBarSearchByNamePressed];
    };
    if ([self isAdminLog]) {
        [_searchPanel setNone];
    }
    _searchPanel.delegate = self;
    
    [self setCustomInputPanel:_searchPanel force:false setupResponder:^{}];
    
    [self beginSearchWithQuery:query];
}

- (void)searchBar:(TGSearchBar *)__unused searchBar willChangeHeight:(CGFloat)__unused newHeight
{
}

- (void)searchBarCancelButtonClicked:(UISearchBar *)__unused searchBar
{
    _searchingByName = false;
    _searchingByNameUser = nil;
    _searchResultsTotalCount = 0;
    _searchResults = nil;
    _loadingMoreSearchResults = false;
    [self updateSearchBarPrefix];
    
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
    [self setCurrentTitlePanel:_secondaryTitlePanel animation:TGModernConversationPanelAnimationSlideFar];
}

- (void)searchBarCalendarPressed {
    __weak TGModernConversationController *weakSelf = self;
    _pickerSheet = [[TGPickerSheet alloc] initWithDateSelection:^(NSTimeInterval date) {
        __strong TGModernConversationController *strongSelf = weakSelf;
        if (strongSelf != nil) {
            int64_t peerId = ((TGGenericModernConversationCompanion *)strongSelf->_companion).conversationId;
            [_requestDateJumpDisposable setDisposable:[[TGMessageSearchSignals messageIdForPeerId:peerId date:(int32_t)date] startWithNext:^(NSNumber *nMessageId) {
                __strong TGModernConversationController *strongSelf = weakSelf;
                if (strongSelf != nil) {
                    [strongSelf->_companion navigateToMessageId:[nMessageId intValue] scrollBackMessageId:0 forceUnseenMention:false animated:true];
                }
            }]];
            
        }
    } banTimeout:false];
    _pickerSheet.emptyValue = @"";
    
    if (TGAppDelegateInstance.rootController.currentSizeClass == UIUserInterfaceSizeClassCompact) {
        [_pickerSheet show];
    } else {
        if (_customInputPanel != nil) {
            [_pickerSheet showFromRect:[_customInputPanel convertRect:_customInputPanel.bounds toView:self.view] inView:self.view];
        }
    }
}

- (void)searchBarSearchByNamePressed {
    if (!_searchingByName) {
        _searchingByName = true;
        _searchingByNameUser = nil;
        [self updateSearchBarPrefix];
        _searchPanel.enableSearchByName = false;
        _searchPanel.enableCalendar = false;
    }
}

- (void)updateSearchBarPrefix {
    NSMutableAttributedString *prefix = [[NSMutableAttributedString alloc] init];
    bool displaySuggestionPanel = false;
    if (_searchingByName) {
        [prefix appendAttributedString:[[NSAttributedString alloc] initWithString:TGLocalized(@"Conversation.SearchByName.Prefix") attributes:@{NSFontAttributeName: TGSystemFontOfSize(14.0f), NSForegroundColorAttributeName: self.presentation.pallete.searchBarTextColor}]];
        if (_searchingByNameUser != nil) {
            _searchBar.placeholder = @"";
            [prefix appendAttributedString:[[NSAttributedString alloc] initWithString:[_searchingByNameUser.displayFirstName stringByAppendingString:@" "] attributes:@{NSFontAttributeName: TGSystemFontOfSize(14.0f), NSForegroundColorAttributeName: self.presentation.pallete.accentColor}]];
        } else {
            _searchBar.placeholder = TGLocalized(@"Conversation.SearchByName.Placeholder");
            displaySuggestionPanel = true;
        }
    } else {
        _searchBar.placeholder = [self isAdminLog] ? TGLocalized(@"Common.Search") : TGLocalized(@"Conversation.SearchPlaceholder");
    }
    _searchBar.prefixText = prefix;
    if (displaySuggestionPanel) {
        if (_searchMentionsPanel == nil) {
            _searchMentionsPanel = [[TGModernConversationMentionsAssociatedPanel alloc] init];
            _searchMentionsPanel.pallete = self.presentation.associatedInputPanelPallete;
            _searchMentionsPanel.inverted = true;
            __weak TGModernConversationController *weakSelf = self;
            _searchMentionsPanel.userSelected = ^(TGUser *user) {
                __strong TGModernConversationController *strongSelf = weakSelf;
                if (strongSelf != nil) {
                    if (strongSelf->_searchingByName) {
                        strongSelf->_searchingByNameUser = user;
                        [strongSelf updateSearchBarPrefix];
                        strongSelf->_searchBar.text = @"";
                    }
                }
            };
            
            if (_scrollButtons.superview != nil) {
                [_view insertSubview:_searchMentionsPanel aboveSubview:_scrollButtons];
            } else {
                [_view insertSubview:_searchMentionsPanel aboveSubview:_collectionView];
            }
            
            [self _adjustCollectionInset];
            
            [_searchMentionsPanel setUserListSignal:[_companion userListForMention:@"" canBeContextBot:false includeSelf:true]];
        }
    } else if (_searchMentionsPanel != nil) {
        TGModernConversationMentionsAssociatedPanel *searchMentionsPanel = _searchMentionsPanel;
        __weak TGModernConversationMentionsAssociatedPanel *weakPanel = _searchMentionsPanel;
        _searchMentionsPanel = nil;
        [searchMentionsPanel animateOut:^{
            __strong TGModernConversationMentionsAssociatedPanel *strongPanel = weakPanel;
            [strongPanel removeFromSuperview];
        }];
    }
}

- (void)clearSearchBarPrefix:(bool)complete {
    NSString *updateText = nil;
    if (_searchingByName) {
        if (_searchingByNameUser != nil) {
            if (!complete) {
                updateText = _searchingByNameUser.displayFirstName;
            }
            _searchingByNameUser = nil;
        } else {
            _searchingByName = false;
            _searchPanel.enableSearchByName = [_companion messageSearchByUserAvailable];
            _searchPanel.enableCalendar = [_companion messageSearchByDateAvailable];
        }
    }
    [self updateSearchBarPrefix];
    if (updateText != nil) {
        _searchBar.text = updateText;
    }
}

- (void)beginSearchWithQuery:(NSString *)query
{
    if (_searchDisposable == nil)
        _searchDisposable = [[SMetaDisposable alloc] init];
    
    int32_t queryUserId = 0;
    _searchQuery = query;
    
    if (_searchingByName) {
        _searchPanel.enableSearchByName = false;
        _searchPanel.enableCalendar = false;
        
        if (_searchingByNameUser != nil) {
            queryUserId = _searchingByNameUser.uid;
        } else {
            [_searchMentionsPanel setUserListSignal:[_companion userListForMention:query canBeContextBot:false includeSelf:true]];
            
            return;
        }
    } else {
        if (query.length == 0) {
            _searchPanel.enableSearchByName = [_companion messageSearchByUserAvailable];
            _searchPanel.enableCalendar = [_companion messageSearchByDateAvailable];
        } else {
            _searchPanel.enableSearchByName = false;
            _searchPanel.enableCalendar = false;
        }
    }
    
    bool isAdminLog = [self isAdminLog];
    if (!isAdminLog) {
        _companion.viewContext.searchText = query.length == 0 ? nil : query;
        _companion.viewContext.searchAuthorId = queryUserId;
        for (TGMessageModernConversationItem *item in _items)
        {
            [item updateSearchText:false];
        }
    }
    
    if (isAdminLog) {
        [_searchPanel setNone];
    }
    
    _query = query;
    if (query.length == 0 && queryUserId == 0)
    {
        [_searchDisposable setDisposable:nil];
        [self setSearchResults:nil totalCount:0];
        [_searchPanel setInProgress:false];
        
        if (isAdminLog) {
            [(TGAdminLogConversationCompanion *)_companion updateSearchQuery:_query];
        }
    }
    else
    {
        if (isAdminLog) {
            [(TGAdminLogConversationCompanion *)_companion updateSearchQuery:_query];
        } else {
            [self loadMoreSearchResults:true];
        }
    }
    
    _searchPanel.isSearching = query.length != 0 || (!isAdminLog && queryUserId != 0);
}

- (void)loadMoreSearchResults:(bool)reset {
    if (reset) {
        _searchBar.showActivity = true;
        [_searchPanel setInProgress:true];
        _loadingMoreSearchResults = true;
    }
    
    NSArray *previousResults = reset ? nil : _searchResults;
    
    int32_t maxId = [previousResults.lastObject searchMessageId];
    int32_t maxDate = 0;
    
    __weak TGModernConversationController *weakSelf = self;
    [_searchDisposable setDisposable:[[[[TGGlobalMessageSearchSignals searchMessages:_searchQuery peerId:((TGGenericModernConversationCompanion *)_companion).conversationId accessHash:[_companion requestAccessHash] userId:_searchingByNameUser.uid maxId:maxId limit:reset ? 10 : 50 itemMapping:^id(id item)
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
            NSMutableArray *searchResults = [[NSMutableArray alloc] init];
            [searchResults addObjectsFromArray:previousResults];
            NSUInteger totalCount = 0;
            
            for (TGConversation *conversation in next)
            {
                if (conversation.additionalProperties[@"searchMessageId"] != nil)
                {
                    if (maxId == 0 || conversation.searchMessageId < maxId) {
                        [searchResults addObject:conversation];
                    }
                    if (totalCount == 0) {
                        totalCount = [conversation.additionalProperties[@"totalCount"] intValue];
                    }
                }
            }
            strongSelf->_loadingMoreSearchResults = false;
            [strongSelf setSearchResults:searchResults totalCount:totalCount];
        }
    } error:^(__unused id error)
    {
    } completed:^
    {
    }]];
}

- (void)searchBar:(UISearchBar *)__unused searchBar textDidChange:(NSString *)searchText
{
    [self beginSearchWithQuery:searchText];
}

- (void)setSearchResults:(NSArray *)searchResults totalCount:(NSUInteger)totalCount
{
    bool previousHadResults = _searchResults.count != 0;
    NSNumber *previousId = nil;
    if (_searchResults.count != 0)
        previousId = @([_searchResults[_searchResultsOffset] searchMessageId]);
    
    _searchResults = searchResults;
    _searchResultsTotalCount = MAX(totalCount, searchResults.count);
    
    NSMutableSet *idsSet = [[NSMutableSet alloc] initWithArray:searchResults];
    
    NSUInteger offset = 0;
    
    if (_searchResults.count != 0)
    {
        if (!previousHadResults)
            offset = 0;
        else if (previousId != nil && [idsSet containsObject:previousId])
            offset = [_searchResults indexOfObject:previousId];
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
                            offset = [searchResults indexOfObject:nMid];
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
                            offset = [searchResults indexOfObject:nMid];
                            break;
                        }
                    }
                }
            }
        }
    }
    
    [self setSearchResultsOffset:offset totalCount:_searchResultsTotalCount];
}

- (void)setSearchResultsOffset:(NSUInteger)searchResultsOffset totalCount:(NSUInteger)totalCount
{
    _searchResultsOffset = searchResultsOffset;
    if (_searchResults.count != 0 && _searchResultsOffset < _searchResults.count)
    {
        TGConversation *conversation = _searchResults[_searchResultsOffset];
        if ([self isFeed])
        {
            [(TGFeedConversationCompanion *)_companion navigateToMessageId:conversation.searchMessageId peerId:conversation.conversationId animated:true];
        }
        else
        {
            [_companion navigateToMessageId:conversation.searchMessageId scrollBackMessageId:0 forceUnseenMention:false animated:true];
        }
    }
    
    [_searchPanel setOffset:_searchResultsOffset count:totalCount];
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
            [self registerForPreviewingWithDelegate:(id)self sourceView:_avatarButton];
            [self registerForPreviewingWithDelegate:(id)self sourceView:_collectionView];
        }
    }
}

- (UIViewController *)previewingContext:(id<UIViewControllerPreviewing>)previewingContext viewControllerForLocation:(CGPoint)location
{
    if (self.presentedViewController != nil)
        return nil;
    
    if (self.navigationController != nil && self.navigationController.viewControllers.lastObject != self)
        return nil;
    
    if (_isRecording)
        return nil;
    
    if (previewingContext.sourceView == _avatarButton)
    {
        TGModernGalleryController *modernGallery = [self.companion galleryControllerForAvatar];
        if (modernGallery != nil)
        {
            if (_inputTextPanel.isActive)
                _collectionViewIgnoresNextKeyboardHeightChange = true;
            
            CGFloat side = MIN(self.view.frame.size.width, self.view.frame.size.height);
            modernGallery.preferredContentSize = CGSizeMake(side, side);
            modernGallery.showInterface = false;
            [modernGallery setPreviewMode:true];
            return modernGallery;
        }
    }
    else
    {
        CGPoint collectionPoint = [_collectionView convertPoint:location toView:_collectionView];
        for (TGModernCollectionCell *cell in _collectionView.visibleCells) {
            if (CGRectContainsPoint(cell.frame, collectionPoint)) {
                TGMessageModernConversationItem *item = cell.boundItem;
                TGMessage *message = nil;
                if (item != nil) {
                    message = item->_message;

                    NSString *link = [(TGMessageViewModel *)item.viewModel linkAtPoint:[_collectionView convertPoint:collectionPoint toView:[cell contentViewForBinding]]];
                    if (link.length > 0)
                    {
                        previewingContext.sourceRect = CGRectMake(location.x, location.y, 1.0f, 1.0f);
                        
                        if ([[link lowercaseString] hasPrefix:@"http://"] || [[link lowercaseString] hasPrefix:@"https://"] || [link rangeOfString:@"://"].location == NSNotFound) {
                            NSURL *url = nil;
                            @try {
                                url = [NSURL URLWithString:link];
                            } @catch (NSException *e) {}
                            if (url != nil && [[url.scheme lowercaseString] hasPrefix:@"http"]) {
                                if (_inputTextPanel.isActive)
                                    _collectionViewIgnoresNextKeyboardHeightChange = true;
                                
                                SFSafariViewController *controller = [[SFSafariViewController alloc] initWithURL:url];
                                TGDispatchAfter(0.1, dispatch_get_main_queue(), ^
                                {
                                    [TGPreviewPresentationHelper stylePreviewActionSheet];
                                });
                                
                                return controller;
                            }
                        }
                    }
                    else if ([(TGMessageViewModel *)item.viewModel isPreviewableAtPoint:[_collectionView convertPoint:collectionPoint toView:[cell contentViewForBinding]]])
                    {
                        int32_t mid = message.mid;
                        int64_t peerId = message.fromUid;
                        
                        if ([item.viewModel isKindOfClass:[TGNotificationMessageViewModel class]])
                        {
                            UIView *referenceView = [item referenceViewForImageTransition];
                            previewingContext.sourceRect = [referenceView convertRect:referenceView.bounds toView:_collectionView];
                        }
                        else
                        {
                            CGRect sourceRect = CGRectZero;
                            
                            for (TGModernCollectionCell *cell in _collectionView.visibleCells)
                            {
                                TGMessageModernConversationItem *messageItem = cell.boundItem;
                                if (messageItem != nil && messageItem->_message.mid == mid)
                                {
                                    sourceRect = [[cell contentViewForBinding] convertRect:[messageItem effectiveContentFrame] toView:_view];
                                    break;
                                }
                            }
                            
                            if (!CGRectIsNull(sourceRect) && !CGRectIsEmpty(sourceRect))
                                previewingContext.sourceRect = [_view convertRect:sourceRect toView:_collectionView];
                        }
                        
                        NSArray *actions = nil;
                        
                        UIViewController *controller = [self openMediaFromMessage:mid peerId:peerId instant:false previewMode:true previewActions:&actions cancelPIP:false];
                        if (controller != nil)
                        {
                            if (_inputTextPanel.isActive)
                                _collectionViewIgnoresNextKeyboardHeightChange = true;
                            return controller;
                        }
                        
                        if (message.groupedId == 0)
                            return nil;
                    }
                }
                
                if (message.groupedId == 0)
                    break;
            }
        }
    }
    
    return nil;
}

- (void)previewingContext:(id<UIViewControllerPreviewing>)__unused previewingContext commitViewController:(UIViewController *)viewControllerToCommit
{
    if ([viewControllerToCommit isKindOfClass:[TGModernGalleryController class]])
    {
        TGModernGalleryController *controller = (TGModernGalleryController *)viewControllerToCommit;
        controller.previewMode = false;
        
        TGOverlayControllerWindow *controllerWindow = [[TGOverlayControllerWindow alloc] initWithManager:[[TGLegacyComponentsContext shared] makeOverlayWindowManager] parentController:self contentController:controller];
        controllerWindow.hidden = false;
    }
    else if ([viewControllerToCommit isKindOfClass:[SFSafariViewController class]])
    {
        [self presentViewController:viewControllerToCommit animated:true completion:nil];
    }
    else
    {
        if ([viewControllerToCommit isKindOfClass:[TGLocationViewController class]])
            ((TGLocationViewController *)viewControllerToCommit).previewMode = false;
        
        [self.navigationController pushViewController:viewControllerToCommit animated:true];
    }
}

- (NSArray<id<UIPreviewActionItem>> * _Nonnull)previewActionItems {
    if ([self isSavedMessages] || [self isFeed])
        return @[];
    
    __weak TGModernConversationController *weakSelf = self;
    int64_t peerId = ((TGGenericModernConversationCompanion *)_companion).conversationId;
    
    UIPreviewAction *thumbAction = [UIPreviewAction actionWithTitle:@"👍" style:UIPreviewActionStyleDefault handler:^(__unused UIPreviewAction * _Nonnull action, __unused UIViewController * _Nonnull previewViewController) {
        [[TGSendMessageSignals sendTextMessageWithPeerId:peerId text:@"👍" replyToMid:0] startWithNext:nil error: nil completed: ^ {
        }];
    }];
    
    NSNumber *muteUntil = nil;
    [TGDatabaseInstance() loadPeerNotificationSettings:peerId soundId:NULL muteUntil:&muteUntil previewText:NULL messagesMuted:NULL notFound:NULL];
    if (muteUntil == nil)
    {
        int64_t defaultPeerId = TGPeerIdIsUser(peerId) ? INT_MAX - 1 : INT_MAX - 2;
        [TGDatabaseInstance() loadPeerNotificationSettings:defaultPeerId soundId:NULL muteUntil:&muteUntil previewText:NULL messagesMuted:NULL notFound:NULL];
    }
    
    UIPreviewAction *muteAction = [UIPreviewAction actionWithTitle:TGPeerIdIsChannel(peerId) ? TGLocalized(@"Conversation.Mute") :TGLocalized(@"Notification.Mute1h") style:UIPreviewActionStyleDefault handler:^(__unused UIPreviewAction * _Nonnull action, __unused UIViewController * _Nonnull previewViewController) {
        __strong TGModernConversationController *strongSelf = weakSelf;
        if (strongSelf != nil) {
            NSNumber *muteUntil = nil;
            [TGDatabaseInstance() loadPeerNotificationSettings:peerId soundId:NULL muteUntil:&muteUntil previewText:NULL messagesMuted:NULL notFound:NULL];
            
            int muteTime = TGPeerIdIsChannel(peerId) ? INT32_MAX : 1 * 60 * 60;
            muteUntil = @(TGPeerIdIsChannel(peerId) ? INT32_MAX : MAX(muteUntil.intValue, (int)[[TGTelegramNetworking instance] approximateRemoteTime] + muteTime));
            
            static int actionId = 0;
            
            void (^muteBlock)(int64_t, NSNumber *, NSNumber *) = ^(int64_t peerId, NSNumber *muteUntil, NSNumber *accessHash)
            {
                NSMutableDictionary *options = [NSMutableDictionary dictionaryWithDictionary:@{ @"peerId": @(peerId), @"muteUntil": muteUntil }];
                if (accessHash != nil)
                    options[@"accessHash"] = accessHash;
                
                [ActionStageInstance() requestActor:[NSString stringWithFormat:@"/tg/changePeerSettings/(%" PRId64 ")/(muteAction%d)", peerId, actionId++] options:options watcher:TGTelegraphInstance];
            };
            
            if (TGPeerIdIsChannel(peerId))
            {
                [[[TGDatabaseInstance() existingChannel:peerId] take:1] startWithNext:^(TGConversation *channel)
                {
                    muteBlock(peerId, muteUntil, @(channel.accessHash));
                }];
            }
            else
            {
                muteBlock(peerId, muteUntil, nil);
            }
        }
    }];
    
    UIPreviewAction *unmuteAction = [UIPreviewAction actionWithTitle:TGLocalized(@"Conversation.Unmute") style:UIPreviewActionStyleDefault handler:^(__unused UIPreviewAction * _Nonnull action, __unused UIViewController * _Nonnull previewViewController) {
        __strong TGModernConversationController *strongSelf = weakSelf;
        if (strongSelf != nil) {
            NSNumber *muteUntil = 0;
            [TGDatabaseInstance() loadPeerNotificationSettings:peerId soundId:NULL muteUntil:&muteUntil previewText:NULL messagesMuted:NULL notFound:NULL];
            
            muteUntil = @0;
            
            static int actionId = 0;
            
            void (^muteBlock)(int64_t, NSNumber *, NSNumber *) = ^(int64_t peerId, NSNumber *muteUntil, NSNumber *accessHash)
            {
                NSMutableDictionary *options = [NSMutableDictionary dictionaryWithDictionary:@{ @"peerId": @(peerId), @"muteUntil": muteUntil }];
                if (accessHash != nil)
                    options[@"accessHash"] = accessHash;
                
                [ActionStageInstance() requestActor:[NSString stringWithFormat:@"/tg/changePeerSettings/(%" PRId64 ")/(muteAction%d)", peerId, actionId++] options:options watcher:TGTelegraphInstance];
            };
            
            if (TGPeerIdIsChannel(peerId))
            {
                [[[TGDatabaseInstance() existingChannel:peerId] take:1] startWithNext:^(TGConversation *channel)
                {
                    muteBlock(peerId, muteUntil, @(channel.accessHash));
                }];
            }
            else
            {
                muteBlock(peerId, muteUntil, nil);
            }
        }
    }];
    
    NSMutableArray *actions = [[NSMutableArray alloc] init];
    
    if (!TGPeerIdIsChannel(peerId) && !TGPeerIdIsGroup(peerId)) {
        [actions addObject:thumbAction];
    }
    
    if (muteUntil.intValue <= [[TGTelegramNetworking instance] approximateRemoteTime]) {
        [actions addObject:muteAction];
    } else {
        [actions addObject:unmuteAction];
    }
    
    return actions;
}

- (void)forwardMessages:(NSArray *)messageIndices fastForward:(bool)fastForward grouped:(bool)grouped {
    [self endEditing];
    
    if (fastForward)
    {
        SSignal *linkSignal = nil;
        
        NSString *fixedSharedLink = nil;
        bool isGame = false;
        bool isRoundMessage = false;
        NSString *invoiceStartParam = nil;
        
        TGWebAppControllerShareGameData *shareGameData = nil;
        
        TGMessage *message = nil;
        TGMessageIndex *messageIndex = messageIndices.firstObject;
        if (messageIndex != nil) {
            for (TGMessageModernConversationItem *item in _items) {
                if (item->_message.mid == messageIndex.messageId && item->_message.cid == messageIndex.peerId) {
                    message = item->_message;
                    break;
                }
            }
            
            TGUser *botUser = nil;
            NSString *shareName = nil;
            for (id attachment in message.mediaAttachments) {
                if ([attachment isKindOfClass:[TGGameMediaAttachment class]]) {
                    isGame = true;
                    shareName = ((TGGameMediaAttachment *)attachment).shortName;
                } else if ([attachment isKindOfClass:[TGViaUserAttachment class]]) {
                    botUser = [TGDatabaseInstance() loadUser:((TGViaUserAttachment *)attachment).userId];
                } else if ([attachment isKindOfClass:[TGInvoiceMediaAttachment class]]) {
                    invoiceStartParam = ((TGInvoiceMediaAttachment *)attachment).invoiceStartParam;
                } else if ([attachment isKindOfClass:[TGVideoMediaAttachment class]]) {
                    isRoundMessage = ((TGVideoMediaAttachment *)attachment).roundMessage;
                }
            }
            if (botUser == nil) {
                TGUser *user = [TGDatabaseInstance() loadUser:(int32_t)message.fromUid];
                if (user.kind == TGUserKindBot || user.kind == TGUserKindSmartBot) {
                    botUser = user;
                }
            }
            
            if (botUser != nil && invoiceStartParam != nil) {
                fixedSharedLink = [NSString stringWithFormat:@"https://t.me/%@?start=%@", botUser.userName, invoiceStartParam];
            } else {
                if (botUser != nil && isGame) {
                    shareGameData = [[TGWebAppControllerShareGameData alloc] initWithPeerId:((TGGenericModernConversationCompanion *)_companion).conversationId messageId:messageIndex.messageId botName:botUser.userName shareName:shareName];
                }
                
                if (botUser != nil && shareName != nil && botUser.userName.length != 0) {
                    fixedSharedLink = [NSString stringWithFormat:@"https://t.me/%@?game=%@", botUser.userName, shareName];
                }
            }
        }
        
        if (fixedSharedLink != nil) {
            linkSignal = [SSignal single:fixedSharedLink];
        } else if ([_companion canCreateLinksToMessages]) {
            SVariable *sharedLink = [[SVariable alloc] init];
            TGConversation *conversation = [TGDatabaseInstance() loadConversationWithId:message.cid];
            if (conversation.username.length > 0)
            {
                [sharedLink set:[[TGMessageSearchSignals shareLinkForChannelMessage:conversation.conversationId accessHash:conversation.accessHash messageId:message.mid grouped:message.groupedId != 0] catch:^SSignal *(__unused id error) {
                    return [SSignal single:nil];
                }]];
                linkSignal = [[sharedLink.signal take:1] deliverOn:[SQueue mainQueue]];
            }
        }
        
        CGRect (^sourceRect)(void) = ^CGRect
        {
            return [self sourceRectForMessageId:messageIndex.messageId peerId:messageIndex.peerId];
        };
        
        NSString *actionButtonTitle = TGLocalized(@"ShareMenu.CopyShareLink");
        if (isGame)
            actionButtonTitle = TGLocalized(@"ShareMenu.CopyShareLinkGame");
        else if (isRoundMessage)
            actionButtonTitle = TGLocalized(@"Web.OpenExternal");
        SSignal *externalSignal = [linkSignal map:^NSURL *(NSString *linkString)
        {
            return [NSURL URLWithString:linkString];
        }];
        
        if ((!_isChannel || ![_companion canCreateLinksToMessages] || linkSignal == nil) && fixedSharedLink == nil)
        {
            actionButtonTitle = nil;
            externalSignal = nil;
        }
        
        __weak TGModernConversationController *weakSelf = self;
        _menuController = [TGShareMenu presentInParentController:self menuController:nil buttonTitle:actionButtonTitle buttonAction:^
        {
            if (messageIndices.count == 0)
                return;
            
            TGProgressWindow *progressWindow = [[TGProgressWindow alloc] init];
            [progressWindow showWithDelay:0.2];
            
            [[linkSignal onDispose:^
            {
                [progressWindow dismiss:true];
            }] startWithNext:^(id next)
            {
                if (next != nil) {
                    if (isRoundMessage) {
                        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:next]];
                        [progressWindow dismiss:false];
                    } else {
                        [[UIPasteboard generalPasteboard] setString:next];
                        [progressWindow dismissWithSuccess];
                    }
                }
            }];
        } shareAction:^(NSArray *peerIds, NSString *caption)
        {
            __strong TGModernConversationController *strongSelf = weakSelf;
            if (strongSelf == nil)
                return;
            
            if (shareGameData != nil) {
                TGProgressWindow *progressWindow = [[TGProgressWindow alloc] init];
                [progressWindow showWithDelay:0.1];
                
                NSMutableArray *signals = [[NSMutableArray alloc] init];
                for (NSNumber *nPeerId in peerIds) {
                    [signals addObject:[TGBotSignals shareBotGame:shareGameData.peerId messageId:shareGameData.messageId toPeerId:[nPeerId int64Value] withScore:false]];
                }
                
                NSMutableArray *captionSignals = [[NSMutableArray alloc] init];
                if (caption.length != 0) {
                    for (NSNumber *peerIdVal in peerIds)
                    {
                        int64_t peerId = peerIdVal.int64Value;
                        SSignal *signal = [TGSendMessageSignals sendTextMessageWithPeerId:peerId text:caption replyToMid:0];
                        [captionSignals addObject:signal];
                    }
                }
                
                SSignal *combined = [[SSignal combineSignals:signals] then:[SSignal combineSignals:captionSignals]];
                
                [[[combined deliverOn:[SQueue mainQueue]] onDispose:^{
                    TGDispatchOnMainThread(^{
                        [progressWindow dismiss:true];
                    });
                }] startWithNext:nil error:nil completed:^{
                    [progressWindow dismissWithSuccess];
                }];
            } else {
                [strongSelf broadcastForwardMessages:messageIndices caption:caption toPeerIds:peerIds grouped:grouped];
            }
            
            [[[TGProgressWindow alloc] init] dismissWithSuccess];
        } externalShareItemSignal:externalSignal sourceView:_view sourceRect:sourceRect barButtonItem:nil];
    } else {
        [_companion controllerWantsToForwardMessages:messageIndices];
    }
}

- (void)broadcastForwardMessages:(NSArray<TGMessageIndex *> *)messageIndices caption:(NSString *)caption toPeerIds:(NSArray<NSNumber *> *)peerIds grouped:(bool)grouped {
    int64_t peerId = [messageIndices.firstObject peerId];
    int64_t accessHash = [TGDatabaseInstance() loadConversationWithId:peerId].accessHash;
    
    NSMutableArray *messageIds = [[NSMutableArray alloc] init];
    for (TGMessageIndex *messageIndex in messageIndices) {
        [messageIds addObject:@(messageIndex.messageId)];
    }
    
    SSignal *signal = [TGSendMessageSignals forwardMessagesWithMessageIds:messageIds toPeerIds:peerIds fromPeerId:peerId fromPeerAccessHash:accessHash grouped:grouped];
    if (caption.length != 0) {
        signal = [[TGSendMessageSignals broadcastMessageWithText:caption toPeerIds:peerIds] then:signal];
    }
    [signal startWithNext:nil];
}

- (void)setLoadingMessages:(bool)loadingMessages {
    _loadingMessages = loadingMessages;
    if (loadingMessages) {
        if (_loadingMessagesController == nil) {
            _loadingMessagesController = [[TGProgressWindowController alloc] init];
            _loadingMessagesController.view.frame = self.view.bounds;
            _loadingMessagesController.view.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
            [_loadingMessagesController show:false];
            [self.view addSubview:_loadingMessagesController.view];
        }
        /*if (_loadingMessagesIndicator == nil) {
         _loadingMessagesIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
         _loadingMessagesIndicator.frame = CGRectMake(CGFloor((self.view.frame.size.width - _loadingMessagesIndicator.frame.size.width) / 2.0f), CGFloor((self.view.frame.size.height - _loadingMessagesIndicator.frame.size.height) / 2.0f), _loadingMessagesIndicator.frame.size.width, _loadingMessagesIndicator.frame.size.height);
         _loadingMessagesIndicator.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin;
         [self.view addSubview:_loadingMessagesIndicator];
         [_loadingMessagesIndicator startAnimating];
         }*/
        
        _snapshotImageView.hidden = true;
        _collectionView.hidden = true;
        _snapshotBackgroundView.hidden = true;
    } else {
        _snapshotImageView.hidden = false;
        _collectionView.hidden = false;
        _snapshotBackgroundView.hidden = false;
        
        if (_loadingMessagesController != nil) {
            __weak UIView *loadingView = _loadingMessagesController.view;
            [_loadingMessagesController dismiss:true completion:^{
                __strong UIView *strongView = loadingView;
                if (strongView != nil) {
                    [strongView removeFromSuperview];
                }
            }];
            _loadingMessagesController = nil;
        }
        
        /*if (_loadingMessagesIndicator != nil) {
         [_loadingMessagesIndicator stopAnimating];
         [_loadingMessagesIndicator removeFromSuperview];
         _loadingMessagesIndicator = nil;
         }*/
    }
}

- (void)maybeDisplayGifTooltip {
    if (iosMajorVersion() < 8 || TGIsPad() || _isChannel) {
        return;
    }
    
    if ([self hasNonTextInputPanel]) {
        return;
    }
    
    NSString *key = @"TG_displayedGifsTooltip_v0";
    __block bool displayed = [[[NSUserDefaults standardUserDefaults] objectForKey:key] boolValue];
    if (!displayed) {
        __weak TGModernConversationController *weakSelf = self;
        if (_recentGifsDisposable == nil) {
            _recentGifsDisposable = [[SMetaDisposable alloc] init];
        }
        
        [_recentGifsDisposable setDisposable:[[[TGRecentGifsSignal recentGifs] deliverOn:[SQueue mainQueue]] startWithNext:^(NSArray *recentGifs) {
            if (displayed) {
                return;
            }
            
            __strong TGModernConversationController *strongSelf = weakSelf;
            if (strongSelf != nil) {
                if (recentGifs.count != 0) {
                    [[NSUserDefaults standardUserDefaults] setObject:@true forKey:key];
                    displayed = true;
                    
                    if (strongSelf->_tooltipContainerView == nil && [strongSelf->_inputTextPanel stickerButtonFrame].size.width > FLT_EPSILON)
                    {
                        strongSelf->_tooltipContainerView = [[TGMenuContainerView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, strongSelf.view.frame.size.width, strongSelf.view.frame.size.height)];
                        [strongSelf.view addSubview:strongSelf->_tooltipContainerView];
                        
                        NSMutableArray *actions = [[NSMutableArray alloc] init];
                        [actions addObject:[[NSDictionary alloc] initWithObjectsAndKeys:TGLocalized(@"Conversation.GifTooltip"), @"title", nil]];
                        
                        [strongSelf->_tooltipContainerView.menuView setButtonsAndActions:actions watcherHandle:nil];
                        [strongSelf->_tooltipContainerView.menuView sizeToFit];
                        strongSelf->_tooltipContainerView.menuView.userInteractionEnabled = false;
                        CGRect titleLockIconViewFrame = [strongSelf->_inputTextPanel convertRect:[strongSelf->_inputTextPanel stickerButtonFrame] toView:strongSelf->_tooltipContainerView];
                        titleLockIconViewFrame.origin.y += 12.0f;
                        [strongSelf->_tooltipContainerView showMenuFromRect:titleLockIconViewFrame animated:false];
                    }
                }
            }
        }]];
    }
}

- (void)setPrimaryExtendedPanel:(TGModernConversationAssociatedInputPanel *)panel animated:(bool)animated skipHeightAnimation:(bool)skipHeightAnimation {
    [_inputTextPanel setPrimaryExtendedPanel:panel animated:animated skipHeightAnimation:skipHeightAnimation];
    if (_currentInputPanel != _inputTextPanel && _currentInputPanel != nil && [_currentInputPanel respondsToSelector:@selector(setPrimaryExtendedPanel:animated:skipHeightAnimation:)]) {
        if ([panel isKindOfClass:[TGModernConversationForwardInputPanel class]]) {
            panel = nil;
        }
        [(TGModernConversationInputTextPanel *)_currentInputPanel setPrimaryExtendedPanel:panel animated:animated skipHeightAnimation:skipHeightAnimation];
    }
}

- (void)setPrimaryExtendedPanel:(TGModernConversationAssociatedInputPanel *)panel animated:(bool)animated {
    [self setPrimaryExtendedPanel:panel animated:animated skipHeightAnimation:false];
}

- (void)setSecondaryExtendedPanel:(TGModernConversationAssociatedInputPanel *)panel animated:(bool)animated skipHeightAnimation:(bool)skipHeightAnimation {
    [_inputTextPanel setSecondaryExtendedPanel:panel animated:animated];
    if (_currentInputPanel != _inputTextPanel && _currentInputPanel != nil && [_currentInputPanel respondsToSelector:@selector(setSecondaryExtendedPanel:animated:skipHeightAnimation:)]) {
        [(TGModernConversationInputTextPanel *)_currentInputPanel setSecondaryExtendedPanel:panel animated:animated skipHeightAnimation:skipHeightAnimation];
    }
}

- (void)setSecondaryExtendedPanel:(TGModernConversationAssociatedInputPanel *)panel animated:(bool)animated {
    [self setSecondaryExtendedPanel:panel animated:animated skipHeightAnimation:false];
}

- (void)scrollConversationUp
{
    CGFloat newOffset = MIN(_collectionView.contentSize.height + _collectionView.contentInset.bottom - _collectionView.bounds.size.height, _collectionView.contentOffset.y + 75.0f);
    [_collectionView setContentOffset:CGPointMake(0, newOffset)];
}

- (void)scrollConversationDown
{
    CGFloat newOffset = MAX(-_collectionView.contentInset.top, _collectionView.contentOffset.y - 75.0f);
    [_collectionView setContentOffset:CGPointMake(0, newOffset)];
}

- (void)selectPreviousSuggestion
{
    [[_inputTextPanel associatedPanel] selectPreviousItem];
}

- (void)selectNextSuggestion
{
    [[_inputTextPanel associatedPanel] selectNextItem];
}

- (bool)canEditLastMessage
{
    TGMessageModernConversationItem *messageItem = _items.firstObject;
    return messageItem != nil && [_companion canEditMessage:messageItem->_message] && _inputTextPanel.messageEditingContext == nil && _inputTextPanel.maybeInputField.text.length == 0 && _inputTextPanel.associatedPanel == nil;
}

- (void)processKeyCommand:(UIKeyCommand *)keyCommand
{
    if ([keyCommand.input isEqualToString:@"\r"])
    {
        if (_inputTextPanel.maybeInputField.isFirstResponder)
        {
            if ([_inputTextPanel associatedPanel] != nil && [[_inputTextPanel associatedPanel] hasSelectedItem])
                [[_inputTextPanel associatedPanel] commitSelectedItem];
            else if ([_inputTextPanel.maybeInputField.text hasNonWhitespaceCharacters])
                [self inputPanelRequestedSendMessage:_inputTextPanel text:_inputTextPanel.inputField.text];
        }
        else
        {
            [self openKeyboard];
        }
    }
    else if ([keyCommand.input isEqualToString:@"/"])
    {
        if (keyCommand.modifierFlags & UIKeyModifierCommand)
            [_inputTextPanel showStickersPanel];
        else
            [_inputTextPanel startCommand];
    }
    else if ([keyCommand.input isEqualToString:@"2"] && keyCommand.modifierFlags & UIKeyModifierShift)
    {
        [_inputTextPanel startMention];
    }
    else if ([keyCommand.input isEqualToString:@"3"] && keyCommand.modifierFlags & UIKeyModifierShift)
    {
        [_inputTextPanel startHashtag];
    }
    else if ([keyCommand.input isEqualToString:UIKeyInputUpArrow])
    {
        if (keyCommand.modifierFlags & UIKeyModifierShift)
        {
            [self scrollConversationUp];
        }
        else
        {
            if ([_inputTextPanel associatedPanel])
            {
                [self selectPreviousSuggestion];
            }
            else if ([self canEditLastMessage])
            {
                TGMessageModernConversationItem *messageItem = _items.firstObject;
                _currentEditingMessageContext = [[SVariable alloc] init];
                [_currentEditingMessageContext set:[_companion editingContextForMessageWithId:messageItem->_message.mid]];
                
                bool isCaption = false;
                NSString *messageText = nil;
                if (messageItem->_message.caption.length != 0)
                {
                    messageText = messageItem->_message.caption;
                    isCaption = true;
                }
                else if (messageItem->_message.text.length != 0)
                {
                    messageText = messageItem->_message.text;
                }
                
                NSArray *messageEntities = messageItem->_message.entities;
                
                if (_editingContextDisposable == nil) {
                    _editingContextDisposable = [[SMetaDisposable alloc] init];
                }
                
                __strong TGModernConversationController *strongSelf = self;
                if (strongSelf != nil) {
                    [self setEditMessageWithText:messageText entities:messageEntities messageId:messageItem->_message.mid animated:true];
                    if (_currentInputPanel == _inputTextPanel && messageItem->_message.replyMarkup.rows.count == 0) {
                        [self openKeyboard];
                    }
                }
            }
        }
    }
    else if ([keyCommand.input isEqualToString:UIKeyInputDownArrow])
    {
        if (keyCommand.modifierFlags & UIKeyModifierShift)
            [self scrollConversationDown];
        else
            [self selectNextSuggestion];
    }
    else if ([keyCommand.input isEqualToString:@"I"])
    {
        if (self.associatedPopoverController != nil && [self.associatedPopoverController isKindOfClass:[TGPopoverController class]] && [self.associatedPopoverController.contentViewController isKindOfClass:[TGNavigationController class]] && [((TGNavigationController *)self.associatedPopoverController.contentViewController).viewControllers.firstObject isKindOfClass:[TGCollectionMenuController class]])
        {
            [self.associatedPopoverController dismissPopoverAnimated:true];
            if ([self.associatedPopoverController.delegate respondsToSelector:@selector(popoverControllerDidDismissPopover:)])
                [self.associatedPopoverController.delegate popoverControllerDidDismissPopover:self.associatedPopoverController];
        }
        else
        {
            [self infoButtonPressed];
        }
    }
    else if ([keyCommand.input isEqualToString:@"W"])
    {
        if (self.associatedPopoverController != nil)
        {
            [self.associatedPopoverController dismissPopoverAnimated:true];
            if ([self.associatedPopoverController.delegate respondsToSelector:@selector(popoverControllerDidDismissPopover:)])
                [self.associatedPopoverController.delegate popoverControllerDidDismissPopover:self.associatedPopoverController];
        }
        else if (_menuController != nil)
        {
            [_menuController dismissAnimated:true];
        }
        else
        {
            [self closeButtonPressed];
        }
    }
    else if ([keyCommand.input isEqualToString:UIKeyInputEscape] || [keyCommand.input isEqualToString:@"\t"])
    {
        [self endMessageEditing:true];
    }
}

- (NSArray *)availableKeyCommands
{
    NSMutableArray *commands = [[NSMutableArray alloc] init];
    
    if (!_inputTextPanel.maybeInputField.isFirstResponder)
    {
        TGKeyCommand *focusKeyCommand = [TGKeyCommand keyCommandWithTitle:TGLocalized(@"KeyCommand.FocusOnInputField") input:@"\r" modifierFlags:0];
        if (![TGAppDelegateInstance.keyCommandController isKeyCommandOccupied:focusKeyCommand])
        {
            [commands addObject:focusKeyCommand];
            [commands addObject:[TGKeyCommand keyCommandWithTitle:nil input:@"/" modifierFlags:0]];
            [commands addObject:[TGKeyCommand keyCommandWithTitle:nil input:@"2" modifierFlags:UIKeyModifierShift]];
            [commands addObject:[TGKeyCommand keyCommandWithTitle:nil input:@"3" modifierFlags:UIKeyModifierShift]];
        }
        
        if ([self canEditLastMessage])
            [commands addObject:[TGKeyCommand keyCommandWithTitle:nil input:UIKeyInputUpArrow modifierFlags:0]];
    }
    else
    {
        [commands addObject:[TGKeyCommand keyCommandWithTitle:TGLocalized(@"KeyCommand.SendMessage") input:@"\r" modifierFlags:0]];
        
        if ([_inputTextPanel associatedPanel] != nil)
        {
            [commands addObject:[TGKeyCommand keyCommandWithTitle:nil input:UIKeyInputUpArrow modifierFlags:0]];
            [commands addObject:[TGKeyCommand keyCommandWithTitle:nil input:UIKeyInputDownArrow modifierFlags:0]];
        }
        else if ([self canEditLastMessage])
        {
            [commands addObject:[TGKeyCommand keyCommandWithTitle:nil input:UIKeyInputUpArrow modifierFlags:0]];
        }
        
        if (_inputTextPanel.messageEditingContext != nil)
        {
            [commands addObject:[TGKeyCommand keyCommandWithTitle:nil input:UIKeyInputEscape modifierFlags:0]];
            [commands addObject:[TGKeyCommand keyCommandWithTitle:nil input:@"\t" modifierFlags:0]];
        }
    }
    
    [commands addObject:[TGKeyCommand keyCommandWithTitle:nil input:@"/" modifierFlags:UIKeyModifierCommand]];
    
    [commands addObject:[TGKeyCommand keyCommandWithTitle:TGLocalized(@"KeyCommand.ScrollUp") input:UIKeyInputUpArrow modifierFlags:UIKeyModifierShift]];
    [commands addObject:[TGKeyCommand keyCommandWithTitle:TGLocalized(@"KeyCommand.ScrollDown") input:UIKeyInputDownArrow modifierFlags:UIKeyModifierShift]];
    [commands addObject:[TGKeyCommand keyCommandWithTitle:TGLocalized(@"KeyCommand.ChatInfo") input:@"I" modifierFlags:UIKeyModifierControl | UIKeyModifierCommand]];
    [commands addObject:[TGKeyCommand keyCommandWithTitle:nil input:@"W" modifierFlags:UIKeyModifierCommand]];
    
    return commands;
}

- (void)messageEditingCancelPressed {
    [self endMessageEditing:true];
}

- (void)messagesDeleted:(NSArray *)messageIds {
    NSMutableSet *set = [[NSMutableSet alloc] initWithArray:messageIds];
    if (_inputTextPanel.messageEditingContext != nil && [set containsObject:@(_inputTextPanel.messageEditingContext.messageId)]) {
        [self endMessageEditing:true];
    }
}

- (void)_showModerateSheetForMessageIndices:(NSArray *)messageIndices author:(TGUser *)author {
    __weak TGModernConversationController *weakSelf = self;
    _shareSheetWindow = [[TGShareSheetWindow alloc] init];
    _shareSheetWindow.dismissalBlock = ^
    {
        __strong TGModernConversationController *strongSelf = weakSelf;
        if (strongSelf == nil)
            return;
        
        strongSelf->_shareSheetWindow.rootViewController = nil;
        strongSelf->_shareSheetWindow = nil;
    };
    
    NSArray *actions = @[@(TGMessageModerateActionDelete), @(TGMessageModerateActionBan), @(TGMessageModerateActionReport), @(TGMessageModerateActionDeleteAll)];
    NSMutableSet *selectedActions = [[NSMutableSet alloc] init];
    [selectedActions addObject:@(TGMessageModerateActionDelete)];
    
    NSMutableArray *items = [[NSMutableArray alloc] init];
    
    TGShareSheetButtonItemView *actionItem = [[TGShareSheetButtonItemView alloc] initWithTitle:TGLocalized(@"Common.Done") pressed:^ {
        __strong TGModernConversationController *strongSelf = weakSelf;
        if (strongSelf != nil) {
            [strongSelf->_shareSheetWindow dismissAnimated:true completion:nil];
            strongSelf->_shareSheetWindow = nil;
            
            if (selectedActions.count != 0) {
                NSMutableArray *messageIds = [[NSMutableArray alloc] init];
                for (TGMessageIndex *messageIndex in messageIndices) {
                    [messageIds addObject:@(messageIndex.messageId)];
                }
                [strongSelf _applyModerateMessageActions:selectedActions messageIds:messageIds];
            }
        }
    }];
    
    void (^updateCheckedTypes)() = ^{
        [actionItem setEnabled:selectedActions.count != 0];
    };
    
    updateCheckedTypes();
    
    TGUser *user = author;
    
    NSArray *typeTitles = @[
                            (messageIndices.count == 1 ? TGLocalized(@"Conversation.Moderate.Delete") : TGLocalized(@"Conversation.DeleteManyMessages")),
                            TGLocalized(@"Conversation.Moderate.Ban"),
                            TGLocalized(@"Conversation.Moderate.Report"),
                            [NSString stringWithFormat:TGLocalized(@"Conversation.Moderate.DeleteAllMessages"), user.displayName]
                            ];
    
    NSInteger index = -1;
    for (NSString *title in typeTitles) {
        index++;
        TGAttachmentSheetCheckmarkVariantItemView *itemView = [[TGAttachmentSheetCheckmarkVariantItemView alloc] initWithTitle:title variant:nil checked:index == 0];
        itemView.onCheckedChanged = ^(bool value) {
            if (value) {
                [selectedActions addObject:actions[index]];
            } else {
                [selectedActions removeObject:actions[index]];
            }
            updateCheckedTypes();
        };
        [items addObject:itemView];
    }
    
    [items addObject:actionItem];
    
    _shareSheetWindow.view.cancel = ^{
        __strong TGModernConversationController *strongSelf = weakSelf;
        if (strongSelf != nil) {
            [strongSelf->_shareSheetWindow dismissAnimated:true completion:nil];
            strongSelf->_shareSheetWindow = nil;
        }
    };
    
    _shareSheetWindow.view.items = items;
    [_shareSheetWindow showAnimated:true completion:nil];
}

- (void)_applyModerateMessageActions:(NSSet *)actions messageIds:(NSArray *)messageIds {
    TGProgressWindow *progressWindow = [[TGProgressWindow alloc] init];
    [progressWindow showWithDelay:0.2];
    [[[[_companion applyModerateMessageActions:actions messageIds:messageIds] deliverOn:[SQueue mainQueue]] onDispose:^{
        [progressWindow dismiss:true];
    }] startWithNext:nil error:^(__unused id error) {
        
    } completed:nil];
    [self leaveEditingMode];
}

- (void)pushEarliestUnreadMessageId:(int32_t)messageId {
    [_scrollStack pushMessageId:messageId];
}

- (void)incrementScrollDownUnreadCount:(NSInteger)count {
    if (_scrollButtons.superview != nil && _scrollButtons.displayDownButton) {
        _scrollButtons.unreadMessageCount += (int32_t)count;
    }
}

- (void)_updateItemForReplySwipeInteraction:(int32_t)mid ended:(bool)ended
{
    for (TGModernCollectionCell *cell in _collectionView.visibleCells)
    {
        if ([cell.boundItem isKindOfClass:[TGMessageModernConversationItem class]] && ((TGMessageModernConversationItem *)cell.boundItem)->_message.mid == mid)
            [(TGMessageModernConversationItem *)cell.boundItem updateReplySwipeInteraction:_viewStorage ended:ended];
    }
}


- (void)_updateGroupedItemsForReplySwipeInteraction:(int32_t)mid groupedId:(int64_t)groupedId offset:(CGFloat)offset ended:(bool)ended
{
    NSMutableArray *itemsToUpdate = [[NSMutableArray alloc] init];
    
    TGMessageModernConversationItem *mainItem = nil;
    for (TGModernCollectionCell *cell in _collectionView.visibleCells)
    {
        if (![cell.boundItem isKindOfClass:[TGMessageModernConversationItem class]])
            continue;
        
        TGMessageModernConversationItem *messageItem = (TGMessageModernConversationItem *)cell.boundItem;
        if (messageItem->_message.groupedId == groupedId)
        {
            if (messageItem->_message.mid == mid)
                mainItem = messageItem;
        
            [itemsToUpdate addObject:messageItem];
        }
    }
    
    for (TGMessageModernConversationItem *messageItem in itemsToUpdate)
    {
        if (messageItem != mainItem)
            [messageItem setExplicitReplyPanOffset:offset ended:ended];
    }
}

- (SSignal *)messageVisiblitySignalForMessageId:(int32_t)messageId peerId:(int64_t)peerId
{
    TGMessageIndex *currentPair = [TGMessageIndex indexWithPeerId:peerId messageId:messageId];
    SSignal *initialSignal = [[SSignal alloc] initWithGenerator:^id<SDisposable>(SSubscriber *subscriber)
    {
        bool found = false;
        for (TGModernCollectionCell *cell in _collectionView.visibleCells)
        {
            TGMessageModernConversationItem *messageItem = cell.boundItem;
            if (messageItem != nil && messageItem->_message.mid == messageId && (peerId == 0 || messageItem->_message.fromUid == peerId))
            {
                found = true;
                break;
            }
        }
        
        [subscriber putNext:@{ @"type": found ? @"bind" : @"unbind", @"pair": currentPair }];
        [subscriber putCompletion];
        
        return nil;
    }];
    
    SSignal *viewVisibleSignal = _viewVisible.signal;
    SSignal *signal = [[SSignal alloc] initWithGenerator:^id<SDisposable>(SSubscriber *subscriber)
    {
        return [viewVisibleSignal startWithNext:^(id next)
        {
            if (next == nil)
            {
                [subscriber putNext:@false];
                [subscriber putCompletion];
            }
            else
            {
                [subscriber putNext:next];
            }
        }];
    }];
    
    SSignal *scrollingToMessageSignal = [[[SSignal alloc] initWithGenerator:^id<SDisposable>(SSubscriber *subscriber)
    {
        TGDispatchOnMainThread(^
        {
            [subscriber putNext:@(_scrollToMid != nil)];
            [subscriber putCompletion];
        });
        
        return nil;
    }] startOn:[SQueue concurrentDefaultQueue]];
    
    __weak TGModernConversationController *weakSelf = self;
    return [signal mapToSignal:^SSignal *(NSNumber *value)
    {
        __strong TGModernConversationController *strongSelf = weakSelf;
        if (strongSelf == nil)
            return [SSignal single:@false];
        
        if (value.boolValue)
        {
            SSignal *bindingSignal = [[[initialSignal then:strongSelf->_bindingPipe.signalProducer()] filter:^bool(NSDictionary *value)
            {
                return [value[@"pair"] isEqual:currentPair];
            }] mapToSignal:^SSignal *(NSDictionary *value)
            {
                if ([value[@"type"] isEqualToString:@"bind"])
                    return [strongSelf messageVisibleInViewportSignal:messageId peerId:peerId once:false wholeVisible:false];
                else
                    return [SSignal single:@false];
            }];
            
            return [scrollingToMessageSignal mapToSignal:^SSignal *(NSNumber *value)
            {
                if (value.boolValue)
                {
                    return [[[strongSelf->_scrollToFinishedPipe.signalProducer() take:1] mapToSignal:^SSignal *(id)
                    {
                        return [SSignal complete];
                    }] then:bindingSignal];
                }
                else
                {
                    return bindingSignal;
                }
            }];
        }
        else
        {
            return [SSignal single:@false];
        }
    }];
}

- (SSignal *)messageVisibleInViewportSignal:(int32_t)messageId peerId:(int64_t)peerId once:(bool)once wholeVisible:(bool)wholeVisible
{
    if (!once)
        _positionMonitoredForMessageWithMid = [TGMessageIndex indexWithPeerId:peerId messageId:messageId];
    
    __weak TGModernConversationController *weakSelf = self;
    return [[[SSignal alloc] initWithGenerator:^id<SDisposable>(SSubscriber *subscriber)
    {
        __strong TGModernConversationController *strongSelf = weakSelf;
        if (strongSelf != nil)
        {
            bool found = false;
            
            if (strongSelf->_scrollToMid == nil)
            {
                for (TGModernCollectionCell *cell in strongSelf->_collectionView.visibleCells)
                {
                    TGMessageModernConversationItem *messageItem = cell.boundItem;
                    if (messageItem != nil && messageItem->_message.mid == messageId && (peerId == 0 || messageItem->_message.fromUid == peerId))
                    {
                        found = true;
                        CGRect rect = [strongSelf->_collectionView convertRect:cell.frame toView:strongSelf.view];
                        
                        TGNavigationController *navController = (TGNavigationController *)strongSelf.navigationController;
                        bool visible = false;
                        
                        CGFloat topLimit = CGRectGetMaxY(navController.navigationBar.frame) + navController.currentAdditionalNavigationBarHeight;
                        CGFloat bottomLimit = strongSelf->_currentInputPanel.frame.origin.y;
                        if (wholeVisible)
                            visible = CGRectGetMinY(rect) > topLimit && CGRectGetMaxY(rect) < bottomLimit;
                        else
                            visible = CGRectGetMaxY(rect) > topLimit && CGRectGetMinY(rect) < bottomLimit;
                        
                        [subscriber putNext:@(visible)];
                        if (visible)
                        {
                            [[SQueue concurrentDefaultQueue] dispatch:^
                            {
                                TGDispatchOnMainThread(^
                                {
                                    [messageItem updateMessageVisibility];
                                });
                            }];
                        }
                        
                        break;
                    }
                }
            }
            else
            {
                found = true;
            }
            
            if (!once)
            {
                strongSelf->_visibilityChanged = ^(bool visible)
                {
                    [subscriber putNext:@(visible)];
                };
            }
            
            if (!found)
                [subscriber putNext:@(false)];
        }
        
        return [[SBlockDisposable alloc] initWithBlock:^
        {
            if (!once)
            {
                __strong TGModernConversationController *strongSelf = weakSelf;
                strongSelf->_positionMonitoredForMessageWithMid = nil;
                strongSelf->_visibilityChanged = nil;
            }
        }];
    }] ignoreRepeated];
}

- (void)updateFeaturesAvailability
{
    [_inputTextPanel setVideoMessageAvailable:[_companion allowVideoMessages]];
}

- (void)searchPressed {
    [self activateSearch];
}

- (void)setBannedStickers:(bool)bannedStickers {
    _bannedStickers = bannedStickers;
    _inputTextPanel.stickerButton.fadeDisabled = _bannedStickers;
}

- (void)setBannedMedia:(bool)bannedMedia {
    _bannedMedia = bannedMedia;
    _inputTextPanel.micButton.fadeDisabled = _bannedMedia;
}

- (void)backPressed {
    [self.navigationController popViewControllerAnimated:true];
}

- (void)endEditing
{
    [_inputTextPanel endEditing:true];
    [_inputTextPanel prepareForResultPreviewDismissal:false];
    [_searchBar endEditing:true];
}

- (void)setTitleView:(UIView *)titleView
{
    _titleView = nil;
    [super setTitleView:titleView];
}

- (bool)isSavedMessages
{
    return [self peerId] == TGTelegraphInstance.clientUserId;
}

- (bool)isAdminLog
{
    return [self.companion isKindOfClass:[TGAdminLogConversationCompanion class]];
}

- (bool)isFeed
{
    return [self.companion isKindOfClass:[TGFeedConversationCompanion class]];
}

- (BOOL)prefersStatusBarHidden
{
    return [self.navigationController prefersStatusBarHidden];
}

- (CGFloat)initialUnreadOffset
{
    if ([TGViewController hasTallScreen])
        return 108.0f;
    
    return 0.0f;
}

- (void)showNext
{
    int32_t maxVisibleMessageId = 0;
    int64_t maxVisiblePeerId = 0;
    int32_t date = 0;
    for (TGModernCollectionCell *cell in _collectionView.visibleCells)
    {
        TGMessageModernConversationItem *messageItem = cell.boundItem;
        if (messageItem != nil)
        {
            if (messageItem->_message.date > date)
            {
                date = (int32_t)messageItem->_message.date;
                maxVisibleMessageId = messageItem->_message.mid;
                maxVisiblePeerId = messageItem->_message.fromUid;
            }
        }
    }
    
    CGFloat contentOffset = [self contentOffsetForMessageId:maxVisibleMessageId peerId:maxVisiblePeerId scrollPosition:TGInitialScrollPositionTop initial:false additionalOffset:0.0f];
    //if (ABS(contentOffset - _collectionView.contentOffset.y) > FLT_EPSILON)
    [_collectionView setContentOffset:CGPointMake(0.0f, contentOffset) animated:true];
}

- (void)setSecondaryController:(TGViewController *)controller
{
    if (controller == nil)
    {
        [_secondaryController.view removeFromSuperview];
        [_secondaryController removeFromParentViewController];
        _secondaryController = nil;
    }
    
    _secondaryController = controller;
    if (controller != nil)
    {
        [self addChildViewController:controller];
        [_view insertSubview:controller.view belowSubview:_currentInputPanel];
    }
    
    if (controller != nil)
    {
        [self setRightBarButtonItem:[[UIBarButtonItem alloc] initWithTitle:TGLocalized(@"Common.Edit") style:UIBarButtonItemStylePlain target:self action:@selector(avatarPressed)] animated:true];
    }
    else
    {
        [self setRightBarButtonItem:[self defaultRightBarButtonItem] animated:true];
    }
}

@end
