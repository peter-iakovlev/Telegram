#import "TGInterfaceManager.h"

#import "TGAppDelegate.h"

#import "TGTelegraph.h"
#import "TGMessage.h"
#import "TGPeerIdAdapter.h"

#import "TGDatabase.h"

#import "TGMessageNotificationView.h"

#import "TGNavigationBar.h"

#import "TGLinearProgressView.h"

#import "TGModernConversationController.h"
#import "TGGroupModernConversationCompanion.h"
#import "TGPrivateModernConversationCompanion.h"
#import "TGSecretModernConversationCompanion.h"
#import "TGBroadcastModernConversationCompanion.h"
#import "TGChannelConversationCompanion.h"

#import "TGTelegraphUserInfoController.h"
#import "TGSecretChatUserInfoController.h"
#import "TGPhonebookUserInfoController.h"
#import "TGBotUserInfoController.h"

#import "TGGenericPeerMediaListModel.h"
#import "TGModernMediaListController.h"

@interface TGInterfaceManager ()

@property (nonatomic, strong) UIWindow *preloadWindow;

@end

@implementation TGInterfaceManager

@synthesize actionHandle = _actionHandle;

@synthesize preloadWindow = _preloadWindow;

+ (TGInterfaceManager *)instance
{
    static TGInterfaceManager *singleton = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^
    {
        singleton = [[TGInterfaceManager alloc] init];
    });
    return singleton;
}

- (id)init
{
    self = [super init];
    if (self != nil)
    {
        _actionHandle = [[ASHandle alloc] initWithDelegate:self releaseOnMainThread:false];
    }
    return self;
}

- (void)dealloc
{
    [_actionHandle reset];
    [ActionStageInstance() removeWatcher:self];
}

- (void)preload
{
}

- (void)navigateToConversationWithId:(int64_t)conversationId conversation:(TGConversation *)conversation
{
    [self navigateToConversationWithId:conversationId conversation:conversation performActions:nil animated:true];
}

- (void)navigateToConversationWithId:(int64_t)conversationId conversation:(TGConversation *)conversation animated:(bool)animated
{
    [self navigateToConversationWithId:conversationId conversation:conversation performActions:nil animated:animated];
}

- (void)navigateToConversationWithId:(int64_t)conversationId conversation:(TGConversation *)conversation performActions:(NSDictionary *)performActions
{
    [self navigateToConversationWithId:conversationId conversation:conversation performActions:performActions animated:true];
}

- (void)navigateToConversationWithId:(int64_t)conversationId conversation:(TGConversation *)conversation performActions:(NSDictionary *)performActions animated:(bool)animated
{
    [self navigateToConversationWithId:conversationId conversation:conversation performActions:performActions atMessage:nil clearStack:true openKeyboard:false animated:animated];
}

