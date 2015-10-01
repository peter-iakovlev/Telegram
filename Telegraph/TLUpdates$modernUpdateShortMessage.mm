#import "TLUpdates$modernUpdateShortMessage.h"

#import "TLMetaClassStore.h"

@implementation TLUpdates$modernUpdateShortMessage

- (void)TLserialize:(NSOutputStream *)__unused os
{
    TGLog(@"***** TLUpdates$modernUpdateShortMessage serialization not supported");
}

- (id<TLObject>)TLdeserialize:(NSInputStream *)is signature:(int32_t)__unused signature environment:(id<TLSerializationEnvironment>)__unused environment context:(TLSerializationContext *)__unused context error:(__autoreleasing NSError **)__unused error
{
    TLUpdates$modernUpdateShortMessage *result = [[TLUpdates$modernUpdateShortMessage alloc] init];
    
    result.flags = [is readInt32];
    
    result.n_id = [is readInt32];
    result.user_id = [is readInt32];
    
    result.message = [is readString];
    
    result.pts = [is readInt32];
    result.pts_count = [is readInt32];
    
    result.date = [is readInt32];
    
    if (result.flags & (1 << 2))
    {
        int32_t signature = [is readInt32];
        result.fwd_from_id = TLMetaClassStore::constructObject(is, signature, environment, nil, error);
        result.fwd_date = [is readInt32];
    }
    
    if (result.flags & (1 << 3))
        result.reply_to_msg_id = [is readInt32];
    
    if (result.flags & (1 << 7))
    {
        __unused int32_t entitiesSignature = [is readInt32];
        int32_t count = [is readInt32];
        NSMutableArray *entities = [[NSMutableArray alloc] init];
        for (int32_t i = 0; i < count; i++)
        {
            int32_t signature = [is readInt32];
            id entity = TLMetaClassStore::constructObject(is, signature, environment, nil, error);
            if (entity != nil)
                [entities addObject:entity];
        }
        result.entities = entities;
    }
    
    return result;
}

@end
