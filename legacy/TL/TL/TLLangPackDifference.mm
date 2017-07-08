#import "TLLangPackDifference.h"

#import "../NSInputStream+TL.h"
#import "../NSOutputStream+TL.h"


@implementation TLLangPackDifference


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

@implementation TLLangPackDifference$langPackDifference : TLLangPackDifference


- (int32_t)TLconstructorSignature
{
    return (int32_t)0xf385c1f6;
}

- (int32_t)TLconstructorName
{
    return (int32_t)0x73802d72;
}

- (id<TLObject>)TLbuildFromMetaObject:(std::shared_ptr<TLMetaObject>)metaObject
{
    TLLangPackDifference$langPackDifference *object = [[TLLangPackDifference$langPackDifference alloc] init];
    object.lang_code = metaObject->getString((int32_t)0x2ccfcaf3);
    object.from_version = metaObject->getInt32((int32_t)0x75ff6a2f);
    object.version = metaObject->getInt32((int32_t)0x4ea810e9);
    object.strings = metaObject->getArray((int32_t)0x1e032245);
    return object;
}

- (void)TLfillFieldsWithValues:(std::map<int32_t, TLConstructedValue> *)values
{
    {
        TLConstructedValue value;
        value.type = TLConstructedValueTypeString;
        value.nativeObject = self.lang_code;
        values->insert(std::pair<int32_t, TLConstructedValue>((int32_t)0x2ccfcaf3, value));
    }
    {
        TLConstructedValue value;
        value.type = TLConstructedValueTypePrimitiveInt32;
        value.primitive.int32Value = self.from_version;
        values->insert(std::pair<int32_t, TLConstructedValue>((int32_t)0x75ff6a2f, value));
    }
    {
        TLConstructedValue value;
        value.type = TLConstructedValueTypePrimitiveInt32;
        value.primitive.int32Value = self.version;
        values->insert(std::pair<int32_t, TLConstructedValue>((int32_t)0x4ea810e9, value));
    }
    {
        TLConstructedValue value;
        value.type = TLConstructedValueTypeVector;
        value.nativeObject = self.strings;
        values->insert(std::pair<int32_t, TLConstructedValue>((int32_t)0x1e032245, value));
    }
}


@end

