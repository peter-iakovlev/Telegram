#import "TGMessageSearchSignals.h"

#import "TGTelegramNetworking.h"
#import "TL/TLMetaScheme.h"
#import "TGTelegraph.h"

#import "TGMessage+Telegraph.h"
#import "TGUserDataRequestBuilder.h"

#import "TGPeerIdAdapter.h"

@implementation TGMessageSearchSignals

+ (TLMessagesFilter *)nativeFilterForFilter:(TGMessageSearchFilter)filter
{
    switch (filter)
    {
        case TGMessageSearchFilterAny:
            return [[TLMessagesFilter$inputMessagesFilterEmpty alloc] init];
        case TGMessageSearchFilterPhoto:
            return [[TLMessagesFilter$inputMessagesFilterPhotos alloc] init];
        case TGMessageSearchFilterPhotoVideo:
            return [[TLMessagesFilter$inputMessagesFilterPhotoVideo alloc] init];
        case TGMessageSearchFilterVideo:
            return [[TLMessagesFilter$inputMessagesFilterVideo alloc] init];
        case TGMessageSearchFilterFile:
            return [[TLMessagesFilter$inputMessagesFilterDocument alloc] init];
        case TGMessageSearchFilterAudio:
            return [[TLMessagesFilter$inputMessagesFilterMusic alloc] init];
        case TGMessageSearchFilterPhotoVideoFile:
            return [[TLMessagesFilter$inputMessagesFilterPhotoVideoDocuments alloc] init];
        case TGMessageSearchFilterLink:
            return [[TLMessagesFilter$inputMessagesFilterUrl alloc] init];
        case TGMessageSearchFilterGroupPhotos:
            return [[TLMessagesFilter$inputMessagesFilterChatPhotos alloc] init];
        case TGMessageSearchFilterPhoneCalls:
            return [[TLMessagesFilter$inputMessagesFilterPhoneCalls alloc] init];
        case TGMessageSearchFilterVoiceRound:
            return [[TLMessagesFilter$inputMessagesFilterRoundVideo alloc] init];
    }
}

+ (TGSharedMediaCacheItemType)cacheItemTypeForFilter:(TGMessageSearchFilter)filter
{
    switch (filter)
    {
        case TGMessageSearchFilterAny:
            return TGSharedMediaCacheItemTypePhotoVideoFile;
        case TGMessageSearchFilterPhoto:
            return TGSharedMediaCacheItemTypePhoto;
        case TGMessageSearchFilterPhotoVideo:
            return TGSharedMediaCacheItemTypePhotoVideo;
        case TGMessageSearchFilterVideo:
            return TGSharedMediaCacheItemTypeVideo;
        case TGMessageSearchFilterFile:
            return TGSharedMediaCacheItemTypeFile;
        case TGMessageSearchFilterAudio:
            return TGSharedMediaCacheItemTypeAudio;
        case TGMessageSearchFilterPhotoVideoFile:
            return TGSharedMediaCacheItemTypePhotoVideoFile;
        case TGMessageSearchFilterLink:
            return TGSharedMediaCacheItemTypeLink;
        case TGMessageSearchFilterGroupPhotos:
            return TGSharedMediaCacheItemTypeNone;
        case TGMessageSearchFilterPhoneCalls:
            return TGSharedMediaCacheItemTypeNone;
        case TGMessageSearchFilterVoiceRound:
            return TGSharedMediaCacheItemTypeVoiceVideoMessage;
    }
}

+ (SSignal *)searchPeer:(int64_t)peer accessHash:(int64_t)accessHash query:(NSString *)query filter:(TGMessageSearchFilter)filter maxMessageId:(int32_t)maxMessageId limit:(NSUInteger)limit {
    return [self searchPeer:peer accessHash:accessHash query:query filter:filter maxMessageId:maxMessageId limit:limit around:false];
}

