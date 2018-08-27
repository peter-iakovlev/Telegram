#import "TLSecureRequiredType.h"

@implementation TLSecureRequiredType

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

@implementation TLSecureRequiredType$secureRequiredType : TLSecureRequiredType


- (int32_t)TLconstructorSignature
{
    return (int32_t)0x829d99da;
}

- (int32_t)TLconstructorName
{
    return (int32_t)0x63e2a3d6;
}

- (id<TLObject>)TLbuildFromMetaObject:(std::shared_ptr<TLMetaObject>)metaObject
{
    TLSecureRequiredType$secureRequiredType *object = [[TLSecureRequiredType$secureRequiredType alloc] init];
    object.flags = metaObject->getInt32((int32_t)0x81915c23);
    object.type = metaObject->getObject((int32_t)0x9211ab0a);
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
        value.nativeObject = self.type;
        values->insert(std::pair<int32_t, TLConstructedValue>((int32_t)0x9211ab0a, value));
    }
}


@end

@implementation TLSecureRequiredType$secureRequiredTypeOneOf : TLSecureRequiredType


- (int32_t)TLconstructorSignature
{
    return (int32_t)0x27477b4;
}

- (int32_t)TLconstructorName
{
    return (int32_t)0x1034479a;
}

- (id<TLObject>)TLbuildFromMetaObject:(std::shared_ptr<TLMetaObject>)metaObject
{
    TLSecureRequiredType$secureRequiredTypeOneOf *object = [[TLSecureRequiredType$secureRequiredTypeOneOf alloc] init];
    object.types = metaObject->getArray((int32_t)0x32251ae0);
    return object;
}

- (void)TLfillFieldsWithValues:(std::map<int32_t, TLConstructedValue> *)values
{
    {
        TLConstructedValue value;
        value.type = TLConstructedValueTypeVector;
        value.nativeObject = self.types;
        values->insert(std::pair<int32_t, TLConstructedValue>((int32_t)0x32251ae0, value));
    }
}


@end
