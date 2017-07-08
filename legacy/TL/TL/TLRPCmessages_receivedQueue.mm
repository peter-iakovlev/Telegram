#import "TLRPCmessages_receivedQueue.h"

#import "../NSInputStream+TL.h"
#import "../NSOutputStream+TL.h"

#import "NSArray_long.h"

@implementation TLRPCmessages_receivedQueue


- (Class)responseClass
{
    return [NSArray class];
}

- (int)impliedResponseSignature
{
    return (int)0xc734a64e;
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

@implementation TLRPCmessages_receivedQueue$messages_receivedQueue : TLRPCmessages_receivedQueue


- (int32_t)TLconstructorSignature
{
    return (int32_t)0x55a5bb66;
}

- (int32_t)TLconstructorName
{
    return (int32_t)0x790f5df6;
}

- (id<TLObject>)TLbuildFromMetaObject:(std::shared_ptr<TLMetaObject>)metaObject
{
    TLRPCmessages_receivedQueue$messages_receivedQueue *object = [[TLRPCmessages_receivedQueue$messages_receivedQueue alloc] init];
    object.max_qts = metaObject->getInt32((int32_t)0xcea6acce);
    return object;
}

- (void)TLfillFieldsWithValues:(std::map<int32_t, TLConstructedValue> *)values
{
    {
        TLConstructedValue value;
        value.type = TLConstructedValueTypePrimitiveInt32;
        value.primitive.int32Value = self.max_qts;
        values->insert(std::pair<int32_t, TLConstructedValue>((int32_t)0xcea6acce, value));
    }
}


@end

