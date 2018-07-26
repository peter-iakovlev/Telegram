#import "TLSecureValue.h"

@implementation TLSecureValue

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

@implementation TLSecureValue$secureValueMeta : TLSecureValue


- (int32_t)TLconstructorSignature
{
    return (int32_t)0xec4134c8;
}

- (int32_t)TLconstructorName
{
    return (int32_t)0x6593964b;
}

- (id<TLObject>)TLbuildFromMetaObject:(std::shared_ptr<TLMetaObject>)metaObject
{
    TLSecureValue$secureValueMeta *object = [[TLSecureValue$secureValueMeta alloc] init];
    object.flags = metaObject->getInt32((int32_t)0x81915c23);
    object.data = metaObject->getObject((int32_t)0xa361765d);
    object.files = metaObject->getArray((int32_t)0x70c65335);
    return object;
}

- (void)TLfillFieldsWithValues:(std::map<int32_t, TLConstructedValue> *)values
{
    {
        TLConstructedValue value;
        value.type = TLConstructedValueTypePrimitiveInt32;
        value.primitive.int32Value = self.flags;
        values->insert(std::pair<int32_t, TLConstructedValue>((int32_t)0x81915c23, value));
    }
    {
        TLConstructedValue value;
        value.type = TLConstructedValueTypeObject;
        value.nativeObject = self.data;
        values->insert(std::pair<int32_t, TLConstructedValue>((int32_t)0xa361765d, value));
    }
    {
        TLConstructedValue value;
        value.type = TLConstructedValueTypeVector;
        value.nativeObject = self.files;
        values->insert(std::pair<int32_t, TLConstructedValue>((int32_t)0x70c65335, value));
    }
}


@end
