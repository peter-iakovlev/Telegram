#import "TLRPChelp_getNearestDc.h"

#import "../NSInputStream+TL.h"
#import "../NSOutputStream+TL.h"

#import "TLNearestDc.h"

@implementation TLRPChelp_getNearestDc


- (Class)responseClass
{
    return [TLNearestDc class];
}

- (int)impliedResponseSignature
{
    return (int)0x8e1a1775;
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

@implementation TLRPChelp_getNearestDc$help_getNearestDc : TLRPChelp_getNearestDc


- (int32_t)TLconstructorSignature
{
    return (int32_t)0x1fb33026;
}

- (int32_t)TLconstructorName
{
    return (int32_t)0xded6b405;
}

- (id<TLObject>)TLbuildFromMetaObject:(std::shared_ptr<TLMetaObject>)__unused metaObject
{
    TLRPChelp_getNearestDc$help_getNearestDc *object = [[TLRPChelp_getNearestDc$help_getNearestDc alloc] init];
    return object;
}

- (void)TLfillFieldsWithValues:(std::map<int32_t, TLConstructedValue> *)__unused values
{
}


@end

