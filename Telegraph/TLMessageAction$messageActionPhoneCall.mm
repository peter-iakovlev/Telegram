#import "TLMessageAction$messageActionPhoneCall.h"

#import "TLMetaClassStore.h"

//messageActionPhoneCall flags:# call_id:long reason:flags.0?PhoneCallDiscardReason duration:flags.1?int = MessageAction;

@implementation TLMessageAction$messageActionPhoneCall

- (void)TLserialize:(NSOutputStream *)__unused os
{
    TGLog(@"***** TLMessageAction$messageActionPhoneCall serialization not supported");
}

- (id<TLObject>)TLdeserialize:(NSInputStream *)is signature:(int32_t)__unused signature environment:(id<TLSerializationEnvironment>)__unused environment context:(TLSerializationContext *)__unused context error:(__autoreleasing NSError **)__unused error
{
    TLMessageAction$messageActionPhoneCall *result = [[TLMessageAction$messageActionPhoneCall alloc] init];
    
    int32_t flags = [is readInt32];
    result.flags = flags;
    
    result.call_id = [is readInt64];
    
    if (flags & (1 << 0) ) {
        int32_t signature = [is readInt32];
        result.reason = TLMetaClassStore::constructObject(is, signature, environment, nil, error);
    }
    
    if (flags & (1 << 1)) {
        result.duration = [is readInt32];
    }
    
    return result;
}


@end
