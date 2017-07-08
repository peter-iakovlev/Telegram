#import "TLRPCset_client_DH_params.h"

#import "../NSInputStream+TL.h"
#import "../NSOutputStream+TL.h"

#import "TLSet_client_DH_params_answer.h"

@implementation TLRPCset_client_DH_params


- (Class)responseClass
{
    return [TLSet_client_DH_params_answer class];
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

@implementation TLRPCset_client_DH_params$set_client_DH_params : TLRPCset_client_DH_params


- (int32_t)TLconstructorSignature
{
    return (int32_t)0xf5045f1f;
}

- (int32_t)TLconstructorName
{
    return (int32_t)0x732822ea;
}

- (id<TLObject>)TLbuildFromMetaObject:(std::shared_ptr<TLMetaObject>)metaObject
{
    TLRPCset_client_DH_params$set_client_DH_params *object = [[TLRPCset_client_DH_params$set_client_DH_params alloc] init];
    object.nonce = metaObject->getBytes((int32_t)0x48cbe731);
    object.server_nonce = metaObject->getBytes((int32_t)0xe1dc3f2c);
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
        value.nativeObject = self.encrypted_data;
        values->insert(std::pair<int32_t, TLConstructedValue>((int32_t)0xd9c47df7, value));
    }
}


@end