+ (SSignal *)searchPeer:(int64_t)peer accessHash:(int64_t)accessHash query:(NSString *)query filter:(TGMessageSearchFilter)filter maxMessageId:(int32_t)maxMessageId limit:(NSUInteger)limit around:(bool)around
{
    TLRPCmessages_search$messages_search *search = [[TLRPCmessages_search$messages_search alloc] init];
    search.peer = [TGTelegraphInstance createInputPeerForConversation:peer accessHash:accessHash];
    search.q = query == nil ? @"" : query;
    search.filter = [self nativeFilterForFilter:filter];
    search.min_date = 0;
    search.max_date = 0;
    if (around) {
        search.offset = ((int32_t)(limit)) / -2;
    } else {
        search.offset = 0;
    }
    search.max_id = maxMessageId;
    search.limit = (int32_t)limit;
    
    return [[[TGTelegramNetworking instance] requestSignal:search] map:^id (TLmessages_Messages *result)
    {
        [TGUserDataRequestBuilder executeUserDataUpdate:result.users];
        
        NSMutableArray *messages = [[NSMutableArray alloc] init];
        for (TLMessage *messageDesc in result.messages)
        {
            TGMessage *message = [[TGMessage alloc] initWithTelegraphMessageDesc:messageDesc];
            if (message.mid != 0)
            {
                bool isSticker = false;
                
                for (id attachment in message.mediaAttachments)
                {
                    if ([attachment isKindOfClass:[TGDocumentMediaAttachment class]])
                    {
                        for (id attribute in ((TGDocumentMediaAttachment *)attachment).attributes)
                        {
                            if ([attribute isKindOfClass:[TGDocumentAttributeSticker class]])
                            {
                                isSticker = true;
                                break;
                            }
                        }
                    }
                }
                
                if (!isSticker)
                    [messages addObject:message];
            }
        }
        
        if ([self cacheItemTypeForFilter:filter] != TGSharedMediaCacheItemTypeNone) {
            [TGDatabaseInstance() cacheMediaForPeerId:peer messages:messages];
            if (messages.count == 0)
            {
                if ([self cacheItemTypeForFilter:filter] != TGSharedMediaCacheItemTypeLink)
                {
                    [TGDatabaseInstance() setSharedMediaIndexDownloadedForPeerId:peer itemType:[self cacheItemTypeForFilter:filter]];
                }
            }
        }
        
        return messages;
    }];
}

+ (SSignal *)shareLinkForChannelMessage:(int64_t)peerId accessHash:(int64_t)accessHash messageId:(int32_t)messageId {
    TLRPCchannels_exportMessageLink$channels_exportMessageLink *exportMessageLink = [[TLRPCchannels_exportMessageLink$channels_exportMessageLink alloc] init];
    TLInputChannel$inputChannel *inputChannel = [[TLInputChannel$inputChannel alloc] init];
    inputChannel.channel_id = TGChannelIdFromPeerId(peerId);
    inputChannel.access_hash = accessHash;
    exportMessageLink.channel = inputChannel;
    
    exportMessageLink.n_id = messageId;
    
    if (false) {
        return [[[TGDatabaseInstance() existingChannel:peerId] take:1] map:^id(TGConversation *conversation) {
            return [NSString stringWithFormat:@"https://t.me/%@/%d", conversation.username, messageId];
        }];
    } else {
        return [[[TGTelegramNetworking instance] requestSignal:exportMessageLink] map:^id(TLExportedMessageLink *result) {
            return result.link;
        }];
    }
}

+ (TLInputPeer *)inputPeerWithPeerId:(int64_t)peerId {
    if (TGPeerIdIsUser(peerId)) {
        TGUser *user = [TGDatabaseInstance() loadUser:(int32_t)peerId];
        if (user != nil) {
            TLInputPeer$inputPeerUser *inputPeerUser = [[TLInputPeer$inputPeerUser alloc] init];
            inputPeerUser.user_id = user.uid;
            inputPeerUser.access_hash = user.phoneNumberHash;
            return inputPeerUser;
        }
    } else {
        TGConversation *conversation = [TGDatabaseInstance() loadConversationWithId:peerId];
        if (conversation != nil) {
            if (TGPeerIdIsChannel(peerId)) {
                TLInputPeer$inputPeerChannel *inputPeerChannel = [[TLInputPeer$inputPeerChannel alloc] init];
                inputPeerChannel.channel_id = TGChannelIdFromPeerId(peerId);
                inputPeerChannel.access_hash = conversation.accessHash;
                return inputPeerChannel;
            } else{
                TLInputPeer$inputPeerChat *inputPeerChat = [[TLInputPeer$inputPeerChat alloc] init];
                inputPeerChat.chat_id = TGGroupIdFromPeerId(peerId);
                return inputPeerChat;
            }
        }
    }
    return nil;
}

+ (SSignal *)messageIdForPeerId:(int64_t)peerId date:(int32_t)date {
    return [[TGDatabaseInstance() modify:^id{
        return [self inputPeerWithPeerId:peerId];
    }] mapToSignal:^SSignal *(TLInputPeer *inputPeer) {
        if (inputPeer == nil) {
            return [SSignal fail:nil];
        } else {
            TLRPCmessages_getHistory$messages_getHistory *getHistory = [[TLRPCmessages_getHistory$messages_getHistory alloc] init];
            getHistory.peer = inputPeer;
            getHistory.offset_date = date;
            getHistory.limit = 1;
            getHistory.add_offset = -1;
            return [[[TGTelegramNetworking instance] requestSignal:getHistory] mapToSignal:^SSignal *(TLmessages_Messages *result) {
                for (TLMessage *desc in result.messages) {
                    TGMessage *message = [[TGMessage alloc] initWithTelegraphMessageDesc:desc];
                    if (message.mid != 0) {
                        return [SSignal single:@(message.mid)];
                    }
                }
                return [SSignal fail:nil];
            }];
        }
    }];
}

@end
