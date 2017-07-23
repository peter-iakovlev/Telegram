#import "TLMessage.h"

#import "../NSInputStream+TL.h"
#import "../NSOutputStream+TL.h"

#import "TLPeer.h"
#import "TLMessageMedia.h"
#import "TLMessageFwdHeader.h"
#import "TLReplyMarkup.h"

@implementation TLMessage


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

@implementation TLMessage$messageEmpty : TLMessage


- (int32_t)TLconstructorSignature
{
    return (int32_t)0x83e5de54;
}

- (int32_t)TLconstructorName
{
    return (int32_t)0x777e7e3c;
}

- (id<TLObject>)TLbuildFromMetaObject:(std::shared_ptr<TLMetaObject>)metaObject
{
    TLMessage$messageEmpty *object = [[TLMessage$messageEmpty alloc] init];
    object.n_id = metaObject->getInt32((int32_t)0x7a5601fb);
    return object;
}

- (void)TLfillFieldsWithValues:(std::map<int32_t, TLConstructedValue> *)values
{
    {
        TLConstructedValue value;
        value.type = TLConstructedValueTypePrimitiveInt32;
        value.primitive.int32Value = self.n_id;
        values->insert(std::pair<int32_t, TLConstructedValue>((int32_t)0x7a5601fb, value));
    }
}


@end

@implementation TLMessage$message : TLMessage


- (int32_t)TLconstructorSignature
{
    return (int32_t)0x567699b3;
}

- (int32_t)TLconstructorName
{
    return (int32_t)0xc43b7853;
}

- (id<TLObject>)TLbuildFromMetaObject:(std::shared_ptr<TLMetaObject>)metaObject
{
    TLMessage$message *object = [[TLMessage$message alloc] init];
    object.flags = metaObject->getInt32((int32_t)0x81915c23);
    object.n_id = metaObject->getInt32((int32_t)0x7a5601fb);
    object.from_id = metaObject->getInt32((int32_t)0xf39a7861);
    object.to_id = metaObject->getObject((int32_t)0x98822893);
    object.date = metaObject->getInt32((int32_t)0xb76958ba);
    object.message = metaObject->getString((int32_t)0xc43b7853);
    object.media = metaObject->getObject((int32_t)0x598de2e7);
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
        value.primitive.int32Value = self.n_id;
        values->insert(std::pair<int32_t, TLConstructedValue>((int32_t)0x7a5601fb, value));
    }
    {
        TLConstructedValue value;
        value.type = TLConstructedValueTypePrimitiveInt32;
        value.primitive.int32Value = self.from_id;
        values->insert(std::pair<int32_t, TLConstructedValue>((int32_t)0xf39a7861, value));
    }
    {
        TLConstructedValue value;
        value.type = TLConstructedValueTypeObject;
        value.nativeObject = self.to_id;
        values->insert(std::pair<int32_t, TLConstructedValue>((int32_t)0x98822893, value));
    }
    {
        TLConstructedValue value;
        value.type = TLConstructedValueTypePrimitiveInt32;
        value.primitive.int32Value = self.date;
        values->insert(std::pair<int32_t, TLConstructedValue>((int32_t)0xb76958ba, value));
    }
    {
        TLConstructedValue value;
        value.type = TLConstructedValueTypeString;
        value.nativeObject = self.message;
        values->insert(std::pair<int32_t, TLConstructedValue>((int32_t)0xc43b7853, value));
    }
    {
        TLConstructedValue value;
        value.type = TLConstructedValueTypeObject;
        value.nativeObject = self.media;
        values->insert(std::pair<int32_t, TLConstructedValue>((int32_t)0x598de2e7, value));
    }
}


@end

@implementation TLMessage$messageMeta : TLMessage


- (int32_t)TLconstructorSignature
{
    return (int32_t)0x6c07448;
}

- (int32_t)TLconstructorName
{
    return (int32_t)0xcffde30d;
}

