#import "TLRPCauth_exportAuthorization.h"

#import "../NSInputStream+TL.h"
#import "../NSOutputStream+TL.h"

#import "TLauth_ExportedAuthorization.h"

@implementation TLRPCauth_exportAuthorization


- (Class)responseClass
{
    return [TLauth_ExportedAuthorization class];
}

- (int)impliedResponseSignature
{
    return (int)0xdf969c2d;
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

@implementation TLRPCauth_exportAuthorization$auth_exportAuthorization : TLRPCauth_exportAuthorization


- (int32_t)TLconstructorSignature
{
    return (int32_t)0xe5bfffcd;
}

- (int32_t)TLconstructorName
{
    return (int32_t)0x1fa9ee2d;
}

- (id<TLObject>)TLbuildFromMetaObject:(std::shared_ptr<TLMetaObject>)metaObject
{
    TLRPCauth_exportAuthorization$auth_exportAuthorization *object = [[TLRPCauth_exportAuthorization$auth_exportAuthorization alloc] init];
    object.dc_id = metaObject->getInt32((int32_t)0xae973dc4);
    return object;
}

- (void)TLfillFieldsWithValues:(std::map<int32_t, TLConstructedValue> *)values
{
    {
        TLConstructedValue value;
        value.type = TLConstructedValueTypePrimitiveInt32;
        value.primitive.int32Value = self.dc_id;
        values->insert(std::pair<int32_t, TLConstructedValue>((int32_t)0xae973dc4, value));
    }
}


@end

