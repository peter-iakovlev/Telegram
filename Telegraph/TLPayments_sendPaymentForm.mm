#import "TLPayments_sendPaymentForm.h"

#import "TL/TLMetaScheme.h"
#import "TLMetaClassStore.h"

@implementation TLPayments_sendPaymentForm

- (int32_t)TLconstructorSignature
{
    return 0x2b8879b3;
}

- (int32_t)TLconstructorName
{
    return -1;
}

- (Class)responseClass
{
    return [TLpayments_PaymentResult class];
}

- (int)impliedResponseSignature
{
    return 0;
}

- (int)layerVersion
{
    return 64;
}

//payments.sendPaymentForm flags:# msg_id:int requested_info_id:flags.0?string shipping_option_id:flags.1?string credentials:InputPaymentCredentials = payments.PaymentResult;

- (void)TLserialize:(NSOutputStream *)os
{
    [os writeInt32:self.flags];
    
    [os writeInt32:self.msg_id];
    if (self.flags & (1 << 0)) {
        [os writeString:self.requested_info_id];
    }
    if (self.flags & (1 << 1)) {
        [os writeString:self.shipping_option_id];
    }
    
    TLMetaClassStore::serializeObject(os, self.credentials, true);
}

- (id<TLObject>)TLdeserialize:(NSInputStream *)__unused is signature:(int32_t)__unused signature environment:(id<TLSerializationEnvironment>)__unused environment context:(TLSerializationContext *)__unused context error:(__autoreleasing NSError **)__unused error
{
    return nil;
}

@end
