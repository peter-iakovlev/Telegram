#import "TGSendMessageSignals.h"

#import "TGTelegraph.h"
#import "TGTelegramNetworking.h"
#import "TGDatabase.h"
#import "ActionStage.h"

#import "TGStickersSignals.h"

#import "TL/TLMetaScheme.h"

#import "TLRPCmessages_sendMessage_manual.h"
#import "TLRPCmessages_sendMedia_manual.h"

#import "TLUpdates+TG.h"
#import "TGMessage+Telegraph.h"
#import "TLMessage$modernMessage.h"
#import "TLMessage$modernMessageService.h"
#import "TLUpdates$updateShortSentMessage.h"

#import "TGPeerIdAdapter.h"

@implementation TGSendMessageSignals

+ (SSignal *)sendTextMessageWithPeerId:(int64_t)peerId text:(NSString *)text replyToMid:(int32_t)replyToMid
{
    SSignal *accessHashSignal = TGPeerIdIsChannel(peerId) ? [[[TGDatabaseInstance() existingChannel:peerId] take:1] map:^NSNumber *(TGConversation *channel)
    {
        return @(channel.accessHash);
    }] : [SSignal single:nil];
    
    SSignal *addToDatabaseSignal = [self _addMessageToDatabaseWithPeerId:peerId replyToMid:replyToMid text:text attachment:nil];
    
    SSignal *(^sendMessage)(TGMessage *, int64_t) = ^SSignal *(TGMessage *message, int64_t accessHash)
    {
        TLRPCmessages_sendMessage_manual *sendMessage = [[TLRPCmessages_sendMessage_manual alloc] init];
        sendMessage.peer = [TGTelegraphInstance createInputPeerForConversation:peerId accessHash:accessHash];
        sendMessage.message = message.text;
        sendMessage.random_id = message.randomId;
        sendMessage.reply_to_msg_id = replyToMid;
        sendMessage.flags |= replyToMid != 0 ? (1 << 0) : 0;
        
        return [[SSignal single:message] then:[[[[[TGTelegramNetworking instance] requestSignal:sendMessage] mapToSignal:^SSignal *(TLUpdates *updates)
        {
            TLMessage *updateMessage = updates.messages.firstObject;
            
            if ([updates isKindOfClass:[TLUpdates$updateShortSentMessage class]])
            {
                TLUpdates$updateShortSentMessage *sentMessage = (TLUpdates$updateShortSentMessage *)updates;
                
                std::vector<TGDatabaseMessageFlagValue> flags;
                flags.push_back((TGDatabaseMessageFlagValue){.flag = TGDatabaseMessageFlagDeliveryState, .value = TGMessageDeliveryStateDelivered});
                flags.push_back((TGDatabaseMessageFlagValue){.flag = TGDatabaseMessageFlagMid, .value = sentMessage.n_id});
                flags.push_back((TGDatabaseMessageFlagValue){.flag = TGDatabaseMessageFlagDate, .value = sentMessage.date});
                
                TGMessage *updatedMessage = [message copy];
                updatedMessage.mid = sentMessage.n_id;
                updatedMessage.deliveryState = TGMessageDeliveryStateDelivered;
                updatedMessage.date = sentMessage.date;
                if ([sentMessage.media isKindOfClass:[TLMessageMedia$messageMediaWebPage class]])
                {
                    NSMutableArray *attachments = [[NSMutableArray alloc] initWithArray:updatedMessage.mediaAttachments];
                    for (id attachment in attachments)
                    {
                        if ([attachment isKindOfClass:[TGWebPageMediaAttachment class]])
                        {
                            [attachments removeObject:attachment];
                            break;
                        }
                    }
                    [attachments addObjectsFromArray:[TGMessage parseTelegraphMedia:sentMessage.media]];
                    updatedMessage.mediaAttachments = attachments;
                }
                
                [TGDatabaseInstance() updateMessage:message.mid peerId:0 flags:flags media:updatedMessage.mediaAttachments dispatch:true];
                
                [TGDatabaseInstance() removeTempIds:@[@(message.randomId)]];
                
                [[TGTelegramNetworking instance] updatePts:sentMessage.pts ptsCount:sentMessage.pts_count seq:0];
                
                id resource = [[SGraphObjectNode alloc] initWithObject:[[NSArray alloc] initWithObjects:[[NSNumber alloc] initWithInt:message.mid], updatedMessage, nil]];
                [ActionStageInstance() dispatchResource:[[NSString alloc] initWithFormat:@"/tg/conversation/(%lld)/messagesChanged", (long long)peerId] resource:resource];
                
                return [SSignal single:updatedMessage];
            }
            else if (updateMessage != nil)
            {
                int32_t date = 0;
                if ([updateMessage isKindOfClass:[TLMessage$modernMessage class]])
                    date = ((TLMessage$message *)updateMessage).date;
                else if ([updateMessage isKindOfClass:[TLMessage$modernMessageService class]])
                    date = ((TLMessage$modernMessageService *)updateMessage).date;
                
                std::vector<TGDatabaseMessageFlagValue> flags;
                flags.push_back((TGDatabaseMessageFlagValue){.flag = TGDatabaseMessageFlagDeliveryState, .value = TGMessageDeliveryStateDelivered});
                flags.push_back((TGDatabaseMessageFlagValue){.flag = TGDatabaseMessageFlagMid, .value = updateMessage.n_id});
                flags.push_back((TGDatabaseMessageFlagValue){.flag = TGDatabaseMessageFlagDate, .value = date});
                
                TGMessage *updatedMessage = [[TGMessage alloc] initWithTelegraphMessageDesc:updateMessage];
                
                [TGDatabaseInstance() updateMessage:message.mid peerId:0 flags:flags media:updatedMessage.mediaAttachments dispatch:true];
                
                [TGDatabaseInstance() removeTempIds:@[@(message.randomId)]];
                
                id resource = [[SGraphObjectNode alloc] initWithObject:[[NSArray alloc] initWithObjects:[[NSNumber alloc] initWithInt:message.mid], updatedMessage, nil]];
                [ActionStageInstance() dispatchResource:[[NSString alloc] initWithFormat:@"/tg/conversation/(%lld)/messagesChanged", (long long)peerId] resource:resource];
                
                [[TGTelegramNetworking instance] addUpdates:updates];
                
                return [SSignal single:updatedMessage];
            }
            else
                return [SSignal fail:nil];
        }] take:1] catch:^SSignal *(__unused id error)
        {
            TGMessage *updatedMessage = [message copy];
            updatedMessage.deliveryState = TGMessageDeliveryStateFailed;
            return [SSignal single:updatedMessage];
        }]];
    };
    
    return [addToDatabaseSignal mapToSignal:^SSignal *(TGMessage *message)
    {
        return [accessHashSignal mapToSignal:^SSignal *(NSNumber *accessHash)
        {
            return sendMessage(message, accessHash.int64Value);
        }];
    }];
}
+ (SSignal *)_addMessageToDatabaseWithPeerId:(int64_t)peerId replyToMid:(int32_t)replyToMid text:(NSString *)text attachment:(TGMediaAttachment *)attachment
{
    return [[SSignal alloc] initWithGenerator:^id<SDisposable>(SSubscriber *subscriber)
    {
        TGMessage *message = [[TGMessage alloc] init];
        
        message.outgoing = true;
        message.unread = true;
        message.fromUid = TGTelegraphInstance.clientUserId;
        message.toUid = peerId;
        message.deliveryState = TGMessageDeliveryStatePending;
        
        int64_t randomId = 0;
        arc4random_buf(&randomId, 8);
        message.randomId = randomId;

        if (text != nil)
            message.text = text;
        
        NSMutableArray *attachments = [[NSMutableArray alloc] init];
        TGMessage *replyMessage = nil;
        if (replyToMid != 0)
            replyMessage = [TGDatabaseInstance() loadMessageWithMid:replyToMid peerId:peerId];
        
        if (replyMessage != nil)
        {
            TGReplyMessageMediaAttachment *replyMedia = [[TGReplyMessageMediaAttachment alloc] init];
            replyMedia.replyMessageId = replyMessage.mid;
            replyMedia.replyMessage = replyMessage;
            [attachments addObject:replyMedia];
        }
        
        if (attachment != nil)
            [attachments addObject:attachment];
        
        message.mediaAttachments = attachments;
        
        message.mid = [[[TGDatabaseInstance() generateLocalMids:1] firstObject] intValue];
        message.date = (int)[[TGTelegramNetworking instance] approximateRemoteTime];
        
        [TGDatabaseInstance() addMessagesToConversation:@[message] conversationId:peerId updateConversation:nil dispatch:true countUnread:false];
        
        [ActionStageInstance() dispatchResource:[[NSString alloc] initWithFormat:@"/tg/conversation/(%lld)/messages", (long long)peerId] resource:[[SGraphObjectNode alloc] initWithObject:@[message]]];
        
        [subscriber putNext:message];
        [subscriber putCompletion];
        
        return nil;
    }];
}

