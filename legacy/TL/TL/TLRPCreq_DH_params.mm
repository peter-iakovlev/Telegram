#import "TLRPCreq_DH_params.h"

#import "../NSInputStream+TL.h"
#import "../NSOutputStream+TL.h"

#import "TLServer_DH_Params.h"

@implementation TLRPCreq_DH_params


- (Class)responseClass
{
    return [TLServer_DH_Params class];
}

- (int)impliedResponseSignature
{
    return 0;
}

- (int)layerVersion
{
    return 0;
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

@implementation TLRPCreq_DH_params$req_DH_params : TLRPCreq_DH_params


- (int32_t)TLconstructorSignature
{
    return (int32_t)0xd712e4be;
}

- (int32_t)TLconstructorName
{
    return (int32_t)0x3cf4b562;
}

- (id<TLObject>)TLbuildFromMetaObject:(std::shared_ptr<TLMetaObject>)metaObject
{
    TLRPCreq_DH_params$req_DH_params *object = [[TLRPCreq_DH_params$req_DH_params alloc] init];
    object.nonce = metaObject->getBytes((int32_t)0x48cbe731);
    object.server_nonce = metaObject->getBytes((int32_t)0xe1dc3f2c);
    object.p = metaObject->getBytes((int32_t)0xb91d8925);
    object.q = metaObject->getBytes((int32_t)0xcd45cb1c);
    object.public_key_fingerprint = metaObject->getInt64((int32_t)0x9a3a505d);
    object.encrypted_data = metaObject->getBytes((int32_t)0xd9c47df7);
    return object;
}

- (void)TLfillFieldsWithValues:(std::map<int32_t, TLConstructedValue> *)values
{
    {
        TLConstructedValue value;
        value.type = TLConstructedValueTypeBytes;
        value.nativeObject = self.nonce;
        values->insert(std::pair<int32_t, TLConstructedValue>((int32_t)0x48cbe731, value));
    }
    {
        TLConstructedValue value;
        value.type = TLConstructedValueTypeBytes;
        value.nativeObject = self.server_nonce;
        values->insert(std::pair<int32_t, TLConstructedValue>((int32_t)0xe1dc3f2c, value));
    }
    {
        TLConstructedValue value;
        value.type = TLConstructedValueTypeBytes;
        value.nativeObject = self.p;
        values->insert(std::pair<int32_t, TLConstructedValue>((int32_t)0xb91d8925, value));
    }
    {
        TLConstructedValue value;
        value.type = TLConstructedValueTypeBytes;
        value.nativeObject = self.q;
        values->insert(std::pair<int32_t, TLConstructedValue>((int32_t)0xcd45cb1c, value));
    }
    {
        TLConstructedValue value;
        value.type = TLConstructedValueTypePrimitiveInt64;
        value.primitive.int64Value = self.public_key_fingerprint;
        values->insert(std::pair<int32_t, TLConstructedValue>((int32_t)0x9a3a505d, value));
    }
    {
        TLConstructedValue value;
        value.type = TLConstructedValueTypeBytes;
        value.nativeObject = self.encrypted_data;
        values->insert(std::pair<int32_t, TLConstructedValue>((int32_t)0xd9c47df7, value));
    }
}


@end

