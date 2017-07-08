#import "TGInterfaceManager.h"

#import "TGAppDelegate.h"
#import "TGTelegraph.h"
#import "TGTelegramNetworking.h"

#import "TGTelegraph.h"
#import "TGMessage.h"
#import "TGPeerIdAdapter.h"
#import "TGBotReplyMarkup.h"

#import "TGDatabase.h"
#import "TGImageUtils.h"

#import "TGNavigationBar.h"

#import "TGLinearProgressView.h"

#import "TGModernConversationController.h"
#import "TGGroupModernConversationCompanion.h"
#import "TGPrivateModernConversationCompanion.h"
#import "TGSecretModernConversationCompanion.h"
#import "TGChannelConversationCompanion.h"

#import "TGTelegraphUserInfoController.h"
#import "TGSecretChatUserInfoController.h"
#import "TGPhonebookUserInfoController.h"
#import "TGBotUserInfoController.h"

#import "TGGenericPeerMediaListModel.h"
#import "TGModernMediaListController.h"

#import "TGOverlayControllerWindow.h"
#import "TGOverlayController.h"
#import "TGNotificationController.h"

#import "TGSharedMediaController.h"
#import "TGEmbedPIPController.h"

#import "TGAlertView.h"

#import "TGCallSession.h"
#import "TGCallController.h"
#import "TGCallStatusBarView.h"
#import "TGCallAlertView.h"
#import "TGCallUtils.h"

#import "TGAccessChecker.h"

#import "TGCallRatingView.h"

#import "TGAdminLogConversationCompanion.h"

@interface TGInterfaceManager ()
{
    TGNotificationController *_notificationController;
    SMetaDisposable *_incomingCallsDisposable;
    
    SPipe *_conversationControllerPipe;
    SPipe *_callControllerPipe;
    
    int32_t _startupTime;
}

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
        _conversationControllerPipe = [[SPipe alloc] init];
        _callControllerPipe = [[SPipe alloc] init];
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

- (void)resetStartupTime:(NSTimeInterval)value
{
    _startupTime = (int32_t)value;
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
    [self navigateToConversationWithId:conversationId conversation:conversation performActions:performActions atMessage:nil clearStack:true openKeyboard:false canOpenKeyboardWhileInTransition:false animated:animated];
}

