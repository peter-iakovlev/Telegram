#import "TLupdates_ChannelDifference.h"

#import "../NSInputStream+TL.h"
#import "../NSOutputStream+TL.h"


@implementation TLupdates_ChannelDifference


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

@implementation TLupdates_ChannelDifference$updates_channelDifferenceMeta : TLupdates_ChannelDifference


- (int32_t)TLconstructorSignature
{
    return (int32_t)0x47ddefe6;
}

- (int32_t)TLconstructorName
{
    return (int32_t)0xfda83d1e;
}

- (id<TLObject>)TLbuildFromMetaObject:(std::shared_ptr<TLMetaObject>)__unused metaObject
{
    TLupdates_ChannelDifference$updates_channelDifferenceMeta *object = [[TLupdates_ChannelDifference$updates_channelDifferenceMeta alloc] init];
    return object;
}

- (void)TLfillFieldsWithValues:(std::map<int32_t, TLConstructedValue> *)__unused values
{
}


@end

@implementation TLupdates_ChannelDifference$updates_channelDifferenceTooLongMeta : TLupdates_ChannelDifference


- (int32_t)TLconstructorSignature
{
    return (int32_t)0x3aeec8d9;
}

- (int32_t)TLconstructorName
{
    return (int32_t)0xbfb5e5f6;
}

- (id<TLObject>)TLbuildFromMetaObject:(std::shared_ptr<TLMetaObject>)metaObject
{
    TLupdates_ChannelDifference$updates_channelDifferenceTooLongMeta *object = [[TLupdates_ChannelDifference$updates_channelDifferenceTooLongMeta alloc] init];
    object.flags = metaObject->getInt32((int32_t)0x81915c23);
    object.pts = metaObject->getInt32((int32_t)0x4fc5f572);
    object.timeout = metaObject->getInt32((int32_t)0xc140a6d8);
    object.top_message = metaObject->getInt32((int32_t)0x8cecb775);
    object.read_inbox_max_id = metaObject->getInt32((int32_t)0xf4c35301);
    object.read_outbox_max_id = metaObject->getInt32((int32_t)0x2317b2ad);
    object.unread_count = metaObject->getInt32((int32_t)0xa6b586be);
    object.unread_mentions_count = metaObject->getInt32((int32_t)0xe73ad0c0);
    object.messages = metaObject->getArray((int32_t)0x8c97b94f);
    object.chats = metaObject->getArray((int32_t)0x4240ad02);
    object.users = metaObject->getArray((int32_t)0x933e5ff3);
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
        value.primitive.int32Value = self.pts;
        values->insert(std::pair<int32_t, TLConstructedValue>((int32_t)0x4fc5f572, value));
    }
    {
        TLConstructedValue value;
        value.type = TLConstructedValueTypePrimitiveInt32;
        value.primitive.int32Value = self.timeout;
        values->insert(std::pair<int32_t, TLConstructedValue>((int32_t)0xc140a6d8, value));
    }
    {
        TLConstructedValue value;
        value.type = TLConstructedValueTypePrimitiveInt32;
        value.primitive.int32Value = self.top_message;
        values->insert(std::pair<int32_t, TLConstructedValue>((int32_t)0x8cecb775, value));
    }
    {
        TLConstructedValue value;
        value.type = TLConstructedValueTypePrimitiveInt32;
        value.primitive.int32Value = self.read_inbox_max_id;
        values->insert(std::pair<int32_t, TLConstructedValue>((int32_t)0xf4c35301, value));
    }
    {
        TLConstructedValue value;
        value.type = TLConstructedValueTypePrimitiveInt32;
        value.primitive.int32Value = self.read_outbox_max_id;
        values->insert(std::pair<int32_t, TLConstructedValue>((int32_t)0x2317b2ad, value));
    }
    {
        TLConstructedValue value;
        value.type = TLConstructedValueTypePrimitiveInt32;
        value.primitive.int32Value = self.unread_count;
        values->insert(std::pair<int32_t, TLConstructedValue>((int32_t)0xa6b586be, value));
    }
    {
        TLConstructedValue value;
        value.type = TLConstructedValueTypePrimitiveInt32;
        value.primitive.int32Value = self.unread_mentions_count;
        values->insert(std::pair<int32_t, TLConstructedValue>((int32_t)0xe73ad0c0, value));
    }
    {
        TLConstructedValue value;
        value.type = TLConstructedValueTypeVector;
        value.nativeObject = self.messages;
        values->insert(std::pair<int32_t, TLConstructedValue>((int32_t)0x8c97b94f, value));
    }
    {
        TLConstructedValue value;
        value.type = TLConstructedValueTypeVector;
        value.nativeObject = self.chats;
        values->insert(std::pair<int32_t, TLConstructedValue>((int32_t)0x4240ad02, value));
    }
    {
        TLConstructedValue value;
        value.type = TLConstructedValueTypeVector;
        value.nativeObject = self.users;
        values->insert(std::pair<int32_t, TLConstructedValue>((int32_t)0x933e5ff3, value));
    }
}


@end