- (id<TLObject>)TLbuildFromMetaObject:(std::shared_ptr<TLMetaObject>)metaObject
{
    TLMessage$messageMeta *object = [[TLMessage$messageMeta alloc] init];
    object.flags = metaObject->getInt32((int32_t)0x81915c23);
    object.n_id = metaObject->getInt32((int32_t)0x7a5601fb);
    object.from_id = metaObject->getInt32((int32_t)0xf39a7861);
    object.to_id = metaObject->getObject((int32_t)0x98822893);
    object.fwd_from = metaObject->getObject((int32_t)0xe9482124);
    object.via_bot_id = metaObject->getInt32((int32_t)0x5651e2e2);
    object.reply_to_msg_id = metaObject->getInt32((int32_t)0x598ed37b);
    object.date = metaObject->getInt32((int32_t)0xb76958ba);
    object.message = metaObject->getString((int32_t)0xc43b7853);
    object.media = metaObject->getObject((int32_t)0x598de2e7);
    object.reply_markup = metaObject->getObject((int32_t)0x35f2c195);
    object.entities = metaObject->getArray((int32_t)0x97759865);
    object.views = metaObject->getInt32((int32_t)0xe59deddf);
    object.edit_date = metaObject->getInt32((int32_t)0xd476805c);
    object.post_author = metaObject->getString((int32_t)0x6d88316);
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
        value.primitive.int32Value = self.n_id;
        values->insert(std::pair<int32_t, TLConstructedValue>((int32_t)0x7a5601fb, value));
    }
    {
        TLConstructedValue value;
        value.type = TLConstructedValueTypePrimitiveInt32;
        value.primitive.int32Value = self.from_id;
        values->insert(std::pair<int32_t, TLConstructedValue>((int32_t)0xf39a7861, value));
    }
    {
        TLConstructedValue value;
        value.type = TLConstructedValueTypeObject;
        value.nativeObject = self.to_id;
        values->insert(std::pair<int32_t, TLConstructedValue>((int32_t)0x98822893, value));
    }
    {
        TLConstructedValue value;
        value.type = TLConstructedValueTypeObject;
        value.nativeObject = self.fwd_from;
        values->insert(std::pair<int32_t, TLConstructedValue>((int32_t)0xe9482124, value));
    }
    {
        TLConstructedValue value;
        value.type = TLConstructedValueTypePrimitiveInt32;
        value.primitive.int32Value = self.via_bot_id;
        values->insert(std::pair<int32_t, TLConstructedValue>((int32_t)0x5651e2e2, value));
    }
    {
        TLConstructedValue value;
        value.type = TLConstructedValueTypePrimitiveInt32;
        value.primitive.int32Value = self.reply_to_msg_id;
        values->insert(std::pair<int32_t, TLConstructedValue>((int32_t)0x598ed37b, value));
    }
    {
        TLConstructedValue value;
        value.type = TLConstructedValueTypePrimitiveInt32;
        value.primitive.int32Value = self.date;
        values->insert(std::pair<int32_t, TLConstructedValue>((int32_t)0xb76958ba, value));
    }
    {
        TLConstructedValue value;
        value.type = TLConstructedValueTypeString;
        value.nativeObject = self.message;
        values->insert(std::pair<int32_t, TLConstructedValue>((int32_t)0xc43b7853, value));
    }
    {
        TLConstructedValue value;
        value.type = TLConstructedValueTypeObject;
        value.nativeObject = self.media;
        values->insert(std::pair<int32_t, TLConstructedValue>((int32_t)0x598de2e7, value));
    }
    {
        TLConstructedValue value;
        value.type = TLConstructedValueTypeObject;
        value.nativeObject = self.reply_markup;
        values->insert(std::pair<int32_t, TLConstructedValue>((int32_t)0x35f2c195, value));
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
        value.primitive.int32Value = self.views;
        values->insert(std::pair<int32_t, TLConstructedValue>((int32_t)0xe59deddf, value));
    }
    {
        TLConstructedValue value;
        value.type = TLConstructedValueTypePrimitiveInt32;
        value.primitive.int32Value = self.edit_date;
        values->insert(std::pair<int32_t, TLConstructedValue>((int32_t)0xd476805c, value));
    }
    {
        TLConstructedValue value;
        value.type = TLConstructedValueTypeString;
        value.nativeObject = self.post_author;
        values->insert(std::pair<int32_t, TLConstructedValue>((int32_t)0x6d88316, value));
    }
}


@end

