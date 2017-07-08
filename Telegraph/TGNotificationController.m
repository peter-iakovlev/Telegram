#import "TGNotificationController.h"
#import "TGOverlayControllerWindow.h"

#import <objc/runtime.h>
#import <AVFoundation/AVFoundation.h>

#import "TGOverlayController.h"
#import "TGMenuSheetController.h"
#import "TGModernGalleryContainerView.h"
#import "TGPickerSheet.h"
#import "TGSingleStickerPreviewWindow.h"
#import "TGModernConversationController.h"
#import "TGWebAppController.h"
#import "TGGenericModernConversationCompanion.h"
#import <SafariServices/SafariServices.h>

#import "TGNotificationOverlayView.h"
#import "TGNotificationView.h"

#import "ActionStage.h"

#import "TGAppDelegate.h"
#import "TGTelegraph.h"
#import "TGConversation.h"
#import "TGDatabase.h"
#import "TGPeerIdAdapter.h"

#import "TGRemoteImageView.h"
#import "TGDownloadManager.h"

#import "TGSendMessageSignals.h"
#import "TGChatMessageListSignal.h"
#import "TGRecentHashtagsSignal.h"
#import "TGConversationSignals.h"
#import "TGChatMessageListSignal.h"
#import "TGStickersSignals.h"
#import "TGStickerAssociation.h"

#import "TGMediaStoreContext.h"
#import "TGPreparedRemoteImageMessage.h"
#import "TGPreparedLocalDocumentMessage.h"
#import "TGModernConversationAudioPlayer.h"

#import "TGMessageViewedContentProperty.h"

#import "TGGenericPeerPlaylistSignals.h"
#import "TGInstantPageController.h"

const NSTimeInterval TGNotificationTimerInterval = 0.5;
const NSUInteger TGNotificationInterItemDelay = 2;
const NSUInteger TGNotificationInterItemDelayAfterHide = 1;
const NSUInteger TGNotificationExpandedTimeout = 60;

@interface TGNotificationWindow : UIWindow

@property (nonatomic, copy) bool (^pointInside)(CGPoint);

- (instancetype)initWithFrame:(CGRect)frame overInAppBrowser:(bool)overInAppBrowser;

@end

@interface TGNotificationWindowViewController : TGOverlayWindowViewController

@end

@interface TGNotificationItem : NSObject

@property (nonatomic, readonly) int32_t identifier;
@property (nonatomic, readonly) int64_t conversationId;
@property (nonatomic, readonly) int32_t replyToMid;
@property (nonatomic, readonly) NSTimeInterval duration;
@property (nonatomic, readonly) bool isChannelGroup;
@property (nonatomic, copy) void (^configure)(TGNotificationContentView *, bool *);

- (instancetype)initWithConversation:(TGConversation *)conversation identifier:(int32_t)identifier replyToMid:(int32_t)replyToMid duration:(NSTimeInterval)duration configure:(void (^)(TGNotificationContentView *, bool *))configure;

@end

@interface TGNotificationController () <ASWatcher, TGModernConversationAudioPlayerDelegate>
{
    TGNotificationItem *_currentItem;
    NSMutableArray *_queue;
    
    STimer *_timer;
    NSUInteger _ticksToTransition;
 
    TGModernConversationAudioPlayer *_currentAudioPlayer;
    int32_t _currentAudioPlayerMessageId;
    
    TGNotificationWindow *_window;
    TGNotificationOverlayView *_overlayView;
}

@property (nonatomic, readonly) TGNotificationView *notificationView;
@property (nonatomic, strong) ASHandle *actionHandle;

@property (nonatomic, readonly) UIView *wrapperView;

@end

@implementation TGNotificationController

- (instancetype)init
{
    self = [super init];
    if (self != nil)
    {
        _actionHandle = [[ASHandle alloc] initWithDelegate:self];

        self.autoManageStatusBarBackground = false;
    
        _queue = [[NSMutableArray alloc] init];
        
        [ActionStageInstance() watchForPaths:@
        [
         @"downloadManagerStateChanged",
         @"/as/media/imageThumbnailUpdated"
        ] watcher:self];
    }
    return self;
}

- (void)dealloc
{
    [_actionHandle reset];
    [ActionStageInstance() removeWatcher:self];
}

- (UIWindow *)notificationWindow
{
    if (_window == nil)
    {
        _window = [[TGNotificationWindow alloc] initWithFrame:TGAppDelegateInstance.rootController.applicationBounds overInAppBrowser:[TGAppDelegateInstance.rootController.presentedViewController isKindOfClass:[SFSafariViewController class]]];
        _window.tag = 0xbeef;
        _window.rootViewController = self;
        
        __weak TGNotificationController *weakSelf = self;
        _window.pointInside = ^bool(CGPoint point)
        {
            __strong TGNotificationController *strongSelf = weakSelf;
            if (strongSelf == nil)
                return false;
            
            bool pointInsideView = CGRectContainsPoint(strongSelf->_notificationView.frame, point);
            bool pointInsideOverlay = CGRectContainsPoint(strongSelf->_overlayView.frame, point) && !strongSelf->_overlayView.hidden;
            
            return pointInsideView || pointInsideOverlay;
        };
    }
    
    return _window;
}

- (BOOL)shouldAutorotate
{
    return true;
}

- (void)removeWindow
{
    _window.rootViewController = nil;
    
    _window.hidden = true;
    _window = nil;
}

