#import "TLRPChelp_getScheme.h"

#import "../NSInputStream+TL.h"
#import "../NSOutputStream+TL.h"

#import "TLScheme.h"

@implementation TLRPChelp_getScheme


- (Class)responseClass
{
    return [TLScheme class];
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

@implementation TLRPChelp_getScheme$help_getScheme : TLRPChelp_getScheme


- (int32_t)TLconstructorSignature
{
    return (int32_t)0xdbb69a9e;
}

- (int32_t)TLconstructorName
{
    return (int32_t)0x36525e30;
}

- (id<TLObject>)TLbuildFromMetaObject:(std::shared_ptr<TLMetaObject>)metaObject
{
    TLRPChelp_getScheme$help_getScheme *object = [[TLRPChelp_getScheme$help_getScheme alloc] init];
    object.version = metaObject->getInt32((int32_t)0x4ea810e9);
    return object;
}

- (void)TLfillFieldsWithValues:(std::map<int32_t, TLConstructedValue> *)values
{
    {
        TLConstructedValue value;
        value.type = TLConstructedValueTypePrimitiveInt32;
        value.primitive.int32Value = self.version;
        values->insert(std::pair<int32_t, TLConstructedValue>((int32_t)0x4ea810e9, value));
    }
}


@end

