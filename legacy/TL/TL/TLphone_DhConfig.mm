#import "TLphone_DhConfig.h"

#import "../NSInputStream+TL.h"
#import "../NSOutputStream+TL.h"


@implementation TLphone_DhConfig


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

@implementation TLphone_DhConfig$phone_dhConfig : TLphone_DhConfig


- (int32_t)TLconstructorSignature
{
    return (int32_t)0x8a5d855e;
}

- (int32_t)TLconstructorName
{
    return (int32_t)0xd4ba8a8;
}

- (id<TLObject>)TLbuildFromMetaObject:(std::shared_ptr<TLMetaObject>)metaObject
{
    TLphone_DhConfig$phone_dhConfig *object = [[TLphone_DhConfig$phone_dhConfig alloc] init];
    object.g = metaObject->getInt32((int32_t)0x75e1067a);
    object.p = metaObject->getString((int32_t)0xb91d8925);
    object.ring_timeout = metaObject->getInt32((int32_t)0x3cc578d1);
    object.expires = metaObject->getInt32((int32_t)0x4743fb6b);
    return object;
}

- (void)TLfillFieldsWithValues:(std::map<int32_t, TLConstructedValue> *)values
{
    {
        TLConstructedValue value;
        value.type = TLConstructedValueTypePrimitiveInt32;
        value.primitive.int32Value = self.g;
        values->insert(std::pair<int32_t, TLConstructedValue>((int32_t)0x75e1067a, value));
    }
    {
        TLConstructedValue value;
        value.type = TLConstructedValueTypeString;
        value.nativeObject = self.p;
        values->insert(std::pair<int32_t, TLConstructedValue>((int32_t)0xb91d8925, value));
    }
    {
        TLConstructedValue value;
        value.type = TLConstructedValueTypePrimitiveInt32;
        value.primitive.int32Value = self.ring_timeout;
        values->insert(std::pair<int32_t, TLConstructedValue>((int32_t)0x3cc578d1, value));
    }
    {
        TLConstructedValue value;
        value.type = TLConstructedValueTypePrimitiveInt32;
        value.primitive.int32Value = self.expires;
        values->insert(std::pair<int32_t, TLConstructedValue>((int32_t)0x4743fb6b, value));
    }
}


@end

