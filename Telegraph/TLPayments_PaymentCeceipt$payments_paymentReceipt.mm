#import "TLPayments_PaymentCeceipt$payments_paymentReceipt.h"

#import "TLMetaClassStore.h"

//payments.paymentReceipt flags:# date:int bot_id:int invoice:Invoice provider_id:int info:flags.0?PaymentRequestedInfo shipping_option:flags.1?ShippingOption currency:string total_amount:int credentials_title:string users:Vector<User> = payments.PaymentReceipt;

@implementation TLPayments_PaymentCeceipt$payments_paymentReceipt

- (int32_t)TLconstructorName {
    return -1;
}

- (int32_t)TLconstructorSignature {
    return 0;
}

- (void)TLserialize:(NSOutputStream *)__unused os
{
    assert(false);
}

- (id<TLObject>)TLdeserialize:(NSInputStream *)is signature:(int32_t)__unused signature environment:(id<TLSerializationEnvironment>)__unused environment context:(TLSerializationContext *)__unused context error:(__autoreleasing NSError **)__unused error
{
    TLPayments_PaymentCeceipt$payments_paymentReceipt *result = [[TLPayments_PaymentCeceipt$payments_paymentReceipt alloc] init];
    
    int32_t flags = [is readInt32];
    result.flags = flags;
    
    result.date = [is readInt32];
    result.bot_id = [is readInt32];
    
    {
        int32_t signature = [is readInt32];
        result.invoice = TLMetaClassStore::constructObject(is, signature, environment, nil, error);
    }
    
    result.provider_id = [is readInt32];
    
    if (flags & (1 << 0))
    {
        int32_t signature = [is readInt32];
        result.info = TLMetaClassStore::constructObject(is, signature, environment, nil, error);
    }
    
    if (flags & (1 << 1)) {
        int32_t signature = [is readInt32];
        result.shipping = TLMetaClassStore::constructObject(is, signature, environment, nil, error);
    }
    
    result.currency = [is readString];
    result.total_amount = [is readInt64];
    result.credentials_title = [is readString];
    
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
        
        result.users = items;
    }
    
    return result;
}


@end
