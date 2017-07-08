#import "TLRPCchannels_getParticipant.h"

#import "../NSInputStream+TL.h"
#import "../NSOutputStream+TL.h"

#import "TLInputChannel.h"
#import "TLInputUser.h"
#import "TLchannels_ChannelParticipant.h"

@implementation TLRPCchannels_getParticipant


- (Class)responseClass
{
    return [TLchannels_ChannelParticipant class];
}

- (int)impliedResponseSignature
{
    return (int)0xd0d9b163;
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

@implementation TLRPCchannels_getParticipant$channels_getParticipant : TLRPCchannels_getParticipant


- (int32_t)TLconstructorSignature
{
    return (int32_t)0x546dd7a6;
}

- (int32_t)TLconstructorName
{
    return (int32_t)0x57bff8bc;
}

- (id<TLObject>)TLbuildFromMetaObject:(std::shared_ptr<TLMetaObject>)metaObject
{
    TLRPCchannels_getParticipant$channels_getParticipant *object = [[TLRPCchannels_getParticipant$channels_getParticipant alloc] init];
    object.channel = metaObject->getObject((int32_t)0xe11f3d41);
    object.user_id = metaObject->getObject((int32_t)0xafdf4073);
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
    {
        TLConstructedValue value;
        value.type = TLConstructedValueTypeObject;
        value.nativeObject = self.user_id;
        values->insert(std::pair<int32_t, TLConstructedValue>((int32_t)0xafdf4073, value));
    }
}


@end

