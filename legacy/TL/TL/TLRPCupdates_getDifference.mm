#import "TLRPCupdates_getDifference.h"

#import "../NSInputStream+TL.h"
#import "../NSOutputStream+TL.h"

#import "TLupdates_Difference.h"

@implementation TLRPCupdates_getDifference


- (Class)responseClass
{
    return [TLupdates_Difference class];
}

- (int)impliedResponseSignature
{
    return 0;
}

- (int)layerVersion
{
    return 58;
}

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

@implementation TLRPCupdates_getDifference$updates_getDifference : TLRPCupdates_getDifference


- (int32_t)TLconstructorSignature
{
    return (int32_t)0x25939651;
}

- (int32_t)TLconstructorName
{
    return (int32_t)0xc0db98ef;
}

- (id<TLObject>)TLbuildFromMetaObject:(std::shared_ptr<TLMetaObject>)metaObject
{
    TLRPCupdates_getDifference$updates_getDifference *object = [[TLRPCupdates_getDifference$updates_getDifference alloc] init];
    object.flags = metaObject->getInt32((int32_t)0x81915c23);
    object.pts = metaObject->getInt32((int32_t)0x4fc5f572);
    object.date = metaObject->getInt32((int32_t)0xb76958ba);
    object.qts = metaObject->getInt32((int32_t)0x3c528e55);
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
        value.primitive.int32Value = self.pts;
        values->insert(std::pair<int32_t, TLConstructedValue>((int32_t)0x4fc5f572, value));
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
        value.primitive.int32Value = self.qts;
        values->insert(std::pair<int32_t, TLConstructedValue>((int32_t)0x3c528e55, value));
    }
}


@end

