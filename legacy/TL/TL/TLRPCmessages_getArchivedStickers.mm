#import "TLRPCmessages_getArchivedStickers.h"

#import "../NSInputStream+TL.h"
#import "../NSOutputStream+TL.h"

#import "TLmessages_ArchivedStickers.h"

@implementation TLRPCmessages_getArchivedStickers


- (Class)responseClass
{
    return [TLmessages_ArchivedStickers class];
}

- (int)impliedResponseSignature
{
    return (int)0x4fcba9c8;
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

@implementation TLRPCmessages_getArchivedStickers$messages_getArchivedStickers : TLRPCmessages_getArchivedStickers


- (int32_t)TLconstructorSignature
{
    return (int32_t)0x57f17692;
}

- (int32_t)TLconstructorName
{
    return (int32_t)0xbda87060;
}

- (id<TLObject>)TLbuildFromMetaObject:(std::shared_ptr<TLMetaObject>)metaObject
{
    TLRPCmessages_getArchivedStickers$messages_getArchivedStickers *object = [[TLRPCmessages_getArchivedStickers$messages_getArchivedStickers alloc] init];
    object.flags = metaObject->getInt32((int32_t)0x81915c23);
    object.offset_id = metaObject->getInt64((int32_t)0x1120a8cd);
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
        value.type = TLConstructedValueTypePrimitiveInt64;
        value.primitive.int64Value = self.offset_id;
        values->insert(std::pair<int32_t, TLConstructedValue>((int32_t)0x1120a8cd, value));
    }
    {
        TLConstructedValue value;
        value.type = TLConstructedValueTypePrimitiveInt32;
        value.primitive.int32Value = self.limit;
        values->insert(std::pair<int32_t, TLConstructedValue>((int32_t)0xb8433fca, value));
    }
}


@end

