#import "TLInvokeAfterMsg.h"

#import "../NSInputStream+TL.h"
#import "../NSOutputStream+TL.h"


@implementation TLInvokeAfterMsg


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

@implementation TLInvokeAfterMsg$invokeAfterMsg : TLInvokeAfterMsg


- (int32_t)TLconstructorSignature
{
    return (int32_t)0xcb9f372d;
}

- (int32_t)TLconstructorName
{
    return (int32_t)0x3b7ec605;
}

- (id<TLObject>)TLbuildFromMetaObject:(std::shared_ptr<TLMetaObject>)metaObject
{
    TLInvokeAfterMsg$invokeAfterMsg *object = [[TLInvokeAfterMsg$invokeAfterMsg alloc] init];
    object.msg_id = metaObject->getInt64((int32_t)0xf1cc383f);
    object.query = metaObject->getObject((int32_t)0x5de9dcb1);
    return object;
}

- (void)TLfillFieldsWithValues:(std::map<int32_t, TLConstructedValue> *)values
{
    {
        TLConstructedValue value;
        value.type = TLConstructedValueTypePrimitiveInt64;
        value.primitive.int64Value = self.msg_id;
        values->insert(std::pair<int32_t, TLConstructedValue>((int32_t)0xf1cc383f, value));
    }
    {
        TLConstructedValue value;
        value.type = TLConstructedValueTypeObject;
        value.nativeObject = self.query;
        values->insert(std::pair<int32_t, TLConstructedValue>((int32_t)0x5de9dcb1, value));
    }
}


@end

