#import "TLupdates_State.h"

#import "../NSInputStream+TL.h"
#import "../NSOutputStream+TL.h"


@implementation TLupdates_State


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

@implementation TLupdates_State$updates_state : TLupdates_State


- (int32_t)TLconstructorSignature
{
    return (int32_t)0xa56c2a3e;
}

- (int32_t)TLconstructorName
{
    return (int32_t)0x27cd12fd;
}

- (id<TLObject>)TLbuildFromMetaObject:(std::shared_ptr<TLMetaObject>)metaObject
{
    TLupdates_State$updates_state *object = [[TLupdates_State$updates_state alloc] init];
    object.pts = metaObject->getInt32((int32_t)0x4fc5f572);
    object.qts = metaObject->getInt32((int32_t)0x3c528e55);
    object.date = metaObject->getInt32((int32_t)0xb76958ba);
    object.seq = metaObject->getInt32((int32_t)0xc769ed79);
    object.unread_count = metaObject->getInt32((int32_t)0xa6b586be);
    return object;
}

- (void)TLfillFieldsWithValues:(std::map<int32_t, TLConstructedValue> *)values
{
    {
        TLConstructedValue value;
        value.type = TLConstructedValueTypePrimitiveInt32;
        value.primitive.int32Value = self.pts;
        values->insert(std::pair<int32_t, TLConstructedValue>((int32_t)0x4fc5f572, value));
    }
    {
        TLConstructedValue value;
        value.type = TLConstructedValueTypePrimitiveInt32;
        value.primitive.int32Value = self.qts;
        values->insert(std::pair<int32_t, TLConstructedValue>((int32_t)0x3c528e55, value));
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
        value.primitive.int32Value = self.seq;
        values->insert(std::pair<int32_t, TLConstructedValue>((int32_t)0xc769ed79, value));
    }
    {
        TLConstructedValue value;
        value.type = TLConstructedValueTypePrimitiveInt32;
        value.primitive.int32Value = self.unread_count;
        values->insert(std::pair<int32_t, TLConstructedValue>((int32_t)0xa6b586be, value));
    }
}


@end

