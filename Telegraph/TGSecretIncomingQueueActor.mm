#import "TGSecretIncomingQueueActor.h"

#import "TGCommon.h"

#import "ActionStage.h"
#import "SGraphObjectNode.h"

#import "TGDatabase.h"
#import "TGTelegraph.h"

#import "TGStoredSecretAction.h"

#import "TGMessage+Telegraph.h"

#import "TGConversationAddMessagesActor.h"
#import "TGModernSendSecretMessageActor.h"
#import "TGRequestEncryptedChatActor.h"
#import "TGUpdateStateRequestBuilder.h"

#import <MTProtoKit/MTEncryption.h>

@interface TGSecretIncomingQueueActor ()
{
    int64_t _peerId;
    int64_t _encryptedChatId;
    int64_t _accessHash;
    int32_t _userId;
}

@end

@implementation TGSecretIncomingQueueActor

+ (void)load
{
    [ASActor registerActorClass:self];
}

+ (NSString *)genericPath
{
    return @"/tg/secret/incoming/@";
}

- (void)execute:(NSDictionary *)options
{
    _peerId = (int64_t)[options[@"peerId"] longLongValue];
    _encryptedChatId = [TGDatabaseInstance() encryptedConversationIdForPeerId:_peerId];
    _accessHash = [TGDatabaseInstance() encryptedConversationAccessHash:_peerId];
    _userId = [TGDatabaseInstance() encryptedParticipantIdForConversationId:_peerId];
    
    [self _poll];
}

- (void)watcherJoined:(ASHandle *)watcherHandle options:(NSDictionary *)options waitingInActorQueue:(bool)waitingInActorQueue
{
    [super watcherJoined:watcherHandle options:options waitingInActorQueue:waitingInActorQueue];
    
    [self _poll];
}

