#import "TLInvoice$invoice.h"

#import "TLMetaClassStore.h"

//invoice flags:# test:flags.0?true name_requested:flags.1?true phone_requested:flags.2?true email_requested:flags.3?true shipping_address_requested:flags.4?true flexible:flags.5?true currency:string prices:Vector<LabeledPrice> = Invoice;

@implementation TLInvoice$invoice

- (void)TLserialize:(NSOutputStream *)__unused os
{
    TGLog(@"***** TLMessageAction$messageActionPhoneCall serialization not supported");
}

- (bool)test {
    return self.flags & (1 << 0);
}

- (bool)name_requested {
    return self.flags & (1 << 1);
}

- (bool)phone_requested {
    return self.flags & (1 << 2);
}

- (bool)email_requested {
    return self.flags & (1 << 3);
}

- (bool)shipping_address_requested {
    return self.flags & (1 << 4);
}

- (bool)flexible {
    return self.flags & (1 << 5);
}

- (id<TLObject>)TLdeserialize:(NSInputStream *)is signature:(int32_t)__unused signature environment:(id<TLSerializationEnvironment>)__unused environment context:(TLSerializationContext *)__unused context error:(__autoreleasing NSError **)__unused error
{
    TLInvoice$invoice *result = [[TLInvoice$invoice alloc] init];
    
    int32_t flags = [is readInt32];
    result.flags = flags;
    
    result.currency = [is readString];
    
    {
        [is readInt32];
        
        NSMutableArray *items = [[NSMutableArray alloc] init];
        int32_t count = [is readInt32];
        for (int32_t i = 0; i < count; i++) {
            int32_t signature = [is readInt32];
            id item = TLMetaClassStore::constructObject(is, signature, environment, nil, error);
            if (error != nil && *error != nil) {
                return nil;
            }
            if (item != nil) {
                [items addObject:item];
            }
        }
        
        result.prices = items;
    }
    
    return result;
}


@end
