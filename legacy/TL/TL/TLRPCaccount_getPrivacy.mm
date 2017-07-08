#import "TLRPCaccount_getPrivacy.h"

#import "../NSInputStream+TL.h"
#import "../NSOutputStream+TL.h"

#import "TLInputPrivacyKey.h"
#import "TLaccount_PrivacyRules.h"

@implementation TLRPCaccount_getPrivacy


- (Class)responseClass
{
    return [TLaccount_PrivacyRules class];
}

- (int)impliedResponseSignature
{
    return (int)0x554abb6f;
}

- (int)layerVersion
{
    return 19;
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

@implementation TLRPCaccount_getPrivacy$account_getPrivacy : TLRPCaccount_getPrivacy


- (int32_t)TLconstructorSignature
{
    return (int32_t)0xdadbc950;
}

- (int32_t)TLconstructorName
{
    return (int32_t)0x47cf378f;
}

- (id<TLObject>)TLbuildFromMetaObject:(std::shared_ptr<TLMetaObject>)metaObject
{
    TLRPCaccount_getPrivacy$account_getPrivacy *object = [[TLRPCaccount_getPrivacy$account_getPrivacy alloc] init];
    object.key = metaObject->getObject((int32_t)0x6d6f838d);
    return object;
}

- (void)TLfillFieldsWithValues:(std::map<int32_t, TLConstructedValue> *)values
{
    {
        TLConstructedValue value;
        value.type = TLConstructedValueTypeObject;
        value.nativeObject = self.key;
        values->insert(std::pair<int32_t, TLConstructedValue>((int32_t)0x6d6f838d, value));
    }
}


@end