- (void)_poll
{
    [TGDatabaseInstance() dequeuePeerIncomingActions:_peerId completion:^(NSArray *actions, int32_t blockNextExpectedSeqOut, NSArray *encryptedActions)
    {
        [ActionStageInstance() dispatchOnStageQueue:^
        {
            bool pollAtTheEnd = false;
            
            int32_t nextExpectedSeqOut = blockNextExpectedSeqOut;
            
            std::map<int64_t, int64_t> cachedPeerIds;
            std::map<int64_t, int> cachedParticipantIds;
            
            NSMutableArray *addedDecryptedActions = [[NSMutableArray alloc] init];
            
            NSUInteger encryptedMessageCount = 0;
            
            for (TGStoredIncomingEncryptedDataSecretActionWithActionId *encryptedAction in encryptedActions)
            {
                TLEncryptedMessage$encryptedMessage *encryptedMessage = [[TLEncryptedMessage$encryptedMessage alloc] init];
                encryptedMessage.random_id = encryptedAction.action.randomId;
                encryptedMessage.chat_id = encryptedAction.action.chatId;
                encryptedMessage.date = encryptedAction.action.date;
                encryptedMessage.bytes = encryptedAction.action.encryptedData;
                
                int64_t conversationId = 0;
                int64_t keyId = 0;
                int32_t seqIn = 0;
                int32_t seqOut = 0;
                NSUInteger decryptedLayer = 1;
                NSData *decryptedMessageData = [TGUpdateStateRequestBuilder decryptEncryptedMessageData:encryptedMessage decryptedLayer:&decryptedLayer cachedPeerIds:&cachedPeerIds cachedParticipantIds:&cachedParticipantIds outConversationId:&conversationId outKeyId:&keyId outSeqIn:&seqIn outSeqOut:&seqOut];
                if (decryptedMessageData != nil)
                {
                    TGStoredIncomingMessageFileInfo *fileInfo = encryptedAction.action.fileInfo;
                    
                    [addedDecryptedActions addObject:[[TGStoredSecretActionWithSeq alloc] initWithActionId:TGStoredSecretActionWithSeqActionIdMake(TGStoredSecretActionWithSeqActionIdEncrypted, encryptedAction.actionId) action:[[TGStoredIncomingMessageSecretAction alloc] initWithLayer:decryptedLayer data:decryptedMessageData date:encryptedMessage.date fileInfo:fileInfo] seqIn:seqIn seqOut:seqOut]];
                }
                else
                {
                    encryptedMessageCount++;
                }
            }
            
            if (encryptedMessageCount != 0)
                TGLog(@"There are %d messages to decrypt yet, but no key available", (int)encryptedMessageCount);
            
            NSMutableArray *removeActionIds = [[NSMutableArray alloc] init];
            NSMutableArray *removeEncryptedActionIds = [[NSMutableArray alloc] init];
            NSMutableArray *addedMessages = [[NSMutableArray alloc] init];
            NSMutableArray *addedActions = [[NSMutableArray alloc] init];
            NSMutableArray *deleteMessageIds = [[NSMutableArray alloc] init];
            
            NSUInteger layerUpdate = 0;
            NSUInteger currentPeerLayer = [TGDatabaseInstance() peerLayer:_peerId];
            
            NSMutableDictionary *secretMessageFlagChanges = [[NSMutableDictionary alloc] init];
            NSMutableArray *initiateSelfDestructMessageRandomIds = [[NSMutableArray alloc] init];
            
            NSMutableArray *actionsToProcess = [[NSMutableArray alloc] init];
            
            int32_t minLocalSeqOut = INT32_MAX;
            int32_t maxSeqIn = -1;
            
            NSMutableArray *mergedActions = [[NSMutableArray alloc] init];
            [mergedActions addObjectsFromArray:actions];
            [mergedActions addObjectsFromArray:addedDecryptedActions];
            
            [mergedActions sortUsingComparator:^NSComparisonResult(TGStoredSecretActionWithSeq *action1, TGStoredSecretActionWithSeq *action2)
            {
                if (action1.seqOut != action2.seqOut)
                {
                    if (action1.seqOut < action2.seqOut)
                        return NSOrderedAscending;
                    else
                        return NSOrderedDescending;
                }
                else if (action1.actionId.value < action2.actionId.value)
                    return NSOrderedAscending;
                else if (action1.actionId.value > action2.actionId.value)
                    return NSOrderedDescending;
                else
                    return NSOrderedSame;
            }];
            
            NSMutableArray *outOfOrderSeqOutList = [[NSMutableArray alloc] init];
            
            for (TGStoredSecretActionWithSeq *action in mergedActions)
            {
                if ([action.action isKindOfClass:[TGStoredIncomingMessageSecretAction class]])
                {
                    TGStoredIncomingMessageSecretAction *concreteAction = action.action;
                    if (currentPeerLayer >= 17)
                    {
                        minLocalSeqOut = MIN(minLocalSeqOut, action.seqOut);
                        
                        if (action.seqOut == nextExpectedSeqOut)
                        {
                            [actionsToProcess addObject:action];
                            nextExpectedSeqOut++;
                            maxSeqIn = MAX(maxSeqIn, action.seqIn);
                        }
                        else if (action.seqOut < nextExpectedSeqOut)
                        {
                            if (action.actionId.type == TGStoredSecretActionWithSeqActionIdGeneric)
                                [removeActionIds addObject:@(action.actionId.value)];
                            else if (action.actionId.type == TGStoredSecretActionWithSeqActionIdEncrypted)
                                [removeEncryptedActionIds addObject:@(action.actionId.value)];
                        }
                        else if ([self isResendAction:action.action])
                        {
                            [actionsToProcess addObject:action];
                        }
                        else
                            [outOfOrderSeqOutList addObject:@(action.seqOut)];
                    }
                    else if (concreteAction.layer >= 17)
                    {
                        minLocalSeqOut = MIN(minLocalSeqOut, action.seqOut);
                        
                        currentPeerLayer = concreteAction.layer;
                        if (action.seqOut == nextExpectedSeqOut)
                        {
                            [actionsToProcess addObject:action];
                            nextExpectedSeqOut++;
                            maxSeqIn = MAX(maxSeqIn, action.seqIn);
                        }
                        else if (action.seqOut < nextExpectedSeqOut)
                        {
                            if (action.actionId.type == TGStoredSecretActionWithSeqActionIdGeneric)
                                [removeActionIds addObject:@(action.actionId.value)];
                            else if (action.actionId.type == TGStoredSecretActionWithSeqActionIdEncrypted)
                                [removeEncryptedActionIds addObject:@(action.actionId.value)];
                        }
                        else if ([self isResendAction:action.action])
                            [actionsToProcess addObject:action];
                    }
                    else {
                        [actionsToProcess addObject:action];
                    }
                }
            }
            
            for (TGStoredSecretActionWithSeq *action in actionsToProcess)
            {
                if ([action.action isKindOfClass:[TGStoredIncomingMessageSecretAction class]])
                {
                    [self _processIncomingMessage:action.action seqIn:action.seqIn seqOut:action.seqOut addedMessages:addedMessages addedActions:addedActions layerUpdate:&layerUpdate];
                    if (action.actionId.type == TGStoredSecretActionWithSeqActionIdGeneric)
                        [removeActionIds addObject:@(action.actionId.value)];
                    else if (action.actionId.type == TGStoredSecretActionWithSeqActionIdEncrypted)
                        [removeEncryptedActionIds addObject:@(action.actionId.value)];
                }
            }
            
            int32_t resendSeqIn = 0;
            __unused bool hasResendSeqIn = [TGDatabaseInstance() currentPeerResendSeqIn:_peerId seqIn:&resendSeqIn] && (resendSeqIn >= 0);
            
            if (removeActionIds.count < actions.count)
            {
                TGLog(@"Waiting for %d more messages to process in sequence (expecting seqOut: %d, got: %@)", (int)(actions.count - actionsToProcess.count), (int)nextExpectedSeqOut, outOfOrderSeqOutList);
                
                //if (!hasResendSeqIn)
                {
                    [TGDatabaseInstance() setCurrentPeerResendSeqIn:_peerId seqIn:nextExpectedSeqOut];
                    
                    int64_t randomId = 0;
                    arc4random_buf(&randomId, 8);
                    
                    if (minLocalSeqOut == INT32_MAX)
                        minLocalSeqOut = nextExpectedSeqOut + 1;
                    
                    bool isCreator = [TGDatabaseInstance() encryptedConversationIsCreator:_peerId];
                    int32_t fromSeq = nextExpectedSeqOut * 2 + (isCreator ? 0 : 1);
                    int32_t toSeq = (minLocalSeqOut - 1) * 2 + (isCreator ? 0 : 1);
                    
                    TGLog(@"Requesting resend from %d * 2 + %d (%d) to (%d - 1) * 2 + %d (%d)", nextExpectedSeqOut, (isCreator ? 0 : 1), fromSeq, minLocalSeqOut, (isCreator ? 0 : 1), toSeq);
                    
                    NSData *messageData = [TGModernSendSecretMessageActor decryptedServiceMessageActionWithLayer:MIN(currentPeerLayer, [TGModernSendSecretMessageActor currentLayer]) resendMessagesFromSeq:fromSeq toSeq:toSeq randomId:randomId];
                    
                    if (messageData != nil)
                    {
                        [TGModernSendSecretMessageActor enqueueOutgoingServiceMessageForPeerId:_peerId layer:MIN(currentPeerLayer, [TGModernSendSecretMessageActor currentLayer]) keyId:0 randomId:randomId messageData:messageData];
                    }
                }
            }
            else
                [TGDatabaseInstance() setCurrentPeerResendSeqIn:_peerId seqIn:-1];
            
            [TGDatabaseInstance() deletePeerIncomingActions:_peerId actionIds:removeActionIds];
            [TGDatabaseInstance() deletePeerIncomingEncryptedActions:_peerId actionIds:removeEncryptedActionIds];
            [TGDatabaseInstance() applyPeerSeqIn:_peerId seqIn:nextExpectedSeqOut];
            if (maxSeqIn > 0)
            {
                [TGDatabaseInstance() confirmPeerSeqOut:_peerId seqOut:maxSeqIn - 1];
                [TGDatabaseInstance() discardEncryptionKeysForConversationId:_peerId beforeSeqOut:maxSeqIn];
            }
            
            for (NSDictionary *actionDesc in addedActions)
            {
                NSString *actionType = actionDesc[@"actionType"];
                if ([actionType isEqualToString:@"readMessages"])
                {
                    for (NSNumber *nRandomId in actionDesc[@"randomIds"])
                    {
                        [TGDatabaseInstance() raiseSecretMessageFlagsByRandomId:[nRandomId longLongValue] flagsToRise:TGSecretMessageFlagViewed];
                        
                        [initiateSelfDestructMessageRandomIds addObject:nRandomId];
                        
                        if (secretMessageFlagChanges[nRandomId] == nil)
                            secretMessageFlagChanges[nRandomId] = @(TGSecretMessageFlagViewed);
                        else
                            secretMessageFlagChanges[nRandomId] = @([secretMessageFlagChanges[nRandomId] intValue] | TGSecretMessageFlagViewed);
                    }
                }
                else if ([actionType isEqualToString:@"screenshotMessages"])
                {
                    for (NSNumber *nRandomId in actionDesc[@"randomIds"])
                    {
                        [TGDatabaseInstance() raiseSecretMessageFlagsByRandomId:[nRandomId longLongValue] flagsToRise:TGSecretMessageFlagScreenshot];
                        
                        if (secretMessageFlagChanges[nRandomId] == nil)
                            secretMessageFlagChanges[nRandomId] = @(TGSecretMessageFlagScreenshot);
                        else
                            secretMessageFlagChanges[nRandomId] = @([secretMessageFlagChanges[nRandomId] intValue] | TGSecretMessageFlagScreenshot);
                    }
                    
                    TGMessage *message = [[TGMessage alloc] init];
                    message.mid = INT_MIN;
                    
                    message.fromUid = _userId;
                    message.toUid = TGTelegraphInstance.clientUserId;
                    message.date = [actionDesc[@"date"] intValue];
                    //message.unread = false;
                    message.outgoing = false;
                    message.cid = _peerId;
                    
                    TGActionMediaAttachment *actionAttachment = [[TGActionMediaAttachment alloc] init];
                    actionAttachment.actionType = TGMessageActionEncryptedChatMessageScreenshot;
                    actionAttachment.actionData = @{@"randomIds": actionDesc[@"randomIds"]};
                    message.mediaAttachments = @[actionAttachment];
                    
                    [addedMessages addObject:message];
                }
                else if ([actionType isEqualToString:@"deleteMessages"])
                {
                    std::map<int64_t, int32_t> mapping;
                    [TGDatabaseInstance() messageIdsForRandomIds:actionDesc[@"randomIds"] mapping:&mapping];
                    
                    for (auto it : mapping)
                    {
                        [deleteMessageIds addObject:@(it.second)];
                    }
                    
                    for (NSNumber *nRandomId in actionDesc[@"randomIds"])
                    {
                        int64_t randomId = [nRandomId longLongValue];
                        int index = -1;
                        for (TGMessage *message in addedMessages)
                        {
                            index++;
                            if (message.randomId == randomId)
                            {
                                [addedMessages removeObjectAtIndex:index];
                                
                                break;
                            }
                        }
                    }
                }
                else if ([actionType isEqualToString:@"updateLayer"])
                {
                    layerUpdate = MAX(layerUpdate, [actionDesc[@"layer"] unsignedIntegerValue]);
                }
                else if ([actionType isEqualToString:@"flushHistory"])
                {
                    NSArray *messageIds = [TGDatabaseInstance() messageIdsInConversation:[actionDesc[@"peerId"] longLongValue]];
                    for (NSNumber *nMid in messageIds)
                    {
                        [deleteMessageIds addObject:nMid];
                    }
                }
                else if ([actionType isEqualToString:@"resendActions"])
                {
                    TGLog(@"Requested to resend messages from %d to %d", [actionDesc[@"fromSeq"] intValue], [actionDesc[@"toSeq"] intValue]);
                    
                    [TGModernSendSecretMessageActor enqueueOutgoingResendMessagesForPeerId:_peerId fromSeq:[actionDesc[@"fromSeq"] intValue] / 2 toSeq:[actionDesc[@"toSeq"] intValue] / 2];
                }
                else if ([actionType isEqualToString:@"requestKey"])
                {
                    bool acceptKey = false;
                    
                    TGConversation *conversation = [TGDatabaseInstance() loadConversationWithId:_peerId];
                    if (conversation.encryptedData.currentRekeyExchangeId != 0)
                    {
                        if (conversation.encryptedData.currentRekeyIsInitiatedByLocalClient)
                        {
                            if (conversation.encryptedData.currentRekeyExchangeId > [actionDesc[@"exchangeId"] longLongValue])
                            {
                                int64_t randomId = 0;
                                arc4random_buf(&randomId, 8);
                                NSUInteger peerLayer = MIN([TGDatabaseInstance() peerLayer:_peerId], [TGModernSendSecretMessageActor currentLayer]);
                                
                                NSData *messageData = [TGModernSendSecretMessageActor decryptedServiceMessageActionWithLayer:peerLayer abortKey:(int64_t)[actionDesc[@"exchangeId"] longLongValue] randomId:randomId];
                                if (messageData != nil)
                                {
                                    [TGModernSendSecretMessageActor enqueueOutgoingServiceMessageForPeerId:_peerId layer:peerLayer keyId:0 randomId:randomId messageData:messageData];
                                }
                            }
                            else
                            {
                                acceptKey = true;
                            }
                        }
                        else
                        {
                            TGLog(@"Ignoring incoming requestKey because there is already one in proccess");
                        }
                    }
                    else
                    {
                        acceptKey = true;
                    }
                    
                    if (acceptKey)
                    {
                        TLmessages_DhConfig$messages_dhConfig *config = [TGRequestEncryptedChatActor cachedEncryptionConfig];
                        if (config != nil)
                        {
                            NSData *gABytes = actionDesc[@"g_a"];
                            
                            if (!MTCheckIsSafeGAOrB(gABytes, config.p))
                            {
                                TGLog(@"Error: received requestKey with an unsafe g_a");
                                
                                [self abortHandshake:[actionDesc[@"exchangeId"] longLongValue]];
                            }
                            else
                            {
                                uint8_t bBytes[256];
                                SecRandomCopyBytes(kSecRandomDefault, 256, bBytes);
                                
                                for (int i = 0; i < 256 && i < (int)config.random.length; i++)
                                {
                                    uint8_t currentByte = ((uint8_t *)config.random.bytes)[i];
                                    bBytes[i] ^= currentByte;
                                }
                                
                                NSData *b = [[NSData alloc] initWithBytes:bBytes length:256];
                                
                                int32_t tmpG = config.g;
                                tmpG = NSSwapInt(tmpG);
                                NSData *g = [[NSData alloc] initWithBytes:&tmpG length:4];
                                
                                NSData *gBBytes = MTExp(g, b, config.p);
                                
                                NSMutableData *key = [MTExp(gABytes, b, config.p) mutableCopy];
                                
                                if (key.length > 256)
                                    [key replaceBytesInRange:NSMakeRange(0, 1) withBytes:NULL length:1];
                                while (key.length < 256)
                                {
                                    uint8_t zero = 0;
                                    [key replaceBytesInRange:NSMakeRange(0, 0) withBytes:&zero length:1];
                                    TGLog(@"(adding key padding)");
                                }
                                
                                NSData *keyHash = MTSha1(key);
                                NSData *nKeyId = [[NSData alloc] initWithBytes:(((uint8_t *)keyHash.bytes) + keyHash.length - 8) length:8];
                                int64_t keyId = 0;
                                [nKeyId getBytes:&keyId length:8];
                                
                                int64_t randomId = 0;
                                arc4random_buf(&randomId, 8);
                                NSUInteger peerLayer = MIN([TGDatabaseInstance() peerLayer:_peerId], [TGModernSendSecretMessageActor currentLayer]);
                                
                                TGEncryptedConversationData *encryptedData = [conversation.encryptedData copy];
                                encryptedData.currentRekeyExchangeId = [actionDesc[@"exchangeId"] longLongValue];
                                encryptedData.currentRekeyKey = key;
                                encryptedData.currentRekeyKeyId = keyId;
                                encryptedData.currentRekeyIsInitiatedByLocalClient = false;
                                conversation = [conversation copy];
                                conversation.encryptedData = encryptedData;
                                
                                [TGDatabaseInstance() transactionAddMessages:nil updateConversationDatas:@{@(conversation.conversationId): conversation} notifyAdded:true];
                                
                                NSData *messageData = [TGModernSendSecretMessageActor decryptedServiceMessageActionWithLayer:peerLayer acceptKey:[actionDesc[@"exchangeId"] longLongValue] g_b:gBBytes keyFingerprint:keyId randomId:randomId];
                                if (messageData != nil)
                                {
                                    [TGModernSendSecretMessageActor enqueueOutgoingServiceMessageForPeerId:_peerId layer:peerLayer keyId:0 randomId:randomId messageData:messageData];
                                }
                            }
                        }
                        else
                        {
                            int64_t randomId = 0;
                            arc4random_buf(&randomId, 8);
                            NSUInteger peerLayer = MIN([TGDatabaseInstance() peerLayer:_peerId], [TGModernSendSecretMessageActor currentLayer]);
                            
                            NSData *messageData = [TGModernSendSecretMessageActor decryptedServiceMessageActionWithLayer:peerLayer abortKey:(int64_t)[actionDesc[@"exchangeId"] longLongValue] randomId:randomId];
                            if (messageData != nil)
                            {
                                [TGModernSendSecretMessageActor enqueueOutgoingServiceMessageForPeerId:_peerId layer:peerLayer keyId:0 randomId:randomId messageData:messageData];
                            }
                        }
                    }
                }
                else if ([actionType isEqualToString:@"acceptKey"])
                {
                    TGConversation *conversation = [TGDatabaseInstance() loadConversationWithId:_peerId];
                    if (conversation.encryptedData.currentRekeyExchangeId == [actionDesc[@"exchangeId"] longLongValue] && conversation.encryptedData.currentRekeyIsInitiatedByLocalClient)
                    {
                        TLmessages_DhConfig$messages_dhConfig *config = [TGRequestEncryptedChatActor cachedEncryptionConfig];
                        if (config != nil)
                        {
                            NSData *gBBytes = actionDesc[@"g_b"];
                            
                            if (!MTCheckIsSafeGAOrB(gBBytes, config.p))
                            {
                                TGLog(@"Error: received acceptKey with an unsafe g_b");
                                
                                [self abortHandshake:[actionDesc[@"exchangeId"] longLongValue]];
                            }
                            else
                            {
                                int32_t tmpG = config.g;
                                tmpG = NSSwapInt(tmpG);
                                
                                NSMutableData *key = [MTExp(gBBytes, conversation.encryptedData.currentRekeyNumber, config.p) mutableCopy];
                                
                                if (key.length > 256)
                                    [key replaceBytesInRange:NSMakeRange(0, 1) withBytes:NULL length:1];
                                while (key.length < 256)
                                {
                                    uint8_t zero = 0;
                                    [key replaceBytesInRange:NSMakeRange(0, 0) withBytes:&zero length:1];
                                    TGLog(@"(adding key padding)");
                                }
                                
                                NSData *keyHash = MTSha1(key);
                                NSData *nKeyId = [[NSData alloc] initWithBytes:(((uint8_t *)keyHash.bytes) + keyHash.length - 8) length:8];
                                int64_t keyId = 0;
                                [nKeyId getBytes:&keyId length:8];
                                
                                if (keyId == [actionDesc[@"key_fingerprint"] longLongValue])
                                {
                                    NSUInteger peerLayer = MIN([TGDatabaseInstance() peerLayer:_peerId], [TGModernSendSecretMessageActor currentLayer]);
                                    
                                    TGEncryptedConversationData *encryptedData = [conversation.encryptedData copy];
                                    encryptedData.currentRekeyKey = nil;
                                    encryptedData.currentRekeyKeyId = 0;
                                    encryptedData.currentRekeyExchangeId = 0;
                                    encryptedData.currentRekeyIsInitiatedByLocalClient = false;
                                    encryptedData.currentRekeyNumber = nil;
                                    conversation = [conversation copy];
                                    conversation.encryptedData = encryptedData;
                                    
                                    {
                                        int64_t randomId = 0;
                                        arc4random_buf(&randomId, 8);
                                        NSData *messageData = [TGModernSendSecretMessageActor decryptedServiceMessageActionWithLayer:peerLayer commitKey:[actionDesc[@"exchangeId"] longLongValue] keyFingerprint:keyId randomId:randomId];
                                        if (messageData != nil)
                                        {
                                            int32_t seqOut = [TGModernSendSecretMessageActor enqueueOutgoingServiceMessageForPeerId:_peerId layer:peerLayer keyId:0 randomId:randomId messageData:messageData];
                                        
                                            [TGDatabaseInstance() storeEncryptionKeyForConversationId:_peerId key:key keyFingerprint:keyId firstSeqOut:seqOut];
                                        }
                                    }
                                    
                                    {
                                        int64_t randomId = 0;
                                        arc4random_buf(&randomId, 8);
                                        NSData *messageData = [TGModernSendSecretMessageActor decryptedServiceMessageActionWithLayer:peerLayer noopRandomId:randomId];
                                        if (messageData != nil)
                                        {
                                            [TGModernSendSecretMessageActor enqueueOutgoingServiceMessageForPeerId:_peerId layer:peerLayer keyId:0 randomId:randomId messageData:messageData];
                                        }
                                    }
                                    
                                    [TGDatabaseInstance() transactionAddMessages:nil updateConversationDatas:@{@(conversation.conversationId): conversation} notifyAdded:true];
                                    
                                    pollAtTheEnd = true;
                                }
                                else
                                {
                                    TGLog(@"Key_fingerprints do not match: %lld vs %lld", [actionDesc[@"key_fingerprint"] longLongValue], (long long)keyId);
                                    [self abortHandshake:[actionDesc[@"exchangeId"] longLongValue]];
                                }
                            }
                        }
                    }
                }
                else if ([actionType isEqualToString:@"commitKey"])
                {
                    TGConversation *conversation = [TGDatabaseInstance() loadConversationWithId:_peerId];
                    if (conversation.encryptedData.currentRekeyExchangeId == [actionDesc[@"exchangeId"] longLongValue] && !conversation.encryptedData.currentRekeyIsInitiatedByLocalClient)
                    {
                        if (conversation.encryptedData.currentRekeyKeyId == [actionDesc[@"key_fingerprint"] longLongValue])
                        {
                            NSData *key = conversation.encryptedData.currentRekeyKey;
                            int64_t keyId = conversation.encryptedData.currentRekeyKeyId;
                            
                            int32_t seqOut = [TGDatabaseInstance() peerNextSeqOut:_peerId];
                            [TGDatabaseInstance() storeEncryptionKeyForConversationId:_peerId key:key keyFingerprint:keyId firstSeqOut:seqOut];
                            
                            TGEncryptedConversationData *encryptedData = [conversation.encryptedData copy];
                            encryptedData.currentRekeyKey = nil;
                            encryptedData.currentRekeyKeyId = 0;
                            encryptedData.currentRekeyExchangeId = 0;
                            encryptedData.currentRekeyIsInitiatedByLocalClient = false;
                            encryptedData.currentRekeyNumber = nil;
                            conversation = [conversation copy];
                            conversation.encryptedData = encryptedData;
                            
                            int64_t randomId = 0;
                            arc4random_buf(&randomId, 8);
                            NSUInteger peerLayer = MIN([TGDatabaseInstance() peerLayer:_peerId], [TGModernSendSecretMessageActor currentLayer]);
                            NSData *messageData = [TGModernSendSecretMessageActor decryptedServiceMessageActionWithLayer:peerLayer noopRandomId:randomId];
                            if (messageData != nil)
                            {
                                [TGModernSendSecretMessageActor enqueueOutgoingServiceMessageForPeerId:_peerId layer:peerLayer keyId:0 randomId:randomId messageData:messageData];
                            }
                            
                            [TGDatabaseInstance() transactionAddMessages:nil updateConversationDatas:@{@(conversation.conversationId): conversation} notifyAdded:true];
                            
                            pollAtTheEnd = true;
                        }
                        else
                        {
                            TGLog(@"Error: received commitKey with invalid key_fingerprint %lld vs %lld", [actionDesc[@"key_fingerprint"] longLongValue], conversation.encryptedData.currentRekeyKeyId);
                        }
                    }
                }
                else if ([actionType isEqualToString:@"abortKey"])
                {
                    [self markHandshakeAsAborted:[actionDesc[@"exchangeId"] longLongValue]];
                }
            }
            
            if (addedMessages.count != 0)
            {
                std::set<int64_t> addedMessagesRandomIds;
                for (TGMessage *message in addedMessages)
                {
                    addedMessagesRandomIds.insert(message.randomId);
                }
                
                [TGDatabaseInstance() filterExistingRandomIds:&addedMessagesRandomIds];
                
                for (NSInteger index = 0; index < (NSInteger)addedMessages.count; index++)
                {
                    TGMessage *message = addedMessages[index];
                    if (addedMessagesRandomIds.find(message.randomId) == addedMessagesRandomIds.end())
                    {
                        [addedMessages removeObjectAtIndex:index];
                        index--;
                    }
                }
                
                [TGDatabaseInstance() transactionAddMessages:addedMessages updateConversationDatas:nil notifyAdded:true];
            }
            
            if (layerUpdate != 0 && layerUpdate > [TGDatabaseInstance() peerLayer:_peerId])
            {
                int64_t randomId = 0;
                arc4random_buf(&randomId, 8);
                
                [TGDatabaseInstance() setPeerLayer:_peerId layer:layerUpdate];
                [TGDatabaseInstance() maybeCreateAdditionalEncryptedHashForPeer:_peerId];

                NSUInteger peerLayer = [TGDatabaseInstance() peerLayer:_peerId];
                
                NSData *messageData = [TGModernSendSecretMessageActor decryptedServiceMessageActionWithLayer:MIN(peerLayer, [TGModernSendSecretMessageActor currentLayer]) notifyLayer:[TGModernSendSecretMessageActor currentLayer] randomId:randomId];
                
                if (messageData != nil)
                {
                    [TGModernSendSecretMessageActor enqueueOutgoingServiceMessageForPeerId:_peerId layer:MIN(peerLayer, [TGModernSendSecretMessageActor currentLayer]) keyId:0 randomId:randomId messageData:messageData];
                }
                
                [ActionStageInstance() dispatchResource:[[NSString alloc] initWithFormat:@"/tg/peerLayerUpdates/(%" PRId64 ")", _peerId] resource:@{@"layer": @(layerUpdate)}];
            }
            
            if (deleteMessageIds.count != 0)
            {
                [TGDatabaseInstance() transactionRemoveMessages:@{@(_peerId): deleteMessageIds} updateConversationDatas:nil];
            }
            
            if (initiateSelfDestructMessageRandomIds.count != 0)
            {
                [TGDatabaseInstance() dispatchOnDatabaseThread:^
                {
                    std::map<int64_t, int32_t> randomIdToMessageIdMap;
                    [TGDatabaseInstance() messageIdsForRandomIds:initiateSelfDestructMessageRandomIds mapping:&randomIdToMessageIdMap];
                    NSMutableArray *messageIds = [[NSMutableArray alloc] init];
                    for (auto it : randomIdToMessageIdMap)
                    {
                        [messageIds addObject:@(it.second)];
                    }
                    [TGDatabaseInstance() initiateSelfDestructForMessageIds:messageIds];
                } synchronous:false];
            }
            
            if (secretMessageFlagChanges.count != 0)
            {
                NSMutableDictionary *secretMessageFlagChangesWithMessageIds = [[NSMutableDictionary alloc] init];
                
                [TGDatabaseInstance() dispatchOnDatabaseThread:^
                {
                    [secretMessageFlagChanges enumerateKeysAndObjectsUsingBlock:^(NSNumber *nRandomId, NSNumber *nFlags, __unused BOOL *stop)
                    {
                        int32_t messageId = [TGDatabaseInstance() messageIdForRandomId:(int64_t)[nRandomId longLongValue]];
                        if (messageId != 0)
                            secretMessageFlagChangesWithMessageIds[@(messageId)] = nFlags;
                    }];
                } synchronous:true];
                
                if (secretMessageFlagChangesWithMessageIds.count != 0)
                {
                    [ActionStageInstance() dispatchResource:[[NSString alloc] initWithFormat:@"/tg/conversation/(%" PRId64 ")/messageFlagChanges", _peerId] resource:secretMessageFlagChangesWithMessageIds];
                }
            }
            
            if (pollAtTheEnd)
                [self _poll];
        }];
    }];
}