+ (SSignal *)_sendMediaWithMessage:(TGMessage *)message replyToMid:(int32_t)replyToMid mediaProducer:(TLInputMedia *(^)(void))mediaProducer
{
    int64_t peerId = message.toUid;
    SSignal *accessHashSignal = TGPeerIdIsChannel(peerId) ? [[[TGDatabaseInstance() existingChannel:peerId] take:1] map:^NSNumber *(TGConversation *channel)
    {
        return @(channel.accessHash);
    }] : [SSignal single:nil];
    
    return [accessHashSignal mapToSignal:^SSignal *(NSNumber *accessHash)
    {
        TLRPCmessages_sendMedia_manual *sendMedia = [[TLRPCmessages_sendMedia_manual alloc] init];
        sendMedia.peer = [TGTelegraphInstance createInputPeerForConversation:message.toUid accessHash:accessHash.int64Value];
        sendMedia.media = mediaProducer();
        sendMedia.random_id = message.randomId;
        sendMedia.reply_to_msg_id = replyToMid;
        sendMedia.flags |= replyToMid != 0 ? (1 << 0) : 0;
        if (TGPeerIdIsChannel(message.toUid)) {
            
        }
        
        return [[SSignal single:message] then:[[[[[TGTelegramNetworking instance] requestSignal:sendMedia] mapToSignal:^SSignal *(TLUpdates *updates)
        {
            TLMessage *updateMessage = updates.messages.firstObject;
            
            if (updateMessage != nil)
            {
                int32_t date = 0;
                if ([updateMessage isKindOfClass:[TLMessage$modernMessage class]])
                    date = ((TLMessage$message *)updateMessage).date;
                else if ([updateMessage isKindOfClass:[TLMessage$modernMessageService class]])
                    date = ((TLMessage$modernMessageService *)updateMessage).date;
                
                std::vector<TGDatabaseMessageFlagValue> flags;
                flags.push_back((TGDatabaseMessageFlagValue){.flag = TGDatabaseMessageFlagDeliveryState, .value = TGMessageDeliveryStateDelivered});
                flags.push_back((TGDatabaseMessageFlagValue){.flag = TGDatabaseMessageFlagMid, .value = updateMessage.n_id});
                flags.push_back((TGDatabaseMessageFlagValue){.flag = TGDatabaseMessageFlagDate, .value = date});
                
                TGMessage *updatedMessage = [[TGMessage alloc] initWithTelegraphMessageDesc:updateMessage];
                
                [TGDatabaseInstance() updateMessage:message.mid peerId:0 flags:flags media:updatedMessage.mediaAttachments dispatch:true];
                
                [TGDatabaseInstance() removeTempIds:@[@(message.randomId)]];
                
                id resource = [[SGraphObjectNode alloc] initWithObject:[[NSArray alloc] initWithObjects:[[NSNumber alloc] initWithInt:message.mid], updatedMessage, nil]];
                [ActionStageInstance() dispatchResource:[[NSString alloc] initWithFormat:@"/tg/conversation/(%lld)/messagesChanged", (long long)message.toUid] resource:resource];
                
                [[TGTelegramNetworking instance] addUpdates:updates];
                
                return [SSignal single:updatedMessage];
            }
            else
                return [SSignal fail:nil];
        }] take:1] catch:^SSignal *(__unused id error)
        {
            TGMessage *updatedMessage = [message copy];
            updatedMessage.deliveryState = TGMessageDeliveryStateFailed;
            return [SSignal single:updatedMessage];
        }]];
    }];
}

