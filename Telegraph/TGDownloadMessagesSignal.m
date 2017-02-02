#import "TGDownloadMessagesSignal.h"

#import "TGTelegramNetworking.h"
#import "TL/TLMetaScheme.h"

#import "TGUserDataRequestBuilder.h"

#import "TGMessage+Telegraph.h"

#import "TGPeerIdAdapter.h"

#import "TGStickersSignals.h"

@implementation TGDownloadMessage

- (instancetype)initWithPeerId:(int64_t)peerId accessHash:(int64_t)accessHash messageId:(int32_t)messageId {
    self = [super init];
    if (self != nil) {
        _peerId = peerId;
        _accessHash = accessHash;
        _messageId = messageId;
    }
    return self;
}

@end

@implementation TGDownloadMessagesSignal

+ (SSignal *)downloadMessages:(NSArray *)messages
{
    if (messages.count == 0) {
        return [SSignal single:messages];
    }
    
    SSignal *channelSignal = [SSignal single:@[]];
    SSignal *genericSignal = [SSignal single:@[]];
    
    NSMutableDictionary *channelMessageIdsByPeerId = [[NSMutableDictionary alloc] init];
    NSMutableArray *genericMessageIds = [[NSMutableArray alloc] init];
    for (TGDownloadMessage *message in messages) {
        if (TGPeerIdIsChannel(message.peerId)) {
            NSMutableArray *channelMessageIds = channelMessageIdsByPeerId[@(message.peerId)];
            if (channelMessageIds == nil) {
                channelMessageIds = [[NSMutableArray alloc] init];
                channelMessageIdsByPeerId[@(message.peerId)] = channelMessageIds;
            }
            [channelMessageIds addObject:message];
        } else {
            [genericMessageIds addObject:@(message.messageId)];
        }
    }
    
    if (channelMessageIdsByPeerId.count != 0) {
        NSMutableArray *signals = [[NSMutableArray alloc] init];
        
        [channelMessageIdsByPeerId enumerateKeysAndObjectsUsingBlock:^(__unused id key, NSArray *messages, __unused BOOL *stop) {
            if (messages.count != 0) {
                TLRPCchannels_getMessages$channels_getMessages *getChannelMessages = [[TLRPCchannels_getMessages$channels_getMessages alloc] init];
                TLInputChannel$inputChannel *inputChannel = [[TLInputChannel$inputChannel alloc] init];
                inputChannel.channel_id = TGChannelIdFromPeerId(((TGDownloadMessage *)messages[0]).peerId);
                inputChannel.access_hash = ((TGDownloadMessage *)messages[0]).accessHash;
                getChannelMessages.channel = inputChannel;
                
                NSMutableArray *messageIds = [[NSMutableArray alloc] init];
                for (TGDownloadMessage *message in messages) {
                    [messageIds addObject:@(message.messageId)];
                }
                
                getChannelMessages.n_id = messageIds;
                
                SSignal *signal = [[[TGTelegramNetworking instance] requestSignal:getChannelMessages] map:^id(TLmessages_Messages *result) {
                    [TGUserDataRequestBuilder executeUserDataUpdate:result.users];
                    
                    NSMutableArray *messages = [[NSMutableArray alloc] init];
                    for (TLMessage *desc in result.messages)
                    {
                        TGMessage *message = [[TGMessage alloc] initWithTelegraphMessageDesc:desc];
                        if (message.mid != 0)
                            [messages addObject:message];
                    }
                    
                    return messages;
                }];
                [signals addObject:signal];
            }
        }];
        
        channelSignal = [[SSignal combineSignals:signals] map:^id(NSArray *messageLists) {
            NSMutableArray *messages = [[NSMutableArray alloc] init];
            for (NSArray *array in messageLists) {
                [messages addObjectsFromArray:array];
            }
            return messages;
        }];
    }
    
    if (genericMessageIds.count != 0) {
        TLRPCmessages_getMessages$messages_getMessages *getMessages = [[TLRPCmessages_getMessages$messages_getMessages alloc] init];
        getMessages.n_id = genericMessageIds;
        genericSignal = [[[TGTelegramNetworking instance] requestSignal:getMessages] map:^id(TLmessages_Messages *result) {
            [TGUserDataRequestBuilder executeUserDataUpdate:result.users];
            
            NSMutableArray *messages = [[NSMutableArray alloc] init];
            for (TLMessage *desc in result.messages)
            {
                TGMessage *message = [[TGMessage alloc] initWithTelegraphMessageDesc:desc];
                if (message.mid != 0)
                    [messages addObject:message];
            }
            
            return messages;
        }];
    }
    
    return [[[SSignal combineSignals:@[genericSignal, channelSignal]] map:^id(NSArray *messageLists) {
        NSMutableArray *messages = [[NSMutableArray alloc] init];
        for (NSArray *array in messageLists) {
            [messages addObjectsFromArray:array];
        }
        return messages;
    }] catch:^SSignal *(__unused id error) {
        return [SSignal single:@[]];
    }];
}

+ (SSignal *)mediaStickerpacks:(TGMediaAttachment *)attachment {
    SSignal *request = nil;
    if ([attachment isKindOfClass:[TGImageMediaAttachment class]]) {
        TGImageMediaAttachment *image = (TGImageMediaAttachment *)attachment;
        TLRPCmessages_getAttachedStickers$messages_getAttachedStickers *getAttachedStickers = [[TLRPCmessages_getAttachedStickers$messages_getAttachedStickers alloc] init];
        TLInputStickeredMedia$inputStickeredMediaPhoto *inputStickeredPhoto = [[TLInputStickeredMedia$inputStickeredMediaPhoto alloc] init];
        TLInputPhoto$inputPhoto *inputPhoto = [[TLInputPhoto$inputPhoto alloc] init];
        inputPhoto.n_id = image.imageId;
        inputPhoto.access_hash = image.accessHash;
        inputStickeredPhoto.n_id = inputPhoto;
        getAttachedStickers.media = inputStickeredPhoto;
        request = [[TGTelegramNetworking instance] requestSignal:getAttachedStickers];
    } else if ([attachment isKindOfClass:[TGVideoMediaAttachment class]]) {
        TGVideoMediaAttachment *video = (TGVideoMediaAttachment *)attachment;
        TLRPCmessages_getAttachedStickers$messages_getAttachedStickers *getAttachedStickers = [[TLRPCmessages_getAttachedStickers$messages_getAttachedStickers alloc] init];
        TLInputStickeredMedia$inputStickeredMediaDocument *inputStickeredDocument = [[TLInputStickeredMedia$inputStickeredMediaDocument alloc] init];
        TLInputDocument$inputDocument *inputDocument = [[TLInputDocument$inputDocument alloc] init];
        inputDocument.n_id = video.videoId;
        inputDocument.access_hash = video.accessHash;
        inputStickeredDocument.n_id = inputDocument;
        getAttachedStickers.media = inputStickeredDocument;
        request = [[TGTelegramNetworking instance] requestSignal:getAttachedStickers];
    } else {
        return [SSignal single:@[]];
    }
    
    return [request mapToSignal:^SSignal *(NSArray<TLStickerSetCovered *> *result) {
        NSMutableArray *signals = [[NSMutableArray alloc] init];
        for (TLStickerSetCovered *coveredSet in result) {
            TGStickerPackIdReference *reference = [[TGStickerPackIdReference alloc] initWithPackId:coveredSet.set.n_id packAccessHash:coveredSet.set.access_hash shortName:coveredSet.set.short_name];
            [signals addObject:[TGStickersSignals stickerPackInfo:reference]];
        }
        return [SSignal combineSignals:signals];
    }];
}

@end
