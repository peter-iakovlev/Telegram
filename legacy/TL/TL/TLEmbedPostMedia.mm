#import "TLEmbedPostMedia.h"

#import "../NSInputStream+TL.h"
#import "../NSOutputStream+TL.h"


@implementation TLEmbedPostMedia


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

@implementation TLEmbedPostMedia$embedPostPhoto : TLEmbedPostMedia


- (int32_t)TLconstructorSignature
{
    return (int32_t)0xe31ee77;
}

- (int32_t)TLconstructorName
{
    return (int32_t)0x2a94ab03;
}

- (id<TLObject>)TLbuildFromMetaObject:(std::shared_ptr<TLMetaObject>)metaObject
{
    TLEmbedPostMedia$embedPostPhoto *object = [[TLEmbedPostMedia$embedPostPhoto alloc] init];
    object.photo_id = metaObject->getInt64((int32_t)0xa4b26129);
    return object;
}

- (void)TLfillFieldsWithValues:(std::map<int32_t, TLConstructedValue> *)values
{
    {
        TLConstructedValue value;
        value.type = TLConstructedValueTypePrimitiveInt64;
        value.primitive.int64Value = self.photo_id;
        values->insert(std::pair<int32_t, TLConstructedValue>((int32_t)0xa4b26129, value));
    }
}


@end

@implementation TLEmbedPostMedia$embedPostVideo : TLEmbedPostMedia


- (int32_t)TLconstructorSignature
{
    return (int32_t)0xa07f2d66;
}

- (int32_t)TLconstructorName
{
    return (int32_t)0x4b4ff7f9;
}

- (id<TLObject>)TLbuildFromMetaObject:(std::shared_ptr<TLMetaObject>)metaObject
{
    TLEmbedPostMedia$embedPostVideo *object = [[TLEmbedPostMedia$embedPostVideo alloc] init];
    object.video_id = metaObject->getInt64((int32_t)0xa09c03ef);
    return object;
}

- (void)TLfillFieldsWithValues:(std::map<int32_t, TLConstructedValue> *)values
{
    {
        TLConstructedValue value;
        value.type = TLConstructedValueTypePrimitiveInt64;
        value.primitive.int64Value = self.video_id;
        values->insert(std::pair<int32_t, TLConstructedValue>((int32_t)0xa09c03ef, value));
    }
}


@end