+ (SSignal *)_sendMediaWithPeerId:(int64_t)peerId replyToMid:(int32_t)replyToMid attachment:(TGMediaAttachment *)attachment mediaProducer:(TLInputMedia *(^)(void))mediaProducer
{
    return [[self _addMessageToDatabaseWithPeerId:peerId replyToMid:replyToMid text:nil attachment:attachment] mapToSignal:^SSignal *(TGMessage *message)
    {
        return [self _sendMediaWithMessage:message replyToMid:replyToMid mediaProducer:mediaProducer];
    }];
}

+ (SSignal *)sendLocationWithPeerId:(int64_t)peerId replyToMid:(int32_t)replyToMid locationAttachment:(TGLocationMediaAttachment *)locationAttachment
{
    return [self _sendMediaWithPeerId:peerId replyToMid:replyToMid attachment:locationAttachment mediaProducer:^TLInputMedia *
    {
        TLInputGeoPoint$inputGeoPoint *geoPoint = [[TLInputGeoPoint$inputGeoPoint alloc] init];
        geoPoint.lat = locationAttachment.latitude;
        geoPoint.n_long = locationAttachment.longitude;

        TLInputMedia *media = nil;
        
        if (locationAttachment.venue != nil)
        {
            TGVenueAttachment *venue = locationAttachment.venue;
            
            TLInputMedia$inputMediaVenue *inputVenue = [[TLInputMedia$inputMediaVenue alloc] init];
            inputVenue.geo_point = geoPoint;
            inputVenue.title = venue.title;
            inputVenue.address = venue.address;
            inputVenue.provider = venue.provider;
            inputVenue.venue_id = venue.venueId;
            media = inputVenue;
        }
        else
        {
            TLInputMedia$inputMediaGeoPoint *inputGeoPoint = [[TLInputMedia$inputMediaGeoPoint alloc] init];
            inputGeoPoint.geo_point = geoPoint;
            media = inputGeoPoint;
        }
        
        return media;
    }];
}

