#import "TLmessages_FavedStickers.h"

#import "../NSInputStream+TL.h"
#import "../NSOutputStream+TL.h"


@implementation TLmessages_FavedStickers


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

@implementation TLmessages_FavedStickers$messages_favedStickersNotModified : TLmessages_FavedStickers


- (int32_t)TLconstructorSignature
{
    return (int32_t)0x9e8fa6d3;
}

- (int32_t)TLconstructorName
{
    return (int32_t)0x6073413d;
}

- (id<TLObject>)TLbuildFromMetaObject:(std::shared_ptr<TLMetaObject>)__unused metaObject
{
    TLmessages_FavedStickers$messages_favedStickersNotModified *object = [[TLmessages_FavedStickers$messages_favedStickersNotModified alloc] init];
    return object;
}

- (void)TLfillFieldsWithValues:(std::map<int32_t, TLConstructedValue> *)__unused values
{
}


@end

@implementation TLmessages_FavedStickers$messages_favedStickers : TLmessages_FavedStickers


- (int32_t)TLconstructorSignature
{
    return (int32_t)0xf37f2f16;
}

- (int32_t)TLconstructorName
{
    return (int32_t)0x12ed18de;
}

- (id<TLObject>)TLbuildFromMetaObject:(std::shared_ptr<TLMetaObject>)metaObject
{
    TLmessages_FavedStickers$messages_favedStickers *object = [[TLmessages_FavedStickers$messages_favedStickers alloc] init];
    object.n_hash = metaObject->getInt32((int32_t)0xc152e470);
    object.packs = metaObject->getArray((int32_t)0xfc361c6c);
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
        value.nativeObject = self.packs;
        values->insert(std::pair<int32_t, TLConstructedValue>((int32_t)0xfc361c6c, value));
    }
    {
        TLConstructedValue value;
        value.type = TLConstructedValueTypeVector;
        value.nativeObject = self.stickers;
        values->insert(std::pair<int32_t, TLConstructedValue>((int32_t)0x6863de1a, value));
    }
}


@end

