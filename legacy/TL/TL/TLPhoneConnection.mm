#import "TLPhoneConnection.h"

#import "../NSInputStream+TL.h"
#import "../NSOutputStream+TL.h"


@implementation TLPhoneConnection


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

@implementation TLPhoneConnection$phoneConnectionNotReady : TLPhoneConnection


- (int32_t)TLconstructorSignature
{
    return (int32_t)0x26bc3c3;
}

- (int32_t)TLconstructorName
{
    return (int32_t)0x5123f80c;
}

- (id<TLObject>)TLbuildFromMetaObject:(std::shared_ptr<TLMetaObject>)__unused metaObject
{
    TLPhoneConnection$phoneConnectionNotReady *object = [[TLPhoneConnection$phoneConnectionNotReady alloc] init];
    return object;
}

- (void)TLfillFieldsWithValues:(std::map<int32_t, TLConstructedValue> *)__unused values
{
}


@end

@implementation TLPhoneConnection$phoneConnection : TLPhoneConnection


- (int32_t)TLconstructorSignature
{
    return (int32_t)0x9d4c17c0;
}

- (int32_t)TLconstructorName
{
    return (int32_t)0x957070a3;
}

- (id<TLObject>)TLbuildFromMetaObject:(std::shared_ptr<TLMetaObject>)metaObject
{
    TLPhoneConnection$phoneConnection *object = [[TLPhoneConnection$phoneConnection alloc] init];
    object.n_id = metaObject->getInt64((int32_t)0x7a5601fb);
    object.ip = metaObject->getString((int32_t)0xe5956ecc);
    object.ipv6 = metaObject->getString((int32_t)0x555f25db);
    object.port = metaObject->getInt32((int32_t)0x81ce65c9);
    object.peer_tag = metaObject->getBytes((int32_t)0x49f791e4);
    return object;
}

- (void)TLfillFieldsWithValues:(std::map<int32_t, TLConstructedValue> *)values
{
    {
        TLConstructedValue value;
        value.type = TLConstructedValueTypePrimitiveInt64;
        value.primitive.int64Value = self.n_id;
        values->insert(std::pair<int32_t, TLConstructedValue>((int32_t)0x7a5601fb, value));
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
        value.nativeObject = self.ipv6;
        values->insert(std::pair<int32_t, TLConstructedValue>((int32_t)0x555f25db, value));
    }
    {
        TLConstructedValue value;
        value.type = TLConstructedValueTypePrimitiveInt32;
        value.primitive.int32Value = self.port;
        values->insert(std::pair<int32_t, TLConstructedValue>((int32_t)0x81ce65c9, value));
    }
    {
        TLConstructedValue value;
        value.type = TLConstructedValueTypeBytes;
        value.nativeObject = self.peer_tag;
        values->insert(std::pair<int32_t, TLConstructedValue>((int32_t)0x49f791e4, value));
    }
}


@end

