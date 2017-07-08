#import "TLChannelAdminLogEventAction.h"

#import "../NSInputStream+TL.h"
#import "../NSOutputStream+TL.h"

#import "TLChatPhoto.h"
#import "TLMessage.h"
#import "TLChannelParticipant.h"

@implementation TLChannelAdminLogEventAction


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

@implementation TLChannelAdminLogEventAction$channelAdminLogEventActionChangeTitle : TLChannelAdminLogEventAction


- (int32_t)TLconstructorSignature
{
    return (int32_t)0xe6dfb825;
}

- (int32_t)TLconstructorName
{
    return (int32_t)0x5541bbdf;
}

- (id<TLObject>)TLbuildFromMetaObject:(std::shared_ptr<TLMetaObject>)metaObject
{
    TLChannelAdminLogEventAction$channelAdminLogEventActionChangeTitle *object = [[TLChannelAdminLogEventAction$channelAdminLogEventActionChangeTitle alloc] init];
    object.prev_value = metaObject->getString((int32_t)0x37014dc8);
    object.n_new_value = metaObject->getString((int32_t)0xc81df074);
    return object;
}

- (void)TLfillFieldsWithValues:(std::map<int32_t, TLConstructedValue> *)values
{
    {
        TLConstructedValue value;
        value.type = TLConstructedValueTypeString;
        value.nativeObject = self.prev_value;
        values->insert(std::pair<int32_t, TLConstructedValue>((int32_t)0x37014dc8, value));
    }
    {
        TLConstructedValue value;
        value.type = TLConstructedValueTypeString;
        value.nativeObject = self.n_new_value;
        values->insert(std::pair<int32_t, TLConstructedValue>((int32_t)0xc81df074, value));
    }
}


@end

@implementation TLChannelAdminLogEventAction$channelAdminLogEventActionChangeAbout : TLChannelAdminLogEventAction


- (int32_t)TLconstructorSignature
{
    return (int32_t)0x55188a2e;
}

- (int32_t)TLconstructorName
{
    return (int32_t)0x8465d5e7;
}

- (id<TLObject>)TLbuildFromMetaObject:(std::shared_ptr<TLMetaObject>)metaObject
{
    TLChannelAdminLogEventAction$channelAdminLogEventActionChangeAbout *object = [[TLChannelAdminLogEventAction$channelAdminLogEventActionChangeAbout alloc] init];
    object.prev_value = metaObject->getString((int32_t)0x37014dc8);
    object.n_new_value = metaObject->getString((int32_t)0xc81df074);
    return object;
}

- (void)TLfillFieldsWithValues:(std::map<int32_t, TLConstructedValue> *)values
{
    {
        TLConstructedValue value;
        value.type = TLConstructedValueTypeString;
        value.nativeObject = self.prev_value;
        values->insert(std::pair<int32_t, TLConstructedValue>((int32_t)0x37014dc8, value));
    }
    {
        TLConstructedValue value;
        value.type = TLConstructedValueTypeString;
        value.nativeObject = self.n_new_value;
        values->insert(std::pair<int32_t, TLConstructedValue>((int32_t)0xc81df074, value));
    }
}


@end

@implementation TLChannelAdminLogEventAction$channelAdminLogEventActionChangeUsername : TLChannelAdminLogEventAction


- (int32_t)TLconstructorSignature
{
    return (int32_t)0x6a4afc38;
}

- (int32_t)TLconstructorName
{
    return (int32_t)0x2385ff1e;
}

- (id<TLObject>)TLbuildFromMetaObject:(std::shared_ptr<TLMetaObject>)metaObject
{
    TLChannelAdminLogEventAction$channelAdminLogEventActionChangeUsername *object = [[TLChannelAdminLogEventAction$channelAdminLogEventActionChangeUsername alloc] init];
    object.prev_value = metaObject->getString((int32_t)0x37014dc8);
    object.n_new_value = metaObject->getString((int32_t)0xc81df074);
    return object;
}

- (void)TLfillFieldsWithValues:(std::map<int32_t, TLConstructedValue> *)values
{
    {
        TLConstructedValue value;
        value.type = TLConstructedValueTypeString;
        value.nativeObject = self.prev_value;
        values->insert(std::pair<int32_t, TLConstructedValue>((int32_t)0x37014dc8, value));
    }
    {
        TLConstructedValue value;
        value.type = TLConstructedValueTypeString;
        value.nativeObject = self.n_new_value;
        values->insert(std::pair<int32_t, TLConstructedValue>((int32_t)0xc81df074, value));
    }
}


