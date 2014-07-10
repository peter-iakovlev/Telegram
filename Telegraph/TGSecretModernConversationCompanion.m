#import "TGSecretModernConversationCompanion.h"

#import "ActionStage.h"
#import "SGraphObjectNode.h"

#import "TGInterfaceManager.h"
#import "TGTelegraph.h"
#import "TGActionSheet.h"
#import "TGNavigationBar.h"
#import "TGSecretChatUserInfoController.h"

#import "TGMessageModernConversationItem.h"
#import "TGMessage.h"

#import "TGModernConversationController.h"
#import "TGModernConversationTitleIcon.h"
#import "TGSecretConversationHandshakeStatusPanel.h"
#import "TGModernConversationActionInputPanel.h"
#import "TGSecretConversationEmptyListView.h"
#import "TGSecretModernConversationAccessoryTimerView.h"

#import "TGDatabase.h"
#import "TGAppDelegate.h"
#import "TGDialogListController.h"
#import "TGTelegraphDialogListCompanion.h"
#import "TGPopoverController.h"

#import "TGModernGalleryController.h"
#import "TGModernGallerySecretImageItem.h"
#import "TGModernGallerySecretVideoItem.h"

@interface TGSecretModernConversationCompanion () <TGSecretModernConversationAccessoryTimerViewDelegate>
{
    int64_t _encryptedConversationId;
    int64_t _accessHash;
    
    bool _encryptedConversationIsIncoming;
    NSString *_encryptedConversationUserName;
    
    NSTimeInterval _lastTypingActivity;
    
    TGConversation *_conversation; // Main Thread
    int _encryptionState; // Main Thread
    
    TGSecretModernConversationAccessoryTimerView *_selfDestructTimerView;
    int _selfDestructTimer; // Main Thread
}

@end

@implementation TGSecretModernConversationCompanion

- (instancetype)initWithEncryptedConversationId:(int64_t)encryptedConversationId accessHash:(int64_t)accessHash conversationId:(int64_t)conversationId uid:(int)uid typing:(bool)typing mayHaveUnreadMessages:(bool)mayHaveUnreadMessages
{
    self = [super initWithConversationId:conversationId uid:uid typing:typing mayHaveUnreadMessages:mayHaveUnreadMessages];
    if (self != nil)
    {
        _encryptedConversationId = encryptedConversationId;
        _accessHash = accessHash;
        
        _conversation = [TGDatabaseInstance() loadConversationWithIdCached:_conversationId];
        _encryptedConversationIsIncoming = _conversation.chatParticipants.chatAdminId != TGTelegraphInstance.clientUserId;
        _encryptedConversationUserName = [TGDatabaseInstance() loadUser:uid].displayFirstName;
    }
    return self;
}

- (void)dealloc
{
    UIView *selfDestructTimerView = _selfDestructTimerView;
    dispatch_async(dispatch_get_main_queue(), ^
    {
        [selfDestructTimerView alpha];
    });
}

#pragma mark -

- (void)loadInitialState
{
    [super loadInitialState];
    
    TGModernConversationTitleIcon *lockIcon = [[TGModernConversationTitleIcon alloc] init];
    lockIcon.bounds = CGRectMake(0.0f, 0.0f, 16, 16);
    lockIcon.offsetWeight = 0.5f;
    lockIcon.imageOffset = CGPointMake(3.0f, 5.0f);
    
    static UIImage *lockImage = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^
    {
        lockImage = [UIImage imageNamed:@"ModernConversationTitleIconLock.png"];
    });
    
    lockIcon.image = lockImage;
    lockIcon.iconPosition = TGModernConversationTitleIconPositionBeforeTitle;
    
    [self setAdditionalTitleIcons:@[lockIcon]];
    
    [self _updateEncryptionState:_conversation.encryptedData.handshakeState];
    
    _selfDestructTimer = [TGDatabaseInstance() messageLifetimeForPeerId:_conversationId];
    _selfDestructTimerView.timerValue = _selfDestructTimer;
}

#pragma mark -

- (bool)controllerShouldStoreCapturedAssets
{
    return false;
}

- (bool)controllerShouldCacheServerAssets
{
    return false;
}

- (bool)controllerShouldLiveUploadVideo
{
    return false;
}

- (bool)allowMessageForwarding
{
    return false;
}

- (bool)allowContactSharing
{
    return false;
}

- (bool)encryptUploads
{
    return true;
}

