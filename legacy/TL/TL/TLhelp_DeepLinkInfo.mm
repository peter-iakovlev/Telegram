#import "TLhelp_DeepLinkInfo.h"

@implementation TLhelp_DeepLinkInfo

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

@implementation TLhelp_DeepLinkInfo$help_deepLinkInfoEmpty : TLhelp_DeepLinkInfo


- (int32_t)TLconstructorSignature
{
    return (int32_t)0x66afa166;
}

- (int32_t)TLconstructorName
{
    return (int32_t)0xd10f80c7;
}

- (id<TLObject>)TLbuildFromMetaObject:(std::shared_ptr<TLMetaObject>)__unused metaObject
{
    TLhelp_DeepLinkInfo$help_deepLinkInfoEmpty *object = [[TLhelp_DeepLinkInfo$help_deepLinkInfoEmpty alloc] init];
    return object;
}

- (void)TLfillFieldsWithValues:(std::map<int32_t, TLConstructedValue> *)__unused values
{
}


@end

@implementation TLhelp_DeepLinkInfo$help_deepLinkInfoMeta : TLhelp_DeepLinkInfo


- (int32_t)TLconstructorSignature
{
    return (int32_t)0x6a4ee832;
}

- (int32_t)TLconstructorName
{
    return (int32_t)0x1d5eec1b;
}

- (id<TLObject>)TLbuildFromMetaObject:(std::shared_ptr<TLMetaObject>)metaObject
{
    TLhelp_DeepLinkInfo$help_deepLinkInfoMeta *object = [[TLhelp_DeepLinkInfo$help_deepLinkInfoMeta alloc] init];
    object.flags = metaObject->getInt32((int32_t)0x81915c23);
    object.message = metaObject->getString((int32_t)0xc43b7853);
    object.entities = metaObject->getArray((int32_t)0x97759865);
    return object;
}

- (void)TLfillFieldsWithValues:(std::map<int32_t, TLConstructedValue> *)values
{
    {
        TLConstructedValue value;
        value.type = TLConstructedValueTypePrimitiveInt32;
        value.primitive.int32Value = self.flags;
        values->insert(std::pair<int32_t, TLConstructedValue>((int32_t)0x81915c23, value));
    }
    {
        TLConstructedValue value;
        value.type = TLConstructedValueTypeString;
        value.nativeObject = self.message;
        values->insert(std::pair<int32_t, TLConstructedValue>((int32_t)0xc43b7853, value));
    }
    {
        TLConstructedValue value;
        value.type = TLConstructedValueTypeVector;
        value.nativeObject = self.entities;
        values->insert(std::pair<int32_t, TLConstructedValue>((int32_t)0x97759865, value));
    }
}


@end

