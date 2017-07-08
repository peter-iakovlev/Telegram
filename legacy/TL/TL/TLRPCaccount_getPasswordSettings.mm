#import "TLRPCaccount_getPasswordSettings.h"

#import "../NSInputStream+TL.h"
#import "../NSOutputStream+TL.h"

#import "TLaccount_PasswordSettings.h"

@implementation TLRPCaccount_getPasswordSettings


- (Class)responseClass
{
    return [TLaccount_PasswordSettings class];
}

- (int)impliedResponseSignature
{
    return (int)0xb7b72ab3;
}

- (int)layerVersion
{
    return 27;
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

@implementation TLRPCaccount_getPasswordSettings$account_getPasswordSettings : TLRPCaccount_getPasswordSettings


- (int32_t)TLconstructorSignature
{
    return (int32_t)0xbc8d11bb;
}

- (int32_t)TLconstructorName
{
    return (int32_t)0x63e203c3;
}

- (id<TLObject>)TLbuildFromMetaObject:(std::shared_ptr<TLMetaObject>)metaObject
{
    TLRPCaccount_getPasswordSettings$account_getPasswordSettings *object = [[TLRPCaccount_getPasswordSettings$account_getPasswordSettings alloc] init];
    object.current_password_hash = metaObject->getBytes((int32_t)0x92cb9b0f);
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
}


@end