- (void)loadView
{
    [super loadView];
    object_setClass(self.view, [TGModernGalleryContainerView class]);
    
    self.view.frame = (CGRect){self.view.frame.origin, TGAppDelegateInstance.rootController.applicationBounds.size};
    
    _wrapperView = [[UIView alloc] initWithFrame:self.view.bounds];
    _wrapperView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    [self.view addSubview:_wrapperView];
    
    CGFloat side = MAX(self.view.bounds.size.width, self.view.bounds.size.height) * 2;
    
    _overlayView = [[TGNotificationOverlayView alloc] initWithFrame:CGRectMake((self.view.frame.size.width - side) / 2, (self.view.frame.size.height - side) / 2, side, side)];
    _overlayView.hidden = true;
    [_overlayView addTarget:self action:@selector(overlayPressed) forControlEvents:UIControlEventTouchUpInside];
    [_wrapperView addSubview:_overlayView];
    
    __weak TGNotificationController *weakSelf = self;
    _notificationView = [[TGNotificationView alloc] initWithFrame:CGRectMake(0, 0, 0, TGNotificationDefaultHeight)];
    _notificationView.sendTextMessage = ^(NSString *text)
    {
        __strong TGNotificationController *strongSelf = weakSelf;
        if (strongSelf == nil)
            return;
        
        [TGRecentHashtagsSignal addRecentHashtagsFromText:text space:TGHashtagSpaceEntered];
        
        [[[TGSendMessageSignals sendTextMessageWithPeerId:strongSelf->_currentItem.conversationId text:text replyToMid:strongSelf->_currentItem.replyToMid] then:[TGChatMessageListSignal readChatMessageListWithPeerId:strongSelf->_currentItem.conversationId]] startWithNext:nil];
    };
    _notificationView.sendSticker = ^(TGDocumentMediaAttachment *sticker)
    {
        __strong TGNotificationController *strongSelf = weakSelf;
        if (strongSelf == nil)
            return;
        
        [[[TGSendMessageSignals sendRemoteDocumentWithPeerId:strongSelf->_currentItem.conversationId replyToMid:strongSelf->_currentItem.replyToMid documentAttachment:sticker] then:[TGChatMessageListSignal readChatMessageListWithPeerId:strongSelf->_currentItem.conversationId]] startWithNext:nil];
    };
    _notificationView.onTap = ^
    {
        __strong TGNotificationController *strongSelf = weakSelf;
        if (strongSelf != nil && strongSelf->_navigateToConversation != nil)
            strongSelf->_navigateToConversation(strongSelf->_currentItem.conversationId);
    };
    _notificationView.onExpand = ^
    {
        __strong TGNotificationController *strongSelf = weakSelf;
        if (strongSelf == nil)
            return;
        
        [strongSelf.notificationWindow makeKeyWindow];
        
        strongSelf->_ticksToTransition = TGNotificationExpandedTimeout;
    };
    _notificationView.onExpandProgress = ^(CGFloat progress)
    {
        __strong TGNotificationController *strongSelf = weakSelf;
        if (strongSelf == nil)
            return;
        
        strongSelf->_overlayView.hidden = (progress < FLT_EPSILON);
        strongSelf->_overlayView.alpha = progress;
    };
    _notificationView.shouldExpandOnTap = ^bool
    {
        __strong TGNotificationController *strongSelf = weakSelf;
        if (strongSelf == nil)
            return false;

        return [strongSelf shouldExpandOnTap];
    };
    _notificationView.hide = ^(bool animated)
    {
        __strong TGNotificationController *strongSelf = weakSelf;
        if (strongSelf == nil)
            return;
        
        [strongSelf hideAnimated:animated];
    };
    _notificationView.parentController = ^TGViewController *
    {
        __strong TGNotificationController *strongSelf = weakSelf;
        return strongSelf;
    };
    _notificationView.userListSignal = ^SSignal *(NSString *mention)
    {
        __strong TGNotificationController *strongSelf = weakSelf;
        if (strongSelf == nil)
            return nil;
        
        return [strongSelf userListForConversationId:strongSelf->_currentItem.conversationId channelGroup:strongSelf->_currentItem.isChannelGroup mention:mention];
    };
    _notificationView.hashtagListSignal = ^SSignal *(NSString *hashtag)
    {
        __strong TGNotificationController *strongSelf = weakSelf;
        if (strongSelf == nil)
            return nil;
        
        return [strongSelf hashtagListForHashtag:hashtag];
    };
    _notificationView.stickersSignal = ^SSignal *(NSString *emoji)
    {
        __strong TGNotificationController *strongSelf = weakSelf;
        if (strongSelf == nil)
            return nil;
        
        return [strongSelf stickersListForEmoji:emoji];
    };
    _notificationView.requestMedia = ^id (TGMediaAttachment *attachment, int64_t cid, int32_t mid)
    {
        __strong TGNotificationController *strongSelf = weakSelf;
        if (strongSelf == nil)
            return nil;
        
        return [strongSelf _downloadMediaWithAttachment:attachment conversationId:cid messageId:mid];
    };
    _notificationView.cancelMedia = ^(id mediaId)
    {
        __strong TGNotificationController *strongSelf = weakSelf;
        if (strongSelf == nil)
            return;
        
        [strongSelf _cancelMediaWithId:mediaId];
    };
    _notificationView.playMedia = ^(TGMediaAttachment *attachment, int64_t cid, int32_t mid)
    {
        __strong TGNotificationController *strongSelf = weakSelf;
        if (strongSelf == nil)
            return;
        
        [strongSelf _playAudioWithAttachment:attachment peerId:cid messageId:mid];
    };
    _notificationView.isMediaAvailable = ^bool(TGMediaAttachment *attachment)
    {
        __strong TGNotificationController *strongSelf = weakSelf;
        if (strongSelf == nil)
            return false;
        
        return [strongSelf _isMediaAvailable:attachment];
    };
    _notificationView.mediaContext = ^TGModernViewInlineMediaContext *(__unused int64_t cid, int32_t mid)
    {
        __strong TGNotificationController *strongSelf = weakSelf;
        if (strongSelf == nil)
            return nil;
        
        return [strongSelf _inlineMediaContext:mid];
    };
    [_wrapperView addSubview:_notificationView];
}

