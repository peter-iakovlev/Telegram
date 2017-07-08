#import "TLRPChelp_getAppUpdate.h"

#import "../NSInputStream+TL.h"
#import "../NSOutputStream+TL.h"

#import "TLhelp_AppUpdate.h"

@implementation TLRPChelp_getAppUpdate


- (Class)responseClass
{
    return [TLhelp_AppUpdate class];
}

- (int)impliedResponseSignature
{
    return 0;
}

- (int)layerVersion
{
    return 8;
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

@implementation TLRPChelp_getAppUpdate$help_getAppUpdate : TLRPChelp_getAppUpdate


- (int32_t)TLconstructorSignature
{
    return (int32_t)0xc812ac7e;
}

- (int32_t)TLconstructorName
{
    return (int32_t)0x3001772a;
}

- (id<TLObject>)TLbuildFromMetaObject:(std::shared_ptr<TLMetaObject>)metaObject
{
    TLRPChelp_getAppUpdate$help_getAppUpdate *object = [[TLRPChelp_getAppUpdate$help_getAppUpdate alloc] init];
    object.device_model = metaObject->getString((int32_t)0x7baba117);
    object.system_version = metaObject->getString((int32_t)0x18665337);
    object.app_version = metaObject->getString((int32_t)0xe92d4c10);
    object.lang_code = metaObject->getString((int32_t)0x2ccfcaf3);
    return object;
}

- (void)TLfillFieldsWithValues:(std::map<int32_t, TLConstructedValue> *)values
{
    {
        TLConstructedValue value;
        value.type = TLConstructedValueTypeString;
        value.nativeObject = self.device_model;
        values->insert(std::pair<int32_t, TLConstructedValue>((int32_t)0x7baba117, value));
    }
    {
        TLConstructedValue value;
        value.type = TLConstructedValueTypeString;
        value.nativeObject = self.system_version;
        values->insert(std::pair<int32_t, TLConstructedValue>((int32_t)0x18665337, value));
    }
    {
        TLConstructedValue value;
        value.type = TLConstructedValueTypeString;
        value.nativeObject = self.app_version;
        values->insert(std::pair<int32_t, TLConstructedValue>((int32_t)0xe92d4c10, value));
    }
    {
        TLConstructedValue value;
        value.type = TLConstructedValueTypeString;
        value.nativeObject = self.lang_code;
        values->insert(std::pair<int32_t, TLConstructedValue>((int32_t)0x2ccfcaf3, value));
    }
}


@end

