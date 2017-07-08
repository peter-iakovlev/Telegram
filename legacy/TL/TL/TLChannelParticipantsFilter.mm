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

@implementation TLChannelParticipantsFilter$channelParticipantsRecent : TLChannelParticipantsFilter


- (int32_t)TLconstructorSignature
{
    return (int32_t)0xde3f3c79;
}

- (int32_t)TLconstructorName
{
    return (int32_t)0x3299c20;
}

- (id<TLObject>)TLbuildFromMetaObject:(std::shared_ptr<TLMetaObject>)__unused metaObject
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

- (id<TLObject>)TLbuildFromMetaObject:(std::shared_ptr<TLMetaObject>)__unused metaObject
{
    TLChannelParticipantsFilter$channelParticipantsAdmins *object = [[TLChannelParticipantsFilter$channelParticipantsAdmins alloc] init];
    return object;
}

- (void)TLfillFieldsWithValues:(std::map<int32_t, TLConstructedValue> *)__unused values
{
}


@end

@implementation TLChannelParticipantsFilter$channelParticipantsBanned : TLChannelParticipantsFilter


- (int32_t)TLconstructorSignature
{
    return (int32_t)0x1427a5e1;
}

- (int32_t)TLconstructorName
{
    return (int32_t)0xeb80e009;
}

- (id<TLObject>)TLbuildFromMetaObject:(std::shared_ptr<TLMetaObject>)metaObject
{
    TLChannelParticipantsFilter$channelParticipantsBanned *object = [[TLChannelParticipantsFilter$channelParticipantsBanned alloc] init];
    object.q = metaObject->getString((int32_t)0xcd45cb1c);
    return object;
}

- (void)TLfillFieldsWithValues:(std::map<int32_t, TLConstructedValue> *)values
{
    {
        TLConstructedValue value;
        value.type = TLConstructedValueTypeString;
        value.nativeObject = self.q;
        values->insert(std::pair<int32_t, TLConstructedValue>((int32_t)0xcd45cb1c, value));
    }
}


@end

@implementation TLChannelParticipantsFilter$channelParticipantsSearch : TLChannelParticipantsFilter


- (int32_t)TLconstructorSignature
{
    return (int32_t)0x656ac4b;
}

- (int32_t)TLconstructorName
{
    return (int32_t)0xc820ea99;
}

- (id<TLObject>)TLbuildFromMetaObject:(std::shared_ptr<TLMetaObject>)metaObject
{
    TLChannelParticipantsFilter$channelParticipantsSearch *object = [[TLChannelParticipantsFilter$channelParticipantsSearch alloc] init];
    object.q = metaObject->getString((int32_t)0xcd45cb1c);
    return object;
}

- (void)TLfillFieldsWithValues:(std::map<int32_t, TLConstructedValue> *)values
{
    {
        TLConstructedValue value;
        value.type = TLConstructedValueTypeString;
        value.nativeObject = self.q;
        values->insert(std::pair<int32_t, TLConstructedValue>((int32_t)0xcd45cb1c, value));
    }
}


@end

@implementation TLChannelParticipantsFilter$channelParticipantsKicked : TLChannelParticipantsFilter


- (int32_t)TLconstructorSignature
{
    return (int32_t)0xa3b54985;
}

- (int32_t)TLconstructorName
{
    return (int32_t)0xb6bbfc3a;
}

- (id<TLObject>)TLbuildFromMetaObject:(std::shared_ptr<TLMetaObject>)metaObject
{
    TLChannelParticipantsFilter$channelParticipantsKicked *object = [[TLChannelParticipantsFilter$channelParticipantsKicked alloc] init];
    object.q = metaObject->getString((int32_t)0xcd45cb1c);
    return object;
}

- (void)TLfillFieldsWithValues:(std::map<int32_t, TLConstructedValue> *)values
{
    {
        TLConstructedValue value;
        value.type = TLConstructedValueTypeString;
        value.nativeObject = self.q;
        values->insert(std::pair<int32_t, TLConstructedValue>((int32_t)0xcd45cb1c, value));
    }
}


@end