- (void)displayNotificationForConversation:(TGConversation *)conversation identifier:(int32_t)identifier replyToMid:(int32_t)replyToMid duration:(NSTimeInterval)duration configure:(void (^)(TGNotificationContentView *view, bool *isRepliable))configure
{    
    if (_currentItem.identifier == identifier)
        return;
    
    for (TGNotificationItem *item in _queue)
    {
        if (item.identifier == identifier)
            return;
    }
    
    TGNotificationItem *item = [[TGNotificationItem alloc] initWithConversation:conversation identifier:identifier replyToMid:replyToMid duration:duration configure:configure];
    [_queue addObject:item];
    
    if (_notificationView.isPresented)
    {
        if (!_notificationView.isExpanded)
            _ticksToTransition = MIN(_ticksToTransition, TGNotificationInterItemDelay);
    }
    else
    {
        _ticksToTransition = (NSInteger)(duration / TGNotificationTimerInterval);
        [self showNextItem];
    }
}

- (void)dismissNotificationsForConversationId:(int64_t)conversationId
{
    NSMutableIndexSet *itemsToRemove = [[NSMutableIndexSet alloc] init];
    [_queue enumerateObjectsUsingBlock:^(TGNotificationItem *item, NSUInteger index, __unused BOOL *stop)
    {
        if (item.conversationId == conversationId)
            [itemsToRemove addIndex:index];
    }];
    [_queue removeObjectsAtIndexes:itemsToRemove];
 
    if (_currentItem.conversationId == conversationId)
        [self showNextItem];
}

- (void)dismissAllNotifications
{
    [_queue removeAllObjects];
    
    [self showNextItem];
}

#pragma mark -

- (bool)shouldExpandOnTap
{
    bool hasModalController = (TGAppDelegateInstance.rootController.presentedViewController != nil);
    if (hasModalController)
        return true;
    
    bool hasOverlayController = false;
    bool hasPlayerController = false;
    bool hasWebAppController = false;
    bool hasInstanPageController = false;
    for (UIWindow *window in [UIApplication sharedApplication].windows)
    {
        if ([window isKindOfClass:[TGOverlayControllerWindow class]] && window != _window)
        {
            TGOverlayController *overlayController = (TGOverlayController *)window.rootViewController;
            if (overlayController.isImportant)
            {
                hasOverlayController = true;
                break;
            }
            else
            {
                for (TGViewController *viewController in overlayController.childViewControllers)
                {
                    if ([viewController isKindOfClass:[TGOverlayController class]])
                    {
                        TGOverlayController *overlayController = (TGOverlayController *)viewController;
                        if (overlayController.isImportant)
                        {
                            hasOverlayController = true;
                            break;
                        }
                    }
                }
            }
        }
        else if (iosMajorVersion() >= 8 && [window isMemberOfClass:[UIWindow class]])
        {
            for (UIView *view in window.rootViewController.view.subviews)
            {
                if ([NSStringFromClass([view class]) hasPrefix:@"AVPlayer"])
                {
                    hasPlayerController = true;
                    break;
                }
            }
        }
        else if (iosMajorVersion() <= 7)
        {
            for (UIView *view in window.subviews)
            {
                if ([NSStringFromClass([view class]) hasPrefix:@"MP"])
                {
                    hasPlayerController = true;
                    break;
                }
            }
        }
    }
    
    for (TGViewController *controller in TGAppDelegateInstance.rootController.viewControllers)
    {
        if ([controller isKindOfClass:[TGWebAppController class]])
        {
            hasWebAppController = true;
            break;
        }
        else if ([controller isKindOfClass:[TGInstantPageController class]]) {
            hasInstanPageController = true;
            break;
        }
    }
    
    if (hasOverlayController || hasPlayerController || hasWebAppController || hasInstanPageController)
        return true;
    
    return false;
}

- (bool)shouldDisplayNotificationForConversation:(TGConversation *)conversation
{
    bool shouldDisplay = true;
    
    bool hasExistingConversationController = false;
    TGModernConversationController *existingConversationController = nil;
    TGGenericModernConversationCompanion *existingConversationCompanion = nil;
    
    for (UIViewController *viewController in TGAppDelegateInstance.rootController.viewControllers)
    {
        if ([viewController isKindOfClass:[TGModernConversationController class]])
        {
            existingConversationController = (TGModernConversationController *)viewController;
            existingConversationCompanion = (TGGenericModernConversationCompanion *)existingConversationController.companion;

            NSArray *viewControllers = TGAppDelegateInstance.rootController.viewControllers;
            TGViewController *lastController = viewControllers.lastObject;
            if ([lastController isKindOfClass:[TGMenuSheetController class]] && viewControllers.count > 2)
                lastController = TGAppDelegateInstance.rootController.viewControllers[viewControllers.count - 2];

            if (existingConversationCompanion.conversationId == conversation.conversationId && lastController == viewController)
            {
                hasExistingConversationController = true;
                break;
            }
        }
    }
    
    bool hasModalController = (TGAppDelegateInstance.rootController.presentedViewController != nil && TGAppDelegateInstance.rootController.currentSizeClass == UIUserInterfaceSizeClassCompact);
    bool hasOverlayController = false;
    bool hasPlayerController = false;
    for (UIWindow *window in [UIApplication sharedApplication].windows)
    {
        if ([window isKindOfClass:[TGOverlayControllerWindow class]] && ![window isKindOfClass:[TGSingleStickerPreviewWindow class]] && window.rootViewController != nil && window != _window)
        {
            if (![window.rootViewController isKindOfClass:[TGPickerSheetOverlayController class]])
            {
                hasOverlayController = true;
                break;
            }
        }
        else if (iosMajorVersion() >= 8 && [window isMemberOfClass:[UIWindow class]])
        {
            for (UIView *view in window.rootViewController.view.subviews)
            {
                if ([NSStringFromClass([view class]) hasPrefix:@"AVPlayer"])
                {
                    hasPlayerController = true;
                    break;
                }
            }
        }
        else if (iosMajorVersion() <= 7)
        {
            for (UIView *view in window.subviews)
            {
                if ([NSStringFromClass([view class]) hasPrefix:@"MP"])
                {
                    hasPlayerController = true;
                    break;
                }
            }
        }
    }
    
    if (hasExistingConversationController && (!hasModalController && !hasOverlayController && !hasPlayerController))
        shouldDisplay = false;
    
    return shouldDisplay;
}

