#import "TGSendMessageSignals.h"

#import "TGTelegraph.h"
#import "TGTelegramNetworking.h"
#import "TGDatabase.h"
#import "ActionStage.h"

#import "TGStickersSignals.h"

#import "TL/TLMetaScheme.h"

#import "TGModernSendCommonMessageActor.h"

#import "TLRPCmessages_sendMessage_manual.h"
#import "TLRPCmessages_sendMedia_manual.h"

#import "TLUpdates+TG.h"
#import "TGMessage+Telegraph.h"
#import "TLMessage$modernMessage.h"
#import "TLMessage$modernMessageService.h"
#import "TLUpdates$updateShortSentMessage.h"

#import "TGPeerIdAdapter.h"

NSString *const TGAccessHashKey = @"accessHash";
NSString *const TGChannelGroupKey = @"channelGroup";

@implementation TGSendMessageSignals

+ (SSignal *)sendTextMessageWithPeerId:(int64_t)peerId text:(NSString *)text  replyToMid:(int32_t)replyToMid
{
    return [self sendTextMessageWithPeerId:peerId text:text entities:nil replyToMid:replyToMid];
}

+ (SSignal *)sendTextMessageWithPeerId:(int64_t)peerId text:(NSString *)text entities:(NSArray *)entities replyToMid:(int32_t)replyToMid
{
    SSignal *(^sendMessage)(TGMessage *, int64_t, bool) = ^SSignal *(TGMessage *message, int64_t accessHash, bool isChannelGroup)
    {
        TLRPCmessages_sendMessage_manual *sendMessage = [[TLRPCmessages_sendMessage_manual alloc] init];
        sendMessage.peer = [TGTelegraphInstance createInputPeerForConversation:peerId accessHash:accessHash];
        sendMessage.message = message.text;
        sendMessage.random_id = message.randomId;
        sendMessage.reply_to_msg_id = replyToMid;
        
        int32_t flags = 0;
        if (replyToMid != 0)
            flags |= (1 << 0);
        if (TGPeerIdIsChannel(peerId) && !isChannelGroup)
            flags |= 16;
        
        if (entities.count > 0) {
            sendMessage.entities = [TGModernSendCommonMessageActor convertEntities:entities];
            flags |= (1 << 3);
        }
        
        sendMessage.flags = flags;
        
        return [[SSignal single:message] then:[[[[[TGTelegramNetworking instance] requestSignal:sendMessage] mapToSignal:^SSignal *(TLUpdates *updates)
        {
            TLMessage *updateMessage = updates.messages.firstObject;
            
            if ([updates isKindOfClass:[TLUpdates$updateShortSentMessage class]])
            {
                TLUpdates$updateShortSentMessage *sentMessage = (TLUpdates$updateShortSentMessage *)updates;
                
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
                    [attachments addObjectsFromArray:[TGMessage parseTelegraphMedia:sentMessage.media mediaLifetime:nil]];
                    updatedMessage.mediaAttachments = attachments;
                }
                
                [TGDatabaseInstance() removeTempIds:@[@(message.randomId)]];
                
                TGDatabaseUpdateMessageWithMessage *messageUpdate = [[TGDatabaseUpdateMessageWithMessage alloc] initWithPeerId:0 messageId:message.mid message:updatedMessage dispatchEdited:false];
                [TGDatabaseInstance() transactionUpdateMessages:@[messageUpdate] updateConversationDatas:nil];
                
                [[TGTelegramNetworking instance] updatePts:sentMessage.pts ptsCount:sentMessage.pts_count seq:0];
                
                id resource = [[SGraphObjectNode alloc] initWithObject:[[NSArray alloc] initWithObjects:[[NSNumber alloc] initWithInt:message.mid], updatedMessage, nil]];
                [ActionStageInstance() dispatchResource:[[NSString alloc] initWithFormat:@"/tg/conversation/(%lld)/messagesChanged", (long long)peerId] resource:resource];
                
                return [SSignal single:updatedMessage];
            }
            else if (updateMessage != nil)
            {
                TGMessage *updatedMessage = [[TGMessage alloc] initWithTelegraphMessageDesc:updateMessage];
                
                TGDatabaseUpdateMessageWithMessage *messageUpdate = [[TGDatabaseUpdateMessageWithMessage alloc] initWithPeerId:0 messageId:message.mid message:updatedMessage dispatchEdited:false];
                [TGDatabaseInstance() transactionUpdateMessages:@[messageUpdate] updateConversationDatas:nil];
                
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
    
    return [[self _channelInfoSignalForPeerId:peerId] mapToSignal:^SSignal *(NSDictionary *info)
    {
        return [[self _addMessageToDatabaseWithPeerId:peerId replyToMid:replyToMid text:text entities:entities attachment:nil isChannelGroup:[info[TGChannelGroupKey] boolValue]] mapToSignal:^SSignal *(TGMessage *message)
        {
            return sendMessage(message, [info[TGAccessHashKey] int64Value], [info[TGChannelGroupKey] boolValue]);
        }];
    }];
}

+ (SSignal *)_channelInfoSignalForPeerId:(int64_t)peerId
{
    return TGPeerIdIsChannel(peerId) ? [[[TGDatabaseInstance() existingChannel:peerId] take:1] map:^NSDictionary *(TGConversation *channel)
    {
        return @{ TGAccessHashKey: @(channel.accessHash), TGChannelGroupKey: @(channel.isChannelGroup) };
    }] : [SSignal single:nil];
}

+ (SSignal *)_addMessageToDatabaseWithPeerId:(int64_t)peerId replyToMid:(int32_t)replyToMid text:(NSString *)text entities:(NSArray *)entities attachment:(TGMediaAttachment *)attachment isChannelGroup:(bool)isChannelGroup
{
    return [[SSignal alloc] initWithGenerator:^id<SDisposable>(SSubscriber *subscriber)
    {
        TGMessage *message = [[TGMessage alloc] init];
        
        message.cid = peerId;
        message.outgoing = true;
        message.fromUid = TGTelegraphInstance.clientUserId;
        message.toUid = peerId;
        message.deliveryState = TGMessageDeliveryStatePending;
        message.entities = entities;
        
        int64_t randomId = 0;
        arc4random_buf(&randomId, 8);
        message.randomId = randomId;

        if (text != nil)
            message.text = text;
        
        if (isChannelGroup)
            message.sortKey = TGMessageSortKeyMake(peerId, TGMessageSpaceUnimportant, (int32_t)message.date, message.mid);
        
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
        
        [TGDatabaseInstance() transactionAddMessages:@[message] updateConversationDatas:nil notifyAdded:true];
        
        [ActionStageInstance() dispatchResource:[[NSString alloc] initWithFormat:@"/tg/conversation/(%lld)/messages", (long long)peerId] resource:[[SGraphObjectNode alloc] initWithObject:@[message]]];
        
        [subscriber putNext:message];
        [subscriber putCompletion];
        
        return nil;
    }];
}

+ (SSignal *)_sendMediaWithMessage:(TGMessage *)message accessHash:(int64_t)accessHash isChannelGroup:(bool)isChannelGroup replyToMid:(int32_t)replyToMid uploadInfo:(NSDictionary *)uploadInfo mediaProducer:(TLInputMedia *(^)(NSDictionary *uploadInfo))mediaProducer
{
    int64_t peerId = message.toUid;
    
    TLRPCmessages_sendMedia_manual *sendMedia = [[TLRPCmessages_sendMedia_manual alloc] init];
    sendMedia.peer = [TGTelegraphInstance createInputPeerForConversation:message.toUid accessHash:accessHash];
    sendMedia.media = mediaProducer(uploadInfo);
    sendMedia.random_id = message.randomId;
    sendMedia.reply_to_msg_id = replyToMid;
    
    int32_t flags = 0;
    if (replyToMid != 0)
        flags |= (1 << 0);
    if (TGPeerIdIsChannel(peerId) && !isChannelGroup)
        flags |= 16;
    
    sendMedia.flags = flags;
    
    return [[SSignal single:message] then:[[[[[TGTelegramNetworking instance] requestSignal:sendMedia] mapToSignal:^SSignal *(TLUpdates *updates)
    {
        TLMessage *updateMessage = updates.messages.firstObject;
        
        if (updateMessage != nil)
        {
            TGMessage *updatedMessage = [[TGMessage alloc] initWithTelegraphMessageDesc:updateMessage];
            
            TGDatabaseUpdateMessageWithMessage *messageUpdate = [[TGDatabaseUpdateMessageWithMessage alloc] initWithPeerId:0 messageId:message.mid message:updatedMessage dispatchEdited:false];
            [TGDatabaseInstance() transactionUpdateMessages:@[messageUpdate] updateConversationDatas:nil];
            
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
}

+ (SSignal *)commitSendMediaWithMessage:(TGMessage *)message mediaProducer:(TLInputMedia *(^)(NSDictionary *))mediaProducer
{
    return [[self _channelInfoSignalForPeerId:message.cid] mapToSignal:^SSignal *(NSDictionary *info)
    {
        int64_t accessHash = [info[TGAccessHashKey] int64Value];
        bool channelGroup = [info[TGChannelGroupKey] boolValue];
        
        return [self _sendMediaWithMessage:message accessHash:accessHash isChannelGroup:channelGroup replyToMid:0 uploadInfo:nil mediaProducer:mediaProducer];
    }];
}

+ (SSignal *)sendMediaWithPeerId:(int64_t)peerId replyToMid:(int32_t)replyToMid attachment:(TGMediaAttachment *)attachment uploadSignal:(SSignal *)uploadSignal mediaProducer:(TLInputMedia *(^)(NSDictionary *uploadInfo))mediaProducer
{
    return [[self _channelInfoSignalForPeerId:peerId] mapToSignal:^SSignal *(NSDictionary *info)
    {
        int64_t accessHash = [info[TGAccessHashKey] int64Value];
        bool channelGroup = [info[TGChannelGroupKey] boolValue];
        
        return [[self _addMessageToDatabaseWithPeerId:peerId replyToMid:replyToMid text:nil entities:nil attachment:attachment isChannelGroup:channelGroup] mapToSignal:^SSignal *(TGMessage *message)
        {
            SSignal *(^sendSignal)(NSDictionary *) = ^SSignal *(NSDictionary *uploadInfo)
            {
                return [self _sendMediaWithMessage:message accessHash:accessHash isChannelGroup:channelGroup replyToMid:replyToMid uploadInfo:uploadInfo mediaProducer:mediaProducer];
            };
            
            if (uploadSignal != nil)
            {
                return [uploadSignal mapToSignal:^SSignal *(NSDictionary *uploadInfo)
                {
                    return sendSignal(uploadInfo);
                }];
            }
            
            return sendSignal(nil);
        }];
    }];
}

+ (SSignal *)sendLocationWithPeerId:(int64_t)peerId replyToMid:(int32_t)replyToMid locationAttachment:(TGLocationMediaAttachment *)locationAttachment
{
    return [self sendMediaWithPeerId:peerId replyToMid:replyToMid attachment:locationAttachment uploadSignal:nil mediaProducer:^TLInputMedia *(__unused NSDictionary *uploadInfo)
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
    
    return [self sendMediaWithPeerId:peerId replyToMid:replyToMid attachment:documentAttachment uploadSignal:nil mediaProducer:^TLInputMedia *(__unused NSDictionary *uploadInfo)
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
        message.fromUid = TGTelegraphInstance.clientUserId;
        message.toUid = peerId;
        message.deliveryState = TGMessageDeliveryStatePending;
        int64_t randomId = 0;
        arc4random_buf(&randomId, 8);
        message.randomId = randomId;
        
        message.mediaAttachments = attachments;
        
        message.mid = [[[TGDatabaseInstance() generateLocalMids:1] firstObject] intValue];
        message.date = (int)[[TGTelegramNetworking instance] approximateRemoteTime];
        
        [TGDatabaseInstance() transactionAddMessages:@[message] updateConversationDatas:nil notifyAdded:true];
        
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
                TGMessage *updatedMessage = [[TGMessage alloc] initWithTelegraphMessageDesc:updateMessage];
                
                TGDatabaseUpdateMessageWithMessage *messageUpdate = [[TGDatabaseUpdateMessageWithMessage alloc] initWithPeerId:0 messageId:message.mid message:updatedMessage dispatchEdited:false];
                [TGDatabaseInstance() transactionUpdateMessages:@[messageUpdate] updateConversationDatas:nil];
                
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


@implementation TGShareSignals

+ (SSignal *)shareText:(NSString *)text toPeerIds:(NSArray *)peerIds caption:(NSString *)caption
{
    return [self shareText:text entities:nil toPeerIds:peerIds caption:caption];
}

+ (SSignal *)shareText:(NSString *)text entities:(NSArray *)entities toPeerIds:(NSArray *)peerIds caption:(NSString *)caption
{
    NSMutableArray *signals = [[NSMutableArray alloc] init];
    
    for (NSNumber *peerIdVal in peerIds)
    {
        int64_t peerId = peerIdVal.int64Value;
        SSignal *signal = [TGSendMessageSignals sendTextMessageWithPeerId:peerId text:text entities:entities replyToMid:0];
        if (caption.length > 0)
            signal = [[TGSendMessageSignals sendTextMessageWithPeerId:peerId text:caption replyToMid:0] then:signal];
        
        [signals addObject:signal];
    }
    
    return [SSignal combineSignals:signals];
}

+ (SSignal *)sharePhoto:(TGImageMediaAttachment *)photo toPeerIds:(NSArray *)peerIds caption:(NSString *)caption
{
    TLInputMedia$inputMediaPhoto *remotePhoto = [[TLInputMedia$inputMediaPhoto alloc] init];
    TLInputPhoto$inputPhoto *inputId = [[TLInputPhoto$inputPhoto alloc] init];
    inputId.n_id = photo.imageId;
    inputId.access_hash = photo.accessHash;
    remotePhoto.n_id = inputId;
    
    TGImageMediaAttachment *attachment = [photo copy];
    attachment.caption = nil;
    
    return [self _shareMedia:remotePhoto attachment:attachment toPeerIds:peerIds caption:caption];
}

+ (SSignal *)shareVideo:(TGVideoMediaAttachment *)video toPeerIds:(NSArray *)peerIds caption:(NSString *)caption
{
    TLInputMedia$inputMediaDocument *remoteDocument = [[TLInputMedia$inputMediaDocument alloc] init];
    TLInputDocument$inputDocument *inputDocument = [[TLInputDocument$inputDocument alloc] init];
    inputDocument.n_id = video.videoId;
    inputDocument.access_hash = video.accessHash;
    remoteDocument.n_id = inputDocument;
    
    TGVideoMediaAttachment *attachment = [video copy];
    attachment.caption = nil;
    
    return [self _shareMedia:remoteDocument attachment:attachment toPeerIds:peerIds caption:caption];
}

+ (SSignal *)shareContact:(TGContactMediaAttachment *)contact toPeerIds:(NSArray *)peerIds caption:(NSString *)caption
{
    TLInputMedia$inputMediaContact *inputContact = [[TLInputMedia$inputMediaContact alloc] init];
    inputContact.first_name = contact.firstName;
    inputContact.last_name = contact.lastName;
    inputContact.phone_number = contact.phoneNumber;
 
    return [self _shareMedia:inputContact attachment:contact toPeerIds:peerIds caption:caption];
}

+ (SSignal *)shareLocation:(TGLocationMediaAttachment *)location toPeerIds:(NSArray *)peerIds caption:(NSString *)caption
{
    TLInputGeoPoint$inputGeoPoint *geoPoint = [[TLInputGeoPoint$inputGeoPoint alloc] init];
    geoPoint.lat = location.latitude;
    geoPoint.n_long = location.longitude;
    
    TLInputMedia *inputLocation = nil;
    
    if (location.venue != nil)
    {
        TGVenueAttachment *venue = location.venue;
        
        TLInputMedia$inputMediaVenue *inputVenue = [[TLInputMedia$inputMediaVenue alloc] init];
        inputVenue.geo_point = geoPoint;
        inputVenue.title = venue.title;
        inputVenue.address = venue.address;
        inputVenue.provider = venue.provider;
        inputVenue.venue_id = venue.venueId;
        inputLocation = inputVenue;
    }
    else
    {
        TLInputMedia$inputMediaGeoPoint *inputGeoPoint = [[TLInputMedia$inputMediaGeoPoint alloc] init];
        inputGeoPoint.geo_point = geoPoint;
        inputLocation = inputGeoPoint;
    }

    return [self _shareMedia:inputLocation attachment:location toPeerIds:peerIds caption:caption];
}

+ (SSignal *)shareDocument:(TGDocumentMediaAttachment *)document toPeerIds:(NSArray *)peerIds caption:(NSString *)caption
{
    TLInputMedia$inputMediaDocument *remoteDocument = [[TLInputMedia$inputMediaDocument alloc] init];
    TLInputDocument$inputDocument *inputDocument = [[TLInputDocument$inputDocument alloc] init];
    inputDocument.n_id = document.documentId;
    inputDocument.access_hash = document.accessHash;
    remoteDocument.n_id = inputDocument;
    
    TGDocumentMediaAttachment *attachment = [document copy];
    attachment.caption = nil;
    
    return [self _shareMedia:remoteDocument attachment:attachment toPeerIds:peerIds caption:caption];
}

+ (SSignal *)_shareMedia:(TLInputMedia *)media attachment:(TGMediaAttachment *)attachment toPeerIds:(NSArray *)peerIds caption:(NSString *)caption
{
    NSMutableArray *signals = [[NSMutableArray alloc] init];
    
    TLInputMedia *(^mediaProducer)(__unused NSDictionary *) = ^(__unused NSDictionary *uploadInfo)
    {
        return media;
    };
    
    for (NSNumber *peerIdVal in peerIds)
    {
        int64_t peerId = peerIdVal.int64Value;
        SSignal *signal = [TGSendMessageSignals sendMediaWithPeerId:peerId replyToMid:0 attachment:attachment uploadSignal:nil mediaProducer:mediaProducer];
        if (caption.length > 0)
            signal = [[TGSendMessageSignals sendTextMessageWithPeerId:peerId text:caption replyToMid:0] then:signal];
        
        [signals addObject:signal];
    }
    
    return [SSignal combineSignals:signals];
}
@end
