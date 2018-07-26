#import "TLchannels_FeedSources.h"

@implementation TLchannels_FeedSources


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

@implementation TLchannels_FeedSources$channels_feedSourcesNotModified : TLchannels_FeedSources


- (int32_t)TLconstructorSignature
{
    return (int32_t)0x88b12a17;
}

- (int32_t)TLconstructorName
{
    return (int32_t)0xafbf13d1;
}

- (id<TLObject>)TLbuildFromMetaObject:(std::shared_ptr<TLMetaObject>)__unused metaObject
{
    TLchannels_FeedSources$channels_feedSourcesNotModified *object = [[TLchannels_FeedSources$channels_feedSourcesNotModified alloc] init];
    return object;
}

- (void)TLfillFieldsWithValues:(std::map<int32_t, TLConstructedValue> *)__unused values
{
}


@end

@implementation TLchannels_FeedSources$channels_feedSourcesMeta : TLchannels_FeedSources


- (int32_t)TLconstructorSignature
{
    return (int32_t)0x8e8bca3d;
}

- (int32_t)TLconstructorName
{
    return (int32_t)0x8fe494af;
}

- (id<TLObject>)TLbuildFromMetaObject:(std::shared_ptr<TLMetaObject>)metaObject
{
    TLchannels_FeedSources$channels_feedSourcesMeta *object = [[TLchannels_FeedSources$channels_feedSourcesMeta alloc] init];
    object.flags = metaObject->getInt32((int32_t)0x81915c23);
    object.newly_joined_feed = metaObject->getInt32((int32_t)0x920a354d);
    object.feeds = metaObject->getObject((int32_t)0x22aed25e);
    object.chats = metaObject->getArray((int32_t)0x4240ad02);
    object.users = metaObject->getArray((int32_t)0x933e5ff3);
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
        value.type = TLConstructedValueTypePrimitiveInt32;
        value.primitive.int32Value = self.newly_joined_feed;
        values->insert(std::pair<int32_t, TLConstructedValue>((int32_t)0x920a354d, value));
    }
    {
        TLConstructedValue value;
        value.type = TLConstructedValueTypeVector;
        value.nativeObject = self.feeds;
        values->insert(std::pair<int32_t, TLConstructedValue>((int32_t)0x22aed25e, value));
    }
    {
        TLConstructedValue value;
        value.type = TLConstructedValueTypeVector;
        value.nativeObject = self.chats;
        values->insert(std::pair<int32_t, TLConstructedValue>((int32_t)0x4240ad02, value));
    }
    {
        TLConstructedValue value;
        value.type = TLConstructedValueTypeVector;
        value.nativeObject = self.users;
        values->insert(std::pair<int32_t, TLConstructedValue>((int32_t)0x933e5ff3, value));
    }
}


@end

