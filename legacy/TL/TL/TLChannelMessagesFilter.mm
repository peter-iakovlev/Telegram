#import "TLChannelMessagesFilter.h"

#import "../NSInputStream+TL.h"
#import "../NSOutputStream+TL.h"


@implementation TLChannelMessagesFilter


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

@implementation TLChannelMessagesFilter$channelMessagesFilterEmpty : TLChannelMessagesFilter


- (int32_t)TLconstructorSignature
{
    return (int32_t)0x94d42ee7;
}

- (int32_t)TLconstructorName
{
    return (int32_t)0x9f28b489;
}

- (id<TLObject>)TLbuildFromMetaObject:(std::shared_ptr<TLMetaObject>)__unused metaObject
{
    TLChannelMessagesFilter$channelMessagesFilterEmpty *object = [[TLChannelMessagesFilter$channelMessagesFilterEmpty alloc] init];
    return object;
}

- (void)TLfillFieldsWithValues:(std::map<int32_t, TLConstructedValue> *)__unused values
{
}


@end

@implementation TLChannelMessagesFilter$channelMessagesFilter : TLChannelMessagesFilter


- (int32_t)TLconstructorSignature
{
    return (int32_t)0xcd77d957;
}

- (int32_t)TLconstructorName
{
    return (int32_t)0x72760d0c;
}

- (id<TLObject>)TLbuildFromMetaObject:(std::shared_ptr<TLMetaObject>)metaObject
{
    TLChannelMessagesFilter$channelMessagesFilter *object = [[TLChannelMessagesFilter$channelMessagesFilter alloc] init];
    object.flags = metaObject->getInt32((int32_t)0x81915c23);
    object.ranges = metaObject->getArray((int32_t)0x70729714);
    return object;
}

- (void)TLfillFieldsWithValues:(std::map<int32_t, TLConstructedValue> *)values
{
    {
        TLConstructedValue value;
        value.type = TLConstructedValueTypePrimitiveInt32;
        value.primitive.int32Value = self.flags;
        values->insert(std::pair<int32_t, TLConstructedValue>((int32_t)0x81915c23, value));
    }
    {
        TLConstructedValue value;
        value.type = TLConstructedValueTypeVector;
        value.nativeObject = self.ranges;
        values->insert(std::pair<int32_t, TLConstructedValue>((int32_t)0x70729714, value));
    }
}


@end

@implementation TLChannelMessagesFilter$channelMessagesFilterCollapsed : TLChannelMessagesFilter


- (int32_t)TLconstructorSignature
{
    return (int32_t)0xfa01232e;
}

- (int32_t)TLconstructorName
{
    return (int32_t)0xc072b842;
}

- (id<TLObject>)TLbuildFromMetaObject:(std::shared_ptr<TLMetaObject>)__unused metaObject
{
    TLChannelMessagesFilter$channelMessagesFilterCollapsed *object = [[TLChannelMessagesFilter$channelMessagesFilterCollapsed alloc] init];
    return object;
}

- (void)TLfillFieldsWithValues:(std::map<int32_t, TLConstructedValue> *)__unused values
{
}


@end

