#import "TLChatParticipant.h"

#import "../NSInputStream+TL.h"
#import "../NSOutputStream+TL.h"


@implementation TLChatParticipant


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

@implementation TLChatParticipant$chatParticipant : TLChatParticipant


- (int32_t)TLconstructorSignature
{
    return (int32_t)0xc8d7493e;
}

- (int32_t)TLconstructorName
{
    return (int32_t)0xbb7c75d2;
}

- (id<TLObject>)TLbuildFromMetaObject:(std::shared_ptr<TLMetaObject>)metaObject
{
    TLChatParticipant$chatParticipant *object = [[TLChatParticipant$chatParticipant alloc] init];
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

@implementation TLChatParticipant$chatParticipantCreator : TLChatParticipant


- (int32_t)TLconstructorSignature
{
    return (int32_t)0xda13538a;
}

- (int32_t)TLconstructorName
{
    return (int32_t)0x3eceaec9;
}

- (id<TLObject>)TLbuildFromMetaObject:(std::shared_ptr<TLMetaObject>)metaObject
{
    TLChatParticipant$chatParticipantCreator *object = [[TLChatParticipant$chatParticipantCreator alloc] init];
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

@implementation TLChatParticipant$chatParticipantAdmin : TLChatParticipant


- (int32_t)TLconstructorSignature
{
    return (int32_t)0xe2d6e436;
}

- (int32_t)TLconstructorName
{
    return (int32_t)0x22e1e015;
}

- (id<TLObject>)TLbuildFromMetaObject:(std::shared_ptr<TLMetaObject>)metaObject
{
    TLChatParticipant$chatParticipantAdmin *object = [[TLChatParticipant$chatParticipantAdmin alloc] init];
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

