#import "TLRPCmessages_getDhConfig.h"

#import "../NSInputStream+TL.h"
#import "../NSOutputStream+TL.h"

#import "TLmessages_DhConfig.h"

@implementation TLRPCmessages_getDhConfig


- (Class)responseClass
{
    return [TLmessages_DhConfig class];
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

@implementation TLRPCmessages_getDhConfig$messages_getDhConfig : TLRPCmessages_getDhConfig


- (int32_t)TLconstructorSignature
{
    return (int32_t)0x26cf8950;
}

- (int32_t)TLconstructorName
{
    return (int32_t)0x1a66479b;
}

- (id<TLObject>)TLbuildFromMetaObject:(std::shared_ptr<TLMetaObject>)metaObject
{
    TLRPCmessages_getDhConfig$messages_getDhConfig *object = [[TLRPCmessages_getDhConfig$messages_getDhConfig alloc] init];
    object.version = metaObject->getInt32((int32_t)0x4ea810e9);
    object.random_length = metaObject->getInt32((int32_t)0x5b2b3b4b);
    return object;
}

- (void)TLfillFieldsWithValues:(std::map<int32_t, TLConstructedValue> *)values
{
    {
        TLConstructedValue value;
        value.type = TLConstructedValueTypePrimitiveInt32;
        value.primitive.int32Value = self.version;
        values->insert(std::pair<int32_t, TLConstructedValue>((int32_t)0x4ea810e9, value));
    }
    {
        TLConstructedValue value;
        value.type = TLConstructedValueTypePrimitiveInt32;
        value.primitive.int32Value = self.random_length;
        values->insert(std::pair<int32_t, TLConstructedValue>((int32_t)0x5b2b3b4b, value));
    }
}


@end

