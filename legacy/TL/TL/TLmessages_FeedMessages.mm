#import "TLmessages_FeedMessages.h"

#import "../NSInputStream+TL.h"
#import "../NSOutputStream+TL.h"

#import "TLFeedPosition.h"

@implementation TLmessages_FeedMessages


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

@implementation TLmessages_FeedMessages$messages_feedMessagesNotModified : TLmessages_FeedMessages


- (int32_t)TLconstructorSignature
{
    return (int32_t)0x4678d0cf;
}

- (int32_t)TLconstructorName
{
    return (int32_t)0x24e69b83;
}

- (id<TLObject>)TLbuildFromMetaObject:(std::shared_ptr<TLMetaObject>)__unused metaObject
{
    TLmessages_FeedMessages$messages_feedMessagesNotModified *object = [[TLmessages_FeedMessages$messages_feedMessagesNotModified alloc] init];
    return object;
}

- (void)TLfillFieldsWithValues:(std::map<int32_t, TLConstructedValue> *)__unused values
{
}


@end

@implementation TLmessages_FeedMessages$messages_feedMessagesMeta : TLmessages_FeedMessages


- (int32_t)TLconstructorSignature
{
    return (int32_t)0x55c3a1b1;
}

- (int32_t)TLconstructorName
{
    return (int32_t)0xdac1627e;
}

- (id<TLObject>)TLbuildFromMetaObject:(std::shared_ptr<TLMetaObject>)metaObject
{
    TLmessages_FeedMessages$messages_feedMessagesMeta *object = [[TLmessages_FeedMessages$messages_feedMessagesMeta alloc] init];
    object.flags = metaObject->getInt32((int32_t)0x81915c23);
    object.max_position = metaObject->getObject((int32_t)0x7d9baa49);
    object.min_position = metaObject->getObject((int32_t)0x7cac5735);
    object.messages = metaObject->getObject((int32_t)0x8c97b94f);
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
        value.type = TLConstructedValueTypeObject;
        value.nativeObject = self.max_position;
        values->insert(std::pair<int32_t, TLConstructedValue>((int32_t)0x7d9baa49, value));
    }
    {
        TLConstructedValue value;
        value.type = TLConstructedValueTypeObject;
        value.nativeObject = self.min_position;
        values->insert(std::pair<int32_t, TLConstructedValue>((int32_t)0x7cac5735, value));
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
