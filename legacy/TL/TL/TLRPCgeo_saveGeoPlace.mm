#import "TLRPCgeo_saveGeoPlace.h"

#import "../NSInputStream+TL.h"
#import "../NSOutputStream+TL.h"

#import "TLInputGeoPoint.h"
#import "TLInputGeoPlaceName.h"

@implementation TLRPCgeo_saveGeoPlace


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

@implementation TLRPCgeo_saveGeoPlace$geo_saveGeoPlace : TLRPCgeo_saveGeoPlace


- (int32_t)TLconstructorSignature
{
    return (int32_t)0x8efd01cc;
}

- (int32_t)TLconstructorName
{
    return (int32_t)0xe3c9b4dc;
}

- (id<TLObject>)TLbuildFromMetaObject:(std::shared_ptr<TLMetaObject>)metaObject
{
    TLRPCgeo_saveGeoPlace$geo_saveGeoPlace *object = [[TLRPCgeo_saveGeoPlace$geo_saveGeoPlace alloc] init];
    object.geo_point = metaObject->getObject((int32_t)0xa4670371);
    object.lang_code = metaObject->getString((int32_t)0x2ccfcaf3);
    object.place_name = metaObject->getObject((int32_t)0x1faf5cd7);
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
        value.type = TLConstructedValueTypeString;
        value.nativeObject = self.lang_code;
        values->insert(std::pair<int32_t, TLConstructedValue>((int32_t)0x2ccfcaf3, value));
    }
    {
        TLConstructedValue value;
        value.type = TLConstructedValueTypeObject;
        value.nativeObject = self.place_name;
        values->insert(std::pair<int32_t, TLConstructedValue>((int32_t)0x1faf5cd7, value));
    }
}


@end

