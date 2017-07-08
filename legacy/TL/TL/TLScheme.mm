#import "TLScheme.h"

#import "../NSInputStream+TL.h"
#import "../NSOutputStream+TL.h"


@implementation TLScheme


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

@implementation TLScheme$scheme : TLScheme


- (int32_t)TLconstructorSignature
{
    return (int32_t)0x4e6ef65e;
}

- (int32_t)TLconstructorName
{
    return (int32_t)0x141525ef;
}

- (id<TLObject>)TLbuildFromMetaObject:(std::shared_ptr<TLMetaObject>)metaObject
{
    TLScheme$scheme *object = [[TLScheme$scheme alloc] init];
    object.scheme_raw = metaObject->getString((int32_t)0x595f3bb0);
    object.types = metaObject->getArray((int32_t)0x32251ae0);
    object.methods = metaObject->getArray((int32_t)0x6a1783c2);
    object.version = metaObject->getInt32((int32_t)0x4ea810e9);
    return object;
}

- (void)TLfillFieldsWithValues:(std::map<int32_t, TLConstructedValue> *)values
{
    {
        TLConstructedValue value;
        value.type = TLConstructedValueTypeString;
        value.nativeObject = self.scheme_raw;
        values->insert(std::pair<int32_t, TLConstructedValue>((int32_t)0x595f3bb0, value));
    }
    {
        TLConstructedValue value;
        value.type = TLConstructedValueTypeVector;
        value.nativeObject = self.types;
        values->insert(std::pair<int32_t, TLConstructedValue>((int32_t)0x32251ae0, value));
    }
    {
        TLConstructedValue value;
        value.type = TLConstructedValueTypeVector;
        value.nativeObject = self.methods;
        values->insert(std::pair<int32_t, TLConstructedValue>((int32_t)0x6a1783c2, value));
    }
    {
        TLConstructedValue value;
        value.type = TLConstructedValueTypePrimitiveInt32;
        value.primitive.int32Value = self.version;
        values->insert(std::pair<int32_t, TLConstructedValue>((int32_t)0x4ea810e9, value));
    }
}


@end

@implementation TLScheme$schemeNotModified : TLScheme


- (int32_t)TLconstructorSignature
{
    return (int32_t)0x263c9c58;
}

- (int32_t)TLconstructorName
{
    return (int32_t)0xee8efac4;
}

- (id<TLObject>)TLbuildFromMetaObject:(std::shared_ptr<TLMetaObject>)__unused metaObject
{
    TLScheme$schemeNotModified *object = [[TLScheme$schemeNotModified alloc] init];
    return object;
}

- (void)TLfillFieldsWithValues:(std::map<int32_t, TLConstructedValue> *)__unused values
{
}


@end

