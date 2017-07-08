#import "TLpayments_PaymentResult.h"

#import "../NSInputStream+TL.h"
#import "../NSOutputStream+TL.h"

#import "TLUpdates.h"

@implementation TLpayments_PaymentResult


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

@implementation TLpayments_PaymentResult$payments_paymentResult : TLpayments_PaymentResult


- (int32_t)TLconstructorSignature
{
    return (int32_t)0x4e5f810d;
}

- (int32_t)TLconstructorName
{
    return (int32_t)0x7783ed5e;
}

- (id<TLObject>)TLbuildFromMetaObject:(std::shared_ptr<TLMetaObject>)metaObject
{
    TLpayments_PaymentResult$payments_paymentResult *object = [[TLpayments_PaymentResult$payments_paymentResult alloc] init];
    object.updates = metaObject->getObject((int32_t)0x9ae046f4);
    return object;
}

- (void)TLfillFieldsWithValues:(std::map<int32_t, TLConstructedValue> *)values
{
    {
        TLConstructedValue value;
        value.type = TLConstructedValueTypeObject;
        value.nativeObject = self.updates;
        values->insert(std::pair<int32_t, TLConstructedValue>((int32_t)0x9ae046f4, value));
    }
}


@end

@implementation TLpayments_PaymentResult$payments_paymentVerficationNeeded : TLpayments_PaymentResult


- (int32_t)TLconstructorSignature
{
    return (int32_t)0x6b56b921;
}

- (int32_t)TLconstructorName
{
    return (int32_t)0x4aeb3c30;
}

- (id<TLObject>)TLbuildFromMetaObject:(std::shared_ptr<TLMetaObject>)metaObject
{
    TLpayments_PaymentResult$payments_paymentVerficationNeeded *object = [[TLpayments_PaymentResult$payments_paymentVerficationNeeded alloc] init];
    object.url = metaObject->getString((int32_t)0xeaf7861e);
    return object;
}

- (void)TLfillFieldsWithValues:(std::map<int32_t, TLConstructedValue> *)values
{
    {
        TLConstructedValue value;
        value.type = TLConstructedValueTypeString;
        value.nativeObject = self.url;
        values->insert(std::pair<int32_t, TLConstructedValue>((int32_t)0xeaf7861e, value));
    }
}


@end

