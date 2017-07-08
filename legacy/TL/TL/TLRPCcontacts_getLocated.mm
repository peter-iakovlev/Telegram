#import "TLRPCcontacts_getLocated.h"

#import "../NSInputStream+TL.h"
#import "../NSOutputStream+TL.h"

#import "TLInputGeoPoint.h"
#import "TLcontacts_Located.h"

@implementation TLRPCcontacts_getLocated


- (Class)responseClass
{
    return [TLcontacts_Located class];
}

- (int)impliedResponseSignature
{
    return (int)0xaad7f4a7;
}

- (int)layerVersion
{
    return 8;
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

@implementation TLRPCcontacts_getLocated$contacts_getLocated : TLRPCcontacts_getLocated


- (int32_t)TLconstructorSignature
{
    return (int32_t)0x61b5827c;
}

- (int32_t)TLconstructorName
{
    return (int32_t)0xb01f0675;
}

- (id<TLObject>)TLbuildFromMetaObject:(std::shared_ptr<TLMetaObject>)metaObject
{
    TLRPCcontacts_getLocated$contacts_getLocated *object = [[TLRPCcontacts_getLocated$contacts_getLocated alloc] init];
    object.geo_point = metaObject->getObject((int32_t)0xa4670371);
    object.hidden = metaObject->getBool((int32_t)0x42a54c9f);
    object.radius = metaObject->getInt32((int32_t)0x90d29c8b);
    object.limit = metaObject->getInt32((int32_t)0xb8433fca);
    return object;
}

- (void)TLfillFieldsWithValues:(std::map<int32_t, TLConstructedValue> *)values
{
    {
        TLConstructedValue value;
        value.type = TLConstructedValueTypeObject;
        value.nativeObject = self.geo_point;
        values->insert(std::pair<int32_t, TLConstructedValue>((int32_t)0xa4670371, value));
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
        value.primitive.int32Value = self.radius;
        values->insert(std::pair<int32_t, TLConstructedValue>((int32_t)0x90d29c8b, value));
    }
    {
        TLConstructedValue value;
        value.type = TLConstructedValueTypePrimitiveInt32;
        value.primitive.int32Value = self.limit;
        values->insert(std::pair<int32_t, TLConstructedValue>((int32_t)0xb8433fca, value));
    }
}


@end

