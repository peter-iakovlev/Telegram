#import "TLRPCauth_requestPasswordRecovery.h"

#import "../NSInputStream+TL.h"
#import "../NSOutputStream+TL.h"

#import "TLauth_PasswordRecovery.h"

@implementation TLRPCauth_requestPasswordRecovery


- (Class)responseClass
{
    return [TLauth_PasswordRecovery class];
}

- (int)impliedResponseSignature
{
    return (int)0x137948a5;
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

@implementation TLRPCauth_requestPasswordRecovery$auth_requestPasswordRecovery : TLRPCauth_requestPasswordRecovery


- (int32_t)TLconstructorSignature
{
    return (int32_t)0xd897bc66;
}

- (int32_t)TLconstructorName
{
    return (int32_t)0xc44309fe;
}

- (id<TLObject>)TLbuildFromMetaObject:(std::shared_ptr<TLMetaObject>)__unused metaObject
{
    TLRPCauth_requestPasswordRecovery$auth_requestPasswordRecovery *object = [[TLRPCauth_requestPasswordRecovery$auth_requestPasswordRecovery alloc] init];
    return object;
}

- (void)TLfillFieldsWithValues:(std::map<int32_t, TLConstructedValue> *)__unused values
{
}


@end

