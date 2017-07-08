#import "TLRPClangpack_getLanguages.h"

#import "../NSInputStream+TL.h"
#import "../NSOutputStream+TL.h"

#import "NSArray_LangPackLanguage.h"

@implementation TLRPClangpack_getLanguages


- (Class)responseClass
{
    return [NSArray class];
}

- (int)impliedResponseSignature
{
    return (int)0xf1fb56bc;
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

@implementation TLRPClangpack_getLanguages$langpack_getLanguages : TLRPClangpack_getLanguages


- (int32_t)TLconstructorSignature
{
    return (int32_t)0x800fd57d;
}

- (int32_t)TLconstructorName
{
    return (int32_t)0x230ac3a6;
}

- (id<TLObject>)TLbuildFromMetaObject:(std::shared_ptr<TLMetaObject>)__unused metaObject
{
    TLRPClangpack_getLanguages$langpack_getLanguages *object = [[TLRPClangpack_getLanguages$langpack_getLanguages alloc] init];
    return object;
}

- (void)TLfillFieldsWithValues:(std::map<int32_t, TLConstructedValue> *)__unused values
{
}


@end

