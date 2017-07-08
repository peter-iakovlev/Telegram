#import "TLRPCping_delay_disconnect.h"

#import "../NSInputStream+TL.h"
#import "../NSOutputStream+TL.h"

#import "TLPong.h"

@implementation TLRPCping_delay_disconnect


- (Class)responseClass
{
    return [TLPong class];
}

- (int)impliedResponseSignature
{
    return (int)0x347773c5;
}

- (int)layerVersion
{
    return 0;
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

@implementation TLRPCping_delay_disconnect$ping_delay_disconnect : TLRPCping_delay_disconnect


- (int32_t)TLconstructorSignature
{
    return (int32_t)0xf3427b8c;
}

- (int32_t)TLconstructorName
{
    return (int32_t)0x14c36a18;
}

- (id<TLObject>)TLbuildFromMetaObject:(std::shared_ptr<TLMetaObject>)metaObject
{
    TLRPCping_delay_disconnect$ping_delay_disconnect *object = [[TLRPCping_delay_disconnect$ping_delay_disconnect alloc] init];
    object.ping_id = metaObject->getInt64((int32_t)0x357f0145);
    object.disconnect_delay = metaObject->getInt32((int32_t)0x10283039);
    return object;
}

- (void)TLfillFieldsWithValues:(std::map<int32_t, TLConstructedValue> *)values
{
    {
        TLConstructedValue value;
        value.type = TLConstructedValueTypePrimitiveInt64;
        value.primitive.int64Value = self.ping_id;
        values->insert(std::pair<int32_t, TLConstructedValue>((int32_t)0x357f0145, value));
    }
    {
        TLConstructedValue value;
        value.type = TLConstructedValueTypePrimitiveInt32;
        value.primitive.int32Value = self.disconnect_delay;
        values->insert(std::pair<int32_t, TLConstructedValue>((int32_t)0x10283039, value));
    }
}


@end

