#import "TLRPChelp_getRecentMeUrls.h"

#import "../NSInputStream+TL.h"
#import "../NSOutputStream+TL.h"

#import "NSArray_string.h"

@implementation TLRPChelp_getRecentMeUrls


- (Class)responseClass
{
    return [NSArray class];
}

- (int)impliedResponseSignature
{
    return (int)0x651abfef;
}

- (int)layerVersion
{
    return 72;
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

@implementation TLRPChelp_getRecentMeUrls$help_getRecentMeUrls : TLRPChelp_getRecentMeUrls


- (int32_t)TLconstructorSignature
{
    return (int32_t)0xd19bc174;
}

- (int32_t)TLconstructorName
{
    return (int32_t)0x38a0843b;
}

- (id<TLObject>)TLbuildFromMetaObject:(std::shared_ptr<TLMetaObject>)metaObject
{
    TLRPChelp_getRecentMeUrls$help_getRecentMeUrls *object = [[TLRPChelp_getRecentMeUrls$help_getRecentMeUrls alloc] init];
    object.referer = metaObject->getString((int32_t)0x5a2d8c62);
    return object;
}

- (void)TLfillFieldsWithValues:(std::map<int32_t, TLConstructedValue> *)values
{
    {
        TLConstructedValue value;
        value.type = TLConstructedValueTypeString;
        value.nativeObject = self.referer;
        values->insert(std::pair<int32_t, TLConstructedValue>((int32_t)0x5a2d8c62, value));
    }
}


@end

