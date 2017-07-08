#import "TLpayments_SavedInfo.h"

#import "../NSInputStream+TL.h"
#import "../NSOutputStream+TL.h"

#import "TLPaymentRequestedInfo.h"

@implementation TLpayments_SavedInfo


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

@implementation TLpayments_SavedInfo$payments_savedInfoMeta : TLpayments_SavedInfo


- (int32_t)TLconstructorSignature
{
    return (int32_t)0xa2ffb0da;
}

- (int32_t)TLconstructorName
{
    return (int32_t)0x6aeb6663;
}

- (id<TLObject>)TLbuildFromMetaObject:(std::shared_ptr<TLMetaObject>)metaObject
{
    TLpayments_SavedInfo$payments_savedInfoMeta *object = [[TLpayments_SavedInfo$payments_savedInfoMeta alloc] init];
    object.flags = metaObject->getInt32((int32_t)0x81915c23);
    object.saved_info = metaObject->getObject((int32_t)0x35896b20);
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
        value.type = TLConstructedValueTypeObject;
        value.nativeObject = self.saved_info;
        values->insert(std::pair<int32_t, TLConstructedValue>((int32_t)0x35896b20, value));
    }
}


@end

