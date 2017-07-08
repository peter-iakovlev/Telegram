#import "TLmessages_StickerSet.h"

#import "../NSInputStream+TL.h"
#import "../NSOutputStream+TL.h"

#import "TLStickerSet.h"

@implementation TLmessages_StickerSet


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

@implementation TLmessages_StickerSet$messages_stickerSet : TLmessages_StickerSet


- (int32_t)TLconstructorSignature
{
    return (int32_t)0xb60a24a6;
}

- (int32_t)TLconstructorName
{
    return (int32_t)0x3af4e357;
}

- (id<TLObject>)TLbuildFromMetaObject:(std::shared_ptr<TLMetaObject>)metaObject
{
    TLmessages_StickerSet$messages_stickerSet *object = [[TLmessages_StickerSet$messages_stickerSet alloc] init];
    object.set = metaObject->getObject((int32_t)0xb2c820f9);
    object.packs = metaObject->getArray((int32_t)0xfc361c6c);
    object.documents = metaObject->getArray((int32_t)0xbf7d927d);
    return object;
}

- (void)TLfillFieldsWithValues:(std::map<int32_t, TLConstructedValue> *)values
{
    {
        TLConstructedValue value;
        value.type = TLConstructedValueTypeObject;
        value.nativeObject = self.set;
        values->insert(std::pair<int32_t, TLConstructedValue>((int32_t)0xb2c820f9, value));
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
        value.nativeObject = self.documents;
        values->insert(std::pair<int32_t, TLConstructedValue>((int32_t)0xbf7d927d, value));
    }
}


@end

