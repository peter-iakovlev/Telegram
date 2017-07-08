#import "TLInputPrivacyRule.h"

#import "../NSInputStream+TL.h"
#import "../NSOutputStream+TL.h"


@implementation TLInputPrivacyRule


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

@implementation TLInputPrivacyRule$inputPrivacyValueAllowContacts : TLInputPrivacyRule


- (int32_t)TLconstructorSignature
{
    return (int32_t)0xd09e07b;
}

- (int32_t)TLconstructorName
{
    return (int32_t)0xfc107595;
}

- (id<TLObject>)TLbuildFromMetaObject:(std::shared_ptr<TLMetaObject>)__unused metaObject
{
    TLInputPrivacyRule$inputPrivacyValueAllowContacts *object = [[TLInputPrivacyRule$inputPrivacyValueAllowContacts alloc] init];
    return object;
}

- (void)TLfillFieldsWithValues:(std::map<int32_t, TLConstructedValue> *)__unused values
{
}


@end

@implementation TLInputPrivacyRule$inputPrivacyValueAllowAll : TLInputPrivacyRule


- (int32_t)TLconstructorSignature
{
    return (int32_t)0x184b35ce;
}

- (int32_t)TLconstructorName
{
    return (int32_t)0x21f0227f;
}

- (id<TLObject>)TLbuildFromMetaObject:(std::shared_ptr<TLMetaObject>)__unused metaObject
{
    TLInputPrivacyRule$inputPrivacyValueAllowAll *object = [[TLInputPrivacyRule$inputPrivacyValueAllowAll alloc] init];
    return object;
}

- (void)TLfillFieldsWithValues:(std::map<int32_t, TLConstructedValue> *)__unused values
{
}


@end

@implementation TLInputPrivacyRule$inputPrivacyValueAllowUsers : TLInputPrivacyRule


- (int32_t)TLconstructorSignature
{
    return (int32_t)0x131cc67f;
}

- (int32_t)TLconstructorName
{
    return (int32_t)0xa41cc9fa;
}

- (id<TLObject>)TLbuildFromMetaObject:(std::shared_ptr<TLMetaObject>)metaObject
{
    TLInputPrivacyRule$inputPrivacyValueAllowUsers *object = [[TLInputPrivacyRule$inputPrivacyValueAllowUsers alloc] init];
    object.users = metaObject->getArray((int32_t)0x933e5ff3);
    return object;
}

- (void)TLfillFieldsWithValues:(std::map<int32_t, TLConstructedValue> *)values
{
    {
        TLConstructedValue value;
        value.type = TLConstructedValueTypeVector;
        value.nativeObject = self.users;
        values->insert(std::pair<int32_t, TLConstructedValue>((int32_t)0x933e5ff3, value));
    }
}


@end

@implementation TLInputPrivacyRule$inputPrivacyValueDisallowContacts : TLInputPrivacyRule


- (int32_t)TLconstructorSignature
{
    return (int32_t)0xba52007;
}

- (int32_t)TLconstructorName
{
    return (int32_t)0x636ee2e7;
}

- (id<TLObject>)TLbuildFromMetaObject:(std::shared_ptr<TLMetaObject>)__unused metaObject
{
    TLInputPrivacyRule$inputPrivacyValueDisallowContacts *object = [[TLInputPrivacyRule$inputPrivacyValueDisallowContacts alloc] init];
    return object;
}

- (void)TLfillFieldsWithValues:(std::map<int32_t, TLConstructedValue> *)__unused values
{
}


@end

@implementation TLInputPrivacyRule$inputPrivacyValueDisallowAll : TLInputPrivacyRule


- (int32_t)TLconstructorSignature
{
    return (int32_t)0xd66b66c9;
}

- (int32_t)TLconstructorName
{
    return (int32_t)0x23ab6ca;
}

- (id<TLObject>)TLbuildFromMetaObject:(std::shared_ptr<TLMetaObject>)__unused metaObject
{
    TLInputPrivacyRule$inputPrivacyValueDisallowAll *object = [[TLInputPrivacyRule$inputPrivacyValueDisallowAll alloc] init];
    return object;
}

- (void)TLfillFieldsWithValues:(std::map<int32_t, TLConstructedValue> *)__unused values
{
}


@end

@implementation TLInputPrivacyRule$inputPrivacyValueDisallowUsers : TLInputPrivacyRule


- (int32_t)TLconstructorSignature
{
    return (int32_t)0x90110467;
}

- (int32_t)TLconstructorName
{
    return (int32_t)0x5cbd45c8;
}

- (id<TLObject>)TLbuildFromMetaObject:(std::shared_ptr<TLMetaObject>)metaObject
{
    TLInputPrivacyRule$inputPrivacyValueDisallowUsers *object = [[TLInputPrivacyRule$inputPrivacyValueDisallowUsers alloc] init];
    object.users = metaObject->getArray((int32_t)0x933e5ff3);
    return object;
}

- (void)TLfillFieldsWithValues:(std::map<int32_t, TLConstructedValue> *)values
{
    {
        TLConstructedValue value;
        value.type = TLConstructedValueTypeVector;
        value.nativeObject = self.users;
        values->insert(std::pair<int32_t, TLConstructedValue>((int32_t)0x933e5ff3, value));
    }
}


@end

