#import "TLRPCauth_sendCode.h"

#import "../NSInputStream+TL.h"
#import "../NSOutputStream+TL.h"

#import "TLauth_SentCode.h"

@implementation TLRPCauth_sendCode


- (Class)responseClass
{
    return [TLauth_SentCode class];
}

- (int)impliedResponseSignature
{
    return 0;
}

- (int)layerVersion
{
    return 5;
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

- (id<TLObject>)TLbuildFromMetaObject:(std::tr1::shared_ptr<TLMetaObject>)__unused metaObject
{
    TGLog(@"TLbuildFromMetaObject is not implemented for base type");
    return nil;
}

- (void)TLfillFieldsWithValues:(std::map<int32_t, TLConstructedValue> *)__unused values
{
    TGLog(@"TLfillFieldsWithValues is not implemented for base type");
}


@end

@implementation TLRPCauth_sendCode$auth_sendCode : TLRPCauth_sendCode


- (int32_t)TLconstructorSignature
{
    return (int32_t)0x768d5f4d;
}

- (int32_t)TLconstructorName
{
    return (int32_t)0x6ef386b1;
}

- (id<TLObject>)TLbuildFromMetaObject:(std::tr1::shared_ptr<TLMetaObject>)metaObject
{
    TLRPCauth_sendCode$auth_sendCode *object = [[TLRPCauth_sendCode$auth_sendCode alloc] init];
    object.phone_number = metaObject->getString((int32_t)0xaecb6c79);
    object.sms_type = metaObject->getInt32((int32_t)0x81989b48);
    object.api_id = metaObject->getInt32((int32_t)0x658ffe92);
    object.api_hash = metaObject->getString((int32_t)0x868d53ee);
    object.lang_code = metaObject->getString((int32_t)0x2ccfcaf3);
    return object;
}

- (void)TLfillFieldsWithValues:(std::map<int32_t, TLConstructedValue> *)values
{
    {
        TLConstructedValue value;
        value.type = TLConstructedValueTypeString;
        value.nativeObject = self.phone_number;
        values->insert(std::pair<int32_t, TLConstructedValue>((int32_t)0xaecb6c79, value));
    }
    {
        TLConstructedValue value;
        value.type = TLConstructedValueTypePrimitiveInt32;
        value.primitive.int32Value = self.sms_type;
        values->insert(std::pair<int32_t, TLConstructedValue>((int32_t)0x81989b48, value));
    }
    {
        TLConstructedValue value;
        value.type = TLConstructedValueTypePrimitiveInt32;
        value.primitive.int32Value = self.api_id;
        values->insert(std::pair<int32_t, TLConstructedValue>((int32_t)0x658ffe92, value));
    }
    {
        TLConstructedValue value;
        value.type = TLConstructedValueTypeString;
        value.nativeObject = self.api_hash;
        values->insert(std::pair<int32_t, TLConstructedValue>((int32_t)0x868d53ee, value));
    }
    {
        TLConstructedValue value;
        value.type = TLConstructedValueTypeString;
        value.nativeObject = self.lang_code;
        values->insert(std::pair<int32_t, TLConstructedValue>((int32_t)0x2ccfcaf3, value));
    }
}


@end

