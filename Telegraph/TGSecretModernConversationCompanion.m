#import "TGSecretModernConversationCompanion.h"

#import "ActionStage.h"
#import "SGraphObjectNode.h"

#import "TGInterfaceManager.h"
#import "TGTelegraph.h"
#import "TGActionSheet.h"
#import "TGAlertView.h"
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

#import "TGSecretTimerValueController.h"

#import "TGStringUtils.h"

#import "TGModernConversationUpgradeStateTitlePanel.h"

#import "TGModernSendSecretMessageActor.h"

#import "TGPickerSheet.h"

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
    
    TGPickerSheet *_pickerSheet;
}

@end

@implementation TGSecretModernConversationCompanion

- (instancetype)initWithEncryptedConversationId:(int64_t)encryptedConversationId accessHash:(int64_t)accessHash conversationId:(int64_t)conversationId uid:(int)uid activity:(NSString *)activity mayHaveUnreadMessages:(bool)mayHaveUnreadMessages
{
    self = [super initWithConversationId:conversationId uid:uid activity:activity mayHaveUnreadMessages:mayHaveUnreadMessages];
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
    TGPickerSheet *pickerSheet = _pickerSheet;
    dispatch_async(dispatch_get_main_queue(), ^
    {
        [selfDestructTimerView alpha];
        [pickerSheet dismiss];
    });
}

#pragma mark -