- (void)_controllerAvatarPressed
{
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone)
        [[TGInterfaceManager instance] navigateToProfileOfUser:_uid encryptedConversationId:_encryptedConversationId];
    else
    {
        TGModernConversationController *controller = self.controller;
        if (controller != nil)
        {
            TGSecretChatUserInfoController *secretChatInfoController = [[TGSecretChatUserInfoController alloc] initWithUid:_uid encryptedConversationId:_encryptedConversationId];
            
            TGNavigationController *navigationController = [TGNavigationController navigationControllerWithControllers:@[secretChatInfoController] navigationBarClass:[TGWhiteNavigationBar class]];
            navigationController.presentationStyle = TGNavigationControllerPresentationStyleRootInPopover;
            TGPopoverController *popoverController = [[TGPopoverController alloc] initWithContentViewController:navigationController];
            navigationController.parentPopoverController = popoverController;
            [popoverController setPopoverContentSize:CGSizeMake(320.0f, 528.0f) animated:false];
            
            controller.associatedPopoverController = popoverController;
            [popoverController presentPopoverFromBarButtonItem:controller.navigationItem.rightBarButtonItem permittedArrowDirections:UIPopoverArrowDirectionAny animated:true];
            secretChatInfoController.collectionView.contentOffset = CGPointMake(0.0f, -secretChatInfoController.collectionView.contentInset.top);
        }
    }
}

- (TGModernConversationEmptyListPlaceholderView *)_conversationEmptyListPlaceholder
{
    TGSecretConversationEmptyListView *placeholder = [[TGSecretConversationEmptyListView alloc] initWithIncoming:_encryptedConversationIsIncoming userName:_encryptedConversationUserName];
    placeholder.delegate = self.controller;
    
    return placeholder;
}

- (UIView *)_controllerInputTextPanelAccessoryView
{
    if (_selfDestructTimerView == nil)
    {
        _selfDestructTimerView = [[TGSecretModernConversationAccessoryTimerView alloc] init];
        _selfDestructTimerView.delegate = self;
        _selfDestructTimerView.timerValue = _selfDestructTimer;
    }
    
    return _selfDestructTimerView;
}

- (void)accessoryTimerViewPressed:(TGSecretModernConversationAccessoryTimerView *)__unused accessoryTimerView
{
    NSMutableArray *actions = [[NSMutableArray alloc] init];
    
    NSArray *labels = @[
        TGLocalized(@"Profile.MessageLifetimeForever"),
        TGLocalized(@"Profile.MessageLifetime2s"),
        TGLocalized(@"Profile.MessageLifetime5s"),
        TGLocalized(@"Profile.MessageLifetime1m"),
        TGLocalized(@"Profile.MessageLifetime1h"),
        TGLocalized(@"Profile.MessageLifetime1d"),
        TGLocalized(@"Profile.MessageLifetime1w")
    ];
    
    NSArray *values = @[@0, @2, @5, @(1 * 60), @(1 * 60 * 60), @(1 * 60 * 60 * 24), @(7 * 60 * 60 * 24)];
    
    int index = -1;
    for (NSString *item in labels)
    {
        index++;
        [actions addObject:[[TGActionSheetAction alloc] initWithTitle:item action:[[NSString alloc] initWithFormat:@"%@", values[index]]]];
    }
    
    [actions addObject:[[TGActionSheetAction alloc] initWithTitle:TGLocalized(@"Common.Cancel") action:@"cancel" type:TGActionSheetActionTypeCancel]];
    
    TGModernConversationController *controller = self.controller;
    __weak TGSecretModernConversationCompanion *weakSelf = self;
    if (controller != nil)
    {
        [[[TGActionSheet alloc] initWithTitle:nil actions:actions actionBlock:^(__unused TGModernConversationController *controller, NSString *action)
        {
            if (![action isEqualToString:@"cancel"])
            {
                __strong TGSecretModernConversationCompanion *strongSelf = weakSelf;
                [strongSelf _commitSetSelfDestructTimer:[action intValue]];
            }
        } target:controller] showInView:controller.view];
    }
}

- (void)_commitSetSelfDestructTimer:(int)value
{
    if (value != _selfDestructTimer)
    {
        _selfDestructTimer = value;
        _selfDestructTimerView.timerValue = _selfDestructTimer;
        
        [TGDatabaseInstance() setMessageLifetimeForPeerId:_conversationId encryptedConversationId:_encryptedConversationId messageLifetime:value writeToActionQueue:true];
        [ActionStageInstance() requestActor:@"/tg/service/synchronizeserviceactions/(settings)" options:nil watcher:TGTelegraphInstance];
    }
}

