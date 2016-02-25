#import "TLRPCchannels_editMessage.h"

#import "TL/TLMetaScheme.h"
#import "TLMetaClassStore.h"

//channels.editMessage flags:# no_webpage:flags.1?true channel:InputChannel id:int message:string entities:flags.3?Vector<MessageEntity> = Updates;

@implementation TLRPCchannels_editMessage

- (int32_t)TLconstructorSignature
{
    return 0xDCDA80ED;
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
    [os writeInt32:_flags];
    
    TLMetaClassStore::serializeObject(os, _channel, true);
    
    [os writeInt32:_n_id];
    [os writeString:_message];
    
    if (_flags & (1 << 3)) {
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
