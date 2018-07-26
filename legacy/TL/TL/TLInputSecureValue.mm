#import "TLInputSecureValue.h"

@implementation TLInputSecureValue

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

@implementation TLInputSecureValue$inputSecureValueMeta : TLInputSecureValue


- (int32_t)TLconstructorSignature
{
    return (int32_t)0x94fa65b;
}

- (int32_t)TLconstructorName
{
    return (int32_t)0x23663ab1;
}

- (id<TLObject>)TLbuildFromMetaObject:(std::shared_ptr<TLMetaObject>)metaObject
{
    TLInputSecureValue$inputSecureValueMeta *object = [[TLInputSecureValue$inputSecureValueMeta alloc] init];
    object.data = metaObject->getObject((int32_t)0xa361765d);
    object.files = metaObject->getArray((int32_t)0x70c65335);
    return object;
}

- (void)TLfillFieldsWithValues:(std::map<int32_t, TLConstructedValue> *)values
{
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