- (bool)shouldDisplayContactLinkPanel
{
    return false;
}

#pragma mark -

- (void)_updateEncryptionState:(int)encryptionState
{
    if (_encryptionState != encryptionState)
    {
        _encryptionState = encryptionState;
        
        TGModernConversationInputPanel *panel = nil;
        
        if (encryptionState == 1 || encryptionState == 2)
        {
            TGSecretConversationHandshakeStatusPanel *statusPanel = [[TGSecretConversationHandshakeStatusPanel alloc] init];
            statusPanel.delegate = self.controller;
            panel = statusPanel;
            
            if (encryptionState == 1) // awaiting
            {
                NSString *formatText = TGLocalized(@"Conversation.EncryptionWaiting");
                NSString *baseText = [[NSString alloc] initWithFormat:formatText, [TGDatabaseInstance() loadUser:_uid].displayFirstName];
                [statusPanel setText:baseText];
            }
            else
                [statusPanel setText:TGLocalized(@"Conversation.EncryptionProcessing")];
        }
        else if (encryptionState == 3) // cancelled
        {
            TGModernConversationActionInputPanel *deleteAndExitPanel = [[TGModernConversationActionInputPanel alloc] init];
            [deleteAndExitPanel setActionWithTitle:TGLocalized(@"ConversationProfile.LeaveDeleteAndExit") action:@"deleteAndExit"];
            deleteAndExitPanel.delegate = self.controller;
            deleteAndExitPanel.companionHandle = self.actionHandle;
            panel = deleteAndExitPanel;
        }
        
        TGModernConversationController *controller = self.controller;
        [controller setCustomInputPanel:panel];
    }
}

#pragma mark -

- (void)controllerDidUpdateTypingActivity
{
    [ActionStageInstance() dispatchOnStageQueue:^
    {
        CFAbsoluteTime currentTime = CFAbsoluteTimeGetCurrent();
        if (ABS(currentTime - _lastTypingActivity) >= 4.0)
        {
            _lastTypingActivity = currentTime;
            [ActionStageInstance() requestActor:[NSString stringWithFormat:@"/tg/conversation/(%lld)/activity/(typing)", _conversationId] options:[self _optionsForMessageActions] watcher:self];
        }
    }];
}

#pragma mark -

- (bool)imageDownloadsShouldAutosavePhotos
{
    return false;
}

- (bool)_shouldCacheRemoteAssetUris
{
    return false;
}

- (int)messageLifetime
{
    return [TGDatabaseInstance() messageLifetimeForPeerId:_conversationId];
}

- (NSString *)_sendMessagePathForMessageId:(int32_t)mid
{
    return [[NSString alloc] initWithFormat:@"/tg/sendSecretMessage/(%@)/(%d)", [self _conversationIdPathComponent], mid];
}

- (NSString *)_sendMessagePathPrefix
{
    return [[NSString alloc] initWithFormat:@"/tg/sendSecretMessage/(%@)/", [self _conversationIdPathComponent]];
}

- (void)subscribeToUpdates
{
    [ActionStageInstance() watchForPaths:@[
        [[NSString alloc] initWithFormat:@"/tg/conversation/(%lld)/conversation", _conversationId],
        [[NSString alloc] initWithFormat:@"/tg/conversation/(%lld)/readByDateMessages", _conversationId],
        [[NSString alloc] initWithFormat:@"/tg/conversation/(%lld)/messageFlagChanges", _conversationId],
        [[NSString alloc] initWithFormat:@"/tg/encrypted/messageLifetime/(%" PRId64 ")", _conversationId]
    ] watcher:self];
    
    [super subscribeToUpdates];
}

- (NSDictionary *)_optionsForMessageActions
{
    return @{
        @"conversationId": @(_conversationId),
        @"encryptedConversationId": @(_encryptedConversationId),
        @"accessHash": @(_accessHash),
        @"isEncrypted": @(true)
    };
}

- (bool)_messagesNeedRandomId
{
    return true;
}

#pragma mark -

- (TGMessageModernConversationItem *)_updateMediaStatusData:(TGMessageModernConversationItem *)item
{
    if (item->_message.messageLifetime != 0 && item->_message.mediaAttachments.count != 0)
    {
        for (TGMediaAttachment *attachment in item->_message.mediaAttachments)
        {
            switch (attachment.type)
            {
                case TGImageMediaAttachmentType:
                case TGVideoMediaAttachmentType:
                {
                    int flags = [TGDatabaseInstance() secretMessageFlags:item->_message.mid];
                    if (flags != 0)
                        [self _setMessageFlags:item->_message.mid flags:flags];
                    break;
                }
                default:
                    break;
            }
        }
    }
    
    return [super _updateMediaStatusData:item];
}

