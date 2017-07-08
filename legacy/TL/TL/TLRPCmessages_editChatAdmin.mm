#import "TLRPCmessages_editChatAdmin.h"

#import "../NSInputStream+TL.h"
#import "../NSOutputStream+TL.h"

#import "TLInputUser.h"

@implementation TLRPCmessages_editChatAdmin


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

@implementation TLRPCmessages_editChatAdmin$messages_editChatAdmin : TLRPCmessages_editChatAdmin


- (int32_t)TLconstructorSignature
{
    return (int32_t)0xa9e69f2e;
}

- (int32_t)TLconstructorName
{
    return (int32_t)0x54cc80d9;
}

- (id<TLObject>)TLbuildFromMetaObject:(std::shared_ptr<TLMetaObject>)metaObject
{
    TLRPCmessages_editChatAdmin$messages_editChatAdmin *object = [[TLRPCmessages_editChatAdmin$messages_editChatAdmin alloc] init];
    object.chat_id = metaObject->getInt32((int32_t)0x7234457c);
    object.user_id = metaObject->getObject((int32_t)0xafdf4073);
    object.is_admin = metaObject->getBool((int32_t)0x41fdf05a);
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
        value.type = TLConstructedValueTypeObject;
        value.nativeObject = self.user_id;
        values->insert(std::pair<int32_t, TLConstructedValue>((int32_t)0xafdf4073, value));
    }
    {
        TLConstructedValue value;
        value.type = TLConstructedValueTypePrimitiveBool;
        value.primitive.boolValue = self.is_admin;
        values->insert(std::pair<int32_t, TLConstructedValue>((int32_t)0x41fdf05a, value));
    }
}


@end