- (void)navigateToConversationWithId:(int64_t)conversationId conversation:(TGConversation *)__unused conversation performActions:(NSDictionary *)performActions atMessage:(NSDictionary *)atMessage clearStack:(bool)__unused clearStack openKeyboard:(bool)openKeyboard animated:(bool)animated
{
    [TGAppDelegateInstance.rootController.dialogListController selectConversationWithId:conversationId];
    
    [self dismissBannerForConversationId:conversationId];
    
    TGModernConversationController *conversationController = nil;
    
    for (UIViewController *viewController in TGAppDelegateInstance.rootController.viewControllers)
    {
        if ([viewController isKindOfClass:[TGModernConversationController class]])
        {
            TGModernConversationController *existingConversationController = (TGModernConversationController *)viewController;
            id companion = existingConversationController.companion;
            if ([companion isKindOfClass:[TGGenericModernConversationCompanion class]])
            {
                if (((TGGenericModernConversationCompanion *)companion).conversationId == conversationId)
                {
                    conversationController = existingConversationController;
                    break;
                }
            }
        }
    }
    
    if (conversationController == nil || atMessage[@"mid"] != nil)
    {
        int conversationUnreadCount = [TGDatabaseInstance() unreadCountForConversation:conversationId];
        int globalUnreadCount = [TGDatabaseInstance() cachedUnreadCount];
        
        conversationController = [[TGModernConversationController alloc] init];
        conversationController.shouldOpenKeyboardOnce = openKeyboard;
        
        if (TGPeerIdIsChannel(conversationId))
        {
            conversation = [TGDatabaseInstance() loadChannels:@[@(conversationId)]][@(conversationId)];
            if (conversation != nil) {
                TGChannelConversationCompanion *companion = [[TGChannelConversationCompanion alloc] initWithPeerId:conversationId conversation:conversation];
                if (atMessage != nil)
                    [companion setPreferredInitialMessagePositioning:[atMessage[@"mid"] intValue]];
                [companion setInitialMessagePayloadWithForwardMessages:performActions[@"forwardMessages"] sendMessages:performActions[@"sendMessages"] sendFiles:performActions[@"sendFiles"]];
                [companion setOthersUnreadCount:MAX(globalUnreadCount - conversationUnreadCount, 0)];
                conversationController.companion = companion;
            }
        }
        else if (conversationId <= INT_MIN)
        {
            if ([TGDatabaseInstance() isConversationBroadcast:conversationId])
            {
                TGBroadcastModernConversationCompanion *companion = [[TGBroadcastModernConversationCompanion alloc] initWithConversationId:conversation.conversationId conversation:conversation];
                if (atMessage != nil)
                    [companion setPreferredInitialMessagePositioning:[atMessage[@"mid"] intValue]];
                [companion setInitialMessagePayloadWithForwardMessages:performActions[@"forwardMessages"] sendMessages:performActions[@"sendMessages"] sendFiles:performActions[@"sendFiles"]];
                [companion setOthersUnreadCount:MAX(globalUnreadCount - conversationUnreadCount, 0)];
                conversationController.companion = companion;
            }
            else
            {
                int64_t encryptedConversationId = [TGDatabaseInstance() encryptedConversationIdForPeerId:conversationId];
                int64_t accessHash = [TGDatabaseInstance() encryptedConversationAccessHash:conversationId];
                int32_t uid = [TGDatabaseInstance() encryptedParticipantIdForConversationId:conversationId];
                TGSecretModernConversationCompanion *companion = [[TGSecretModernConversationCompanion alloc] initWithEncryptedConversationId:encryptedConversationId accessHash:accessHash conversationId:conversationId uid:uid activity:[TGTelegraphInstance typingUserActivitiesInConversationFromMainThread:conversationId][@(uid)] mayHaveUnreadMessages:conversationUnreadCount != 0];
                if (atMessage != nil)
                    [companion setPreferredInitialMessagePositioning:[atMessage[@"mid"] intValue]];
                [companion setInitialMessagePayloadWithForwardMessages:performActions[@"forwardMessages"] sendMessages:performActions[@"sendMessages"] sendFiles:performActions[@"sendFiles"]];
                [companion setOthersUnreadCount:MAX(globalUnreadCount - conversationUnreadCount, 0)];
                conversationController.companion = companion;
            }
        }
        else if (conversationId < 0)
        {
            TGConversation *cachedConversation = [TGDatabaseInstance() loadConversationWithIdCached:conversationId];
            TGGroupModernConversationCompanion *companion = [[TGGroupModernConversationCompanion alloc] initWithConversationId:conversationId conversation:cachedConversation userActivities:[TGTelegraphInstance typingUserActivitiesInConversationFromMainThread:conversationId] mayHaveUnreadMessages:conversationUnreadCount != 0];
            if (atMessage != nil)
                [companion setPreferredInitialMessagePositioning:[atMessage[@"mid"] intValue]];
            [companion setInitialMessagePayloadWithForwardMessages:performActions[@"forwardMessages"] sendMessages:performActions[@"sendMessages"] sendFiles:performActions[@"sendFiles"]];
            [companion setOthersUnreadCount:MAX(globalUnreadCount - conversationUnreadCount, 0)];
            conversationController.companion = companion;
        }
        else
        {
            TGPrivateModernConversationCompanion *companion = [[TGPrivateModernConversationCompanion alloc] initWithUid:(int)conversationId activity:[TGTelegraphInstance typingUserActivitiesInConversationFromMainThread:conversationId][@((int)conversationId)] mayHaveUnreadMessages:conversationUnreadCount != 0];
            companion.botStartPayload = performActions[@"botStartPayload"];
            if (atMessage != nil)
                [companion setPreferredInitialMessagePositioning:[atMessage[@"mid"] intValue]];
            [companion setInitialMessagePayloadWithForwardMessages:performActions[@"forwardMessages"] sendMessages:performActions[@"sendMessages"] sendFiles:performActions[@"sendFiles"]];
            [companion setOthersUnreadCount:MAX(globalUnreadCount - conversationUnreadCount, 0)];
            conversationController.companion = companion;
        }
        
        [conversationController.companion bindController:conversationController];
        
        conversationController.shouldIgnoreAppearAnimationOnce = !animated;
        if (performActions[@"text"] != nil)
            [conversationController setInputText:performActions[@"text"] replace:false];
        
        [TGAppDelegateInstance.rootController replaceContentController:conversationController];
    }
    else
    {
        if ([(NSArray *)performActions[@"forwardMessages"] count] != 0)
            [(TGGenericModernConversationCompanion *)conversationController.companion standaloneForwardMessages:performActions[@"forwardMessages"]];
        
        if ([(NSArray *)performActions[@"sendMessages"] count] != 0)
            [(TGGenericModernConversationCompanion *)conversationController.companion standaloneSendMessages:performActions[@"sendMessages"]];
        
        if ([(NSArray *)performActions[@"sendFiles"] count] != 0)
            [(TGGenericModernConversationCompanion *)conversationController.companion standaloneSendFiles:performActions[@"sendFiles"]];
        
        if (performActions[@"text"] != nil)
            [conversationController setInputText:performActions[@"text"] replace:false];
        
        if (performActions[@"botStartPayload"] != nil)
        {
            if ([conversationController.companion isKindOfClass:[TGPrivateModernConversationCompanion class]])
            {
                [(TGPrivateModernConversationCompanion *)conversationController.companion standaloneSendBotStartPayload:performActions[@"botStartPayload"]];
            }
        }
        [TGAppDelegateInstance.rootController popToContentController:conversationController];
        
        if (openKeyboard)
            [conversationController openKeyboard];
    }
}

