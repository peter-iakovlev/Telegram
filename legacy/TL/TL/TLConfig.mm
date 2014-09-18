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
    return (int32_t)0x2e54dd74;
}

- (int32_t)TLconstructorName
{
    return (int32_t)0x9167d250;
}

- (id<TLObject>)TLbuildFromMetaObject:(std::tr1::shared_ptr<TLMetaObject>)metaObject
{
    TLConfig$config *object = [[TLConfig$config alloc] init];
    object.date = metaObject->getInt32((int32_t)0xb76958ba);
    object.test_mode = metaObject->getBool((int32_t)0x1288ca35);
    object.this_dc = metaObject->getInt32((int32_t)0x1b29ec36);
    object.dc_options = metaObject->getArray((int32_t)0x25e6c768);
    object.chat_size_max = metaObject->getInt32((int32_t)0x95174295);
    object.broadcast_size_max = metaObject->getInt32((int32_t)0xe161a8ce);
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
}


@end

