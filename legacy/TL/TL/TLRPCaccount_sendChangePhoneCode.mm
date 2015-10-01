#import "TLRPCaccount_sendChangePhoneCode.h"

#import "../NSInputStream+TL.h"
#import "../NSOutputStream+TL.h"

#import "TLaccount_SentChangePhoneCode.h"

@implementation TLRPCaccount_sendChangePhoneCode


- (Class)responseClass
{
    return [TLaccount_SentChangePhoneCode class];
}

- (int)impliedResponseSignature
{
    return (int)0xa4f58c4c;
}

- (int)layerVersion
{
    return 20;
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

@implementation TLRPCaccount_sendChangePhoneCode$account_sendChangePhoneCode : TLRPCaccount_sendChangePhoneCode


- (int32_t)TLconstructorSignature
{
    return (int32_t)0xa407a8f4;
}

- (int32_t)TLconstructorName
{
    return (int32_t)0xb90fbbca;
}

- (id<TLObject>)TLbuildFromMetaObject:(std::tr1::shared_ptr<TLMetaObject>)metaObject
{
    TLRPCaccount_sendChangePhoneCode$account_sendChangePhoneCode *object = [[TLRPCaccount_sendChangePhoneCode$account_sendChangePhoneCode alloc] init];
    object.phone_number = metaObject->getString((int32_t)0xaecb6c79);
    return object;
}

- (void)TLfillFieldsWithValues:(std::map<int32_t, TLConstructedValue> *)values
{
    {
        TLConstructedValue value;
        value.type = TLConstructedValueTypeString;
        value.nativeObject = self.phone_number;
        values->insert(std::pair<int32_t, TLConstructedValue>((int32_t)0xaecb6c79, value));
    }
}


@end

