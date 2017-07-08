#import "TLRPCmessages_getRecentStickers.h"

#import "../NSInputStream+TL.h"
#import "../NSOutputStream+TL.h"

#import "TLmessages_RecentStickers.h"

@implementation TLRPCmessages_getRecentStickers


- (Class)responseClass
{
    return [TLmessages_RecentStickers class];
}

- (int)impliedResponseSignature
{
    return 0;
}

- (int)layerVersion
{
    return 56;
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

@implementation TLRPCmessages_getRecentStickers$messages_getRecentStickers : TLRPCmessages_getRecentStickers


- (int32_t)TLconstructorSignature
{
    return (int32_t)0x5ea192c9;
}

- (int32_t)TLconstructorName
{
    return (int32_t)0x752f4484;
}

- (id<TLObject>)TLbuildFromMetaObject:(std::shared_ptr<TLMetaObject>)metaObject
{
    TLRPCmessages_getRecentStickers$messages_getRecentStickers *object = [[TLRPCmessages_getRecentStickers$messages_getRecentStickers alloc] init];
    object.flags = metaObject->getInt32((int32_t)0x81915c23);
    object.n_hash = metaObject->getInt32((int32_t)0xc152e470);
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
        value.primitive.int32Value = self.n_hash;
        values->insert(std::pair<int32_t, TLConstructedValue>((int32_t)0xc152e470, value));
    }
}


@end

