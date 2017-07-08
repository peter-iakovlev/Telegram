#import "TLServer_DH_Params.h"

#import "../NSInputStream+TL.h"
#import "../NSOutputStream+TL.h"


@implementation TLServer_DH_Params


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

@implementation TLServer_DH_Params$server_DH_params_fail : TLServer_DH_Params


- (int32_t)TLconstructorSignature
{
    return (int32_t)0x79cb045d;
}

- (int32_t)TLconstructorName
{
    return (int32_t)0xf001b9ed;
}

- (id<TLObject>)TLbuildFromMetaObject:(std::shared_ptr<TLMetaObject>)metaObject
{
    TLServer_DH_Params$server_DH_params_fail *object = [[TLServer_DH_Params$server_DH_params_fail alloc] init];
    object.nonce = metaObject->getBytes((int32_t)0x48cbe731);
    object.server_nonce = metaObject->getBytes((int32_t)0xe1dc3f2c);
    object.n_new_nonce_hash = metaObject->getBytes((int32_t)0x5568335a);
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
        value.nativeObject = self.n_new_nonce_hash;
        values->insert(std::pair<int32_t, TLConstructedValue>((int32_t)0x5568335a, value));
    }
}


@end

@implementation TLServer_DH_Params$server_DH_params_ok : TLServer_DH_Params


- (int32_t)TLconstructorSignature
{
    return (int32_t)0xd0e8075c;
}

- (int32_t)TLconstructorName
{
    return (int32_t)0xf1e19570;
}

- (id<TLObject>)TLbuildFromMetaObject:(std::shared_ptr<TLMetaObject>)metaObject
{
    TLServer_DH_Params$server_DH_params_ok *object = [[TLServer_DH_Params$server_DH_params_ok alloc] init];
    object.nonce = metaObject->getBytes((int32_t)0x48cbe731);
    object.server_nonce = metaObject->getBytes((int32_t)0xe1dc3f2c);
    object.encrypted_answer = metaObject->getBytes((int32_t)0xbdd67186);
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
        value.nativeObject = self.encrypted_answer;
        values->insert(std::pair<int32_t, TLConstructedValue>((int32_t)0xbdd67186, value));
    }
}


@end

