#import "TLRPCpayments_getPaymentForm.h"

#import "../NSInputStream+TL.h"
#import "../NSOutputStream+TL.h"

#import "TLpayments_PaymentForm.h"

@implementation TLRPCpayments_getPaymentForm


- (Class)responseClass
{
    return [TLpayments_PaymentForm class];
}

- (int)impliedResponseSignature
{
    return (int)0xf82b6dc0;
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

@implementation TLRPCpayments_getPaymentForm$payments_getPaymentForm : TLRPCpayments_getPaymentForm


- (int32_t)TLconstructorSignature
{
    return (int32_t)0x99f09745;
}

- (int32_t)TLconstructorName
{
    return (int32_t)0xc8a871f;
}

- (id<TLObject>)TLbuildFromMetaObject:(std::shared_ptr<TLMetaObject>)metaObject
{
    TLRPCpayments_getPaymentForm$payments_getPaymentForm *object = [[TLRPCpayments_getPaymentForm$payments_getPaymentForm alloc] init];
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

