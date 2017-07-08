#import "TLRPCaccount_getAuthorizations.h"

#import "../NSInputStream+TL.h"
#import "../NSOutputStream+TL.h"

#import "TLaccount_Authorizations.h"

@implementation TLRPCaccount_getAuthorizations


- (Class)responseClass
{
    return [TLaccount_Authorizations class];
}

- (int)impliedResponseSignature
{
    return (int)0x1250abde;
}

- (int)layerVersion
{
    return 26;
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

@implementation TLRPCaccount_getAuthorizations$account_getAuthorizations : TLRPCaccount_getAuthorizations


- (int32_t)TLconstructorSignature
{
    return (int32_t)0xe320c158;
}

- (int32_t)TLconstructorName
{
    return (int32_t)0xb28a0f5b;
}

- (id<TLObject>)TLbuildFromMetaObject:(std::shared_ptr<TLMetaObject>)__unused metaObject
{
    TLRPCaccount_getAuthorizations$account_getAuthorizations *object = [[TLRPCaccount_getAuthorizations$account_getAuthorizations alloc] init];
    return object;
}

- (void)TLfillFieldsWithValues:(std::map<int32_t, TLConstructedValue> *)__unused values
{
}


@end

