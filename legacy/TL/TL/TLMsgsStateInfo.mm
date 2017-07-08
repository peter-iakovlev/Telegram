#import "TLMsgsStateInfo.h"

#import "../NSInputStream+TL.h"
#import "../NSOutputStream+TL.h"


@implementation TLMsgsStateInfo


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

@implementation TLMsgsStateInfo$msgs_state_info : TLMsgsStateInfo


- (int32_t)TLconstructorSignature
{
    return (int32_t)0x4deb57d;
}

- (int32_t)TLconstructorName
{
    return (int32_t)0x6487aab;
}

- (id<TLObject>)TLbuildFromMetaObject:(std::shared_ptr<TLMetaObject>)metaObject
{
    TLMsgsStateInfo$msgs_state_info *object = [[TLMsgsStateInfo$msgs_state_info alloc] init];
    object.req_msg_id = metaObject->getInt64((int32_t)0x96e02a8b);
    object.info = metaObject->getString((int32_t)0x3928e0e2);
    return object;
}

- (void)TLfillFieldsWithValues:(std::map<int32_t, TLConstructedValue> *)values
{
    {
        TLConstructedValue value;
        value.type = TLConstructedValueTypePrimitiveInt64;
        value.primitive.int64Value = self.req_msg_id;
        values->insert(std::pair<int32_t, TLConstructedValue>((int32_t)0x96e02a8b, value));
    }
    {
        TLConstructedValue value;
        value.type = TLConstructedValueTypeString;
        value.nativeObject = self.info;
        values->insert(std::pair<int32_t, TLConstructedValue>((int32_t)0x3928e0e2, value));
    }
}


@end

