#import "TLLabeledPrice.h"

#import "../NSInputStream+TL.h"
#import "../NSOutputStream+TL.h"


@implementation TLLabeledPrice


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

@implementation TLLabeledPrice$labeledPrice : TLLabeledPrice


- (int32_t)TLconstructorSignature
{
    return (int32_t)0xcb296bf8;
}

- (int32_t)TLconstructorName
{
    return (int32_t)0xd13f0dd5;
}

- (id<TLObject>)TLbuildFromMetaObject:(std::shared_ptr<TLMetaObject>)metaObject
{
    TLLabeledPrice$labeledPrice *object = [[TLLabeledPrice$labeledPrice alloc] init];
    object.label = metaObject->getString((int32_t)0xfb41709);
    object.amount = metaObject->getInt64((int32_t)0x5d37edaf);
    return object;
}

- (void)TLfillFieldsWithValues:(std::map<int32_t, TLConstructedValue> *)values
{
    {
        TLConstructedValue value;
        value.type = TLConstructedValueTypeString;
        value.nativeObject = self.label;
        values->insert(std::pair<int32_t, TLConstructedValue>((int32_t)0xfb41709, value));
    }
    {
        TLConstructedValue value;
        value.type = TLConstructedValueTypePrimitiveInt64;
        value.primitive.int64Value = self.amount;
        values->insert(std::pair<int32_t, TLConstructedValue>((int32_t)0x5d37edaf, value));
    }
}


@end

