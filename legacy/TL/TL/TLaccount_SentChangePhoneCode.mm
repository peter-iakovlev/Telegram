#import "TLaccount_SentChangePhoneCode.h"

#import "../NSInputStream+TL.h"
#import "../NSOutputStream+TL.h"


@implementation TLaccount_SentChangePhoneCode


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

@implementation TLaccount_SentChangePhoneCode$account_sentChangePhoneCode : TLaccount_SentChangePhoneCode


- (int32_t)TLconstructorSignature
{
    return (int32_t)0xa4f58c4c;
}

- (int32_t)TLconstructorName
{
    return (int32_t)0xf6dffb80;
}

- (id<TLObject>)TLbuildFromMetaObject:(std::tr1::shared_ptr<TLMetaObject>)metaObject
{
    TLaccount_SentChangePhoneCode$account_sentChangePhoneCode *object = [[TLaccount_SentChangePhoneCode$account_sentChangePhoneCode alloc] init];
    object.phone_code_hash = metaObject->getString((int32_t)0xd4dfef1b);
    object.send_call_timeout = metaObject->getInt32((int32_t)0x74e5208b);
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
        value.type = TLConstructedValueTypePrimitiveInt32;
        value.primitive.int32Value = self.send_call_timeout;
        values->insert(std::pair<int32_t, TLConstructedValue>((int32_t)0x74e5208b, value));
    }
}


@end