- (void)abortHandshake:(int64_t)exchangeId
{
    int64_t randomId = 0;
    arc4random_buf(&randomId, 8);
    NSUInteger peerLayer = MIN([TGDatabaseInstance() peerLayer:_peerId], [TGModernSendSecretMessageActor currentLayer]);
    
    NSData *messageData = [TGModernSendSecretMessageActor decryptedServiceMessageActionWithLayer:peerLayer abortKey:exchangeId randomId:randomId];
    if (messageData != nil)
    {
        [TGModernSendSecretMessageActor enqueueOutgoingServiceMessageForPeerId:_peerId layer:peerLayer keyId:0 randomId:randomId messageData:messageData];
    }
    
    [self markHandshakeAsAborted:exchangeId];
}

- (void)markHandshakeAsAborted:(int64_t)exchangeId
{
    TGConversation *conversation = [TGDatabaseInstance() loadConversationWithId:_peerId];
    if (conversation.encryptedData.currentRekeyExchangeId == exchangeId)
    {
        TGEncryptedConversationData *encryptedData = [conversation.encryptedData copy];
        encryptedData.currentRekeyKey = nil;
        encryptedData.currentRekeyKeyId = 0;
        encryptedData.currentRekeyExchangeId = 0;
        encryptedData.currentRekeyIsInitiatedByLocalClient = false;
        encryptedData.currentRekeyNumber = nil;
        conversation = [conversation copy];
        conversation.encryptedData = encryptedData;
        
        [TGDatabaseInstance() transactionAddMessages:nil updateConversationDatas:@{@(conversation.conversationId): conversation} notifyAdded:true];
    }
}

