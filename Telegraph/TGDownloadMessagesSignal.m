#import "TGDownloadMessagesSignal.h"

#import "TGTelegramNetworking.h"
#import "TL/TLMetaScheme.h"

#import "TGUserDataRequestBuilder.h"

#import "TGMessage+Telegraph.h"

#import "TGPeerIdAdapter.h"

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
    
    return [[SSignal combineSignals:@[genericSignal, channelSignal]] map:^id(NSArray *messageLists) {
        NSMutableArray *messages = [[NSMutableArray alloc] init];
        for (NSArray *array in messageLists) {
            [messages addObjectsFromArray:array];
        }
        return messages;
    }];
}

@end
