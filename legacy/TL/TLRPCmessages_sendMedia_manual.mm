#import "TLRPCmessages_sendMedia_manual.h"

#import "TL/TLMetaScheme.h"
#import "TLMetaClassStore.h"

//messages.sendMedia#b8d1262b flags:# silent:flags.5?true background:flags.6?true clear_draft:flags.7?true peer:InputPeer reply_to_msg_id:flags.0?int media:InputMedia message:string random_id:long reply_markup:flags.2?ReplyMarkup entities:flags.3?Vector<MessageEntity> = Updates;

@implementation TLRPCmessages_sendMedia_manual

- (int32_t)TLconstructorSignature
{
    return 0xb8d1262b;
}

- (int32_t)TLconstructorName
{
    return -1;
}

- (Class)responseClass
{
    return [TLUpdates class];
}

- (int)impliedResponseSignature
{
    return 0;
}

- (int)layerVersion
{
    return 26;
}

- (void)TLserialize:(NSOutputStream *)os
{
    [os writeInt32:_flags];
    
    TLMetaClassStore::serializeObject(os, _peer, true);
    
    if (_flags & (1 << 0))
        [os writeInt32:_reply_to_msg_id];
    
    TLMetaClassStore::serializeObject(os, _media, true);
    
    [os writeString:_message];
    [os writeInt64:_random_id];
    
    if (_flags & (1 << 3)) {
        int32_t vectorSignature = TL_UNIVERSAL_VECTOR_CONSTRUCTOR;
        [os writeInt32:vectorSignature];
        [os writeInt32:(int32_t)self.entities.count];
        for (TLMessageEntity *entity in self.entities) {
            TLMetaClassStore::serializeObject(os, entity, true);
        }
    }
}

- (id<TLObject>)TLdeserialize:(NSInputStream *)__unused is signature:(int32_t)__unused signature environment:(id<TLSerializationEnvironment>)__unused environment context:(TLSerializationContext *)__unused context error:(__autoreleasing NSError **)__unused error
{
    TGLog(@"***** TLRPCmessages_sendMedia_manual deserialization not supported");
    return nil;
}

@end
