#import "TLhelp_TermsOfServiceUpdate.h"

#import "../NSInputStream+TL.h"
#import "../NSOutputStream+TL.h"


@implementation TLhelp_TermsOfServiceUpdate


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

@implementation TLhelp_TermsOfServiceUpdate$help_termsOfServiceUpdateEmpty : TLhelp_TermsOfServiceUpdate


- (int32_t)TLconstructorSignature
{
    return (int32_t)0xe3309f7f;
}

- (int32_t)TLconstructorName
{
    return (int32_t)0x400e1037;
}

- (id<TLObject>)TLbuildFromMetaObject:(std::shared_ptr<TLMetaObject>)metaObject
{
    TLhelp_TermsOfServiceUpdate$help_termsOfServiceUpdateEmpty *object = [[TLhelp_TermsOfServiceUpdate$help_termsOfServiceUpdateEmpty alloc] init];
    object.expires = metaObject->getInt32((int32_t)0x4743fb6b);
    return object;
}

- (void)TLfillFieldsWithValues:(std::map<int32_t, TLConstructedValue> *)values
{
    {
        TLConstructedValue value;
        value.type = TLConstructedValueTypePrimitiveInt32;
        value.primitive.int32Value = self.expires;
        values->insert(std::pair<int32_t, TLConstructedValue>((int32_t)0x4743fb6b, value));
    }
}


@end

@implementation TLhelp_TermsOfServiceUpdate$help_termsOfServiceUpdate : TLhelp_TermsOfServiceUpdate


- (int32_t)TLconstructorSignature
{
    return (int32_t)0x28ecf961;
}

- (int32_t)TLconstructorName
{
    return (int32_t)0x1170b6d4;
}

- (id<TLObject>)TLbuildFromMetaObject:(std::shared_ptr<TLMetaObject>)metaObject
{
    TLhelp_TermsOfServiceUpdate$help_termsOfServiceUpdate *object = [[TLhelp_TermsOfServiceUpdate$help_termsOfServiceUpdate alloc] init];
    object.expires = metaObject->getInt32((int32_t)0x4743fb6b);
    object.terms_of_service = metaObject->getObject((int32_t)0xfac33343);
    return object;
}

- (void)TLfillFieldsWithValues:(std::map<int32_t, TLConstructedValue> *)values
{
    {
        TLConstructedValue value;
        value.type = TLConstructedValueTypePrimitiveInt32;
        value.primitive.int32Value = self.expires;
        values->insert(std::pair<int32_t, TLConstructedValue>((int32_t)0x4743fb6b, value));
    }
    {
        TLConstructedValue value;
        value.type = TLConstructedValueTypeObject;
        value.nativeObject = self.terms_of_service;
        values->insert(std::pair<int32_t, TLConstructedValue>((int32_t)0xfac33343, value));
    }
}


@end

