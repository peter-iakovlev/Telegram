#import "TLGeoPoint.h"

#import "../NSInputStream+TL.h"
#import "../NSOutputStream+TL.h"

#import "TLGeoPlaceName.h"

@implementation TLGeoPoint


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

@implementation TLGeoPoint$geoPointEmpty : TLGeoPoint


- (int32_t)TLconstructorSignature
{
    return (int32_t)0x1117dd5f;
}

- (int32_t)TLconstructorName
{
    return (int32_t)0x8fc1c3ef;
}

- (id<TLObject>)TLbuildFromMetaObject:(std::shared_ptr<TLMetaObject>)__unused metaObject
{
    TLGeoPoint$geoPointEmpty *object = [[TLGeoPoint$geoPointEmpty alloc] init];
    return object;
}

- (void)TLfillFieldsWithValues:(std::map<int32_t, TLConstructedValue> *)__unused values
{
}


@end

@implementation TLGeoPoint$geoPoint : TLGeoPoint


- (int32_t)TLconstructorSignature
{
    return (int32_t)0x2049d70c;
}

- (int32_t)TLconstructorName
{
    return (int32_t)0x94efe0d2;
}

- (id<TLObject>)TLbuildFromMetaObject:(std::shared_ptr<TLMetaObject>)metaObject
{
    TLGeoPoint$geoPoint *object = [[TLGeoPoint$geoPoint alloc] init];
    object.n_long = metaObject->getDouble((int32_t)0x682f3647);
    object.lat = metaObject->getDouble((int32_t)0x8161c7a1);
    return object;
}

- (void)TLfillFieldsWithValues:(std::map<int32_t, TLConstructedValue> *)values
{
    {
        TLConstructedValue value;
        value.type = TLConstructedValueTypePrimitiveDouble;
        value.primitive.doubleValue = self.n_long;
        values->insert(std::pair<int32_t, TLConstructedValue>((int32_t)0x682f3647, value));
    }
    {
        TLConstructedValue value;
        value.type = TLConstructedValueTypePrimitiveDouble;
        value.primitive.doubleValue = self.lat;
        values->insert(std::pair<int32_t, TLConstructedValue>((int32_t)0x8161c7a1, value));
    }
}


@end

@implementation TLGeoPoint$geoPlace : TLGeoPoint


- (int32_t)TLconstructorSignature
{
    return (int32_t)0x6e9e21ca;
}

- (int32_t)TLconstructorName
{
    return (int32_t)0x65f82ade;
}

- (id<TLObject>)TLbuildFromMetaObject:(std::shared_ptr<TLMetaObject>)metaObject
{
    TLGeoPoint$geoPlace *object = [[TLGeoPoint$geoPlace alloc] init];
    object.n_long = metaObject->getDouble((int32_t)0x682f3647);
    object.lat = metaObject->getDouble((int32_t)0x8161c7a1);
    object.name = metaObject->getObject((int32_t)0x798b364a);
    return object;
}

- (void)TLfillFieldsWithValues:(std::map<int32_t, TLConstructedValue> *)values
{
    {
        TLConstructedValue value;
        value.type = TLConstructedValueTypePrimitiveDouble;
        value.primitive.doubleValue = self.n_long;
        values->insert(std::pair<int32_t, TLConstructedValue>((int32_t)0x682f3647, value));
    }
    {
        TLConstructedValue value;
        value.type = TLConstructedValueTypePrimitiveDouble;
        value.primitive.doubleValue = self.lat;
        values->insert(std::pair<int32_t, TLConstructedValue>((int32_t)0x8161c7a1, value));
    }
    {
        TLConstructedValue value;
        value.type = TLConstructedValueTypeObject;
        value.nativeObject = self.name;
        values->insert(std::pair<int32_t, TLConstructedValue>((int32_t)0x798b364a, value));
    }
}


@end