- (bool)isResendAction:(TGStoredIncomingMessageSecretAction *)action
{
    id decryptedObject = nil;
    switch (action.layer)
    {
        case 1:
            decryptedObject = [Secret1__Environment parseObject:action.data];
            break;
        case 17:
        {
            decryptedObject = [Secret17__Environment parseObject:action.data];
            if ([decryptedObject isKindOfClass:[Secret17_DecryptedMessageLayer class]])
                decryptedObject = ((Secret17_DecryptedMessageLayer *)decryptedObject).message;
            break;
        }
        case 20:
        {
            decryptedObject = [Secret20__Environment parseObject:action.data];
            if ([decryptedObject isKindOfClass:[Secret20_DecryptedMessageLayer class]])
                decryptedObject = ((Secret20_DecryptedMessageLayer *)decryptedObject).message;
            break;
        }
        case 23:
        {
            decryptedObject = [Secret23__Environment parseObject:action.data];
            if ([decryptedObject isKindOfClass:[Secret23_DecryptedMessageLayer class]])
                decryptedObject = ((Secret23_DecryptedMessageLayer *)decryptedObject).message;
            break;
        }
        case 46:
        {
            decryptedObject = [Secret46__Environment parseObject:action.data];
            if ([decryptedObject isKindOfClass:[Secret46_DecryptedMessageLayer class]])
                decryptedObject = ((Secret46_DecryptedMessageLayer *)decryptedObject).message;
            break;
        }
        case 66:
        {
            decryptedObject = [Secret66__Environment parseObject:action.data];
            if ([decryptedObject isKindOfClass:[Secret66_DecryptedMessageLayer class]])
                decryptedObject = ((Secret66_DecryptedMessageLayer *)decryptedObject).message;
            break;
        }
        default:
            break;
    }
    
    bool decodeMessage = false;
    bool flushHistory = false;
    bool decodeMessageWithoutAction = true;
    NSDictionary *decryptedAction = [TGSecretIncomingQueueActor parseDecryptedAction:decryptedObject conversationId:_peerId decodeMessageWithAction:&decodeMessage flushHistory:&flushHistory decodeMessageWithoutAction:&decodeMessageWithoutAction date:action.date];
    if ([decryptedAction[@"actionType"] isEqualToString:@"resendActions"])
        return true;
    return false;
}

