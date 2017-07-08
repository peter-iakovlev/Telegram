#import "TLAuthorization.h"

#import "../NSInputStream+TL.h"
#import "../NSOutputStream+TL.h"


@implementation TLAuthorization


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

@implementation TLAuthorization$authorization : TLAuthorization


- (int32_t)TLconstructorSignature
{
    return (int32_t)0x7bf2e6f6;
}

- (int32_t)TLconstructorName
{
    return (int32_t)0xd97b25b7;
}

- (id<TLObject>)TLbuildFromMetaObject:(std::shared_ptr<TLMetaObject>)metaObject
{
    TLAuthorization$authorization *object = [[TLAuthorization$authorization alloc] init];
    object.n_hash = metaObject->getInt64((int32_t)0xc152e470);
    object.flags = metaObject->getInt32((int32_t)0x81915c23);
    object.device_model = metaObject->getString((int32_t)0x7baba117);
    object.platform = metaObject->getString((int32_t)0x2b6704be);
    object.system_version = metaObject->getString((int32_t)0x18665337);
    object.api_id = metaObject->getInt32((int32_t)0x658ffe92);
    object.app_name = metaObject->getString((int32_t)0xafd961ca);
    object.app_version = metaObject->getString((int32_t)0xe92d4c10);
    object.date_created = metaObject->getInt32((int32_t)0x1fa8db99);
    object.date_active = metaObject->getInt32((int32_t)0xdf2c7255);
    object.ip = metaObject->getString((int32_t)0xe5956ecc);
    object.country = metaObject->getString((int32_t)0xbf857ba3);
    object.region = metaObject->getString((int32_t)0x6758e6e0);
    return object;
}

- (void)TLfillFieldsWithValues:(std::map<int32_t, TLConstructedValue> *)values
{
    {
        TLConstructedValue value;
        value.type = TLConstructedValueTypePrimitiveInt64;
        value.primitive.int64Value = self.n_hash;
        values->insert(std::pair<int32_t, TLConstructedValue>((int32_t)0xc152e470, value));
    }
    {
        TLConstructedValue value;
        value.type = TLConstructedValueTypePrimitiveInt32;
        value.primitive.int32Value = self.flags;
        values->insert(std::pair<int32_t, TLConstructedValue>((int32_t)0x81915c23, value));
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
        value.nativeObject = self.platform;
        values->insert(std::pair<int32_t, TLConstructedValue>((int32_t)0x2b6704be, value));
    }
    {
        TLConstructedValue value;
        value.type = TLConstructedValueTypeString;
        value.nativeObject = self.system_version;
        values->insert(std::pair<int32_t, TLConstructedValue>((int32_t)0x18665337, value));
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
        value.nativeObject = self.app_name;
        values->insert(std::pair<int32_t, TLConstructedValue>((int32_t)0xafd961ca, value));
    }
    {
        TLConstructedValue value;
        value.type = TLConstructedValueTypeString;
        value.nativeObject = self.app_version;
        values->insert(std::pair<int32_t, TLConstructedValue>((int32_t)0xe92d4c10, value));
    }
    {
        TLConstructedValue value;
        value.type = TLConstructedValueTypePrimitiveInt32;
        value.primitive.int32Value = self.date_created;
        values->insert(std::pair<int32_t, TLConstructedValue>((int32_t)0x1fa8db99, value));
    }
    {
        TLConstructedValue value;
        value.type = TLConstructedValueTypePrimitiveInt32;
        value.primitive.int32Value = self.date_active;
        values->insert(std::pair<int32_t, TLConstructedValue>((int32_t)0xdf2c7255, value));
    }
    {
        TLConstructedValue value;
        value.type = TLConstructedValueTypeString;
        value.nativeObject = self.ip;
        values->insert(std::pair<int32_t, TLConstructedValue>((int32_t)0xe5956ecc, value));
    }
    {
        TLConstructedValue value;
        value.type = TLConstructedValueTypeString;
        value.nativeObject = self.country;
        values->insert(std::pair<int32_t, TLConstructedValue>((int32_t)0xbf857ba3, value));
    }
    {
        TLConstructedValue value;
        value.type = TLConstructedValueTypeString;
        value.nativeObject = self.region;
        values->insert(std::pair<int32_t, TLConstructedValue>((int32_t)0x6758e6e0, value));
    }
}


@end

