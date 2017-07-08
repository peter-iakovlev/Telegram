#import "TLRPCaccount_updatePasswordSettings.h"

#import "../NSInputStream+TL.h"
#import "../NSOutputStream+TL.h"

#import "TLaccount_PasswordInputSettings.h"

@implementation TLRPCaccount_updatePasswordSettings


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

@implementation TLRPCaccount_updatePasswordSettings$account_updatePasswordSettings : TLRPCaccount_updatePasswordSettings


- (int32_t)TLconstructorSignature
{
    return (int32_t)0xfa7c4b86;
}

- (int32_t)TLconstructorName
{
    return (int32_t)0x6dd689a2;
}

- (id<TLObject>)TLbuildFromMetaObject:(std::shared_ptr<TLMetaObject>)metaObject
{
    TLRPCaccount_updatePasswordSettings$account_updatePasswordSettings *object = [[TLRPCaccount_updatePasswordSettings$account_updatePasswordSettings alloc] init];
    object.current_password_hash = metaObject->getBytes((int32_t)0x92cb9b0f);
    object.n_new_settings = metaObject->getObject((int32_t)0xbbcb0183);
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
        value.type = TLConstructedValueTypeObject;
        value.nativeObject = self.n_new_settings;
        values->insert(std::pair<int32_t, TLConstructedValue>((int32_t)0xbbcb0183, value));
    }
}


@end

