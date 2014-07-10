#import "TGSynchronizeServiceActionsActor.h"

#import "ActionStage.h"

#import "TGDatabase.h"

#import "TGTelegraph.h"

#import "TGModernSendSecretMessageActor.h"
#import "TGConversationAddMessagesActor.h"

#import "TLMetaClassStore.h"

@interface TGSynchronizeServiceActionsActor ()

@property (nonatomic) int64_t currentActionUniqueId;
@property (nonatomic) int currentActionType;
@property (nonatomic) int currentActionRandomId;
@property (nonatomic, strong) NSString *currentRequestPath;

@property (nonatomic) NSArray *currentDeleteProfilePhotoItems;

@property (nonatomic) int64_t currentMessageLifetimePeerId;
@property (nonatomic) int currentMessageLifetimeSetting;

@end

@implementation TGSynchronizeServiceActionsActor

+ (NSString *)genericPath
{
    return @"/tg/service/synchronizeserviceactions/@";
}

- (id)initWithPath:(NSString *)path
{
    self = [super initWithPath:path];
    if (self != nil)
    {
        _actionHandle = [[ASHandle alloc] initWithDelegate:self releaseOnMainThread:false];
        
        [ActionStageInstance() watchForPath:@"/tg/service/cancelAcceptEncryptedChat" watcher:self];
        [ActionStageInstance() watchForPath:@"/tg/service/cancelSynchronizeEncryptedChatSettings" watcher:self];
    }
    return self;
}

- (void)dealloc
{
    [_actionHandle reset];
    [ActionStageInstance() removeWatcher:self];
}

- (void)prepare:(NSDictionary *)__unused options
{
    if ([self.path hasSuffix:@"settings)"])
        self.requestQueueName = @"settings";
}

