#import "TLInvoice.h"

#import "../NSInputStream+TL.h"
#import "../NSOutputStream+TL.h"


@implementation TLInvoice


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

@implementation TLInvoice$invoiceMeta : TLInvoice


- (int32_t)TLconstructorSignature
{
    return (int32_t)0x187882c1;
}

- (int32_t)TLconstructorName
{
    return (int32_t)0x961979ab;
}

- (id<TLObject>)TLbuildFromMetaObject:(std::shared_ptr<TLMetaObject>)metaObject
{
    TLInvoice$invoiceMeta *object = [[TLInvoice$invoiceMeta alloc] init];
    object.flags = metaObject->getInt32((int32_t)0x81915c23);
    object.currency = metaObject->getString((int32_t)0xd2a84177);
    object.prices = metaObject->getArray((int32_t)0x258944ac);
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
        value.type = TLConstructedValueTypeString;
        value.nativeObject = self.currency;
        values->insert(std::pair<int32_t, TLConstructedValue>((int32_t)0xd2a84177, value));
    }
    {
        TLConstructedValue value;
        value.type = TLConstructedValueTypeVector;
        value.nativeObject = self.prices;
        values->insert(std::pair<int32_t, TLConstructedValue>((int32_t)0x258944ac, value));
    }
}


@end

