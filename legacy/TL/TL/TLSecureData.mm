#import "TLSecureData.h"

@implementation TLSecureData

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

@implementation TLSecureData$secureData : TLSecureData


- (int32_t)TLconstructorSignature
{
    return (int32_t)0x8aeabec3;
}

- (int32_t)TLconstructorName
{
    return (int32_t)0x52433039;
}

- (id<TLObject>)TLbuildFromMetaObject:(std::shared_ptr<TLMetaObject>)metaObject
{
    TLSecureData$secureData *object = [[TLSecureData$secureData alloc] init];
    object.data = metaObject->getBytes((int32_t)0xa361765d);
    object.data_hash = metaObject->getBytes((int32_t)0x6f8539a2);
    object.secret = metaObject->getBytes((int32_t)0x6706b4b7);
    return object;
}

- (void)TLfillFieldsWithValues:(std::map<int32_t, TLConstructedValue> *)values
{
    {
        TLConstructedValue value;
        value.type = TLConstructedValueTypeBytes;
        value.nativeObject = self.data;
        values->insert(std::pair<int32_t, TLConstructedValue>((int32_t)0xa361765d, value));
    }
    {
        TLConstructedValue value;
        value.type = TLConstructedValueTypeBytes;
        value.nativeObject = self.data_hash;
        values->insert(std::pair<int32_t, TLConstructedValue>((int32_t)0x6f8539a2, value));
    }
    {
        TLConstructedValue value;
        value.type = TLConstructedValueTypeBytes;
        value.nativeObject = self.secret;
        values->insert(std::pair<int32_t, TLConstructedValue>((int32_t)0x6706b4b7, value));
    }
}


@end

