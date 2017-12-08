#import "TLRPCmessages_getUnreadMentions.h"

#import "../NSInputStream+TL.h"
#import "../NSOutputStream+TL.h"

#import "TLInputPeer.h"
#import "TLmessages_Messages.h"

@implementation TLRPCmessages_getUnreadMentions


- (Class)responseClass
{
    return [TLmessages_Messages class];
}

- (int)impliedResponseSignature
{
    return 0;
}

- (int)layerVersion
{
    return 71;
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

@implementation TLRPCmessages_getUnreadMentions$messages_getUnreadMentions : TLRPCmessages_getUnreadMentions


- (int32_t)TLconstructorSignature
{
    return (int32_t)0x46578472;
}

- (int32_t)TLconstructorName
{
    return (int32_t)0x2f53ea0a;
}

- (id<TLObject>)TLbuildFromMetaObject:(std::shared_ptr<TLMetaObject>)metaObject
{
    TLRPCmessages_getUnreadMentions$messages_getUnreadMentions *object = [[TLRPCmessages_getUnreadMentions$messages_getUnreadMentions alloc] init];
    object.peer = metaObject->getObject((int32_t)0x9344c37d);
    object.offset_id = metaObject->getInt32((int32_t)0x1120a8cd);
    object.add_offset = metaObject->getInt32((int32_t)0xb3d4dff0);
    object.limit = metaObject->getInt32((int32_t)0xb8433fca);
    object.max_id = metaObject->getInt32((int32_t)0xe2c00ace);
    object.min_id = metaObject->getInt32((int32_t)0x52b518c0);
    return object;
}

- (void)TLfillFieldsWithValues:(std::map<int32_t, TLConstructedValue> *)values
{
    {
        TLConstructedValue value;
        value.type = TLConstructedValueTypeObject;
        value.nativeObject = self.peer;
        values->insert(std::pair<int32_t, TLConstructedValue>((int32_t)0x9344c37d, value));
    }
    {
        TLConstructedValue value;
        value.type = TLConstructedValueTypePrimitiveInt32;
        value.primitive.int32Value = self.offset_id;
        values->insert(std::pair<int32_t, TLConstructedValue>((int32_t)0x1120a8cd, value));
    }
    {
        TLConstructedValue value;
        value.type = TLConstructedValueTypePrimitiveInt32;
        value.primitive.int32Value = self.add_offset;
        values->insert(std::pair<int32_t, TLConstructedValue>((int32_t)0xb3d4dff0, value));
    }
    {
        TLConstructedValue value;
        value.type = TLConstructedValueTypePrimitiveInt32;
        value.primitive.int32Value = self.limit;
        values->insert(std::pair<int32_t, TLConstructedValue>((int32_t)0xb8433fca, value));
    }
    {
        TLConstructedValue value;
        value.type = TLConstructedValueTypePrimitiveInt32;
        value.primitive.int32Value = self.max_id;
        values->insert(std::pair<int32_t, TLConstructedValue>((int32_t)0xe2c00ace, value));
    }
    {
        TLConstructedValue value;
        value.type = TLConstructedValueTypePrimitiveInt32;
        value.primitive.int32Value = self.min_id;
        values->insert(std::pair<int32_t, TLConstructedValue>((int32_t)0x52b518c0, value));
    }
}


@end