- (void)execute:(NSDictionary *)__unused options
{
    bool completed = true;
    
    if ([self.path hasSuffix:@"settings)"])
    {
        while (true)
        {
            NSArray *futureActions = [TGDatabaseInstance() loadOneFutureAction];
            if (futureActions.count != 0)
            {
                completed = false;
                
                TGFutureAction *action = [futureActions objectAtIndex:0];
                if ([action isKindOfClass:[TGChangeNotificationSettingsFutureAction class]])
                {
                    _currentActionUniqueId = action.uniqueId;
                    _currentActionType = action.type;
                    _currentActionRandomId = action.randomId;
                    
                    TGChangeNotificationSettingsFutureAction *notificationSettingsAction = (TGChangeNotificationSettingsFutureAction *)action;
                    
                    int peerSoundId = notificationSettingsAction.soundId;
                    
                    self.cancelToken = [TGTelegraphInstance doChangePeerNotificationSettings:notificationSettingsAction.uniqueId muteUntil:notificationSettingsAction.muteUntil soundId:peerSoundId previewText:notificationSettingsAction.previewText photoNotificationsEnabled:notificationSettingsAction.photoNotificationsEnabled actor:self];
                    
                    break;
                }
                else if ([action isKindOfClass:[TGClearNotificationsFutureAction class]])
                {
                    _currentActionUniqueId = action.uniqueId;
                    _currentActionType = action.type;
                    _currentActionRandomId = action.randomId;
                    
                    self.cancelToken = [TGTelegraphInstance doResetPeerNotificationSettings:self];
                    
                    break;
                }
                else if ([action isKindOfClass:[TGChangePrivacySettingsFutureAction class]])
                {
                    _currentActionUniqueId = action.uniqueId;
                    _currentActionType = action.type;
                    _currentActionRandomId = action.randomId;
                    
                    TGChangePrivacySettingsFutureAction *changeAction = (TGChangePrivacySettingsFutureAction *)action;
                    
                    self.cancelToken = [TGTelegraphInstance doChangePrivacySettings:changeAction.disableSuggestions hideContacts:changeAction.hideContacts hideLastVisit:changeAction.hideLastVisit hideLocation:changeAction.hideLocation actor:self];
                    
                    break;
                }
                else if ([action isKindOfClass:[TGChangePeerBlockStatusFutureAction class]])
                {
                    _currentActionUniqueId = action.uniqueId;
                    _currentActionType = action.type;
                    _currentActionRandomId = action.randomId;
                    
                    TGChangePeerBlockStatusFutureAction *changeAction = (TGChangePeerBlockStatusFutureAction *)action;
                    
                    self.cancelToken = [TGTelegraphInstance doChangePeerBlockStatus:action.uniqueId block:changeAction.block actor:self];
                    
                    break;
                }
                else if ([action isKindOfClass:[TGSynchronizeEncryptedChatSettingsFutureAction class]])
                {
                    _currentActionUniqueId = action.uniqueId;
                    _currentActionType = action.type;
                    _currentActionRandomId = action.randomId;
                    
                    TGSynchronizeEncryptedChatSettingsFutureAction *settingsAction = (TGSynchronizeEncryptedChatSettingsFutureAction *)action;
                    
                    int64_t peerId = [TGDatabaseInstance() peerIdForEncryptedConversationId:settingsAction.uniqueId createIfNecessary:false];
                    _currentMessageLifetimePeerId = peerId;
                    
                    int64_t accessHash = [TGDatabaseInstance() encryptedConversationAccessHash:peerId];
                    
                    int64_t keyId = 0;
                    NSData *key = [TGDatabaseInstance() encryptionKeyForConversationId:peerId keyFingerprint:&keyId];
                    
                    if (key == nil)
                    {
                        [TGDatabaseInstance() removeFutureAction:_currentActionUniqueId type:_currentActionType randomId:_currentActionRandomId];
                    }
                    else
                    {
                        TLDecryptedMessage$decryptedMessageService *serviceMessage = [[TLDecryptedMessage$decryptedMessageService alloc] init];
                        serviceMessage.random_id = settingsAction.messageRandomId;
                        
                        TLDecryptedMessageAction$decryptedMessageActionSetMessageTTL *serviceAction = [[TLDecryptedMessageAction$decryptedMessageActionSetMessageTTL alloc] init];
                        serviceAction.ttl_seconds = settingsAction.messageLifetime;
                        _currentMessageLifetimeSetting = settingsAction.messageLifetime;
                        serviceMessage.action = serviceAction;
                        
                        NSOutputStream *os = [[NSOutputStream alloc] initToMemory];
                        [os open];
                        TLMetaClassStore::serializeObject(os, serviceMessage, true);
                        NSData *serializedData = [os currentBytes];
                        [os close];
                        
                        self.cancelToken = [TGTelegraphInstance doSendEncryptedServiceMessage:settingsAction.uniqueId accessHash:accessHash randomId:settingsAction.messageRandomId data:[TGModernSendSecretMessageActor encryptMessage:serializedData key:key keyId:keyId] actor:self];
                    }
                    
                    break;
                }
                else if ([action isKindOfClass:[TGEncryptedChatServiceAction class]])
                {
                    _currentActionUniqueId = action.uniqueId;
                    _currentActionType = action.type;
                    _currentActionRandomId = action.randomId;
                    
                    TGEncryptedChatServiceAction *serviceMessageAction = (TGEncryptedChatServiceAction *)action;
                    
                    int64_t peerId = [TGDatabaseInstance() peerIdForEncryptedConversationId:serviceMessageAction.encryptedConversationId createIfNecessary:false];
                    
                    int64_t accessHash = [TGDatabaseInstance() encryptedConversationAccessHash:peerId];
                    
                    int64_t keyId = 0;
                    NSData *key = [TGDatabaseInstance() encryptionKeyForConversationId:peerId keyFingerprint:&keyId];
                    
                    if (key == nil)
                    {
                        [TGDatabaseInstance() removeFutureAction:_currentActionUniqueId type:_currentActionType randomId:_currentActionRandomId];
                    }
                    else
                    {
                        TLDecryptedMessage$decryptedMessageService *serviceMessage = [[TLDecryptedMessage$decryptedMessageService alloc] init];
                        serviceMessage.random_id = serviceMessageAction.messageRandomId;
                        
                        if (serviceMessageAction.action == TGEncryptedChatServiceActionViewMessage)
                        {
                            TLDecryptedMessageAction$decryptedMessageActionViewMessage *viewMessage = [[TLDecryptedMessageAction$decryptedMessageActionViewMessage alloc] init];
                            viewMessage.random_id = serviceMessageAction.actionContext;
                            serviceMessage.action = viewMessage;
                        }
                        else if (serviceMessageAction.action == TGEncryptedChatServiceActionMessageScreenshotTaken)
                        {
                            TLDecryptedMessageAction$decryptedMessageActionScreenshotMessage *screenshotMessage = [[TLDecryptedMessageAction$decryptedMessageActionScreenshotMessage alloc] init];
                            screenshotMessage.random_id = serviceMessageAction.actionContext;
                            serviceMessage.action = screenshotMessage;
                        }
                        else if (serviceMessageAction.action == TGEncryptedChatServiceActionChatScreenshotTaken)
                            serviceMessage.action = [[TLDecryptedMessageAction$decryptedMessageActionScreenshot alloc] init];
                        
                        NSOutputStream *os = [[NSOutputStream alloc] initToMemory];
                        [os open];
                        TLMetaClassStore::serializeObject(os, serviceMessage, true);
                        NSData *serializedData = [os currentBytes];
                        [os close];
                        
                        self.cancelToken = [TGTelegraphInstance doSendEncryptedServiceMessage:serviceMessageAction.encryptedConversationId accessHash:accessHash randomId:serviceMessageAction.messageRandomId data:[TGModernSendSecretMessageActor encryptMessage:serializedData key:key keyId:keyId] actor:self];
                    }
                    
                    break;
                }
                else if ([action isKindOfClass:[TGAcceptEncryptionFutureAction class]])
                {
                    _currentActionUniqueId = action.uniqueId;
                    _currentActionType = action.type;
                    _currentActionRandomId = action.randomId;
                    
                    int64_t peerId = [TGDatabaseInstance() peerIdForEncryptedConversationId:action.uniqueId createIfNecessary:false];
                    int64_t accessHash = [TGDatabaseInstance() encryptedConversationAccessHash:peerId];
                    
                    static int actionId = 0;
                    _currentRequestPath = [[NSString alloc] initWithFormat:@"/tg/encrypted/acceptEncryptedChat/(serviceActions%d)", actionId++];
                    [ActionStageInstance() requestActor:_currentRequestPath options:@{@"encryptedConversationId": @(action.uniqueId), @"accessHash": @(accessHash)} flags:0 watcher:self];
                    
                    break;
                }
                else
                {
                    [TGDatabaseInstance() removeFutureAction:action.uniqueId type:action.type randomId:action.randomId];
                    
                    break;
                }
            }
            else
                break;
        }
    }
    else if ([self.path hasSuffix:@"other)"])
    {
        NSArray *deleteAvatarActions = [TGDatabaseInstance() loadFutureActionsWithType:TGDeleteProfilePhotoFutureActionType];
        if (deleteAvatarActions.count != 0)
        {
            NSMutableArray *photoItems = [[NSMutableArray alloc] init];
            
            for (TGDeleteProfilePhotoFutureAction *action in deleteAvatarActions)
            {
                [photoItems addObject:[[NSDictionary alloc] initWithObjectsAndKeys:[[NSNumber alloc] initWithLongLong:action.imageId], @"imageId", [[NSNumber alloc] initWithLongLong:action.accessHash], @"accessHash", [[NSNumber alloc] initWithInt:action.randomId], @"actionRandomId", nil]];
            }
            
            _currentDeleteProfilePhotoItems = photoItems;
            self.cancelToken = [TGTelegraphInstance doDeleteProfilePhotos:photoItems actor:self];
        }
        else
        {
            NSArray *uploadAvatarActions = [TGDatabaseInstance() loadFutureActionsWithType:TGUploadAvatarFutureActionType];
            if (uploadAvatarActions.count != 0)
            {
                for (int i = 0; i < (int)(uploadAvatarActions.count - 1); i++)
                {
                    TGFutureAction *action = [uploadAvatarActions objectAtIndex:i];
                    [TGDatabaseInstance() removeFutureAction:action.uniqueId type:action.type randomId:action.randomId];
                }
                
                TGUploadAvatarFutureAction *avatarAction = [uploadAvatarActions lastObject];
                [ActionStageInstance() requestActor:[[NSString alloc] initWithFormat:@"/tg/timeline/(%d)/uploadPhoto/(%@)", TGTelegraphInstance.clientUserId, avatarAction.originalFileUrl] options:[[NSDictionary alloc] initWithObjectsAndKeys:avatarAction.originalFileUrl, @"originalFileUrl", [[NSNumber alloc] initWithDouble:avatarAction.latitude], @"latitude", [[NSNumber alloc] initWithDouble:avatarAction.longitude], @"longitude", [[NSNumber alloc] initWithBool:true], @"restoringFromFutureAction", nil] watcher:TGTelegraphInstance];
            }
        }
    }
    
    if (completed)
    {
        [ActionStageInstance() actionCompleted:self.path result:nil];
    }
}

