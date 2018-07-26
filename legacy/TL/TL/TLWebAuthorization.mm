//webAuthorization#cac943f2 hash:long bot_id:int domain:string browser:string platform:string date_created:int date_active:int ip:string region:string = WebAuthorization;

#import "TLWebAuthorization.h"

#import "../NSInputStream+TL.h"
#import "../NSOutputStream+TL.h"

#import "TLInputPeer.h"

@implementation TLWebAuthorization


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

@implementation TLWebAuthorization$webAuthorization : TLWebAuthorization


- (int32_t)TLconstructorSignature
{
    return (int32_t)0xcac943f2;
}

- (int32_t)TLconstructorName
{
    return (int32_t)0xa0792d73;
}

- (id<TLObject>)TLbuildFromMetaObject:(std::shared_ptr<TLMetaObject>)metaObject
{
    TLWebAuthorization$webAuthorization *object = [[TLWebAuthorization$webAuthorization alloc] init];
    object.n_hash = metaObject->getInt64((int32_t)0xc152e470);
    object.bot_id = metaObject->getInt32((int32_t)0x214f3dba);
    object.domain = metaObject->getString((int32_t)0x4bfcaf2c);
    object.browser = metaObject->getString((int32_t)0x8d3cf31d);
    object.platform = metaObject->getString((int32_t)0x2b6704be);
    object.date_created = metaObject->getInt32((int32_t)0x1fa8db99);
    object.date_active = metaObject->getInt32((int32_t)0xdf2c7255);
    object.ip = metaObject->getString((int32_t)0xe5956ecc);
    object.region = metaObject->getString((int32_t)0x6758e6e0);
    return object;
}

- (void)TLfillFieldsWithValues:(std::map<int32_t, TLConstructedValue> *)values
{
    {
        TLConstructedValue value;
        value.type = TLConstructedValueTypePrimitiveInt64;
        value.primitive.int64Value = self.n_hash;
        values->insert(std::pair<int32_t, TLConstructedValue>((int32_t)0xc152e470, value));
    }
    {
        TLConstructedValue value;
        value.type = TLConstructedValueTypePrimitiveInt32;
        value.primitive.int32Value = self.bot_id;
        values->insert(std::pair<int32_t, TLConstructedValue>((int32_t)0x214f3dba, value));
    }
    {
        TLConstructedValue value;
        value.type = TLConstructedValueTypeString;
        value.nativeObject = self.domain;
        values->insert(std::pair<int32_t, TLConstructedValue>((int32_t)0x4bfcaf2c, value));
    }
    {
        TLConstructedValue value;
        value.type = TLConstructedValueTypeString;
        value.nativeObject = self.browser;
        values->insert(std::pair<int32_t, TLConstructedValue>((int32_t)0x8d3cf31d, value));
    }
    {
        TLConstructedValue value;
        value.type = TLConstructedValueTypeString;
        value.nativeObject = self.platform;
        values->insert(std::pair<int32_t, TLConstructedValue>((int32_t)0x2b6704be, value));
    }
    {
        TLConstructedValue value;
        value.type = TLConstructedValueTypePrimitiveInt32;
        value.primitive.int32Value = self.date_created;
        values->insert(std::pair<int32_t, TLConstructedValue>((int32_t)0x1fa8db99, value));
    }
    {
        TLConstructedValue value;
        value.type = TLConstructedValueTypePrimitiveInt32;
        value.primitive.int32Value = self.date_active;
        values->insert(std::pair<int32_t, TLConstructedValue>((int32_t)0xdf2c7255, value));
    }
    {
        TLConstructedValue value;
        value.type = TLConstructedValueTypeString;
        value.nativeObject = self.ip;
        values->insert(std::pair<int32_t, TLConstructedValue>((int32_t)0xe5956ecc, value));
    }
    {
        TLConstructedValue value;
        value.type = TLConstructedValueTypeString;
        value.nativeObject = self.region;
        values->insert(std::pair<int32_t, TLConstructedValue>((int32_t)0x6758e6e0, value));
    }
}


@end
