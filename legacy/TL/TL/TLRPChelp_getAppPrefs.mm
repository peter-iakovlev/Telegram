#import "TLRPChelp_getAppPrefs.h"

#import "../NSInputStream+TL.h"
#import "../NSOutputStream+TL.h"

#import "TLhelp_AppPrefs.h"

@implementation TLRPChelp_getAppPrefs


- (Class)responseClass
{
    return [TLhelp_AppPrefs class];
}

- (int)impliedResponseSignature
{
    return (int)0x424f8614;
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

@implementation TLRPChelp_getAppPrefs$help_getAppPrefs : TLRPChelp_getAppPrefs


- (int32_t)TLconstructorSignature
{
    return (int32_t)0x704120a3;
}

- (int32_t)TLconstructorName
{
    return (int32_t)0x5b448a73;
}

- (id<TLObject>)TLbuildFromMetaObject:(std::shared_ptr<TLMetaObject>)metaObject
{
    TLRPChelp_getAppPrefs$help_getAppPrefs *object = [[TLRPChelp_getAppPrefs$help_getAppPrefs alloc] init];
    object.api_id = metaObject->getInt32((int32_t)0x658ffe92);
    object.api_hash = metaObject->getString((int32_t)0x868d53ee);
    return object;
}

- (void)TLfillFieldsWithValues:(std::map<int32_t, TLConstructedValue> *)values
{
    {
        TLConstructedValue value;
        value.type = TLConstructedValueTypePrimitiveInt32;
        value.primitive.int32Value = self.api_id;
        values->insert(std::pair<int32_t, TLConstructedValue>((int32_t)0x658ffe92, value));
    }
    {
        TLConstructedValue value;
        value.type = TLConstructedValueTypeString;
        value.nativeObject = self.api_hash;
        values->insert(std::pair<int32_t, TLConstructedValue>((int32_t)0x868d53ee, value));
    }
}


@end

