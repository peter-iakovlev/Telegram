#import "TLRPCaccount_getAccountTTL.h"

#import "../NSInputStream+TL.h"
#import "../NSOutputStream+TL.h"

#import "TLAccountDaysTTL.h"

@implementation TLRPCaccount_getAccountTTL


- (Class)responseClass
{
    return [TLAccountDaysTTL class];
}

- (int)impliedResponseSignature
{
    return (int)0xb8d0afdf;
}

- (int)layerVersion
{
    return 19;
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

@implementation TLRPCaccount_getAccountTTL$account_getAccountTTL : TLRPCaccount_getAccountTTL


- (int32_t)TLconstructorSignature
{
    return (int32_t)0x8fc711d;
}

- (int32_t)TLconstructorName
{
    return (int32_t)0x595d640d;
}

- (id<TLObject>)TLbuildFromMetaObject:(std::shared_ptr<TLMetaObject>)__unused metaObject
{
    TLRPCaccount_getAccountTTL$account_getAccountTTL *object = [[TLRPCaccount_getAccountTTL$account_getAccountTTL alloc] init];
    return object;
}

- (void)TLfillFieldsWithValues:(std::map<int32_t, TLConstructedValue> *)__unused values
{
}


@end

