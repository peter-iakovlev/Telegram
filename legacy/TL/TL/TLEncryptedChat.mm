#import "TLEncryptedChat.h"

#import "../NSInputStream+TL.h"
#import "../NSOutputStream+TL.h"


@implementation TLEncryptedChat


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

@implementation TLEncryptedChat$encryptedChatEmpty : TLEncryptedChat


- (int32_t)TLconstructorSignature
{
    return (int32_t)0xab7ec0a0;
}

- (int32_t)TLconstructorName
{
    return (int32_t)0xd0f49303;
}

- (id<TLObject>)TLbuildFromMetaObject:(std::shared_ptr<TLMetaObject>)metaObject
{
    TLEncryptedChat$encryptedChatEmpty *object = [[TLEncryptedChat$encryptedChatEmpty alloc] init];
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

@implementation TLEncryptedChat$encryptedChatWaiting : TLEncryptedChat


- (int32_t)TLconstructorSignature
{
    return (int32_t)0x3bf703dc;
}

- (int32_t)TLconstructorName
{
    return (int32_t)0x1602df74;
}

- (id<TLObject>)TLbuildFromMetaObject:(std::shared_ptr<TLMetaObject>)metaObject
{
    TLEncryptedChat$encryptedChatWaiting *object = [[TLEncryptedChat$encryptedChatWaiting alloc] init];
    object.n_id = metaObject->getInt32((int32_t)0x7a5601fb);
    object.access_hash = metaObject->getInt64((int32_t)0x8f305224);
    object.date = metaObject->getInt32((int32_t)0xb76958ba);
    object.admin_id = metaObject->getInt32((int32_t)0xdf3d1ee7);
    object.participant_id = metaObject->getInt32((int32_t)0x9abadf01);
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
        value.type = TLConstructedValueTypePrimitiveInt64;
        value.primitive.int64Value = self.access_hash;
        values->insert(std::pair<int32_t, TLConstructedValue>((int32_t)0x8f305224, value));
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
        value.primitive.int32Value = self.admin_id;
        values->insert(std::pair<int32_t, TLConstructedValue>((int32_t)0xdf3d1ee7, value));
    }
    {
        TLConstructedValue value;
        value.type = TLConstructedValueTypePrimitiveInt32;
        value.primitive.int32Value = self.participant_id;
        values->insert(std::pair<int32_t, TLConstructedValue>((int32_t)0x9abadf01, value));
    }
}


@end

@implementation TLEncryptedChat$encryptedChatDiscarded : TLEncryptedChat


- (int32_t)TLconstructorSignature
{
    return (int32_t)0x13d6dd27;
}

- (int32_t)TLconstructorName
{
    return (int32_t)0xe2266ec5;
}

- (id<TLObject>)TLbuildFromMetaObject:(std::shared_ptr<TLMetaObject>)metaObject
{
    TLEncryptedChat$encryptedChatDiscarded *object = [[TLEncryptedChat$encryptedChatDiscarded alloc] init];
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

@implementation TLEncryptedChat$encryptedChatRequested : TLEncryptedChat


- (int32_t)TLconstructorSignature
{
    return (int32_t)0xc878527e;
}

- (int32_t)TLconstructorName
{
    return (int32_t)0x49581c53;
}

- (id<TLObject>)TLbuildFromMetaObject:(std::shared_ptr<TLMetaObject>)metaObject
{
    TLEncryptedChat$encryptedChatRequested *object = [[TLEncryptedChat$encryptedChatRequested alloc] init];
    object.n_id = metaObject->getInt32((int32_t)0x7a5601fb);
    object.access_hash = metaObject->getInt64((int32_t)0x8f305224);
    object.date = metaObject->getInt32((int32_t)0xb76958ba);
    object.admin_id = metaObject->getInt32((int32_t)0xdf3d1ee7);
    object.participant_id = metaObject->getInt32((int32_t)0x9abadf01);
    object.g_a = metaObject->getBytes((int32_t)0xa6887fe5);
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
        value.type = TLConstructedValueTypePrimitiveInt64;
        value.primitive.int64Value = self.access_hash;
        values->insert(std::pair<int32_t, TLConstructedValue>((int32_t)0x8f305224, value));
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
        value.primitive.int32Value = self.admin_id;
        values->insert(std::pair<int32_t, TLConstructedValue>((int32_t)0xdf3d1ee7, value));
    }
    {
        TLConstructedValue value;
        value.type = TLConstructedValueTypePrimitiveInt32;
        value.primitive.int32Value = self.participant_id;
        values->insert(std::pair<int32_t, TLConstructedValue>((int32_t)0x9abadf01, value));
    }
    {
        TLConstructedValue value;
        value.type = TLConstructedValueTypeBytes;
        value.nativeObject = self.g_a;
        values->insert(std::pair<int32_t, TLConstructedValue>((int32_t)0xa6887fe5, value));
    }
}


@end

@implementation TLEncryptedChat$encryptedChat : TLEncryptedChat


- (int32_t)TLconstructorSignature
{
    return (int32_t)0xfa56ce36;
}

- (int32_t)TLconstructorName
{
    return (int32_t)0xd6d39e97;
}

- (id<TLObject>)TLbuildFromMetaObject:(std::shared_ptr<TLMetaObject>)metaObject
{
    TLEncryptedChat$encryptedChat *object = [[TLEncryptedChat$encryptedChat alloc] init];
    object.n_id = metaObject->getInt32((int32_t)0x7a5601fb);
    object.access_hash = metaObject->getInt64((int32_t)0x8f305224);
    object.date = metaObject->getInt32((int32_t)0xb76958ba);
    object.admin_id = metaObject->getInt32((int32_t)0xdf3d1ee7);
    object.participant_id = metaObject->getInt32((int32_t)0x9abadf01);
    object.g_a_or_b = metaObject->getBytes((int32_t)0x817dfd4a);
    object.key_fingerprint = metaObject->getInt64((int32_t)0x3633de43);
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
        value.type = TLConstructedValueTypePrimitiveInt64;
        value.primitive.int64Value = self.access_hash;
        values->insert(std::pair<int32_t, TLConstructedValue>((int32_t)0x8f305224, value));
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
        value.primitive.int32Value = self.admin_id;
        values->insert(std::pair<int32_t, TLConstructedValue>((int32_t)0xdf3d1ee7, value));
    }
    {
        TLConstructedValue value;
        value.type = TLConstructedValueTypePrimitiveInt32;
        value.primitive.int32Value = self.participant_id;
        values->insert(std::pair<int32_t, TLConstructedValue>((int32_t)0x9abadf01, value));
    }
    {
        TLConstructedValue value;
        value.type = TLConstructedValueTypeBytes;
        value.nativeObject = self.g_a_or_b;
        values->insert(std::pair<int32_t, TLConstructedValue>((int32_t)0x817dfd4a, value));
    }
    {
        TLConstructedValue value;
        value.type = TLConstructedValueTypePrimitiveInt64;
        value.primitive.int64Value = self.key_fingerprint;
        values->insert(std::pair<int32_t, TLConstructedValue>((int32_t)0x3633de43, value));
    }
}


@end

