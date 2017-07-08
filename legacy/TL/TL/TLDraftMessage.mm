#import "TLDraftMessage.h"

#import "../NSInputStream+TL.h"
#import "../NSOutputStream+TL.h"


@implementation TLDraftMessage


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

@implementation TLDraftMessage$draftMessageEmpty : TLDraftMessage


- (int32_t)TLconstructorSignature
{
    return (int32_t)0xba4baec5;
}

- (int32_t)TLconstructorName
{
    return (int32_t)0xd158331f;
}

- (id<TLObject>)TLbuildFromMetaObject:(std::shared_ptr<TLMetaObject>)__unused metaObject
{
    TLDraftMessage$draftMessageEmpty *object = [[TLDraftMessage$draftMessageEmpty alloc] init];
    return object;
}

- (void)TLfillFieldsWithValues:(std::map<int32_t, TLConstructedValue> *)__unused values
{
}


@end

@implementation TLDraftMessage$draftMessageMeta : TLDraftMessage


- (int32_t)TLconstructorSignature
{
    return (int32_t)0xd20ec09c;
}

- (int32_t)TLconstructorName
{
    return (int32_t)0x58579bc2;
}

- (id<TLObject>)TLbuildFromMetaObject:(std::shared_ptr<TLMetaObject>)metaObject
{
    TLDraftMessage$draftMessageMeta *object = [[TLDraftMessage$draftMessageMeta alloc] init];
    object.flags = metaObject->getInt32((int32_t)0x81915c23);
    object.reply_to_msg_id = metaObject->getInt32((int32_t)0x598ed37b);
    object.message = metaObject->getString((int32_t)0xc43b7853);
    object.entities = metaObject->getArray((int32_t)0x97759865);
    object.date = metaObject->getInt32((int32_t)0xb76958ba);
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
        value.primitive.int32Value = self.reply_to_msg_id;
        values->insert(std::pair<int32_t, TLConstructedValue>((int32_t)0x598ed37b, value));
    }
    {
        TLConstructedValue value;
        value.type = TLConstructedValueTypeString;
        value.nativeObject = self.message;
        values->insert(std::pair<int32_t, TLConstructedValue>((int32_t)0xc43b7853, value));
    }
    {
        TLConstructedValue value;
        value.type = TLConstructedValueTypeVector;
        value.nativeObject = self.entities;
        values->insert(std::pair<int32_t, TLConstructedValue>((int32_t)0x97759865, value));
    }
    {
        TLConstructedValue value;
        value.type = TLConstructedValueTypePrimitiveInt32;
        value.primitive.int32Value = self.date;
        values->insert(std::pair<int32_t, TLConstructedValue>((int32_t)0xb76958ba, value));
    }
}


@end

