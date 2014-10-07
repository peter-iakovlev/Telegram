#import "TLRPCmessages_readHistory.h"

#import "../NSInputStream+TL.h"
#import "../NSOutputStream+TL.h"

#import "TLInputPeer.h"
#import "TLmessages_AffectedHistory.h"

@implementation TLRPCmessages_readHistory


- (Class)responseClass
{
    return [TLmessages_AffectedHistory class];
}

- (int)impliedResponseSignature
{
    return (int)0xb7de36f2;
}

- (int)layerVersion
{
    return 17;
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

- (id<TLObject>)TLbuildFromMetaObject:(std::tr1::shared_ptr<TLMetaObject>)__unused metaObject
{
    TGLog(@"TLbuildFromMetaObject is not implemented for base type");
    return nil;
}

- (void)TLfillFieldsWithValues:(std::map<int32_t, TLConstructedValue> *)__unused values
{
    TGLog(@"TLfillFieldsWithValues is not implemented for base type");
}


@end

@implementation TLRPCmessages_readHistory$messages_readHistory : TLRPCmessages_readHistory


- (int32_t)TLconstructorSignature
{
    return (int32_t)0xeed884c6;
}

- (int32_t)TLconstructorName
{
    return (int32_t)0x594626ce;
}

- (id<TLObject>)TLbuildFromMetaObject:(std::tr1::shared_ptr<TLMetaObject>)metaObject
{
    TLRPCmessages_readHistory$messages_readHistory *object = [[TLRPCmessages_readHistory$messages_readHistory alloc] init];
    object.peer = metaObject->getObject((int32_t)0x9344c37d);
    object.max_id = metaObject->getInt32((int32_t)0xe2c00ace);
    object.offset = metaObject->getInt32((int32_t)0xfc56269);
    object.read_contents = metaObject->getBool((int32_t)0xe3a5f15f);
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
        value.primitive.int32Value = self.max_id;
        values->insert(std::pair<int32_t, TLConstructedValue>((int32_t)0xe2c00ace, value));
    }
    {
        TLConstructedValue value;
        value.type = TLConstructedValueTypePrimitiveInt32;
        value.primitive.int32Value = self.offset;
        values->insert(std::pair<int32_t, TLConstructedValue>((int32_t)0xfc56269, value));
    }
    {
        TLConstructedValue value;
        value.type = TLConstructedValueTypePrimitiveBool;
        value.primitive.boolValue = self.read_contents;
        values->insert(std::pair<int32_t, TLConstructedValue>((int32_t)0xe3a5f15f, value));
    }
}


@end