- (void)navigateToConversationWithId:(int64_t)conversationId conversation:(TGConversation *)__unused conversation performActions:(NSDictionary *)performActions atMessage:(NSDictionary *)atMessage clearStack:(bool)clearStack openKeyboard:(bool)openKeyboard canOpenKeyboardWhileInTransition:(bool)canOpenKeyboardWhileInTransition animated:(bool)animated
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
    
    if (conversationController == nil || (atMessage[@"mid"] != nil && ![atMessage[@"openMedia"] boolValue] && ![atMessage[@"useExisting"] boolValue]))
    {
        int conversationUnreadCount = [TGDatabaseInstance() unreadCountForConversation:conversationId];
        int globalUnreadCount = [TGDatabaseInstance() cachedUnreadCount];
        
        conversationController = [[TGModernConversationController alloc] init];
        conversationController.shouldOpenKeyboardOnce = openKeyboard;
        conversationController.canOpenKeyboardWhileInTransition = canOpenKeyboardWhileInTransition;
        
        if (TGPeerIdIsChannel(conversationId))
        {
            conversation = [TGDatabaseInstance() loadChannels:@[@(conversationId)]][@(conversationId)];
            if (conversation != nil) {
                if (conversation.hasExplicitContent) {
                    [TGAppDelegateInstance.rootController.dialogListController selectConversationWithId:0];
                    
                    [[[TGAlertView alloc] initWithTitle:TGLocalized(@"ExplicitContent.AlertTitle") message:conversation.restrictionReason.length == 0 ? TGLocalized(@"ExplicitContent.AlertChannel") : [self explicitContentReason:conversation.restrictionReason] cancelButtonTitle:TGLocalized(@"Common.OK") okButtonTitle:nil completionBlock:nil] show];
                    
                    return;
                }
                TGChannelConversationCompanion *companion = [[TGChannelConversationCompanion alloc] initWithConversation:conversation userActivities:[TGTelegraphInstance typingUserActivitiesInConversationFromMainThread:conversationId]];
                if (atMessage != nil)
                    [companion setPreferredInitialMessagePositioning:[atMessage[@"mid"] intValue] pipLocation:atMessage[@"pipLocation"]];
                [companion setInitialMessagePayloadWithForwardMessages:performActions[@"forwardMessages"] sendMessages:performActions[@"sendMessages"] sendFiles:performActions[@"sendFiles"]];
                [companion setOthersUnreadCount:MAX(globalUnreadCount - conversationUnreadCount, 0)];
                conversationController.companion = companion;
            }
        }
        else if (conversationId <= INT_MIN)
        {
            int64_t encryptedConversationId = [TGDatabaseInstance() encryptedConversationIdForPeerId:conversationId];
            int64_t accessHash = [TGDatabaseInstance() encryptedConversationAccessHash:conversationId];
            int32_t uid = [TGDatabaseInstance() encryptedParticipantIdForConversationId:conversationId];
            TGConversation *conversation = [TGDatabaseInstance() loadConversationWithId:conversationId];
            TGSecretModernConversationCompanion *companion = [[TGSecretModernConversationCompanion alloc] initWithConversation:conversation encryptedConversationId:encryptedConversationId accessHash:accessHash uid:uid activity:[TGTelegraphInstance typingUserActivitiesInConversationFromMainThread:conversationId][@(uid)] mayHaveUnreadMessages:conversationUnreadCount != 0];
            if (atMessage != nil)
                [companion setPreferredInitialMessagePositioning:[atMessage[@"mid"] intValue] pipLocation:atMessage[@"pipLocation"]];
            [companion setInitialMessagePayloadWithForwardMessages:performActions[@"forwardMessages"] sendMessages:performActions[@"sendMessages"] sendFiles:performActions[@"sendFiles"]];
            [companion setOthersUnreadCount:MAX(globalUnreadCount - conversationUnreadCount, 0)];
            conversationController.companion = companion;
        }
        else if (conversationId < 0)
        {
            TGConversation *conversation = [TGDatabaseInstance() loadConversationWithId:conversationId];
            if (conversation == nil) {
                conversation = [[TGConversation alloc] initWithConversationId:conversationId unreadCount:0 serviceUnreadCount:0];
            }
            TGGroupModernConversationCompanion *companion = [[TGGroupModernConversationCompanion alloc] initWithConversation:conversation userActivities:[TGTelegraphInstance typingUserActivitiesInConversationFromMainThread:conversationId] mayHaveUnreadMessages:conversationUnreadCount != 0];
            if (atMessage != nil)
                [companion setPreferredInitialMessagePositioning:[atMessage[@"mid"] intValue] pipLocation:atMessage[@"pipLocation"]];
            [companion setInitialMessagePayloadWithForwardMessages:performActions[@"forwardMessages"] sendMessages:performActions[@"sendMessages"] sendFiles:performActions[@"sendFiles"]];
            [companion setOthersUnreadCount:MAX(globalUnreadCount - conversationUnreadCount, 0)];
            conversationController.companion = companion;
        }
        else
        {
            TGUser *user = [TGDatabaseInstance() loadUser:(int32_t)conversationId];
            if (user.hasExplicitContent) {
                [TGAppDelegateInstance.rootController.dialogListController selectConversationWithId:0];
                
                [[[TGAlertView alloc] initWithTitle:TGLocalized(@"ExplicitContent.AlertTitle") message:user.restrictionReason.length == 0 ? TGLocalized(@"ExplicitContent.AlertUser") : [self explicitContentReason:user.restrictionReason] cancelButtonTitle:TGLocalized(@"Common.OK") okButtonTitle:nil completionBlock:nil] show];
                
                return;
            }
            
            TGConversation *conversation = [TGDatabaseInstance() loadConversationWithId:conversationId];
            if (conversation == nil) {
                conversation = [[TGConversation alloc] initWithConversationId:conversationId unreadCount:0 serviceUnreadCount:0];
            }
            TGPrivateModernConversationCompanion *companion = [[TGPrivateModernConversationCompanion alloc] initWithConversation:conversation activity:[TGTelegraphInstance typingUserActivitiesInConversationFromMainThread:conversationId][@((int)conversationId)] mayHaveUnreadMessages:conversationUnreadCount != 0];
            companion.botStartPayload = performActions[@"botStartPayload"];
            companion.botContextPeerId = performActions[@"contextPeerId"];
            companion.botAutostartPayload = performActions[@"botAutostartPayload"];
            if (atMessage != nil)
                [companion setPreferredInitialMessagePositioning:[atMessage[@"mid"] intValue] pipLocation:atMessage[@"pipLocation"]];
            [companion setInitialMessagePayloadWithForwardMessages:performActions[@"forwardMessages"] sendMessages:performActions[@"sendMessages"] sendFiles:performActions[@"sendFiles"]];
            [companion setOthersUnreadCount:MAX(globalUnreadCount - conversationUnreadCount, 0)];
            conversationController.companion = companion;
        }
        
        ((TGGenericModernConversationCompanion *)conversationController.companion).replaceInitialText = performActions[@"replaceInitialText"];
        
        [conversationController.companion bindController:conversationController];
        
        conversationController.shouldIgnoreAppearAnimationOnce = !animated;
        if (performActions[@"text"] != nil) {
            [conversationController setInputText:performActions[@"text"] replace:[performActions[@"textReplace"] boolValue] selectRange:NSMakeRange(0, 0)];
        }
        
        if (performActions[@"shareLink"] != nil && ((NSDictionary *)performActions[@"shareLink"])[@"url"] != nil) {
            NSString *url = performActions[@"shareLink"][@"url"];
            NSString *text = performActions[@"shareLink"][@"text"];
            NSString *result = @"";
            NSRange textRange = NSMakeRange(0, 0);
            if (text.length != 0) {
                result = [[url stringByAppendingString:@"\n"] stringByAppendingString:text];
                textRange = NSMakeRange(url.length + 1, result.length - url.length - 1);
            } else {
                result = url;
            }
            [conversationController setInputText:result replace:true selectRange:textRange];
            conversationController.shouldOpenKeyboardOnce = true;
        }
        
        if (clearStack) {
            [TGAppDelegateInstance.rootController replaceContentController:conversationController];
        } else {
            [TGAppDelegateInstance.rootController pushContentController:conversationController];
        }
        
        __weak TGModernConversationController *weakController = conversationController;
        _conversationControllerPipe.sink(weakController);
    }
    else
    {
        if ([(NSArray *)performActions[@"forwardMessages"] count] != 0)
            [(TGGenericModernConversationCompanion *)conversationController.companion standaloneForwardMessages:performActions[@"forwardMessages"]];
        
        if ([(NSArray *)performActions[@"sendMessages"] count] != 0)
            [(TGGenericModernConversationCompanion *)conversationController.companion standaloneSendMessages:performActions[@"sendMessages"]];
        
        if ([(NSArray *)performActions[@"sendFiles"] count] != 0)
            [(TGGenericModernConversationCompanion *)conversationController.companion standaloneSendFiles:performActions[@"sendFiles"]];
        
        if (performActions[@"text"] != nil) {
            [conversationController setInputText:performActions[@"text"] replace:[performActions[@"textReplace"] boolValue] selectRange:NSMakeRange(0, 0)];
        }
        
        if (performActions[@"shareLink"] != nil && ((NSDictionary *)performActions[@"shareLink"])[@"url"] != nil) {
            NSString *url = performActions[@"shareLink"][@"url"];
            NSString *text = performActions[@"shareLink"][@"text"];
            NSString *result = @"";
            NSRange textRange = NSMakeRange(0, 0);
            if (text.length != 0) {
                result = [[url stringByAppendingString:@"\n"] stringByAppendingString:text];
                textRange = NSMakeRange(url.length + 1, result.length - url.length - 1);
            } else {
                result = url;
            }
            [conversationController setInputText:result replace:true selectRange:textRange];
            conversationController.shouldOpenKeyboardOnce = true;
        }
        
        if (performActions[@"replaceInitialText"] != nil) {
            [conversationController setInputText:performActions[@"replaceInitialText"] replace:true selectRange:NSMakeRange(0, 0)];
            conversationController.shouldOpenKeyboardOnce = true;
        }
        
        if (performActions[@"botStartPayload"] != nil)
        {
            if ([conversationController.companion isKindOfClass:[TGPrivateModernConversationCompanion class]])
            {
                [(TGPrivateModernConversationCompanion *)conversationController.companion standaloneSendBotStartPayload:performActions[@"botStartPayload"]];
            }
        }
        
        bool dontPop = false;
        if ([atMessage[@"mid"] intValue] != 0)
        {
            int mid = [atMessage[@"mid"] intValue];
            
            [conversationController.companion navigateToMessageId:mid scrollBackMessageId:0 animated:true];
        
            if ([atMessage[@"openMedia"] boolValue])
            {
                if (atMessage[@"pipLocation"])
                {
                    dontPop = [conversationController openPIPSourceLocation:atMessage[@"pipLocation"]];
                }
                else
                {
                    [conversationController openMediaFromMessage:mid cancelPIP:false];
                }
            }
        }
        
        if (!dontPop)
            [TGAppDelegateInstance.rootController popToContentController:conversationController];
        
        if (openKeyboard)
            [conversationController openKeyboard];
    }
}

