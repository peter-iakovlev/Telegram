#import "TLSchemeType.h"

#import "../NSInputStream+TL.h"
#import "../NSOutputStream+TL.h"


@implementation TLSchemeType


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

@implementation TLSchemeType$schemeType : TLSchemeType


- (int32_t)TLconstructorSignature
{
    return (int32_t)0xa8e1e989;
}

- (int32_t)TLconstructorName
{
    return (int32_t)0x85a203a1;
}

- (id<TLObject>)TLbuildFromMetaObject:(std::shared_ptr<TLMetaObject>)metaObject
{
    TLSchemeType$schemeType *object = [[TLSchemeType$schemeType alloc] init];
    object.n_id = metaObject->getInt32((int32_t)0x7a5601fb);
    object.predicate = metaObject->getString((int32_t)0x5b3a3e46);
    object.params = metaObject->getArray((int32_t)0xb58ba8a1);
    object.type = metaObject->getString((int32_t)0x9211ab0a);
    return object;
}

- (void)TLfillFieldsWithValues:(std::map<int32_t, TLConstructedValue> *)values
{
    {
        TLConstructedValue value;
        value.type = TLConstructedValueTypePrimitiveInt32;
        value.primitive.int32Value = self.n_id;
        values->insert(std::pair<int32_t, TLConstructedValue>((int32_t)0x7a5601fb, value));
    }
    {
        TLConstructedValue value;
        value.type = TLConstructedValueTypeString;
        value.nativeObject = self.predicate;
        values->insert(std::pair<int32_t, TLConstructedValue>((int32_t)0x5b3a3e46, value));
    }
    {
        TLConstructedValue value;
        value.type = TLConstructedValueTypeVector;
        value.nativeObject = self.params;
        values->insert(std::pair<int32_t, TLConstructedValue>((int32_t)0xb58ba8a1, value));
    }
    {
        TLConstructedValue value;
        value.type = TLConstructedValueTypeString;
        value.nativeObject = self.type;
        values->insert(std::pair<int32_t, TLConstructedValue>((int32_t)0x9211ab0a, value));
    }
}


@end