- (void)changePeerNotificationSettingsSuccess:(TLPeerNotifySettings *)__unused settings
{
    [TGDatabaseInstance() removeFutureAction:_currentActionUniqueId type:_currentActionType randomId:_currentActionRandomId];
    [self execute:nil];
}

- (void)changePeerNotificationSettingsFailed
{
    [self changePeerNotificationSettingsSuccess:nil];
}

- (void)resetPeerNotificationSettingsSuccess
{
    [TGDatabaseInstance() removeFutureAction:_currentActionUniqueId type:_currentActionType randomId:_currentActionRandomId];
    [self execute:nil];
}

- (void)resetPeerNotificationSettingsFailed
{
    [self resetPeerNotificationSettingsSuccess];
}

- (void)changePrivacySettingsSuccess
{
    [TGDatabaseInstance() removeFutureAction:_currentActionUniqueId type:_currentActionType randomId:_currentActionRandomId];
    [self execute:nil];
}

- (void)changePrivacySettingsFailed
{
    [self changePrivacySettingsSuccess];
}

- (void)changePeerBlockStatusSuccess
{
    [TGDatabaseInstance() removeFutureAction:_currentActionUniqueId type:_currentActionType randomId:_currentActionRandomId];
    [self execute:nil];
}

- (void)changePeerBlockStatusFailed
{
    [self changePeerBlockStatusSuccess];
}

