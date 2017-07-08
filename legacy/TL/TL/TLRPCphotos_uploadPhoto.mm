#import "TLRPCphotos_uploadPhoto.h"

#import "../NSInputStream+TL.h"
#import "../NSOutputStream+TL.h"

#import "TLInputFile.h"
#import "TLInputGeoPoint.h"
#import "TLphotos_Photo.h"

@implementation TLRPCphotos_uploadPhoto


- (Class)responseClass
{
    return [TLphotos_Photo class];
}

- (int)impliedResponseSignature
{
    return (int)0x20212ca8;
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

@implementation TLRPCphotos_uploadPhoto$photos_uploadPhoto : TLRPCphotos_uploadPhoto


- (int32_t)TLconstructorSignature
{
    return (int32_t)0x9b5965ae;
}

- (int32_t)TLconstructorName
{
    return (int32_t)0x947b2a4d;
}

- (id<TLObject>)TLbuildFromMetaObject:(std::shared_ptr<TLMetaObject>)metaObject
{
    TLRPCphotos_uploadPhoto$photos_uploadPhoto *object = [[TLRPCphotos_uploadPhoto$photos_uploadPhoto alloc] init];
    object.file = metaObject->getObject((int32_t)0x3187ec9);
    object.caption = metaObject->getString((int32_t)0x9bcfcf5a);
    object.geo_point = metaObject->getObject((int32_t)0xa4670371);
    return object;
}

- (void)TLfillFieldsWithValues:(std::map<int32_t, TLConstructedValue> *)values
{
    {
        TLConstructedValue value;
        value.type = TLConstructedValueTypeObject;
        value.nativeObject = self.file;
        values->insert(std::pair<int32_t, TLConstructedValue>((int32_t)0x3187ec9, value));
    }
    {
        TLConstructedValue value;
        value.type = TLConstructedValueTypeString;
        value.nativeObject = self.caption;
        values->insert(std::pair<int32_t, TLConstructedValue>((int32_t)0x9bcfcf5a, value));
    }
    {
        TLConstructedValue value;
        value.type = TLConstructedValueTypeObject;
        value.nativeObject = self.geo_point;
        values->insert(std::pair<int32_t, TLConstructedValue>((int32_t)0xa4670371, value));
    }
}


@end

