#import "TGSecretIncomingQueueActor.h"

#import "ActionStage.h"
#import "SGraphObjectNode.h"

#import "TGDatabase.h"
#import "TGTelegraph.h"

#import "TGStoredSecretAction.h"

#import "TGMessage+Telegraph.h"

#import "TGConversationAddMessagesActor.h"

#import "TGModernSendSecretMessageActor.h"

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
    [TGDatabaseInstance() dequeuePeerIncomingActions:_peerId completion:^(NSArray *actions, int32_t blockNextExpectedSeqOut)
    {
        [ActionStageInstance() dispatchOnStageQueue:^
        {
            int32_t nextExpectedSeqOut = blockNextExpectedSeqOut;
            
            NSMutableArray *removeActionIds = [[NSMutableArray alloc] init];
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
            
            for (TGStoredSecretActionWithSeq *action in actions)
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
                            [removeActionIds addObject:@(action.actionId)];
                        else if ([self isResendAction:action.action])
                            [actionsToProcess addObject:action];
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
                            [removeActionIds addObject:@(action.actionId)];
                        else if ([self isResendAction:action.action])
                            [actionsToProcess addObject:action];
                    }
                    else
                        [actionsToProcess addObject:action];
                }
            }
            
            for (TGStoredSecretActionWithSeq *action in actionsToProcess)
            {
                if ([action.action isKindOfClass:[TGStoredIncomingMessageSecretAction class]])
                {
                    [self _processIncomingMessage:action.action seqIn:action.seqIn seqOut:action.seqOut addedMessages:addedMessages addedActions:addedActions layerUpdate:&layerUpdate];
                    [removeActionIds addObject:@(action.actionId)];
                }
            }
            
            int32_t resendSeqIn = 0;
            bool hasResendSeqIn = [TGDatabaseInstance() currentPeerResendSeqIn:_peerId seqIn:&resendSeqIn] && (resendSeqIn >= 0);
            
            if (removeActionIds.count < actions.count)
            {
                TGLog(@"Waiting for %d more messages to process in sequence", (int)(actions.count - actionsToProcess.count));
                
                if (!hasResendSeqIn)
                {
                    [TGDatabaseInstance() setCurrentPeerResendSeqIn:_peerId seqIn:nextExpectedSeqOut];
                    
                    int64_t randomId = 0;
                    arc4random_buf(&randomId, 8);
                    
                    if (minLocalSeqOut == INT32_MAX)
                        minLocalSeqOut = nextExpectedSeqOut + 1;
                    
                    bool isCreator = [TGDatabaseInstance() encryptedConversationIsCreator:_peerId];
                    int32_t fromSeq = nextExpectedSeqOut * 2 + (isCreator ? 0 : 1);
                    int32_t toSeq = (minLocalSeqOut - 1) * 2 + (isCreator ? 0 : 1);
                    
                    NSData *messageData = [TGModernSendSecretMessageActor decryptedServiceMessageActionWithLayer:MIN(currentPeerLayer, [TGModernSendSecretMessageActor currentLayer]) resendMessagesFromSeq:fromSeq toSeq:toSeq randomId:randomId];
                    
                    if (messageData != nil)
                    {
                        [TGModernSendSecretMessageActor enqueueOutgoingServiceMessageForPeerId:_peerId layer:MIN(currentPeerLayer, [TGModernSendSecretMessageActor currentLayer]) randomId:randomId messageData:messageData];
                    }
                }
            }
            else
                [TGDatabaseInstance() setCurrentPeerResendSeqIn:_peerId seqIn:-1];
            
            [TGDatabaseInstance() deletePeerIncomingActions:_peerId actionIds:removeActionIds];
            [TGDatabaseInstance() applyPeerSeqIn:_peerId seqIn:nextExpectedSeqOut];
            if (maxSeqIn > 0)
                [TGDatabaseInstance() confirmPeerSeqOut:_peerId seqOut:maxSeqIn - 1];
            
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
                    message.unread = false;
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
                
                static int messageActionId = 0;
                [[[TGConversationAddMessagesActor alloc] initWithPath:[NSString stringWithFormat:@"/tg/addmessage/(%dsecretIncoming)", messageActionId++]] execute:[NSDictionary dictionaryWithObjectsAndKeys:addedMessages, @"messages", nil]];
            }
            
            if (layerUpdate != 0 && layerUpdate > [TGDatabaseInstance() peerLayer:_peerId])
            {
                int64_t randomId = 0;
                arc4random_buf(&randomId, 8);

                NSUInteger peerLayer = [TGDatabaseInstance() peerLayer:_peerId];
                
                NSData *messageData = [TGModernSendSecretMessageActor decryptedServiceMessageActionWithLayer:MIN(peerLayer, [TGModernSendSecretMessageActor currentLayer]) notifyLayer:[TGModernSendSecretMessageActor currentLayer] randomId:randomId];
                
                if (messageData != nil)
                {
                    [TGModernSendSecretMessageActor enqueueOutgoingServiceMessageForPeerId:_peerId layer:MIN(peerLayer, [TGModernSendSecretMessageActor currentLayer]) randomId:randomId messageData:messageData];
                }
                
                [TGDatabaseInstance() setPeerLayer:_peerId layer:layerUpdate];
                
                [ActionStageInstance() dispatchResource:[[NSString alloc] initWithFormat:@"/tg/peerLayerUpdates/(%" PRId64 ")", _peerId] resource:@{@"layer": @(layerUpdate)}];
            }
            
            if (deleteMessageIds.count != 0)
            {
                NSMutableDictionary *messagesByConversation = [[NSMutableDictionary alloc] init];
                [TGDatabaseInstance() deleteMessages:deleteMessageIds populateActionQueue:false fillMessagesByConversationId:messagesByConversation];
                [messagesByConversation enumerateKeysAndObjectsUsingBlock:^(NSNumber *nConversationId, NSArray *messagesInConversation, __unused BOOL *stop)
                 {
                     [ActionStageInstance() dispatchResource:[[NSString alloc] initWithFormat:@"/tg/conversation/(%lld)/messagesDeleted", [nConversationId longLongValue]] resource:[[SGraphObjectNode alloc] initWithObject:messagesInConversation]];
                 }];
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
        }];
    }];
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
                     @"randomIds": concreteAction.random_ids == nil ? @[] : concreteAction.random_ids
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
                     @"randomIds": concreteAction.random_ids == nil ? @[] : concreteAction.random_ids
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
                     @"randomIds": concreteAction.random_ids
                     };
        }
        else if ([action isKindOfClass:[Secret17_DecryptedMessageAction_decryptedMessageActionScreenshotMessages class]])
        {
            Secret17_DecryptedMessageAction_decryptedMessageActionScreenshotMessages *concreteAction = action;
            return @{
                     @"peerId": @(conversationId),
                     @"actionType": @"screenshotMessages",
                     @"randomIds": concreteAction.random_ids,
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
            return @{@"actionType": @"resendActions", @"fromSeq": concreteAction.start_seq_no, @"toSeq": concreteAction.end_seq_no};
        }
    }
    
    return nil;
}

@end
