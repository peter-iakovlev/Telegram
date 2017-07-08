#import "TLChannelParticipant.h"

#import "../NSInputStream+TL.h"
#import "../NSOutputStream+TL.h"

#import "TLChannelAdminRights.h"
#import "TLChannelBannedRights.h"

@implementation TLChannelParticipant


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

@implementation TLChannelParticipant$channelParticipant : TLChannelParticipant


- (int32_t)TLconstructorSignature
{
    return (int32_t)0x15ebac1d;
}

- (int32_t)TLconstructorName
{
    return (int32_t)0x62bdefab;
}

- (id<TLObject>)TLbuildFromMetaObject:(std::shared_ptr<TLMetaObject>)metaObject
{
    TLChannelParticipant$channelParticipant *object = [[TLChannelParticipant$channelParticipant alloc] init];
    object.user_id = metaObject->getInt32((int32_t)0xafdf4073);
    object.date = metaObject->getInt32((int32_t)0xb76958ba);
    return object;
}

- (void)TLfillFieldsWithValues:(std::map<int32_t, TLConstructedValue> *)values
{
    {
        TLConstructedValue value;
        value.type = TLConstructedValueTypePrimitiveInt32;
        value.primitive.int32Value = self.user_id;
        values->insert(std::pair<int32_t, TLConstructedValue>((int32_t)0xafdf4073, value));
    }
    {
        TLConstructedValue value;
        value.type = TLConstructedValueTypePrimitiveInt32;
        value.primitive.int32Value = self.date;
        values->insert(std::pair<int32_t, TLConstructedValue>((int32_t)0xb76958ba, value));
    }
}


@end

@implementation TLChannelParticipant$channelParticipantSelf : TLChannelParticipant


- (int32_t)TLconstructorSignature
{
    return (int32_t)0xa3289a6d;
}

- (int32_t)TLconstructorName
{
    return (int32_t)0x1f33494d;
}

- (id<TLObject>)TLbuildFromMetaObject:(std::shared_ptr<TLMetaObject>)metaObject
{
    TLChannelParticipant$channelParticipantSelf *object = [[TLChannelParticipant$channelParticipantSelf alloc] init];
    object.user_id = metaObject->getInt32((int32_t)0xafdf4073);
    object.inviter_id = metaObject->getInt32((int32_t)0x9ddfbd93);
    object.date = metaObject->getInt32((int32_t)0xb76958ba);
    return object;
}

- (void)TLfillFieldsWithValues:(std::map<int32_t, TLConstructedValue> *)values
{
    {
        TLConstructedValue value;
        value.type = TLConstructedValueTypePrimitiveInt32;
        value.primitive.int32Value = self.user_id;
        values->insert(std::pair<int32_t, TLConstructedValue>((int32_t)0xafdf4073, value));
    }
    {
        TLConstructedValue value;
        value.type = TLConstructedValueTypePrimitiveInt32;
        value.primitive.int32Value = self.inviter_id;
        values->insert(std::pair<int32_t, TLConstructedValue>((int32_t)0x9ddfbd93, value));
    }
    {
        TLConstructedValue value;
        value.type = TLConstructedValueTypePrimitiveInt32;
        value.primitive.int32Value = self.date;
        values->insert(std::pair<int32_t, TLConstructedValue>((int32_t)0xb76958ba, value));
    }
}


@end

@implementation TLChannelParticipant$channelParticipantCreator : TLChannelParticipant


- (int32_t)TLconstructorSignature
{
    return (int32_t)0xe3e2e1f9;
}

- (int32_t)TLconstructorName
{
    return (int32_t)0x32ce00ff;
}

- (id<TLObject>)TLbuildFromMetaObject:(std::shared_ptr<TLMetaObject>)metaObject
{
    TLChannelParticipant$channelParticipantCreator *object = [[TLChannelParticipant$channelParticipantCreator alloc] init];
    object.user_id = metaObject->getInt32((int32_t)0xafdf4073);
    return object;
}

- (void)TLfillFieldsWithValues:(std::map<int32_t, TLConstructedValue> *)values
{
    {
        TLConstructedValue value;
        value.type = TLConstructedValueTypePrimitiveInt32;
        value.primitive.int32Value = self.user_id;
        values->insert(std::pair<int32_t, TLConstructedValue>((int32_t)0xafdf4073, value));
    }
}


@end

@implementation TLChannelParticipant$channelParticipantAdmin : TLChannelParticipant


- (int32_t)TLconstructorSignature
{
    return (int32_t)0xa82fa898;
}

- (int32_t)TLconstructorName
{
    return (int32_t)0xd92d146c;
}

