#import "TLRPCaccount_setPassword.h"

#import "../NSInputStream+TL.h"
#import "../NSOutputStream+TL.h"


@implementation TLRPCaccount_setPassword


- (Class)responseClass
{
    return [NSNumber class];
}

- (int)impliedResponseSignature
{
    return 0;
}

- (int)layerVersion
{
    return 21;
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

@implementation TLRPCaccount_setPassword$account_setPassword : TLRPCaccount_setPassword


- (int32_t)TLconstructorSignature
{
    return (int32_t)0xdd2a4d8f;
}

- (int32_t)TLconstructorName
{
    return (int32_t)0xa9e71630;
}

- (id<TLObject>)TLbuildFromMetaObject:(std::shared_ptr<TLMetaObject>)metaObject
{
    TLRPCaccount_setPassword$account_setPassword *object = [[TLRPCaccount_setPassword$account_setPassword alloc] init];
    object.current_password_hash = metaObject->getBytes((int32_t)0x92cb9b0f);
    object.n_new_salt = metaObject->getBytes((int32_t)0x6b0fed36);
    object.n_new_password_hash = metaObject->getBytes((int32_t)0xfc571e23);
    object.hint = metaObject->getString((int32_t)0xb8a444ca);
    return object;
}

- (void)TLfillFieldsWithValues:(std::map<int32_t, TLConstructedValue> *)values
{
    {
        TLConstructedValue value;
        value.type = TLConstructedValueTypeBytes;
        value.nativeObject = self.current_password_hash;
        values->insert(std::pair<int32_t, TLConstructedValue>((int32_t)0x92cb9b0f, value));
    }
    {
        TLConstructedValue value;
        value.type = TLConstructedValueTypeBytes;
        value.nativeObject = self.n_new_salt;
        values->insert(std::pair<int32_t, TLConstructedValue>((int32_t)0x6b0fed36, value));
    }
    {
        TLConstructedValue value;
        value.type = TLConstructedValueTypeBytes;
        value.nativeObject = self.n_new_password_hash;
        values->insert(std::pair<int32_t, TLConstructedValue>((int32_t)0xfc571e23, value));
    }
    {
        TLConstructedValue value;
        value.type = TLConstructedValueTypeString;
        value.nativeObject = self.hint;
        values->insert(std::pair<int32_t, TLConstructedValue>((int32_t)0xb8a444ca, value));
    }
}


@end

