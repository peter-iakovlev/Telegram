#import "TLupdates_Difference.h"

#import "../NSInputStream+TL.h"
#import "../NSOutputStream+TL.h"

#import "TLupdates_State.h"

@implementation TLupdates_Difference


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

@implementation TLupdates_Difference$updates_differenceEmpty : TLupdates_Difference


- (int32_t)TLconstructorSignature
{
    return (int32_t)0x5d75a138;
}

- (int32_t)TLconstructorName
{
    return (int32_t)0xe47016d4;
}

- (id<TLObject>)TLbuildFromMetaObject:(std::shared_ptr<TLMetaObject>)metaObject
{
    TLupdates_Difference$updates_differenceEmpty *object = [[TLupdates_Difference$updates_differenceEmpty alloc] init];
    object.date = metaObject->getInt32((int32_t)0xb76958ba);
    object.seq = metaObject->getInt32((int32_t)0xc769ed79);
    return object;
}

- (void)TLfillFieldsWithValues:(std::map<int32_t, TLConstructedValue> *)values
{
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

@implementation TLupdates_Difference$updates_difference : TLupdates_Difference


- (int32_t)TLconstructorSignature
{
    return (int32_t)0xf49ca0;
}

- (int32_t)TLconstructorName
{
    return (int32_t)0xc92fa56d;
}

- (id<TLObject>)TLbuildFromMetaObject:(std::shared_ptr<TLMetaObject>)metaObject
{
    TLupdates_Difference$updates_difference *object = [[TLupdates_Difference$updates_difference alloc] init];
    object.n_new_messages = metaObject->getArray((int32_t)0xe7cf9f7c);
    object.n_new_encrypted_messages = metaObject->getArray((int32_t)0xff8a59e6);
    object.other_updates = metaObject->getArray((int32_t)0x91aa7dcd);
    object.chats = metaObject->getArray((int32_t)0x4240ad02);
    object.users = metaObject->getArray((int32_t)0x933e5ff3);
    object.state = metaObject->getObject((int32_t)0x449b9b4e);
    return object;
}

- (void)TLfillFieldsWithValues:(std::map<int32_t, TLConstructedValue> *)values
{
    {
        TLConstructedValue value;
        value.type = TLConstructedValueTypeVector;
        value.nativeObject = self.n_new_messages;
        values->insert(std::pair<int32_t, TLConstructedValue>((int32_t)0xe7cf9f7c, value));
    }
    {
        TLConstructedValue value;
        value.type = TLConstructedValueTypeVector;
        value.nativeObject = self.n_new_encrypted_messages;
        values->insert(std::pair<int32_t, TLConstructedValue>((int32_t)0xff8a59e6, value));
    }
    {
        TLConstructedValue value;
        value.type = TLConstructedValueTypeVector;
        value.nativeObject = self.other_updates;
        values->insert(std::pair<int32_t, TLConstructedValue>((int32_t)0x91aa7dcd, value));
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
    {
        TLConstructedValue value;
        value.type = TLConstructedValueTypeObject;
        value.nativeObject = self.state;
        values->insert(std::pair<int32_t, TLConstructedValue>((int32_t)0x449b9b4e, value));
    }
}


@end

@implementation TLupdates_Difference$updates_differenceSlice : TLupdates_Difference


- (int32_t)TLconstructorSignature
{
    return (int32_t)0xa8fb1981;
}

- (int32_t)TLconstructorName
{
    return (int32_t)0xb6d9f085;
}

- (id<TLObject>)TLbuildFromMetaObject:(std::shared_ptr<TLMetaObject>)metaObject
{
    TLupdates_Difference$updates_differenceSlice *object = [[TLupdates_Difference$updates_differenceSlice alloc] init];
    object.n_new_messages = metaObject->getArray((int32_t)0xe7cf9f7c);
    object.n_new_encrypted_messages = metaObject->getArray((int32_t)0xff8a59e6);
    object.other_updates = metaObject->getArray((int32_t)0x91aa7dcd);
    object.chats = metaObject->getArray((int32_t)0x4240ad02);
    object.users = metaObject->getArray((int32_t)0x933e5ff3);
    object.intermediate_state = metaObject->getObject((int32_t)0xc976b11c);
    return object;
}

- (void)TLfillFieldsWithValues:(std::map<int32_t, TLConstructedValue> *)values
{
    {
        TLConstructedValue value;
        value.type = TLConstructedValueTypeVector;
        value.nativeObject = self.n_new_messages;
        values->insert(std::pair<int32_t, TLConstructedValue>((int32_t)0xe7cf9f7c, value));
    }
    {
        TLConstructedValue value;
        value.type = TLConstructedValueTypeVector;
        value.nativeObject = self.n_new_encrypted_messages;
        values->insert(std::pair<int32_t, TLConstructedValue>((int32_t)0xff8a59e6, value));
    }
    {
        TLConstructedValue value;
        value.type = TLConstructedValueTypeVector;
        value.nativeObject = self.other_updates;
        values->insert(std::pair<int32_t, TLConstructedValue>((int32_t)0x91aa7dcd, value));
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
    {
        TLConstructedValue value;
        value.type = TLConstructedValueTypeObject;
        value.nativeObject = self.intermediate_state;
        values->insert(std::pair<int32_t, TLConstructedValue>((int32_t)0xc976b11c, value));
    }
}


@end

@implementation TLupdates_Difference$updates_differenceTooLong : TLupdates_Difference


- (int32_t)TLconstructorSignature
{
    return (int32_t)0x4afe8f6d;
}

- (int32_t)TLconstructorName
{
    return (int32_t)0x3105285b;
}

- (id<TLObject>)TLbuildFromMetaObject:(std::shared_ptr<TLMetaObject>)metaObject
{
    TLupdates_Difference$updates_differenceTooLong *object = [[TLupdates_Difference$updates_differenceTooLong alloc] init];
    object.pts = metaObject->getInt32((int32_t)0x4fc5f572);
    return object;
}

- (void)TLfillFieldsWithValues:(std::map<int32_t, TLConstructedValue> *)values
{
    {
        TLConstructedValue value;
        value.type = TLConstructedValueTypePrimitiveInt32;
        value.primitive.int32Value = self.pts;
        values->insert(std::pair<int32_t, TLConstructedValue>((int32_t)0x4fc5f572, value));
    }
}


@end

