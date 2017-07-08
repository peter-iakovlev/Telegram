#import "TLRPChelp_getConfig.h"

#import "../NSInputStream+TL.h"
#import "../NSOutputStream+TL.h"

#import "TLConfig.h"

@implementation TLRPChelp_getConfig


- (Class)responseClass
{
    return [TLConfig class];
}

- (int)impliedResponseSignature
{
    return (int)0x5f688205;
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

@implementation TLRPChelp_getConfig$help_getConfig : TLRPChelp_getConfig


- (int32_t)TLconstructorSignature
{
    return (int32_t)0xc4f9186b;
}

- (int32_t)TLconstructorName
{
    return (int32_t)0xd393702c;
}

- (id<TLObject>)TLbuildFromMetaObject:(std::shared_ptr<TLMetaObject>)__unused metaObject
{
    TLRPChelp_getConfig$help_getConfig *object = [[TLRPChelp_getConfig$help_getConfig alloc] init];
    return object;
}

- (void)TLfillFieldsWithValues:(std::map<int32_t, TLConstructedValue> *)__unused values
{
}


@end

