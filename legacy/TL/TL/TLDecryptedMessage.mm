#import "TLDecryptedMessage.h"

#import "../NSInputStream+TL.h"
#import "../NSOutputStream+TL.h"

#import "TLDecryptedMessageMedia.h"
#import "TLDecryptedMessageAction.h"

@implementation TLDecryptedMessage


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

@implementation TLDecryptedMessage$decryptedMessage : TLDecryptedMessage


- (int32_t)TLconstructorSignature
{
    return (int32_t)0x1f814f1f;
}

- (int32_t)TLconstructorName
{
    return (int32_t)0xf5633b38;
}

- (id<TLObject>)TLbuildFromMetaObject:(std::tr1::shared_ptr<TLMetaObject>)metaObject
{
    TLDecryptedMessage$decryptedMessage *object = [[TLDecryptedMessage$decryptedMessage alloc] init];
    object.random_id = metaObject->getInt64((int32_t)0xca5a160a);
    object.random_bytes = metaObject->getBytes((int32_t)0xaf157b8d);
    object.message = metaObject->getString((int32_t)0xc43b7853);
    object.media = metaObject->getObject((int32_t)0x598de2e7);
    return object;
}

- (void)TLfillFieldsWithValues:(std::map<int32_t, TLConstructedValue> *)values
{
    {
        TLConstructedValue value;
        value.type = TLConstructedValueTypePrimitiveInt64;
        value.primitive.int64Value = self.random_id;
        values->insert(std::pair<int32_t, TLConstructedValue>((int32_t)0xca5a160a, value));
    }
    {
        TLConstructedValue value;
        value.type = TLConstructedValueTypeBytes;
        value.nativeObject = self.random_bytes;
        values->insert(std::pair<int32_t, TLConstructedValue>((int32_t)0xaf157b8d, value));
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

@implementation TLDecryptedMessage$decryptedMessageService : TLDecryptedMessage


- (int32_t)TLconstructorSignature
{
    return (int32_t)0xaa48327d;
}

- (int32_t)TLconstructorName
{
    return (int32_t)0x983ec892;
}

- (id<TLObject>)TLbuildFromMetaObject:(std::tr1::shared_ptr<TLMetaObject>)metaObject
{
    TLDecryptedMessage$decryptedMessageService *object = [[TLDecryptedMessage$decryptedMessageService alloc] init];
    object.random_id = metaObject->getInt64((int32_t)0xca5a160a);
    object.random_bytes = metaObject->getBytes((int32_t)0xaf157b8d);
    object.action = metaObject->getObject((int32_t)0xc2d4a0f7);
    return object;
}

- (void)TLfillFieldsWithValues:(std::map<int32_t, TLConstructedValue> *)values
{
    {
        TLConstructedValue value;
        value.type = TLConstructedValueTypePrimitiveInt64;
        value.primitive.int64Value = self.random_id;
        values->insert(std::pair<int32_t, TLConstructedValue>((int32_t)0xca5a160a, value));
    }
    {
        TLConstructedValue value;
        value.type = TLConstructedValueTypeBytes;
        value.nativeObject = self.random_bytes;
        values->insert(std::pair<int32_t, TLConstructedValue>((int32_t)0xaf157b8d, value));
    }
    {
        TLConstructedValue value;
        value.type = TLConstructedValueTypeObject;
        value.nativeObject = self.action;
        values->insert(std::pair<int32_t, TLConstructedValue>((int32_t)0xc2d4a0f7, value));
    }
}


@end

