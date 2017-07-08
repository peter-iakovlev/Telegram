#import "TLRPCaccount_updateStatus.h"

#import "../NSInputStream+TL.h"
#import "../NSOutputStream+TL.h"


@implementation TLRPCaccount_updateStatus


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
    return 8;
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

@implementation TLRPCaccount_updateStatus$account_updateStatus : TLRPCaccount_updateStatus


- (int32_t)TLconstructorSignature
{
    return (int32_t)0x6628562c;
}

- (int32_t)TLconstructorName
{
    return (int32_t)0xfded5077;
}

- (id<TLObject>)TLbuildFromMetaObject:(std::shared_ptr<TLMetaObject>)metaObject
{
    TLRPCaccount_updateStatus$account_updateStatus *object = [[TLRPCaccount_updateStatus$account_updateStatus alloc] init];
    object.offline = metaObject->getBool((int32_t)0x4b79ae7e);
    return object;
}

- (void)TLfillFieldsWithValues:(std::map<int32_t, TLConstructedValue> *)values
{
    {
        TLConstructedValue value;
        value.type = TLConstructedValueTypePrimitiveBool;
        value.primitive.boolValue = self.offline;
        values->insert(std::pair<int32_t, TLConstructedValue>((int32_t)0x4b79ae7e, value));
    }
}


@end

