#import "TLRPClangpack_getStrings.h"

#import "../NSInputStream+TL.h"
#import "../NSOutputStream+TL.h"

#import "NSArray_LangPackString.h"

@implementation TLRPClangpack_getStrings


- (Class)responseClass
{
    return [NSArray class];
}

- (int)impliedResponseSignature
{
    return (int)0x7c8e948;
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

@implementation TLRPClangpack_getStrings$langpack_getStrings : TLRPClangpack_getStrings


- (int32_t)TLconstructorSignature
{
    return (int32_t)0x2e1ee318;
}

- (int32_t)TLconstructorName
{
    return (int32_t)0xb1550bc8;
}

- (id<TLObject>)TLbuildFromMetaObject:(std::shared_ptr<TLMetaObject>)metaObject
{
    TLRPClangpack_getStrings$langpack_getStrings *object = [[TLRPClangpack_getStrings$langpack_getStrings alloc] init];
    object.lang_code = metaObject->getString((int32_t)0x2ccfcaf3);
    object.keys = metaObject->getArray((int32_t)0x5d5f4afa);
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
        value.type = TLConstructedValueTypeVector;
        value.nativeObject = self.keys;
        values->insert(std::pair<int32_t, TLConstructedValue>((int32_t)0x5d5f4afa, value));
    }
}


@end

