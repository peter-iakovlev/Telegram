#import "TLNewSession.h"

#import "../NSInputStream+TL.h"
#import "../NSOutputStream+TL.h"


@implementation TLNewSession


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

@implementation TLNewSession$new_session_created : TLNewSession


- (int32_t)TLconstructorSignature
{
    return (int32_t)0x9ec20908;
}

- (int32_t)TLconstructorName
{
    return (int32_t)0x11cb312c;
}

- (id<TLObject>)TLbuildFromMetaObject:(std::shared_ptr<TLMetaObject>)metaObject
{
    TLNewSession$new_session_created *object = [[TLNewSession$new_session_created alloc] init];
    object.first_msg_id = metaObject->getInt64((int32_t)0xaf6a6ecd);
    object.unique_id = metaObject->getInt64((int32_t)0xa73d4588);
    object.server_salt = metaObject->getInt64((int32_t)0x9e9616d5);
    return object;
}

- (void)TLfillFieldsWithValues:(std::map<int32_t, TLConstructedValue> *)values
{
    {
        TLConstructedValue value;
        value.type = TLConstructedValueTypePrimitiveInt64;
        value.primitive.int64Value = self.first_msg_id;
        values->insert(std::pair<int32_t, TLConstructedValue>((int32_t)0xaf6a6ecd, value));
    }
    {
        TLConstructedValue value;
        value.type = TLConstructedValueTypePrimitiveInt64;
        value.primitive.int64Value = self.unique_id;
        values->insert(std::pair<int32_t, TLConstructedValue>((int32_t)0xa73d4588, value));
    }
    {
        TLConstructedValue value;
        value.type = TLConstructedValueTypePrimitiveInt64;
        value.primitive.int64Value = self.server_salt;
        values->insert(std::pair<int32_t, TLConstructedValue>((int32_t)0x9e9616d5, value));
    }
}


@end

