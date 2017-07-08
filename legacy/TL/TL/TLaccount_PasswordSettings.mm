#import "TLaccount_PasswordSettings.h"

#import "../NSInputStream+TL.h"
#import "../NSOutputStream+TL.h"


@implementation TLaccount_PasswordSettings


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

@implementation TLaccount_PasswordSettings$account_passwordSettings : TLaccount_PasswordSettings


- (int32_t)TLconstructorSignature
{
    return (int32_t)0xb7b72ab3;
}

- (int32_t)TLconstructorName
{
    return (int32_t)0x28bafaad;
}

- (id<TLObject>)TLbuildFromMetaObject:(std::shared_ptr<TLMetaObject>)metaObject
{
    TLaccount_PasswordSettings$account_passwordSettings *object = [[TLaccount_PasswordSettings$account_passwordSettings alloc] init];
    object.email = metaObject->getString((int32_t)0x5b2095e7);
    return object;
}

- (void)TLfillFieldsWithValues:(std::map<int32_t, TLConstructedValue> *)values
{
    {
        TLConstructedValue value;
        value.type = TLConstructedValueTypeString;
        value.nativeObject = self.email;
        values->insert(std::pair<int32_t, TLConstructedValue>((int32_t)0x5b2095e7, value));
    }
}


@end

