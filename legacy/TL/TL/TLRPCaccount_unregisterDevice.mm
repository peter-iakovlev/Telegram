#import "TLRPCaccount_unregisterDevice.h"

#import "../NSInputStream+TL.h"
#import "../NSOutputStream+TL.h"


@implementation TLRPCaccount_unregisterDevice


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

@implementation TLRPCaccount_unregisterDevice$account_unregisterDevice : TLRPCaccount_unregisterDevice


- (int32_t)TLconstructorSignature
{
    return (int32_t)0x65c55b40;
}

- (int32_t)TLconstructorName
{
    return (int32_t)0xb7a9ce9e;
}

- (id<TLObject>)TLbuildFromMetaObject:(std::shared_ptr<TLMetaObject>)metaObject
{
    TLRPCaccount_unregisterDevice$account_unregisterDevice *object = [[TLRPCaccount_unregisterDevice$account_unregisterDevice alloc] init];
    object.token_type = metaObject->getInt32((int32_t)0xb5f2fc25);
    object.token = metaObject->getString((int32_t)0x1e8aa3f5);
    return object;
}

- (void)TLfillFieldsWithValues:(std::map<int32_t, TLConstructedValue> *)values
{
    {
        TLConstructedValue value;
        value.type = TLConstructedValueTypePrimitiveInt32;
        value.primitive.int32Value = self.token_type;
        values->insert(std::pair<int32_t, TLConstructedValue>((int32_t)0xb5f2fc25, value));
    }
    {
        TLConstructedValue value;
        value.type = TLConstructedValueTypeString;
        value.nativeObject = self.token;
        values->insert(std::pair<int32_t, TLConstructedValue>((int32_t)0x1e8aa3f5, value));
    }
}


@end