+ (SSignal *)sendRemoteDocumentWithPeerId:(int64_t)peerId replyToMid:(int32_t)replyToMid documentAttachment:(TGDocumentMediaAttachment *)documentAttachment
{
    bool isSticker = false;
    for (id attribute in documentAttachment.attributes)
    {
        if ([attribute isKindOfClass:[TGDocumentAttributeSticker class]])
        {
            isSticker = true;
            break;
        }
    }

    if (isSticker)
    {
        [[SQueue concurrentDefaultQueue] dispatch:^{
            [TGStickersSignals addUseCountForDocumentId:documentAttachment.documentId];
        }];
    }
    
    return [self _sendMediaWithPeerId:peerId replyToMid:replyToMid attachment:documentAttachment mediaProducer:^TLInputMedia *
    {
        TLInputMedia$inputMediaDocument *remoteDocument = [[TLInputMedia$inputMediaDocument alloc] init];
        
        TLInputDocument$inputDocument *inputDocument = [[TLInputDocument$inputDocument alloc] init];
        inputDocument.n_id = documentAttachment.documentId;
        inputDocument.access_hash = documentAttachment.accessHash;
        remoteDocument.n_id = inputDocument;
        
        return remoteDocument;
    }];
}

+ (SSignal *)forwardMessageWithMid:(int32_t)mid peerId:(int64_t)peerId
{
    SSignal *addToDatabaseSignal = [[SSignal alloc] initWithGenerator:^id<SDisposable>(SSubscriber *subscriber)
    {
        TGMessage *forwardedMessage = [TGDatabaseInstance() loadMessageWithMid:mid peerId:peerId];
        int32_t forwardMid = forwardedMessage.mid;
        bool keepForwarded = true;
        
        NSMutableArray *attachments = [[NSMutableArray alloc] init];
        for (TGMediaAttachment *attachment in forwardedMessage.mediaAttachments)
        {
            if ([attachment isKindOfClass:[TGForwardedMessageMediaAttachment class]])
            {
                TGForwardedMessageMediaAttachment *forwardedMessageAttachment = (TGForwardedMessageMediaAttachment *)attachment;
                forwardedMessage.fromUid = forwardedMessageAttachment.forwardPeerId;
                forwardedMessage.date = forwardedMessageAttachment.forwardDate;
                if (forwardedMessageAttachment.forwardMid != 0)
                    forwardMid = forwardedMessageAttachment.forwardMid;
            }
            else if (![attachment isKindOfClass:[TGReplyMessageMediaAttachment class]])
            {
                [attachments addObject:attachment];
            }
        }
        
        TGForwardedMessageMediaAttachment *forwardAttachment = nil;
        if (keepForwarded)
        {
            forwardAttachment = [[TGForwardedMessageMediaAttachment alloc] init];
            forwardAttachment.forwardPeerId = (int32_t)forwardedMessage.fromUid;
            forwardAttachment.forwardDate = (int32_t)forwardedMessage.date;
            forwardAttachment.forwardMid = forwardMid;
        }
        
        if (forwardAttachment != nil)
            [attachments addObject:forwardAttachment];
        
        TGMessage *message = [forwardedMessage copy];
        if (message.contentProperties != nil)
        {
            NSMutableDictionary *contentProperties = [[NSMutableDictionary alloc] initWithDictionary:message.contentProperties];
            [contentProperties removeObjectForKey:@"contentsRead"];
            message.contentProperties = contentProperties;
        }
        
        message.outgoing = true;
        message.unread = true;
        message.fromUid = TGTelegraphInstance.clientUserId;
        message.toUid = peerId;
        message.deliveryState = TGMessageDeliveryStatePending;
        int64_t randomId = 0;
        arc4random_buf(&randomId, 8);
        message.randomId = randomId;
        
        message.mediaAttachments = attachments;
        
        message.mid = [[[TGDatabaseInstance() generateLocalMids:1] firstObject] intValue];
        message.date = (int)[[TGTelegramNetworking instance] approximateRemoteTime];
        
        [TGDatabaseInstance() addMessagesToConversation:@[message] conversationId:peerId updateConversation:nil dispatch:true countUnread:false];
        
        [ActionStageInstance() dispatchResource:[[NSString alloc] initWithFormat:@"/tg/conversation/(%lld)/messages", (long long)peerId] resource:[[SGraphObjectNode alloc] initWithObject:@[message]]];
        
        [subscriber putNext:message];
        [subscriber putCompletion];
        
        return nil;
    }];
    
    SSignal *(^sendMessage)(TGMessage *) = ^SSignal *(TGMessage *message)
    {
        TLRPCmessages_forwardMessages$messages_forwardMessages *forwardMessages = [[TLRPCmessages_forwardMessages$messages_forwardMessages alloc] init];
        forwardMessages.to_peer = [TGTelegraphInstance createInputPeerForConversation:peerId accessHash:0];
        forwardMessages.from_peer = [[TLInputPeer$inputPeerEmpty alloc] init];
        forwardMessages.n_id = @[@(mid)];
        forwardMessages.random_id = @[@(message.randomId)];
        
        return [[SSignal single:message] then:[[[[[TGTelegramNetworking instance] requestSignal:forwardMessages] mapToSignal:^SSignal *(TLUpdates *updates)
        {
            TLMessage *updateMessage = updates.messages.firstObject;
            
            if (updateMessage != nil)
            {
                int32_t date = 0;
                if ([updateMessage isKindOfClass:[TLMessage$modernMessage class]])
                    date = ((TLMessage$message *)updateMessage).date;
                else if ([updateMessage isKindOfClass:[TLMessage$modernMessageService class]])
                    date = ((TLMessage$modernMessageService *)updateMessage).date;
                
                std::vector<TGDatabaseMessageFlagValue> flags;
                flags.push_back((TGDatabaseMessageFlagValue){.flag = TGDatabaseMessageFlagDeliveryState, .value = TGMessageDeliveryStateDelivered});
                flags.push_back((TGDatabaseMessageFlagValue){.flag = TGDatabaseMessageFlagMid, .value = updateMessage.n_id});
                flags.push_back((TGDatabaseMessageFlagValue){.flag = TGDatabaseMessageFlagDate, .value = date});
                
                TGMessage *updatedMessage = [[TGMessage alloc] initWithTelegraphMessageDesc:updateMessage];
                
                [TGDatabaseInstance() updateMessage:message.mid peerId:0 flags:flags media:updatedMessage.mediaAttachments dispatch:true];
                
                [TGDatabaseInstance() removeTempIds:@[@(message.randomId)]];
                
                id resource = [[SGraphObjectNode alloc] initWithObject:[[NSArray alloc] initWithObjects:[[NSNumber alloc] initWithInt:message.mid], updatedMessage, nil]];
                [ActionStageInstance() dispatchResource:[[NSString alloc] initWithFormat:@"/tg/conversation/(%lld)/messagesChanged", (long long)peerId] resource:resource];
                
                [[TGTelegramNetworking instance] addUpdates:updates];
                
                return [SSignal single:updatedMessage];
            }
            else
                return [SSignal fail:nil];
        }] take:1] catch:^SSignal *(__unused id error)
        {
            TGMessage *updatedMessage = [message copy];
            updatedMessage.deliveryState = TGMessageDeliveryStateFailed;
            return [SSignal single:updatedMessage];
        }]];
    };
    
    return [addToDatabaseSignal mapToSignal:^SSignal *(TGMessage *message)
    {
        return sendMessage(message);
    }];
}

