#import "TLmessages_BotResults.h"

#import "../NSInputStream+TL.h"
#import "../NSOutputStream+TL.h"

#import "TLInlineBotSwitchPM.h"

@implementation TLmessages_BotResults


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

@implementation TLmessages_BotResults$messages_botResultsMeta : TLmessages_BotResults


- (int32_t)TLconstructorSignature
{
    return (int32_t)0x6aa35bdd;
}

- (int32_t)TLconstructorName
{
    return (int32_t)0xf63b203d;
}

- (id<TLObject>)TLbuildFromMetaObject:(std::shared_ptr<TLMetaObject>)metaObject
{
    TLmessages_BotResults$messages_botResultsMeta *object = [[TLmessages_BotResults$messages_botResultsMeta alloc] init];
    object.flags = metaObject->getInt32((int32_t)0x81915c23);
    object.query_id = metaObject->getInt64((int32_t)0x4536add4);
    object.next_offset = metaObject->getString((int32_t)0x873f1f36);
    object.switch_pm = metaObject->getObject((int32_t)0xf18f6473);
    object.results = metaObject->getArray((int32_t)0x817bffcc);
    object.cache_time = metaObject->getInt32((int32_t)0xf340b03d);
    object.users = metaObject->getArray((int32_t)0x933e5ff3);
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
        value.type = TLConstructedValueTypePrimitiveInt64;
        value.primitive.int64Value = self.query_id;
        values->insert(std::pair<int32_t, TLConstructedValue>((int32_t)0x4536add4, value));
    }
    {
        TLConstructedValue value;
        value.type = TLConstructedValueTypeString;
        value.nativeObject = self.next_offset;
        values->insert(std::pair<int32_t, TLConstructedValue>((int32_t)0x873f1f36, value));
    }
    {
        TLConstructedValue value;
        value.type = TLConstructedValueTypeObject;
        value.nativeObject = self.switch_pm;
        values->insert(std::pair<int32_t, TLConstructedValue>((int32_t)0xf18f6473, value));
    }
    {
        TLConstructedValue value;
        value.type = TLConstructedValueTypeVector;
        value.nativeObject = self.results;
        values->insert(std::pair<int32_t, TLConstructedValue>((int32_t)0x817bffcc, value));
    }
    {
        TLConstructedValue value;
        value.type = TLConstructedValueTypePrimitiveInt32;
        value.primitive.int32Value = self.cache_time;
        values->insert(std::pair<int32_t, TLConstructedValue>((int32_t)0xf340b03d, value));
    }
    {
        TLConstructedValue value;
        value.type = TLConstructedValueTypeVector;
        value.nativeObject = self.users;
        values->insert(std::pair<int32_t, TLConstructedValue>((int32_t)0x933e5ff3, value));
    }
}


@end

