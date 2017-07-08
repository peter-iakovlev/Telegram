#import "TLchannels_ChannelParticipant.h"

#import "../NSInputStream+TL.h"
#import "../NSOutputStream+TL.h"

#import "TLChannelParticipant.h"

@implementation TLchannels_ChannelParticipant


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

@implementation TLchannels_ChannelParticipant$channels_channelParticipant : TLchannels_ChannelParticipant


- (int32_t)TLconstructorSignature
{
    return (int32_t)0xd0d9b163;
}

- (int32_t)TLconstructorName
{
    return (int32_t)0x77a1ed5b;
}

- (id<TLObject>)TLbuildFromMetaObject:(std::shared_ptr<TLMetaObject>)metaObject
{
    TLchannels_ChannelParticipant$channels_channelParticipant *object = [[TLchannels_ChannelParticipant$channels_channelParticipant alloc] init];
    object.participant = metaObject->getObject((int32_t)0x837816d4);
    object.users = metaObject->getArray((int32_t)0x933e5ff3);
    return object;
}

- (void)TLfillFieldsWithValues:(std::map<int32_t, TLConstructedValue> *)values
{
    {
        TLConstructedValue value;
        value.type = TLConstructedValueTypeObject;
        value.nativeObject = self.participant;
        values->insert(std::pair<int32_t, TLConstructedValue>((int32_t)0x837816d4, value));
    }
    {
        TLConstructedValue value;
        value.type = TLConstructedValueTypeVector;
        value.nativeObject = self.users;
        values->insert(std::pair<int32_t, TLConstructedValue>((int32_t)0x933e5ff3, value));
    }
}


@end