- (TGModernConversationController *)configuredConversationControlerWithId:(int64_t)conversationId {
    return [self configuredConversationControlerWithId:conversationId performActions:nil];
}

- (TGModernConversationController *)configuredConversationControlerWithId:(int64_t)conversationId performActions:(NSDictionary *)performActions {
    NSDictionary *atMessage = nil;
    
    int conversationUnreadCount = [TGDatabaseInstance() unreadCountForConversation:conversationId];
    int globalUnreadCount = [TGDatabaseInstance() cachedUnreadCount];
    
    TGModernConversationController *conversationController = [[TGModernConversationController alloc] init];
    conversationController.shouldOpenKeyboardOnce = false;
    
    TGConversation *conversation = nil;
    if (TGPeerIdIsChannel(conversationId))
    {
        conversation = [TGDatabaseInstance() loadChannels:@[@(conversationId)]][@(conversationId)];
        if (conversation != nil) {
            TGChannelConversationCompanion *companion = [[TGChannelConversationCompanion alloc] initWithPeerId:conversationId conversation:conversation];
            //if (atMessage != nil)
            //    [companion setPreferredInitialMessagePositioning:[atMessage[@"mid"] intValue]];
            [companion setInitialMessagePayloadWithForwardMessages:performActions[@"forwardMessages"] sendMessages:performActions[@"sendMessages"] sendFiles:performActions[@"sendFiles"]];
            [companion setOthersUnreadCount:MAX(globalUnreadCount - conversationUnreadCount, 0)];
            conversationController.companion = companion;
        }
    }
    else if (conversationId <= INT_MIN)
    {
        if ([TGDatabaseInstance() isConversationBroadcast:conversationId])
        {
            TGBroadcastModernConversationCompanion *companion = [[TGBroadcastModernConversationCompanion alloc] initWithConversationId:conversation.conversationId conversation:conversation];
            if (atMessage != nil)
                [companion setPreferredInitialMessagePositioning:[atMessage[@"mid"] intValue]];
            [companion setInitialMessagePayloadWithForwardMessages:performActions[@"forwardMessages"] sendMessages:performActions[@"sendMessages"] sendFiles:performActions[@"sendFiles"]];
            [companion setOthersUnreadCount:MAX(globalUnreadCount - conversationUnreadCount, 0)];
            conversationController.companion = companion;
        }
        else
        {
            int64_t encryptedConversationId = [TGDatabaseInstance() encryptedConversationIdForPeerId:conversationId];
            int64_t accessHash = [TGDatabaseInstance() encryptedConversationAccessHash:conversationId];
            int32_t uid = [TGDatabaseInstance() encryptedParticipantIdForConversationId:conversationId];
            TGSecretModernConversationCompanion *companion = [[TGSecretModernConversationCompanion alloc] initWithEncryptedConversationId:encryptedConversationId accessHash:accessHash conversationId:conversationId uid:uid activity:[TGTelegraphInstance typingUserActivitiesInConversationFromMainThread:conversationId][@(uid)] mayHaveUnreadMessages:conversationUnreadCount != 0];
            if (atMessage != nil)
                [companion setPreferredInitialMessagePositioning:[atMessage[@"mid"] intValue]];
            [companion setInitialMessagePayloadWithForwardMessages:performActions[@"forwardMessages"] sendMessages:performActions[@"sendMessages"] sendFiles:performActions[@"sendFiles"]];
            [companion setOthersUnreadCount:MAX(globalUnreadCount - conversationUnreadCount, 0)];
            conversationController.companion = companion;
        }
    }
    else if (conversationId < 0)
    {
        TGConversation *cachedConversation = [TGDatabaseInstance() loadConversationWithIdCached:conversationId];
        TGGroupModernConversationCompanion *companion = [[TGGroupModernConversationCompanion alloc] initWithConversationId:conversationId conversation:cachedConversation userActivities:[TGTelegraphInstance typingUserActivitiesInConversationFromMainThread:conversationId] mayHaveUnreadMessages:conversationUnreadCount != 0];
        if (atMessage != nil)
            [companion setPreferredInitialMessagePositioning:[atMessage[@"mid"] intValue]];
        [companion setInitialMessagePayloadWithForwardMessages:performActions[@"forwardMessages"] sendMessages:performActions[@"sendMessages"] sendFiles:performActions[@"sendFiles"]];
        [companion setOthersUnreadCount:MAX(globalUnreadCount - conversationUnreadCount, 0)];
        conversationController.companion = companion;
    }
    else
    {
        TGPrivateModernConversationCompanion *companion = [[TGPrivateModernConversationCompanion alloc] initWithUid:(int)conversationId activity:[TGTelegraphInstance typingUserActivitiesInConversationFromMainThread:conversationId][@((int)conversationId)] mayHaveUnreadMessages:conversationUnreadCount != 0];
        companion.botStartPayload = performActions[@"botStartPayload"];
        if (atMessage != nil)
            [companion setPreferredInitialMessagePositioning:[atMessage[@"mid"] intValue]];
        [companion setInitialMessagePayloadWithForwardMessages:performActions[@"forwardMessages"] sendMessages:performActions[@"sendMessages"] sendFiles:performActions[@"sendFiles"]];
        [companion setOthersUnreadCount:MAX(globalUnreadCount - conversationUnreadCount, 0)];
        conversationController.companion = companion;
    }
    
    [conversationController.companion bindController:conversationController];
    
    conversationController.shouldIgnoreAppearAnimationOnce = true;
    if (performActions[@"text"] != nil)
        [conversationController setInputText:performActions[@"text"] replace:false];
    
    return conversationController;
}

