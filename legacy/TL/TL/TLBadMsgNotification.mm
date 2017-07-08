#import "TLBadMsgNotification.h"

#import "../NSInputStream+TL.h"
#import "../NSOutputStream+TL.h"


@implementation TLBadMsgNotification


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

@implementation TLBadMsgNotification$bad_msg_notification : TLBadMsgNotification


- (int32_t)TLconstructorSignature
{
    return (int32_t)0xa7eff811;
}

- (int32_t)TLconstructorName
{
    return (int32_t)0xf58e5117;
}

- (id<TLObject>)TLbuildFromMetaObject:(std::shared_ptr<TLMetaObject>)metaObject
{
    TLBadMsgNotification$bad_msg_notification *object = [[TLBadMsgNotification$bad_msg_notification alloc] init];
    object.bad_msg_id = metaObject->getInt64((int32_t)0xc40e024);
    object.bad_msg_seqno = metaObject->getInt32((int32_t)0xb4044574);
    object.error_code = metaObject->getInt32((int32_t)0xd1591cb4);
    return object;
}

- (void)TLfillFieldsWithValues:(std::map<int32_t, TLConstructedValue> *)values
{
    {
        TLConstructedValue value;
        value.type = TLConstructedValueTypePrimitiveInt64;
        value.primitive.int64Value = self.bad_msg_id;
        values->insert(std::pair<int32_t, TLConstructedValue>((int32_t)0xc40e024, value));
    }
    {
        TLConstructedValue value;
        value.type = TLConstructedValueTypePrimitiveInt32;
        value.primitive.int32Value = self.bad_msg_seqno;
        values->insert(std::pair<int32_t, TLConstructedValue>((int32_t)0xb4044574, value));
    }
    {
        TLConstructedValue value;
        value.type = TLConstructedValueTypePrimitiveInt32;
        value.primitive.int32Value = self.error_code;
        values->insert(std::pair<int32_t, TLConstructedValue>((int32_t)0xd1591cb4, value));
    }
}


@end

@implementation TLBadMsgNotification$bad_server_salt : TLBadMsgNotification


- (int32_t)TLconstructorSignature
{
    return (int32_t)0xedab447b;
}

- (int32_t)TLconstructorName
{
    return (int32_t)0x31e51389;
}

- (id<TLObject>)TLbuildFromMetaObject:(std::shared_ptr<TLMetaObject>)metaObject
{
    TLBadMsgNotification$bad_server_salt *object = [[TLBadMsgNotification$bad_server_salt alloc] init];
    object.bad_msg_id = metaObject->getInt64((int32_t)0xc40e024);
    object.bad_msg_seqno = metaObject->getInt32((int32_t)0xb4044574);
    object.error_code = metaObject->getInt32((int32_t)0xd1591cb4);
    object.n_new_server_salt = metaObject->getInt64((int32_t)0xa66279b6);
    return object;
}

- (void)TLfillFieldsWithValues:(std::map<int32_t, TLConstructedValue> *)values
{
    {
        TLConstructedValue value;
        value.type = TLConstructedValueTypePrimitiveInt64;
        value.primitive.int64Value = self.bad_msg_id;
        values->insert(std::pair<int32_t, TLConstructedValue>((int32_t)0xc40e024, value));
    }
    {
        TLConstructedValue value;
        value.type = TLConstructedValueTypePrimitiveInt32;
        value.primitive.int32Value = self.bad_msg_seqno;
        values->insert(std::pair<int32_t, TLConstructedValue>((int32_t)0xb4044574, value));
    }
    {
        TLConstructedValue value;
        value.type = TLConstructedValueTypePrimitiveInt32;
        value.primitive.int32Value = self.error_code;
        values->insert(std::pair<int32_t, TLConstructedValue>((int32_t)0xd1591cb4, value));
    }
    {
        TLConstructedValue value;
        value.type = TLConstructedValueTypePrimitiveInt64;
        value.primitive.int64Value = self.n_new_server_salt;
        values->insert(std::pair<int32_t, TLConstructedValue>((int32_t)0xa66279b6, value));
    }
}


@end

