#import "TLPaymentRequestedInfo.h"

#import "../NSInputStream+TL.h"
#import "../NSOutputStream+TL.h"

#import "TLPostAddress.h"

@implementation TLPaymentRequestedInfo


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

@implementation TLPaymentRequestedInfo$paymentRequestedInfoMeta : TLPaymentRequestedInfo


- (int32_t)TLconstructorSignature
{
    return (int32_t)0xeb45a08f;
}

- (int32_t)TLconstructorName
{
    return (int32_t)0xd00e6be1;
}

- (id<TLObject>)TLbuildFromMetaObject:(std::shared_ptr<TLMetaObject>)metaObject
{
    TLPaymentRequestedInfo$paymentRequestedInfoMeta *object = [[TLPaymentRequestedInfo$paymentRequestedInfoMeta alloc] init];
    object.flags = metaObject->getInt32((int32_t)0x81915c23);
    object.name = metaObject->getString((int32_t)0x798b364a);
    object.phone = metaObject->getString((int32_t)0x9e6a8d86);
    object.email = metaObject->getString((int32_t)0x5b2095e7);
    object.shipping_address = metaObject->getObject((int32_t)0xe68acb99);
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
        value.type = TLConstructedValueTypeString;
        value.nativeObject = self.name;
        values->insert(std::pair<int32_t, TLConstructedValue>((int32_t)0x798b364a, value));
    }
    {
        TLConstructedValue value;
        value.type = TLConstructedValueTypeString;
        value.nativeObject = self.phone;
        values->insert(std::pair<int32_t, TLConstructedValue>((int32_t)0x9e6a8d86, value));
    }
    {
        TLConstructedValue value;
        value.type = TLConstructedValueTypeString;
        value.nativeObject = self.email;
        values->insert(std::pair<int32_t, TLConstructedValue>((int32_t)0x5b2095e7, value));
    }
    {
        TLConstructedValue value;
        value.type = TLConstructedValueTypeObject;
        value.nativeObject = self.shipping_address;
        values->insert(std::pair<int32_t, TLConstructedValue>((int32_t)0xe68acb99, value));
    }
}


@end