@end

@implementation TLChannelAdminLogEventAction$channelAdminLogEventActionChangePhoto : TLChannelAdminLogEventAction


- (int32_t)TLconstructorSignature
{
    return (int32_t)0xb82f55c3;
}

- (int32_t)TLconstructorName
{
    return (int32_t)0xfe9e171d;
}

- (id<TLObject>)TLbuildFromMetaObject:(std::shared_ptr<TLMetaObject>)metaObject
{
    TLChannelAdminLogEventAction$channelAdminLogEventActionChangePhoto *object = [[TLChannelAdminLogEventAction$channelAdminLogEventActionChangePhoto alloc] init];
    object.prev_photo = metaObject->getObject((int32_t)0xa5f14031);
    object.n_new_photo = metaObject->getObject((int32_t)0xe624d021);
    return object;
}

- (void)TLfillFieldsWithValues:(std::map<int32_t, TLConstructedValue> *)values
{
    {
        TLConstructedValue value;
        value.type = TLConstructedValueTypeObject;
        value.nativeObject = self.prev_photo;
        values->insert(std::pair<int32_t, TLConstructedValue>((int32_t)0xa5f14031, value));
    }
    {
        TLConstructedValue value;
        value.type = TLConstructedValueTypeObject;
        value.nativeObject = self.n_new_photo;
        values->insert(std::pair<int32_t, TLConstructedValue>((int32_t)0xe624d021, value));
    }
}


@end

@implementation TLChannelAdminLogEventAction$channelAdminLogEventActionToggleInvites : TLChannelAdminLogEventAction


- (int32_t)TLconstructorSignature
{
    return (int32_t)0x1b7907ae;
}

- (int32_t)TLconstructorName
{
    return (int32_t)0x91acc9cb;
}

- (id<TLObject>)TLbuildFromMetaObject:(std::shared_ptr<TLMetaObject>)metaObject
{
    TLChannelAdminLogEventAction$channelAdminLogEventActionToggleInvites *object = [[TLChannelAdminLogEventAction$channelAdminLogEventActionToggleInvites alloc] init];
    object.n_new_value = metaObject->getBool((int32_t)0xc81df074);
    return object;
}

- (void)TLfillFieldsWithValues:(std::map<int32_t, TLConstructedValue> *)values
{
    {
        TLConstructedValue value;
        value.type = TLConstructedValueTypePrimitiveBool;
        value.primitive.boolValue = self.n_new_value;
        values->insert(std::pair<int32_t, TLConstructedValue>((int32_t)0xc81df074, value));
    }
}


@end

@implementation TLChannelAdminLogEventAction$channelAdminLogEventActionToggleSignatures : TLChannelAdminLogEventAction


- (int32_t)TLconstructorSignature
{
    return (int32_t)0x26ae0971;
}

- (int32_t)TLconstructorName
{
    return (int32_t)0x5239264e;
}

- (id<TLObject>)TLbuildFromMetaObject:(std::shared_ptr<TLMetaObject>)metaObject
{
    TLChannelAdminLogEventAction$channelAdminLogEventActionToggleSignatures *object = [[TLChannelAdminLogEventAction$channelAdminLogEventActionToggleSignatures alloc] init];
    object.n_new_value = metaObject->getBool((int32_t)0xc81df074);
    return object;
}

- (void)TLfillFieldsWithValues:(std::map<int32_t, TLConstructedValue> *)values
{
    {
        TLConstructedValue value;
        value.type = TLConstructedValueTypePrimitiveBool;
        value.primitive.boolValue = self.n_new_value;
        values->insert(std::pair<int32_t, TLConstructedValue>((int32_t)0xc81df074, value));
    }
}


@end

@implementation TLChannelAdminLogEventAction$channelAdminLogEventActionUpdatePinned : TLChannelAdminLogEventAction


- (int32_t)TLconstructorSignature
{
    return (int32_t)0xe9e82c18;
}

- (int32_t)TLconstructorName
{
    return (int32_t)0xa11d7a2e;
}