- (void)navigateToChannelLogWithConversation:(TGConversation *)conversation animated:(bool)animated {
    TGModernConversationController *conversationController = [[TGModernConversationController alloc] init];
    
    TGAdminLogConversationCompanion *companion = [[TGAdminLogConversationCompanion alloc] initWithConversation:conversation];
    conversationController.companion = companion;
    
    [conversationController.companion bindController:conversationController];
    
    conversationController.shouldIgnoreAppearAnimationOnce = !animated;
    
    if (false) {
        [TGAppDelegateInstance.rootController replaceContentController:conversationController];
    } else {
        [TGAppDelegateInstance.rootController pushContentController:conversationController];
    }
    
    __weak TGModernConversationController *weakController = conversationController;
    _conversationControllerPipe.sink(weakController);
}

- (NSString *)explicitContentReason:(NSString *)text {
    NSRange range = [text rangeOfString:@":"];
    if (range.location != NSNotFound) {
        return [text substringFromIndex:range.location + range.length];
    } else {
        return text;
    }
}

- (TGModernConversationController *)configuredPreviewConversationControlerWithId:(int64_t)conversationId {
    return [self configuredPreviewConversationControlerWithId:conversationId performActions:nil];
}

- (TGModernConversationController *)configuredPreviewConversationControlerWithId:(int64_t)conversationId performActions:(NSDictionary *)performActions {
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
            if (conversation.hasExplicitContent) {
                [TGAppDelegateInstance.rootController.dialogListController selectConversationWithId:0];
                
                [[[TGAlertView alloc] initWithTitle:TGLocalized(@"ExplicitContent.AlertTitle") message:conversation.restrictionReason.length == 0 ? TGLocalized(@"ExplicitContent.AlertChannel") : [self explicitContentReason:conversation.restrictionReason] cancelButtonTitle:TGLocalized(@"Common.OK") okButtonTitle:nil completionBlock:nil] show];
                
                return nil;
            }
            
            TGChannelConversationCompanion *companion = [[TGChannelConversationCompanion alloc] initWithConversation:conversation userActivities:nil];
            companion.previewMode = true;
            //if (atMessage != nil)
            //    [companion setPreferredInitialMessagePositioning:[atMessage[@"mid"] intValue]];
            [companion setInitialMessagePayloadWithForwardMessages:performActions[@"forwardMessages"] sendMessages:performActions[@"sendMessages"] sendFiles:performActions[@"sendFiles"]];
            [companion setOthersUnreadCount:MAX(globalUnreadCount - conversationUnreadCount, 0)];
            conversationController.companion = companion;
        }
    }
    else if (conversationId <= INT_MIN)
    {
        int64_t encryptedConversationId = [TGDatabaseInstance() encryptedConversationIdForPeerId:conversationId];
        int64_t accessHash = [TGDatabaseInstance() encryptedConversationAccessHash:conversationId];
        int32_t uid = [TGDatabaseInstance() encryptedParticipantIdForConversationId:conversationId];
        TGConversation *conversation = [TGDatabaseInstance() loadConversationWithId:conversationId];
        if (conversation == nil) {
            conversation = [[TGConversation alloc] initWithConversationId:conversationId unreadCount:0 serviceUnreadCount:0];
        }
        TGSecretModernConversationCompanion *companion = [[TGSecretModernConversationCompanion alloc] initWithConversation:conversation encryptedConversationId:encryptedConversationId accessHash:accessHash uid:uid activity:[TGTelegraphInstance typingUserActivitiesInConversationFromMainThread:conversationId][@(uid)] mayHaveUnreadMessages:conversationUnreadCount != 0];
        companion.previewMode = true;
        if (atMessage != nil)
            [companion setPreferredInitialMessagePositioning:[atMessage[@"mid"] intValue] pipLocation:atMessage[@"pipLocation"]];
        [companion setInitialMessagePayloadWithForwardMessages:performActions[@"forwardMessages"] sendMessages:performActions[@"sendMessages"] sendFiles:performActions[@"sendFiles"]];
        [companion setOthersUnreadCount:MAX(globalUnreadCount - conversationUnreadCount, 0)];
        conversationController.companion = companion;
    }
    else if (conversationId < 0)
    {
        TGConversation *conversation = [TGDatabaseInstance() loadConversationWithId:conversationId];
        if (conversation == nil) {
            conversation = [[TGConversation alloc] initWithConversationId:conversationId unreadCount:0 serviceUnreadCount:0];
        }
        TGGroupModernConversationCompanion *companion = [[TGGroupModernConversationCompanion alloc] initWithConversation:conversation userActivities:[TGTelegraphInstance typingUserActivitiesInConversationFromMainThread:conversationId] mayHaveUnreadMessages:conversationUnreadCount != 0];
        companion.previewMode = true;
        if (atMessage != nil)
            [companion setPreferredInitialMessagePositioning:[atMessage[@"mid"] intValue] pipLocation:atMessage[@"pipLocation"]];
        [companion setInitialMessagePayloadWithForwardMessages:performActions[@"forwardMessages"] sendMessages:performActions[@"sendMessages"] sendFiles:performActions[@"sendFiles"]];
        [companion setOthersUnreadCount:MAX(globalUnreadCount - conversationUnreadCount, 0)];
        conversationController.companion = companion;
    }
    else
    {
        TGUser *user = [TGDatabaseInstance() loadUser:(int32_t)conversationId];
        if (user.hasExplicitContent) {
            [TGAppDelegateInstance.rootController.dialogListController selectConversationWithId:0];
            
            [[[TGAlertView alloc] initWithTitle:TGLocalized(@"ExplicitContent.AlertTitle") message:user.restrictionReason.length == 0 ? TGLocalized(@"ExplicitContent.AlertUser") : [self explicitContentReason:user.restrictionReason] cancelButtonTitle:TGLocalized(@"Common.OK") okButtonTitle:nil completionBlock:nil] show];
            
            return nil;
        }
        
        TGConversation *conversation = [TGDatabaseInstance() loadConversationWithId:conversationId];
        if (conversation == nil) {
            conversation = [[TGConversation alloc] initWithConversationId:conversationId unreadCount:0 serviceUnreadCount:0];
        }
        TGPrivateModernConversationCompanion *companion = [[TGPrivateModernConversationCompanion alloc] initWithConversation:conversation activity:[TGTelegraphInstance typingUserActivitiesInConversationFromMainThread:conversationId][@((int)conversationId)] mayHaveUnreadMessages:conversationUnreadCount != 0];
        companion.previewMode = true;
        companion.botStartPayload = performActions[@"botStartPayload"];
        companion.botAutostartPayload = performActions[@"botAutostartPayload"];
        companion.botContextPeerId = performActions[@"contextPeerId"];
        if (atMessage != nil)
            [companion setPreferredInitialMessagePositioning:[atMessage[@"mid"] intValue] pipLocation:atMessage[@"pipLocation"]];
        [companion setInitialMessagePayloadWithForwardMessages:performActions[@"forwardMessages"] sendMessages:performActions[@"sendMessages"] sendFiles:performActions[@"sendFiles"]];
        [companion setOthersUnreadCount:MAX(globalUnreadCount - conversationUnreadCount, 0)];
        conversationController.companion = companion;
    }
    
    [conversationController.companion bindController:conversationController];
    
    conversationController.shouldIgnoreAppearAnimationOnce = true;
    
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
    [self navigateToProfileOfUser:uid preferNativeContactId:0 encryptedConversationId:encryptedConversationId callMessages:nil];
}