- (void)_processIncomingMessage:(TGStoredIncomingMessageSecretAction *)action seqIn:(int32_t)seqIn seqOut:(int32_t)seqOut addedMessages:(NSMutableArray *)addedMessages addedActions:(NSMutableArray *)addedActions layerUpdate:(NSUInteger *)layerUpdate
{
    TGLog(@"incoming message: layer: %d seq_in: %d, seq_out: %d", (int)action.layer, seqIn, seqOut);
    
    if (layerUpdate)
        *layerUpdate = MAX(*layerUpdate, action.layer);
    
    id decryptedObject = nil;
    switch (action.layer)
    {
        case 1:
            decryptedObject = [Secret1__Environment parseObject:action.data];
            break;
        case 17:
        {
            decryptedObject = [Secret17__Environment parseObject:action.data];
            if ([decryptedObject isKindOfClass:[Secret17_DecryptedMessageLayer class]])
                decryptedObject = ((Secret17_DecryptedMessageLayer *)decryptedObject).message;
            break;
        }
        case 20:
        {
            decryptedObject = [Secret20__Environment parseObject:action.data];
            if ([decryptedObject isKindOfClass:[Secret20_DecryptedMessageLayer class]])
                decryptedObject = ((Secret20_DecryptedMessageLayer *)decryptedObject).message;
            break;
        }
        case 23:
        {
            decryptedObject = [Secret23__Environment parseObject:action.data];
            if ([decryptedObject isKindOfClass:[Secret23_DecryptedMessageLayer class]])
                decryptedObject = ((Secret23_DecryptedMessageLayer *)decryptedObject).message;
            break;
        }
        case 46:
        {
            decryptedObject = [Secret46__Environment parseObject:action.data];
            if ([decryptedObject isKindOfClass:[Secret46_DecryptedMessageLayer class]])
                decryptedObject = ((Secret46_DecryptedMessageLayer *)decryptedObject).message;
            break;
        }
        case 66:
        {
            decryptedObject = [Secret66__Environment parseObject:action.data];
            if ([decryptedObject isKindOfClass:[Secret66_DecryptedMessageLayer class]])
                decryptedObject = ((Secret66_DecryptedMessageLayer *)decryptedObject).message;
            break;
        }
        default:
            break;
    }
    
    bool decodeMessage = false;
    bool flushHistory = false;
    bool decodeMessageWithoutAction = true;
    NSDictionary *decryptedAction = [TGSecretIncomingQueueActor parseDecryptedAction:decryptedObject conversationId:_peerId decodeMessageWithAction:&decodeMessage flushHistory:&flushHistory decodeMessageWithoutAction:&decodeMessageWithoutAction date:action.date];
    
    if (flushHistory)
        [addedMessages removeAllObjects];
    
    if (decryptedAction != nil)
        [addedActions addObject:decryptedAction];
    
    if ((decryptedAction == nil || decodeMessage) && decodeMessageWithoutAction)
    {
        TGMessage *message = [TGSecretIncomingQueueActor parseDecryptedMessage:decryptedObject date:action.date fileInfo:action.fileInfo conversationId:_peerId fromUid:_userId seqIn:seqIn seqOut:seqOut];
        message.layer = action.layer;
        if (message != nil)
            [addedMessages addObject:message];
    }
}

+ (TGMessage *)parseDecryptedMessage:(id)decryptedMessage date:(int32_t)date fileInfo:(TGStoredIncomingMessageFileInfo *)fileInfo conversationId:(int64_t)conversationId fromUid:(int32_t)fromUid seqIn:(int32_t)seqIn seqOut:(int32_t)seqOut
{
    TGMessage *message = nil;
    
    if ([decryptedMessage isKindOfClass:[Secret1_DecryptedMessage class]])
    {
        message = [[TGMessage alloc] initWithDecryptedMessageDesc1:decryptedMessage encryptedFile:fileInfo conversationId:conversationId fromUid:fromUid date:date];
    }
    else if ([decryptedMessage isKindOfClass:[Secret17_DecryptedMessage class]])
    {
        message = [[TGMessage alloc] initWithDecryptedMessageDesc17:decryptedMessage encryptedFile:fileInfo conversationId:conversationId fromUid:fromUid date:date];
    }
    else if ([decryptedMessage isKindOfClass:[Secret20_DecryptedMessage class]])
    {
        message = [[TGMessage alloc] initWithDecryptedMessageDesc20:decryptedMessage encryptedFile:fileInfo conversationId:conversationId fromUid:fromUid date:date];
    }
    else if ([decryptedMessage isKindOfClass:[Secret23_DecryptedMessage class]])
    {
        message = [[TGMessage alloc] initWithDecryptedMessageDesc23:decryptedMessage encryptedFile:fileInfo conversationId:conversationId fromUid:fromUid date:date];
    }
    else if ([decryptedMessage isKindOfClass:[Secret46_DecryptedMessage class]])
    {
        message = [[TGMessage alloc] initWithDecryptedMessageDesc45:decryptedMessage encryptedFile:fileInfo conversationId:conversationId fromUid:fromUid date:date];
    }
    else if ([decryptedMessage isKindOfClass:[Secret66_DecryptedMessage class]])
    {
        message = [[TGMessage alloc] initWithDecryptedMessageDesc66:decryptedMessage encryptedFile:fileInfo conversationId:conversationId fromUid:fromUid date:date];
    }
    message.mid = INT_MIN;
    message.seqIn = seqIn;
    message.seqOut = seqOut;
    
    return message;
}

