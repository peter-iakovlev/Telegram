#import "TLDecryptedMessageAction.h"

#import "../NSInputStream+TL.h"
#import "../NSOutputStream+TL.h"


@implementation TLDecryptedMessageAction


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

@implementation TLDecryptedMessageAction$decryptedMessageActionSetMessageTTL : TLDecryptedMessageAction


- (int32_t)TLconstructorSignature
{
    return (int32_t)0xa1733aec;
}

- (int32_t)TLconstructorName
{
    return (int32_t)0xa6a09e05;
}

- (id<TLObject>)TLbuildFromMetaObject:(std::tr1::shared_ptr<TLMetaObject>)metaObject
{
    TLDecryptedMessageAction$decryptedMessageActionSetMessageTTL *object = [[TLDecryptedMessageAction$decryptedMessageActionSetMessageTTL alloc] init];
    object.ttl_seconds = metaObject->getInt32((int32_t)0x401ae035);
    return object;
}

- (void)TLfillFieldsWithValues:(std::map<int32_t, TLConstructedValue> *)values
{
    {
        TLConstructedValue value;
        value.type = TLConstructedValueTypePrimitiveInt32;
        value.primitive.int32Value = self.ttl_seconds;
        values->insert(std::pair<int32_t, TLConstructedValue>((int32_t)0x401ae035, value));
    }
}


@end

@implementation TLDecryptedMessageAction$decryptedMessageActionViewMessage : TLDecryptedMessageAction


- (int32_t)TLconstructorSignature
{
    return (int32_t)0x1e1604f2;
}

- (int32_t)TLconstructorName
{
    return (int32_t)0x6c006311;
}

- (id<TLObject>)TLbuildFromMetaObject:(std::tr1::shared_ptr<TLMetaObject>)metaObject
{
    TLDecryptedMessageAction$decryptedMessageActionViewMessage *object = [[TLDecryptedMessageAction$decryptedMessageActionViewMessage alloc] init];
    object.random_id = metaObject->getInt64((int32_t)0xca5a160a);
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
}


@end

@implementation TLDecryptedMessageAction$decryptedMessageActionScreenshotMessage : TLDecryptedMessageAction


- (int32_t)TLconstructorSignature
{
    return (int32_t)0xb56b1bc5;
}

- (int32_t)TLconstructorName
{
    return (int32_t)0xfbb5e9ad;
}

- (id<TLObject>)TLbuildFromMetaObject:(std::tr1::shared_ptr<TLMetaObject>)metaObject
{
    TLDecryptedMessageAction$decryptedMessageActionScreenshotMessage *object = [[TLDecryptedMessageAction$decryptedMessageActionScreenshotMessage alloc] init];
    object.random_id = metaObject->getInt64((int32_t)0xca5a160a);
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
}


@end

@implementation TLDecryptedMessageAction$decryptedMessageActionScreenshot : TLDecryptedMessageAction


- (int32_t)TLconstructorSignature
{
    return (int32_t)0xd9f5c5d4;
}

- (int32_t)TLconstructorName
{
    return (int32_t)0xa5f1e21e;
}

- (id<TLObject>)TLbuildFromMetaObject:(std::tr1::shared_ptr<TLMetaObject>)__unused metaObject
{
    TLDecryptedMessageAction$decryptedMessageActionScreenshot *object = [[TLDecryptedMessageAction$decryptedMessageActionScreenshot alloc] init];
    return object;
}

- (void)TLfillFieldsWithValues:(std::map<int32_t, TLConstructedValue> *)__unused values
{
}


@end

@implementation TLDecryptedMessageAction$decryptedMessageActionDeleteMessages : TLDecryptedMessageAction


- (int32_t)TLconstructorSignature
{
    return (int32_t)0x65614304;
}

- (int32_t)TLconstructorName
{
    return (int32_t)0x11ba85c;
}

- (id<TLObject>)TLbuildFromMetaObject:(std::tr1::shared_ptr<TLMetaObject>)metaObject
{
    TLDecryptedMessageAction$decryptedMessageActionDeleteMessages *object = [[TLDecryptedMessageAction$decryptedMessageActionDeleteMessages alloc] init];
    object.random_ids = metaObject->getArray((int32_t)0x31af7f5d);
    return object;
}

- (void)TLfillFieldsWithValues:(std::map<int32_t, TLConstructedValue> *)values
{
    {
        TLConstructedValue value;
        value.type = TLConstructedValueTypeVector;
        value.nativeObject = self.random_ids;
        values->insert(std::pair<int32_t, TLConstructedValue>((int32_t)0x31af7f5d, value));
    }
}


@end

@implementation TLDecryptedMessageAction$decryptedMessageActionFlushHistory : TLDecryptedMessageAction


- (int32_t)TLconstructorSignature
{
    return (int32_t)0x6719e45c;
}

- (int32_t)TLconstructorName
{
    return (int32_t)0x840bb041;
}

- (id<TLObject>)TLbuildFromMetaObject:(std::tr1::shared_ptr<TLMetaObject>)__unused metaObject
{
    TLDecryptedMessageAction$decryptedMessageActionFlushHistory *object = [[TLDecryptedMessageAction$decryptedMessageActionFlushHistory alloc] init];
    return object;
}

- (void)TLfillFieldsWithValues:(std::map<int32_t, TLConstructedValue> *)__unused values
{
}


@end

