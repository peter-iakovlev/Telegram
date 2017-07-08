#import "TLpayments_ValidatedRequestedInfo.h"

#import "../NSInputStream+TL.h"
#import "../NSOutputStream+TL.h"


@implementation TLpayments_ValidatedRequestedInfo


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

@implementation TLpayments_ValidatedRequestedInfo$payments_validatedRequestedInfoMeta : TLpayments_ValidatedRequestedInfo


- (int32_t)TLconstructorSignature
{
    return (int32_t)0x3cfc7e35;
}

- (int32_t)TLconstructorName
{
    return (int32_t)0x35fa113;
}

- (id<TLObject>)TLbuildFromMetaObject:(std::shared_ptr<TLMetaObject>)metaObject
{
    TLpayments_ValidatedRequestedInfo$payments_validatedRequestedInfoMeta *object = [[TLpayments_ValidatedRequestedInfo$payments_validatedRequestedInfoMeta alloc] init];
    object.flags = metaObject->getInt32((int32_t)0x81915c23);
    object.n_id = metaObject->getString((int32_t)0x7a5601fb);
    object.shipping_options = metaObject->getArray((int32_t)0x65aaa013);
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
        value.nativeObject = self.n_id;
        values->insert(std::pair<int32_t, TLConstructedValue>((int32_t)0x7a5601fb, value));
    }
    {
        TLConstructedValue value;
        value.type = TLConstructedValueTypeVector;
        value.nativeObject = self.shipping_options;
        values->insert(std::pair<int32_t, TLConstructedValue>((int32_t)0x65aaa013, value));
    }
}


@end

