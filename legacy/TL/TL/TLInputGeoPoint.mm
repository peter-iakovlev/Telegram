#import "TLInputGeoPoint.h"

#import "../NSInputStream+TL.h"
#import "../NSOutputStream+TL.h"


@implementation TLInputGeoPoint


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

@implementation TLInputGeoPoint$inputGeoPointEmpty : TLInputGeoPoint


- (int32_t)TLconstructorSignature
{
    return (int32_t)0xe4c123d6;
}

- (int32_t)TLconstructorName
{
    return (int32_t)0xbdde1e02;
}

- (id<TLObject>)TLbuildFromMetaObject:(std::shared_ptr<TLMetaObject>)__unused metaObject
{
    TLInputGeoPoint$inputGeoPointEmpty *object = [[TLInputGeoPoint$inputGeoPointEmpty alloc] init];
    return object;
}

- (void)TLfillFieldsWithValues:(std::map<int32_t, TLConstructedValue> *)__unused values
{
}


@end

@implementation TLInputGeoPoint$inputGeoPoint : TLInputGeoPoint


- (int32_t)TLconstructorSignature
{
    return (int32_t)0xf3b7acc9;
}

- (int32_t)TLconstructorName
{
    return (int32_t)0x90c5b4ec;
}

- (id<TLObject>)TLbuildFromMetaObject:(std::shared_ptr<TLMetaObject>)metaObject
{
    TLInputGeoPoint$inputGeoPoint *object = [[TLInputGeoPoint$inputGeoPoint alloc] init];
    object.lat = metaObject->getDouble((int32_t)0x8161c7a1);
    object.n_long = metaObject->getDouble((int32_t)0x682f3647);
    return object;
}

- (void)TLfillFieldsWithValues:(std::map<int32_t, TLConstructedValue> *)values
{
    {
        TLConstructedValue value;
        value.type = TLConstructedValueTypePrimitiveDouble;
        value.primitive.doubleValue = self.lat;
        values->insert(std::pair<int32_t, TLConstructedValue>((int32_t)0x8161c7a1, value));
    }
    {
        TLConstructedValue value;
        value.type = TLConstructedValueTypePrimitiveDouble;
        value.primitive.doubleValue = self.n_long;
        values->insert(std::pair<int32_t, TLConstructedValue>((int32_t)0x682f3647, value));
    }
}


@end

