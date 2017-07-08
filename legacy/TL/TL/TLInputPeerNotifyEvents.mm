#import "TLInputPeerNotifyEvents.h"

#import "../NSInputStream+TL.h"
#import "../NSOutputStream+TL.h"


@implementation TLInputPeerNotifyEvents


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

@implementation TLInputPeerNotifyEvents$inputPeerNotifyEventsEmpty : TLInputPeerNotifyEvents


- (int32_t)TLconstructorSignature
{
    return (int32_t)0xf03064d8;
}

- (int32_t)TLconstructorName
{
    return (int32_t)0xfe29b22b;
}

- (id<TLObject>)TLbuildFromMetaObject:(std::shared_ptr<TLMetaObject>)__unused metaObject
{
    TLInputPeerNotifyEvents$inputPeerNotifyEventsEmpty *object = [[TLInputPeerNotifyEvents$inputPeerNotifyEventsEmpty alloc] init];
    return object;
}

- (void)TLfillFieldsWithValues:(std::map<int32_t, TLConstructedValue> *)__unused values
{
}


@end

@implementation TLInputPeerNotifyEvents$inputPeerNotifyEventsAll : TLInputPeerNotifyEvents


- (int32_t)TLconstructorSignature
{
    return (int32_t)0xe86a2c74;
}

- (int32_t)TLconstructorName
{
    return (int32_t)0xcff77b2c;
}

- (id<TLObject>)TLbuildFromMetaObject:(std::shared_ptr<TLMetaObject>)__unused metaObject
{
    TLInputPeerNotifyEvents$inputPeerNotifyEventsAll *object = [[TLInputPeerNotifyEvents$inputPeerNotifyEventsAll alloc] init];
    return object;
}

- (void)TLfillFieldsWithValues:(std::map<int32_t, TLConstructedValue> *)__unused values
{
}


@end

