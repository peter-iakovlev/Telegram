#import "TLmessages_SentEncryptedMessage.h"

#import "../NSInputStream+TL.h"
#import "../NSOutputStream+TL.h"

#import "TLEncryptedFile.h"

@implementation TLmessages_SentEncryptedMessage


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

@implementation TLmessages_SentEncryptedMessage$messages_sentEncryptedMessage : TLmessages_SentEncryptedMessage


- (int32_t)TLconstructorSignature
{
    return (int32_t)0x560f8935;
}

- (int32_t)TLconstructorName
{
    return (int32_t)0x3870329c;
}

- (id<TLObject>)TLbuildFromMetaObject:(std::shared_ptr<TLMetaObject>)metaObject
{
    TLmessages_SentEncryptedMessage$messages_sentEncryptedMessage *object = [[TLmessages_SentEncryptedMessage$messages_sentEncryptedMessage alloc] init];
    object.date = metaObject->getInt32((int32_t)0xb76958ba);
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
}


@end

@implementation TLmessages_SentEncryptedMessage$messages_sentEncryptedFile : TLmessages_SentEncryptedMessage


- (int32_t)TLconstructorSignature
{
    return (int32_t)0x9493ff32;
}

- (int32_t)TLconstructorName
{
    return (int32_t)0xb2f767d7;
}

- (id<TLObject>)TLbuildFromMetaObject:(std::shared_ptr<TLMetaObject>)metaObject
{
    TLmessages_SentEncryptedMessage$messages_sentEncryptedFile *object = [[TLmessages_SentEncryptedMessage$messages_sentEncryptedFile alloc] init];
    object.date = metaObject->getInt32((int32_t)0xb76958ba);
    object.file = metaObject->getObject((int32_t)0x3187ec9);
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
        value.type = TLConstructedValueTypeObject;
        value.nativeObject = self.file;
        values->insert(std::pair<int32_t, TLConstructedValue>((int32_t)0x3187ec9, value));
    }
}


@end

