#import "TLProtoMessage.h"

#import "../NSInputStream+TL.h"
#import "../NSOutputStream+TL.h"


@implementation TLProtoMessage


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

@implementation TLProtoMessage$protoMessage : TLProtoMessage


- (int32_t)TLconstructorSignature
{
    return (int32_t)0x5bb8e511;
}

- (int32_t)TLconstructorName
{
    return (int32_t)0x18a5e7a3;
}

- (id<TLObject>)TLbuildFromMetaObject:(std::shared_ptr<TLMetaObject>)metaObject
{
    TLProtoMessage$protoMessage *object = [[TLProtoMessage$protoMessage alloc] init];
    object.msg_id = metaObject->getInt64((int32_t)0xf1cc383f);
    object.seqno = metaObject->getInt32((int32_t)0xb8a3dd00);
    object.bytes = metaObject->getInt32((int32_t)0xec5ef20a);
    object.body = metaObject->getObject((int32_t)0x21ab60d2);
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
        value.type = TLConstructedValueTypePrimitiveInt32;
        value.primitive.int32Value = self.seqno;
        values->insert(std::pair<int32_t, TLConstructedValue>((int32_t)0xb8a3dd00, value));
    }
    {
        TLConstructedValue value;
        value.type = TLConstructedValueTypePrimitiveInt32;
        value.primitive.int32Value = self.bytes;
        values->insert(std::pair<int32_t, TLConstructedValue>((int32_t)0xec5ef20a, value));
    }
    {
        TLConstructedValue value;
        value.type = TLConstructedValueTypeObject;
        value.nativeObject = self.body;
        values->insert(std::pair<int32_t, TLConstructedValue>((int32_t)0x21ab60d2, value));
    }
}


@end

