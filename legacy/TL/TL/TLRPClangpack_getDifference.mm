#import "TLRPClangpack_getDifference.h"

#import "../NSInputStream+TL.h"
#import "../NSOutputStream+TL.h"

#import "TLLangPackDifference.h"

@implementation TLRPClangpack_getDifference


- (Class)responseClass
{
    return [TLLangPackDifference class];
}

- (int)impliedResponseSignature
{
    return (int)0xf385c1f6;
}

- (int)layerVersion
{
    return 67;
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

@implementation TLRPClangpack_getDifference$langpack_getDifference : TLRPClangpack_getDifference


- (int32_t)TLconstructorSignature
{
    return (int32_t)0xb2e4d7d;
}

- (int32_t)TLconstructorName
{
    return (int32_t)0x8b088c1;
}

- (id<TLObject>)TLbuildFromMetaObject:(std::shared_ptr<TLMetaObject>)metaObject
{
    TLRPClangpack_getDifference$langpack_getDifference *object = [[TLRPClangpack_getDifference$langpack_getDifference alloc] init];
    object.from_version = metaObject->getInt32((int32_t)0x75ff6a2f);
    return object;
}

- (void)TLfillFieldsWithValues:(std::map<int32_t, TLConstructedValue> *)values
{
    {
        TLConstructedValue value;
        value.type = TLConstructedValueTypePrimitiveInt32;
        value.primitive.int32Value = self.from_version;
        values->insert(std::pair<int32_t, TLConstructedValue>((int32_t)0x75ff6a2f, value));
    }
}


@end