#pragma mark -

- (void)_deleteMessages:(NSArray *)messageIds animated:(bool)animated
{
    [super _deleteMessages:messageIds animated:animated];
    
    [TGModernConversationCompanion dispatchOnMessageQueue:^
    {
        TGModernConversationController *controller = self.controller;
        for (UIWindow *window in controller.associatedWindowStack)
        {
            if ([window.rootViewController isKindOfClass:[TGModernGalleryController class]])
            {
                TGModernGalleryController *galleryController = (TGModernGalleryController *)window.rootViewController;
                for (id item in galleryController.items)
                {
                    int32_t itemMessageId = 0;
                    if ([item isKindOfClass:[TGModernGallerySecretImageItem class]])
                        itemMessageId = ((TGModernGallerySecretImageItem *)item).messageId;
                    else if ([item isKindOfClass:[TGModernGallerySecretVideoItem class]])
                        itemMessageId = ((TGModernGallerySecretVideoItem *)item).messageId;
                    
                    if (itemMessageId != 0 && [messageIds containsObject:@(itemMessageId)])
                    {
                        [galleryController dismissWhenReady];
                        
                        break;
                    }
                }
            }
        }
    }];
}

#pragma mark -

- (void)actionStageActionRequested:(NSString *)action options:(id)options
{
    if ([action isEqualToString:@"actionPanelAction"])
    {
        NSString *panelAction = options[@"action"];
        
        if ([panelAction isEqualToString:@"deleteAndExit"])
        {
            TGModernConversationController *controller = self.controller;
            
            UINavigationController *navigationController = controller.navigationController;
            NSUInteger index = [navigationController.viewControllers indexOfObject:controller];
            if (index != NSNotFound)
            {
                [TGAppDelegateInstance.dialogListController.dialogListCompanion deleteItem:[[TGConversation alloc] initWithConversationId:_conversationId unreadCount:0 serviceUnreadCount:0] animated:false];
                [self _dismissController];
            }
        }
    }
    
    [super actionStageActionRequested:action options:options];
}

- (void)actionStageResourceDispatched:(NSString *)path resource:(id)resource arguments:(id)arguments
{
    if ([path isEqualToString:[[NSString alloc] initWithFormat:@"/tg/conversation/(%lld)/readByDateMessages", _conversationId]])
    {
        int maxDate = [resource[@"maxDate"] intValue];
        
        [TGModernConversationCompanion dispatchOnMessageQueue:^
        {
            NSMutableArray *messageIds = [[NSMutableArray alloc] init];
            
            for (TGMessageModernConversationItem *messageItem in _items)
            {
                if (messageItem->_additionalDate != 0)
                {
                    if (messageItem->_additionalDate <= maxDate)
                        [messageIds addObject:[[NSNumber alloc] initWithInt:messageItem->_message.mid]];
                }
                else if (messageItem->_message.date <= maxDate)
                    [messageIds addObject:[[NSNumber alloc] initWithInt:messageItem->_message.mid]];
            }
            
            if (messageIds.count != 0)
                [self _updateMessagesRead:messageIds];
        }];
    }
    else if ([path isEqualToString:[[NSString alloc] initWithFormat:@"/tg/conversation/(%lld)/conversation", _conversationId]])
    {
        TGDispatchOnMainThread(^
        {
            _conversation = ((SGraphObjectNode *)resource).object;
            [self _updateEncryptionState:_conversation.encryptedData.handshakeState];
        });
    }
    else if ([path isEqualToString:[[NSString alloc] initWithFormat:@"/tg/conversation/(%lld)/messageFlagChanges", _conversationId]])
    {
        [(NSMutableDictionary *)resource enumerateKeysAndObjectsUsingBlock:^(NSNumber *nMessageId, NSNumber *nFlags, __unused BOOL *stop)
        {
            [self _setMessageFlags:(int32_t)[nMessageId intValue] flags:[nFlags intValue]];
        }];
    }
    else if ([path hasPrefix:@"/tg/encrypted/messageLifetime/"])
    {
        TGDispatchOnMainThread(^
        {
            _selfDestructTimer = [resource intValue];
            _selfDestructTimerView.timerValue = _selfDestructTimer;
        });
    }
    
    [super actionStageResourceDispatched:path resource:resource arguments:arguments];
}

@end
