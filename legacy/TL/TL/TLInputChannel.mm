#import "TLInputChannel.h"

#import "../NSInputStream+TL.h"
#import "../NSOutputStream+TL.h"


@implementation TLInputChannel


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

@implementation TLInputChannel$inputChannelEmpty : TLInputChannel


- (int32_t)TLconstructorSignature
{
    return (int32_t)0xee8c1e86;
}

- (int32_t)TLconstructorName
{
    return (int32_t)0xe8e89274;
}

- (id<TLObject>)TLbuildFromMetaObject:(std::shared_ptr<TLMetaObject>)__unused metaObject
{
    TLInputChannel$inputChannelEmpty *object = [[TLInputChannel$inputChannelEmpty alloc] init];
    return object;
}

- (void)TLfillFieldsWithValues:(std::map<int32_t, TLConstructedValue> *)__unused values
{
}


@end

@implementation TLInputChannel$inputChannel : TLInputChannel


- (int32_t)TLconstructorSignature
{
    return (int32_t)0xafeb712e;
}

- (int32_t)TLconstructorName
{
    return (int32_t)0x59bec2a2;
}

- (id<TLObject>)TLbuildFromMetaObject:(std::shared_ptr<TLMetaObject>)metaObject
{
    TLInputChannel$inputChannel *object = [[TLInputChannel$inputChannel alloc] init];
    object.channel_id = metaObject->getInt32((int32_t)0x1cfcdb86);
    object.access_hash = metaObject->getInt64((int32_t)0x8f305224);
    return object;
}

- (void)TLfillFieldsWithValues:(std::map<int32_t, TLConstructedValue> *)values
{
    {
        TLConstructedValue value;
        value.type = TLConstructedValueTypePrimitiveInt32;
        value.primitive.int32Value = self.channel_id;
        values->insert(std::pair<int32_t, TLConstructedValue>((int32_t)0x1cfcdb86, value));
    }
    {
        TLConstructedValue value;
        value.type = TLConstructedValueTypePrimitiveInt64;
        value.primitive.int64Value = self.access_hash;
        values->insert(std::pair<int32_t, TLConstructedValue>((int32_t)0x8f305224, value));
    }
}


@end

