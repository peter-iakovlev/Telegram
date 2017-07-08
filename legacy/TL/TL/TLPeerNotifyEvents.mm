#import "TLPeerNotifyEvents.h"

#import "../NSInputStream+TL.h"
#import "../NSOutputStream+TL.h"


@implementation TLPeerNotifyEvents


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

@implementation TLPeerNotifyEvents$peerNotifyEventsEmpty : TLPeerNotifyEvents


- (int32_t)TLconstructorSignature
{
    return (int32_t)0xadd53cb3;
}

- (int32_t)TLconstructorName
{
    return (int32_t)0x86e4f3c2;
}

- (id<TLObject>)TLbuildFromMetaObject:(std::shared_ptr<TLMetaObject>)__unused metaObject
{
    TLPeerNotifyEvents$peerNotifyEventsEmpty *object = [[TLPeerNotifyEvents$peerNotifyEventsEmpty alloc] init];
    return object;
}

- (void)TLfillFieldsWithValues:(std::map<int32_t, TLConstructedValue> *)__unused values
{
}


@end

@implementation TLPeerNotifyEvents$peerNotifyEventsAll : TLPeerNotifyEvents


- (int32_t)TLconstructorSignature
{
    return (int32_t)0x6d1ded88;
}

- (int32_t)TLconstructorName
{
    return (int32_t)0x53770738;
}

- (id<TLObject>)TLbuildFromMetaObject:(std::shared_ptr<TLMetaObject>)__unused metaObject
{
    TLPeerNotifyEvents$peerNotifyEventsAll *object = [[TLPeerNotifyEvents$peerNotifyEventsAll alloc] init];
    return object;
}

- (void)TLfillFieldsWithValues:(std::map<int32_t, TLConstructedValue> *)__unused values
{
}


@end

