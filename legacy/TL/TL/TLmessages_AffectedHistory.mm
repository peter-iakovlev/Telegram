#import "TLmessages_AffectedHistory.h"

#import "../NSInputStream+TL.h"
#import "../NSOutputStream+TL.h"


@implementation TLmessages_AffectedHistory


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

@implementation TLmessages_AffectedHistory$messages_affectedHistory : TLmessages_AffectedHistory


- (int32_t)TLconstructorSignature
{
    return (int32_t)0xb45c69d1;
}

- (int32_t)TLconstructorName
{
    return (int32_t)0xef024466;
}

- (id<TLObject>)TLbuildFromMetaObject:(std::shared_ptr<TLMetaObject>)metaObject
{
    TLmessages_AffectedHistory$messages_affectedHistory *object = [[TLmessages_AffectedHistory$messages_affectedHistory alloc] init];
    object.pts = metaObject->getInt32((int32_t)0x4fc5f572);
    object.pts_count = metaObject->getInt32((int32_t)0x4ad9fe06);
    object.offset = metaObject->getInt32((int32_t)0xfc56269);
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
        value.primitive.int32Value = self.pts_count;
        values->insert(std::pair<int32_t, TLConstructedValue>((int32_t)0x4ad9fe06, value));
    }
    {
        TLConstructedValue value;
        value.type = TLConstructedValueTypePrimitiveInt32;
        value.primitive.int32Value = self.offset;
        values->insert(std::pair<int32_t, TLConstructedValue>((int32_t)0xfc56269, value));
    }
}


@end