- (void)navigateToProfileOfUser:(int)uid callMessages:(NSArray *)callMessages
{
    [self navigateToProfileOfUser:uid preferNativeContactId:0 encryptedConversationId:0 callMessages:callMessages];
}

- (void)navigateToProfileOfUser:(int)uid preferNativeContactId:(int)preferNativeContactId
{
    [self navigateToProfileOfUser:uid preferNativeContactId:preferNativeContactId encryptedConversationId:0 callMessages:nil];
}

- (void)navigateToProfileOfUser:(int)uid preferNativeContactId:(int)__unused preferNativeContactId encryptedConversationId:(int64_t)encryptedConversationId callMessages:(NSArray *)callMessages
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
            TGTelegraphUserInfoController *userInfoController = [[TGTelegraphUserInfoController alloc] initWithUid:uid callMessages:callMessages];
            [TGAppDelegateInstance.rootController pushContentController:userInfoController];
        }
    }
    else
    {
        TGSecretChatUserInfoController *secretChatInfoController = [[TGSecretChatUserInfoController alloc] initWithUid:uid encryptedConversationId:encryptedConversationId];
        [TGAppDelegateInstance.rootController pushContentController:secretChatInfoController];
    }
}

- (void)navigateToSharedMediaOfConversationWithId:(int64_t)conversationId mode:(int)mode atMessage:(NSDictionary *)__unused atMessage
{
    TGSharedMediaController *controller = nil;
    for (UIViewController *viewController in TGAppDelegateInstance.rootController.viewControllers)
    {
        if ([viewController isKindOfClass:[TGSharedMediaController class]])
        {
            TGSharedMediaController *existingController = (TGSharedMediaController *)viewController;
            if (existingController.peerId == conversationId)
            {
                controller = existingController;
                break;
            }
        }
    }

    if (controller != nil)
    {
        if (controller.mode != mode)
            [controller setMode:(TGSharedMediaControllerMode)mode];
    }
    else
    {
        TGConversation *conversation = [TGDatabaseInstance() loadConversationWithId:conversationId];
        controller = [[TGSharedMediaController alloc] initWithPeerId:conversation.conversationId accessHash:conversation.accessHash mode:(TGSharedMediaControllerMode)mode important:!conversation.isChannelGroup];
        [TGAppDelegateInstance.rootController pushContentController:controller];
    }
}

