#import "TLSecureValueHash.h"

@implementation TLSecureValueHash

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

@implementation TLSecureValueHash$secureValueHash : TLSecureValueHash


- (int32_t)TLconstructorSignature
{
    return (int32_t)0xed1ecdb0;
}

- (int32_t)TLconstructorName
{
    return (int32_t)0xa75765d2;
}

- (id<TLObject>)TLbuildFromMetaObject:(std::shared_ptr<TLMetaObject>)metaObject
{
    TLSecureValueHash$secureValueHash *object = [[TLSecureValueHash$secureValueHash alloc] init];
    object.type = metaObject->getObject((int32_t)0x9211ab0a);
    object.n_hash = metaObject->getBytes((int32_t)0xc152e470);
    return object;
}

- (void)TLfillFieldsWithValues:(std::map<int32_t, TLConstructedValue> *)values
{
    {
        TLConstructedValue value;
        value.type = TLConstructedValueTypeObject;
        value.nativeObject = self.type;
        values->insert(std::pair<int32_t, TLConstructedValue>((int32_t)0x9211ab0a, value));
    }
    {
        TLConstructedValue value;
        value.type = TLConstructedValueTypeBytes;
        value.nativeObject = self.n_hash;
        values->insert(std::pair<int32_t, TLConstructedValue>((int32_t)0xc152e470, value));
    }
}


@end
