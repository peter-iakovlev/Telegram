#import "TLpayments_SavedInfo$payments_savedInfo.h"

#import "TLMetaClassStore.h"

//payments.savedInfo flags:# saved_info:flags.0?PaymentRequestedInfo has_saved_credentials:flags.1?true = payments.SavedInfo;

@implementation TLpayments_SavedInfo$payments_savedInfo

- (void)TLserialize:(NSOutputStream *)__unused os
{
}

- (bool)has_saved_credentials {
    return self.flags & (1 << 2);
}

- (id<TLObject>)TLdeserialize:(NSInputStream *)is signature:(int32_t)__unused signature environment:(id<TLSerializationEnvironment>)__unused environment context:(TLSerializationContext *)__unused context error:(__autoreleasing NSError **)__unused error
{
    TLpayments_SavedInfo$payments_savedInfo *result = [[TLpayments_SavedInfo$payments_savedInfo alloc] init];
    
    int32_t flags = [is readInt32];
    result.flags = flags;
    
    if (flags & (1 << 0)) {
        int32_t signature = [is readInt32];
        result.saved_info = TLMetaClassStore::constructObject(is, signature, environment, nil, error);
    }
    
    return result;
}

@end
