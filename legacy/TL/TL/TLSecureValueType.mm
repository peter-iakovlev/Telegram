#import "TLSecureValueType.h"

@implementation TLSecureValueType

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

@implementation TLSecureValueType$secureValueTypePersonalDetails : TLSecureValueType


- (int32_t)TLconstructorSignature
{
    return (int32_t)0x9d2a81e3;
}

- (int32_t)TLconstructorName
{
    return (int32_t)0x6777387a;
}

- (id<TLObject>)TLbuildFromMetaObject:(std::shared_ptr<TLMetaObject>)__unused metaObject
{
    TLSecureValueType$secureValueTypePersonalDetails *object = [[TLSecureValueType$secureValueTypePersonalDetails alloc] init];
    return object;
}

- (void)TLfillFieldsWithValues:(std::map<int32_t, TLConstructedValue> *)__unused values
{
}


@end

@implementation TLSecureValueType$secureValueTypePassport : TLSecureValueType


- (int32_t)TLconstructorSignature
{
    return (int32_t)0x3dac6a00;
}

- (int32_t)TLconstructorName
{
    return (int32_t)0x1e8abd97;
}

- (id<TLObject>)TLbuildFromMetaObject:(std::shared_ptr<TLMetaObject>)__unused metaObject
{
    TLSecureValueType$secureValueTypePassport *object = [[TLSecureValueType$secureValueTypePassport alloc] init];
    return object;
}

- (void)TLfillFieldsWithValues:(std::map<int32_t, TLConstructedValue> *)__unused values
{
}


@end

@implementation TLSecureValueType$secureValueTypeDriverLicense : TLSecureValueType


- (int32_t)TLconstructorSignature
{
    return (int32_t)0x6e425c4;
}

- (int32_t)TLconstructorName
{
    return (int32_t)0x8580ba55;
}

- (id<TLObject>)TLbuildFromMetaObject:(std::shared_ptr<TLMetaObject>)__unused metaObject
{
    TLSecureValueType$secureValueTypeDriverLicense *object = [[TLSecureValueType$secureValueTypeDriverLicense alloc] init];
    return object;
}

- (void)TLfillFieldsWithValues:(std::map<int32_t, TLConstructedValue> *)__unused values
{
}


@end

@implementation TLSecureValueType$secureValueTypeIdentityCard : TLSecureValueType


- (int32_t)TLconstructorSignature
{
    return (int32_t)0xa0d0744b;
}

- (int32_t)TLconstructorName
{
    return (int32_t)0x36a8e579;
}

- (id<TLObject>)TLbuildFromMetaObject:(std::shared_ptr<TLMetaObject>)__unused metaObject
{
    TLSecureValueType$secureValueTypeIdentityCard *object = [[TLSecureValueType$secureValueTypeIdentityCard alloc] init];
    return object;
}

- (void)TLfillFieldsWithValues:(std::map<int32_t, TLConstructedValue> *)__unused values
{
}


@end

@implementation TLSecureValueType$secureValueTypeInternalPassport : TLSecureValueType


- (int32_t)TLconstructorSignature
{
    return (int32_t)0x99a48f23;
}

- (int32_t)TLconstructorName
{
    return (int32_t)0x1396b8da;
}

- (id<TLObject>)TLbuildFromMetaObject:(std::shared_ptr<TLMetaObject>)__unused metaObject
{
    TLSecureValueType$secureValueTypeInternalPassport *object = [[TLSecureValueType$secureValueTypeInternalPassport alloc] init];
    return object;
}

- (void)TLfillFieldsWithValues:(std::map<int32_t, TLConstructedValue> *)__unused values
{
}


@end

@implementation TLSecureValueType$secureValueTypeAddress : TLSecureValueType


- (int32_t)TLconstructorSignature
{
    return (int32_t)0xcbe31e26;
}

- (int32_t)TLconstructorName
{
    return (int32_t)0x466f254d;
}

- (id<TLObject>)TLbuildFromMetaObject:(std::shared_ptr<TLMetaObject>)__unused metaObject
{
    TLSecureValueType$secureValueTypeAddress *object = [[TLSecureValueType$secureValueTypeAddress alloc] init];
    return object;
}

- (void)TLfillFieldsWithValues:(std::map<int32_t, TLConstructedValue> *)__unused values
{
}


@end

@implementation TLSecureValueType$secureValueTypeUtilityBill : TLSecureValueType


- (int32_t)TLconstructorSignature
{
    return (int32_t)0xfc36954e;
}

- (int32_t)TLconstructorName
{
    return (int32_t)0xe7e18435;
}