- (void)_initializeNotificationControllerIfNeeded
{
    if (_notificationController == nil)
    {
        _notificationController = [[TGNotificationController alloc] init];
        
        __weak TGInterfaceManager *weakSelf = self;
        void (^navigateBlock)(int64_t) = ^(int64_t conversationId)
        {
            __strong TGInterfaceManager *strongSelf = weakSelf;
            if (strongSelf == nil)
                return;
            
            bool animated = true;
            if (TGAppDelegateInstance.rootController.presentedViewController != nil)
            {
                [TGAppDelegateInstance.rootController dismissViewControllerAnimated:true completion:nil];
                animated = false;
            }
            
            for (UIWindow *window in [UIApplication sharedApplication].windows)
            {
                if ([window isKindOfClass:[TGOverlayControllerWindow class]] && window != _notificationController.window)
                {
                    TGOverlayController *controller = (TGOverlayController *)window.rootViewController;
                    if ([controller isKindOfClass:[TGCallController class]])
                    {
                        [(TGCallController *)controller minimize];
                    }
                    else
                    {
                        [controller dismiss];
                        animated = false;
                    }
                }
            }
            
            [strongSelf navigateToConversationWithId:conversationId conversation:nil animated:animated];
        };
        
        _notificationController.navigateToConversation = ^(int64_t conversationId)
        {
            __strong TGInterfaceManager *strongSelf = weakSelf;
            if (strongSelf == nil)
                return;
            
            if (TGAppDelegateInstance.contentWindow != nil)
                return;
            
            if (conversationId == 0)
                return;
            
            if (conversationId < 0)
            {
                if ([TGDatabaseInstance() loadConversationWithId:conversationId] == nil)
                    return;
            }
            
            UIView<TGPIPAblePlayerView> *playerView = [TGEmbedPIPController activeNonPIPPlayerView];
            if (playerView != nil)
            {
                [playerView switchToPictureInPicture];
                TGDispatchAfter(0.3, dispatch_get_main_queue(), ^
                {
                    navigateBlock(conversationId);
                });
            }
            else
            {
                navigateBlock(conversationId);
            }
        };
    }
}

