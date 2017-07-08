#import "TLmessages_FeaturedStickers.h"

#import "../NSInputStream+TL.h"
#import "../NSOutputStream+TL.h"


@implementation TLmessages_FeaturedStickers


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

@implementation TLmessages_FeaturedStickers$messages_featuredStickersNotModified : TLmessages_FeaturedStickers


- (int32_t)TLconstructorSignature
{
    return (int32_t)0x4ede3cf;
}

- (int32_t)TLconstructorName
{
    return (int32_t)0x176b8be2;
}

- (id<TLObject>)TLbuildFromMetaObject:(std::shared_ptr<TLMetaObject>)__unused metaObject
{
    TLmessages_FeaturedStickers$messages_featuredStickersNotModified *object = [[TLmessages_FeaturedStickers$messages_featuredStickersNotModified alloc] init];
    return object;
}

- (void)TLfillFieldsWithValues:(std::map<int32_t, TLConstructedValue> *)__unused values
{
}


@end

@implementation TLmessages_FeaturedStickers$messages_featuredStickers : TLmessages_FeaturedStickers


- (int32_t)TLconstructorSignature
{
    return (int32_t)0xf89d88e5;
}

- (int32_t)TLconstructorName
{
    return (int32_t)0xfb99259c;
}

- (id<TLObject>)TLbuildFromMetaObject:(std::shared_ptr<TLMetaObject>)metaObject
{
    TLmessages_FeaturedStickers$messages_featuredStickers *object = [[TLmessages_FeaturedStickers$messages_featuredStickers alloc] init];
    object.n_hash = metaObject->getInt32((int32_t)0xc152e470);
    object.sets = metaObject->getArray((int32_t)0xc535ffc6);
    object.unread = metaObject->getArray((int32_t)0x5027354e);
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
        value.nativeObject = self.sets;
        values->insert(std::pair<int32_t, TLConstructedValue>((int32_t)0xc535ffc6, value));
    }
    {
        TLConstructedValue value;
        value.type = TLConstructedValueTypeVector;
        value.nativeObject = self.unread;
        values->insert(std::pair<int32_t, TLConstructedValue>((int32_t)0x5027354e, value));
    }
}


@end