- (void)expandCurrentNotification
{
    
}

#pragma mark -

- (void)overlayPressed
{
    if (!_notificationView.isPresented || !_notificationView.isExpanded || _notificationView.hasUnsavedData || _notificationView.isInteracting)
        return;
    
    [self hideAnimated:true];
}

#pragma mark -

- (void)showNextItem
{
    if (_queue.count == 0)
    {
        [self hideAnimated:true];
        return;
    }
    
    TGNotificationItem *item = _queue.firstObject;
    _currentItem = item;
    [_queue removeObjectAtIndex:0];
    
    bool isRepliable = false;
    bool isPresented = _notificationView.isPresented;
    if (!isPresented)
    {
        if (![self isViewLoaded])
            [self loadView];
        
        item.configure(_notificationView.contentView, &isRepliable);
        [self _presentNotificationView];
    }
    else
    {
        [_notificationView prepareInterItemTransitionView];
        [_notificationView.contentView reset];
        item.configure(_notificationView.contentView, &isRepliable);
        [_notificationView playInterItemTransition];
    }
    
    _notificationView.isRepliable = isRepliable;
    _overlayView.isTransparent = !isRepliable;
    
    [_notificationView updateHandleViewAnimated:isPresented];
}

- (void)hideAnimated:(bool)animated
{
    [self hideAnimated:animated completion:nil];
}

- (void)hideAnimated:(bool)animated completion:(void (^)(void))completion
{
    _currentItem = nil;
    
    _notificationView.isHiding = true;
    [_notificationView prepareForHide];
    
    [self _updateStatusBarHiding:false];
    
    void (^changeBlock)(void) = ^
    {
        _notificationView.frame = CGRectOffset(_notificationView.frame, 0, -_notificationView.frame.size.height);
        _overlayView.alpha = 0.0f;
    };
    void (^finishBlock)(BOOL) = ^(__unused BOOL finished)
    {
        _notificationView.isPresented = false;
        [self removeWindow];

        _overlayView.hidden = true;
        
        [_notificationView reset];
        
        if (_queue.count == 0)
            [self _stopTimer];
        else
            _ticksToTransition = TGNotificationInterItemDelayAfterHide;
        
        if (completion != nil)
            completion();
    };
    
    if (animated)
    {
        [UIView animateWithDuration:0.25 delay:0.0 options:(6 << 16 | UIViewAnimationOptionLayoutSubviews) animations:changeBlock completion:finishBlock];
    }
    else
    {
        changeBlock();
        finishBlock(true);
    }
}

- (void)_presentNotificationView
{
    _notificationView.isHiding = false;
    self.notificationWindow.hidden = false;
    
    [self _startTimer];
    
    _notificationView.isPresented = true;
    _notificationView.frame = CGRectMake(0, -TGNotificationDefaultHeight, _wrapperView.frame.size.width, TGNotificationDefaultHeight);
    
    [UIView animateWithDuration:0.35 delay:0.0 options:UIViewAnimationOptionCurveEaseInOut animations:^
    {
        _notificationView.frame = CGRectMake(0, 0, _notificationView.frame.size.width, _notificationView.frame.size.height);
    } completion:^(__unused BOOL finished)
    {

        
        if (iosMajorVersion() > 8)
        {
            [self _updateStatusBarHiding:true];
        }
        else
        {
            //fix ios8 crash
            dispatch_async(dispatch_get_main_queue(), ^
            {
                [self _updateStatusBarHiding:true];
            });
        }
    }];
}

#pragma mark -

- (void)_startTimer
{
    [self _stopTimer];
    
    __weak TGNotificationController *weakSelf = self;
    _timer = [[STimer alloc] initWithTimeout:TGNotificationTimerInterval repeat:true completion:^
    {
        __strong TGNotificationController *strongSelf = weakSelf;
        if (strongSelf == nil)
            return;
        
        if (strongSelf->_notificationView.isExpanded)
        {
            if (!strongSelf->_notificationView.isIdle)
            {
                strongSelf->_ticksToTransition = TGNotificationExpandedTimeout;
                return;
            }
        }
        else if (strongSelf->_notificationView.isInteracting)
        {
            TGNotificationItem *currentItem = strongSelf->_currentItem;
            strongSelf->_ticksToTransition = (NSInteger)(currentItem.duration / TGNotificationTimerInterval);
            return;
        }
        
        strongSelf->_ticksToTransition--;
        if (strongSelf->_ticksToTransition > 0)
            return;
        
        if (strongSelf->_notificationView.isExpanded)
        {
            [strongSelf hideAnimated:true];
        }
        else
        {
            if (strongSelf->_queue.count == 1)
            {
                TGNotificationItem *lastItem = strongSelf->_queue.firstObject;
                strongSelf->_ticksToTransition = (NSInteger)(lastItem.duration / TGNotificationTimerInterval);
            }
            else
            {
                strongSelf->_ticksToTransition = TGNotificationInterItemDelay;
            }
            [strongSelf showNextItem];
        }
    } queue:[SQueue mainQueue]];
    [_timer start];
}

- (void)_stopTimer
{
    [_timer invalidate];
    _timer = nil;
}

- (void)localizationUpdated
{
    [_notificationView localizationUpdated];
}

- (void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    [super willAnimateRotationToInterfaceOrientation:toInterfaceOrientation duration:duration];
 
    bool shouldShrink = ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPhone && UIInterfaceOrientationIsLandscape(toInterfaceOrientation));
    
    CGFloat height = _notificationView.isExpanded && !shouldShrink ? [_notificationView expandedHeight] : [_notificationView shrinkedHeight];
    _notificationView.frame = CGRectMake(0, _notificationView.frame.origin.y, _wrapperView.frame.size.width, height);
    [_notificationView setShrinked:shouldShrink];
}

