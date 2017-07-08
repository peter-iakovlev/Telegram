#import "TLRPCpayments_getSavedInfo.h"

#import "../NSInputStream+TL.h"
#import "../NSOutputStream+TL.h"

#import "TLpayments_SavedInfo.h"

@implementation TLRPCpayments_getSavedInfo


- (Class)responseClass
{
    return [TLpayments_SavedInfo class];
}

- (int)impliedResponseSignature
{
    return (int)0xa2ffb0da;
}

- (int)layerVersion
{
    return 64;
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

@implementation TLRPCpayments_getSavedInfo$payments_getSavedInfo : TLRPCpayments_getSavedInfo


- (int32_t)TLconstructorSignature
{
    return (int32_t)0x227d824b;
}

- (int32_t)TLconstructorName
{
    return (int32_t)0x27af031b;
}

- (id<TLObject>)TLbuildFromMetaObject:(std::shared_ptr<TLMetaObject>)__unused metaObject
{
    TLRPCpayments_getSavedInfo$payments_getSavedInfo *object = [[TLRPCpayments_getSavedInfo$payments_getSavedInfo alloc] init];
    return object;
}

- (void)TLfillFieldsWithValues:(std::map<int32_t, TLConstructedValue> *)__unused values
{
}


@end

