#import "TLSecureSecretSettings.h"

@implementation TLSecureSecretSettings

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

@implementation TLSecureSecretSettings$secureSecretSettings : TLSecureSecretSettings

- (int32_t)TLconstructorSignature
{
    return (int32_t)0x1527bcac;
}

- (int32_t)TLconstructorName
{
    return (int32_t)0x95c15cb1;
}

- (id<TLObject>)TLbuildFromMetaObject:(std::shared_ptr<TLMetaObject>)metaObject
{
    TLSecureSecretSettings$secureSecretSettings *object = [[TLSecureSecretSettings$secureSecretSettings alloc] init];
    object.secure_algo = metaObject->getObject((int32_t)0x8acbe9b7);
    object.secure_secret = metaObject->getBytes((int32_t)0x9f64911f);
    object.secure_secret_id = metaObject->getInt64((int32_t)0xfca1cb16);
    return object;
}

- (void)TLfillFieldsWithValues:(std::map<int32_t, TLConstructedValue> *)values
{
    {
        TLConstructedValue value;
        value.type = TLConstructedValueTypeObject;
        value.nativeObject = self.secure_algo;
        values->insert(std::pair<int32_t, TLConstructedValue>((int32_t)0x8acbe9b7, value));
    }
    {
        TLConstructedValue value;
        value.type = TLConstructedValueTypeBytes;
        value.nativeObject = self.secure_secret;
        values->insert(std::pair<int32_t, TLConstructedValue>((int32_t)0x9f64911f, value));
    }
    {
        TLConstructedValue value;
        value.type = TLConstructedValueTypePrimitiveInt64;
        value.primitive.int64Value = self.secure_secret_id;
        values->insert(std::pair<int32_t, TLConstructedValue>((int32_t)0xfca1cb16, value));
    }
}


@end
