#import "TGDownloadMessagesSignal.h"

#import <LegacyComponents/LegacyComponents.h>

#import "TGTelegramNetworking.h"
#import "TL/TLMetaScheme.h"

#import "TGUserDataRequestBuilder.h"

#import "TGMessage+Telegraph.h"

#import "TGStickersSignals.h"

#import "TGTelegraph.h"
#import "TGDatabase.h"

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

+ (SSignal *)loadUnseenMentionMessageId:(int64_t)peerId accessHash:(int64_t)accessHash maxId:(int32_t)maxId {
    TLRPCmessages_getUnreadMentions$messages_getUnreadMentions *getUnreadMentions = [[TLRPCmessages_getUnreadMentions$messages_getUnreadMentions alloc] init];
    int32_t limit = 100;
    getUnreadMentions.peer = [TGTelegraphInstance createInputPeerForConversation:peerId accessHash:accessHash];
    getUnreadMentions.offset_id = maxId;
    getUnreadMentions.add_offset = -limit;
    getUnreadMentions.limit = limit;
    getUnreadMentions.max_id = INT32_MAX;
    getUnreadMentions.min_id = maxId - 1;
    
    return [[[TGTelegramNetworking instance] requestSignal:getUnreadMentions] mapToSignal:^SSignal *(TLmessages_Messages *result) {
        return [TGDatabaseInstance() modify:^id{
            NSMutableArray *messageIds = [[NSMutableArray alloc] init];
            NSMutableArray *messageUpdates = [[NSMutableArray alloc] init];
            for (TLMessage *message in result.messages) {
                [messageIds addObject:@(message.n_id)];
                [messageUpdates addObject:[[TGDatabaseUpdateMentionUnread alloc] initWithPeerId:peerId messageId:message.n_id]];
            }
            [TGDatabaseInstance() _addUnreadMensionMessageIds:peerId messageIds:messageIds replaceAfter:maxId <= 1 ? 1 : 0 afterFinal:(int32_t)messageIds.count < limit];
            [TGDatabaseInstance() transactionUpdateMessages:messageUpdates updateConversationDatas:nil];
            
            return messageIds.firstObject;
        }];
    }];
}

+ (SSignal *)earliestUnseenMentionMessageId:(int64_t)peerId accessHash:(int64_t)accessHash {
    return [[TGDatabaseInstance() modify:^id{
        int32_t loadRequiredAfterMessageId = 0;
        int32_t localId = [TGDatabaseInstance() _nextUnreadMentionMessageId:peerId loadRequiredAfterMessageId:&loadRequiredAfterMessageId];
        
        if (localId != 0) {
            [TGDatabaseInstance() transactionUpdateMessages:@[[[TGDatabaseUpdateMentionUnread alloc] initWithPeerId:peerId messageId:localId]] updateConversationDatas:nil];
            
            return [SSignal single:@(localId)];
        } else if (loadRequiredAfterMessageId != 0) {
            return [self loadUnseenMentionMessageId:peerId accessHash:accessHash maxId:loadRequiredAfterMessageId];
        } else {
            [TGDatabaseInstance() _addUnreadMensionMessageIds:peerId messageIds:@[] replaceAfter:1 afterFinal:true];
            return [SSignal single:nil];
        }
    }] switchToLatest];
}

static dispatch_block_t recursiveBlock(void (^block)(dispatch_block_t recurse))
{
    return ^
    {
        block(recursiveBlock(block));
    };
}

+ (SSignal *)clearUnseenMentions:(int64_t)peerId {
    SSignal *clear = [[SSignal alloc] initWithGenerator:^id<SDisposable>(SSubscriber *subscriber) {
        SMetaDisposable *disposable = [[SMetaDisposable alloc] init];
        void (^start)() = recursiveBlock(^(dispatch_block_t recurse) {
            TLRPCmessages_readMentions$messages_readMentions *readMentions = [[TLRPCmessages_readMentions$messages_readMentions alloc] init];
            int64_t accessHash = 0;
            if (TGPeerIdIsChannel(peerId)) {
                accessHash = ((TGConversation *)[TGDatabaseInstance() loadChannels:@[@(peerId)]][@(peerId)]).accessHash;
            }
            readMentions.peer = [TGTelegraphInstance createInputPeerForConversation:peerId accessHash:accessHash];
            [disposable setDisposable:[[[TGTelegramNetworking instance] requestSignal:readMentions] startWithNext:^(TLmessages_AffectedHistory *result) {
                if (result != nil) {
                    if (!TGPeerIdIsChannel(peerId)) {
                        [[TGTelegramNetworking instance] updatePts:result.pts ptsCount:result.pts_count seq:0];
                    }
                }
                
                if (result.offset > 0) {
                    recurse();
                } else {
                    [subscriber putCompletion];
                }
            } error:^(__unused id error) {
                [subscriber putCompletion];
            } completed:nil]];
        });
        
        start();
        
        return [[SBlockDisposable alloc] initWithBlock:^{
            [disposable dispose];
        }];
    }];
    
    return [clear then:[[TGDatabaseInstance() modify:^id{
        NSMutableDictionary<NSNumber *, TGUnseenPeerMentionsState *> *resetPeerUnseenMentionsStates = [[NSMutableDictionary alloc] init];
        resetPeerUnseenMentionsStates[@(peerId)] = [[TGUnseenPeerMentionsState alloc] initWithVersion:0 count:0 maxIdWithPrecalculatedCount:0];
        [TGDatabaseInstance() transactionResetPeerUnseenMentionsStates:resetPeerUnseenMentionsStates];
        return [SSignal complete];
    }] switchToLatest]];
}

@end