- (void)viewWillLayoutSubviews
{
    [super viewWillLayoutSubviews];
    
    _overlayView.center = self.view.center;
    _notificationView.frame = CGRectMake(0, _notificationView.frame.origin.y, _wrapperView.frame.size.width, _notificationView.frame.size.height);
}

- (UIWindow *)window
{
    return _window;
}

- (void)_updateStatusBarHiding:(bool)__unused hiding
{
    if (iosMajorVersion() < 8 || (iosMajorVersion() == 8 && iosMinorVersion() < 1))
        return;
    
    [[UIApplication sharedApplication].keyWindow.rootViewController setNeedsStatusBarAppearanceUpdate];
}

#pragma mark -

- (SSignal *)userListForConversationId:(int64_t)conversationId channelGroup:(bool)channelGroup mention:(NSString *)mention
{
    if (!TGPeerIdIsGroup(conversationId) && !channelGroup)
        return [SSignal single:@[]];
    
    NSString *normalizedMention = [mention lowercaseString];

    SSignal *participantsSignal = channelGroup ? [[TGDatabaseInstance() channelCachedData:conversationId] map:^id(TGCachedConversationData *data)
    {
        NSMutableArray *chatParticipantsUids = [[NSMutableArray alloc] init];
        for (TGCachedConversationMember *member in data.generalMembers)
            [chatParticipantsUids addObject:@(member.uid)];
        return chatParticipantsUids;
    }] : [[[TGConversationSignals conversationWithPeerId:conversationId] filter:^bool(TGConversation *conversation)
    {
        return (conversation.chatParticipants != nil);
    }] map:^NSArray *(TGConversation *conversation)
    {
        return conversation.chatParticipants.chatParticipantUids;
    }];
    
    return [[[participantsSignal take:1] mapToSignal:^SSignal *(NSArray *chatParticipantUids)
    {
        NSMutableDictionary *userDict = [[NSMutableDictionary alloc] init];
        for (NSNumber *nUid in chatParticipantUids)
        {
            TGUser *user = [TGDatabaseInstance() loadUser:[nUid intValue]];
            if (user != nil && user.uid != TGTelegraphInstance.clientUserId && user.userName.length != 0 && (normalizedMention.length == 0 || [[user.userName lowercaseString] hasPrefix:normalizedMention]))
            {
                userDict[@(user.uid)] = user;
            }
        }
        
        return [[[TGChatMessageListSignal chatMessageListViewWithPeerId:conversationId atMessageId:0 rangeMessageCount:16] take:1] map:^NSArray *(TGChatMessageListView *messageListView)
        {
            NSMutableArray *sortedUserList = [[NSMutableArray alloc] init];
            for (TGMessage *message in messageListView.messages)
            {
                int32_t uid = (int32_t)message.fromUid;
                TGUser *user = userDict[@(uid)];
 
                if (user != nil)
                {
                    [sortedUserList addObject:user];
                    [userDict removeObjectForKey:@(uid)];
                    if (userDict.count == 0)
                        break;
                }
            }
            
            NSArray *sortedRemainingUsers = [[userDict allValues] sortedArrayUsingComparator:^NSComparisonResult(TGUser *user1, TGUser *user2)
            {
                return [user1.displayName compare:user2.displayName];
            }];
            
            [sortedUserList addObjectsFromArray:sortedRemainingUsers];
            
            return sortedUserList;
        }];
    }] deliverOn:[SQueue mainQueue]];
}

- (SSignal *)hashtagListForHashtag:(NSString *)hashtag
{
    return [[TGRecentHashtagsSignal recentHashtagsFromSpaces:TGHashtagSpaceEntered | TGHashtagSpaceSearchedBy] map:^id (NSArray *recentHashtags)
    {
        if (hashtag.length == 0)
            return recentHashtags;
        
        NSMutableArray *filteredHashtags = [[NSMutableArray alloc] init];
        for (NSString *listHashtag in recentHashtags)
        {
            if ([listHashtag hasPrefix:hashtag])
                [filteredHashtags addObject:listHashtag];
        }
        
        return filteredHashtags;
    }];
}

- (SSignal *)stickersListForEmoji:(NSString *)emoji
{
    return [[[[[TGStickersSignals stickerPacks] filter:^bool(NSDictionary *dict)
    {
        return ((NSArray *)dict[@"packs"]).count != 0;
    }] take:1] mapToSignal:^SSignal *(NSDictionary *dict)
    {
        NSMutableArray *matchedDocuments = [[NSMutableArray alloc] init];
        NSMutableDictionary *associations = [[NSMutableDictionary alloc] init];
        
        NSArray *sortedStickerPacks = dict[@"packs"];
        
        for (TGStickerPack *stickerPack in sortedStickerPacks)
        {
            NSMutableArray *documentIds = [[NSMutableArray alloc] init];
            for (TGStickerAssociation *association in stickerPack.stickerAssociations)
            {
                if ([association.key isEqual:emoji])
                {
                    [documentIds addObjectsFromArray:association.documentIds];
                    for (NSNumber *documentId in association.documentIds)
                        associations[documentId] = stickerPack.stickerAssociations;
                }
            }
            
            for (NSNumber *nDocumentId in documentIds)
            {
                for (TGDocumentMediaAttachment *document in stickerPack.documents)
                {
                    if (document.documentId == [nDocumentId longLongValue])
                    {
                        [matchedDocuments addObject:document];
                        break;
                    }
                }
            }
        }
        
        return [TGStickersSignals preloadedStickerPreviews:@{ @"documents": matchedDocuments, @"associations": associations } count:6];
    }] deliverOn:[SQueue mainQueue]];
}

#pragma mark - Media

