#import "TLPrivacyKey.h"

#import "../NSInputStream+TL.h"
#import "../NSOutputStream+TL.h"


@implementation TLPrivacyKey


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

@implementation TLPrivacyKey$privacyKeyStatusTimestamp : TLPrivacyKey


- (int32_t)TLconstructorSignature
{
    return (int32_t)0xbc2eab30;
}

- (int32_t)TLconstructorName
{
    return (int32_t)0x44f2ddc3;
}

- (id<TLObject>)TLbuildFromMetaObject:(std::shared_ptr<TLMetaObject>)__unused metaObject
{
    TLPrivacyKey$privacyKeyStatusTimestamp *object = [[TLPrivacyKey$privacyKeyStatusTimestamp alloc] init];
    return object;
}

- (void)TLfillFieldsWithValues:(std::map<int32_t, TLConstructedValue> *)__unused values
{
}


@end

@implementation TLPrivacyKey$privacyKeyChatInvite : TLPrivacyKey


- (int32_t)TLconstructorSignature
{
    return (int32_t)0x500e6dfa;
}

- (int32_t)TLconstructorName
{
    return (int32_t)0x481adf95;
}

- (id<TLObject>)TLbuildFromMetaObject:(std::shared_ptr<TLMetaObject>)__unused metaObject
{
    TLPrivacyKey$privacyKeyChatInvite *object = [[TLPrivacyKey$privacyKeyChatInvite alloc] init];
    return object;
}

- (void)TLfillFieldsWithValues:(std::map<int32_t, TLConstructedValue> *)__unused values
{
}


@end

@implementation TLPrivacyKey$privacyKeyPhoneCall : TLPrivacyKey


- (int32_t)TLconstructorSignature
{
    return (int32_t)0x3d662b7b;
}

- (int32_t)TLconstructorName
{
    return (int32_t)0xda7dacf7;
}

- (id<TLObject>)TLbuildFromMetaObject:(std::shared_ptr<TLMetaObject>)__unused metaObject
{
    TLPrivacyKey$privacyKeyPhoneCall *object = [[TLPrivacyKey$privacyKeyPhoneCall alloc] init];
    return object;
}

- (void)TLfillFieldsWithValues:(std::map<int32_t, TLConstructedValue> *)__unused values
{
}


@end

