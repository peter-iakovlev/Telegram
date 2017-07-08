#import "TLInvokeWithLayer.h"

#import "../NSInputStream+TL.h"
#import "../NSOutputStream+TL.h"


@implementation TLInvokeWithLayer


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

@implementation TLInvokeWithLayer$invokeWithLayer : TLInvokeWithLayer


- (int32_t)TLconstructorSignature
{
    return (int32_t)0xda9b0d0d;
}

- (int32_t)TLconstructorName
{
    return (int32_t)0xf0662114;
}

- (id<TLObject>)TLbuildFromMetaObject:(std::shared_ptr<TLMetaObject>)metaObject
{
    TLInvokeWithLayer$invokeWithLayer *object = [[TLInvokeWithLayer$invokeWithLayer alloc] init];
    object.layer = metaObject->getInt32((int32_t)0xf2aee9c3);
    object.query = metaObject->getObject((int32_t)0x5de9dcb1);
    return object;
}

- (void)TLfillFieldsWithValues:(std::map<int32_t, TLConstructedValue> *)values
{
    {
        TLConstructedValue value;
        value.type = TLConstructedValueTypePrimitiveInt32;
        value.primitive.int32Value = self.layer;
        values->insert(std::pair<int32_t, TLConstructedValue>((int32_t)0xf2aee9c3, value));
    }
    {
        TLConstructedValue value;
        value.type = TLConstructedValueTypeObject;
        value.nativeObject = self.query;
        values->insert(std::pair<int32_t, TLConstructedValue>((int32_t)0x5de9dcb1, value));
    }
}


@end