- (id)_downloadMediaWithAttachment:(TGMediaAttachment *)attachment conversationId:(int64_t)conversationId messageId:(int32_t)messageId
{
    switch (attachment.type)
    {
        case TGImageMediaAttachmentType:
        {
            TGImageMediaAttachment *imageAttachment = (TGImageMediaAttachment *)attachment;
            id mediaId = [[TGMediaId alloc] initWithType:2 itemId:imageAttachment.imageId];
            
            NSString *url = [[imageAttachment imageInfo] closestImageUrlWithSize:CGSizeMake(1136, 1136) resultingSize:NULL pickLargest:true];
            
            if (url != nil)
            {
                NSInteger contentHints = TGRemoteImageContentHintLargeFile;
                
                NSDictionary *options = @
                {
                    @"cancelTimeout": @0,
                    @"cache": [TGRemoteImageView sharedCache],
                    @"useCache": @false,
                    @"allowThumbnailCache": @false,
                    @"contentHints": @(contentHints),
                    @"userProperties": @
                    {
                        @"messageId": @(messageId),
                        @"conversationId": @(conversationId),
                        @"forceSave": @(true),
                        @"mediaId": mediaId,
                        @"imageInfo": imageAttachment.imageInfo
                    }
                };
                
                [[TGDownloadManager instance] requestItem:[NSString stringWithFormat:@"/img/(download:{filter:%@}%@)", @"maybeScale", url] options:options changePriority:true messageId:messageId itemId:mediaId groupId:conversationId itemClass:TGDownloadItemClassImage];
                
                return mediaId;
            }
        }
            break;
            
        case TGAudioMediaAttachmentType:
        {
            TGAudioMediaAttachment *audioAttachment = (TGAudioMediaAttachment *)attachment;
            if (audioAttachment.audioId != 0 || audioAttachment.audioUri.length != 0)
            {
                id mediaId = [[TGMediaId alloc] initWithType:4 itemId:audioAttachment.audioId != 0 ? audioAttachment.audioId : audioAttachment.localAudioId];
                
                NSDictionary *options = @{ @"audioAttachment": audioAttachment };
                
                [[TGDownloadManager instance] requestItem:[NSString stringWithFormat:@"/tg/media/audio/(%" PRId32 ":%" PRId64 ":%@)", audioAttachment.datacenterId, audioAttachment.audioId, audioAttachment.audioUri.length != 0 ? audioAttachment.audioUri : @""] options:options changePriority:true messageId:messageId itemId:mediaId groupId:conversationId itemClass:TGDownloadItemClassAudio];
                
                return mediaId;
            }
            break;
        }
            
        case TGDocumentMediaAttachmentType:
        {
            TGDocumentMediaAttachment *documentAttachment = (TGDocumentMediaAttachment *)attachment;
            if (documentAttachment.documentId != 0 || documentAttachment.documentUri.length != 0) {
                id mediaId = nil;
                if (documentAttachment.documentId != 0) {
                    mediaId = [[TGMediaId alloc] initWithType:3 itemId:documentAttachment.documentId];
                } else if (documentAttachment.localDocumentId != 0 && documentAttachment.documentUri.length != 0) {
                    mediaId = [[TGMediaId alloc] initWithType:3 itemId:documentAttachment.localDocumentId];
                }
                
                if (mediaId != nil) {
                    NSString *downloadUri = documentAttachment.documentUri;
                    [[TGDownloadManager instance] requestItem:[NSString stringWithFormat:@"/tg/media/document/(%d:%" PRId64 ":%@)", documentAttachment.datacenterId, documentAttachment.documentId, downloadUri.length != 0 ? downloadUri : @""] options:[[NSDictionary alloc] initWithObjectsAndKeys:documentAttachment, @"documentAttachment", nil] changePriority:true messageId:messageId itemId:mediaId groupId:conversationId itemClass:TGDownloadItemClassDocument];
                    
                    return mediaId;
                }
            }
            
            break;
        }
            
        default:
            break;
    }
    
    return nil;
}

- (void)_cancelMediaWithId:(id)mediaId
{
    [[TGDownloadManager instance] cancelItem:mediaId];
}

- (TGModernViewInlineMediaContext *)_inlineMediaContext:(int32_t)messageId
{
    if (_currentAudioPlayerMessageId == messageId && _currentAudioPlayer != nil)
        return [_currentAudioPlayer inlineMediaContext];
    
    return nil;
}

- (void)_updateInlineMediaContext
{
    [_notificationView.contentView.previewView updateInlineMediaContext];
}

- (void)_playAudioWithAttachment:(TGMediaAttachment *)attachment peerId:(int64_t)peerId messageId:(int32_t)messageId
{
    bool isVoice = false;
    if ([attachment isKindOfClass:[TGAudioMediaAttachment class]]) {
        isVoice = true;
    } else if ([attachment isKindOfClass:[TGDocumentMediaAttachment class]]) {
        for (id attribute in ((TGDocumentMediaAttachment *)attachment).attributes) {
            if ([attribute isKindOfClass:[TGDocumentAttributeAudio class]]) {
                isVoice = ((TGDocumentAttributeAudio *)attribute).isVoice;
            }
        }
    }
    [TGTelegraphInstance.musicPlayer setPlaylist:[TGGenericPeerPlaylistSignals playlistForPeerId:peerId important:true atMessageId:messageId voice:isVoice] initialItemKey:@(messageId) metadata:@{@"peerId": @(peerId), @"voice": @(isVoice)}];
    
    [self hideAnimated:true];
}

