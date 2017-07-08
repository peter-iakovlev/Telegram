#import "TLRPCmessages_sendEncryptedService.h"

#import "../NSInputStream+TL.h"
#import "../NSOutputStream+TL.h"

#import "TLInputEncryptedChat.h"
#import "TLmessages_SentEncryptedMessage.h"

@implementation TLRPCmessages_sendEncryptedService


- (Class)responseClass
{
    return [TLmessages_SentEncryptedMessage class];
}

- (int)impliedResponseSignature
{
    return 0;
}

- (int)layerVersion
{
    return 8;
}

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

@implementation TLRPCmessages_sendEncryptedService$messages_sendEncryptedService : TLRPCmessages_sendEncryptedService


- (int32_t)TLconstructorSignature
{
    return (int32_t)0x32d439a4;
}

- (int32_t)TLconstructorName
{
    return (int32_t)0x748f99f5;
}

- (id<TLObject>)TLbuildFromMetaObject:(std::shared_ptr<TLMetaObject>)metaObject
{
    TLRPCmessages_sendEncryptedService$messages_sendEncryptedService *object = [[TLRPCmessages_sendEncryptedService$messages_sendEncryptedService alloc] init];
    object.peer = metaObject->getObject((int32_t)0x9344c37d);
    object.random_id = metaObject->getInt64((int32_t)0xca5a160a);
    object.data = metaObject->getBytes((int32_t)0xa361765d);
    return object;
}

- (void)TLfillFieldsWithValues:(std::map<int32_t, TLConstructedValue> *)values
{
    {
        TLConstructedValue value;
        value.type = TLConstructedValueTypeObject;
        value.nativeObject = self.peer;
        values->insert(std::pair<int32_t, TLConstructedValue>((int32_t)0x9344c37d, value));
    }
    {
        TLConstructedValue value;
        value.type = TLConstructedValueTypePrimitiveInt64;
        value.primitive.int64Value = self.random_id;
        values->insert(std::pair<int32_t, TLConstructedValue>((int32_t)0xca5a160a, value));
    }
    {
        TLConstructedValue value;
        value.type = TLConstructedValueTypeBytes;
        value.nativeObject = self.data;
        values->insert(std::pair<int32_t, TLConstructedValue>((int32_t)0xa361765d, value));
    }
}


@end

