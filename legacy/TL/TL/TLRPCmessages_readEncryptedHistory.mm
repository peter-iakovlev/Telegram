#import "TLRPCmessages_readEncryptedHistory.h"

#import "../NSInputStream+TL.h"
#import "../NSOutputStream+TL.h"

#import "TLInputEncryptedChat.h"

@implementation TLRPCmessages_readEncryptedHistory


- (Class)responseClass
{
    return [NSNumber class];
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

@implementation TLRPCmessages_readEncryptedHistory$messages_readEncryptedHistory : TLRPCmessages_readEncryptedHistory


- (int32_t)TLconstructorSignature
{
    return (int32_t)0x7f4b690a;
}

- (int32_t)TLconstructorName
{
    return (int32_t)0x35df8fda;
}

- (id<TLObject>)TLbuildFromMetaObject:(std::shared_ptr<TLMetaObject>)metaObject
{
    TLRPCmessages_readEncryptedHistory$messages_readEncryptedHistory *object = [[TLRPCmessages_readEncryptedHistory$messages_readEncryptedHistory alloc] init];
    object.peer = metaObject->getObject((int32_t)0x9344c37d);
    object.max_date = metaObject->getInt32((int32_t)0xf4d47b51);
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
        value.type = TLConstructedValueTypePrimitiveInt32;
        value.primitive.int32Value = self.max_date;
        values->insert(std::pair<int32_t, TLConstructedValue>((int32_t)0xf4d47b51, value));
    }
}


@end