static id mediaIdForAttachment(TGMediaAttachment *attachment)
{
    if (attachment.type == TGVideoMediaAttachmentType)
    {
        if (((TGVideoMediaAttachment *)attachment).videoId == 0)
            return nil;
        
        return [[TGMediaId alloc] initWithType:1 itemId:((TGVideoMediaAttachment *)attachment).videoId];
    }
    else if (attachment.type == TGImageMediaAttachmentType)
    {
        if (((TGImageMediaAttachment *)attachment).imageId == 0)
            return nil;
        
        return [[TGMediaId alloc] initWithType:2 itemId:((TGImageMediaAttachment *)attachment).imageId];
    }
    else if (attachment.type == TGDocumentMediaAttachmentType)
    {
        if (((TGDocumentMediaAttachment *)attachment).documentId != 0)
            return [[TGMediaId alloc] initWithType:3 itemId:((TGDocumentMediaAttachment *)attachment).documentId];
        else if (((TGDocumentMediaAttachment *)attachment).localDocumentId != 0 && ((TGDocumentMediaAttachment *)attachment).documentUri.length != 0)
            return [[TGMediaId alloc] initWithType:3 itemId:((TGDocumentMediaAttachment *)attachment).localDocumentId];
        
        return nil;
    }
    else if (attachment.type == TGAudioMediaAttachmentType)
    {
        if (((TGAudioMediaAttachment *)attachment).audioId != 0)
            return [[TGMediaId alloc] initWithType:4 itemId:((TGAudioMediaAttachment *)attachment).audioId];
        else if (((TGAudioMediaAttachment *)attachment).localAudioId != 0)
            return [[TGMediaId alloc] initWithType:4 itemId:((TGAudioMediaAttachment *)attachment).localAudioId];
        
        return nil;
    }
    
    return nil;
}

- (void)_updateMediaAccessTimeWithAttachment:(TGMediaAttachment *)attachment peerId:(int64_t)peerId messageId:(int32_t)messageId
{
    TGMediaId *mediaId = mediaIdForAttachment(attachment);
    if (mediaId != 0)
        [TGDatabaseInstance() updateLastUseDateForMediaType:mediaId.type mediaId:mediaId.itemId messageId:messageId];
    
    bool maybeReadContents = ([attachment isKindOfClass:[TGAudioMediaAttachment class]] || [attachment isKindOfClass:[TGDocumentMediaAttachment class]]);
    
    if (maybeReadContents)// && [self allowMessageForwarding] && !TGPeerIdIsChannel(_conversationId))
    {
        TGMessage *message = [TGDatabaseInstance() loadMessageWithMid:messageId peerId:peerId];
        if (message == nil)
            return;
        
        bool found = (message.contentProperties[@"contentsRead"] != nil);
        
        if (!found)
        {
            NSMutableDictionary *contentProperties = [[NSMutableDictionary alloc] initWithDictionary:message.contentProperties];
            contentProperties[@"contentsRead"] = [[TGMessageViewedContentProperty alloc] init];
            
            TGDatabaseAction action = { .type = TGDatabaseActionReadMessageContents, .subject = message.mid, .arg0 = 0, .arg1 = 0};
            [TGDatabaseInstance() storeQueuedActions:[NSArray arrayWithObject:[[NSValue alloc] initWithBytes:&action objCType:@encode(TGDatabaseAction)]]];
            [ActionStageInstance() requestActor:@"/tg/service/synchronizeactionqueue/(global)" options:nil watcher:TGTelegraphInstance];
            
            [TGDatabaseInstance() transactionUpdateMessages:@[[[TGDatabaseUpdateContentsRead alloc] initWithPeerId:message.cid messageId:message.mid]] updateConversationDatas:nil];
        }
    }
}

- (void)_stopInlineMediaIfPlaying
{
    if (_currentAudioPlayer != nil)
    {
        [_currentAudioPlayer stop];
        _currentAudioPlayer = nil;
        _currentAudioPlayerMessageId = 0;
        
        [self _updateInlineMediaContext];
    }
}

- (void)audioPlayerDidFinish
{
    [self _stopInlineMediaIfPlaying];
}

- (bool)_isMediaAvailable:(TGMediaAttachment *)attachment
{
    static NSFileManager *fileManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^
    {
        fileManager = [[NSFileManager alloc] init];
    });
    
    switch (attachment.type)
    {
        case TGImageMediaAttachmentType:
        {
            static TGCache *cache = nil;
            
            static dispatch_once_t onceToken;
            dispatch_once(&onceToken, ^
            {
                cache = [TGRemoteImageView sharedCache];
            });
            
            TGImageMediaAttachment *imageAttachment = (TGImageMediaAttachment *)attachment;
            
            NSString *url = [imageAttachment.imageInfo closestImageUrlWithSize:(CGSizeMake(1136, 1136)) resultingSize:NULL pickLargest:true];
            
            bool imageDownloaded = false;
            
            if ([url hasPrefix:@"http://"] || [url hasPrefix:@"https://"])
            {
                imageDownloaded = [[[TGMediaStoreContext instance] temporaryFilesCache] containsValueForKey:[url dataUsingEncoding:NSUTF8StringEncoding]];
            }
            else
            {
                if (imageAttachment.imageId != 0)
                {
                    NSString *path = [TGPreparedRemoteImageMessage filePathForRemoteImageId:imageAttachment.imageId];
                    imageDownloaded = [fileManager fileExistsAtPath:path];
                }
                
                if (!imageDownloaded)
                {
                    NSString *path = [cache pathForCachedData:url];
                    if (path != nil)
                    {
                        imageDownloaded = ([url hasPrefix:@"upload/"] || [url hasPrefix:@"file://"]) ? true : [fileManager fileExistsAtPath:path];
                    }
                }
            }
            
            return imageDownloaded;
        }
        case TGDocumentMediaAttachmentType:
        {
            TGDocumentMediaAttachment *documentAttachment = (TGDocumentMediaAttachment *)attachment;
            
            bool documentDownloaded = false;
            if (documentAttachment.localDocumentId != 0)
            {
                NSString *documentPath = [[TGPreparedLocalDocumentMessage localDocumentDirectoryForLocalDocumentId:documentAttachment.localDocumentId version:documentAttachment.version] stringByAppendingPathComponent:[documentAttachment safeFileName]];
                documentDownloaded = [[NSFileManager defaultManager] fileExistsAtPath:documentPath];
            }
            else
            {
                NSString *documentPath = [[TGPreparedLocalDocumentMessage localDocumentDirectoryForDocumentId:documentAttachment.documentId version:documentAttachment.version] stringByAppendingPathComponent:[documentAttachment safeFileName]];
                documentDownloaded = [[NSFileManager defaultManager] fileExistsAtPath:documentPath];
            }
            
            return documentDownloaded;
        }
        case TGAudioMediaAttachmentType:
        {
            TGAudioMediaAttachment *audioAttachment = (TGAudioMediaAttachment *)attachment;
            
            bool audioDownloaded = false;
            if (audioAttachment.localAudioId != 0)
            {
                NSString *audioPath = [TGAudioMediaAttachment localAudioFilePathForLocalAudioId:audioAttachment.localAudioId];
                audioDownloaded = [[NSFileManager defaultManager] fileExistsAtPath:audioPath];
            }
            else
            {
                NSString *audioPath = [TGAudioMediaAttachment localAudioFilePathForRemoteAudioId:audioAttachment.audioId];
                audioDownloaded = [[NSFileManager defaultManager] fileExistsAtPath:audioPath];
            }
            
            return audioDownloaded;
        }
        default:
            break;
    }
    
    return false;
}

