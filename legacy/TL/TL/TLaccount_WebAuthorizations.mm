#import "TLaccount_WebAuthorizations.h"

@implementation TLaccount_WebAuthorizations


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

@implementation TLaccount_WebAuthorizations$account_webAuthorizations : TLaccount_WebAuthorizations


- (int32_t)TLconstructorSignature
{
    return (int32_t)0xed56c9fc;
}

- (int32_t)TLconstructorName
{
    return (int32_t)0x7fbaefc2;
}

- (id<TLObject>)TLbuildFromMetaObject:(std::shared_ptr<TLMetaObject>)metaObject
{
    TLaccount_WebAuthorizations$account_webAuthorizations *object = [[TLaccount_WebAuthorizations$account_webAuthorizations alloc] init];
    object.authorizations = metaObject->getObject((int32_t)0x789949f8);
    object.users = metaObject->getArray((int32_t)0x933e5ff3);
    return object;
}

- (void)TLfillFieldsWithValues:(std::map<int32_t, TLConstructedValue> *)values
{
    {
        TLConstructedValue value;
        value.type = TLConstructedValueTypeVector;
        value.nativeObject = self.authorizations;
        values->insert(std::pair<int32_t, TLConstructedValue>((int32_t)0x789949f8, value));
    }
    {
        TLConstructedValue value;
        value.type = TLConstructedValueTypeVector;
        value.nativeObject = self.users;
        values->insert(std::pair<int32_t, TLConstructedValue>((int32_t)0x933e5ff3, value));
    }
}


@end
