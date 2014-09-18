#import "TLRPCgeochats_getLocated.h"

#import "../NSInputStream+TL.h"
#import "../NSOutputStream+TL.h"

#import "TLInputGeoPoint.h"
#import "TLgeochats_Located.h"

@implementation TLRPCgeochats_getLocated


- (Class)responseClass
{
    return [TLgeochats_Located class];
}

- (int)impliedResponseSignature
{
    return (int)0x48feb267;
}

- (int)layerVersion
{
    return 4;
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

@implementation TLRPCgeochats_getLocated$geochats_getLocated : TLRPCgeochats_getLocated


- (int32_t)TLconstructorSignature
{
    return (int32_t)0x7f192d8f;
}

- (int32_t)TLconstructorName
{
    return (int32_t)0x5fc3595d;
}

- (id<TLObject>)TLbuildFromMetaObject:(std::tr1::shared_ptr<TLMetaObject>)metaObject
{
    TLRPCgeochats_getLocated$geochats_getLocated *object = [[TLRPCgeochats_getLocated$geochats_getLocated alloc] init];
    object.geo_point = metaObject->getObject((int32_t)0xa4670371);
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

