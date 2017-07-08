#import "TLmessages_BotCallbackAnswer.h"

#import "../NSInputStream+TL.h"
#import "../NSOutputStream+TL.h"


@implementation TLmessages_BotCallbackAnswer


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

@implementation TLmessages_BotCallbackAnswer$messages_botCallbackAnswerMeta : TLmessages_BotCallbackAnswer


- (int32_t)TLconstructorSignature
{
    return (int32_t)0x13041387;
}

- (int32_t)TLconstructorName
{
    return (int32_t)0x633036a6;
}

- (id<TLObject>)TLbuildFromMetaObject:(std::shared_ptr<TLMetaObject>)metaObject
{
    TLmessages_BotCallbackAnswer$messages_botCallbackAnswerMeta *object = [[TLmessages_BotCallbackAnswer$messages_botCallbackAnswerMeta alloc] init];
    object.flags = metaObject->getInt32((int32_t)0x81915c23);
    object.message = metaObject->getString((int32_t)0xc43b7853);
    object.url = metaObject->getString((int32_t)0xeaf7861e);
    object.cache_time = metaObject->getInt32((int32_t)0xf340b03d);
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
        value.type = TLConstructedValueTypeString;
        value.nativeObject = self.message;
        values->insert(std::pair<int32_t, TLConstructedValue>((int32_t)0xc43b7853, value));
    }
    {
        TLConstructedValue value;
        value.type = TLConstructedValueTypeString;
        value.nativeObject = self.url;
        values->insert(std::pair<int32_t, TLConstructedValue>((int32_t)0xeaf7861e, value));
    }
    {
        TLConstructedValue value;
        value.type = TLConstructedValueTypePrimitiveInt32;
        value.primitive.int32Value = self.cache_time;
        values->insert(std::pair<int32_t, TLConstructedValue>((int32_t)0xf340b03d, value));
    }
}


@end

