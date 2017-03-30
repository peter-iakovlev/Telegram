#import "TLPaymentRequestedInfo$paymentRequestedInfo.h"

#import "TLMetaClassStore.h"

//paymentRequestedInfo flags:# name:flags.0?string phone:flags.1?string email:flags.2?string shipping_address:flags.3?PostAddress = PaymentRequestedInfo;

@implementation TLPaymentRequestedInfo$paymentRequestedInfo

- (int32_t)TLconstructorName {
    return -1;
}

- (int32_t)TLconstructorSignature {
    return 0x909c3f94;
}

- (void)TLserialize:(NSOutputStream *)__unused os
{
    [os writeInt32:self.flags];
    if (self.flags & (1 << 0)) {
        [os writeString:self.name];
    }
    if (self.flags & (1 << 1)) {
        [os writeString:self.phone];
    }
    if (self.flags & (1 << 2)) {
        [os writeString:self.email];
    }
    if (self.flags & (1 << 3)) {
        TLMetaClassStore::serializeObject(os, self.shipping_address, true);
    }
}

- (id<TLObject>)TLdeserialize:(NSInputStream *)is signature:(int32_t)__unused signature environment:(id<TLSerializationEnvironment>)__unused environment context:(TLSerializationContext *)__unused context error:(__autoreleasing NSError **)__unused error
{
    TLPaymentRequestedInfo$paymentRequestedInfo *result = [[TLPaymentRequestedInfo$paymentRequestedInfo alloc] init];
    
    int32_t flags = [is readInt32];
    result.flags = flags;
    
    if (flags & (1 << 0)) {
        result.name = [is readString];
    }
    
    if (flags & (1 << 1)) {
        result.phone = [is readString];
    }
    
    if (flags & (1 << 2)) {
        result.email = [is readString];
    }
    
    if (flags & (1 << 3)) {
        int32_t signature = [is readInt32];
        result.shipping_address = TLMetaClassStore::constructObject(is, signature, environment, nil, error);
    }
    
    return result;
}


@end
