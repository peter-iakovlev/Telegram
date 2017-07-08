#import "TLpayments_PaymentForm.h"

#import "../NSInputStream+TL.h"
#import "../NSOutputStream+TL.h"

#import "TLInvoice.h"
#import "TLDataJSON.h"
#import "TLPaymentRequestedInfo.h"
#import "TLPaymentSavedCredentials.h"

@implementation TLpayments_PaymentForm


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

@implementation TLpayments_PaymentForm$payments_paymentFormMeta : TLpayments_PaymentForm


- (int32_t)TLconstructorSignature
{
    return (int32_t)0xf82b6dc0;
}

- (int32_t)TLconstructorName
{
    return (int32_t)0xcf18b5ee;
}

- (id<TLObject>)TLbuildFromMetaObject:(std::shared_ptr<TLMetaObject>)metaObject
{
    TLpayments_PaymentForm$payments_paymentFormMeta *object = [[TLpayments_PaymentForm$payments_paymentFormMeta alloc] init];
    object.flags = metaObject->getInt32((int32_t)0x81915c23);
    object.bot_id = metaObject->getInt32((int32_t)0x214f3dba);
    object.invoice = metaObject->getObject((int32_t)0xdb2f8b58);
    object.provider_id = metaObject->getInt32((int32_t)0x50f236f6);
    object.url = metaObject->getString((int32_t)0xeaf7861e);
    object.native_provider = metaObject->getString((int32_t)0x8ed215fa);
    object.native_params = metaObject->getObject((int32_t)0xdd888a7c);
    object.saved_info = metaObject->getObject((int32_t)0x35896b20);
    object.saved_credentials = metaObject->getObject((int32_t)0x40a34c15);
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
        value.type = TLConstructedValueTypeString;
        value.nativeObject = self.url;
        values->insert(std::pair<int32_t, TLConstructedValue>((int32_t)0xeaf7861e, value));
    }
    {
        TLConstructedValue value;
        value.type = TLConstructedValueTypeString;
        value.nativeObject = self.native_provider;
        values->insert(std::pair<int32_t, TLConstructedValue>((int32_t)0x8ed215fa, value));
    }
    {
        TLConstructedValue value;
        value.type = TLConstructedValueTypeObject;
        value.nativeObject = self.native_params;
        values->insert(std::pair<int32_t, TLConstructedValue>((int32_t)0xdd888a7c, value));
    }
    {
        TLConstructedValue value;
        value.type = TLConstructedValueTypeObject;
        value.nativeObject = self.saved_info;
        values->insert(std::pair<int32_t, TLConstructedValue>((int32_t)0x35896b20, value));
    }
    {
        TLConstructedValue value;
        value.type = TLConstructedValueTypeObject;
        value.nativeObject = self.saved_credentials;
        values->insert(std::pair<int32_t, TLConstructedValue>((int32_t)0x40a34c15, value));
    }
    {
        TLConstructedValue value;
        value.type = TLConstructedValueTypeVector;
        value.nativeObject = self.users;
        values->insert(std::pair<int32_t, TLConstructedValue>((int32_t)0x933e5ff3, value));
    }
}


@end