- (TGModernConversationController *)currentControllerWithPeerId:(int64_t)peerId
{
    for (UIViewController *viewController in TGAppDelegateInstance.rootController.viewControllers)
    {
        if ([viewController isKindOfClass:[TGModernConversationController class]])
        {
            TGModernConversationController *existingConversationController = (TGModernConversationController *)viewController;
            id companion = existingConversationController.companion;
            if ([companion isKindOfClass:[TGGenericModernConversationCompanion class]])
            {
                if (((TGGenericModernConversationCompanion *)companion).conversationId == peerId)
                    return existingConversationController;
            }
        }
    }
    
    return nil;
}

- (void)dismissConversation
{
    [TGAppDelegateInstance.rootController clearContentControllers];
    [TGAppDelegateInstance.rootController.dialogListController selectConversationWithId:0];
}

- (void)navigateToConversationWithBroadcastUids:(NSArray *)__unused broadcastUids forwardMessages:(NSArray *)__unused forwardMessages
{
}

- (void)navigateToProfileOfUser:(int)uid
{
    [self navigateToProfileOfUser:uid preferNativeContactId:0];
}

- (void)navigateToProfileOfUser:(int)uid shareVCard:(void (^)())shareVCard
{
    TGUser *user = [TGDatabaseInstance() loadUser:uid];
    if (user.kind == TGUserKindBot || user.kind == TGUserKindSmartBot)
    {
        TGBotUserInfoController *userInfoController = [[TGBotUserInfoController alloc] initWithUid:uid sendCommand:nil];
        [TGAppDelegateInstance.rootController pushContentController:userInfoController];
    }
    else
    {
        TGTelegraphUserInfoController *userInfoController = [[TGTelegraphUserInfoController alloc] initWithUid:uid];
        userInfoController.shareVCard = shareVCard;
        [TGAppDelegateInstance.rootController pushContentController:userInfoController];
    }
}

