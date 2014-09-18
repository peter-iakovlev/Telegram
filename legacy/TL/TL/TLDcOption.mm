#import "TLDcOption.h"

#import "../NSInputStream+TL.h"
#import "../NSOutputStream+TL.h"


@implementation TLDcOption


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

- (id<TLObject>)TLbuildFromMetaObject:(std::tr1::shared_ptr<TLMetaObject>)__unused metaObject
{
    TGLog(@"TLbuildFromMetaObject is not implemented for base type");
    return nil;
}

- (void)TLfillFieldsWithValues:(std::map<int32_t, TLConstructedValue> *)__unused values
{
    TGLog(@"TLfillFieldsWithValues is not implemented for base type");
}


@end

@implementation TLDcOption$dcOption : TLDcOption


- (int32_t)TLconstructorSignature
{
    return (int32_t)0x2ec2a43c;
}

- (int32_t)TLconstructorName
{
    return (int32_t)0x43ea98d5;
}

- (id<TLObject>)TLbuildFromMetaObject:(std::tr1::shared_ptr<TLMetaObject>)metaObject
{
    TLDcOption$dcOption *object = [[TLDcOption$dcOption alloc] init];
    object.n_id = metaObject->getInt32((int32_t)0x7a5601fb);
    object.hostname = metaObject->getString((int32_t)0x5d7aec67);
    object.ip_address = metaObject->getString((int32_t)0x7055e8ec);
    object.port = metaObject->getInt32((int32_t)0x81ce65c9);
    return object;
}

- (void)TLfillFieldsWithValues:(std::map<int32_t, TLConstructedValue> *)values
{
    {
        TLConstructedValue value;
        value.type = TLConstructedValueTypePrimitiveInt32;
        value.primitive.int32Value = self.n_id;
        values->insert(std::pair<int32_t, TLConstructedValue>((int32_t)0x7a5601fb, value));
    }
    {
        TLConstructedValue value;
        value.type = TLConstructedValueTypeString;
        value.nativeObject = self.hostname;
        values->insert(std::pair<int32_t, TLConstructedValue>((int32_t)0x5d7aec67, value));
    }
    {
        TLConstructedValue value;
        value.type = TLConstructedValueTypeString;
        value.nativeObject = self.ip_address;
        values->insert(std::pair<int32_t, TLConstructedValue>((int32_t)0x7055e8ec, value));
    }
    {
        TLConstructedValue value;
        value.type = TLConstructedValueTypePrimitiveInt32;
        value.primitive.int32Value = self.port;
        values->insert(std::pair<int32_t, TLConstructedValue>((int32_t)0x81ce65c9, value));
    }
}


@end

