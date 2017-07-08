#import "TLRPCphone_getDhConfig.h"

#import "../NSInputStream+TL.h"
#import "../NSOutputStream+TL.h"

#import "TLphone_DhConfig.h"

@implementation TLRPCphone_getDhConfig


- (Class)responseClass
{
    return [TLphone_DhConfig class];
}

- (int)impliedResponseSignature
{
    return (int)0x8a5d855e;
}

- (int)layerVersion
{
    return 8;
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

@implementation TLRPCphone_getDhConfig$phone_getDhConfig : TLRPCphone_getDhConfig


- (int32_t)TLconstructorSignature
{
    return (int32_t)0xc4721a8e;
}

- (int32_t)TLconstructorName
{
    return (int32_t)0x9cc7b96;
}

- (id<TLObject>)TLbuildFromMetaObject:(std::shared_ptr<TLMetaObject>)__unused metaObject
{
    TLRPCphone_getDhConfig$phone_getDhConfig *object = [[TLRPCphone_getDhConfig$phone_getDhConfig alloc] init];
    return object;
}

- (void)TLfillFieldsWithValues:(std::map<int32_t, TLConstructedValue> *)__unused values
{
}


@end

