#import "TLChannelAdminLogEvent.h"

#import "../NSInputStream+TL.h"
#import "../NSOutputStream+TL.h"

#import "TLChannelAdminLogEventAction.h"

@implementation TLChannelAdminLogEvent


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

@implementation TLChannelAdminLogEvent$channelAdminLogEvent : TLChannelAdminLogEvent


- (int32_t)TLconstructorSignature
{
    return (int32_t)0x3b5a3e40;
}

- (int32_t)TLconstructorName
{
    return (int32_t)0xea4139da;
}

- (id<TLObject>)TLbuildFromMetaObject:(std::shared_ptr<TLMetaObject>)metaObject
{
    TLChannelAdminLogEvent$channelAdminLogEvent *object = [[TLChannelAdminLogEvent$channelAdminLogEvent alloc] init];
    object.n_id = metaObject->getInt64((int32_t)0x7a5601fb);
    object.date = metaObject->getInt32((int32_t)0xb76958ba);
    object.user_id = metaObject->getInt32((int32_t)0xafdf4073);
    object.action = metaObject->getObject((int32_t)0xc2d4a0f7);
    return object;
}

- (void)TLfillFieldsWithValues:(std::map<int32_t, TLConstructedValue> *)values
{
    {
        TLConstructedValue value;
        value.type = TLConstructedValueTypePrimitiveInt64;
        value.primitive.int64Value = self.n_id;
        values->insert(std::pair<int32_t, TLConstructedValue>((int32_t)0x7a5601fb, value));
    }
    {
        TLConstructedValue value;
        value.type = TLConstructedValueTypePrimitiveInt32;
        value.primitive.int32Value = self.date;
        values->insert(std::pair<int32_t, TLConstructedValue>((int32_t)0xb76958ba, value));
    }
    {
        TLConstructedValue value;
        value.type = TLConstructedValueTypePrimitiveInt32;
        value.primitive.int32Value = self.user_id;
        values->insert(std::pair<int32_t, TLConstructedValue>((int32_t)0xafdf4073, value));
    }
    {
        TLConstructedValue value;
        value.type = TLConstructedValueTypeObject;
        value.nativeObject = self.action;
        values->insert(std::pair<int32_t, TLConstructedValue>((int32_t)0xc2d4a0f7, value));
    }
}


@end

