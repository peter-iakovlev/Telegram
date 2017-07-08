#import "TLmessages_DhConfig.h"

#import "../NSInputStream+TL.h"
#import "../NSOutputStream+TL.h"


@implementation TLmessages_DhConfig


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

@implementation TLmessages_DhConfig$messages_dhConfigNotModified : TLmessages_DhConfig


- (int32_t)TLconstructorSignature
{
    return (int32_t)0xc0e24635;
}

- (int32_t)TLconstructorName
{
    return (int32_t)0x4271272b;
}

- (id<TLObject>)TLbuildFromMetaObject:(std::shared_ptr<TLMetaObject>)metaObject
{
    TLmessages_DhConfig$messages_dhConfigNotModified *object = [[TLmessages_DhConfig$messages_dhConfigNotModified alloc] init];
    object.random = metaObject->getBytes((int32_t)0x5e7f46f5);
    return object;
}

- (void)TLfillFieldsWithValues:(std::map<int32_t, TLConstructedValue> *)values
{
    {
        TLConstructedValue value;
        value.type = TLConstructedValueTypeBytes;
        value.nativeObject = self.random;
        values->insert(std::pair<int32_t, TLConstructedValue>((int32_t)0x5e7f46f5, value));
    }
}


@end

@implementation TLmessages_DhConfig$messages_dhConfig : TLmessages_DhConfig


- (int32_t)TLconstructorSignature
{
    return (int32_t)0x2c221edd;
}

- (int32_t)TLconstructorName
{
    return (int32_t)0x911db814;
}

- (id<TLObject>)TLbuildFromMetaObject:(std::shared_ptr<TLMetaObject>)metaObject
{
    TLmessages_DhConfig$messages_dhConfig *object = [[TLmessages_DhConfig$messages_dhConfig alloc] init];
    object.g = metaObject->getInt32((int32_t)0x75e1067a);
    object.p = metaObject->getBytes((int32_t)0xb91d8925);
    object.version = metaObject->getInt32((int32_t)0x4ea810e9);
    object.random = metaObject->getBytes((int32_t)0x5e7f46f5);
    return object;
}

- (void)TLfillFieldsWithValues:(std::map<int32_t, TLConstructedValue> *)values
{
    {
        TLConstructedValue value;
        value.type = TLConstructedValueTypePrimitiveInt32;
        value.primitive.int32Value = self.g;
        values->insert(std::pair<int32_t, TLConstructedValue>((int32_t)0x75e1067a, value));
    }
    {
        TLConstructedValue value;
        value.type = TLConstructedValueTypeBytes;
        value.nativeObject = self.p;
        values->insert(std::pair<int32_t, TLConstructedValue>((int32_t)0xb91d8925, value));
    }
    {
        TLConstructedValue value;
        value.type = TLConstructedValueTypePrimitiveInt32;
        value.primitive.int32Value = self.version;
        values->insert(std::pair<int32_t, TLConstructedValue>((int32_t)0x4ea810e9, value));
    }
    {
        TLConstructedValue value;
        value.type = TLConstructedValueTypeBytes;
        value.nativeObject = self.random;
        values->insert(std::pair<int32_t, TLConstructedValue>((int32_t)0x5e7f46f5, value));
    }
}


@end

