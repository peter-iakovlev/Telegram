#import "TLRPCphone_confirmCall.h"

#import "../NSInputStream+TL.h"
#import "../NSOutputStream+TL.h"

#import "TLInputPhoneCall.h"
#import "TLPhoneCallProtocol.h"
#import "TLphone_PhoneCall.h"

@implementation TLRPCphone_confirmCall


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

@implementation TLRPCphone_confirmCall$phone_confirmCall : TLRPCphone_confirmCall


- (int32_t)TLconstructorSignature
{
    return (int32_t)0x2efe1722;
}

- (int32_t)TLconstructorName
{
    return (int32_t)0x753ccb0e;
}

- (id<TLObject>)TLbuildFromMetaObject:(std::shared_ptr<TLMetaObject>)metaObject
{
    TLRPCphone_confirmCall$phone_confirmCall *object = [[TLRPCphone_confirmCall$phone_confirmCall alloc] init];
    object.peer = metaObject->getObject((int32_t)0x9344c37d);
    object.g_a = metaObject->getBytes((int32_t)0xa6887fe5);
    object.key_fingerprint = metaObject->getInt64((int32_t)0x3633de43);
    object.protocol = metaObject->getObject((int32_t)0xd45aa5f2);
    return object;
}

- (void)TLfillFieldsWithValues:(std::map<int32_t, TLConstructedValue> *)values
{
    {
        TLConstructedValue value;
        value.type = TLConstructedValueTypeObject;
        value.nativeObject = self.peer;
        values->insert(std::pair<int32_t, TLConstructedValue>((int32_t)0x9344c37d, value));
    }
    {
        TLConstructedValue value;
        value.type = TLConstructedValueTypeBytes;
        value.nativeObject = self.g_a;
        values->insert(std::pair<int32_t, TLConstructedValue>((int32_t)0xa6887fe5, value));
    }
    {
        TLConstructedValue value;
        value.type = TLConstructedValueTypePrimitiveInt64;
        value.primitive.int64Value = self.key_fingerprint;
        values->insert(std::pair<int32_t, TLConstructedValue>((int32_t)0x3633de43, value));
    }
    {
        TLConstructedValue value;
        value.type = TLConstructedValueTypeObject;
        value.nativeObject = self.protocol;
        values->insert(std::pair<int32_t, TLConstructedValue>((int32_t)0xd45aa5f2, value));
    }
}


@end

