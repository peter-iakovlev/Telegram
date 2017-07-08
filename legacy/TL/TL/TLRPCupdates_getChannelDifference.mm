#import "TLRPCupdates_getChannelDifference.h"

#import "../NSInputStream+TL.h"
#import "../NSOutputStream+TL.h"

#import "TLInputChannel.h"
#import "TLChannelMessagesFilter.h"
#import "TLupdates_ChannelDifference.h"

@implementation TLRPCupdates_getChannelDifference


- (Class)responseClass
{
    return [TLupdates_ChannelDifference class];
}

- (int)impliedResponseSignature
{
    return (int)0x47ddefe6;
}

- (int)layerVersion
{
    return 38;
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

@implementation TLRPCupdates_getChannelDifference$updates_getChannelDifference : TLRPCupdates_getChannelDifference


- (int32_t)TLconstructorSignature
{
    return (int32_t)0xbb32d7c0;
}

- (int32_t)TLconstructorName
{
    return (int32_t)0x607c8b7a;
}

- (id<TLObject>)TLbuildFromMetaObject:(std::shared_ptr<TLMetaObject>)metaObject
{
    TLRPCupdates_getChannelDifference$updates_getChannelDifference *object = [[TLRPCupdates_getChannelDifference$updates_getChannelDifference alloc] init];
    object.channel = metaObject->getObject((int32_t)0xe11f3d41);
    object.filter = metaObject->getObject((int32_t)0x834de586);
    object.pts = metaObject->getInt32((int32_t)0x4fc5f572);
    object.limit = metaObject->getInt32((int32_t)0xb8433fca);
    return object;
}

- (void)TLfillFieldsWithValues:(std::map<int32_t, TLConstructedValue> *)values
{
    {
        TLConstructedValue value;
        value.type = TLConstructedValueTypeObject;
        value.nativeObject = self.channel;
        values->insert(std::pair<int32_t, TLConstructedValue>((int32_t)0xe11f3d41, value));
    }
    {
        TLConstructedValue value;
        value.type = TLConstructedValueTypeObject;
        value.nativeObject = self.filter;
        values->insert(std::pair<int32_t, TLConstructedValue>((int32_t)0x834de586, value));
    }
    {
        TLConstructedValue value;
        value.type = TLConstructedValueTypePrimitiveInt32;
        value.primitive.int32Value = self.pts;
        values->insert(std::pair<int32_t, TLConstructedValue>((int32_t)0x4fc5f572, value));
    }
    {
        TLConstructedValue value;
        value.type = TLConstructedValueTypePrimitiveInt32;
        value.primitive.int32Value = self.limit;
        values->insert(std::pair<int32_t, TLConstructedValue>((int32_t)0xb8433fca, value));
    }
}


@end

