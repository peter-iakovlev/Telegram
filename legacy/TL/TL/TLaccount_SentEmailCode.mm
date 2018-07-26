#import "TLaccount_SentEmailCode.h"

@implementation TLaccount_SentEmailCode

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

@implementation TLaccount_SentEmailCode$account_sentEmailCode : TLaccount_SentEmailCode


- (int32_t)TLconstructorSignature
{
    return (int32_t)0x811f854f;
}

- (int32_t)TLconstructorName
{
    return (int32_t)0x95c4f46e;
}

- (id<TLObject>)TLbuildFromMetaObject:(std::shared_ptr<TLMetaObject>)metaObject
{
    TLaccount_SentEmailCode$account_sentEmailCode *object = [[TLaccount_SentEmailCode$account_sentEmailCode alloc] init];
    object.email_pattern = metaObject->getString((int32_t)0x2499ca21);
    object.length = metaObject->getInt32((int32_t)0x18492126);
    return object;
}

- (void)TLfillFieldsWithValues:(std::map<int32_t, TLConstructedValue> *)values
{
    {
        TLConstructedValue value;
        value.type = TLConstructedValueTypeString;
        value.nativeObject = self.email_pattern;
        values->insert(std::pair<int32_t, TLConstructedValue>((int32_t)0x2499ca21, value));
    }
    {
        TLConstructedValue value;
        value.type = TLConstructedValueTypePrimitiveInt32;
        value.primitive.int32Value = self.length;
        values->insert(std::pair<int32_t, TLConstructedValue>((int32_t)0x18492126, value));
    }
}


@end

