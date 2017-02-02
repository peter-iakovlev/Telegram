#import "TLRPCmessages_editMessage.h"

#import "TL/TLMetaScheme.h"
#import "TLMetaClassStore.h"

//messages.editMessage flags:# no_webpage:flags.1?true peer:InputPeer id:int message:string entities:flags.3?Vector<MessageEntity> reply_markup:flags.2?ReplyMarkup = Updates

//messages.editMessage flags:# no_webpage:flags.1?true peer:InputPeer id:int message:flags.11?string reply_markup:flags.2?ReplyMarkup entities:flags.3?Vector<MessageEntity> = Updates;

@implementation TLRPCmessages_editMessage

- (int32_t)TLconstructorSignature
{
    return 0xce91e4ca;
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
    return 48;
}

- (void)setNo_webpage:(bool)no_webpage {
    if (no_webpage) {
        _flags |= 1 << 1;
    } else {
        _flags &= ~(1 << 1);
    }
}

- (bool)no_webpage {
    return _flags & (1 << 1);
}

- (void)TLserialize:(NSOutputStream *)os
{
    int32_t realFlags = _flags | (1 << 11);
    [os writeInt32:realFlags];
    
    TLMetaClassStore::serializeObject(os, _peer, true);
    
    [os writeInt32:_n_id];
    
    if (realFlags & (1 << 11)) {
        [os writeString:_message];
    }
    
    if (realFlags & (1 << 3)) {
        int32_t vectorSignature = TL_UNIVERSAL_VECTOR_CONSTRUCTOR;
        [os writeInt32:vectorSignature];
        
        [os writeInt32:(int32_t)_entities.count];
        for (TLMessageEntity *entity in _entities) {
            TLMetaClassStore::serializeObject(os, entity, true);
        }
    }
}

- (id<TLObject>)TLdeserialize:(NSInputStream *)__unused is signature:(int32_t)__unused signature environment:(id<TLSerializationEnvironment>)__unused environment context:(TLSerializationContext *)__unused context error:(__autoreleasing NSError **)__unused error
{
    TGLog(@"***** TLRPCmessages_sendContextBotResult deserialization not supported");
    return nil;
}

@end
