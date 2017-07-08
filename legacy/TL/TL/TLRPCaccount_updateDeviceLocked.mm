#import "TLRPCaccount_updateDeviceLocked.h"

#import "../NSInputStream+TL.h"
#import "../NSOutputStream+TL.h"


@implementation TLRPCaccount_updateDeviceLocked


- (Class)responseClass
{
    return [NSNumber class];
}

- (int)impliedResponseSignature
{
    return 0;
}

- (int)layerVersion
{
    return 22;
}

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

@implementation TLRPCaccount_updateDeviceLocked$account_updateDeviceLocked : TLRPCaccount_updateDeviceLocked


- (int32_t)TLconstructorSignature
{
    return (int32_t)0x38df3532;
}

- (int32_t)TLconstructorName
{
    return (int32_t)0x24bb22af;
}

- (id<TLObject>)TLbuildFromMetaObject:(std::shared_ptr<TLMetaObject>)metaObject
{
    TLRPCaccount_updateDeviceLocked$account_updateDeviceLocked *object = [[TLRPCaccount_updateDeviceLocked$account_updateDeviceLocked alloc] init];
    object.period = metaObject->getInt32((int32_t)0xc19ffb71);
    return object;
}

- (void)TLfillFieldsWithValues:(std::map<int32_t, TLConstructedValue> *)values
{
    {
        TLConstructedValue value;
        value.type = TLConstructedValueTypePrimitiveInt32;
        value.primitive.int32Value = self.period;
        values->insert(std::pair<int32_t, TLConstructedValue>((int32_t)0xc19ffb71, value));
    }
}


@end

