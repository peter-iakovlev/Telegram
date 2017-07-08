#import "TLPrivacyRule.h"

#import "../NSInputStream+TL.h"
#import "../NSOutputStream+TL.h"


@implementation TLPrivacyRule


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

@implementation TLPrivacyRule$privacyValueAllowContacts : TLPrivacyRule


- (int32_t)TLconstructorSignature
{
    return (int32_t)0xfffe1bac;
}

- (int32_t)TLconstructorName
{
    return (int32_t)0xeb9d8189;
}

- (id<TLObject>)TLbuildFromMetaObject:(std::shared_ptr<TLMetaObject>)__unused metaObject
{
    TLPrivacyRule$privacyValueAllowContacts *object = [[TLPrivacyRule$privacyValueAllowContacts alloc] init];
    return object;
}

- (void)TLfillFieldsWithValues:(std::map<int32_t, TLConstructedValue> *)__unused values
{
}


@end

@implementation TLPrivacyRule$privacyValueAllowAll : TLPrivacyRule


- (int32_t)TLconstructorSignature
{
    return (int32_t)0x65427b82;
}

- (int32_t)TLconstructorName
{
    return (int32_t)0x1c4faf84;
}

- (id<TLObject>)TLbuildFromMetaObject:(std::shared_ptr<TLMetaObject>)__unused metaObject
{
    TLPrivacyRule$privacyValueAllowAll *object = [[TLPrivacyRule$privacyValueAllowAll alloc] init];
    return object;
}

- (void)TLfillFieldsWithValues:(std::map<int32_t, TLConstructedValue> *)__unused values
{
}


@end

@implementation TLPrivacyRule$privacyValueAllowUsers : TLPrivacyRule


- (int32_t)TLconstructorSignature
{
    return (int32_t)0x4d5bbe0c;
}

- (int32_t)TLconstructorName
{
    return (int32_t)0x11fc301c;
}

- (id<TLObject>)TLbuildFromMetaObject:(std::shared_ptr<TLMetaObject>)metaObject
{
    TLPrivacyRule$privacyValueAllowUsers *object = [[TLPrivacyRule$privacyValueAllowUsers alloc] init];
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

@implementation TLPrivacyRule$privacyValueDisallowContacts : TLPrivacyRule


- (int32_t)TLconstructorSignature
{
    return (int32_t)0xf888fa1a;
}

- (int32_t)TLconstructorName
{
    return (int32_t)0xec102e9b;
}

- (id<TLObject>)TLbuildFromMetaObject:(std::shared_ptr<TLMetaObject>)__unused metaObject
{
    TLPrivacyRule$privacyValueDisallowContacts *object = [[TLPrivacyRule$privacyValueDisallowContacts alloc] init];
    return object;
}

- (void)TLfillFieldsWithValues:(std::map<int32_t, TLConstructedValue> *)__unused values
{
}


@end

@implementation TLPrivacyRule$privacyValueDisallowAll : TLPrivacyRule


- (int32_t)TLconstructorSignature
{
    return (int32_t)0x8b73e763;
}

- (int32_t)TLconstructorName
{
    return (int32_t)0x4219ce13;
}

- (id<TLObject>)TLbuildFromMetaObject:(std::shared_ptr<TLMetaObject>)__unused metaObject
{
    TLPrivacyRule$privacyValueDisallowAll *object = [[TLPrivacyRule$privacyValueDisallowAll alloc] init];
    return object;
}

- (void)TLfillFieldsWithValues:(std::map<int32_t, TLConstructedValue> *)__unused values
{
}


@end

@implementation TLPrivacyRule$privacyValueDisallowUsers : TLPrivacyRule


- (int32_t)TLconstructorSignature
{
    return (int32_t)0xc7f49b7;
}

- (int32_t)TLconstructorName
{
    return (int32_t)0x9c2b188b;
}

- (id<TLObject>)TLbuildFromMetaObject:(std::shared_ptr<TLMetaObject>)metaObject
{
    TLPrivacyRule$privacyValueDisallowUsers *object = [[TLPrivacyRule$privacyValueDisallowUsers alloc] init];
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

