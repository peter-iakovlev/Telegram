#import "TLRPCphone_getCallConfig.h"

#import "../NSInputStream+TL.h"
#import "../NSOutputStream+TL.h"

#import "TLDataJSON.h"

@implementation TLRPCphone_getCallConfig


- (Class)responseClass
{
    return [TLDataJSON class];
}

- (int)impliedResponseSignature
{
    return (int)0x7d748d04;
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

@implementation TLRPCphone_getCallConfig$phone_getCallConfig : TLRPCphone_getCallConfig


- (int32_t)TLconstructorSignature
{
    return (int32_t)0x55451fa9;
}

- (int32_t)TLconstructorName
{
    return (int32_t)0x28c34829;
}

- (id<TLObject>)TLbuildFromMetaObject:(std::shared_ptr<TLMetaObject>)__unused metaObject
{
    TLRPCphone_getCallConfig$phone_getCallConfig *object = [[TLRPCphone_getCallConfig$phone_getCallConfig alloc] init];
    return object;
}

- (void)TLfillFieldsWithValues:(std::map<int32_t, TLConstructedValue> *)__unused values
{
}


@end

