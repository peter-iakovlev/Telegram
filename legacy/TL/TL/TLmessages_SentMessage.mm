#import "TLmessages_SentMessage.h"

#import "../NSInputStream+TL.h"
#import "../NSOutputStream+TL.h"


@implementation TLmessages_SentMessage


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

- (id<TLObject>)TLbuildFromMetaObject:(std::tr1::shared_ptr<TLMetaObject>)__unused metaObject
{
    TGLog(@"TLbuildFromMetaObject is not implemented for base type");
    return nil;
}

- (void)TLfillFieldsWithValues:(std::map<int32_t, TLConstructedValue> *)__unused values
{
    TGLog(@"TLfillFieldsWithValues is not implemented for base type");
}


@end

@implementation TLmessages_SentMessage$messages_sentMessage : TLmessages_SentMessage


- (int32_t)TLconstructorSignature
{
    return (int32_t)0xd1f4d35c;
}

- (int32_t)TLconstructorName
{
    return (int32_t)0x2be5d2bd;
}

- (id<TLObject>)TLbuildFromMetaObject:(std::tr1::shared_ptr<TLMetaObject>)metaObject
{
    TLmessages_SentMessage$messages_sentMessage *object = [[TLmessages_SentMessage$messages_sentMessage alloc] init];
    object.n_id = metaObject->getInt32((int32_t)0x7a5601fb);
    object.date = metaObject->getInt32((int32_t)0xb76958ba);
    object.pts = metaObject->getInt32((int32_t)0x4fc5f572);
    object.seq = metaObject->getInt32((int32_t)0xc769ed79);
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
    {
        TLConstructedValue value;
        value.type = TLConstructedValueTypePrimitiveInt32;
        value.primitive.int32Value = self.date;
        values->insert(std::pair<int32_t, TLConstructedValue>((int32_t)0xb76958ba, value));
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
        value.primitive.int32Value = self.seq;
        values->insert(std::pair<int32_t, TLConstructedValue>((int32_t)0xc769ed79, value));
    }
}


@end

@implementation TLmessages_SentMessage$messages_sentMessageLink : TLmessages_SentMessage


- (int32_t)TLconstructorSignature
{
    return (int32_t)0xe9db4a3f;
}

- (int32_t)TLconstructorName
{
    return (int32_t)0x1e145f5d;
}

- (id<TLObject>)TLbuildFromMetaObject:(std::tr1::shared_ptr<TLMetaObject>)metaObject
{
    TLmessages_SentMessage$messages_sentMessageLink *object = [[TLmessages_SentMessage$messages_sentMessageLink alloc] init];
    object.n_id = metaObject->getInt32((int32_t)0x7a5601fb);
    object.date = metaObject->getInt32((int32_t)0xb76958ba);
    object.pts = metaObject->getInt32((int32_t)0x4fc5f572);
    object.seq = metaObject->getInt32((int32_t)0xc769ed79);
    object.links = metaObject->getArray((int32_t)0x1660f3a7);
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
    {
        TLConstructedValue value;
        value.type = TLConstructedValueTypePrimitiveInt32;
        value.primitive.int32Value = self.date;
        values->insert(std::pair<int32_t, TLConstructedValue>((int32_t)0xb76958ba, value));
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
        value.primitive.int32Value = self.seq;
        values->insert(std::pair<int32_t, TLConstructedValue>((int32_t)0xc769ed79, value));
    }
    {
        TLConstructedValue value;
        value.type = TLConstructedValueTypeVector;
        value.nativeObject = self.links;
        values->insert(std::pair<int32_t, TLConstructedValue>((int32_t)0x1660f3a7, value));
    }
}


@end

