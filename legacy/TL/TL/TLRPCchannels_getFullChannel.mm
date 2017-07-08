#import "TLRPCchannels_getFullChannel.h"

#import "../NSInputStream+TL.h"
#import "../NSOutputStream+TL.h"

#import "TLInputChannel.h"
#import "TLmessages_ChatFull.h"

@implementation TLRPCchannels_getFullChannel


- (Class)responseClass
{
    return [TLmessages_ChatFull class];
}

- (int)impliedResponseSignature
{
    return (int)0xe5d7d19c;
}

- (int)layerVersion
{
    return 38;
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

@implementation TLRPCchannels_getFullChannel$channels_getFullChannel : TLRPCchannels_getFullChannel


- (int32_t)TLconstructorSignature
{
    return (int32_t)0x8736a09;
}

- (int32_t)TLconstructorName
{
    return (int32_t)0x1851eb5;
}

- (id<TLObject>)TLbuildFromMetaObject:(std::shared_ptr<TLMetaObject>)metaObject
{
    TLRPCchannels_getFullChannel$channels_getFullChannel *object = [[TLRPCchannels_getFullChannel$channels_getFullChannel alloc] init];
    object.channel = metaObject->getObject((int32_t)0xe11f3d41);
    return object;
}

- (void)TLfillFieldsWithValues:(std::map<int32_t, TLConstructedValue> *)values
{
    {
        TLConstructedValue value;
        value.type = TLConstructedValueTypeObject;
        value.nativeObject = self.channel;
        values->insert(std::pair<int32_t, TLConstructedValue>((int32_t)0xe11f3d41, value));
    }
}


@end

