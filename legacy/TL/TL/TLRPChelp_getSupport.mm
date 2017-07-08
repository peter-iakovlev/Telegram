#import "TLRPChelp_getSupport.h"

#import "../NSInputStream+TL.h"
#import "../NSOutputStream+TL.h"

#import "TLhelp_Support.h"

@implementation TLRPChelp_getSupport


- (Class)responseClass
{
    return [TLhelp_Support class];
}

- (int)impliedResponseSignature
{
    return (int)0x17c6b5f6;
}

- (int)layerVersion
{
    return 12;
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

@implementation TLRPChelp_getSupport$help_getSupport : TLRPChelp_getSupport


- (int32_t)TLconstructorSignature
{
    return (int32_t)0x9cdf08cd;
}

- (int32_t)TLconstructorName
{
    return (int32_t)0x98d22080;
}

- (id<TLObject>)TLbuildFromMetaObject:(std::shared_ptr<TLMetaObject>)__unused metaObject
{
    TLRPChelp_getSupport$help_getSupport *object = [[TLRPChelp_getSupport$help_getSupport alloc] init];
    return object;
}

- (void)TLfillFieldsWithValues:(std::map<int32_t, TLConstructedValue> *)__unused values
{
}


@end