- (void)displayBannerIfNeeded:(TGMessage *)message conversationId:(int64_t)conversationId
{
    if (TGAppDelegateInstance.isDisplayingPasscodeWindow || !TGAppDelegateInstance.bannerEnabled || TGAppDelegateInstance.rootController.isSplitView)
        return;
    
    if (message.date < _startupTime)
        return;
    
    TGBotReplyMarkup *replyMarkup = message.replyMarkup;
    if (replyMarkup.isInline)
    {
        for (TGBotReplyMarkupRow *row in replyMarkup.rows)
        {
            for (TGBotReplyMarkupButton *button in row.buttons)
            {
                if ([button.action isKindOfClass:[TGBotReplyMarkupButtonActionSwitchInline class]])
                    return;
            }
        }
    }
    
    [ActionStageInstance() dispatchOnStageQueue:^
    {
        TGUser *user = nil;
        TGConversation *conversation = [TGDatabaseInstance() loadConversationWithId:conversationId];
        
        if (!conversation.isChannel || conversation.isChannelGroup)
            user = [TGDatabaseInstance() loadUser:(int)message.fromUid];
        
        if (conversationId > 0 || conversation != nil)
        {
            TGDispatchOnMainThread(^
            {
                if ([UIApplication sharedApplication] == nil || [UIApplication sharedApplication].applicationState != UIApplicationStateActive)
                    return;
                
                [self _initializeNotificationControllerIfNeeded];

                if ([_notificationController shouldDisplayNotificationForConversation:conversation])
                {
                    NSMutableDictionary *peers = [[NSMutableDictionary alloc] init];
                    if (user != nil)
                        peers[@"author"] = user;
                    
                    if (message.mediaAttachments.count != 0)
                    {
                        NSMutableArray *peerIds = [[NSMutableArray alloc] init];
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
                                        if (actionAttachment.actionData[@"uids"] != nil) {
                                            [peerIds addObjectsFromArray:actionAttachment.actionData[@"uids"]];
                                        } else if (actionAttachment.actionData[@"uid"] != nil) {
                                            NSNumber *nUid = [actionAttachment.actionData objectForKey:@"uid"];
                                            [peerIds addObject:nUid];
                                        }
                                        break;
                                    }
                                    default:
                                        break;
                                }
                            }
                            else if (attachment.type == TGReplyMessageMediaAttachmentType)
                            {
                                TGReplyMessageMediaAttachment *replyAttachment = (TGReplyMessageMediaAttachment *)attachment;
                                if (replyAttachment.replyMessage.fromUid != 0)
                                    [peerIds addObject:@(replyAttachment.replyMessage.fromUid)];
                            }
                            else if (attachment.type == TGForwardedMessageMediaAttachmentType)
                            {
                                TGForwardedMessageMediaAttachment *forwardAttachment = (TGForwardedMessageMediaAttachment *)attachment;
                                if (forwardAttachment.forwardPeerId != 0)
                                    [peerIds addObject:@(forwardAttachment.forwardPeerId)];
                            }
                            else if (attachment.type == TGContactMediaAttachmentType)
                            {
                                TGContactMediaAttachment *contactAttachment = (TGContactMediaAttachment *)attachment;
                                if (contactAttachment.uid != 0)
                                    [peerIds addObject:@(contactAttachment.uid)];
                            }
                        }
                        
                        for (NSNumber *peerIdValue in peerIds)
                        {
                            int64_t peerId = peerIdValue.int64Value;
                            if (TGPeerIdIsChannel(peerId))
                            {
                                TGConversation *channel = [TGDatabaseInstance() loadConversationWithId:peerId];
                                if (channel != nil)
                                    peers[@(channel.conversationId)] = channel;
                            }
                            else
                            {
                                TGUser *user = [TGDatabaseInstance() loadUser:(int32_t)peerId];
                                if (user != nil)
                                    peers[@(user.uid)] = user;
                            }
                        }
                    }
                    
                    int32_t replyToMid = (TGPeerIdIsGroup(message.cid) || TGPeerIdIsChannel(message.cid)) ? message.mid : 0;
                    [_notificationController displayNotificationForConversation:conversation identifier:message.mid replyToMid:replyToMid duration:5.0 configure:^(TGNotificationContentView *view, bool *isRepliable)
                    {
                        *isRepliable = (!conversation.isChannel || conversation.isChannelGroup) && (conversation.encryptedData == nil);
                        [view configureWithMessage:message conversation:conversation peers:peers];
                    }];
                }
            });
        }
    }];
}

