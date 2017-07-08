#import "TLInputPrivacyKey.h"

#import "../NSInputStream+TL.h"
#import "../NSOutputStream+TL.h"


@implementation TLInputPrivacyKey


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

@implementation TLInputPrivacyKey$inputPrivacyKeyStatusTimestamp : TLInputPrivacyKey


- (int32_t)TLconstructorSignature
{
    return (int32_t)0x4f96cb18;
}

- (int32_t)TLconstructorName
{
    return (int32_t)0x364e966f;
}

- (id<TLObject>)TLbuildFromMetaObject:(std::shared_ptr<TLMetaObject>)__unused metaObject
{
    TLInputPrivacyKey$inputPrivacyKeyStatusTimestamp *object = [[TLInputPrivacyKey$inputPrivacyKeyStatusTimestamp alloc] init];
    return object;
}

- (void)TLfillFieldsWithValues:(std::map<int32_t, TLConstructedValue> *)__unused values
{
}


@end

@implementation TLInputPrivacyKey$inputPrivacyKeyChatInvite : TLInputPrivacyKey


- (int32_t)TLconstructorSignature
{
    return (int32_t)0xbdfb0426;
}

- (int32_t)TLconstructorName
{
    return (int32_t)0x60d4dc4b;
}

- (id<TLObject>)TLbuildFromMetaObject:(std::shared_ptr<TLMetaObject>)__unused metaObject
{
    TLInputPrivacyKey$inputPrivacyKeyChatInvite *object = [[TLInputPrivacyKey$inputPrivacyKeyChatInvite alloc] init];
    return object;
}

- (void)TLfillFieldsWithValues:(std::map<int32_t, TLConstructedValue> *)__unused values
{
}


@end

@implementation TLInputPrivacyKey$inputPrivacyKeyPhoneCall : TLInputPrivacyKey


- (int32_t)TLconstructorSignature
{
    return (int32_t)0xfabadc5f;
}

- (int32_t)TLconstructorName
{
    return (int32_t)0x6c3f60ce;
}

- (id<TLObject>)TLbuildFromMetaObject:(std::shared_ptr<TLMetaObject>)__unused metaObject
{
    TLInputPrivacyKey$inputPrivacyKeyPhoneCall *object = [[TLInputPrivacyKey$inputPrivacyKeyPhoneCall alloc] init];
    return object;
}

- (void)TLfillFieldsWithValues:(std::map<int32_t, TLConstructedValue> *)__unused values
{
}


@end

