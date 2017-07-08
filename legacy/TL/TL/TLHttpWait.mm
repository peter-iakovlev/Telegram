#import "TLHttpWait.h"

#import "../NSInputStream+TL.h"
#import "../NSOutputStream+TL.h"


@implementation TLHttpWait


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

@implementation TLHttpWait$http_wait : TLHttpWait


- (int32_t)TLconstructorSignature
{
    return (int32_t)0x9299359f;
}

- (int32_t)TLconstructorName
{
    return (int32_t)0xd7cd05e6;
}

- (id<TLObject>)TLbuildFromMetaObject:(std::shared_ptr<TLMetaObject>)metaObject
{
    TLHttpWait$http_wait *object = [[TLHttpWait$http_wait alloc] init];
    object.max_delay = metaObject->getInt32((int32_t)0x42201079);
    object.wait_after = metaObject->getInt32((int32_t)0x446f5020);
    object.max_wait = metaObject->getInt32((int32_t)0x89283bed);
    return object;
}

- (void)TLfillFieldsWithValues:(std::map<int32_t, TLConstructedValue> *)values
{
    {
        TLConstructedValue value;
        value.type = TLConstructedValueTypePrimitiveInt32;
        value.primitive.int32Value = self.max_delay;
        values->insert(std::pair<int32_t, TLConstructedValue>((int32_t)0x42201079, value));
    }
    {
        TLConstructedValue value;
        value.type = TLConstructedValueTypePrimitiveInt32;
        value.primitive.int32Value = self.wait_after;
        values->insert(std::pair<int32_t, TLConstructedValue>((int32_t)0x446f5020, value));
    }
    {
        TLConstructedValue value;
        value.type = TLConstructedValueTypePrimitiveInt32;
        value.primitive.int32Value = self.max_wait;
        values->insert(std::pair<int32_t, TLConstructedValue>((int32_t)0x89283bed, value));
    }
}


@end

