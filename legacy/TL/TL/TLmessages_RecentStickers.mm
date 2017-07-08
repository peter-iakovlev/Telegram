#import "TLmessages_RecentStickers.h"

#import "../NSInputStream+TL.h"
#import "../NSOutputStream+TL.h"


@implementation TLmessages_RecentStickers


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

@implementation TLmessages_RecentStickers$messages_recentStickersNotModified : TLmessages_RecentStickers


- (int32_t)TLconstructorSignature
{
    return (int32_t)0xb17f890;
}

- (int32_t)TLconstructorName
{
    return (int32_t)0x880f146d;
}

- (id<TLObject>)TLbuildFromMetaObject:(std::shared_ptr<TLMetaObject>)__unused metaObject
{
    TLmessages_RecentStickers$messages_recentStickersNotModified *object = [[TLmessages_RecentStickers$messages_recentStickersNotModified alloc] init];
    return object;
}

- (void)TLfillFieldsWithValues:(std::map<int32_t, TLConstructedValue> *)__unused values
{
}


@end

@implementation TLmessages_RecentStickers$messages_recentStickers : TLmessages_RecentStickers


- (int32_t)TLconstructorSignature
{
    return (int32_t)0x5ce20970;
}

- (int32_t)TLconstructorName
{
    return (int32_t)0xa7fdfb2f;
}

- (id<TLObject>)TLbuildFromMetaObject:(std::shared_ptr<TLMetaObject>)metaObject
{
    TLmessages_RecentStickers$messages_recentStickers *object = [[TLmessages_RecentStickers$messages_recentStickers alloc] init];
    object.n_hash = metaObject->getInt32((int32_t)0xc152e470);
    object.stickers = metaObject->getArray((int32_t)0x6863de1a);
    return object;
}

- (void)TLfillFieldsWithValues:(std::map<int32_t, TLConstructedValue> *)values
{
    {
        TLConstructedValue value;
        value.type = TLConstructedValueTypePrimitiveInt32;
        value.primitive.int32Value = self.n_hash;
        values->insert(std::pair<int32_t, TLConstructedValue>((int32_t)0xc152e470, value));
    }
    {
        TLConstructedValue value;
        value.type = TLConstructedValueTypeVector;
        value.nativeObject = self.stickers;
        values->insert(std::pair<int32_t, TLConstructedValue>((int32_t)0x6863de1a, value));
    }
}


@end

