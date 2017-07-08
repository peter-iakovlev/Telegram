#import "TLDialog.h"

#import "../NSInputStream+TL.h"
#import "../NSOutputStream+TL.h"

#import "TLPeer.h"
#import "TLPeerNotifySettings.h"
#import "TLDraftMessage.h"

@implementation TLDialog


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

@implementation TLDialog$dialogMeta : TLDialog


- (int32_t)TLconstructorSignature
{
    return (int32_t)0x96518a23;
}

- (int32_t)TLconstructorName
{
    return (int32_t)0x7e8654c8;
}

- (id<TLObject>)TLbuildFromMetaObject:(std::shared_ptr<TLMetaObject>)metaObject
{
    TLDialog$dialogMeta *object = [[TLDialog$dialogMeta alloc] init];
    object.flags = metaObject->getInt32((int32_t)0x81915c23);
    object.peer = metaObject->getObject((int32_t)0x9344c37d);
    object.top_message = metaObject->getInt32((int32_t)0x8cecb775);
    object.read_inbox_max_id = metaObject->getInt32((int32_t)0xf4c35301);
    object.read_outbox_max_id = metaObject->getInt32((int32_t)0x2317b2ad);
    object.unread_count = metaObject->getInt32((int32_t)0xa6b586be);
    object.notify_settings = metaObject->getObject((int32_t)0xfa59265);
    object.pts = metaObject->getInt32((int32_t)0x4fc5f572);
    object.draft = metaObject->getObject((int32_t)0x67a43482);
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
        value.nativeObject = self.peer;
        values->insert(std::pair<int32_t, TLConstructedValue>((int32_t)0x9344c37d, value));
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
        value.type = TLConstructedValueTypeObject;
        value.nativeObject = self.notify_settings;
        values->insert(std::pair<int32_t, TLConstructedValue>((int32_t)0xfa59265, value));
    }
    {
        TLConstructedValue value;
        value.type = TLConstructedValueTypePrimitiveInt32;
        value.primitive.int32Value = self.pts;
        values->insert(std::pair<int32_t, TLConstructedValue>((int32_t)0x4fc5f572, value));
    }
    {
        TLConstructedValue value;
        value.type = TLConstructedValueTypeObject;
        value.nativeObject = self.draft;
        values->insert(std::pair<int32_t, TLConstructedValue>((int32_t)0x67a43482, value));
    }
}


@end