- (void)loadInitialState
{
    _selfDestructTimer = [TGDatabaseInstance() messageLifetimeForPeerId:_conversationId];
    _selfDestructTimerView.timerValue = _selfDestructTimer;
    
    [self updateLayer:[TGDatabaseInstance() peerLayer:_conversationId]];\
    
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
    NSMutableArray *timerValues = [[NSMutableArray alloc] init];
    [timerValues addObject:@(0)];
    for (int i = 1; i < 16; i++)
    {
        [timerValues addObject:@(i)];
    }
    [timerValues addObject:@(30)];
    [timerValues addObject:@(1 * 60)];
    [timerValues addObject:@(1 * 60 * 60)];
    [timerValues addObject:@(1 * 60 * 60 * 24)];
    [timerValues addObject:@(1 * 60 * 60 * 24 * 7)];
    
    NSUInteger selectedIndex = 5;
    if (_selfDestructTimer != 0)
    {
        NSInteger closestMatchIndex = 5;
        NSInteger index = -1;
        for (NSNumber *nValue in timerValues)
        {
            index++;
            if ([nValue intValue] != 0 && ABS([nValue intValue] - _selfDestructTimer) < ABS([timerValues[closestMatchIndex] intValue] - _selfDestructTimer))
            {
                closestMatchIndex = index;
            }
        }
        selectedIndex = closestMatchIndex;
    }
    
    __weak TGSecretModernConversationCompanion *weakSelf = self;
    _pickerSheet = [[TGPickerSheet alloc] initWithItems:timerValues selectedIndex:selectedIndex action:^(NSNumber *timerValue)
    {
        __strong TGSecretModernConversationCompanion *strongSelf = weakSelf;
        [strongSelf _commitSetSelfDestructTimer:[timerValue intValue]];
    }];
    
    TGModernConversationController *controller = self.controller;
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad)
    {
        CGRect windowRect = [_selfDestructTimerView convertRect:_selfDestructTimerView.bounds toView:controller.view];
        [_pickerSheet showFromRect:windowRect inView:controller.view];
    }
    else
        [_pickerSheet show];
    
    return;
    
    NSMutableArray *actions = [[NSMutableArray alloc] init];
    
    NSArray *values = @[@0, @2, @5, @(1 * 60), @(1 * 60 * 60), @(1 * 60 * 60 * 24), @(7 * 60 * 60 * 24)];
    
    for (NSNumber *item in values)
    {
        [actions addObject:[[TGActionSheetAction alloc] initWithTitle:[item intValue] == 0 ? TGLocalized(@"Profile.MessageLifetimeForever") : [TGStringUtils stringForMessageTimerSeconds:[item intValue]] action:[[NSString alloc] initWithFormat:@"%@", item]]];
    }
    
    [actions addObject:[[TGActionSheetAction alloc] initWithTitle:TGLocalized(@"MessageTimer.Custom") action:@"_custom"]];
    
    [actions addObject:[[TGActionSheetAction alloc] initWithTitle:TGLocalized(@"Common.Cancel") action:@"cancel" type:TGActionSheetActionTypeCancel]];
    
    if (controller != nil)
    {
        [[[TGActionSheet alloc] initWithTitle:nil actions:actions actionBlock:^(__unused TGModernConversationController *controller, NSString *action)
        {
            __strong TGSecretModernConversationCompanion *strongSelf = weakSelf;
            if ([action isEqualToString:@"_custom"])
            {
                TGSecretTimerValueController *timerController = [[TGSecretTimerValueController alloc] init];
                timerController.timerValueSelected = ^(NSUInteger seconds)
                {
                    __strong TGSecretModernConversationCompanion *strongSelf = weakSelf;
                    [strongSelf _commitSetSelfDestructTimer:seconds];
                };
                
                TGNavigationController *navigationController = [TGNavigationController navigationControllerWithControllers:@[timerController]];
                if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad)
                {
                    navigationController.presentationStyle = TGNavigationControllerPresentationStyleInFormSheet;
                    navigationController.modalPresentationStyle = UIModalPresentationFormSheet;
                }
                
                [((TGModernConversationController *)strongSelf.controller) presentViewController:navigationController animated:true completion:nil];
            }
            else if (![action isEqualToString:@"cancel"])
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
        
        if (_selfDestructTimer > 0 && _selfDestructTimer <= 60 && [self layer] < 17)
        {
            TGDispatchOnMainThread(^
            {
                [[[TGAlertView alloc] initWithTitle:TGLocalized(@"Compatibility.SecretMediaVersionTooLow") message:nil cancelButtonTitle:TGLocalized(@"Common.OK") okButtonTitle:nil completionBlock:nil] show];
            });
        }
        
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

- (void)updateLayer:(NSUInteger)layer
{
    self.layer = layer;
    
    /*TGDispatchOnMainThread(^
    {
        TGModernConversationController *controller = self.controller;
        
        TGModernConversationUpgradeStateTitlePanel *panel = [controller.secondaryTitlePanel isKindOfClass:[TGModernConversationUpgradeStateTitlePanel class]] ? (TGModernConversationUpgradeStateTitlePanel *)controller.secondaryTitlePanel : nil;
        if (panel == nil)
        {
            panel = [[TGModernConversationUpgradeStateTitlePanel alloc] init];
        }
        
        [panel setCurrentLayer:layer];
        
        [controller setSecondaryTitlePanel:panel animated:false];
    });*/
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
        [[NSString alloc] initWithFormat:@"/tg/conversation/messageViewDateChanges"],
        [[NSString alloc] initWithFormat:@"/tg/encrypted/messageLifetime/(%" PRId64 ")", _conversationId],
        [[NSString alloc] initWithFormat:@"/tg/peerLayerUpdates/(%" PRId64 ")", _conversationId]
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

- (void)serviceNotificationsForMessageIds:(NSArray *)messageIds
{
    [TGModernConversationCompanion dispatchOnMessageQueue:^
    {
        NSMutableDictionary *messageFlagChanges = [[NSMutableDictionary alloc] init];
        NSMutableArray *randomIds = [[NSMutableArray alloc] init];
        
        for (NSNumber *nMid in messageIds)
        {
            int32_t messageId = [nMid intValue];
            
            int messageFlags = [TGDatabaseInstance() secretMessageFlags:messageId];
            if ((messageFlags & TGSecretMessageFlagScreenshot) == 0)
            {
                messageFlags |= TGSecretMessageFlagScreenshot;
                TGMessage *message = [TGDatabaseInstance() loadMessageWithMid:messageId];
                if (message != nil)
                {
                    messageFlagChanges[@(messageId)] = @(messageFlags);
                    
                    int64_t randomId = [TGDatabaseInstance() randomIdForMessageId:messageId];
                    if (randomId != 0)
                        [randomIds addObject:@(randomId)];
                }
            }
        }
        
        int64_t encryptedConversationId = [TGDatabaseInstance() encryptedConversationIdForPeerId:_conversationId];
        if (encryptedConversationId != 0 && randomIds.count != 0)
        {
            int64_t actionRandomId = 0;
            arc4random_buf(&actionRandomId, 8);
            
            NSUInteger peerLayer = [TGDatabaseInstance() peerLayer:_conversationId];
            
            NSData *messageData = [TGModernSendSecretMessageActor decryptedServiceMessageActionWithLayer:MIN(peerLayer, [TGModernSendSecretMessageActor currentLayer]) screenshotMessagesWithRandomIds:randomIds randomId:actionRandomId];
            
            if (messageData != nil)
            {
                [TGModernSendSecretMessageActor enqueueOutgoingServiceMessageForPeerId:_conversationId layer:MIN(peerLayer, [TGModernSendSecretMessageActor currentLayer]) randomId:actionRandomId messageData:messageData];
            }
            
            [ActionStageInstance() dispatchResource:[[NSString alloc] initWithFormat:@"/tg/conversation/(%" PRId64 ")/messageFlagChanges", _conversationId] resource:messageFlagChanges];
        }
    }];
}

#pragma mark -

- (TGMessageModernConversationItem *)_updateMediaStatusData:(TGMessageModernConversationItem *)item
{
    if (item->_message.messageLifetime > 0 && item->_message.messageLifetime <= 60 && item->_message.mediaAttachments.count != 0)
    {
        for (TGMediaAttachment *attachment in item->_message.mediaAttachments)
        {
            switch (attachment.type)
            {
                case TGImageMediaAttachmentType:
                case TGVideoMediaAttachmentType:
                {
                    int flags = [TGDatabaseInstance() secretMessageFlags:item->_message.mid];
                    NSTimeInterval viewDate = [TGDatabaseInstance() messageCountdownLocalTime:item->_message.mid enqueueIfNotQueued:false initiatedCountdown:NULL];
                    
                    if (flags != 0 || ABS(viewDate - DBL_EPSILON) > 0.0)
                        [self _setMessageFlagsAndViewDate:item->_message.mid flags:flags viewDate:viewDate];
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
        TGDispatchOnMainThread(^
        {
            [(NSMutableDictionary *)resource enumerateKeysAndObjectsUsingBlock:^(NSNumber *nMessageId, NSNumber *nFlags, __unused BOOL *stop)
            {
                [self _setMessageFlags:(int32_t)[nMessageId intValue] flags:[nFlags intValue]];
            }];
        });
    }
    else if ([path isEqualToString:[[NSString alloc] initWithFormat:@"/tg/conversation/messageViewDateChanges"]])
    {
        TGDispatchOnMainThread(^
        {
            [(NSMutableDictionary *)resource enumerateKeysAndObjectsUsingBlock:^(NSNumber *nMessageId, NSNumber *nViewDate, __unused BOOL *stop)
            {
                [self _setMessageViewDate:(int32_t)[nMessageId intValue] viewDate:[nViewDate doubleValue]];
            }];
        });
    }
    else if ([path hasPrefix:@"/tg/encrypted/messageLifetime/"])
    {
        TGDispatchOnMainThread(^
        {
            _selfDestructTimer = [resource intValue];
            _selfDestructTimerView.timerValue = _selfDestructTimer;
        });
    }
    else if ([path isEqualToString:[[NSString alloc] initWithFormat:@"/tg/peerLayerUpdates/(%" PRId64 ")", _conversationId]])
    {
        [self updateLayer:[resource[@"layer"] unsignedIntegerValue]];
    }
    
    [super actionStageResourceDispatched:path resource:resource arguments:arguments];
}

@end
