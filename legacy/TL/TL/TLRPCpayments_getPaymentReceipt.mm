#import "TLRPCpayments_getPaymentReceipt.h"

#import "../NSInputStream+TL.h"
#import "../NSOutputStream+TL.h"

#import "TLpayments_PaymentReceipt.h"

@implementation TLRPCpayments_getPaymentReceipt


- (Class)responseClass
{
    return [TLpayments_PaymentReceipt class];
}

- (int)impliedResponseSignature
{
    return (int)0x5f1794be;
}

- (int)layerVersion
{
    return 64;
}

- (int32_t)TLconstructorSignature
{
    TGLog(@"constructorSignature is not implemented for base type");
    return 0;
}

- (int32_t)TLconstructorName
{
    TGLog(@"constructorName is not implemented for base type");
    return 0;
}

- (id<TLObject>)TLbuildFromMetaObject:(std::shared_ptr<TLMetaObject>)__unused metaObject
{
    TGLog(@"TLbuildFromMetaObject is not implemented for base type");
    return nil;
}

- (void)TLfillFieldsWithValues:(std::map<int32_t, TLConstructedValue> *)__unused values
{
    TGLog(@"TLfillFieldsWithValues is not implemented for base type");
}


@end

@implementation TLRPCpayments_getPaymentReceipt$payments_getPaymentReceipt : TLRPCpayments_getPaymentReceipt


- (int32_t)TLconstructorSignature
{
    return (int32_t)0xa092a980;
}

- (int32_t)TLconstructorName
{
    return (int32_t)0x6c89a49e;
}

- (id<TLObject>)TLbuildFromMetaObject:(std::shared_ptr<TLMetaObject>)metaObject
{
    TLRPCpayments_getPaymentReceipt$payments_getPaymentReceipt *object = [[TLRPCpayments_getPaymentReceipt$payments_getPaymentReceipt alloc] init];
    object.msg_id = metaObject->getInt32((int32_t)0xf1cc383f);
    return object;
}

- (void)TLfillFieldsWithValues:(std::map<int32_t, TLConstructedValue> *)values
{
    {
        TLConstructedValue value;
        value.type = TLConstructedValueTypePrimitiveInt32;
        value.primitive.int32Value = self.msg_id;
        values->insert(std::pair<int32_t, TLConstructedValue>((int32_t)0xf1cc383f, value));
    }
}


@end