- (void)dismissBannerForConversationId:(int64_t)conversationId
{
    [_notificationController dismissNotificationsForConversationId:conversationId];
}

- (void)dismissAllBanners
{
    [_notificationController dismissAllNotifications];
}

- (void)localizationUpdated
{
    [_notificationController localizationUpdated];
}

- (void)setupCallManager:(TGCallManager *)callManager
{
    if (_incomingCallsDisposable != nil)
        return;
    
    __weak TGInterfaceManager *weakSelf = self;
    _incomingCallsDisposable = [[SMetaDisposable alloc] init];
    [_incomingCallsDisposable setDisposable:[[[callManager incomingCallInternalIds] deliverOn:[SQueue mainQueue]] startWithNext:^(id next)
    {
        __strong TGInterfaceManager *strongSelf = weakSelf;
        if (strongSelf == nil || ![next respondsToSelector:@selector(intValue)])
            return;
        
        [strongSelf presentCallWithSessionInitializer:^TGCallSession *{
            return [TGTelegraphInstance.callManager sessionForIncomingCallWithInternalId:next];
        } completion:nil];
    }]];
}

- (void)callPeerWithId:(int64_t)peerId
{
    [self callPeerWithId:peerId completion:nil];
}

- (void)callPeerWithId:(int64_t)peerId completion:(void (^)(void))completion
{
    if (peerId == 0)
        return;
    
    if (![TGAccessChecker checkMicrophoneAuthorizationStatusForIntent:TGMicrophoneAccessIntentCall alertDismissCompletion:nil])
        return;
    
    [TGCallController requestMicrophoneAccess:^(bool granted)
    {
        if (!granted)
            return;
        
        TGCallController *currentCallController = nil;
        for (TGOverlayControllerWindow *window in TGAppDelegateInstance.rootController.associatedWindowStack)
        {
            if ([window.rootViewController isKindOfClass:[TGCallController class]])
            {
                TGCallController *callController = (TGCallController *)window.rootViewController;
                if (callController.peerId == peerId)
                {
                    [callController presentController];
                    return;
                }
                
                currentCallController = callController;
            }
        }
        
        void (^actionBlock)(void) = ^
        {
            [self presentCallWithSessionInitializer:^TGCallSession *{
                return [TGTelegraphInstance.callManager sessionForOutgoingCallWithPeerId:peerId];
            } completion:completion];
        };
        
        if (currentCallController != nil)
        {
            TGUser *newUser = [TGDatabaseInstance() loadUser:(int)peerId];
            NSString *message = [NSString stringWithFormat:TGLocalized(@"Call.CallInProgressMessage"), currentCallController.peer.displayName, newUser.displayName];
           
            [[[TGAlertView alloc] initWithTitle:TGLocalized(@"Call.CallInProgressTitle") message:message cancelButtonTitle:TGLocalized(@"Common.No") okButtonTitle:TGLocalized(@"Common.Yes") completionBlock:
            ^(bool okButtonPressed)
            {
                if (okButtonPressed)
                {
                    [[UIApplication sharedApplication] beginIgnoringInteractionEvents];
                    [currentCallController hangUpCallWithCompletion:^
                    {
                        actionBlock();
                        TGDispatchOnMainThread(^
                        {
                            [[UIApplication sharedApplication] endIgnoringInteractionEvents];
                        });
                    }];
                }
            }] show];
        }
        else
        {
            if ([TGCallUtils isOnPhoneCall])
            {
                [[[TGAlertView alloc] initWithTitle:TGLocalized(@"Call.CallInProgressTitle") message:TGLocalized(@"Call.PhoneCallInProgressMessage") cancelButtonTitle:TGLocalized(@"Common.OK") okButtonTitle:nil completionBlock:nil] show];
            }
            else
            {
                actionBlock();
            }
        }
    }];
}