+ (NSDictionary *)parseDecryptedAction:(id)decryptedMessage conversationId:(int64_t)conversationId decodeMessageWithAction:(bool *)decodeMessageWithAction flushHistory:(bool *)flushHistory decodeMessageWithoutAction:(bool *)decodeMessageWithoutAction date:(int32_t)date
{
    if (decodeMessageWithAction)
        *decodeMessageWithAction = false;
    
    if ([decryptedMessage isKindOfClass:[Secret1_DecryptedMessage_decryptedMessageService class]])
    {
        if (decodeMessageWithoutAction)
            *decodeMessageWithoutAction = false;
        
        id action = ((Secret1_DecryptedMessage_decryptedMessageService *)decryptedMessage).action;
        
        if ([action isKindOfClass:[Secret1_DecryptedMessageAction_decryptedMessageActionDeleteMessages class]])
        {
            Secret1_DecryptedMessageAction_decryptedMessageActionDeleteMessages *concreteAction = action;
            
            return @{
                     @"peerId": @(conversationId),
                     @"actionType": @"deleteMessages",
                     @"randomIds": concreteAction.randomIds == nil ? @[] : concreteAction.randomIds
                     };
        }
        else if ([action isKindOfClass:[Secret1_DecryptedMessageAction_decryptedMessageActionFlushHistory class]])
        {
            if (flushHistory != NULL)
                *flushHistory = true;
            
            return @{
                     @"peerId": @(conversationId),
                     @"actionType": @"flushHistory"
                     };
        }
        else if ([action isKindOfClass:[Secret1_DecryptedMessageAction_decryptedMessageActionSetMessageTTL class]])
        {
            if (decodeMessageWithoutAction)
                *decodeMessageWithoutAction = true;
        }
        else if ([action isKindOfClass:[Secret1_DecryptedMessageAction_decryptedMessageActionNotifyLayer class]])
        {
            Secret1_DecryptedMessageAction_decryptedMessageActionNotifyLayer *concreteAction = action;
            return @{
                     @"peerId": @(conversationId),
                     @"actionType": @"updateLayer",
                     @"layer": @([concreteAction.layer unsignedIntegerValue])
                     };
        }
    }
    else if ([decryptedMessage isKindOfClass:[Secret17_DecryptedMessage_decryptedMessageService class]])
    {
        if (decodeMessageWithoutAction)
            *decodeMessageWithoutAction = false;
        
        id action = ((Secret17_DecryptedMessage_decryptedMessageService *)decryptedMessage).action;
        
        if ([action isKindOfClass:[Secret17_DecryptedMessageAction_decryptedMessageActionDeleteMessages class]])
        {
            Secret1_DecryptedMessageAction_decryptedMessageActionDeleteMessages *concreteAction = action;
            
            return @{
                     @"peerId": @(conversationId),
                     @"actionType": @"deleteMessages",
                     @"randomIds": concreteAction.randomIds == nil ? @[] : concreteAction.randomIds
                     };
        }
        else if ([action isKindOfClass:[Secret17_DecryptedMessageAction_decryptedMessageActionFlushHistory class]])
        {
            if (flushHistory != NULL)
                *flushHistory = true;
            
            return @{
                     @"peerId": @(conversationId),
                     @"actionType": @"flushHistory"
                     };
        }
        else if ([action isKindOfClass:[Secret17_DecryptedMessageAction_decryptedMessageActionNotifyLayer class]])
        {
            Secret17_DecryptedMessageAction_decryptedMessageActionNotifyLayer *concreteAction = action;
            return @{
                     @"peerId": @(conversationId),
                     @"actionType": @"updateLayer",
                     @"layer": @([concreteAction.layer unsignedIntegerValue])
                     };
        }
        else if ([action isKindOfClass:[Secret17_DecryptedMessageAction_decryptedMessageActionReadMessages class]])
        {
            Secret17_DecryptedMessageAction_decryptedMessageActionReadMessages *concreteAction = action;
            return @{
                     @"peerId": @(conversationId),
                     @"actionType": @"readMessages",
                     @"randomIds": concreteAction.randomIds
                     };
        }
        else if ([action isKindOfClass:[Secret17_DecryptedMessageAction_decryptedMessageActionScreenshotMessages class]])
        {
            Secret17_DecryptedMessageAction_decryptedMessageActionScreenshotMessages *concreteAction = action;
            return @{
                     @"peerId": @(conversationId),
                     @"actionType": @"screenshotMessages",
                     @"randomIds": concreteAction.randomIds,
                     @"date": @(date)
                     };
        }
        else if ([action isKindOfClass:[Secret17_DecryptedMessageAction_decryptedMessageActionTyping class]])
        {
            
        }
        else if ([action isKindOfClass:[Secret17_DecryptedMessageAction_decryptedMessageActionSetMessageTTL class]])
        {
            if (decodeMessageWithoutAction)
                *decodeMessageWithoutAction = true;
        }
        else if ([action isKindOfClass:[Secret17_DecryptedMessageAction_decryptedMessageActionResend class]])
        {
            Secret17_DecryptedMessageAction_decryptedMessageActionResend *concreteAction = action;
            return @{@"actionType": @"resendActions", @"fromSeq": concreteAction.startSeqNo, @"toSeq": concreteAction.endSeqNo};
        }
    }
    else if ([decryptedMessage isKindOfClass:[Secret20_DecryptedMessage_decryptedMessageService class]])
    {
        if (decodeMessageWithoutAction)
            *decodeMessageWithoutAction = false;
        
        id action = ((Secret20_DecryptedMessage_decryptedMessageService *)decryptedMessage).action;
        
        if ([action isKindOfClass:[Secret20_DecryptedMessageAction_decryptedMessageActionDeleteMessages class]])
        {
            Secret1_DecryptedMessageAction_decryptedMessageActionDeleteMessages *concreteAction = action;
            
            return @{
                     @"peerId": @(conversationId),
                     @"actionType": @"deleteMessages",
                     @"randomIds": concreteAction.randomIds == nil ? @[] : concreteAction.randomIds
                     };
        }
        else if ([action isKindOfClass:[Secret20_DecryptedMessageAction_decryptedMessageActionFlushHistory class]])
        {
            if (flushHistory != NULL)
                *flushHistory = true;
            
            return @{
                     @"peerId": @(conversationId),
                     @"actionType": @"flushHistory"
                     };
        }
        else if ([action isKindOfClass:[Secret20_DecryptedMessageAction_decryptedMessageActionNotifyLayer class]])
        {
            Secret20_DecryptedMessageAction_decryptedMessageActionNotifyLayer *concreteAction = action;
            return @{
                     @"peerId": @(conversationId),
                     @"actionType": @"updateLayer",
                     @"layer": @([concreteAction.layer unsignedIntegerValue])
                     };
        }
        else if ([action isKindOfClass:[Secret20_DecryptedMessageAction_decryptedMessageActionReadMessages class]])
        {
            Secret20_DecryptedMessageAction_decryptedMessageActionReadMessages *concreteAction = action;
            return @{
                     @"peerId": @(conversationId),
                     @"actionType": @"readMessages",
                     @"randomIds": concreteAction.randomIds
                     };
        }
        else if ([action isKindOfClass:[Secret20_DecryptedMessageAction_decryptedMessageActionScreenshotMessages class]])
        {
            Secret20_DecryptedMessageAction_decryptedMessageActionScreenshotMessages *concreteAction = action;
            return @{
                     @"peerId": @(conversationId),
                     @"actionType": @"screenshotMessages",
                     @"randomIds": concreteAction.randomIds,
                     @"date": @(date)
                     };
        }
        else if ([action isKindOfClass:[Secret20_DecryptedMessageAction_decryptedMessageActionTyping class]])
        {
            
        }
        else if ([action isKindOfClass:[Secret20_DecryptedMessageAction_decryptedMessageActionSetMessageTTL class]])
        {
            if (decodeMessageWithoutAction)
                *decodeMessageWithoutAction = true;
        }
        else if ([action isKindOfClass:[Secret20_DecryptedMessageAction_decryptedMessageActionResend class]])
        {
            Secret20_DecryptedMessageAction_decryptedMessageActionResend *concreteAction = action;
            return @{@"actionType": @"resendActions", @"fromSeq": concreteAction.startSeqNo, @"toSeq": concreteAction.endSeqNo};
        }
        else if ([action isKindOfClass:[Secret20_DecryptedMessageAction_decryptedMessageActionRequestKey class]])
        {
            Secret20_DecryptedMessageAction_decryptedMessageActionRequestKey *concreteAction = action;
            return @{@"actionType": @"requestKey", @"exchangeId": concreteAction.exchangeId, @"g_a": concreteAction.gA};
        }
        else if ([action isKindOfClass:[Secret20_DecryptedMessageAction_decryptedMessageActionAcceptKey class]])
        {
            Secret20_DecryptedMessageAction_decryptedMessageActionAcceptKey *concreteAction = action;
            return @{@"actionType": @"acceptKey", @"exchangeId": concreteAction.exchangeId, @"g_b": concreteAction.gB, @"key_fingerprint": concreteAction.keyFingerprint};
        }
        else if ([action isKindOfClass:[Secret20_DecryptedMessageAction_decryptedMessageActionCommitKey class]])
        {
            Secret20_DecryptedMessageAction_decryptedMessageActionCommitKey *concreteAction = action;
            return @{@"actionType": @"commitKey", @"exchangeId": concreteAction.exchangeId, @"key_fingerprint": concreteAction.keyFingerprint};
        }
        else if ([action isKindOfClass:[Secret20_DecryptedMessageAction_decryptedMessageActionAbortKey class]])
        {
            Secret20_DecryptedMessageAction_decryptedMessageActionAbortKey *concreteAction = action;
            return @{@"actionType": @"abortKey", @"exchangeId": concreteAction.exchangeId};
        }
    }
    else if ([decryptedMessage isKindOfClass:[Secret23_DecryptedMessage_decryptedMessageService class]])
    {
        if (decodeMessageWithoutAction)
        *decodeMessageWithoutAction = false;
        
        id action = ((Secret23_DecryptedMessage_decryptedMessageService *)decryptedMessage).action;
        
        if ([action isKindOfClass:[Secret23_DecryptedMessageAction_decryptedMessageActionDeleteMessages class]])
        {
            Secret1_DecryptedMessageAction_decryptedMessageActionDeleteMessages *concreteAction = action;
            
            return @{
                     @"peerId": @(conversationId),
                     @"actionType": @"deleteMessages",
                     @"randomIds": concreteAction.randomIds == nil ? @[] : concreteAction.randomIds
                     };
        }
        else if ([action isKindOfClass:[Secret23_DecryptedMessageAction_decryptedMessageActionFlushHistory class]])
        {
            if (flushHistory != NULL)
            *flushHistory = true;
            
            return @{
                     @"peerId": @(conversationId),
                     @"actionType": @"flushHistory"
                     };
        }
        else if ([action isKindOfClass:[Secret23_DecryptedMessageAction_decryptedMessageActionNotifyLayer class]])
        {
            Secret23_DecryptedMessageAction_decryptedMessageActionNotifyLayer *concreteAction = action;
            return @{
                     @"peerId": @(conversationId),
                     @"actionType": @"updateLayer",
                     @"layer": @([concreteAction.layer unsignedIntegerValue])
                     };
        }
        else if ([action isKindOfClass:[Secret23_DecryptedMessageAction_decryptedMessageActionReadMessages class]])
        {
            Secret23_DecryptedMessageAction_decryptedMessageActionReadMessages *concreteAction = action;
            return @{
                     @"peerId": @(conversationId),
                     @"actionType": @"readMessages",
                     @"randomIds": concreteAction.randomIds
                     };
        }
        else if ([action isKindOfClass:[Secret23_DecryptedMessageAction_decryptedMessageActionScreenshotMessages class]])
        {
            Secret23_DecryptedMessageAction_decryptedMessageActionScreenshotMessages *concreteAction = action;
            return @{
                     @"peerId": @(conversationId),
                     @"actionType": @"screenshotMessages",
                     @"randomIds": concreteAction.randomIds,
                     @"date": @(date)
                     };
        }
        else if ([action isKindOfClass:[Secret23_DecryptedMessageAction_decryptedMessageActionTyping class]])
        {
            
        }
        else if ([action isKindOfClass:[Secret23_DecryptedMessageAction_decryptedMessageActionSetMessageTTL class]])
        {
            if (decodeMessageWithoutAction)
                *decodeMessageWithoutAction = true;
        }
        else if ([action isKindOfClass:[Secret23_DecryptedMessageAction_decryptedMessageActionResend class]])
        {
            Secret23_DecryptedMessageAction_decryptedMessageActionResend *concreteAction = action;
            return @{@"actionType": @"resendActions", @"fromSeq": concreteAction.startSeqNo, @"toSeq": concreteAction.endSeqNo};
        }
        else if ([action isKindOfClass:[Secret23_DecryptedMessageAction_decryptedMessageActionRequestKey class]])
        {
            Secret23_DecryptedMessageAction_decryptedMessageActionRequestKey *concreteAction = action;
            return @{@"actionType": @"requestKey", @"exchangeId": concreteAction.exchangeId, @"g_a": concreteAction.gA};
        }
        else if ([action isKindOfClass:[Secret23_DecryptedMessageAction_decryptedMessageActionAcceptKey class]])
        {
            Secret23_DecryptedMessageAction_decryptedMessageActionAcceptKey *concreteAction = action;
            return @{@"actionType": @"acceptKey", @"exchangeId": concreteAction.exchangeId, @"g_b": concreteAction.gB, @"key_fingerprint": concreteAction.keyFingerprint};
        }
        else if ([action isKindOfClass:[Secret23_DecryptedMessageAction_decryptedMessageActionCommitKey class]])
        {
            Secret23_DecryptedMessageAction_decryptedMessageActionCommitKey *concreteAction = action;
            return @{@"actionType": @"commitKey", @"exchangeId": concreteAction.exchangeId, @"key_fingerprint": concreteAction.keyFingerprint};
        }
        else if ([action isKindOfClass:[Secret23_DecryptedMessageAction_decryptedMessageActionAbortKey class]])
        {
            Secret23_DecryptedMessageAction_decryptedMessageActionAbortKey *concreteAction = action;
            return @{@"actionType": @"abortKey", @"exchangeId": concreteAction.exchangeId};
        }
    }
    else if ([decryptedMessage isKindOfClass:[Secret46_DecryptedMessage_decryptedMessageService class]])
    {
        if (decodeMessageWithoutAction)
            *decodeMessageWithoutAction = false;
        
        id action = ((Secret46_DecryptedMessage_decryptedMessageService *)decryptedMessage).action;
        
        if ([action isKindOfClass:[Secret46_DecryptedMessageAction_decryptedMessageActionDeleteMessages class]])
        {
            Secret1_DecryptedMessageAction_decryptedMessageActionDeleteMessages *concreteAction = action;
            
            return @{
                     @"peerId": @(conversationId),
                     @"actionType": @"deleteMessages",
                     @"randomIds": concreteAction.randomIds == nil ? @[] : concreteAction.randomIds
                     };
        }
        else if ([action isKindOfClass:[Secret46_DecryptedMessageAction_decryptedMessageActionFlushHistory class]])
        {
            if (flushHistory != NULL)
                *flushHistory = true;
            
            return @{
                     @"peerId": @(conversationId),
                     @"actionType": @"flushHistory"
                     };
        }
        else if ([action isKindOfClass:[Secret46_DecryptedMessageAction_decryptedMessageActionNotifyLayer class]])
        {
            Secret46_DecryptedMessageAction_decryptedMessageActionNotifyLayer *concreteAction = action;
            return @{
                     @"peerId": @(conversationId),
                     @"actionType": @"updateLayer",
                     @"layer": @([concreteAction.layer unsignedIntegerValue])
                     };
        }
        else if ([action isKindOfClass:[Secret46_DecryptedMessageAction_decryptedMessageActionReadMessages class]])
        {
            Secret46_DecryptedMessageAction_decryptedMessageActionReadMessages *concreteAction = action;
            return @{
                     @"peerId": @(conversationId),
                     @"actionType": @"readMessages",
                     @"randomIds": concreteAction.randomIds
                     };
        }
        else if ([action isKindOfClass:[Secret46_DecryptedMessageAction_decryptedMessageActionScreenshotMessages class]])
        {
            Secret46_DecryptedMessageAction_decryptedMessageActionScreenshotMessages *concreteAction = action;
            return @{
                     @"peerId": @(conversationId),
                     @"actionType": @"screenshotMessages",
                     @"randomIds": concreteAction.randomIds,
                     @"date": @(date)
                     };
        }
        else if ([action isKindOfClass:[Secret46_DecryptedMessageAction_decryptedMessageActionTyping class]])
        {
            
        }
        else if ([action isKindOfClass:[Secret46_DecryptedMessageAction_decryptedMessageActionSetMessageTTL class]])
        {
            if (decodeMessageWithoutAction)
                *decodeMessageWithoutAction = true;
        }
        else if ([action isKindOfClass:[Secret46_DecryptedMessageAction_decryptedMessageActionResend class]])
        {
            Secret46_DecryptedMessageAction_decryptedMessageActionResend *concreteAction = action;
            return @{@"actionType": @"resendActions", @"fromSeq": concreteAction.startSeqNo, @"toSeq": concreteAction.endSeqNo};
        }
        else if ([action isKindOfClass:[Secret46_DecryptedMessageAction_decryptedMessageActionRequestKey class]])
        {
            Secret46_DecryptedMessageAction_decryptedMessageActionRequestKey *concreteAction = action;
            return @{@"actionType": @"requestKey", @"exchangeId": concreteAction.exchangeId, @"g_a": concreteAction.gA};
        }
        else if ([action isKindOfClass:[Secret46_DecryptedMessageAction_decryptedMessageActionAcceptKey class]])
        {
            Secret46_DecryptedMessageAction_decryptedMessageActionAcceptKey *concreteAction = action;
            return @{@"actionType": @"acceptKey", @"exchangeId": concreteAction.exchangeId, @"g_b": concreteAction.gB, @"key_fingerprint": concreteAction.keyFingerprint};
        }
        else if ([action isKindOfClass:[Secret46_DecryptedMessageAction_decryptedMessageActionCommitKey class]])
        {
            Secret46_DecryptedMessageAction_decryptedMessageActionCommitKey *concreteAction = action;
            return @{@"actionType": @"commitKey", @"exchangeId": concreteAction.exchangeId, @"key_fingerprint": concreteAction.keyFingerprint};
        }
        else if ([action isKindOfClass:[Secret46_DecryptedMessageAction_decryptedMessageActionAbortKey class]])
        {
            Secret46_DecryptedMessageAction_decryptedMessageActionAbortKey *concreteAction = action;
            return @{@"actionType": @"abortKey", @"exchangeId": concreteAction.exchangeId};
        }
    } else if ([decryptedMessage isKindOfClass:[Secret66_DecryptedMessage_decryptedMessageService class]]) {
        if (decodeMessageWithoutAction)
            *decodeMessageWithoutAction = false;
        
        id action = ((Secret66_DecryptedMessage_decryptedMessageService *)decryptedMessage).action;
        
        if ([action isKindOfClass:[Secret66_DecryptedMessageAction_decryptedMessageActionDeleteMessages class]])
        {
            Secret1_DecryptedMessageAction_decryptedMessageActionDeleteMessages *concreteAction = action;
            
            return @{
                     @"peerId": @(conversationId),
                     @"actionType": @"deleteMessages",
                     @"randomIds": concreteAction.randomIds == nil ? @[] : concreteAction.randomIds
                     };
        }
        else if ([action isKindOfClass:[Secret66_DecryptedMessageAction_decryptedMessageActionFlushHistory class]])
        {
            if (flushHistory != NULL)
                *flushHistory = true;
            
            return @{
                     @"peerId": @(conversationId),
                     @"actionType": @"flushHistory"
                     };
        }
        else if ([action isKindOfClass:[Secret66_DecryptedMessageAction_decryptedMessageActionNotifyLayer class]])
        {
            Secret66_DecryptedMessageAction_decryptedMessageActionNotifyLayer *concreteAction = action;
            return @{
                     @"peerId": @(conversationId),
                     @"actionType": @"updateLayer",
                     @"layer": @([concreteAction.layer unsignedIntegerValue])
                     };
        }
        else if ([action isKindOfClass:[Secret66_DecryptedMessageAction_decryptedMessageActionReadMessages class]])
        {
            Secret66_DecryptedMessageAction_decryptedMessageActionReadMessages *concreteAction = action;
            return @{
                     @"peerId": @(conversationId),
                     @"actionType": @"readMessages",
                     @"randomIds": concreteAction.randomIds
                     };
        }
        else if ([action isKindOfClass:[Secret66_DecryptedMessageAction_decryptedMessageActionScreenshotMessages class]])
        {
            Secret66_DecryptedMessageAction_decryptedMessageActionScreenshotMessages *concreteAction = action;
            return @{
                     @"peerId": @(conversationId),
                     @"actionType": @"screenshotMessages",
                     @"randomIds": concreteAction.randomIds,
                     @"date": @(date)
                     };
        }
        else if ([action isKindOfClass:[Secret66_DecryptedMessageAction_decryptedMessageActionTyping class]])
        {
            
        }
        else if ([action isKindOfClass:[Secret66_DecryptedMessageAction_decryptedMessageActionSetMessageTTL class]])
        {
            if (decodeMessageWithoutAction)
                *decodeMessageWithoutAction = true;
        }
        else if ([action isKindOfClass:[Secret66_DecryptedMessageAction_decryptedMessageActionResend class]])
        {
            Secret66_DecryptedMessageAction_decryptedMessageActionResend *concreteAction = action;
            return @{@"actionType": @"resendActions", @"fromSeq": concreteAction.startSeqNo, @"toSeq": concreteAction.endSeqNo};
        }
        else if ([action isKindOfClass:[Secret66_DecryptedMessageAction_decryptedMessageActionRequestKey class]])
        {
            Secret66_DecryptedMessageAction_decryptedMessageActionRequestKey *concreteAction = action;
            return @{@"actionType": @"requestKey", @"exchangeId": concreteAction.exchangeId, @"g_a": concreteAction.gA};
        }
        else if ([action isKindOfClass:[Secret66_DecryptedMessageAction_decryptedMessageActionAcceptKey class]])
        {
            Secret66_DecryptedMessageAction_decryptedMessageActionAcceptKey *concreteAction = action;
            return @{@"actionType": @"acceptKey", @"exchangeId": concreteAction.exchangeId, @"g_b": concreteAction.gB, @"key_fingerprint": concreteAction.keyFingerprint};
        }
        else if ([action isKindOfClass:[Secret66_DecryptedMessageAction_decryptedMessageActionCommitKey class]])
        {
            Secret66_DecryptedMessageAction_decryptedMessageActionCommitKey *concreteAction = action;
            return @{@"actionType": @"commitKey", @"exchangeId": concreteAction.exchangeId, @"key_fingerprint": concreteAction.keyFingerprint};
        }
        else if ([action isKindOfClass:[Secret66_DecryptedMessageAction_decryptedMessageActionAbortKey class]])
        {
            Secret66_DecryptedMessageAction_decryptedMessageActionAbortKey *concreteAction = action;
            return @{@"actionType": @"abortKey", @"exchangeId": concreteAction.exchangeId};
        }
    }

    return nil;
}

@end
