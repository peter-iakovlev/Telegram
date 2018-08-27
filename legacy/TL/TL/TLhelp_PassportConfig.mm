#import "TLhelp_PassportConfig.h"

@implementation TLhelp_PassportConfig

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


@implementation TLhelp_PassportConfig$help_passportConfigNotModified : TLhelp_PassportConfig

- (int32_t)TLconstructorSignature
{
    return (int32_t)0xbfb9f457;
}

- (int32_t)TLconstructorName
{
    return (int32_t)0xa0491def;
}

- (id<TLObject>)TLbuildFromMetaObject:(std::shared_ptr<TLMetaObject>)__unused metaObject
{
    TLhelp_PassportConfig$help_passportConfigNotModified *object = [[TLhelp_PassportConfig$help_passportConfigNotModified alloc] init];
    return object;
}

- (void)TLfillFieldsWithValues:(std::map<int32_t, TLConstructedValue> *)__unused values
{
}


@end


@implementation TLhelp_PassportConfig$help_passportConfig : TLhelp_PassportConfig

- (int32_t)TLconstructorSignature
{
    return (int32_t)0xa098d6af;
}

- (int32_t)TLconstructorName
{
    return (int32_t)0x49152abd;
}

- (id<TLObject>)TLbuildFromMetaObject:(std::shared_ptr<TLMetaObject>)metaObject
{
    TLhelp_PassportConfig$help_passportConfig *object = [[TLhelp_PassportConfig$help_passportConfig alloc] init];
    object.n_hash = metaObject->getInt32((int32_t)0xc152e470);
    object.countries_langs = metaObject->getObject((int32_t)0x3a979b68);
    return object;
}

- (void)TLfillFieldsWithValues:(std::map<int32_t, TLConstructedValue> *)values
{
    {
        TLConstructedValue value;
        value.type = TLConstructedValueTypePrimitiveInt32;
        value.primitive.int32Value = self.n_hash;
        values->insert(std::pair<int32_t, TLConstructedValue>((int32_t)0xc152e470, value));
    }
    {
        TLConstructedValue value;
        value.type = TLConstructedValueTypeObject;
        value.nativeObject = self.countries_langs;
        values->insert(std::pair<int32_t, TLConstructedValue>((int32_t)0x3a979b68, value));
    }
}


@end
