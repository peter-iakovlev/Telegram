#import "TLInputStickerSet.h"

#import "../NSInputStream+TL.h"
#import "../NSOutputStream+TL.h"


@implementation TLInputStickerSet


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

@implementation TLInputStickerSet$inputStickerSetEmpty : TLInputStickerSet


- (int32_t)TLconstructorSignature
{
    return (int32_t)0xffb62b95;
}

- (int32_t)TLconstructorName
{
    return (int32_t)0x89555221;
}

- (id<TLObject>)TLbuildFromMetaObject:(std::shared_ptr<TLMetaObject>)__unused metaObject
{
    TLInputStickerSet$inputStickerSetEmpty *object = [[TLInputStickerSet$inputStickerSetEmpty alloc] init];
    return object;
}

- (void)TLfillFieldsWithValues:(std::map<int32_t, TLConstructedValue> *)__unused values
{
}


@end

@implementation TLInputStickerSet$inputStickerSetID : TLInputStickerSet


- (int32_t)TLconstructorSignature
{
    return (int32_t)0x9de7a269;
}

- (int32_t)TLconstructorName
{
    return (int32_t)0x51e3c528;
}

- (id<TLObject>)TLbuildFromMetaObject:(std::shared_ptr<TLMetaObject>)metaObject
{
    TLInputStickerSet$inputStickerSetID *object = [[TLInputStickerSet$inputStickerSetID alloc] init];
    object.n_id = metaObject->getInt64((int32_t)0x7a5601fb);
    object.access_hash = metaObject->getInt64((int32_t)0x8f305224);
    return object;
}

- (void)TLfillFieldsWithValues:(std::map<int32_t, TLConstructedValue> *)values
{
    {
        TLConstructedValue value;
        value.type = TLConstructedValueTypePrimitiveInt64;
        value.primitive.int64Value = self.n_id;
        values->insert(std::pair<int32_t, TLConstructedValue>((int32_t)0x7a5601fb, value));
    }
    {
        TLConstructedValue value;
        value.type = TLConstructedValueTypePrimitiveInt64;
        value.primitive.int64Value = self.access_hash;
        values->insert(std::pair<int32_t, TLConstructedValue>((int32_t)0x8f305224, value));
    }
}


@end

@implementation TLInputStickerSet$inputStickerSetShortName : TLInputStickerSet


- (int32_t)TLconstructorSignature
{
    return (int32_t)0x861cc8a0;
}

- (int32_t)TLconstructorName
{
    return (int32_t)0x555e5c99;
}

- (id<TLObject>)TLbuildFromMetaObject:(std::shared_ptr<TLMetaObject>)metaObject
{
    TLInputStickerSet$inputStickerSetShortName *object = [[TLInputStickerSet$inputStickerSetShortName alloc] init];
    object.short_name = metaObject->getString((int32_t)0xfccec594);
    return object;
}

- (void)TLfillFieldsWithValues:(std::map<int32_t, TLConstructedValue> *)values
{
    {
        TLConstructedValue value;
        value.type = TLConstructedValueTypeString;
        value.nativeObject = self.short_name;
        values->insert(std::pair<int32_t, TLConstructedValue>((int32_t)0xfccec594, value));
    }
}


@end