+ (SSignal *)forwardMessageWithMessageIds:(NSArray *)messageIds peerId:(int64_t)peerId accessHash:(int64_t)accessHash fromPeerId:(int64_t)fromPeerId fromPeerAccessHash:(int64_t)fromPeerAccessHash
{
    SSignal *(^sendMessage)() = ^SSignal *()
    {
        TLRPCmessages_forwardMessages$messages_forwardMessages *forwardMessages = [[TLRPCmessages_forwardMessages$messages_forwardMessages alloc] init];
        forwardMessages.to_peer = [TGTelegraphInstance createInputPeerForConversation:peerId accessHash:accessHash];
        forwardMessages.from_peer = [TGTelegraphInstance createInputPeerForConversation:fromPeerId accessHash:fromPeerAccessHash];
        if (TGPeerIdIsChannel(peerId)) {
            TGConversation *conversation = [TGDatabaseInstance() loadConversationWithId:peerId];
            if (conversation.isChannelGroup) {
                
            } else {
                forwardMessages.flags |= 16;
            }
        }
        
        NSMutableArray *randomIds = [[NSMutableArray alloc] init];
        for (NSUInteger i = 0; i < messageIds.count; i++) {
            int64_t randomId = 0;
            arc4random_buf(&randomId, 8);
            [randomIds addObject:@(randomId)];
        }
        
        forwardMessages.n_id = messageIds;
        forwardMessages.random_id = randomIds;
        
        return [[[[[TGTelegramNetworking instance] requestSignal:forwardMessages] mapToSignal:^SSignal *(TLUpdates *updates)
        {
            [[TGTelegramNetworking instance] addUpdates:updates];
            
            /*TLMessage *updateMessage = updates.messages.firstObject;
            
            if (updateMessage != nil)
            {
                int32_t date = 0;
                if ([updateMessage isKindOfClass:[TLMessage$modernMessage class]])
                    date = ((TLMessage$message *)updateMessage).date;
                else if ([updateMessage isKindOfClass:[TLMessage$modernMessageService class]])
                    date = ((TLMessage$modernMessageService *)updateMessage).date;
                
                std::vector<TGDatabaseMessageFlagValue> flags;
                flags.push_back((TGDatabaseMessageFlagValue){.flag = TGDatabaseMessageFlagDeliveryState, .value = TGMessageDeliveryStateDelivered});
                flags.push_back((TGDatabaseMessageFlagValue){.flag = TGDatabaseMessageFlagMid, .value = updateMessage.n_id});
                flags.push_back((TGDatabaseMessageFlagValue){.flag = TGDatabaseMessageFlagDate, .value = date});
                
                TGMessage *updatedMessage = [[TGMessage alloc] initWithTelegraphMessageDesc:updateMessage];
                
                [TGDatabaseInstance() updateMessage:message.mid peerId:0 flags:flags media:updatedMessage.mediaAttachments dispatch:true];
                
                [TGDatabaseInstance() removeTempIds:@[@(message.randomId)]];
                
                id resource = [[SGraphObjectNode alloc] initWithObject:[[NSArray alloc] initWithObjects:[[NSNumber alloc] initWithInt:message.mid], updatedMessage, nil]];
                [ActionStageInstance() dispatchResource:[[NSString alloc] initWithFormat:@"/tg/conversation/(%lld)/messagesChanged", (long long)peerId] resource:resource];
                
                [[TGTelegramNetworking instance] addUpdates:updates];
                
                return [SSignal single:updatedMessage];
            }
            else
                return [SSignal fail:nil];*/
            return [SSignal complete];
        }] take:1] catch:^SSignal *(__unused id error)
        {
            return [SSignal fail:nil];
        }];
    };
    
    return sendMessage();
}

