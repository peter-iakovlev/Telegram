#import "TLContactLocated.h"

#import "../NSInputStream+TL.h"
#import "../NSOutputStream+TL.h"

#import "TLGeoPoint.h"

@implementation TLContactLocated


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

@implementation TLContactLocated$contactLocated : TLContactLocated


- (int32_t)TLconstructorSignature
{
    return (int32_t)0xe144acaf;
}

- (int32_t)TLconstructorName
{
    return (int32_t)0x1ab68184;
}

- (id<TLObject>)TLbuildFromMetaObject:(std::shared_ptr<TLMetaObject>)metaObject
{
    TLContactLocated$contactLocated *object = [[TLContactLocated$contactLocated alloc] init];
    object.user_id = metaObject->getInt32((int32_t)0xafdf4073);
    object.location = metaObject->getObject((int32_t)0x504a1f06);
    object.date = metaObject->getInt32((int32_t)0xb76958ba);
    object.distance = metaObject->getInt32((int32_t)0xba1de8e4);
    return object;
}

- (void)TLfillFieldsWithValues:(std::map<int32_t, TLConstructedValue> *)values
{
    {
        TLConstructedValue value;
        value.type = TLConstructedValueTypePrimitiveInt32;
        value.primitive.int32Value = self.user_id;
        values->insert(std::pair<int32_t, TLConstructedValue>((int32_t)0xafdf4073, value));
    }
    {
        TLConstructedValue value;
        value.type = TLConstructedValueTypeObject;
        value.nativeObject = self.location;
        values->insert(std::pair<int32_t, TLConstructedValue>((int32_t)0x504a1f06, value));
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
        value.primitive.int32Value = self.distance;
        values->insert(std::pair<int32_t, TLConstructedValue>((int32_t)0xba1de8e4, value));
    }
}


@end

@implementation TLContactLocated$contactLocatedPreview : TLContactLocated


- (int32_t)TLconstructorSignature
{
    return (int32_t)0xc1257157;
}

- (int32_t)TLconstructorName
{
    return (int32_t)0x86dfd42d;
}

- (id<TLObject>)TLbuildFromMetaObject:(std::shared_ptr<TLMetaObject>)metaObject
{
    TLContactLocated$contactLocatedPreview *object = [[TLContactLocated$contactLocatedPreview alloc] init];
    object.n_hash = metaObject->getString((int32_t)0xc152e470);
    object.hidden = metaObject->getBool((int32_t)0x42a54c9f);
    object.date = metaObject->getInt32((int32_t)0xb76958ba);
    object.distance = metaObject->getInt32((int32_t)0xba1de8e4);
    return object;
}

- (void)TLfillFieldsWithValues:(std::map<int32_t, TLConstructedValue> *)values
{
    {
        TLConstructedValue value;
        value.type = TLConstructedValueTypeString;
        value.nativeObject = self.n_hash;
        values->insert(std::pair<int32_t, TLConstructedValue>((int32_t)0xc152e470, value));
    }
    {
        TLConstructedValue value;
        value.type = TLConstructedValueTypePrimitiveBool;
        value.primitive.boolValue = self.hidden;
        values->insert(std::pair<int32_t, TLConstructedValue>((int32_t)0x42a54c9f, value));
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
        value.primitive.int32Value = self.distance;
        values->insert(std::pair<int32_t, TLConstructedValue>((int32_t)0xba1de8e4, value));
    }
}


@end

