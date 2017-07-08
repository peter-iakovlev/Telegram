#import "TLRPCaccount_getPassword.h"

#import "../NSInputStream+TL.h"
#import "../NSOutputStream+TL.h"

#import "TLaccount_Password.h"

@implementation TLRPCaccount_getPassword


- (Class)responseClass
{
    return [TLaccount_Password class];
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

@implementation TLRPCaccount_getPassword$account_getPassword : TLRPCaccount_getPassword


- (int32_t)TLconstructorSignature
{
    return (int32_t)0x548a30f5;
}

- (int32_t)TLconstructorName
{
    return (int32_t)0x99c11e22;
}

- (id<TLObject>)TLbuildFromMetaObject:(std::shared_ptr<TLMetaObject>)__unused metaObject
{
    TLRPCaccount_getPassword$account_getPassword *object = [[TLRPCaccount_getPassword$account_getPassword alloc] init];
    return object;
}

- (void)TLfillFieldsWithValues:(std::map<int32_t, TLConstructedValue> *)__unused values
{
}


@end

