#import "TLFeedBroadcasts.h"

#import "../NSInputStream+TL.h"
#import "../NSOutputStream+TL.h"

@implementation TLFeedBroadcasts


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

@implementation TLFeedBroadcasts$feedBroadcasts : TLFeedBroadcasts


- (int32_t)TLconstructorSignature
{
    return (int32_t)0x4f4feaf1;
}

- (int32_t)TLconstructorName
{
    return (int32_t)0x4450e4bf;
}

- (id<TLObject>)TLbuildFromMetaObject:(std::shared_ptr<TLMetaObject>)metaObject
{
    TLFeedBroadcasts$feedBroadcasts *object = [[TLFeedBroadcasts$feedBroadcasts alloc] init];
    object.feed_id = metaObject->getInt32((int32_t)0xf204bed5);
    object.channels = metaObject->getObject((int32_t)0x0ae18efd);
    return object;
}

- (void)TLfillFieldsWithValues:(std::map<int32_t, TLConstructedValue> *)values
{
    {
        TLConstructedValue value;
        value.type = TLConstructedValueTypePrimitiveInt32;
        value.primitive.int32Value = self.feed_id;
        values->insert(std::pair<int32_t, TLConstructedValue>((int32_t)0xf204bed5, value));
    }
    {
        TLConstructedValue value;
        value.type = TLConstructedValueTypeVector;
        value.nativeObject = self.channels;
        values->insert(std::pair<int32_t, TLConstructedValue>((int32_t)0x0ae18efd, value));
    }
}


@end

@implementation TLFeedBroadcasts$feedBroadcastsUngrouped : TLFeedBroadcasts


- (int32_t)TLconstructorSignature
{
    return (int32_t)0x9a687cba;
}

- (int32_t)TLconstructorName
{
    return (int32_t)0x40d855e4;
}

- (id<TLObject>)TLbuildFromMetaObject:(std::shared_ptr<TLMetaObject>)metaObject
{
    TLFeedBroadcasts$feedBroadcastsUngrouped *object = [[TLFeedBroadcasts$feedBroadcastsUngrouped alloc] init];
    object.channels = metaObject->getObject((int32_t)0x0ae18efd);
    return object;
}

- (void)TLfillFieldsWithValues:(std::map<int32_t, TLConstructedValue> *)values
{
    {
        TLConstructedValue value;
        value.type = TLConstructedValueTypeVector;
        value.nativeObject = self.channels;
        values->insert(std::pair<int32_t, TLConstructedValue>((int32_t)0x0ae18efd, value));
    }
}


@end
