#import "TLSecurePasswordKdfAlgo.h"

@implementation TLSecurePasswordKdfAlgo

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

@implementation TLSecurePasswordKdfAlgo$securePasswordKdfAlgoUnknown : TLSecurePasswordKdfAlgo

- (int32_t)TLconstructorSignature
{
    return (int32_t)0x4a8537;
}

- (int32_t)TLconstructorName
{
    return (int32_t)0x825eed19;
}

- (id<TLObject>)TLbuildFromMetaObject:(std::shared_ptr<TLMetaObject>)__unused metaObject
{
    TLSecurePasswordKdfAlgo$securePasswordKdfAlgoUnknown *object = [[TLSecurePasswordKdfAlgo$securePasswordKdfAlgoUnknown alloc] init];
    return object;
}

- (void)TLfillFieldsWithValues:(std::map<int32_t, TLConstructedValue> *)__unused values
{
}


@end

@implementation TLSecurePasswordKdfAlgo$securePasswordKdfAlgoPBKDF2HMACSHA512iter100000 : TLSecurePasswordKdfAlgo

- (int32_t)TLconstructorSignature
{
    return (int32_t)0xbbf2dda0;
}

- (int32_t)TLconstructorName
{
    return (int32_t)0x8a4dc260;
}

- (id<TLObject>)TLbuildFromMetaObject:(std::shared_ptr<TLMetaObject>)metaObject
{
    TLSecurePasswordKdfAlgo$securePasswordKdfAlgoPBKDF2HMACSHA512iter100000 *object = [[TLSecurePasswordKdfAlgo$securePasswordKdfAlgoPBKDF2HMACSHA512iter100000 alloc] init];
    object.salt = metaObject->getBytes((int32_t)0x9cda6869);
    return object;
}

- (void)TLfillFieldsWithValues:(std::map<int32_t, TLConstructedValue> *)values
{
    {
        TLConstructedValue value;
        value.type = TLConstructedValueTypeBytes;
        value.nativeObject = self.salt;
        values->insert(std::pair<int32_t, TLConstructedValue>((int32_t)0x9cda6869, value));
    }
}


@end

@implementation TLSecurePasswordKdfAlgo$securePasswordKdfAlgoSHA512 : TLSecurePasswordKdfAlgo

- (int32_t)TLconstructorSignature
{
    return (int32_t)0x86471d92;
}

- (int32_t)TLconstructorName
{
    return (int32_t)0xf2d6f3d6;
}

- (id<TLObject>)TLbuildFromMetaObject:(std::shared_ptr<TLMetaObject>)metaObject
{
    TLSecurePasswordKdfAlgo$securePasswordKdfAlgoSHA512 *object = [[TLSecurePasswordKdfAlgo$securePasswordKdfAlgoSHA512 alloc] init];
    object.salt = metaObject->getBytes((int32_t)0x9cda6869);
    return object;
}

- (void)TLfillFieldsWithValues:(std::map<int32_t, TLConstructedValue> *)values
{
    {
        TLConstructedValue value;
        value.type = TLConstructedValueTypeBytes;
        value.nativeObject = self.salt;
        values->insert(std::pair<int32_t, TLConstructedValue>((int32_t)0x9cda6869, value));
    }
}


@end
