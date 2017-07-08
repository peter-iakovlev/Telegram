#import "TLRPCmessages_setEncryptedTyping.h"

#import "../NSInputStream+TL.h"
#import "../NSOutputStream+TL.h"

#import "TLInputEncryptedChat.h"

@implementation TLRPCmessages_setEncryptedTyping


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

@implementation TLRPCmessages_setEncryptedTyping$messages_setEncryptedTyping : TLRPCmessages_setEncryptedTyping


- (int32_t)TLconstructorSignature
{
    return (int32_t)0x791451ed;
}

- (int32_t)TLconstructorName
{
    return (int32_t)0x8bb2428d;
}

- (id<TLObject>)TLbuildFromMetaObject:(std::shared_ptr<TLMetaObject>)metaObject
{
    TLRPCmessages_setEncryptedTyping$messages_setEncryptedTyping *object = [[TLRPCmessages_setEncryptedTyping$messages_setEncryptedTyping alloc] init];
    object.peer = metaObject->getObject((int32_t)0x9344c37d);
    object.typing = metaObject->getBool((int32_t)0x77929cef);
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
        value.type = TLConstructedValueTypePrimitiveBool;
        value.primitive.boolValue = self.typing;
        values->insert(std::pair<int32_t, TLConstructedValue>((int32_t)0x77929cef, value));
    }
}


@end