- (id<TLObject>)TLbuildFromMetaObject:(std::shared_ptr<TLMetaObject>)__unused metaObject
{
    TLSecureValueType$secureValueTypeUtilityBill *object = [[TLSecureValueType$secureValueTypeUtilityBill alloc] init];
    return object;
}

- (void)TLfillFieldsWithValues:(std::map<int32_t, TLConstructedValue> *)__unused values
{
}


@end

@implementation TLSecureValueType$secureValueTypeBankStatement : TLSecureValueType


- (int32_t)TLconstructorSignature
{
    return (int32_t)0x89137c0d;
}

- (int32_t)TLconstructorName
{
    return (int32_t)0x4e061e08;
}

- (id<TLObject>)TLbuildFromMetaObject:(std::shared_ptr<TLMetaObject>)__unused metaObject
{
    TLSecureValueType$secureValueTypeBankStatement *object = [[TLSecureValueType$secureValueTypeBankStatement alloc] init];
    return object;
}

- (void)TLfillFieldsWithValues:(std::map<int32_t, TLConstructedValue> *)__unused values
{
}


@end

@implementation TLSecureValueType$secureValueTypeRentalAgreement : TLSecureValueType


- (int32_t)TLconstructorSignature
{
    return (int32_t)0x8b883488;
}

- (int32_t)TLconstructorName
{
    return (int32_t)0xf4d49b3a;
}

- (id<TLObject>)TLbuildFromMetaObject:(std::shared_ptr<TLMetaObject>)__unused metaObject
{
    TLSecureValueType$secureValueTypeRentalAgreement *object = [[TLSecureValueType$secureValueTypeRentalAgreement alloc] init];
    return object;
}

- (void)TLfillFieldsWithValues:(std::map<int32_t, TLConstructedValue> *)__unused values
{
}


@end

@implementation TLSecureValueType$secureValueTypePassportRegistration : TLSecureValueType


- (int32_t)TLconstructorSignature
{
    return (int32_t)0x99e3806a;
}

- (int32_t)TLconstructorName
{
    return (int32_t)0x0ada3d50;
}

- (id<TLObject>)TLbuildFromMetaObject:(std::shared_ptr<TLMetaObject>)__unused metaObject
{
    TLSecureValueType$secureValueTypePassportRegistration *object = [[TLSecureValueType$secureValueTypePassportRegistration alloc] init];
    return object;
}

- (void)TLfillFieldsWithValues:(std::map<int32_t, TLConstructedValue> *)__unused values
{
}


@end

@implementation TLSecureValueType$secureValueTypeTemporaryRegistration : TLSecureValueType


- (int32_t)TLconstructorSignature
{
    return (int32_t)0xea02ec33;
}

- (int32_t)TLconstructorName
{
    return (int32_t)0xdd513fe7;
}

- (id<TLObject>)TLbuildFromMetaObject:(std::shared_ptr<TLMetaObject>)__unused metaObject
{
    TLSecureValueType$secureValueTypeTemporaryRegistration *object = [[TLSecureValueType$secureValueTypeTemporaryRegistration alloc] init];
    return object;
}

- (void)TLfillFieldsWithValues:(std::map<int32_t, TLConstructedValue> *)__unused values
{
}


@end

@implementation TLSecureValueType$secureValueTypePhone : TLSecureValueType


- (int32_t)TLconstructorSignature
{
    return (int32_t)0xb320aadb;
}

- (int32_t)TLconstructorName
{
    return (int32_t)0x8bd93562;
}

- (id<TLObject>)TLbuildFromMetaObject:(std::shared_ptr<TLMetaObject>)__unused metaObject
{
    TLSecureValueType$secureValueTypePhone *object = [[TLSecureValueType$secureValueTypePhone alloc] init];
    return object;
}

- (void)TLfillFieldsWithValues:(std::map<int32_t, TLConstructedValue> *)__unused values
{
}


@end

@implementation TLSecureValueType$secureValueTypeEmail : TLSecureValueType


- (int32_t)TLconstructorSignature
{
    return (int32_t)0x8e3ca7ee;
}

- (int32_t)TLconstructorName
{
    return (int32_t)0x7d899940;
}

- (id<TLObject>)TLbuildFromMetaObject:(std::shared_ptr<TLMetaObject>)__unused metaObject
{
    TLSecureValueType$secureValueTypeEmail *object = [[TLSecureValueType$secureValueTypeEmail alloc] init];
    return object;
}

- (void)TLfillFieldsWithValues:(std::map<int32_t, TLConstructedValue> *)__unused values
{
}


@end

