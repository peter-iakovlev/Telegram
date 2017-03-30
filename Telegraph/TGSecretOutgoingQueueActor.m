#import "TGSecretOutgoingQueueActor.h"

#import <MTProtoKit/MTContext.h>
#import <MTProtoKit/MTRequest.h>

#import "TGDatabase.h"
#import "TL/TLMetaScheme.h"

#import "ActionStage.h"

#import "TGTelegramNetworking.h"

#import "TGModernSendSecretMessageActor.h"

#import "TGTelegraph.h"

@interface TGSecretOutgoingRequest : MTRequest

@property (nonatomic) int32_t actionId;
@property (nonatomic) int32_t seqOut;
@property (nonatomic) bool isResend;
@property (nonatomic) NSUInteger layer;

@end

@implementation TGSecretOutgoingRequest

@end

@interface TGSecretOutgoingQueueActor ()
{
    int64_t _peerId;
    int64_t _encryptedChatId;
    int64_t _accessHash;
    bool _isCreator;
    
    NSMutableSet *_executingRequestsActionIds;
}

@end

@implementation TGSecretOutgoingQueueActor

+ (void)load
{
    [ASActor registerActorClass:self];
}

+ (NSString *)genericPath
{
    return @"/tg/secret/outgoing/@";
}

- (void)execute:(NSDictionary *)options
{
    _peerId = (int64_t)[options[@"peerId"] longLongValue];
    _encryptedChatId = [TGDatabaseInstance() encryptedConversationIdForPeerId:_peerId];
    _accessHash = [TGDatabaseInstance() encryptedConversationAccessHash:_peerId];
    _isCreator = [TGDatabaseInstance() encryptedConversationIsCreator:_peerId];
    
    if (_accessHash == 0)
        [ActionStageInstance() actionFailed:self.path reason:-1];
    else
    {
        _executingRequestsActionIds = [[NSMutableSet alloc] init];
        
        [self _poll];
    }
}

- (void)watcherJoined:(ASHandle *)watcherHandle options:(NSDictionary *)options waitingInActorQueue:(bool)waitingInActorQueue
{
    [super watcherJoined:watcherHandle options:options waitingInActorQueue:waitingInActorQueue];
    
    [self _poll];
}

