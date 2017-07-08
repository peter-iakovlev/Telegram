#import "TLServer_DH_inner_data.h"

#import "../NSInputStream+TL.h"
#import "../NSOutputStream+TL.h"


@implementation TLServer_DH_inner_data


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

@implementation TLServer_DH_inner_data$server_DH_inner_data : TLServer_DH_inner_data


- (int32_t)TLconstructorSignature
{
    return (int32_t)0xb5890dba;
}

- (int32_t)TLconstructorName
{
    return (int32_t)0x41472b5b;
}

- (id<TLObject>)TLbuildFromMetaObject:(std::shared_ptr<TLMetaObject>)metaObject
{
    TLServer_DH_inner_data$server_DH_inner_data *object = [[TLServer_DH_inner_data$server_DH_inner_data alloc] init];
    object.nonce = metaObject->getBytes((int32_t)0x48cbe731);
    object.server_nonce = metaObject->getBytes((int32_t)0xe1dc3f2c);
    object.g = metaObject->getInt32((int32_t)0x75e1067a);
    object.dh_prime = metaObject->getBytes((int32_t)0xbd796e8b);
    object.g_a = metaObject->getBytes((int32_t)0xa6887fe5);
    object.server_time = metaObject->getInt32((int32_t)0x5dcc0dd1);
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
        value.type = TLConstructedValueTypePrimitiveInt32;
        value.primitive.int32Value = self.g;
        values->insert(std::pair<int32_t, TLConstructedValue>((int32_t)0x75e1067a, value));
    }
    {
        TLConstructedValue value;
        value.type = TLConstructedValueTypeBytes;
        value.nativeObject = self.dh_prime;
        values->insert(std::pair<int32_t, TLConstructedValue>((int32_t)0xbd796e8b, value));
    }
    {
        TLConstructedValue value;
        value.type = TLConstructedValueTypeBytes;
        value.nativeObject = self.g_a;
        values->insert(std::pair<int32_t, TLConstructedValue>((int32_t)0xa6887fe5, value));
    }
    {
        TLConstructedValue value;
        value.type = TLConstructedValueTypePrimitiveInt32;
        value.primitive.int32Value = self.server_time;
        values->insert(std::pair<int32_t, TLConstructedValue>((int32_t)0x5dcc0dd1, value));
    }
}


@end

