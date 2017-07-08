#import "TLRPCphone_discardCall.h"

#import "../NSInputStream+TL.h"
#import "../NSOutputStream+TL.h"

#import "TLInputPhoneCall.h"
#import "TLPhoneCallDiscardReason.h"
#import "TLUpdates.h"

@implementation TLRPCphone_discardCall


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
    return 64;
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

@implementation TLRPCphone_discardCall$phone_discardCall : TLRPCphone_discardCall


- (int32_t)TLconstructorSignature
{
    return (int32_t)0x78d413a6;
}

- (int32_t)TLconstructorName
{
    return (int32_t)0xf204e6fb;
}

- (id<TLObject>)TLbuildFromMetaObject:(std::shared_ptr<TLMetaObject>)metaObject
{
    TLRPCphone_discardCall$phone_discardCall *object = [[TLRPCphone_discardCall$phone_discardCall alloc] init];
    object.peer = metaObject->getObject((int32_t)0x9344c37d);
    object.duration = metaObject->getInt32((int32_t)0xac00f752);
    object.reason = metaObject->getObject((int32_t)0x3405f57);
    object.connection_id = metaObject->getInt64((int32_t)0x5cb28fa3);
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
        value.primitive.int32Value = self.duration;
        values->insert(std::pair<int32_t, TLConstructedValue>((int32_t)0xac00f752, value));
    }
    {
        TLConstructedValue value;
        value.type = TLConstructedValueTypeObject;
        value.nativeObject = self.reason;
        values->insert(std::pair<int32_t, TLConstructedValue>((int32_t)0x3405f57, value));
    }
    {
        TLConstructedValue value;
        value.type = TLConstructedValueTypePrimitiveInt64;
        value.primitive.int64Value = self.connection_id;
        values->insert(std::pair<int32_t, TLConstructedValue>((int32_t)0x5cb28fa3, value));
    }
}


@end

