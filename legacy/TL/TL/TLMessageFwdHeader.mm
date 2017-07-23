#import "TLMessageFwdHeader.h"

#import "../NSInputStream+TL.h"
#import "../NSOutputStream+TL.h"


@implementation TLMessageFwdHeader


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

@implementation TLMessageFwdHeader$messageFwdHeaderMeta : TLMessageFwdHeader


- (int32_t)TLconstructorSignature
{
    return (int32_t)0xba3903bf;
}

- (int32_t)TLconstructorName
{
    return (int32_t)0xff8f2d02;
}

- (id<TLObject>)TLbuildFromMetaObject:(std::shared_ptr<TLMetaObject>)metaObject
{
    TLMessageFwdHeader$messageFwdHeaderMeta *object = [[TLMessageFwdHeader$messageFwdHeaderMeta alloc] init];
    object.flags = metaObject->getInt32((int32_t)0x81915c23);
    object.from_id = metaObject->getInt32((int32_t)0xf39a7861);
    object.date = metaObject->getInt32((int32_t)0xb76958ba);
    object.channel_id = metaObject->getInt32((int32_t)0x1cfcdb86);
    object.channel_post = metaObject->getInt32((int32_t)0x2c34eb97);
    object.post_author = metaObject->getString((int32_t)0x6d88316);
    return object;
}

- (void)TLfillFieldsWithValues:(std::map<int32_t, TLConstructedValue> *)values
{
    {
        TLConstructedValue value;
        value.type = TLConstructedValueTypePrimitiveInt32;
        value.primitive.int32Value = self.flags;
        values->insert(std::pair<int32_t, TLConstructedValue>((int32_t)0x81915c23, value));
    }
    {
        TLConstructedValue value;
        value.type = TLConstructedValueTypePrimitiveInt32;
        value.primitive.int32Value = self.from_id;
        values->insert(std::pair<int32_t, TLConstructedValue>((int32_t)0xf39a7861, value));
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
        value.primitive.int32Value = self.channel_id;
        values->insert(std::pair<int32_t, TLConstructedValue>((int32_t)0x1cfcdb86, value));
    }
    {
        TLConstructedValue value;
        value.type = TLConstructedValueTypePrimitiveInt32;
        value.primitive.int32Value = self.channel_post;
        values->insert(std::pair<int32_t, TLConstructedValue>((int32_t)0x2c34eb97, value));
    }
    {
        TLConstructedValue value;
        value.type = TLConstructedValueTypeString;
        value.nativeObject = self.post_author;
        values->insert(std::pair<int32_t, TLConstructedValue>((int32_t)0x6d88316, value));
    }
}


@end

