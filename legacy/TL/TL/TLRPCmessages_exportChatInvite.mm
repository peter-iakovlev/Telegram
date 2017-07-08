#import "TLRPCmessages_exportChatInvite.h"

#import "../NSInputStream+TL.h"
#import "../NSOutputStream+TL.h"

#import "TLExportedChatInvite.h"

@implementation TLRPCmessages_exportChatInvite


- (Class)responseClass
{
    return [TLExportedChatInvite class];
}

- (int)impliedResponseSignature
{
    return 0;
}

- (int)layerVersion
{
    return 28;
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

@implementation TLRPCmessages_exportChatInvite$messages_exportChatInvite : TLRPCmessages_exportChatInvite


- (int32_t)TLconstructorSignature
{
    return (int32_t)0x7d885289;
}

- (int32_t)TLconstructorName
{
    return (int32_t)0x3fe1647c;
}

- (id<TLObject>)TLbuildFromMetaObject:(std::shared_ptr<TLMetaObject>)metaObject
{
    TLRPCmessages_exportChatInvite$messages_exportChatInvite *object = [[TLRPCmessages_exportChatInvite$messages_exportChatInvite alloc] init];
    object.chat_id = metaObject->getInt32((int32_t)0x7234457c);
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
}


@end

