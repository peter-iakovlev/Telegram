#import "TLRPCphone_requestCall.h"

#import "../NSInputStream+TL.h"
#import "../NSOutputStream+TL.h"

#import "TLInputUser.h"
#import "TLPhoneCallProtocol.h"
#import "TLphone_PhoneCall.h"

@implementation TLRPCphone_requestCall


- (Class)responseClass
{
    return [TLphone_PhoneCall class];
}

- (int)impliedResponseSignature
{
    return (int)0xec82e140;
}

- (int)layerVersion
{
    return 64;
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

@implementation TLRPCphone_requestCall$phone_requestCall : TLRPCphone_requestCall


- (int32_t)TLconstructorSignature
{
    return (int32_t)0x5b95b3d4;
}

- (int32_t)TLconstructorName
{
    return (int32_t)0xc5eecdc9;
}

- (id<TLObject>)TLbuildFromMetaObject:(std::shared_ptr<TLMetaObject>)metaObject
{
    TLRPCphone_requestCall$phone_requestCall *object = [[TLRPCphone_requestCall$phone_requestCall alloc] init];
    object.user_id = metaObject->getObject((int32_t)0xafdf4073);
    object.random_id = metaObject->getInt32((int32_t)0xca5a160a);
    object.g_a_hash = metaObject->getBytes((int32_t)0xb39b1140);
    object.protocol = metaObject->getObject((int32_t)0xd45aa5f2);
    return object;
}

- (void)TLfillFieldsWithValues:(std::map<int32_t, TLConstructedValue> *)values
{
    {
        TLConstructedValue value;
        value.type = TLConstructedValueTypeObject;
        value.nativeObject = self.user_id;
        values->insert(std::pair<int32_t, TLConstructedValue>((int32_t)0xafdf4073, value));
    }
    {
        TLConstructedValue value;
        value.type = TLConstructedValueTypePrimitiveInt32;
        value.primitive.int32Value = self.random_id;
        values->insert(std::pair<int32_t, TLConstructedValue>((int32_t)0xca5a160a, value));
    }
    {
        TLConstructedValue value;
        value.type = TLConstructedValueTypeBytes;
        value.nativeObject = self.g_a_hash;
        values->insert(std::pair<int32_t, TLConstructedValue>((int32_t)0xb39b1140, value));
    }
    {
        TLConstructedValue value;
        value.type = TLConstructedValueTypeObject;
        value.nativeObject = self.protocol;
        values->insert(std::pair<int32_t, TLConstructedValue>((int32_t)0xd45aa5f2, value));
    }
}


@end

