#import "TGMessageSearchSignals.h"

#import "TGTelegramNetworking.h"
#import "TL/TLMetaScheme.h"
#import "TGTelegraph.h"

#import "TGMessage+Telegraph.h"
#import "TGUserDataRequestBuilder.h"

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
            return [[TLMessagesFilter$inputMessagesFilterAudio alloc] init];
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

@end
