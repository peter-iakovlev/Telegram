#import "TLSchemeMethod.h"

#import "../NSInputStream+TL.h"
#import "../NSOutputStream+TL.h"


@implementation TLSchemeMethod


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

@implementation TLSchemeMethod$schemeMethod : TLSchemeMethod


- (int32_t)TLconstructorSignature
{
    return (int32_t)0x479357c0;
}

- (int32_t)TLconstructorName
{
    return (int32_t)0xed3e7bb0;
}

- (id<TLObject>)TLbuildFromMetaObject:(std::shared_ptr<TLMetaObject>)metaObject
{
    TLSchemeMethod$schemeMethod *object = [[TLSchemeMethod$schemeMethod alloc] init];
    object.n_id = metaObject->getInt32((int32_t)0x7a5601fb);
    object.method = metaObject->getString((int32_t)0xe282a4e9);
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
        value.nativeObject = self.method;
        values->insert(std::pair<int32_t, TLConstructedValue>((int32_t)0xe282a4e9, value));
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

