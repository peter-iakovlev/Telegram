#import "TLDcNetworkStats.h"

#import "../NSInputStream+TL.h"
#import "../NSOutputStream+TL.h"


@implementation TLDcNetworkStats


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

@implementation TLDcNetworkStats$dcPingStats : TLDcNetworkStats


- (int32_t)TLconstructorSignature
{
    return (int32_t)0x3203df8c;
}

- (int32_t)TLconstructorName
{
    return (int32_t)0x3fb0ef38;
}

- (id<TLObject>)TLbuildFromMetaObject:(std::shared_ptr<TLMetaObject>)metaObject
{
    TLDcNetworkStats$dcPingStats *object = [[TLDcNetworkStats$dcPingStats alloc] init];
    object.dc_id = metaObject->getInt32((int32_t)0xae973dc4);
    object.ip_address = metaObject->getString((int32_t)0x7055e8ec);
    object.pings = metaObject->getArray((int32_t)0xcd57c35e);
    return object;
}

- (void)TLfillFieldsWithValues:(std::map<int32_t, TLConstructedValue> *)values
{
    {
        TLConstructedValue value;
        value.type = TLConstructedValueTypePrimitiveInt32;
        value.primitive.int32Value = self.dc_id;
        values->insert(std::pair<int32_t, TLConstructedValue>((int32_t)0xae973dc4, value));
    }
    {
        TLConstructedValue value;
        value.type = TLConstructedValueTypeString;
        value.nativeObject = self.ip_address;
        values->insert(std::pair<int32_t, TLConstructedValue>((int32_t)0x7055e8ec, value));
    }
    {
        TLConstructedValue value;
        value.type = TLConstructedValueTypeVector;
        value.nativeObject = self.pings;
        values->insert(std::pair<int32_t, TLConstructedValue>((int32_t)0xcd57c35e, value));
    }
}


@end

