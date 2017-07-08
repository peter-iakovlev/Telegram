#import "TLRPCaccount_setPrivacy.h"

#import "../NSInputStream+TL.h"
#import "../NSOutputStream+TL.h"

#import "TLInputPrivacyKey.h"
#import "TLaccount_PrivacyRules.h"

@implementation TLRPCaccount_setPrivacy


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

@implementation TLRPCaccount_setPrivacy$account_setPrivacy : TLRPCaccount_setPrivacy


- (int32_t)TLconstructorSignature
{
    return (int32_t)0xc9f81ce8;
}

- (int32_t)TLconstructorName
{
    return (int32_t)0x9d958687;
}

- (id<TLObject>)TLbuildFromMetaObject:(std::shared_ptr<TLMetaObject>)metaObject
{
    TLRPCaccount_setPrivacy$account_setPrivacy *object = [[TLRPCaccount_setPrivacy$account_setPrivacy alloc] init];
    object.key = metaObject->getObject((int32_t)0x6d6f838d);
    object.rules = metaObject->getArray((int32_t)0x2aa6cca);
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
    {
        TLConstructedValue value;
        value.type = TLConstructedValueTypeVector;
        value.nativeObject = self.rules;
        values->insert(std::pair<int32_t, TLConstructedValue>((int32_t)0x2aa6cca, value));
    }
}


@end