- (id<TLObject>)TLbuildFromMetaObject:(std::shared_ptr<TLMetaObject>)metaObject
{
    TLChannelParticipant$channelParticipantAdmin *object = [[TLChannelParticipant$channelParticipantAdmin alloc] init];
    object.flags = metaObject->getInt32((int32_t)0x81915c23);
    object.user_id = metaObject->getInt32((int32_t)0xafdf4073);
    object.inviter_id = metaObject->getInt32((int32_t)0x9ddfbd93);
    object.promoted_by = metaObject->getInt32((int32_t)0x525bb9d2);
    object.date = metaObject->getInt32((int32_t)0xb76958ba);
    object.admin_rights = metaObject->getObject((int32_t)0x86c3114f);
    return object;
}

- (void)TLfillFieldsWithValues:(std::map<int32_t, TLConstructedValue> *)values
{
    {
        TLConstructedValue value;
        value.type = TLConstructedValueTypePrimitiveInt32;
        value.primitive.int32Value = self.flags;
        values->insert(std::pair<int32_t, TLConstructedValue>((int32_t)0x81915c23, value));
    }
    {
        TLConstructedValue value;
        value.type = TLConstructedValueTypePrimitiveInt32;
        value.primitive.int32Value = self.user_id;
        values->insert(std::pair<int32_t, TLConstructedValue>((int32_t)0xafdf4073, value));
    }
    {
        TLConstructedValue value;
        value.type = TLConstructedValueTypePrimitiveInt32;
        value.primitive.int32Value = self.inviter_id;
        values->insert(std::pair<int32_t, TLConstructedValue>((int32_t)0x9ddfbd93, value));
    }
    {
        TLConstructedValue value;
        value.type = TLConstructedValueTypePrimitiveInt32;
        value.primitive.int32Value = self.promoted_by;
        values->insert(std::pair<int32_t, TLConstructedValue>((int32_t)0x525bb9d2, value));
    }
    {
        TLConstructedValue value;
        value.type = TLConstructedValueTypePrimitiveInt32;
        value.primitive.int32Value = self.date;
        values->insert(std::pair<int32_t, TLConstructedValue>((int32_t)0xb76958ba, value));
    }
    {
        TLConstructedValue value;
        value.type = TLConstructedValueTypeObject;
        value.nativeObject = self.admin_rights;
        values->insert(std::pair<int32_t, TLConstructedValue>((int32_t)0x86c3114f, value));
    }
}


@end

@implementation TLChannelParticipant$channelParticipantBanned : TLChannelParticipant


- (int32_t)TLconstructorSignature
{
    return (int32_t)0x222c1886;
}

- (int32_t)TLconstructorName
{
    return (int32_t)0xee8ea686;
}

- (id<TLObject>)TLbuildFromMetaObject:(std::shared_ptr<TLMetaObject>)metaObject
{
    TLChannelParticipant$channelParticipantBanned *object = [[TLChannelParticipant$channelParticipantBanned alloc] init];
    object.flags = metaObject->getInt32((int32_t)0x81915c23);
    object.user_id = metaObject->getInt32((int32_t)0xafdf4073);
    object.kicked_by = metaObject->getInt32((int32_t)0xd6716483);
    object.date = metaObject->getInt32((int32_t)0xb76958ba);
    object.banned_rights = metaObject->getObject((int32_t)0x7ecb6900);
    return object;
}

- (void)TLfillFieldsWithValues:(std::map<int32_t, TLConstructedValue> *)values
{
    {
        TLConstructedValue value;
        value.type = TLConstructedValueTypePrimitiveInt32;
        value.primitive.int32Value = self.flags;
        values->insert(std::pair<int32_t, TLConstructedValue>((int32_t)0x81915c23, value));
    }
    {
        TLConstructedValue value;
        value.type = TLConstructedValueTypePrimitiveInt32;
        value.primitive.int32Value = self.user_id;
        values->insert(std::pair<int32_t, TLConstructedValue>((int32_t)0xafdf4073, value));
    }
    {
        TLConstructedValue value;
        value.type = TLConstructedValueTypePrimitiveInt32;
        value.primitive.int32Value = self.kicked_by;
        values->insert(std::pair<int32_t, TLConstructedValue>((int32_t)0xd6716483, value));
    }
    {
        TLConstructedValue value;
        value.type = TLConstructedValueTypePrimitiveInt32;
        value.primitive.int32Value = self.date;
        values->insert(std::pair<int32_t, TLConstructedValue>((int32_t)0xb76958ba, value));
    }
    {
        TLConstructedValue value;
        value.type = TLConstructedValueTypeObject;
        value.nativeObject = self.banned_rights;
        values->insert(std::pair<int32_t, TLConstructedValue>((int32_t)0x7ecb6900, value));
    }
}


@end

