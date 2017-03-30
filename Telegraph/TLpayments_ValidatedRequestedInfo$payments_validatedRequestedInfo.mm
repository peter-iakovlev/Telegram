#import "TLpayments_ValidatedRequestedInfo$payments_validatedRequestedInfo.h"

#import "TLMetaClassStore.h"

//payments.validatedRequestedInfo flags:# id:flags.0?string url:string webview_only:flags.2?true shipping_options:flags.1?Vector<ShippingOption> = payments.ValidatedRequestedInfo;

@implementation TLpayments_ValidatedRequestedInfo$payments_validatedRequestedInfo

- (bool)webview_only {
    return self.flags & (1 << 2);
}

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
    TLpayments_ValidatedRequestedInfo$payments_validatedRequestedInfo *result = [[TLpayments_ValidatedRequestedInfo$payments_validatedRequestedInfo alloc] init];
    
    int32_t flags = [is readInt32];
    result.flags = flags;
    
    if (flags & (1 << 0)) {
        result.n_id = [is readString];
    }
    
    if (flags & (1 << 1))
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
        
        result.shipping_options = items;
    }
    
    return result;
}

@end