- (id<TLObject>)TLbuildFromMetaObject:(std::shared_ptr<TLMetaObject>)metaObject
{
    TLChannelAdminLogEventAction$channelAdminLogEventActionUpdatePinned *object = [[TLChannelAdminLogEventAction$channelAdminLogEventActionUpdatePinned alloc] init];
    object.message = metaObject->getObject((int32_t)0xc43b7853);
    return object;
}

- (void)TLfillFieldsWithValues:(std::map<int32_t, TLConstructedValue> *)values
{
    {
        TLConstructedValue value;
        value.type = TLConstructedValueTypeObject;
        value.nativeObject = self.message;
        values->insert(std::pair<int32_t, TLConstructedValue>((int32_t)0xc43b7853, value));
    }
}


@end

@implementation TLChannelAdminLogEventAction$channelAdminLogEventActionEditMessage : TLChannelAdminLogEventAction


- (int32_t)TLconstructorSignature
{
    return (int32_t)0x709b2405;
}

- (int32_t)TLconstructorName
{
    return (int32_t)0xaf0cfbc1;
}

- (id<TLObject>)TLbuildFromMetaObject:(std::shared_ptr<TLMetaObject>)metaObject
{
    TLChannelAdminLogEventAction$channelAdminLogEventActionEditMessage *object = [[TLChannelAdminLogEventAction$channelAdminLogEventActionEditMessage alloc] init];
    object.prev_message = metaObject->getObject((int32_t)0xbb325e90);
    object.n_new_message = metaObject->getObject((int32_t)0xea60186);
    return object;
}

- (void)TLfillFieldsWithValues:(std::map<int32_t, TLConstructedValue> *)values
{
    {
        TLConstructedValue value;
        value.type = TLConstructedValueTypeObject;
        value.nativeObject = self.prev_message;
        values->insert(std::pair<int32_t, TLConstructedValue>((int32_t)0xbb325e90, value));
    }
    {
        TLConstructedValue value;
        value.type = TLConstructedValueTypeObject;
        value.nativeObject = self.n_new_message;
        values->insert(std::pair<int32_t, TLConstructedValue>((int32_t)0xea60186, value));
    }
}


@end

@implementation TLChannelAdminLogEventAction$channelAdminLogEventActionDeleteMessage : TLChannelAdminLogEventAction


- (int32_t)TLconstructorSignature
{
    return (int32_t)0x42e047bb;
}

- (int32_t)TLconstructorName
{
    return (int32_t)0xaf11ec2c;
}

- (id<TLObject>)TLbuildFromMetaObject:(std::shared_ptr<TLMetaObject>)metaObject
{
    TLChannelAdminLogEventAction$channelAdminLogEventActionDeleteMessage *object = [[TLChannelAdminLogEventAction$channelAdminLogEventActionDeleteMessage alloc] init];
    object.message = metaObject->getObject((int32_t)0xc43b7853);
    return object;
}

- (void)TLfillFieldsWithValues:(std::map<int32_t, TLConstructedValue> *)values
{
    {
        TLConstructedValue value;
        value.type = TLConstructedValueTypeObject;
        value.nativeObject = self.message;
        values->insert(std::pair<int32_t, TLConstructedValue>((int32_t)0xc43b7853, value));
    }
}


@end

@implementation TLChannelAdminLogEventAction$channelAdminLogEventActionParticipantJoin : TLChannelAdminLogEventAction


- (int32_t)TLconstructorSignature
{
    return (int32_t)0x183040d3;
}

- (int32_t)TLconstructorName
{
    return (int32_t)0x2e7c715e;
}

- (id<TLObject>)TLbuildFromMetaObject:(std::shared_ptr<TLMetaObject>)__unused metaObject
{
    TLChannelAdminLogEventAction$channelAdminLogEventActionParticipantJoin *object = [[TLChannelAdminLogEventAction$channelAdminLogEventActionParticipantJoin alloc] init];
    return object;
}

- (void)TLfillFieldsWithValues:(std::map<int32_t, TLConstructedValue> *)__unused values
{
}


@end

@implementation TLChannelAdminLogEventAction$channelAdminLogEventActionParticipantLeave : TLChannelAdminLogEventAction


- (int32_t)TLconstructorSignature
{
    return (int32_t)0xf89777f2;
}