- (void)navigateToProfileOfUser:(int)uid encryptedConversationId:(int64_t)encryptedConversationId
{
    [self navigateToProfileOfUser:uid preferNativeContactId:0 encryptedConversationId:encryptedConversationId];
}

- (void)navigateToProfileOfUser:(int)uid preferNativeContactId:(int)preferNativeContactId
{
    [self navigateToProfileOfUser:uid preferNativeContactId:preferNativeContactId encryptedConversationId:0];
}

- (void)navigateToProfileOfUser:(int)uid preferNativeContactId:(int)__unused preferNativeContactId encryptedConversationId:(int64_t)encryptedConversationId
{
    if (encryptedConversationId == 0)
    {
        TGUser *user = [TGDatabaseInstance() loadUser:uid];
        
        if (user.kind == TGUserKindBot || user.kind == TGUserKindSmartBot)
        {
            TGBotUserInfoController *userInfoController = [[TGBotUserInfoController alloc] initWithUid:uid sendCommand:nil];
            [TGAppDelegateInstance.rootController pushContentController:userInfoController];
        }
        else
        {
            TGTelegraphUserInfoController *userInfoController = [[TGTelegraphUserInfoController alloc] initWithUid:uid];
            [TGAppDelegateInstance.rootController pushContentController:userInfoController];
        }
    }
    else
    {
        TGSecretChatUserInfoController *secretChatInfoController = [[TGSecretChatUserInfoController alloc] initWithUid:uid encryptedConversationId:encryptedConversationId];
        [TGAppDelegateInstance.rootController pushContentController:secretChatInfoController];
    }
}

