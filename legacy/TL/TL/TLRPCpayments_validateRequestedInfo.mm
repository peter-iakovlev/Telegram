#import "TLRPCpayments_validateRequestedInfo.h"

#import "../NSInputStream+TL.h"
#import "../NSOutputStream+TL.h"

#import "TLPaymentRequestedInfo.h"
#import "TLpayments_ValidatedRequestedInfo.h"

@implementation TLRPCpayments_validateRequestedInfo


- (Class)responseClass
{
    return [TLpayments_ValidatedRequestedInfo class];
}

- (int)impliedResponseSignature
{
    return (int)0x3cfc7e35;
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

@implementation TLRPCpayments_validateRequestedInfo$payments_validateRequestedInfo : TLRPCpayments_validateRequestedInfo


- (int32_t)TLconstructorSignature
{
    return (int32_t)0x770a8e74;
}

- (int32_t)TLconstructorName
{
    return (int32_t)0x136390b0;
}

- (id<TLObject>)TLbuildFromMetaObject:(std::shared_ptr<TLMetaObject>)metaObject
{
    TLRPCpayments_validateRequestedInfo$payments_validateRequestedInfo *object = [[TLRPCpayments_validateRequestedInfo$payments_validateRequestedInfo alloc] init];
    object.flags = metaObject->getInt32((int32_t)0x81915c23);
    object.msg_id = metaObject->getInt32((int32_t)0xf1cc383f);
    object.info = metaObject->getObject((int32_t)0x3928e0e2);
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
        value.primitive.int32Value = self.msg_id;
        values->insert(std::pair<int32_t, TLConstructedValue>((int32_t)0xf1cc383f, value));
    }
    {
        TLConstructedValue value;
        value.type = TLConstructedValueTypeObject;
        value.nativeObject = self.info;
        values->insert(std::pair<int32_t, TLConstructedValue>((int32_t)0x3928e0e2, value));
    }
}


@end

