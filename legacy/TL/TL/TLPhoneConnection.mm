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

@implementation TLPhoneConnection$phoneConnectionNotReady : TLPhoneConnection


- (int32_t)TLconstructorSignature
{
    return (int32_t)0x26bc3c3;
}

- (int32_t)TLconstructorName
{
    return (int32_t)0x5123f80c;
}

- (id<TLObject>)TLbuildFromMetaObject:(std::tr1::shared_ptr<TLMetaObject>)__unused metaObject
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
    return (int32_t)0x3a84026a;
}

- (int32_t)TLconstructorName
{
    return (int32_t)0x957070a3;
}

- (id<TLObject>)TLbuildFromMetaObject:(std::tr1::shared_ptr<TLMetaObject>)metaObject
{
    TLPhoneConnection$phoneConnection *object = [[TLPhoneConnection$phoneConnection alloc] init];
    object.server = metaObject->getString((int32_t)0x3bc2f529);
    object.port = metaObject->getInt32((int32_t)0x81ce65c9);
    object.stream_id = metaObject->getInt64((int32_t)0x736c1b31);
    return object;
}

- (void)TLfillFieldsWithValues:(std::map<int32_t, TLConstructedValue> *)values
{
    {
        TLConstructedValue value;
        value.type = TLConstructedValueTypeString;
        value.nativeObject = self.server;
        values->insert(std::pair<int32_t, TLConstructedValue>((int32_t)0x3bc2f529, value));
    }
    {
        TLConstructedValue value;
        value.type = TLConstructedValueTypePrimitiveInt32;
        value.primitive.int32Value = self.port;
        values->insert(std::pair<int32_t, TLConstructedValue>((int32_t)0x81ce65c9, value));
    }
    {
        TLConstructedValue value;
        value.type = TLConstructedValueTypePrimitiveInt64;
        value.primitive.int64Value = self.stream_id;
        values->insert(std::pair<int32_t, TLConstructedValue>((int32_t)0x736c1b31, value));
    }
}


@end

