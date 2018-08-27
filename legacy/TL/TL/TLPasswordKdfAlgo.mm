#import "TLPasswordKdfAlgo.h"

@implementation TLPasswordKdfAlgo

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

@implementation TLPasswordKdfAlgo$passwordKdfAlgoUnknown : TLPasswordKdfAlgo

- (int32_t)TLconstructorSignature
{
    return (int32_t)0xd45ab096;
}

- (int32_t)TLconstructorName
{
    return (int32_t)0x1b3fd618;
}

- (id<TLObject>)TLbuildFromMetaObject:(std::shared_ptr<TLMetaObject>)__unused metaObject
{
    TLPasswordKdfAlgo$passwordKdfAlgoUnknown *object = [[TLPasswordKdfAlgo$passwordKdfAlgoUnknown alloc] init];
    return object;
}

- (void)TLfillFieldsWithValues:(std::map<int32_t, TLConstructedValue> *)__unused values
{
}


@end

@implementation TLPasswordKdfAlgo$passwordKdfAlgoSHA256SHA256PBKDF2HMACSHA512iter100000SHA256ModPow : TLPasswordKdfAlgo

- (int32_t)TLconstructorSignature
{
    return (int32_t)0x3a912d4a;
}

- (int32_t)TLconstructorName
{
    return (int32_t)0xbfbd4719;
}

- (id<TLObject>)TLbuildFromMetaObject:(std::shared_ptr<TLMetaObject>)metaObject
{
    TLPasswordKdfAlgo$passwordKdfAlgoSHA256SHA256PBKDF2HMACSHA512iter100000SHA256ModPow *object = [[TLPasswordKdfAlgo$passwordKdfAlgoSHA256SHA256PBKDF2HMACSHA512iter100000SHA256ModPow alloc] init];
    object.salt1 = metaObject->getBytes((int32_t)0x7b7b7d07);
    object.salt2 = metaObject->getBytes((int32_t)0xe2d48f5c);
    object.g = metaObject->getInt32((int32_t)0x75e1067a);
    object.p = metaObject->getBytes((int32_t)0xb91d8925);
    return object;
}

- (void)TLfillFieldsWithValues:(std::map<int32_t, TLConstructedValue> *)values
{
    {
        TLConstructedValue value;
        value.type = TLConstructedValueTypeBytes;
        value.nativeObject = self.salt1;
        values->insert(std::pair<int32_t, TLConstructedValue>((int32_t)0x7b7b7d07, value));
    }
    {
        TLConstructedValue value;
        value.type = TLConstructedValueTypeBytes;
        value.nativeObject = self.salt2;
        values->insert(std::pair<int32_t, TLConstructedValue>((int32_t)0xe2d48f5c, value));
    }
    {
        TLConstructedValue value;
        value.type = TLConstructedValueTypePrimitiveInt32;
        value.primitive.int32Value = self.g;
        values->insert(std::pair<int32_t, TLConstructedValue>((int32_t)0x75e1067a, value));
    }
    {
        TLConstructedValue value;
        value.type = TLConstructedValueTypeBytes;
        value.nativeObject = self.p;
        values->insert(std::pair<int32_t, TLConstructedValue>((int32_t)0xb91d8925, value));
    }
}


@end
