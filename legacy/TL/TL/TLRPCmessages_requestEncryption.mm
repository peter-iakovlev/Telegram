#import "TLRPCmessages_requestEncryption.h"

#import "../NSInputStream+TL.h"
#import "../NSOutputStream+TL.h"

#import "TLInputUser.h"
#import "TLEncryptedChat.h"

@implementation TLRPCmessages_requestEncryption


- (Class)responseClass
{
    return [TLEncryptedChat class];
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

@implementation TLRPCmessages_requestEncryption$messages_requestEncryption : TLRPCmessages_requestEncryption


- (int32_t)TLconstructorSignature
{
    return (int32_t)0xf64daf43;
}

- (int32_t)TLconstructorName
{
    return (int32_t)0x99df1c99;
}

- (id<TLObject>)TLbuildFromMetaObject:(std::shared_ptr<TLMetaObject>)metaObject
{
    TLRPCmessages_requestEncryption$messages_requestEncryption *object = [[TLRPCmessages_requestEncryption$messages_requestEncryption alloc] init];
    object.user_id = metaObject->getObject((int32_t)0xafdf4073);
    object.random_id = metaObject->getInt32((int32_t)0xca5a160a);
    object.g_a = metaObject->getBytes((int32_t)0xa6887fe5);
    return object;
}

- (void)TLfillFieldsWithValues:(std::map<int32_t, TLConstructedValue> *)values
{
    {
        TLConstructedValue value;
        value.type = TLConstructedValueTypeObject;
        value.nativeObject = self.user_id;
        values->insert(std::pair<int32_t, TLConstructedValue>((int32_t)0xafdf4073, value));
    }
    {
        TLConstructedValue value;
        value.type = TLConstructedValueTypePrimitiveInt32;
        value.primitive.int32Value = self.random_id;
        values->insert(std::pair<int32_t, TLConstructedValue>((int32_t)0xca5a160a, value));
    }
    {
        TLConstructedValue value;
        value.type = TLConstructedValueTypeBytes;
        value.nativeObject = self.g_a;
        values->insert(std::pair<int32_t, TLConstructedValue>((int32_t)0xa6887fe5, value));
    }
}


@end

