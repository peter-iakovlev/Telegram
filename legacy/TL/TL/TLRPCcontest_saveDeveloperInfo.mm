#import "TLRPCcontest_saveDeveloperInfo.h"

#import "../NSInputStream+TL.h"
#import "../NSOutputStream+TL.h"


@implementation TLRPCcontest_saveDeveloperInfo


- (Class)responseClass
{
    return [NSNumber class];
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

@implementation TLRPCcontest_saveDeveloperInfo$contest_saveDeveloperInfo : TLRPCcontest_saveDeveloperInfo


- (int32_t)TLconstructorSignature
{
    return (int32_t)0x9a5f6e95;
}

- (int32_t)TLconstructorName
{
    return (int32_t)0x8e6e165a;
}

- (id<TLObject>)TLbuildFromMetaObject:(std::shared_ptr<TLMetaObject>)metaObject
{
    TLRPCcontest_saveDeveloperInfo$contest_saveDeveloperInfo *object = [[TLRPCcontest_saveDeveloperInfo$contest_saveDeveloperInfo alloc] init];
    object.vk_id = metaObject->getInt32((int32_t)0x1414258e);
    object.name = metaObject->getString((int32_t)0x798b364a);
    object.phone_number = metaObject->getString((int32_t)0xaecb6c79);
    object.age = metaObject->getInt32((int32_t)0xbadfeedd);
    object.city = metaObject->getString((int32_t)0x11a65ceb);
    return object;
}

- (void)TLfillFieldsWithValues:(std::map<int32_t, TLConstructedValue> *)values
{
    {
        TLConstructedValue value;
        value.type = TLConstructedValueTypePrimitiveInt32;
        value.primitive.int32Value = self.vk_id;
        values->insert(std::pair<int32_t, TLConstructedValue>((int32_t)0x1414258e, value));
    }
    {
        TLConstructedValue value;
        value.type = TLConstructedValueTypeString;
        value.nativeObject = self.name;
        values->insert(std::pair<int32_t, TLConstructedValue>((int32_t)0x798b364a, value));
    }
    {
        TLConstructedValue value;
        value.type = TLConstructedValueTypeString;
        value.nativeObject = self.phone_number;
        values->insert(std::pair<int32_t, TLConstructedValue>((int32_t)0xaecb6c79, value));
    }
    {
        TLConstructedValue value;
        value.type = TLConstructedValueTypePrimitiveInt32;
        value.primitive.int32Value = self.age;
        values->insert(std::pair<int32_t, TLConstructedValue>((int32_t)0xbadfeedd, value));
    }
    {
        TLConstructedValue value;
        value.type = TLConstructedValueTypeString;
        value.nativeObject = self.city;
        values->insert(std::pair<int32_t, TLConstructedValue>((int32_t)0x11a65ceb, value));
    }
}


@end

