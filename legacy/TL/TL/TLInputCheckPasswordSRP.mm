#import "TLInputCheckPasswordSRP.h"

@implementation TLInputCheckPasswordSRP

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

@implementation TLInputCheckPasswordSRP$inputCheckPasswordSRP : TLInputCheckPasswordSRP


- (int32_t)TLconstructorSignature
{
    return (int32_t)0xd27ff082;
}

- (int32_t)TLconstructorName
{
    return (int32_t)0x4d9e32d1;
}

- (id<TLObject>)TLbuildFromMetaObject:(std::shared_ptr<TLMetaObject>)metaObject
{
    TLInputCheckPasswordSRP$inputCheckPasswordSRP *object = [[TLInputCheckPasswordSRP$inputCheckPasswordSRP alloc] init];
    object.srp_id = metaObject->getInt64((int32_t)0x0b686027);
    object.A = metaObject->getBytes((int32_t)0x217b21f3);
    object.M1 = metaObject->getBytes((int32_t)0x3fe0a3ba);
    return object;
}

- (void)TLfillFieldsWithValues:(std::map<int32_t, TLConstructedValue> *)values
{
    {
        TLConstructedValue value;
        value.type = TLConstructedValueTypePrimitiveInt64;
        value.primitive.int64Value = self.srp_id;
        values->insert(std::pair<int32_t, TLConstructedValue>((int32_t)0x0b686027, value));
    }
    {
        TLConstructedValue value;
        value.type = TLConstructedValueTypeBytes;
        value.nativeObject = self.A;
        values->insert(std::pair<int32_t, TLConstructedValue>((int32_t)0x217b21f3, value));
    }
    {
        TLConstructedValue value;
        value.type = TLConstructedValueTypeBytes;
        value.nativeObject = self.M1;
        values->insert(std::pair<int32_t, TLConstructedValue>((int32_t)0x3fe0a3ba, value));
    }
}


@end

@implementation TLInputCheckPasswordSRP$inputCheckPasswordEmpty : TLInputCheckPasswordSRP


- (int32_t)TLconstructorSignature
{
    return (int32_t)0x9880f658;
}

- (int32_t)TLconstructorName
{
    return (int32_t)0x80cec44a;
}

- (id<TLObject>)TLbuildFromMetaObject:(std::shared_ptr<TLMetaObject>)__unused metaObject
{
    TLInputCheckPasswordSRP$inputCheckPasswordEmpty *object = [[TLInputCheckPasswordSRP$inputCheckPasswordEmpty alloc] init];
    return object;
}

- (void)TLfillFieldsWithValues:(std::map<int32_t, TLConstructedValue> *)__unused values
{
}


@end

