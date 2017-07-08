#import "TLRPChelp_getAppChangelog.h"

#import "../NSInputStream+TL.h"
#import "../NSOutputStream+TL.h"

#import "TLUpdates.h"

@implementation TLRPChelp_getAppChangelog


- (Class)responseClass
{
    return [TLUpdates class];
}

- (int)impliedResponseSignature
{
    return 0;
}

- (int)layerVersion
{
    return 64;
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

@implementation TLRPChelp_getAppChangelog$help_getAppChangelog : TLRPChelp_getAppChangelog


- (int32_t)TLconstructorSignature
{
    return (int32_t)0x9010ef6f;
}

- (int32_t)TLconstructorName
{
    return (int32_t)0xfb23d486;
}

- (id<TLObject>)TLbuildFromMetaObject:(std::shared_ptr<TLMetaObject>)metaObject
{
    TLRPChelp_getAppChangelog$help_getAppChangelog *object = [[TLRPChelp_getAppChangelog$help_getAppChangelog alloc] init];
    object.prev_app_version = metaObject->getString((int32_t)0xb8b9e57a);
    return object;
}

- (void)TLfillFieldsWithValues:(std::map<int32_t, TLConstructedValue> *)values
{
    {
        TLConstructedValue value;
        value.type = TLConstructedValueTypeString;
        value.nativeObject = self.prev_app_version;
        values->insert(std::pair<int32_t, TLConstructedValue>((int32_t)0xb8b9e57a, value));
    }
}


@end

