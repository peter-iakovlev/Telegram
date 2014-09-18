#import "TLUpdates.h"

#import "../NSInputStream+TL.h"
#import "../NSOutputStream+TL.h"

#import "TLUpdate.h"

@implementation TLUpdates


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

@implementation TLUpdates$updatesTooLong : TLUpdates


- (int32_t)TLconstructorSignature
{
    return (int32_t)0xe317af7e;
}

- (int32_t)TLconstructorName
{
    return (int32_t)0xbd35b7ee;
}

- (id<TLObject>)TLbuildFromMetaObject:(std::tr1::shared_ptr<TLMetaObject>)__unused metaObject
{
    TLUpdates$updatesTooLong *object = [[TLUpdates$updatesTooLong alloc] init];
    return object;
}

- (void)TLfillFieldsWithValues:(std::map<int32_t, TLConstructedValue> *)__unused values
{
}


@end

@implementation TLUpdates$updateShortMessage : TLUpdates


- (int32_t)TLconstructorSignature
{
    return (int32_t)0xd3f45784;
}

- (int32_t)TLconstructorName
{
    return (int32_t)0xa4b24a6d;
}

- (id<TLObject>)TLbuildFromMetaObject:(std::tr1::shared_ptr<TLMetaObject>)metaObject
{
    TLUpdates$updateShortMessage *object = [[TLUpdates$updateShortMessage alloc] init];
    object.n_id = metaObject->getInt32((int32_t)0x7a5601fb);
    object.from_id = metaObject->getInt32((int32_t)0xf39a7861);
    object.message = metaObject->getString((int32_t)0xc43b7853);
    object.pts = metaObject->getInt32((int32_t)0x4fc5f572);
    object.date = metaObject->getInt32((int32_t)0xb76958ba);
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
        value.primitive.int32Value = self.from_id;
        values->insert(std::pair<int32_t, TLConstructedValue>((int32_t)0xf39a7861, value));
    }
    {
        TLConstructedValue value;
        value.type = TLConstructedValueTypeString;
        value.nativeObject = self.message;
        values->insert(std::pair<int32_t, TLConstructedValue>((int32_t)0xc43b7853, value));
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
        value.primitive.int32Value = self.date;
        values->insert(std::pair<int32_t, TLConstructedValue>((int32_t)0xb76958ba, value));
    }
    {
        TLConstructedValue value;
        value.type = TLConstructedValueTypePrimitiveInt32;
        value.primitive.int32Value = self.seq;
        values->insert(std::pair<int32_t, TLConstructedValue>((int32_t)0xc769ed79, value));
    }
}


@end

@implementation TLUpdates$updateShortChatMessage : TLUpdates


- (int32_t)TLconstructorSignature
{
    return (int32_t)0x2b2fbd4e;
}

- (int32_t)TLconstructorName
{
    return (int32_t)0x547ac969;
}

- (id<TLObject>)TLbuildFromMetaObject:(std::tr1::shared_ptr<TLMetaObject>)metaObject
{
    TLUpdates$updateShortChatMessage *object = [[TLUpdates$updateShortChatMessage alloc] init];
    object.n_id = metaObject->getInt32((int32_t)0x7a5601fb);
    object.from_id = metaObject->getInt32((int32_t)0xf39a7861);
    object.chat_id = metaObject->getInt32((int32_t)0x7234457c);
    object.message = metaObject->getString((int32_t)0xc43b7853);
    object.pts = metaObject->getInt32((int32_t)0x4fc5f572);
    object.date = metaObject->getInt32((int32_t)0xb76958ba);
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
        value.primitive.int32Value = self.from_id;
        values->insert(std::pair<int32_t, TLConstructedValue>((int32_t)0xf39a7861, value));
    }
    {
        TLConstructedValue value;
        value.type = TLConstructedValueTypePrimitiveInt32;
        value.primitive.int32Value = self.chat_id;
        values->insert(std::pair<int32_t, TLConstructedValue>((int32_t)0x7234457c, value));
    }
    {
        TLConstructedValue value;
        value.type = TLConstructedValueTypeString;
        value.nativeObject = self.message;
        values->insert(std::pair<int32_t, TLConstructedValue>((int32_t)0xc43b7853, value));
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
        value.primitive.int32Value = self.date;
        values->insert(std::pair<int32_t, TLConstructedValue>((int32_t)0xb76958ba, value));
    }
    {
        TLConstructedValue value;
        value.type = TLConstructedValueTypePrimitiveInt32;
        value.primitive.int32Value = self.seq;
        values->insert(std::pair<int32_t, TLConstructedValue>((int32_t)0xc769ed79, value));
    }
}


@end

@implementation TLUpdates$updateShort : TLUpdates


- (int32_t)TLconstructorSignature
{
    return (int32_t)0x78d4dec1;
}

- (int32_t)TLconstructorName
{
    return (int32_t)0xccd3026b;
}

