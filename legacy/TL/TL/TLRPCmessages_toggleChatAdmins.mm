#import "TLRPCmessages_toggleChatAdmins.h"

#import "../NSInputStream+TL.h"
#import "../NSOutputStream+TL.h"

#import "TLUpdates.h"

@implementation TLRPCmessages_toggleChatAdmins


- (Class)responseClass
{
    return [TLUpdates class];
}

- (int)impliedResponseSignature
{
    return 0;
}

- (int)layerVersion
{
    return 40;
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

@implementation TLRPCmessages_toggleChatAdmins$messages_toggleChatAdmins : TLRPCmessages_toggleChatAdmins


- (int32_t)TLconstructorSignature
{
    return (int32_t)0xec8bd9e1;
}

- (int32_t)TLconstructorName
{
    return (int32_t)0xfe61e1ed;
}

- (id<TLObject>)TLbuildFromMetaObject:(std::shared_ptr<TLMetaObject>)metaObject
{
    TLRPCmessages_toggleChatAdmins$messages_toggleChatAdmins *object = [[TLRPCmessages_toggleChatAdmins$messages_toggleChatAdmins alloc] init];
    object.chat_id = metaObject->getInt32((int32_t)0x7234457c);
    object.enabled = metaObject->getBool((int32_t)0x335ec0ee);
    return object;
}

- (void)TLfillFieldsWithValues:(std::map<int32_t, TLConstructedValue> *)values
{
    {
        TLConstructedValue value;
        value.type = TLConstructedValueTypePrimitiveInt32;
        value.primitive.int32Value = self.chat_id;
        values->insert(std::pair<int32_t, TLConstructedValue>((int32_t)0x7234457c, value));
    }
    {
        TLConstructedValue value;
        value.type = TLConstructedValueTypePrimitiveBool;
        value.primitive.boolValue = self.enabled;
        values->insert(std::pair<int32_t, TLConstructedValue>((int32_t)0x335ec0ee, value));
    }
}


@end

