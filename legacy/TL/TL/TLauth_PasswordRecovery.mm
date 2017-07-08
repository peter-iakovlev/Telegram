#import "TLauth_PasswordRecovery.h"

#import "../NSInputStream+TL.h"
#import "../NSOutputStream+TL.h"


@implementation TLauth_PasswordRecovery


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

@implementation TLauth_PasswordRecovery$auth_passwordRecovery : TLauth_PasswordRecovery


- (int32_t)TLconstructorSignature
{
    return (int32_t)0x137948a5;
}

- (int32_t)TLconstructorName
{
    return (int32_t)0xa314075d;
}

- (id<TLObject>)TLbuildFromMetaObject:(std::shared_ptr<TLMetaObject>)metaObject
{
    TLauth_PasswordRecovery$auth_passwordRecovery *object = [[TLauth_PasswordRecovery$auth_passwordRecovery alloc] init];
    object.email_pattern = metaObject->getString((int32_t)0x2499ca21);
    return object;
}

- (void)TLfillFieldsWithValues:(std::map<int32_t, TLConstructedValue> *)values
{
    {
        TLConstructedValue value;
        value.type = TLConstructedValueTypeString;
        value.nativeObject = self.email_pattern;
        values->insert(std::pair<int32_t, TLConstructedValue>((int32_t)0x2499ca21, value));
    }
}


@end

