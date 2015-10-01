#import "TLRPCphone_confirmCall.h"

#import "../NSInputStream+TL.h"
#import "../NSOutputStream+TL.h"

#import "TLInputPhoneCall.h"
#import "TLPhoneConnection.h"

@implementation TLRPCphone_confirmCall


- (Class)responseClass
{
    return [TLPhoneConnection class];
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

- (id<TLObject>)TLbuildFromMetaObject:(std::tr1::shared_ptr<TLMetaObject>)__unused metaObject
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
    return (int32_t)0x3e383969;
}

- (int32_t)TLconstructorName
{
    return (int32_t)0x753ccb0e;
}

- (id<TLObject>)TLbuildFromMetaObject:(std::tr1::shared_ptr<TLMetaObject>)metaObject
{
    TLRPCphone_confirmCall$phone_confirmCall *object = [[TLRPCphone_confirmCall$phone_confirmCall alloc] init];
    object.n_id = metaObject->getObject((int32_t)0x7a5601fb);
    object.a_or_b = metaObject->getBytes((int32_t)0xd2c3dff4);
    return object;
}

- (void)TLfillFieldsWithValues:(std::map<int32_t, TLConstructedValue> *)values
{
    {
        TLConstructedValue value;
        value.type = TLConstructedValueTypeObject;
        value.nativeObject = self.n_id;
        values->insert(std::pair<int32_t, TLConstructedValue>((int32_t)0x7a5601fb, value));
    }
    {
        TLConstructedValue value;
        value.type = TLConstructedValueTypeBytes;
        value.nativeObject = self.a_or_b;
        values->insert(std::pair<int32_t, TLConstructedValue>((int32_t)0xd2c3dff4, value));
    }
}


@end

