#import "TLRPCmessages_forwardMessages.h"

#import "../NSInputStream+TL.h"
#import "../NSOutputStream+TL.h"

#import "TLInputPeer.h"
#import "TLUpdates.h"

@implementation TLRPCmessages_forwardMessages


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
    return 38;
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

@implementation TLRPCmessages_forwardMessages$messages_forwardMessages : TLRPCmessages_forwardMessages


- (int32_t)TLconstructorSignature
{
    return (int32_t)0x708e0195;
}

- (int32_t)TLconstructorName
{
    return (int32_t)0xc5e10c1e;
}

- (id<TLObject>)TLbuildFromMetaObject:(std::shared_ptr<TLMetaObject>)metaObject
{
    TLRPCmessages_forwardMessages$messages_forwardMessages *object = [[TLRPCmessages_forwardMessages$messages_forwardMessages alloc] init];
    object.flags = metaObject->getInt32((int32_t)0x81915c23);
    object.from_peer = metaObject->getObject((int32_t)0x680e83e8);
    object.n_id = metaObject->getArray((int32_t)0x7a5601fb);
    object.random_id = metaObject->getArray((int32_t)0xca5a160a);
    object.to_peer = metaObject->getObject((int32_t)0x484673da);
    return object;
}

- (void)TLfillFieldsWithValues:(std::map<int32_t, TLConstructedValue> *)values
{
    {
        TLConstructedValue value;
        value.type = TLConstructedValueTypePrimitiveInt32;
        value.primitive.int32Value = self.flags;
        values->insert(std::pair<int32_t, TLConstructedValue>((int32_t)0x81915c23, value));
    }
    {
        TLConstructedValue value;
        value.type = TLConstructedValueTypeObject;
        value.nativeObject = self.from_peer;
        values->insert(std::pair<int32_t, TLConstructedValue>((int32_t)0x680e83e8, value));
    }
    {
        TLConstructedValue value;
        value.type = TLConstructedValueTypeVector;
        value.nativeObject = self.n_id;
        values->insert(std::pair<int32_t, TLConstructedValue>((int32_t)0x7a5601fb, value));
    }
    {
        TLConstructedValue value;
        value.type = TLConstructedValueTypeVector;
        value.nativeObject = self.random_id;
        values->insert(std::pair<int32_t, TLConstructedValue>((int32_t)0xca5a160a, value));
    }
    {
        TLConstructedValue value;
        value.type = TLConstructedValueTypeObject;
        value.nativeObject = self.to_peer;
        values->insert(std::pair<int32_t, TLConstructedValue>((int32_t)0x484673da, value));
    }
}


@end

