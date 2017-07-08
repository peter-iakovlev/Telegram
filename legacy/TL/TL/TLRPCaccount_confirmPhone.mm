#import "TLRPCaccount_confirmPhone.h"

#import "../NSInputStream+TL.h"
#import "../NSOutputStream+TL.h"


@implementation TLRPCaccount_confirmPhone


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
    return 54;
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

@implementation TLRPCaccount_confirmPhone$account_confirmPhone : TLRPCaccount_confirmPhone


- (int32_t)TLconstructorSignature
{
    return (int32_t)0x5f2178c3;
}

- (int32_t)TLconstructorName
{
    return (int32_t)0x38b298c5;
}

- (id<TLObject>)TLbuildFromMetaObject:(std::shared_ptr<TLMetaObject>)metaObject
{
    TLRPCaccount_confirmPhone$account_confirmPhone *object = [[TLRPCaccount_confirmPhone$account_confirmPhone alloc] init];
    object.phone_code_hash = metaObject->getString((int32_t)0xd4dfef1b);
    object.phone_code = metaObject->getString((int32_t)0xbbf1e711);
    return object;
}

- (void)TLfillFieldsWithValues:(std::map<int32_t, TLConstructedValue> *)values
{
    {
        TLConstructedValue value;
        value.type = TLConstructedValueTypeString;
        value.nativeObject = self.phone_code_hash;
        values->insert(std::pair<int32_t, TLConstructedValue>((int32_t)0xd4dfef1b, value));
    }
    {
        TLConstructedValue value;
        value.type = TLConstructedValueTypeString;
        value.nativeObject = self.phone_code;
        values->insert(std::pair<int32_t, TLConstructedValue>((int32_t)0xbbf1e711, value));
    }
}


@end

