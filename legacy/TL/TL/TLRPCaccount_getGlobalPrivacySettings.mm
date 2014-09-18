#import "TLRPCaccount_getGlobalPrivacySettings.h"

#import "../NSInputStream+TL.h"
#import "../NSOutputStream+TL.h"

#import "TLGlobalPrivacySettings.h"

@implementation TLRPCaccount_getGlobalPrivacySettings


- (Class)responseClass
{
    return [TLGlobalPrivacySettings class];
}

- (int)impliedResponseSignature
{
    return (int)0x40f5c53a;
}

- (int)layerVersion
{
    return 8;
}

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

- (id<TLObject>)TLbuildFromMetaObject:(std::tr1::shared_ptr<TLMetaObject>)__unused metaObject
{
    TGLog(@"TLbuildFromMetaObject is not implemented for base type");
    return nil;
}

- (void)TLfillFieldsWithValues:(std::map<int32_t, TLConstructedValue> *)__unused values
{
    TGLog(@"TLfillFieldsWithValues is not implemented for base type");
}


@end

@implementation TLRPCaccount_getGlobalPrivacySettings$account_getGlobalPrivacySettings : TLRPCaccount_getGlobalPrivacySettings


- (int32_t)TLconstructorSignature
{
    return (int32_t)0xeb2b4cf6;
}

- (int32_t)TLconstructorName
{
    return (int32_t)0x4b73d4fc;
}

- (id<TLObject>)TLbuildFromMetaObject:(std::tr1::shared_ptr<TLMetaObject>)__unused metaObject
{
    TLRPCaccount_getGlobalPrivacySettings$account_getGlobalPrivacySettings *object = [[TLRPCaccount_getGlobalPrivacySettings$account_getGlobalPrivacySettings alloc] init];
    return object;
}

- (void)TLfillFieldsWithValues:(std::map<int32_t, TLConstructedValue> *)__unused values
{
}


@end

