#import "TLauth_SentCode.h"

#import "../NSInputStream+TL.h"
#import "../NSOutputStream+TL.h"


@implementation TLauth_SentCode


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

@implementation TLauth_SentCode$auth_sentCodePreview : TLauth_SentCode


- (int32_t)TLconstructorSignature
{
    return (int32_t)0x3cf5727a;
}

- (int32_t)TLconstructorName
{
    return (int32_t)0xe3ffd86f;
}

- (id<TLObject>)TLbuildFromMetaObject:(std::tr1::shared_ptr<TLMetaObject>)metaObject
{
    TLauth_SentCode$auth_sentCodePreview *object = [[TLauth_SentCode$auth_sentCodePreview alloc] init];
    object.phone_registered = metaObject->getBool((int32_t)0xd2179e1d);
    object.phone_code_hash = metaObject->getString((int32_t)0xd4dfef1b);
    object.phone_code_test = metaObject->getString((int32_t)0x9a6ac976);
    return object;
}

- (void)TLfillFieldsWithValues:(std::map<int32_t, TLConstructedValue> *)values
{
    {
        TLConstructedValue value;
        value.type = TLConstructedValueTypePrimitiveBool;
        value.primitive.boolValue = self.phone_registered;
        values->insert(std::pair<int32_t, TLConstructedValue>((int32_t)0xd2179e1d, value));
    }
    {
        TLConstructedValue value;
        value.type = TLConstructedValueTypeString;
        value.nativeObject = self.phone_code_hash;
        values->insert(std::pair<int32_t, TLConstructedValue>((int32_t)0xd4dfef1b, value));
    }
    {
        TLConstructedValue value;
        value.type = TLConstructedValueTypeString;
        value.nativeObject = self.phone_code_test;
        values->insert(std::pair<int32_t, TLConstructedValue>((int32_t)0x9a6ac976, value));
    }
}


@end

@implementation TLauth_SentCode$auth_sentPassPhrase : TLauth_SentCode


- (int32_t)TLconstructorSignature
{
    return (int32_t)0x1a1e1fae;
}

- (int32_t)TLconstructorName
{
    return (int32_t)0x91c3e08;
}

- (id<TLObject>)TLbuildFromMetaObject:(std::tr1::shared_ptr<TLMetaObject>)metaObject
{
    TLauth_SentCode$auth_sentPassPhrase *object = [[TLauth_SentCode$auth_sentPassPhrase alloc] init];
    object.phone_registered = metaObject->getBool((int32_t)0xd2179e1d);
    return object;
}

- (void)TLfillFieldsWithValues:(std::map<int32_t, TLConstructedValue> *)values
{
    {
        TLConstructedValue value;
        value.type = TLConstructedValueTypePrimitiveBool;
        value.primitive.boolValue = self.phone_registered;
        values->insert(std::pair<int32_t, TLConstructedValue>((int32_t)0xd2179e1d, value));
    }
}


@end

@implementation TLauth_SentCode$auth_sentCode : TLauth_SentCode


- (int32_t)TLconstructorSignature
{
    return (int32_t)0xefed51d9;
}

- (int32_t)TLconstructorName
{
    return (int32_t)0xca956015;
}

- (id<TLObject>)TLbuildFromMetaObject:(std::tr1::shared_ptr<TLMetaObject>)metaObject
{
    TLauth_SentCode$auth_sentCode *object = [[TLauth_SentCode$auth_sentCode alloc] init];
    object.phone_registered = metaObject->getBool((int32_t)0xd2179e1d);
    object.phone_code_hash = metaObject->getString((int32_t)0xd4dfef1b);
    object.send_call_timeout = metaObject->getInt32((int32_t)0x74e5208b);
    object.is_password = metaObject->getBool((int32_t)0x44921d2d);
    return object;
}

- (void)TLfillFieldsWithValues:(std::map<int32_t, TLConstructedValue> *)values
{
    {
        TLConstructedValue value;
        value.type = TLConstructedValueTypePrimitiveBool;
        value.primitive.boolValue = self.phone_registered;
        values->insert(std::pair<int32_t, TLConstructedValue>((int32_t)0xd2179e1d, value));
    }
    {
        TLConstructedValue value;
        value.type = TLConstructedValueTypeString;
        value.nativeObject = self.phone_code_hash;
        values->insert(std::pair<int32_t, TLConstructedValue>((int32_t)0xd4dfef1b, value));
    }
    {
        TLConstructedValue value;
        value.type = TLConstructedValueTypePrimitiveInt32;
        value.primitive.int32Value = self.send_call_timeout;
        values->insert(std::pair<int32_t, TLConstructedValue>((int32_t)0x74e5208b, value));
    }
    {
        TLConstructedValue value;
        value.type = TLConstructedValueTypePrimitiveBool;
        value.primitive.boolValue = self.is_password;
        values->insert(std::pair<int32_t, TLConstructedValue>((int32_t)0x44921d2d, value));
    }
}


@end

@implementation TLauth_SentCode$auth_sentAppCode : TLauth_SentCode


- (int32_t)TLconstructorSignature
{
    return (int32_t)0xe325edcf;
}

- (int32_t)TLconstructorName
{
    return (int32_t)0xd52b41aa;
}

- (id<TLObject>)TLbuildFromMetaObject:(std::tr1::shared_ptr<TLMetaObject>)metaObject
{
    TLauth_SentCode$auth_sentAppCode *object = [[TLauth_SentCode$auth_sentAppCode alloc] init];
    object.phone_registered = metaObject->getBool((int32_t)0xd2179e1d);
    object.phone_code_hash = metaObject->getString((int32_t)0xd4dfef1b);
    object.send_call_timeout = metaObject->getInt32((int32_t)0x74e5208b);
    object.is_password = metaObject->getBool((int32_t)0x44921d2d);
    return object;
}

- (void)TLfillFieldsWithValues:(std::map<int32_t, TLConstructedValue> *)values
{
    {
        TLConstructedValue value;
        value.type = TLConstructedValueTypePrimitiveBool;
        value.primitive.boolValue = self.phone_registered;
        values->insert(std::pair<int32_t, TLConstructedValue>((int32_t)0xd2179e1d, value));
    }
    {
        TLConstructedValue value;
        value.type = TLConstructedValueTypeString;
        value.nativeObject = self.phone_code_hash;
        values->insert(std::pair<int32_t, TLConstructedValue>((int32_t)0xd4dfef1b, value));
    }
    {
        TLConstructedValue value;
        value.type = TLConstructedValueTypePrimitiveInt32;
        value.primitive.int32Value = self.send_call_timeout;
        values->insert(std::pair<int32_t, TLConstructedValue>((int32_t)0x74e5208b, value));
    }
    {
        TLConstructedValue value;
        value.type = TLConstructedValueTypePrimitiveBool;
        value.primitive.boolValue = self.is_password;
        values->insert(std::pair<int32_t, TLConstructedValue>((int32_t)0x44921d2d, value));
    }
}


@end

