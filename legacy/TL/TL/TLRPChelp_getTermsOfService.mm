#import "TLRPChelp_getTermsOfService.h"

#import "../NSInputStream+TL.h"
#import "../NSOutputStream+TL.h"

#import "TLhelp_TermsOfService.h"

@implementation TLRPChelp_getTermsOfService


- (Class)responseClass
{
    return [TLhelp_TermsOfService class];
}

- (int)impliedResponseSignature
{
    return (int)0xf1ee3e90;
}

- (int)layerVersion
{
    return 41;
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

@implementation TLRPChelp_getTermsOfService$help_getTermsOfService : TLRPChelp_getTermsOfService


- (int32_t)TLconstructorSignature
{
    return (int32_t)0x37d78f83;
}

- (int32_t)TLconstructorName
{
    return (int32_t)0xbdfb3311;
}

- (id<TLObject>)TLbuildFromMetaObject:(std::shared_ptr<TLMetaObject>)metaObject
{
    TLRPChelp_getTermsOfService$help_getTermsOfService *object = [[TLRPChelp_getTermsOfService$help_getTermsOfService alloc] init];
    object.lang_code = metaObject->getString((int32_t)0x2ccfcaf3);
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
}


@end

