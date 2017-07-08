#import "TLRPCmessages_acceptEncryption.h"

#import "../NSInputStream+TL.h"
#import "../NSOutputStream+TL.h"

#import "TLInputEncryptedChat.h"
#import "TLEncryptedChat.h"

@implementation TLRPCmessages_acceptEncryption


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

@implementation TLRPCmessages_acceptEncryption$messages_acceptEncryption : TLRPCmessages_acceptEncryption


- (int32_t)TLconstructorSignature
{
    return (int32_t)0x3dbc0415;
}

- (int32_t)TLconstructorName
{
    return (int32_t)0xd836a254;
}

- (id<TLObject>)TLbuildFromMetaObject:(std::shared_ptr<TLMetaObject>)metaObject
{
    TLRPCmessages_acceptEncryption$messages_acceptEncryption *object = [[TLRPCmessages_acceptEncryption$messages_acceptEncryption alloc] init];
    object.peer = metaObject->getObject((int32_t)0x9344c37d);
    object.g_b = metaObject->getBytes((int32_t)0x5643e234);
    object.key_fingerprint = metaObject->getInt64((int32_t)0x3633de43);
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
        value.type = TLConstructedValueTypeBytes;
        value.nativeObject = self.g_b;
        values->insert(std::pair<int32_t, TLConstructedValue>((int32_t)0x5643e234, value));
    }
    {
        TLConstructedValue value;
        value.type = TLConstructedValueTypePrimitiveInt64;
        value.primitive.int64Value = self.key_fingerprint;
        values->insert(std::pair<int32_t, TLConstructedValue>((int32_t)0x3633de43, value));
    }
}


@end

