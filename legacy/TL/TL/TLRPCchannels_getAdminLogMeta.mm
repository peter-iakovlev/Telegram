#import "TLRPCchannels_getAdminLogMeta.h"

#import "../NSInputStream+TL.h"
#import "../NSOutputStream+TL.h"

#import "TLInputChannel.h"
#import "TLChannelAdminLogEventsFilter.h"
#import "TLchannels_AdminLogResults.h"

@implementation TLRPCchannels_getAdminLogMeta


- (Class)responseClass
{
    return [TLchannels_AdminLogResults class];
}

- (int)impliedResponseSignature
{
    return (int)0xed8af74d;
}

- (int)layerVersion
{
    return 68;
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

@implementation TLRPCchannels_getAdminLogMeta$channels_getAdminLogMeta : TLRPCchannels_getAdminLogMeta


- (int32_t)TLconstructorSignature
{
    return (int32_t)0x3e9a6fbd;
}

- (int32_t)TLconstructorName
{
    return (int32_t)0x82866ecb;
}

- (id<TLObject>)TLbuildFromMetaObject:(std::shared_ptr<TLMetaObject>)metaObject
{
    TLRPCchannels_getAdminLogMeta$channels_getAdminLogMeta *object = [[TLRPCchannels_getAdminLogMeta$channels_getAdminLogMeta alloc] init];
    object.flags = metaObject->getInt32((int32_t)0x81915c23);
    object.channel = metaObject->getObject((int32_t)0xe11f3d41);
    object.q = metaObject->getString((int32_t)0xcd45cb1c);
    object.events_filter = metaObject->getObject((int32_t)0x37f51f6a);
    object.admins = metaObject->getArray((int32_t)0x32ffdf76);
    object.max_id = metaObject->getInt64((int32_t)0xe2c00ace);
    object.min_id = metaObject->getInt64((int32_t)0x52b518c0);
    object.limit = metaObject->getInt32((int32_t)0xb8433fca);
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
        value.type = TLConstructedValueTypeObject;
        value.nativeObject = self.channel;
        values->insert(std::pair<int32_t, TLConstructedValue>((int32_t)0xe11f3d41, value));
    }
    {
        TLConstructedValue value;
        value.type = TLConstructedValueTypeString;
        value.nativeObject = self.q;
        values->insert(std::pair<int32_t, TLConstructedValue>((int32_t)0xcd45cb1c, value));
    }
    {
        TLConstructedValue value;
        value.type = TLConstructedValueTypeObject;
        value.nativeObject = self.events_filter;
        values->insert(std::pair<int32_t, TLConstructedValue>((int32_t)0x37f51f6a, value));
    }
    {
        TLConstructedValue value;
        value.type = TLConstructedValueTypeVector;
        value.nativeObject = self.admins;
        values->insert(std::pair<int32_t, TLConstructedValue>((int32_t)0x32ffdf76, value));
    }
    {
        TLConstructedValue value;
        value.type = TLConstructedValueTypePrimitiveInt64;
        value.primitive.int64Value = self.max_id;
        values->insert(std::pair<int32_t, TLConstructedValue>((int32_t)0xe2c00ace, value));
    }
    {
        TLConstructedValue value;
        value.type = TLConstructedValueTypePrimitiveInt64;
        value.primitive.int64Value = self.min_id;
        values->insert(std::pair<int32_t, TLConstructedValue>((int32_t)0x52b518c0, value));
    }
    {
        TLConstructedValue value;
        value.type = TLConstructedValueTypePrimitiveInt32;
        value.primitive.int32Value = self.limit;
        values->insert(std::pair<int32_t, TLConstructedValue>((int32_t)0xb8433fca, value));
    }
}


@end