- (void)dismissAllCalls
{
    for (TGOverlayControllerWindow *window in TGAppDelegateInstance.rootController.associatedWindowStack)
    {
        if ([window.rootViewController isKindOfClass:[TGCallController class]])
        {
            TGCallController *callController = (TGCallController *)window.rootViewController;
            [callController hangUpCall];
        }
    }
}

- (bool)hasCallControllerInForeground
{
    for (TGOverlayControllerWindow *window in TGAppDelegateInstance.rootController.associatedWindowStack)
    {
        if ([window.rootViewController isKindOfClass:[TGCallController class]])
            return !window.hidden;
    }
    
    return false;
}

- (void)presentCallWithSessionInitializer:(TGCallSession *(^)(void))sessionInitializer completion:(void (^)(void))completion
{
    [[[TGCallUtils networkTypeSignal] take:1] startWithNext:^(NSNumber *next)
    {
        for (UIWindow *window in [UIApplication sharedApplication].windows)
        {
            if ([window.rootViewController isKindOfClass:[TGCallAlertViewController class]])
            {
                if ([window isKindOfClass:[TGOverlayControllerWindow class]])
                    [(TGOverlayControllerWindow *)window dismiss];
            }
        }
        
        if (next.integerValue == TGCallNetworkTypeNone)
        {
            [[[TGAlertView alloc] initWithTitle:TGLocalized(@"Call.ConnectionErrorTitle") message:TGLocalized(@"Call.ConnectionErrorMessage") cancelButtonTitle:TGLocalized(@"Common.OK") okButtonTitle:nil completionBlock:nil] show];
        }
        else
        {
            TGCallSession *session = sessionInitializer();
            if (session == nil)
                return;
            
            TGCallController *controller = [[TGCallController alloc] initWithSession:session];
            if (completion != nil)
            {
                controller.onTransitionIn = ^
                {
                    completion();
                };
            }
            
            if (TGTelegraphInstance.musicPlayer != nil)
                [TGTelegraphInstance.musicPlayer controlPause];
            
            TGCallControllerWindow *controllerWindow = [[TGCallControllerWindow alloc] initWithParentController:TGAppDelegateInstance.rootController contentController:controller];
            controllerWindow.hidden = false;
            
            if (!TGIsPad())
            {
                CGSize screenSize = TGScreenSize();
                controllerWindow.frame = CGRectMake(0, 0, screenSize.width, screenSize.height);
            }
            
            TGCallStatusBarView *statusBarView = TGAppDelegateInstance.rootController.callStatusBarView;
            [statusBarView setSignal:controller.callDuration];
            
            __weak TGCallController *weakController = controller;
            statusBarView.statusBarPressed = ^
            {
                __strong TGCallController *strongController = weakController;
                if (strongController != nil)
                    [strongController presentController];
            };
            
            _callControllerPipe.sink(@true);
        }
    }];
}

- (void)maybeDisplayCallsTabAlert
{
    UIImageView *imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"CallsTabBarInfo"]];
    [TGCallAlertView presentAlertWithTitle:TGLocalized(@"Calls.CallTabTitle") message:TGLocalized(@"Calls.CallTabDescription") customView:imageView cancelButtonTitle:TGLocalized(@"Calls.NotNow") doneButtonTitle:TGLocalized(@"Calls.AddTab") completionBlock:^(bool done)
    {
        TGAppDelegateInstance.showCallsTab = done;
        if (done)
            [TGAppDelegateInstance.rootController.mainTabsController setCallsHidden:false animated:true];
    }];
}

- (SSignal *)callControllerInForeground
{
    return _callControllerPipe.signalProducer();
}

- (SSignal *)messageVisibilitySignalWithConversationId:(int64_t)conversationId messageId:(int32_t)messageId
{
    SSignal *initialConversationSignal = [[SSignal alloc] initWithGenerator:^id<SDisposable>(SSubscriber *subscriber)
    {
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
        if (conversationController.navigationController.viewControllers.lastObject != conversationController)
            conversationController = nil;
    
        [subscriber putNext:conversationController];
        [subscriber putCompletion];
        
        return nil;
    }];
    
    return [[[initialConversationSignal then:_conversationControllerPipe.signalProducer()] mapToSignal:^SSignal *(TGModernConversationController *controller)
    {
        if (controller != nil)
        {
            id companion = controller.companion;
            if ([companion isKindOfClass:[TGGenericModernConversationCompanion class]])
            {
                if (((TGGenericModernConversationCompanion *)companion).conversationId == conversationId)
                    return [controller messageVisiblitySignalForMessageId:messageId];
            }
            return [SSignal single:@false];
        }
        else
        {
            return [SSignal single:@false];
        }
    }] deliverOn:[SQueue concurrentDefaultQueue]];
}

@end