- (void)deleteProfilePhotosSucess:(NSArray *)__unused items
{
    for (NSDictionary *photoDesc in _currentDeleteProfilePhotoItems)
    {
        [TGDatabaseInstance() removeFutureAction:[photoDesc[@"imageId"] longLongValue] type:TGDeleteProfilePhotoFutureActionType randomId:[photoDesc[@"actionRandomId"] intValue]];
    }
    
    [self execute:nil];
}

- (void)deleteProfilePhotosFailed:(NSArray *)items
{
    [self deleteProfilePhotosSucess:items];
}

- (void)sendEncryptedServiceMessageSuccess:(int)date
{
    if (_currentActionType == TGSynchronizeEncryptedChatSettingsFutureActionType && date != 0)
    {
        TGMessage *message = [[TGMessage alloc] init];
        
        message.fromUid = TGTelegraphInstance.clientUserId;
        message.toUid = _currentMessageLifetimePeerId;
        message.date = date;
        message.unread = false;
        message.outgoing = true;
        message.cid = _currentMessageLifetimePeerId;
        
        TGActionMediaAttachment *actionAttachment = [[TGActionMediaAttachment alloc] init];
        actionAttachment.actionType = TGMessageActionEncryptedChatMessageLifetime;
        actionAttachment.actionData = [[NSDictionary alloc] initWithObjectsAndKeys:[[NSNumber alloc] initWithInt:_currentMessageLifetimeSetting], @"messageLifetime", nil];
        message.mediaAttachments = @[actionAttachment];
        
        static int messageActionId = 1000000;
        [[[TGConversationAddMessagesActor alloc] initWithPath:[NSString stringWithFormat:@"/tg/addmessage/(%dact)", messageActionId++]] execute:[NSDictionary dictionaryWithObjectsAndKeys:[[NSArray alloc] initWithObjects:message, nil], @"messages", nil]];
    }
    
    [TGDatabaseInstance() removeFutureAction:_currentActionUniqueId type:_currentActionType randomId:_currentActionRandomId];
    [self execute:nil];
}

- (void)sendEncryptedServiceMessageFailed
{
    [self sendEncryptedServiceMessageSuccess:0];
}

- (void)actionStageResourceDispatched:(NSString *)path resource:(id)resource arguments:(id)__unused arguments
{
    if ([path isEqualToString:@"/tg/service/cancelAcceptEncryptedChat"])
    {
        if (_currentActionType == TGAcceptEncryptionFutureActionType && [resource longLongValue] == _currentActionUniqueId)
        {
            if (_currentRequestPath != nil)
                [ActionStageInstance() removeWatcher:self fromPath:_currentRequestPath];
            
            [TGDatabaseInstance() removeFutureAction:_currentActionUniqueId type:_currentActionType randomId:_currentActionRandomId];
            [self execute:nil];
        }
    }
    else if ([path isEqualToString:@"/tg/service/cancelSynchronizeEncryptedChatSettings"])
    {
        if (_currentActionType == TGSynchronizeEncryptedChatSettingsFutureActionType && [resource longLongValue] == _currentActionUniqueId)
        {
            if (_currentRequestPath != nil)
                [ActionStageInstance() removeWatcher:self fromPath:_currentRequestPath];
            
            [TGDatabaseInstance() removeFutureAction:_currentActionUniqueId type:_currentActionType randomId:_currentActionRandomId];
            [self execute:nil];
        }
    }
}

- (void)actorCompleted:(int)__unused status path:(NSString *)path result:(id)__unused result
{
    if ([path hasPrefix:@"/tg/encrypted/acceptEncryptedChat/"])
    {
        [TGDatabaseInstance() removeFutureAction:_currentActionUniqueId type:_currentActionType randomId:_currentActionRandomId];
        [self execute:nil];
    }
}

@end
