#import "TLChannelParticipantsFilter.h"

#import "../NSInputStream+TL.h"
#import "../NSOutputStream+TL.h"


@implementation TLChannelParticipantsFilter


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

- (id<TLObject>)TLbuildFromMetaObject:(std::tr1::shared_ptr<TLMetaObject>)__unused metaObject
{
    TGLog(@"TLbuildFromMetaObject is not implemented for base type");
    return nil;
}

- (void)TLfillFieldsWithValues:(std::map<int32_t, TLConstructedValue> *)__unused values
{
    TGLog(@"TLfillFieldsWithValues is not implemented for base type");
}


@end

@implementation TLChannelParticipantsFilter$channelParticipantsRecent : TLChannelParticipantsFilter


- (int32_t)TLconstructorSignature
{
    return (int32_t)0xde3f3c79;
}

- (int32_t)TLconstructorName
{
    return (int32_t)0x3299c20;
}

- (id<TLObject>)TLbuildFromMetaObject:(std::tr1::shared_ptr<TLMetaObject>)__unused metaObject
{
    TLChannelParticipantsFilter$channelParticipantsRecent *object = [[TLChannelParticipantsFilter$channelParticipantsRecent alloc] init];
    return object;
}

- (void)TLfillFieldsWithValues:(std::map<int32_t, TLConstructedValue> *)__unused values
{
}


@end

@implementation TLChannelParticipantsFilter$channelParticipantsAdmins : TLChannelParticipantsFilter


- (int32_t)TLconstructorSignature
{
    return (int32_t)0xb4608969;
}

- (int32_t)TLconstructorName
{
    return (int32_t)0x981d1035;
}

- (id<TLObject>)TLbuildFromMetaObject:(std::tr1::shared_ptr<TLMetaObject>)__unused metaObject
{
    TLChannelParticipantsFilter$channelParticipantsAdmins *object = [[TLChannelParticipantsFilter$channelParticipantsAdmins alloc] init];
    return object;
}

- (void)TLfillFieldsWithValues:(std::map<int32_t, TLConstructedValue> *)__unused values
{
}


@end

@implementation TLChannelParticipantsFilter$channelParticipantsKicked : TLChannelParticipantsFilter


- (int32_t)TLconstructorSignature
{
    return (int32_t)0x3c37bb7a;
}

- (int32_t)TLconstructorName
{
    return (int32_t)0xb6bbfc3a;
}

- (id<TLObject>)TLbuildFromMetaObject:(std::tr1::shared_ptr<TLMetaObject>)__unused metaObject
{
    TLChannelParticipantsFilter$channelParticipantsKicked *object = [[TLChannelParticipantsFilter$channelParticipantsKicked alloc] init];
    return object;
}

- (void)TLfillFieldsWithValues:(std::map<int32_t, TLConstructedValue> *)__unused values
{
}


@end

