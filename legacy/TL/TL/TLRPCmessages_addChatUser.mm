#import "TLRPCmessages_addChatUser.h"

#import "../NSInputStream+TL.h"
#import "../NSOutputStream+TL.h"

#import "TLInputUser.h"
#import "TLUpdates.h"

@implementation TLRPCmessages_addChatUser


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
    return 26;
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

@implementation TLRPCmessages_addChatUser$messages_addChatUser : TLRPCmessages_addChatUser


- (int32_t)TLconstructorSignature
{
    return (int32_t)0xf9a0aa09;
}

- (int32_t)TLconstructorName
{
    return (int32_t)0x83811712;
}

- (id<TLObject>)TLbuildFromMetaObject:(std::shared_ptr<TLMetaObject>)metaObject
{
    TLRPCmessages_addChatUser$messages_addChatUser *object = [[TLRPCmessages_addChatUser$messages_addChatUser alloc] init];
    object.chat_id = metaObject->getInt32((int32_t)0x7234457c);
    object.user_id = metaObject->getObject((int32_t)0xafdf4073);
    object.fwd_limit = metaObject->getInt32((int32_t)0x84177760);
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
        value.type = TLConstructedValueTypePrimitiveInt32;
        value.primitive.int32Value = self.fwd_limit;
        values->insert(std::pair<int32_t, TLConstructedValue>((int32_t)0x84177760, value));
    }
}


@end

