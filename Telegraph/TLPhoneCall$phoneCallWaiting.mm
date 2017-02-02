#import "TLPhoneCall$phoneCallWaiting.h"

#import "TLMetaClassStore.h"

//phoneCallWaiting flags:# id:long access_hash:long date:int admin_id:int participant_id:int protocol:PhoneCallProtocol receive_date:flags.0?int = PhoneCall;

@implementation TLPhoneCall$phoneCallWaiting

- (void)TLserialize:(NSOutputStream *)__unused os
{
    TGLog(@"***** TLPhoneCall$phoneCallWaiting serialization not supported");
}

//phoneCallWaiting#1b8f4ad1 flags:# id:long access_hash:long date:int admin_id:int participant_id:int protocol:PhoneCallProtocol receive_date:flags.0?int = PhoneCall;

- (id<TLObject>)TLdeserialize:(NSInputStream *)is signature:(int32_t)__unused signature environment:(id<TLSerializationEnvironment>)__unused environment context:(TLSerializationContext *)__unused context error:(__autoreleasing NSError **)__unused error
{
    TLPhoneCall$phoneCallWaiting *result = [[TLPhoneCall$phoneCallWaiting alloc] init];
    
    int32_t flags = [is readInt32];
    result.flags = flags;
    
    result.n_id = [is readInt64];
    result.access_hash = [is readInt64];
    result.date = [is readInt32];
    result.admin_id = [is readInt32];
    result.participant_id = [is readInt32];
    
    {
        int32_t signature = [is readInt32];
        result.protocol = TLMetaClassStore::constructObject(is, signature, environment, nil, error);
    }
    
    if (flags & (1 << 0)) {
        result.receive_date = [is readInt32];
    }
    
    return result;
}

@end
