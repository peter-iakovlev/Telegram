#import "TLpayments_PaymentForm$payments_paymentForm.h"

#import "TLMetaClassStore.h"

@implementation TLpayments_PaymentForm$payments_paymentForm

- (void)TLserialize:(NSOutputStream *)__unused os
{
}

- (bool)can_save_credentials {
    return self.flags & (1 << 2);
}

- (bool)password_missing {
    return self.flags & (1 << 3);
}

//payments.paymentForm flags:# can_save_credentials:flags.2?true password_missing:flags.3?true bot_id:int invoice:Invoice provider_id:int url:string native_provider:flags.4?string native_params:flags.4?DataJSON saved_info:flags.0?PaymentRequestedInfo saved_credentials:flags.1?PaymentSavedCredentials users:Vector<User> = payments.PaymentForm;

- (id<TLObject>)TLdeserialize:(NSInputStream *)is signature:(int32_t)__unused signature environment:(id<TLSerializationEnvironment>)__unused environment context:(TLSerializationContext *)__unused context error:(__autoreleasing NSError **)__unused error
{
    TLpayments_PaymentForm$payments_paymentForm *result = [[TLpayments_PaymentForm$payments_paymentForm alloc] init];
    
    int32_t flags = [is readInt32];
    result.flags = flags;
    result.bot_id = [is readInt32];
    
    {
        int32_t signature = [is readInt32];
        result.invoice = TLMetaClassStore::constructObject(is, signature, environment, nil, error);
    }
    
    result.provider_id = [is readInt32];
    result.url = [is readString];
    
    if (flags & (1 << 4)) {
        result.native_provider = [is readString];
        
        int32_t signature = [is readInt32];
        result.native_params = TLMetaClassStore::constructObject(is, signature, environment, nil, error);
    }
    
    if (flags & (1 << 0)) {
        int32_t signature = [is readInt32];
        result.saved_info = TLMetaClassStore::constructObject(is, signature, environment, nil, error);
    }
    
    if (flags & (1 << 1)) {
        int32_t signature = [is readInt32];
        result.saved_credentials = TLMetaClassStore::constructObject(is, signature, environment, nil, error);
    }
    
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
