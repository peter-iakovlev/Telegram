#import "TLSecurePlainData.h"

@implementation TLSecurePlainData

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

@implementation TLSecurePlainData$securePlainPhone : TLSecurePlainData


- (int32_t)TLconstructorSignature
{
    return (int32_t)0x7d6099dd;
}

- (int32_t)TLconstructorName
{
    return (int32_t)0x914f7ead;
}

- (id<TLObject>)TLbuildFromMetaObject:(std::shared_ptr<TLMetaObject>)metaObject
{
    TLSecurePlainData$securePlainPhone *object = [[TLSecurePlainData$securePlainPhone alloc] init];
    object.phone = metaObject->getString((int32_t)0x9e6a8d86);
    return object;
}

- (void)TLfillFieldsWithValues:(std::map<int32_t, TLConstructedValue> *)values
{
    {
        TLConstructedValue value;
        value.type = TLConstructedValueTypeString;
        value.nativeObject = self.phone;
        values->insert(std::pair<int32_t, TLConstructedValue>((int32_t)0x9e6a8d86, value));
    }
}


@end

@implementation TLSecurePlainData$securePlainEmail : TLSecurePlainData


- (int32_t)TLconstructorSignature
{
    return (int32_t)0x21ec5a5f;
}

- (int32_t)TLconstructorName
{
    return (int32_t)0xb1dfe11d;
}

- (id<TLObject>)TLbuildFromMetaObject:(std::shared_ptr<TLMetaObject>)metaObject
{
    TLSecurePlainData$securePlainEmail *object = [[TLSecurePlainData$securePlainEmail alloc] init];
    object.email = metaObject->getString((int32_t)0x5b2095e7);
    return object;
}

- (void)TLfillFieldsWithValues:(std::map<int32_t, TLConstructedValue> *)values
{
    {
        TLConstructedValue value;
        value.type = TLConstructedValueTypeString;
        value.nativeObject = self.email;
        values->insert(std::pair<int32_t, TLConstructedValue>((int32_t)0x5b2095e7, value));
    }
}


@end
