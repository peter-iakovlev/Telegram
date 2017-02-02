#import "TGSynchronizeServiceActionsActor.h"

#import "ActionStage.h"

#import "TGDatabase.h"

#import "TGTelegraph.h"

#import "TGModernSendSecretMessageActor.h"
#import "TGConversationAddMessagesActor.h"

#import "TLMetaClassStore.h"

#import "TGTelegramNetworking.h"
#import <MTProtoKit/MTContext.h>

#import "TGPeerIdAdapter.h"

@interface TGSynchronizeServiceActionsActor ()

@property (nonatomic) int64_t currentActionUniqueId;
@property (nonatomic) int currentActionType;
@property (nonatomic) int currentActionRandomId;
@property (nonatomic, strong) NSString *currentRequestPath;

@property (nonatomic) NSArray *currentDeleteProfilePhotoItems;

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
    
    [TGDatabaseInstance() peersWithOutgoingAndIncomingActions:^(NSArray *outgoingPeerIds, NSArray *incomingPeerIds)
    {
        [ActionStageInstance() dispatchOnStageQueue:^
        {
            for (NSNumber *nPeerId in outgoingPeerIds)
            {
                [TGModernSendSecretMessageActor beginOutgoingQueueProcessingIfNeeded:[nPeerId longLongValue]];
            }
            
            for (NSNumber *nPeerId in incomingPeerIds)
            {
                [TGModernSendSecretMessageActor beginIncomingQueueProcessingIfNeeded:[nPeerId longLongValue]];
            }
        }];
    }];
    
    if ([TGDatabaseInstance() customProperty:[[NSString alloc] initWithFormat:@"updatedPeersToLayer%d", (int)[TGModernSendSecretMessageActor currentLayer]]].length != 1)
    {
        [TGDatabaseInstance() dispatchOnDatabaseThread:^
        {
            [TGDatabaseInstance() loadAllSercretChatPeerIds:^(NSArray *peerIds)
            {
                NSMutableArray *futureActions = [[NSMutableArray alloc] init];
                for (NSNumber *nPeerId in peerIds)
                {
                    int64_t encryptedConversationId = [TGDatabaseInstance() encryptedConversationIdForPeerId:[nPeerId longLongValue]];
                    int64_t randomId = 0;
                    arc4random_buf(&randomId, 8);
                    if (encryptedConversationId != 0)
                    {
                        [futureActions addObject:[[TGUpdatePeerLayerFutureAction alloc] initWithEncryptedConversationId:encryptedConversationId messageRandomId:randomId]];
                    }
                }
                [TGDatabaseInstance() storeFutureActions:futureActions];
                
                uint8_t one = 1;
                [TGDatabaseInstance() setCustomProperty:[[NSString alloc] initWithFormat:@"updatedPeersToLayer%d", (int)[TGModernSendSecretMessageActor currentLayer]] value:[NSData dataWithBytes:&one length:1]];
            }];
        } synchronous:false];
    }
    
    if ([self.path hasSuffix:@"settings)"])
    {
        while (true)
        {
            completed = true;
            
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
                    __block int64_t accessHash = 0;
                    
                    if (TGPeerIdIsChannel(notificationSettingsAction.uniqueId)) {
                        [TGDatabaseInstance() dispatchOnDatabaseThread:^{
                            accessHash = [TGDatabaseInstance() loadConversationWithId:notificationSettingsAction.uniqueId].accessHash;
                        } synchronous:true];
                    }
                    
                    self.cancelToken = [TGTelegraphInstance doChangePeerNotificationSettings:notificationSettingsAction.uniqueId accessHash:accessHash muteUntil:notificationSettingsAction.muteUntil soundId:peerSoundId previewText:notificationSettingsAction.previewText messagesMuted:notificationSettingsAction.messagesMuted actor:self];
                    
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
                    TGSynchronizeEncryptedChatSettingsFutureAction *settingsAction = (TGSynchronizeEncryptedChatSettingsFutureAction *)action;
                    
                    int64_t peerId = [TGDatabaseInstance() peerIdForEncryptedConversationId:settingsAction.uniqueId createIfNecessary:false];
                    
                    NSUInteger peerLayer = MIN([TGModernSendSecretMessageActor currentLayer], [TGDatabaseInstance() peerLayer:peerId]);
                    
                    NSData *messageData = [TGModernSendSecretMessageActor decryptedServiceMessageActionWithLayer:peerLayer setTTL:settingsAction.messageLifetime randomId:settingsAction.messageRandomId];
                    
                    [TGModernSendSecretMessageActor enqueueOutgoingServiceMessageForPeerId:peerId layer:MIN(peerLayer, [TGModernSendSecretMessageActor currentLayer]) keyId:0 randomId:settingsAction.messageRandomId messageData:messageData];
                    
                    [TGDatabaseInstance() removeFutureAction:action.uniqueId type:action.type randomId:action.randomId];
                    
                    TGMessage *message = [[TGMessage alloc] init];
                    
                    message.fromUid = TGTelegraphInstance.clientUserId;
                    message.toUid = peerId;
                    message.date = [[TGTelegramNetworking instance] approximateRemoteTime];
                    message.outgoing = true;
                    message.cid = peerId;
                    
                    TGActionMediaAttachment *actionAttachment = [[TGActionMediaAttachment alloc] init];
                    actionAttachment.actionType = TGMessageActionEncryptedChatMessageLifetime;
                    actionAttachment.actionData = [[NSDictionary alloc] initWithObjectsAndKeys:[[NSNumber alloc] initWithInt:settingsAction.messageLifetime], @"messageLifetime", nil];
                    message.mediaAttachments = @[actionAttachment];
                    
                    [TGDatabaseInstance() transactionAddMessages:@[message] updateConversationDatas:nil notifyAdded:true];
                }
                else if ([action isKindOfClass:[TGChangePasslockSettingsFutureAction class]])
                {
                    TGChangePasslockSettingsFutureAction *passlockSettingsAction = (TGChangePasslockSettingsFutureAction *)action;
                    
                    __weak TGSynchronizeServiceActionsActor *weakSelf = self;
                    self.cancelToken = [TGTelegraphInstance doChangePasslockSettings:passlockSettingsAction.lockSince >= 0 completion:^(__unused bool success)
                    {
                        __strong TGSynchronizeServiceActionsActor *strongSelf = weakSelf;
                        if (strongSelf != nil)
                        {
                            [TGDatabaseInstance() removeFutureAction:action.uniqueId type:action.type randomId:action.randomId];
                            
                            [strongSelf execute:nil];
                        }
                    }];
                    
                    break;
                }
                else if ([action isKindOfClass:[TGEncryptedChatServiceAction class]])
                {
                    TGEncryptedChatServiceAction *serviceMessageAction = (TGEncryptedChatServiceAction *)action;
                    
                    int64_t peerId = [TGDatabaseInstance() peerIdForEncryptedConversationId:serviceMessageAction.encryptedConversationId createIfNecessary:false];
                    
                    NSUInteger peerLayer = MIN([TGModernSendSecretMessageActor currentLayer], [TGDatabaseInstance() peerLayer:peerId]);
                    
                    NSData *messageData = nil;
                    
                    if (serviceMessageAction.action == TGEncryptedChatServiceActionViewMessage)
                    {
                        messageData = [TGModernSendSecretMessageActor decryptedServiceMessageActionWithLayer:MIN(peerLayer, [TGModernSendSecretMessageActor currentLayer]) readMessagesWithRandomIds:@[@(serviceMessageAction.actionContext)] randomId:serviceMessageAction.messageRandomId];
                    }
                    else if (serviceMessageAction.action == TGEncryptedChatServiceActionMessageScreenshotTaken)
                    {
                        messageData = [TGModernSendSecretMessageActor decryptedServiceMessageActionWithLayer:MIN(peerLayer, [TGModernSendSecretMessageActor currentLayer]) readMessagesWithRandomIds:@[@(serviceMessageAction.actionContext)] randomId:serviceMessageAction.messageRandomId];
                    }
                    
                    if (messageData != nil)
                    {
                        [TGModernSendSecretMessageActor enqueueOutgoingServiceMessageForPeerId:peerId layer:MIN(peerLayer, [TGModernSendSecretMessageActor currentLayer]) keyId:0 randomId:serviceMessageAction.messageRandomId messageData:messageData];
                    }
                    
                    [TGDatabaseInstance() removeFutureAction:action.uniqueId type:action.type randomId:action.randomId];
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
                else if ([action isKindOfClass:[TGUpdatePeerLayerFutureAction class]])
                {
                    TGUpdatePeerLayerFutureAction *settingsAction = (TGUpdatePeerLayerFutureAction *)action;
                    
                    int64_t peerId = [TGDatabaseInstance() peerIdForEncryptedConversationId:settingsAction.uniqueId createIfNecessary:false];
                    
                    NSUInteger peerLayer = [TGDatabaseInstance() peerLayer:peerId];
                    
                    NSData *messageData = [TGModernSendSecretMessageActor decryptedServiceMessageActionWithLayer:MIN(peerLayer, [TGModernSendSecretMessageActor currentLayer]) notifyLayer:[TGModernSendSecretMessageActor currentLayer] randomId:settingsAction.messageRandomId];
                    
                    [TGDatabaseInstance() maybeCreateAdditionalEncryptedHashForPeer:peerId];
                    
                    if (messageData != nil)
                    {
                        [TGModernSendSecretMessageActor enqueueOutgoingServiceMessageForPeerId:peerId layer:MIN(peerLayer, [TGModernSendSecretMessageActor currentLayer]) keyId:0 randomId:settingsAction.messageRandomId messageData:messageData];
                    }

                    [TGDatabaseInstance() removeFutureAction:action.uniqueId type:action.type randomId:action.randomId];
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

- (void)sendEncryptedServiceMessageSuccess:(int)__unused date
{
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