- (void)_poll
{
    [TGDatabaseInstance() dequeuePeerOutgoingActions:_peerId completion:^(NSArray *actions, NSArray *resendActions)
    {
        [ActionStageInstance() dispatchOnStageQueue:^
        {
            if ([TGDatabaseInstance() peerLayer:_peerId] >= 20)
            {
                int32_t keyUseCount = [TGDatabaseInstance() currentEncryptionKeyUseCount:_peerId];
                int32_t maxKeyUseCount = 100;
#ifdef DEBUG
                maxKeyUseCount = 5;
#endif
                if (keyUseCount >= maxKeyUseCount)
                {
                    [TGModernSendSecretMessageActor maybeRekeyPeerId:_peerId];
                }
            }
            
            NSMutableArray *requests = [[NSMutableArray alloc] init];
            
            NSArray *mergedActions = [actions arrayByAddingObjectsFromArray:resendActions];
            
            NSInteger index = -1;
            for (TGStoredSecretActionWithSeq *action in mergedActions)
            {
                index++;
                
                if ([_executingRequestsActionIds containsObject:@(action.actionId.value)])
                    continue;
                
                TGSecretOutgoingRequest *request = [self requestForAction:action.action actionId:action.actionId.value seqIn:action.seqIn seqOut:action.seqOut isResend:index >= (NSInteger)actions.count];
                if (request != nil)
                {
                    __weak TGSecretOutgoingQueueActor *weakSelf = self;
                    int32_t seqOut = action.seqOut;
                    int32_t actionId = action.actionId.value;
                    int32_t actionSeqOut = request.seqOut;
                    bool isResend = request.isResend;
                    NSUInteger actionLayer = request.layer;
                    [request setCompleted:^(id result, NSTimeInterval timestamp, id error)
                    {
                        [ActionStageInstance() dispatchOnStageQueue:^
                        {
                            __strong TGSecretOutgoingQueueActor *strongSelf = weakSelf;
                            if (strongSelf != nil)
                            {
                                if (error == nil)
                                {
                                    [strongSelf actionCompletedWithId:actionId date:(int32_t)(timestamp * 4294967296.0) result:result actionSeqOut:actionSeqOut actionLayer:actionLayer isResend:isResend];
                                }
                                else
                                {
                                    [strongSelf->_executingRequestsActionIds removeObject:@(actionId)];
                                    
                                    NSString *errorType = [[TGTelegramNetworking instance] extractNetworkErrorType:error];
                                    if ([errorType isEqualToString:@"ENCRYPTION_DECLINED"]) {
                                        int64_t encryptedChatId = [TGDatabaseInstance() encryptedConversationIdForPeerId:_peerId];
                                        [ActionStageInstance() requestActor:[[NSString alloc] initWithFormat:@"/tg/encrypted/discardEncryptedChat/(%" PRId64 ")", (int64_t)encryptedChatId] options:@{@"encryptedConversationId": @((int64_t)encryptedChatId), @"locally": @true} flags:0 watcher:TGTelegraphInstance];
                                    }
                                }
                            }
                        }];
                    }];
                    
                    [request setAcknowledgementReceived:^
                    {
                        __strong TGSecretOutgoingQueueActor *strongSelf = weakSelf;
                        if (strongSelf != nil)
                            [strongSelf actionQuickAck:actionId];
                    }];
                    
                    [request setShouldDependOnRequest:^bool(MTRequest *other)
                    {
                        if ([other isKindOfClass:[TGSecretOutgoingRequest class]])
                        {
                            return ((TGSecretOutgoingRequest *)other).seqOut < seqOut;
                        }
                        
                        return false;
                    }];
                    
                    [requests addObject:request];
                }
            }
            
            for (TGSecretOutgoingRequest *request in requests)
            {
#if defined(DEBUG) && 0
                TLmessages_SentEncryptedMessage$messages_sentEncryptedMessage *sentEncryptedMessage = [[TLmessages_SentEncryptedMessage$messages_sentEncryptedMessage alloc] init];
                sentEncryptedMessage.date = (int32_t)[[[TGTelegramNetworking instance] context] globalTime];
                 request.completed(sentEncryptedMessage, 0, nil);
#else
                [[TGTelegramNetworking instance] addRequest:request];
#endif
                [_executingRequestsActionIds addObject:@(request.actionId)];
            }
        }];
    }];
}

- (void)actionCompletedWithId:(int32_t)actionId date:(int32_t)date result:(id)result actionSeqOut:(int32_t)actionSeqOut actionLayer:(NSUInteger)actionLayer isResend:(bool)isResend
{
    [ActionStageInstance() dispatchOnStageQueue:^
    {
        if (isResend)
            [TGDatabaseInstance() deletePeerOutgoingResendActions:_peerId actionIds:@[@(actionId)]];
        else if (actionSeqOut >= 0 && actionLayer >= 17)
            [TGDatabaseInstance() applyPeerSeqOut:_peerId seqOut:actionSeqOut];
        else
            [TGDatabaseInstance() deletePeerOutgoingActions:_peerId actionIds:@[@(actionId)]];
        
        [ActionStageInstance() dispatchMessageToWatchers:self.path messageType:@"actionCompletedWithSeq" message:@{@"actionId": @(actionId), @"date": @(date), @"result": result}];
    }];
}

- (void)actionQuickAck:(int32_t)actionId
{
    [ActionStageInstance() dispatchMessageToWatchers:self.path messageType:@"actionQuickAck" message:@{@"actionId": @(actionId)}];
}