+ (SSignal *)forwardMessagesWithMessageIds:(NSArray *)messageIds toPeerIds:(NSArray *)peerIds fromPeerId:(int64_t)fromPeerId fromPeerAccessHash:(int64_t)fromPeerAccessHash {
    NSMutableArray *signals = [[NSMutableArray alloc] init];
    
    for (NSNumber *nPeerId in peerIds) {
        int64_t accessHash = 0;
        if (TGPeerIdIsChannel([nPeerId longLongValue])) {
            accessHash = ((TGConversation *)[TGDatabaseInstance() loadChannels:@[nPeerId]][nPeerId]).accessHash;
        }
        SSignal *signal = [self forwardMessageWithMessageIds:messageIds peerId:[nPeerId longLongValue] accessHash:accessHash fromPeerId:fromPeerId fromPeerAccessHash:fromPeerAccessHash];
        [signals addObject:signal];
    }
    
    return [SSignal combineSignals:signals];
}

+ (SSignal *)broadcastMessageWithText:(NSString *)text toPeerIds:(NSArray *)peerIds {
    NSMutableArray *signals = [[NSMutableArray alloc] init];
    
    for (NSNumber *nPeerId in peerIds) {
        SSignal *signal = [[self sendTextMessageWithPeerId:[nPeerId longLongValue] text:text replyToMid:0] catch:^SSignal *(__unused id error) {
            return [SSignal complete];
        }];
        [signals addObject:signal];
    }
    
    return [SSignal combineSignals:signals];
}

@end
