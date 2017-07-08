#import "TLRPCauth_checkPassword.h"

#import "../NSInputStream+TL.h"
#import "../NSOutputStream+TL.h"

#import "TLauth_Authorization.h"

@implementation TLRPCauth_checkPassword


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

@implementation TLRPCauth_checkPassword$auth_checkPassword : TLRPCauth_checkPassword


- (int32_t)TLconstructorSignature
{
    return (int32_t)0xa63011e;
}

- (int32_t)TLconstructorName
{
    return (int32_t)0xdb1254c3;
}

- (id<TLObject>)TLbuildFromMetaObject:(std::shared_ptr<TLMetaObject>)metaObject
{
    TLRPCauth_checkPassword$auth_checkPassword *object = [[TLRPCauth_checkPassword$auth_checkPassword alloc] init];
    object.password_hash = metaObject->getBytes((int32_t)0xeb3dbe1);
    return object;
}

- (void)TLfillFieldsWithValues:(std::map<int32_t, TLConstructedValue> *)values
{
    {
        TLConstructedValue value;
        value.type = TLConstructedValueTypeBytes;
        value.nativeObject = self.password_hash;
        values->insert(std::pair<int32_t, TLConstructedValue>((int32_t)0xeb3dbe1, value));
    }
}


@end