- (TGSecretOutgoingRequest *)requestForAction:(id)action actionId:(int32_t)actionId seqIn:(int32_t)seqIn seqOut:(int32_t)seqOut isResend:(bool)isResend
{
    if ([action isKindOfClass:[TGStoredOutgoingMessageSecretAction class]])
    {
        TGStoredOutgoingMessageSecretAction *concreteAction = action;
        
        NSData *messageData = nil;
        NSData *actionData = nil;
        
        for (TGModernSendSecretMessageActor *actor in [ActionStageInstance() executingActorsWithPathPrefix:@"/tg/sendSecretMessage/"])
        {
            if ([actor waitsForActionWithId:actionId])
            {
                actionData = concreteAction.data;
                break;
            }
        }
        
        if (actionData == nil)
        {
            actionData = [TGModernSendSecretMessageActor decryptedServiceMessageActionWithLayer:concreteAction.layer deleteMessagesWithRandomIds:@[@(concreteAction.randomId)] randomId:concreteAction.randomId];
        }
        
        int64_t keyId = 0;
        NSData *key = [TGDatabaseInstance() encryptionKeyForConversationId:_peerId requestedKeyFingerprint:concreteAction.keyId outKeyFingerprint:&keyId];
        
        if (key == nil)
        {
            TGLog(@"missing key %" PRIx64, concreteAction.keyId);
        }
        
        if (concreteAction.layer >= 17)
        {
            NSMutableData *data = [[NSMutableData alloc] init];
            int32_t constructorSignature = 0x1be31789;
            [data appendBytes:&constructorSignature length:4];
            
            uint8_t randomBytesLength = 15;
            [data appendBytes:&randomBytesLength length:1];
            
            uint8_t randomBytes[15];
            arc4random_buf(randomBytes, 15);
            [data appendBytes:randomBytes length:15];
            
            int32_t layer = (int32_t)concreteAction.layer;
            [data appendBytes:&layer length:4];
            
            int32_t inSeqNo = seqIn * 2 + (_isCreator ? 0 : 1);
            [data appendBytes:&inSeqNo length:4];
            
            int32_t outSeqNo = seqOut * 2 + (_isCreator ? 1 : 0);
            [data appendBytes:&outSeqNo length:4];
            
            TGLog(@"preparing outgoing message request for seqOut: %d, seqIn: %d", seqOut, seqIn);
            
            [data appendData:actionData];
            
            messageData = [TGModernSendSecretMessageActor encryptMessage:data key:key keyId:keyId];
        }
        else
            messageData = [TGModernSendSecretMessageActor encryptMessage:actionData key:key keyId:keyId];
        
        TGSecretOutgoingRequest *request = [[TGSecretOutgoingRequest alloc] init];
        request.actionId = actionId;
        request.isResend = isResend;
        request.seqOut = concreteAction.layer >= 17 ? seqOut : -1;
        request.layer = concreteAction.layer;
        
        if (concreteAction.fileInfo == nil)
        {
            TLRPCmessages_sendEncrypted$messages_sendEncrypted *sendEncrypted = [[TLRPCmessages_sendEncrypted$messages_sendEncrypted alloc] init];
            
            TLInputEncryptedChat$inputEncryptedChat *inputEncryptedChat = [[TLInputEncryptedChat$inputEncryptedChat alloc] init];
            inputEncryptedChat.chat_id = (int32_t)_encryptedChatId;
            inputEncryptedChat.access_hash = _accessHash;
            sendEncrypted.peer = inputEncryptedChat;
            
            sendEncrypted.random_id = concreteAction.randomId;
            sendEncrypted.data = messageData;
            
            request.body = sendEncrypted;
        }
        else
        {
            TLRPCmessages_sendEncryptedFile$messages_sendEncryptedFile *sendEncrypted = [[TLRPCmessages_sendEncryptedFile$messages_sendEncryptedFile alloc] init];
            
            TLInputEncryptedChat$inputEncryptedChat *inputEncryptedChat = [[TLInputEncryptedChat$inputEncryptedChat alloc] init];
            inputEncryptedChat.chat_id = (int32_t)_encryptedChatId;
            inputEncryptedChat.access_hash = _accessHash;
            sendEncrypted.peer = inputEncryptedChat;
            
            sendEncrypted.random_id = concreteAction.randomId;
            sendEncrypted.data = messageData;
            
            if ([concreteAction.fileInfo isKindOfClass:[TGStoredOutgoingMessageFileInfoUploaded class]])
            {
                TGStoredOutgoingMessageFileInfoUploaded *fileInfo = (TGStoredOutgoingMessageFileInfoUploaded *)concreteAction.fileInfo;
                TLInputEncryptedFile$inputEncryptedFileUploaded *schemaFileInfo = [[TLInputEncryptedFile$inputEncryptedFileUploaded alloc] init];
                schemaFileInfo.n_id = fileInfo.n_id;
                schemaFileInfo.parts = fileInfo.parts;
                //schemaFileInfo.md5_checksum = fileInfo.md5_checksum;
                schemaFileInfo.md5_checksum = @"";
                schemaFileInfo.key_fingerprint = fileInfo.key_fingerprint;
                
                sendEncrypted.file = schemaFileInfo;
            }
            else if ([concreteAction.fileInfo isKindOfClass:[TGStoredOutgoingMessageFileInfoExisting class]])
            {
                TGStoredOutgoingMessageFileInfoExisting *fileInfo = (TGStoredOutgoingMessageFileInfoExisting *)concreteAction.fileInfo;
                TLInputEncryptedFile$inputEncryptedFile *schemaFileInfo = [[TLInputEncryptedFile$inputEncryptedFile alloc] init];
                schemaFileInfo.n_id = fileInfo.n_id;
                schemaFileInfo.access_hash = fileInfo.access_hash;
                
                sendEncrypted.file = schemaFileInfo;
            }
            else if ([concreteAction.fileInfo isKindOfClass:[TGStoredOutgoingMessageFileInfoBigUploaded class]])
            {
                TGStoredOutgoingMessageFileInfoBigUploaded *fileInfo = (TGStoredOutgoingMessageFileInfoBigUploaded *)concreteAction.fileInfo;
                TLInputEncryptedFile$inputEncryptedFileBigUploaded *schemaFileInfo = [[TLInputEncryptedFile$inputEncryptedFileBigUploaded alloc] init];
                schemaFileInfo.n_id = fileInfo.n_id;
                schemaFileInfo.parts = fileInfo.parts;
                schemaFileInfo.key_fingerprint = fileInfo.key_fingerprint;
                
                sendEncrypted.file = schemaFileInfo;
            }
            
            request.body = sendEncrypted;
        }
        
        return request;
    }
    else if ([action isKindOfClass:[TGStoredOutgoingServiceMessageSecretAction class]])
    {
        TGStoredOutgoingServiceMessageSecretAction *concreteAction = action;
        
        NSData *messageData = nil;
        
        int64_t keyId = 0;
        NSData *key = [TGDatabaseInstance() encryptionKeyForConversationId:_peerId requestedKeyFingerprint:concreteAction.keyId outKeyFingerprint:&keyId];
        
        if (key == nil)
        {
            TGLog(@"missing key %" PRIx64, concreteAction.keyId);
        }
        
        if (concreteAction.layer >= 17)
        {
            NSMutableData *data = [[NSMutableData alloc] init];
            int32_t constructorSignature = 0x1be31789;
            [data appendBytes:&constructorSignature length:4];
            
            uint8_t randomBytesLength = 15;
            [data appendBytes:&randomBytesLength length:1];
            
            uint8_t randomBytes[15];
            arc4random_buf(randomBytes, 15);
            [data appendBytes:randomBytes length:15];
            
            int32_t layer = (int32_t)concreteAction.layer;
            [data appendBytes:&layer length:4];
            
            int32_t inSeqNo = seqIn * 2 + (_isCreator ? 0 : 1);
            [data appendBytes:&inSeqNo length:4];
            
            int32_t outSeqNo = seqOut * 2 + (_isCreator ? 1 : 0);
            [data appendBytes:&outSeqNo length:4];
            
            TGLog(@"preparing outgoing message request for (%lld) seqOut: %d, seqIn: %d", _peerId, seqOut, seqIn);
            
            [data appendData:concreteAction.data];
            
            messageData = [TGModernSendSecretMessageActor encryptMessage:data key:key keyId:keyId];
        }
        else
            messageData = [TGModernSendSecretMessageActor encryptMessage:concreteAction.data key:key keyId:keyId];
        
        TGSecretOutgoingRequest *request = [[TGSecretOutgoingRequest alloc] init];
        request.actionId = actionId;
        request.isResend = isResend;
        request.seqOut = concreteAction.layer >= 17 ? seqOut : -1;
        request.layer = concreteAction.layer;
        
        TLRPCmessages_sendEncryptedService$messages_sendEncryptedService *sendEncryptedService = [[TLRPCmessages_sendEncryptedService$messages_sendEncryptedService alloc] init];
        
        TLInputEncryptedChat$inputEncryptedChat *inputEncryptedChat = [[TLInputEncryptedChat$inputEncryptedChat alloc] init];
        inputEncryptedChat.chat_id = (int32_t)_encryptedChatId;
        inputEncryptedChat.access_hash = _accessHash;
        sendEncryptedService.peer = inputEncryptedChat;
        
        sendEncryptedService.random_id = concreteAction.randomId;
        sendEncryptedService.data = messageData;
        
        request.body = sendEncryptedService;
        
        return request;
    }
    
    return nil;
}

@end