- (void)navigateToMediaListOfConversation:(int64_t)conversationId navigationController:(UINavigationController *)navigationController
{
    if (conversationId == 0)
        return;
    
    TGGenericPeerMediaListModel *model = [[TGGenericPeerMediaListModel alloc] initWithPeerId:conversationId allowActions:conversationId > INT_MIN];
    
    TGModernMediaListController *controller = [[TGModernMediaListController alloc] init];
    controller.model = model;
    
    //TGPhotoGridController *photoController = [[TGPhotoGridController alloc] initWithConversationId:conversationId isEncrypted:conversationId <= INT_MIN];
    [navigationController pushViewController:controller animated:true];
}

- (void)displayBannerIfNeeded:(TGMessage *)message conversationId:(int64_t)conversationId
{
    if (TGAppDelegateInstance.rootController.currentSizeClass == UIUserInterfaceSizeClassRegular || !TGAppDelegateInstance.bannerEnabled) {
        return;
    }
    
    [ActionStageInstance() dispatchOnStageQueue:^
    {
        TGUser *user = nil;
        TGConversation *conversation = nil;
        if (conversationId < 0)
            conversation = [TGDatabaseInstance() loadConversationWithId:conversationId];
        
        if (TGPeerIdIsChannel(conversationId) && message.fromUid == conversationId) {
            user = [[TGUser alloc] init];
            user.firstName = conversation.chatTitle;
            user.photoUrlSmall = conversation.chatPhotoSmall;
            user.customProperties = @{@"groupPeerId": @(conversationId)};
        } else {
            user = [TGDatabaseInstance() loadUser:(int)message.fromUid];;
        }
        
        if (user != nil && (conversationId > 0 || conversation != nil))
        {
            dispatch_async(dispatch_get_main_queue(), ^
            {
                if ([UIApplication sharedApplication] == nil || [UIApplication sharedApplication].applicationState != UIApplicationStateActive)
                    return;
                
                bool hasModalController = false;
                
                hasModalController = TGAppDelegateInstance.rootController.presentedViewController != nil;
                
                if (hasModalController)
                    return;
                
                TGModernConversationController *conversationController = nil;
                for (UIViewController *viewController in TGAppDelegateInstance.rootController.viewControllers)
                {
                    if ([viewController isKindOfClass:[TGModernConversationController class]])
                    {
                        TGModernConversationController *existingConversationController = (TGModernConversationController *)viewController;
                        TGGenericModernConversationCompanion *existingConversationCompanion = (TGGenericModernConversationCompanion *)existingConversationController.companion;
                        if (existingConversationCompanion.conversationId == conversationId)
                        {
                            conversationController = existingConversationController;
                            break;
                        }
                    }
                }
                if (conversationController == nil || conversationController != TGAppDelegateInstance.rootController.viewControllers.lastObject)
                {
                    int timeout = 5;
                    
                    NSMutableDictionary *users = nil;
                    
                    if (message.mediaAttachments.count != 0)
                    {
                        users = [[NSMutableDictionary alloc] initWithCapacity:1];
                        
                        if (user != nil)
                            [users setObject:user forKey:@"author"];
                        
                        for (TGMediaAttachment *attachment in message.mediaAttachments)
                        {
                            if (attachment.type == TGActionMediaAttachmentType)
                            {
                                TGActionMediaAttachment *actionAttachment = (TGActionMediaAttachment *)attachment;
                                switch (actionAttachment.actionType)
                                {
                                    case TGMessageActionChatAddMember:
                                    case TGMessageActionChatDeleteMember:
                                    {
                                        NSNumber *nUid = [actionAttachment.actionData objectForKey:@"uid"];
                                        if (nUid != nil)
                                        {
                                            TGUser *subjectUser = [TGDatabaseInstance() loadUser:[nUid intValue]];
                                            if (subjectUser != nil)
                                                [users setObject:subjectUser forKey:[[NSNumber alloc] initWithInt:subjectUser.uid]];
                                        }
                                        
                                        break;
                                    }
                                    default:
                                        break;
                                }
                            }
                        }
                    }
                    
                    [TGAppDelegateInstance displayNotification:@"message" timeout:timeout constructor:^UIView *(UIView *existingView)
                    {
                        TGMessageNotificationView *messageView = (TGMessageNotificationView *)existingView;
                        if (messageView == nil)
                            messageView = [[TGMessageNotificationView alloc] initWithFrame:CGRectMake(0, 0, 320, 45)];
                        
                        messageView.messageText = message.text;
                        messageView.authorUid = (int)message.fromUid;
                        messageView.conversationId = message.cid;
                        messageView.users = users;
                        messageView.messageAttachments = message.mediaAttachments;
                        messageView.avatarUrl = user.photoUrlSmall;
                        messageView.titleText = conversationId < 0 && conversationId > INT_MIN ? [[NSString alloc] initWithFormat:@"%@@%@", user.displayName, conversation.chatTitle] : user.displayName;
                        messageView.firstName = user.firstName;
                        messageView.lastName = user.lastName;
                        messageView.isLocationNotification = false;
                        [messageView resetView];
                        
                        return messageView;
                    } watcher:_actionHandle watcherAction:@"navigateToConversation" watcherOptions:[[NSDictionary alloc] initWithObjectsAndKeys:[NSNumber numberWithLongLong:conversationId], @"conversationId", nil]];
                }
            });
        }
    }];
}

