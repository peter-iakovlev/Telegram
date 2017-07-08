#import "TLRPCmessages_receivedMessages.h"

#import "../NSInputStream+TL.h"
#import "../NSOutputStream+TL.h"

#import "NSArray_ReceivedNotifyMessage.h"

@implementation TLRPCmessages_receivedMessages


- (Class)responseClass
{
    return [NSArray class];
}

- (int)impliedResponseSignature
{
    return (int)0xa76738ed;
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

@implementation TLRPCmessages_receivedMessages$messages_receivedMessages : TLRPCmessages_receivedMessages


- (int32_t)TLconstructorSignature
{
    return (int32_t)0x5a954c0;
}

- (int32_t)TLconstructorName
{
    return (int32_t)0x2a5097f5;
}

- (id<TLObject>)TLbuildFromMetaObject:(std::shared_ptr<TLMetaObject>)metaObject
{
    TLRPCmessages_receivedMessages$messages_receivedMessages *object = [[TLRPCmessages_receivedMessages$messages_receivedMessages alloc] init];
    object.max_id = metaObject->getInt32((int32_t)0xe2c00ace);
    return object;
}

- (void)TLfillFieldsWithValues:(std::map<int32_t, TLConstructedValue> *)values
{
    {
        TLConstructedValue value;
        value.type = TLConstructedValueTypePrimitiveInt32;
        value.primitive.int32Value = self.max_id;
        values->insert(std::pair<int32_t, TLConstructedValue>((int32_t)0xe2c00ace, value));
    }
}


@end