- (id<TLObject>)TLbuildFromMetaObject:(std::tr1::shared_ptr<TLMetaObject>)metaObject
{
    TLUpdates$updateShort *object = [[TLUpdates$updateShort alloc] init];
    object.update = metaObject->getObject((int32_t)0x88b36c62);
    object.date = metaObject->getInt32((int32_t)0xb76958ba);
    return object;
}

- (void)TLfillFieldsWithValues:(std::map<int32_t, TLConstructedValue> *)values
{
    {
        TLConstructedValue value;
        value.type = TLConstructedValueTypeObject;
        value.nativeObject = self.update;
        values->insert(std::pair<int32_t, TLConstructedValue>((int32_t)0x88b36c62, value));
    }
    {
        TLConstructedValue value;
        value.type = TLConstructedValueTypePrimitiveInt32;
        value.primitive.int32Value = self.date;
        values->insert(std::pair<int32_t, TLConstructedValue>((int32_t)0xb76958ba, value));
    }
}


@end

@implementation TLUpdates$updatesCombined : TLUpdates


- (int32_t)TLconstructorSignature
{
    return (int32_t)0x725b04c3;
}

- (int32_t)TLconstructorName
{
    return (int32_t)0x83479e5f;
}

- (id<TLObject>)TLbuildFromMetaObject:(std::tr1::shared_ptr<TLMetaObject>)metaObject
{
    TLUpdates$updatesCombined *object = [[TLUpdates$updatesCombined alloc] init];
    object.updates = metaObject->getArray((int32_t)0x9ae046f4);
    object.users = metaObject->getArray((int32_t)0x933e5ff3);
    object.chats = metaObject->getArray((int32_t)0x4240ad02);
    object.date = metaObject->getInt32((int32_t)0xb76958ba);
    object.seq_start = metaObject->getInt32((int32_t)0x4cae688b);
    object.seq = metaObject->getInt32((int32_t)0xc769ed79);
    return object;
}

- (void)TLfillFieldsWithValues:(std::map<int32_t, TLConstructedValue> *)values
{
    {
        TLConstructedValue value;
        value.type = TLConstructedValueTypeVector;
        value.nativeObject = self.updates;
        values->insert(std::pair<int32_t, TLConstructedValue>((int32_t)0x9ae046f4, value));
    }
    {
        TLConstructedValue value;
        value.type = TLConstructedValueTypeVector;
        value.nativeObject = self.users;
        values->insert(std::pair<int32_t, TLConstructedValue>((int32_t)0x933e5ff3, value));
    }
    {
        TLConstructedValue value;
        value.type = TLConstructedValueTypeVector;
        value.nativeObject = self.chats;
        values->insert(std::pair<int32_t, TLConstructedValue>((int32_t)0x4240ad02, value));
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
        value.primitive.int32Value = self.seq_start;
        values->insert(std::pair<int32_t, TLConstructedValue>((int32_t)0x4cae688b, value));
    }
    {
        TLConstructedValue value;
        value.type = TLConstructedValueTypePrimitiveInt32;
        value.primitive.int32Value = self.seq;
        values->insert(std::pair<int32_t, TLConstructedValue>((int32_t)0xc769ed79, value));
    }
}


@end

@implementation TLUpdates$updates : TLUpdates


- (int32_t)TLconstructorSignature
{
    return (int32_t)0x74ae4240;
}

- (int32_t)TLconstructorName
{
    return (int32_t)0x9ae046f4;
}

- (id<TLObject>)TLbuildFromMetaObject:(std::tr1::shared_ptr<TLMetaObject>)metaObject
{
    TLUpdates$updates *object = [[TLUpdates$updates alloc] init];
    object.updates = metaObject->getArray((int32_t)0x9ae046f4);
    object.users = metaObject->getArray((int32_t)0x933e5ff3);
    object.chats = metaObject->getArray((int32_t)0x4240ad02);
    object.date = metaObject->getInt32((int32_t)0xb76958ba);
    object.seq = metaObject->getInt32((int32_t)0xc769ed79);
    return object;
}

- (void)TLfillFieldsWithValues:(std::map<int32_t, TLConstructedValue> *)values
{
    {
        TLConstructedValue value;
        value.type = TLConstructedValueTypeVector;
        value.nativeObject = self.updates;
        values->insert(std::pair<int32_t, TLConstructedValue>((int32_t)0x9ae046f4, value));
    }
    {
        TLConstructedValue value;
        value.type = TLConstructedValueTypeVector;
        value.nativeObject = self.users;
        values->insert(std::pair<int32_t, TLConstructedValue>((int32_t)0x933e5ff3, value));
    }
    {
        TLConstructedValue value;
        value.type = TLConstructedValueTypeVector;
        value.nativeObject = self.chats;
        values->insert(std::pair<int32_t, TLConstructedValue>((int32_t)0x4240ad02, value));
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
        value.primitive.int32Value = self.seq;
        values->insert(std::pair<int32_t, TLConstructedValue>((int32_t)0xc769ed79, value));
    }
}


@end

