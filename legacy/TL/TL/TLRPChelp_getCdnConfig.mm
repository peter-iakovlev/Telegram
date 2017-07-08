#import "TLRPChelp_getCdnConfig.h"

#import "../NSInputStream+TL.h"
#import "../NSOutputStream+TL.h"

#import "TLCdnConfig.h"

@implementation TLRPChelp_getCdnConfig


- (Class)responseClass
{
    return [TLCdnConfig class];
}

- (int)impliedResponseSignature
{
    return (int)0x5725e40a;
}

- (int)layerVersion
{
    return 66;
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

@implementation TLRPChelp_getCdnConfig$help_getCdnConfig : TLRPChelp_getCdnConfig


- (int32_t)TLconstructorSignature
{
    return (int32_t)0x52029342;
}

- (int32_t)TLconstructorName
{
    return (int32_t)0xab2a23f;
}

- (id<TLObject>)TLbuildFromMetaObject:(std::shared_ptr<TLMetaObject>)__unused metaObject
{
    TLRPChelp_getCdnConfig$help_getCdnConfig *object = [[TLRPChelp_getCdnConfig$help_getCdnConfig alloc] init];
    return object;
}

- (void)TLfillFieldsWithValues:(std::map<int32_t, TLConstructedValue> *)__unused values
{
}


@end

