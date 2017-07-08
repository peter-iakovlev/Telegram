#import "TLpayments_PaymentReceipt.h"

#import "../NSInputStream+TL.h"
#import "../NSOutputStream+TL.h"

#import "TLInvoice.h"
#import "TLPaymentRequestedInfo.h"
#import "TLShippingOption.h"

@implementation TLpayments_PaymentReceipt


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

@implementation TLpayments_PaymentReceipt$payments_paymentReceiptMeta : TLpayments_PaymentReceipt


- (int32_t)TLconstructorSignature
{
    return (int32_t)0x5f1794be;
}

- (int32_t)TLconstructorName
{
    return (int32_t)0x9573627;
}

- (id<TLObject>)TLbuildFromMetaObject:(std::shared_ptr<TLMetaObject>)metaObject
{
    TLpayments_PaymentReceipt$payments_paymentReceiptMeta *object = [[TLpayments_PaymentReceipt$payments_paymentReceiptMeta alloc] init];
    object.flags = metaObject->getInt32((int32_t)0x81915c23);
    object.date = metaObject->getInt32((int32_t)0xb76958ba);
    object.bot_id = metaObject->getInt32((int32_t)0x214f3dba);
    object.invoice = metaObject->getObject((int32_t)0xdb2f8b58);
    object.provider_id = metaObject->getInt32((int32_t)0x50f236f6);
    object.info = metaObject->getObject((int32_t)0x3928e0e2);
    object.shipping = metaObject->getObject((int32_t)0x8c77294e);
    object.currency = metaObject->getString((int32_t)0xd2a84177);
    object.total_amount = metaObject->getInt64((int32_t)0x662699d7);
    object.credentials_title = metaObject->getString((int32_t)0x3f099692);
    object.users = metaObject->getArray((int32_t)0x933e5ff3);
    return object;
}

- (void)TLfillFieldsWithValues:(std::map<int32_t, TLConstructedValue> *)values
{
    {
        TLConstructedValue value;
        value.type = TLConstructedValueTypePrimitiveInt32;
        value.primitive.int32Value = self.flags;
        values->insert(std::pair<int32_t, TLConstructedValue>((int32_t)0x81915c23, value));
    }
    {
        TLConstructedValue value;
        value.type = TLConstructedValueTypePrimitiveInt32;
        value.primitive.int32Value = self.date;
        values->insert(std::pair<int32_t, TLConstructedValue>((int32_t)0xb76958ba, value));
    }
    {
        TLConstructedValue value;
        value.type = TLConstructedValueTypePrimitiveInt32;
        value.primitive.int32Value = self.bot_id;
        values->insert(std::pair<int32_t, TLConstructedValue>((int32_t)0x214f3dba, value));
    }
    {
        TLConstructedValue value;
        value.type = TLConstructedValueTypeObject;
        value.nativeObject = self.invoice;
        values->insert(std::pair<int32_t, TLConstructedValue>((int32_t)0xdb2f8b58, value));
    }
    {
        TLConstructedValue value;
        value.type = TLConstructedValueTypePrimitiveInt32;
        value.primitive.int32Value = self.provider_id;
        values->insert(std::pair<int32_t, TLConstructedValue>((int32_t)0x50f236f6, value));
    }
    {
        TLConstructedValue value;
        value.type = TLConstructedValueTypeObject;
        value.nativeObject = self.info;
        values->insert(std::pair<int32_t, TLConstructedValue>((int32_t)0x3928e0e2, value));
    }
    {
        TLConstructedValue value;
        value.type = TLConstructedValueTypeObject;
        value.nativeObject = self.shipping;
        values->insert(std::pair<int32_t, TLConstructedValue>((int32_t)0x8c77294e, value));
    }
    {
        TLConstructedValue value;
        value.type = TLConstructedValueTypeString;
        value.nativeObject = self.currency;
        values->insert(std::pair<int32_t, TLConstructedValue>((int32_t)0xd2a84177, value));
    }
    {
        TLConstructedValue value;
        value.type = TLConstructedValueTypePrimitiveInt64;
        value.primitive.int64Value = self.total_amount;
        values->insert(std::pair<int32_t, TLConstructedValue>((int32_t)0x662699d7, value));
    }
    {
        TLConstructedValue value;
        value.type = TLConstructedValueTypeString;
        value.nativeObject = self.credentials_title;
        values->insert(std::pair<int32_t, TLConstructedValue>((int32_t)0x3f099692, value));
    }
    {
        TLConstructedValue value;
        value.type = TLConstructedValueTypeVector;
        value.nativeObject = self.users;
        values->insert(std::pair<int32_t, TLConstructedValue>((int32_t)0x933e5ff3, value));
    }
}


@end

