#import "TLRPCupdates_getState.h"

#import "../NSInputStream+TL.h"
#import "../NSOutputStream+TL.h"

#import "TLupdates_State.h"

@implementation TLRPCupdates_getState


- (Class)responseClass
{
    return [TLupdates_State class];
}

- (int)impliedResponseSignature
{
    return (int)0xa56c2a3e;
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

@implementation TLRPCupdates_getState$updates_getState : TLRPCupdates_getState


- (int32_t)TLconstructorSignature
{
    return (int32_t)0xedd4882a;
}

- (int32_t)TLconstructorName
{
    return (int32_t)0xa67b40e;
}

- (id<TLObject>)TLbuildFromMetaObject:(std::shared_ptr<TLMetaObject>)__unused metaObject
{
    TLRPCupdates_getState$updates_getState *object = [[TLRPCupdates_getState$updates_getState alloc] init];
    return object;
}

- (void)TLfillFieldsWithValues:(std::map<int32_t, TLConstructedValue> *)__unused values
{
}


@end

