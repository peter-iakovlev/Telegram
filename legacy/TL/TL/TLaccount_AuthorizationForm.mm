#import "TLaccount_AuthorizationForm.h"

@implementation TLaccount_AuthorizationForm

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

@implementation TLaccount_AuthorizationForm$account_authorizationFormMeta : TLaccount_AuthorizationForm


- (int32_t)TLconstructorSignature
{
    return (int32_t)0x4cace8c4;
}

- (int32_t)TLconstructorName
{
    return (int32_t)0xab4da313;
}

- (id<TLObject>)TLbuildFromMetaObject:(std::shared_ptr<TLMetaObject>)metaObject
{
    TLaccount_AuthorizationForm$account_authorizationFormMeta *object = [[TLaccount_AuthorizationForm$account_authorizationFormMeta alloc] init];
    object.required_types = metaObject->getArray((int32_t)0x60feea06);
    object.values = metaObject->getArray((int32_t)0xb24bd274);
    object.users = metaObject->getArray((int32_t)0x933e5ff3);
    return object;
}

- (void)TLfillFieldsWithValues:(std::map<int32_t, TLConstructedValue> *)values
{
    {
        TLConstructedValue value;
        value.type = TLConstructedValueTypeVector;
        value.nativeObject = self.required_types;
        values->insert(std::pair<int32_t, TLConstructedValue>((int32_t)0x60feea06, value));
    }
    {
        TLConstructedValue value;
        value.type = TLConstructedValueTypeVector;
        value.nativeObject = self.values;
        values->insert(std::pair<int32_t, TLConstructedValue>((int32_t)0xb24bd274, value));
    }
    {
        TLConstructedValue value;
        value.type = TLConstructedValueTypeVector;
        value.nativeObject = self.users;
        values->insert(std::pair<int32_t, TLConstructedValue>((int32_t)0x933e5ff3, value));
    }
}


@end
