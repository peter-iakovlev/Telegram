#import "TLMessageMedia$messageMediaInvoice.h"

#import "TLMetaClassStore.h"

//messageMediaInvoice flags:# shipping_address_requested:flags.1?true title:string description:string photo:flags.0?WebDocument receipt_msg_id:flags.2?int currency:string total_amount:int = MessageMedia;

@implementation TLMessageMedia$messageMediaInvoice

- (bool)shipping_address_requested {
    return self.flags & (1 << 1);
}

- (void)TLserialize:(NSOutputStream *)__unused os
{
}

- (id<TLObject>)TLdeserialize:(NSInputStream *)is signature:(int32_t)__unused signature environment:(id<TLSerializationEnvironment>)__unused environment context:(TLSerializationContext *)__unused context error:(__autoreleasing NSError **)__unused error
{
    TLMessageMedia$messageMediaInvoice *result = [[TLMessageMedia$messageMediaInvoice alloc] init];
    
    int32_t flags = [is readInt32];
    result.flags = flags;
    
    result.title = [is readString];
    result.n_description = [is readString];
    
    if (flags & (1 << 0)) {
        int32_t signature = [is readInt32];
        result.photo = TLMetaClassStore::constructObject(is, signature, environment, nil, error);
    }
    
    if (flags & (1 << 2)) {
        result.receipt_msg_id = [is readInt32];
    }
    
    result.currency = [is readString];
    result.total_amount = [is readInt64];
    result.start_param = [is readString];
    
    return result;
}


@end
