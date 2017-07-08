#import "TLMaskCoords.h"

#import "../NSInputStream+TL.h"
#import "../NSOutputStream+TL.h"


@implementation TLMaskCoords


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

@implementation TLMaskCoords$maskCoords : TLMaskCoords


- (int32_t)TLconstructorSignature
{
    return (int32_t)0xaed6dbb2;
}

- (int32_t)TLconstructorName
{
    return (int32_t)0x9ace4a2c;
}

- (id<TLObject>)TLbuildFromMetaObject:(std::shared_ptr<TLMetaObject>)metaObject
{
    TLMaskCoords$maskCoords *object = [[TLMaskCoords$maskCoords alloc] init];
    object.n = metaObject->getInt32((int32_t)0x3afcbeb4);
    object.x = metaObject->getDouble((int32_t)0x274fb0c3);
    object.y = metaObject->getDouble((int32_t)0xe0a1ce2d);
    object.zoom = metaObject->getDouble((int32_t)0xa674a1ca);
    return object;
}

- (void)TLfillFieldsWithValues:(std::map<int32_t, TLConstructedValue> *)values
{
    {
        TLConstructedValue value;
        value.type = TLConstructedValueTypePrimitiveInt32;
        value.primitive.int32Value = self.n;
        values->insert(std::pair<int32_t, TLConstructedValue>((int32_t)0x3afcbeb4, value));
    }
    {
        TLConstructedValue value;
        value.type = TLConstructedValueTypePrimitiveDouble;
        value.primitive.doubleValue = self.x;
        values->insert(std::pair<int32_t, TLConstructedValue>((int32_t)0x274fb0c3, value));
    }
    {
        TLConstructedValue value;
        value.type = TLConstructedValueTypePrimitiveDouble;
        value.primitive.doubleValue = self.y;
        values->insert(std::pair<int32_t, TLConstructedValue>((int32_t)0xe0a1ce2d, value));
    }
    {
        TLConstructedValue value;
        value.type = TLConstructedValueTypePrimitiveDouble;
        value.primitive.doubleValue = self.zoom;
        values->insert(std::pair<int32_t, TLConstructedValue>((int32_t)0xa674a1ca, value));
    }
}


@end

