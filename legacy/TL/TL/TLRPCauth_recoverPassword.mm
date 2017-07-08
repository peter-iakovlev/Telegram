#import "TLRPCauth_recoverPassword.h"

#import "../NSInputStream+TL.h"
#import "../NSOutputStream+TL.h"

#import "TLauth_Authorization.h"

@implementation TLRPCauth_recoverPassword


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

@implementation TLRPCauth_recoverPassword$auth_recoverPassword : TLRPCauth_recoverPassword


- (int32_t)TLconstructorSignature
{
    return (int32_t)0x4ea56e92;
}

- (int32_t)TLconstructorName
{
    return (int32_t)0xbaf9c23a;
}

- (id<TLObject>)TLbuildFromMetaObject:(std::shared_ptr<TLMetaObject>)metaObject
{
    TLRPCauth_recoverPassword$auth_recoverPassword *object = [[TLRPCauth_recoverPassword$auth_recoverPassword alloc] init];
    object.code = metaObject->getString((int32_t)0x806ab544);
    return object;
}

- (void)TLfillFieldsWithValues:(std::map<int32_t, TLConstructedValue> *)values
{
    {
        TLConstructedValue value;
        value.type = TLConstructedValueTypeString;
        value.nativeObject = self.code;
        values->insert(std::pair<int32_t, TLConstructedValue>((int32_t)0x806ab544, value));
    }
}


@end

