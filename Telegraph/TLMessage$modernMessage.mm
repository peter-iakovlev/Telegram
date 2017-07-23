#import "TLMessage$modernMessage.h"

#import "TLMetaClassStore.h"

//message flags:# out:flags.1?true mentioned:flags.4?true media_unread:flags.5?true silent:flags.13?true post:flags.14?true id:int from_id:flags.8?int to_id:Peer fwd_from:flags.2?MessageFwdHeader via_bot_id:flags.11?int reply_to_msg_id:flags.3?int date:int message:string media:flags.9?MessageMedia reply_markup:flags.6?ReplyMarkup entities:flags.7?Vector<MessageEntity> views:flags.10?int edit_date:flags.15?int post_author:flags.16?string = Message;

@implementation TLMessage$modernMessage

- (void)TLserialize:(NSOutputStream *)__unused os
{
    TGLog(@"***** TLMessage$modernMessage serialization not supported");
}

- (id<TLObject>)TLdeserialize:(NSInputStream *)is signature:(int32_t)__unused signature environment:(id<TLSerializationEnvironment>)environment context:(TLSerializationContext *)__unused context error:(__autoreleasing NSError **)error
{
    TLMessage$modernMessage *result = [[TLMessage$modernMessage alloc] init];
    
    int32_t flags = [is readInt32];
    
    result.flags = flags;
    result.n_id = [is readInt32];
    
    if (flags & (1 << 8))
    {
        result.from_id = [is readInt32];
    }
    
    int32_t peerSignature = [is readInt32];
    result.to_id = TLMetaClassStore::constructObject(is, peerSignature, environment, nil, error);
    if (error != nil && *error != nil) {
        return nil;
    }
    
    if (flags & (1 << 2))
    {
        int32_t signature = [is readInt32];
        result.fwd_from = TLMetaClassStore::constructObject(is, signature, environment, nil, error);
        if (error != nil && *error != nil) {
            return nil;
        }
    }
    
    if (flags & (1 << 11))
    {
        result.via_bot_id = [is readInt32];
    }
    
    if (flags & (1 << 3))
    {
        result.reply_to_msg_id = [is readInt32];
    }
    
    result.date = [is readInt32];
    
    result.message = [is readString];
    
    if (flags & (1 << 9))
    {
        int32_t mediaSignature = [is readInt32];
        result.media = TLMetaClassStore::constructObject(is, mediaSignature, environment, nil, error);
        if (error != nil && *error != nil) {
            return nil;
        }
    }
    
    if (flags & (1 << 6))
    {
        int32_t replyMarkupSignature = [is readInt32];
        result.reply_markup = TLMetaClassStore::constructObject(is, replyMarkupSignature, environment, nil, error);
        if (error != nil && *error != nil) {
            return nil;
        }
    }
    
    if (flags & (1 << 7))
    {
        __unused int32_t entitiesSignature = [is readInt32];
        int32_t count = [is readInt32];
        NSMutableArray *entities = [[NSMutableArray alloc] init];
        for (int32_t i = 0; i < count; i++)
        {
            int32_t signature = [is readInt32];
            id entity = TLMetaClassStore::constructObject(is, signature, environment, nil, error);
            if (error != nil && *error != nil) {
                return nil;
            }
            if (entity != nil)
                [entities addObject:entity];
        }
        result.entities = entities;
    }
    
    if (flags & (1 << 10)) {
        result.views = [is readInt32];
    }
    
    if (flags & (1 << 15)) {
        result.edit_date = [is readInt32];
    }
    
    if (flags & (1 << 16)) {
        result.post_author = [is readString];
    }
    
    return result;
}

@end
