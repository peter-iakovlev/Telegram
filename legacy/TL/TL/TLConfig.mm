#import "TLConfig.h"

#import "../NSInputStream+TL.h"
#import "../NSOutputStream+TL.h"


@implementation TLConfig


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

@implementation TLConfig$config : TLConfig


- (int32_t)TLconstructorSignature
{
    return (int32_t)0x4e32b894;
}

- (int32_t)TLconstructorName
{
    return (int32_t)0x9167d250;
}

- (id<TLObject>)TLbuildFromMetaObject:(std::tr1::shared_ptr<TLMetaObject>)metaObject
{
    TLConfig$config *object = [[TLConfig$config alloc] init];
    object.date = metaObject->getInt32((int32_t)0xb76958ba);
    object.expires = metaObject->getInt32((int32_t)0x4743fb6b);
    object.test_mode = metaObject->getBool((int32_t)0x1288ca35);
    object.this_dc = metaObject->getInt32((int32_t)0x1b29ec36);
    object.dc_options = metaObject->getArray((int32_t)0x25e6c768);
    object.chat_size_max = metaObject->getInt32((int32_t)0x95174295);
    object.broadcast_size_max = metaObject->getInt32((int32_t)0xe161a8ce);
    object.forwarded_count_max = metaObject->getInt32((int32_t)0xc6f3cb03);
    object.online_update_period_ms = metaObject->getInt32((int32_t)0x1c2d17b2);
    object.offline_blur_timeout_ms = metaObject->getInt32((int32_t)0xbc30fa37);
    object.offline_idle_timeout_ms = metaObject->getInt32((int32_t)0x82b6154);
    object.online_cloud_timeout_ms = metaObject->getInt32((int32_t)0x97f00373);
    object.notify_cloud_delay_ms = metaObject->getInt32((int32_t)0x58eb0cde);
    object.notify_default_delay_ms = metaObject->getInt32((int32_t)0xffe3a208);
    object.chat_big_size = metaObject->getInt32((int32_t)0xbb094b49);
    object.push_chat_period_ms = metaObject->getInt32((int32_t)0x6755b26f);
    object.push_chat_limit = metaObject->getInt32((int32_t)0x68adc403);
    object.disabled_features = metaObject->getArray((int32_t)0x4f56c735);
    return object;
}

- (void)TLfillFieldsWithValues:(std::map<int32_t, TLConstructedValue> *)values
{
    {
        TLConstructedValue value;
        value.type = TLConstructedValueTypePrimitiveInt32;
        value.primitive.int32Value = self.date;
        values->insert(std::pair<int32_t, TLConstructedValue>((int32_t)0xb76958ba, value));
    }
    {
        TLConstructedValue value;
        value.type = TLConstructedValueTypePrimitiveInt32;
        value.primitive.int32Value = self.expires;
        values->insert(std::pair<int32_t, TLConstructedValue>((int32_t)0x4743fb6b, value));
    }
    {
        TLConstructedValue value;
        value.type = TLConstructedValueTypePrimitiveBool;
        value.primitive.boolValue = self.test_mode;
        values->insert(std::pair<int32_t, TLConstructedValue>((int32_t)0x1288ca35, value));
    }
    {
        TLConstructedValue value;
        value.type = TLConstructedValueTypePrimitiveInt32;
        value.primitive.int32Value = self.this_dc;
        values->insert(std::pair<int32_t, TLConstructedValue>((int32_t)0x1b29ec36, value));
    }
    {
        TLConstructedValue value;
        value.type = TLConstructedValueTypeVector;
        value.nativeObject = self.dc_options;
        values->insert(std::pair<int32_t, TLConstructedValue>((int32_t)0x25e6c768, value));
    }
    {
        TLConstructedValue value;
        value.type = TLConstructedValueTypePrimitiveInt32;
        value.primitive.int32Value = self.chat_size_max;
        values->insert(std::pair<int32_t, TLConstructedValue>((int32_t)0x95174295, value));
    }
    {
        TLConstructedValue value;
        value.type = TLConstructedValueTypePrimitiveInt32;
        value.primitive.int32Value = self.broadcast_size_max;
        values->insert(std::pair<int32_t, TLConstructedValue>((int32_t)0xe161a8ce, value));
    }
    {
        TLConstructedValue value;
        value.type = TLConstructedValueTypePrimitiveInt32;
        value.primitive.int32Value = self.forwarded_count_max;
        values->insert(std::pair<int32_t, TLConstructedValue>((int32_t)0xc6f3cb03, value));
    }
    {
        TLConstructedValue value;
        value.type = TLConstructedValueTypePrimitiveInt32;
        value.primitive.int32Value = self.online_update_period_ms;
        values->insert(std::pair<int32_t, TLConstructedValue>((int32_t)0x1c2d17b2, value));
    }
    {
        TLConstructedValue value;
        value.type = TLConstructedValueTypePrimitiveInt32;
        value.primitive.int32Value = self.offline_blur_timeout_ms;
        values->insert(std::pair<int32_t, TLConstructedValue>((int32_t)0xbc30fa37, value));
    }
    {
        TLConstructedValue value;
        value.type = TLConstructedValueTypePrimitiveInt32;
        value.primitive.int32Value = self.offline_idle_timeout_ms;
        values->insert(std::pair<int32_t, TLConstructedValue>((int32_t)0x82b6154, value));
    }
    {
        TLConstructedValue value;
        value.type = TLConstructedValueTypePrimitiveInt32;
        value.primitive.int32Value = self.online_cloud_timeout_ms;
        values->insert(std::pair<int32_t, TLConstructedValue>((int32_t)0x97f00373, value));
    }
    {
        TLConstructedValue value;
        value.type = TLConstructedValueTypePrimitiveInt32;
        value.primitive.int32Value = self.notify_cloud_delay_ms;
        values->insert(std::pair<int32_t, TLConstructedValue>((int32_t)0x58eb0cde, value));
    }
    {
        TLConstructedValue value;
        value.type = TLConstructedValueTypePrimitiveInt32;
        value.primitive.int32Value = self.notify_default_delay_ms;
        values->insert(std::pair<int32_t, TLConstructedValue>((int32_t)0xffe3a208, value));
    }
    {
        TLConstructedValue value;
        value.type = TLConstructedValueTypePrimitiveInt32;
        value.primitive.int32Value = self.chat_big_size;
        values->insert(std::pair<int32_t, TLConstructedValue>((int32_t)0xbb094b49, value));
    }
    {
        TLConstructedValue value;
        value.type = TLConstructedValueTypePrimitiveInt32;
        value.primitive.int32Value = self.push_chat_period_ms;
        values->insert(std::pair<int32_t, TLConstructedValue>((int32_t)0x6755b26f, value));
    }
    {
        TLConstructedValue value;
        value.type = TLConstructedValueTypePrimitiveInt32;
        value.primitive.int32Value = self.push_chat_limit;
        values->insert(std::pair<int32_t, TLConstructedValue>((int32_t)0x68adc403, value));
    }
    {
        TLConstructedValue value;
        value.type = TLConstructedValueTypeVector;
        value.nativeObject = self.disabled_features;
        values->insert(std::pair<int32_t, TLConstructedValue>((int32_t)0x4f56c735, value));
    }
}


@end