- (void)actionStageResourceDispatched:(NSString *)path resource:(id)resource arguments:(id)__unused arguments
{
    if ([path isEqualToString:@"/as/media/imageThumbnailUpdated"])
    {
        NSString *imageUrl = resource;
        
        TGDispatchOnMainThread(^
        {
            [_notificationView.contentView.previewView imageDataInvalidated:imageUrl];
        });
    }
    else if ([path isEqualToString:@"downloadManagerStateChanged"])
    {
        bool animated = ![arguments[@"requested"] boolValue];
        
        NSDictionary *mediaList = resource;
        
        NSMutableDictionary *messageDownloadProgress = [[NSMutableDictionary alloc] init];
        
        if (mediaList == nil || mediaList.count == 0)
        {
            [messageDownloadProgress removeAllObjects];
        }
        else
        {
            [mediaList enumerateKeysAndObjectsUsingBlock:^(__unused NSString *path, TGDownloadItem *item, __unused BOOL *stop)
            {
                if (item.itemId != nil)
                    [messageDownloadProgress setObject:@(item.progress) forKey:item.itemId];
            }];
        }
        
        TGDispatchOnMainThread(^
        {
            id activeMediaId = _notificationView.contentView.previewView.activeRequestMediaId;
            if (activeMediaId == nil)
                return;
            
            NSNumber *nProgress = messageDownloadProgress[activeMediaId];
            if (nProgress != nil)
            {
                float progress = nProgress.floatValue;
                [_notificationView.contentView.previewView updateProgress:(progress > -FLT_EPSILON) progress:progress animated:animated];
            }
            
            if (arguments != nil)
            {
                NSMutableDictionary *completedItemStatuses = [[NSMutableDictionary alloc] init];
                for (id mediaId in [arguments objectForKey:@"completedItemIds"])
                    [completedItemStatuses setObject:@(true) forKey:mediaId];
                
                for (id mediaId in [arguments objectForKey:@"failedItemIds"])
                    [completedItemStatuses setObject:@(false) forKey:mediaId];
                
                NSNumber *nResult = completedItemStatuses[activeMediaId];
                if (nResult != nil)
                {
                    bool availability = nResult.boolValue;
                    [_notificationView.contentView.previewView updateMediaAvailability:availability];
                }
            }
        });
    }
}

@end


@implementation TGNotificationWindowViewController

- (BOOL)prefersStatusBarHidden
{
    TGNotificationController *controller = self.childViewControllers.firstObject;
    bool viewPresented = controller.notificationView.isPresented;
    bool isHiding = controller.notificationView.isHiding;
    
    CGFloat statusBarHeight = [UIApplication sharedApplication].statusBarFrame.size.height;
    return (iosMajorVersion() >= 7 && viewPresented && !isHiding && (statusBarHeight - 20.0f) < FLT_EPSILON);
}

//- (void)viewDidLayoutSubviews
//{
//    self.view.frame = TGAppDelegateInstance.rootController.applicationBounds;
//}

@end


@implementation TGNotificationWindow

- (instancetype)initWithFrame:(CGRect)frame overInAppBrowser:(bool)overInAppBrowser
{
    self = [super initWithFrame:frame];
    if (self != nil)
    {
        [self setHugeWindowLevel:!overInAppBrowser];
        self.backgroundColor = [UIColor clearColor];
    }
    return self;
}

- (void)setHugeWindowLevel:(bool)huge
{
    self.windowLevel = huge ? 100000000.0f + 0.002f : UIWindowLevelStatusBar + 0.001f;
}

- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event
{
    TGNotificationController *controller = (TGNotificationController *)self.rootViewController;
    
    CGPoint localPoint = [controller.view convertPoint:point fromView:self];
    UIView *result = [controller.view hitTest:localPoint withEvent:event];
    if (result == controller.view || result == controller.wrapperView)
        return nil;
    
    return result;
}

- (BOOL)pointInside:(CGPoint)point withEvent:(UIEvent *)event
{
    if (self.pointInside != nil)
        return self.pointInside(point);
    
    return [super pointInside:point withEvent:event];
}

@end


@implementation TGNotificationItem

- (instancetype)initWithConversation:(TGConversation *)conversation identifier:(int32_t)identifier replyToMid:(int32_t)replyToMid duration:(NSTimeInterval)duration configure:(void (^)(TGNotificationContentView *, bool *))configure
{
    self = [super init];
    if (self != nil)
    {
        _conversationId = conversation.conversationId;
        _identifier = identifier;
        _replyToMid = replyToMid;
        _isChannelGroup = conversation.isChannelGroup;
        _duration = duration;
        self.configure = configure;
    }
    return self;
}

@end
