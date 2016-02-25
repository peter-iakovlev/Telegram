#import "TLRPCmessages_sendInlineBotResult.h"

#import "TL/TLMetaScheme.h"
#import "TLMetaClassStore.h"

//messages.sendContextBotResult flags:# broadcast:flags.4?true peer:InputPeer reply_to_msg_id:flags.0?int random_id:long query_id:long id:string = Updates;

@implementation TLRPCmessages_sendInlineBotResult

- (int32_t)TLconstructorSignature
{
    return 0xB16E06FE;
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
    return 45;
}

- (void)TLserialize:(NSOutputStream *)os
{
    [os writeInt32:_flags];
    
    TLMetaClassStore::serializeObject(os, _peer, true);
    
    if (_flags & (1 << 0))
        [os writeInt32:_reply_to_msg_id];
    
    [os writeInt64:_random_id];
    [os writeInt64:_query_id];
    
    [os writeString:_n_id];
}

- (id<TLObject>)TLdeserialize:(NSInputStream *)__unused is signature:(int32_t)__unused signature environment:(id<TLSerializationEnvironment>)__unused environment context:(TLSerializationContext *)__unused context error:(__autoreleasing NSError **)__unused error
{
    TGLog(@"***** TLRPCmessages_sendContextBotResult deserialization not supported");
    return nil;
}

@end