- (void)dismissBannerForConversationId:(int64_t)conversationId
{
    UIView *currentNotificationView = [TGAppDelegateInstance currentNotificationView];
    if (currentNotificationView != nil && [currentNotificationView isKindOfClass:[TGMessageNotificationView class]])
    {
        if (((TGMessageNotificationView *)currentNotificationView).conversationId == conversationId)
            [TGAppDelegateInstance dismissNotification];
    }
}

- (void)displayNearbyBannerIdNeeded:(int)peopleCount
{
    if (!TGAppDelegateInstance.locationTranslationEnabled || peopleCount <= 0)
        return;
    
    dispatch_async(dispatch_get_main_queue(), ^
    {
        if ([UIApplication sharedApplication] == nil || [UIApplication sharedApplication].applicationState != UIApplicationStateActive)
            return;
        
        [TGAppDelegateInstance displayNotification:@"message" timeout:5 constructor:^UIView *(UIView *existingView)
        {
            TGMessageNotificationView *messageView = (TGMessageNotificationView *)existingView;
            if (messageView == nil)
            {
                messageView = [[TGMessageNotificationView alloc] initWithFrame:CGRectMake(0, 0, 320, 45)];
            }
            
            messageView.authorUid = 0;
            messageView.messageText = nil;
            messageView.avatarUrl = nil;
            messageView.titleText = peopleCount == 1 ? @"1 person nearby" : [[NSString alloc] initWithFormat:@"%d people are nearby", peopleCount];
            messageView.isLocationNotification = true;
            [messageView resetView];
            
            return messageView;
        } watcher:_actionHandle watcherAction:@"navigateToPeopleNearby" watcherOptions:nil];
    });
}

- (void)actionStageActionRequested:(NSString *)action options:(NSDictionary *)options
{
    if ([action isEqualToString:@"navigateToConversation"])
    {
        if (TGAppDelegateInstance.contentWindow != nil)
            return;
        
        int64_t conversationId = [[options objectForKey:@"conversationId"] longLongValue];
        if (conversationId == 0)
            return;
        
        if (conversationId < 0)
        {
            if ([TGDatabaseInstance() loadConversationWithId:conversationId] == nil)
                return;
        }
        
        UIViewController *presentedViewController = [TGAppDelegateInstance.rootController presentedViewController];
        
        if (presentedViewController != nil)
        {
            [TGAppDelegateInstance.rootController dismissViewControllerAnimated:true completion:nil];
        }
        
        [self navigateToConversationWithId:conversationId conversation:nil animated:presentedViewController == nil];
    }
}

- (void)actionStageResourceDispatched:(NSString *)__unused path resource:(id)__unused resource arguments:(id)__unused arguments
{
}

@end
