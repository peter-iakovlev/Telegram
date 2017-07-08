#import "TLRPCaccount_registerDevice.h"

#import "../NSInputStream+TL.h"
#import "../NSOutputStream+TL.h"


@implementation TLRPCaccount_registerDevice


- (Class)responseClass
{
    return [NSNumber class];
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

@implementation TLRPCaccount_registerDevice$account_registerDevice : TLRPCaccount_registerDevice


- (int32_t)TLconstructorSignature
{
    return (int32_t)0x446c712c;
}

- (int32_t)TLconstructorName
{
    return (int32_t)0x8a408e97;
}

- (id<TLObject>)TLbuildFromMetaObject:(std::shared_ptr<TLMetaObject>)metaObject
{
    TLRPCaccount_registerDevice$account_registerDevice *object = [[TLRPCaccount_registerDevice$account_registerDevice alloc] init];
    object.token_type = metaObject->getInt32((int32_t)0xb5f2fc25);
    object.token = metaObject->getString((int32_t)0x1e8aa3f5);
    object.device_model = metaObject->getString((int32_t)0x7baba117);
    object.system_version = metaObject->getString((int32_t)0x18665337);
    object.app_version = metaObject->getString((int32_t)0xe92d4c10);
    object.app_sandbox = metaObject->getBool((int32_t)0xee0a6d3);
    object.lang_code = metaObject->getString((int32_t)0x2ccfcaf3);
    return object;
}

- (void)TLfillFieldsWithValues:(std::map<int32_t, TLConstructedValue> *)values
{
    {
        TLConstructedValue value;
        value.type = TLConstructedValueTypePrimitiveInt32;
        value.primitive.int32Value = self.token_type;
        values->insert(std::pair<int32_t, TLConstructedValue>((int32_t)0xb5f2fc25, value));
    }
    {
        TLConstructedValue value;
        value.type = TLConstructedValueTypeString;
        value.nativeObject = self.token;
        values->insert(std::pair<int32_t, TLConstructedValue>((int32_t)0x1e8aa3f5, value));
    }
    {
        TLConstructedValue value;
        value.type = TLConstructedValueTypeString;
        value.nativeObject = self.device_model;
        values->insert(std::pair<int32_t, TLConstructedValue>((int32_t)0x7baba117, value));
    }
    {
        TLConstructedValue value;
        value.type = TLConstructedValueTypeString;
        value.nativeObject = self.system_version;
        values->insert(std::pair<int32_t, TLConstructedValue>((int32_t)0x18665337, value));
    }
    {
        TLConstructedValue value;
        value.type = TLConstructedValueTypeString;
        value.nativeObject = self.app_version;
        values->insert(std::pair<int32_t, TLConstructedValue>((int32_t)0xe92d4c10, value));
    }
    {
        TLConstructedValue value;
        value.type = TLConstructedValueTypePrimitiveBool;
        value.primitive.boolValue = self.app_sandbox;
        values->insert(std::pair<int32_t, TLConstructedValue>((int32_t)0xee0a6d3, value));
    }
    {
        TLConstructedValue value;
        value.type = TLConstructedValueTypeString;
        value.nativeObject = self.lang_code;
        values->insert(std::pair<int32_t, TLConstructedValue>((int32_t)0x2ccfcaf3, value));
    }
}


@end