- (int32_t)TLconstructorName
{
    return (int32_t)0x4bf24475;
}

- (id<TLObject>)TLbuildFromMetaObject:(std::shared_ptr<TLMetaObject>)__unused metaObject
{
    TLChannelAdminLogEventAction$channelAdminLogEventActionParticipantLeave *object = [[TLChannelAdminLogEventAction$channelAdminLogEventActionParticipantLeave alloc] init];
    return object;
}

- (void)TLfillFieldsWithValues:(std::map<int32_t, TLConstructedValue> *)__unused values
{
}


@end

@implementation TLChannelAdminLogEventAction$channelAdminLogEventActionParticipantInvite : TLChannelAdminLogEventAction


- (int32_t)TLconstructorSignature
{
    return (int32_t)0xe31c34d8;
}

- (int32_t)TLconstructorName
{
    return (int32_t)0x4a04b49a;
}

- (id<TLObject>)TLbuildFromMetaObject:(std::shared_ptr<TLMetaObject>)metaObject
{
    TLChannelAdminLogEventAction$channelAdminLogEventActionParticipantInvite *object = [[TLChannelAdminLogEventAction$channelAdminLogEventActionParticipantInvite alloc] init];
    object.participant = metaObject->getObject((int32_t)0x837816d4);
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
}


@end

@implementation TLChannelAdminLogEventAction$channelAdminLogEventActionParticipantToggleBan : TLChannelAdminLogEventAction


- (int32_t)TLconstructorSignature
{
    return (int32_t)0xe6d83d7e;
}

- (int32_t)TLconstructorName
{
    return (int32_t)0x56d65dd5;
}

- (id<TLObject>)TLbuildFromMetaObject:(std::shared_ptr<TLMetaObject>)metaObject
{
    TLChannelAdminLogEventAction$channelAdminLogEventActionParticipantToggleBan *object = [[TLChannelAdminLogEventAction$channelAdminLogEventActionParticipantToggleBan alloc] init];
    object.prev_participant = metaObject->getObject((int32_t)0x25d6d4b8);
    object.n_new_participant = metaObject->getObject((int32_t)0xf6311a80);
    return object;
}

- (void)TLfillFieldsWithValues:(std::map<int32_t, TLConstructedValue> *)values
{
    {
        TLConstructedValue value;
        value.type = TLConstructedValueTypeObject;
        value.nativeObject = self.prev_participant;
        values->insert(std::pair<int32_t, TLConstructedValue>((int32_t)0x25d6d4b8, value));
    }
    {
        TLConstructedValue value;
        value.type = TLConstructedValueTypeObject;
        value.nativeObject = self.n_new_participant;
        values->insert(std::pair<int32_t, TLConstructedValue>((int32_t)0xf6311a80, value));
    }
}


@end

@implementation TLChannelAdminLogEventAction$channelAdminLogEventActionParticipantToggleAdmin : TLChannelAdminLogEventAction


- (int32_t)TLconstructorSignature
{
    return (int32_t)0xd5676710;
}

- (int32_t)TLconstructorName
{
    return (int32_t)0xc3c7a1b2;
}

- (id<TLObject>)TLbuildFromMetaObject:(std::shared_ptr<TLMetaObject>)metaObject
{
    TLChannelAdminLogEventAction$channelAdminLogEventActionParticipantToggleAdmin *object = [[TLChannelAdminLogEventAction$channelAdminLogEventActionParticipantToggleAdmin alloc] init];
    object.prev_participant = metaObject->getObject((int32_t)0x25d6d4b8);
    object.n_new_participant = metaObject->getObject((int32_t)0xf6311a80);
    return object;
}

- (void)TLfillFieldsWithValues:(std::map<int32_t, TLConstructedValue> *)values
{
    {
        TLConstructedValue value;
        value.type = TLConstructedValueTypeObject;
        value.nativeObject = self.prev_participant;
        values->insert(std::pair<int32_t, TLConstructedValue>((int32_t)0x25d6d4b8, value));
    }
    {
        TLConstructedValue value;
        value.type = TLConstructedValueTypeObject;
        value.nativeObject = self.n_new_participant;
        values->insert(std::pair<int32_t, TLConstructedValue>((int32_t)0xf6311a80, value));
    }
}


@end

