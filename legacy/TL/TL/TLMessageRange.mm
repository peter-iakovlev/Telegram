#import "TLMessageRange.h"

#import "../NSInputStream+TL.h"
#import "../NSOutputStream+TL.h"


@implementation TLMessageRange


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

@implementation TLMessageRange$messageRange : TLMessageRange


- (int32_t)TLconstructorSignature
{
    return (int32_t)0xae30253;
}

- (int32_t)TLconstructorName
{
    return (int32_t)0xbb35ae8e;
}

- (id<TLObject>)TLbuildFromMetaObject:(std::shared_ptr<TLMetaObject>)metaObject
{
    TLMessageRange$messageRange *object = [[TLMessageRange$messageRange alloc] init];
    object.min_id = metaObject->getInt32((int32_t)0x52b518c0);
    object.max_id = metaObject->getInt32((int32_t)0xe2c00ace);
    return object;
}

- (void)TLfillFieldsWithValues:(std::map<int32_t, TLConstructedValue> *)values
{
    {
        TLConstructedValue value;
        value.type = TLConstructedValueTypePrimitiveInt32;
        value.primitive.int32Value = self.min_id;
        values->insert(std::pair<int32_t, TLConstructedValue>((int32_t)0x52b518c0, value));
    }
    {
        TLConstructedValue value;
        value.type = TLConstructedValueTypePrimitiveInt32;
        value.primitive.int32Value = self.max_id;
        values->insert(std::pair<int32_t, TLConstructedValue>((int32_t)0xe2c00ace, value));
    }
}


@end

