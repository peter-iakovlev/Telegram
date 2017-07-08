#import "TLRPCmessages_getAllChats.h"

#import "../NSInputStream+TL.h"
#import "../NSOutputStream+TL.h"

#import "TLmessages_Chats.h"

@implementation TLRPCmessages_getAllChats


- (Class)responseClass
{
    return [TLmessages_Chats class];
}

- (int)impliedResponseSignature
{
    return 0;
}

- (int)layerVersion
{
    return 58;
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

@implementation TLRPCmessages_getAllChats$messages_getAllChats : TLRPCmessages_getAllChats


- (int32_t)TLconstructorSignature
{
    return (int32_t)0xeba80ff0;
}

- (int32_t)TLconstructorName
{
    return (int32_t)0x8d0f7474;
}

- (id<TLObject>)TLbuildFromMetaObject:(std::shared_ptr<TLMetaObject>)metaObject
{
    TLRPCmessages_getAllChats$messages_getAllChats *object = [[TLRPCmessages_getAllChats$messages_getAllChats alloc] init];
    object.except_ids = metaObject->getArray((int32_t)0xe8276ed2);
    return object;
}

- (void)TLfillFieldsWithValues:(std::map<int32_t, TLConstructedValue> *)values
{
    {
        TLConstructedValue value;
        value.type = TLConstructedValueTypeVector;
        value.nativeObject = self.except_ids;
        values->insert(std::pair<int32_t, TLConstructedValue>((int32_t)0xe8276ed2, value));
    }
}


@end

