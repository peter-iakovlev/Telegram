#import "TLRPCauth_resetAccountPassword.h"

#import "../NSInputStream+TL.h"
#import "../NSOutputStream+TL.h"

#import "TLauth_Authorization.h"

@implementation TLRPCauth_resetAccountPassword


- (Class)responseClass
{
    return [TLauth_Authorization class];
}

- (int)impliedResponseSignature
{
    return (int)0xb1937d19;
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

@implementation TLRPCauth_resetAccountPassword$auth_resetAccountPassword : TLRPCauth_resetAccountPassword


- (int32_t)TLconstructorSignature
{
    return (int32_t)0xb68929bf;
}

- (int32_t)TLconstructorName
{
    return (int32_t)0xc001ddc3;
}

- (id<TLObject>)TLbuildFromMetaObject:(std::shared_ptr<TLMetaObject>)metaObject
{
    TLRPCauth_resetAccountPassword$auth_resetAccountPassword *object = [[TLRPCauth_resetAccountPassword$auth_resetAccountPassword alloc] init];
    object.first_name = metaObject->getString((int32_t)0xa604f05d);
    object.last_name = metaObject->getString((int32_t)0x10662e0e);
    return object;
}

- (void)TLfillFieldsWithValues:(std::map<int32_t, TLConstructedValue> *)values
{
    {
        TLConstructedValue value;
        value.type = TLConstructedValueTypeString;
        value.nativeObject = self.first_name;
        values->insert(std::pair<int32_t, TLConstructedValue>((int32_t)0xa604f05d, value));
    }
    {
        TLConstructedValue value;
        value.type = TLConstructedValueTypeString;
        value.nativeObject = self.last_name;
        values->insert(std::pair<int32_t, TLConstructedValue>((int32_t)0x10662e0e, value));
    }
}


@end

