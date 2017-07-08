#import "TLRPCmessages_startBot.h"

#import "../NSInputStream+TL.h"
#import "../NSOutputStream+TL.h"

#import "TLInputUser.h"
#import "TLInputPeer.h"
#import "TLUpdates.h"

@implementation TLRPCmessages_startBot


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
    return 41;
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

@implementation TLRPCmessages_startBot$messages_startBot : TLRPCmessages_startBot


- (int32_t)TLconstructorSignature
{
    return (int32_t)0xe6df7378;
}

- (int32_t)TLconstructorName
{
    return (int32_t)0xabbcf900;
}

- (id<TLObject>)TLbuildFromMetaObject:(std::shared_ptr<TLMetaObject>)metaObject
{
    TLRPCmessages_startBot$messages_startBot *object = [[TLRPCmessages_startBot$messages_startBot alloc] init];
    object.bot = metaObject->getObject((int32_t)0x5b476acc);
    object.peer = metaObject->getObject((int32_t)0x9344c37d);
    object.random_id = metaObject->getInt64((int32_t)0xca5a160a);
    object.start_param = metaObject->getString((int32_t)0x90d398cb);
    return object;
}

- (void)TLfillFieldsWithValues:(std::map<int32_t, TLConstructedValue> *)values
{
    {
        TLConstructedValue value;
        value.type = TLConstructedValueTypeObject;
        value.nativeObject = self.bot;
        values->insert(std::pair<int32_t, TLConstructedValue>((int32_t)0x5b476acc, value));
    }
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
        value.type = TLConstructedValueTypeString;
        value.nativeObject = self.start_param;
        values->insert(std::pair<int32_t, TLConstructedValue>((int32_t)0x90d398cb, value));
    }
}


@end

