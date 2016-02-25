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
    }
}

+ (SSignal *)searchPeer:(int64_t)peer accessHash:(int64_t)accessHash query:(NSString *)query filter:(TGMessageSearchFilter)filter maxMessageId:(int32_t)maxMessageId limit:(NSUInteger)limit
{
    TLRPCmessages_search$messages_search *search = [[TLRPCmessages_search$messages_search alloc] init];
    search.peer = [TGTelegraphInstance createInputPeerForConversation:peer accessHash:accessHash];
    search.q = query == nil ? @"" : query;
    search.filter = [self nativeFilterForFilter:filter];
    search.min_date = 0;
    search.max_date = 0;
    search.offset = 0;
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
        
        [TGDatabaseInstance() cacheMediaForPeerId:peer messages:messages];
        if (messages.count == 0)
        {
            if ([self cacheItemTypeForFilter:filter] != TGSharedMediaCacheItemTypeLink)
            {
                [TGDatabaseInstance() setSharedMediaIndexDownloadedForPeerId:peer itemType:[self cacheItemTypeForFilter:filter]];
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
            return [NSString stringWithFormat:@"https://telegram.me/%@/%d", conversation.username, messageId];
        }];
    } else {
        return [[[TGTelegramNetworking instance] requestSignal:exportMessageLink] map:^id(TLExportedMessageLink *result) {
            return result.link;
        }];
    }
}

@end
