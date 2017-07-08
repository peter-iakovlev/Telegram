#import "TLDocumentAttribute.h"

#import "../NSInputStream+TL.h"
#import "../NSOutputStream+TL.h"

#import "TLInputStickerSet.h"
#import "TLMaskCoords.h"

@implementation TLDocumentAttribute


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

@implementation TLDocumentAttribute$documentAttributeImageSize : TLDocumentAttribute


- (int32_t)TLconstructorSignature
{
    return (int32_t)0x6c37c15c;
}

- (int32_t)TLconstructorName
{
    return (int32_t)0x9b6d8cdd;
}

- (id<TLObject>)TLbuildFromMetaObject:(std::shared_ptr<TLMetaObject>)metaObject
{
    TLDocumentAttribute$documentAttributeImageSize *object = [[TLDocumentAttribute$documentAttributeImageSize alloc] init];
    object.w = metaObject->getInt32((int32_t)0x98407fc3);
    object.h = metaObject->getInt32((int32_t)0x27243f49);
    return object;
}

- (void)TLfillFieldsWithValues:(std::map<int32_t, TLConstructedValue> *)values
{
    {
        TLConstructedValue value;
        value.type = TLConstructedValueTypePrimitiveInt32;
        value.primitive.int32Value = self.w;
        values->insert(std::pair<int32_t, TLConstructedValue>((int32_t)0x98407fc3, value));
    }
    {
        TLConstructedValue value;
        value.type = TLConstructedValueTypePrimitiveInt32;
        value.primitive.int32Value = self.h;
        values->insert(std::pair<int32_t, TLConstructedValue>((int32_t)0x27243f49, value));
    }
}


@end

@implementation TLDocumentAttribute$documentAttributeAnimated : TLDocumentAttribute


- (int32_t)TLconstructorSignature
{
    return (int32_t)0x11b58939;
}

- (int32_t)TLconstructorName
{
    return (int32_t)0xb1b0af2c;
}

- (id<TLObject>)TLbuildFromMetaObject:(std::shared_ptr<TLMetaObject>)__unused metaObject
{
    TLDocumentAttribute$documentAttributeAnimated *object = [[TLDocumentAttribute$documentAttributeAnimated alloc] init];
    return object;
}

- (void)TLfillFieldsWithValues:(std::map<int32_t, TLConstructedValue> *)__unused values
{
}


@end

@implementation TLDocumentAttribute$documentAttributeFilename : TLDocumentAttribute


- (int32_t)TLconstructorSignature
{
    return (int32_t)0x15590068;
}

- (int32_t)TLconstructorName
{
    return (int32_t)0xcddece5f;
}

- (id<TLObject>)TLbuildFromMetaObject:(std::shared_ptr<TLMetaObject>)metaObject
{
    TLDocumentAttribute$documentAttributeFilename *object = [[TLDocumentAttribute$documentAttributeFilename alloc] init];
    object.file_name = metaObject->getString((int32_t)0x3fa248c4);
    return object;
}

- (void)TLfillFieldsWithValues:(std::map<int32_t, TLConstructedValue> *)values
{
    {
        TLConstructedValue value;
        value.type = TLConstructedValueTypeString;
        value.nativeObject = self.file_name;
        values->insert(std::pair<int32_t, TLConstructedValue>((int32_t)0x3fa248c4, value));
    }
}


@end

@implementation TLDocumentAttribute$documentAttributeStickerMeta : TLDocumentAttribute


- (int32_t)TLconstructorSignature
{
    return (int32_t)0x21122b4c;
}

- (int32_t)TLconstructorName
{
    return (int32_t)0x1cbf90c3;
}

- (id<TLObject>)TLbuildFromMetaObject:(std::shared_ptr<TLMetaObject>)metaObject
{
    TLDocumentAttribute$documentAttributeStickerMeta *object = [[TLDocumentAttribute$documentAttributeStickerMeta alloc] init];
    object.flags = metaObject->getInt32((int32_t)0x81915c23);
    object.alt = metaObject->getString((int32_t)0xe86810ff);
    object.stickerset = metaObject->getObject((int32_t)0xaac37694);
    object.mask_coords = metaObject->getObject((int32_t)0x84cb27ad);
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
        value.type = TLConstructedValueTypeString;
        value.nativeObject = self.alt;
        values->insert(std::pair<int32_t, TLConstructedValue>((int32_t)0xe86810ff, value));
    }
    {
        TLConstructedValue value;
        value.type = TLConstructedValueTypeObject;
        value.nativeObject = self.stickerset;
        values->insert(std::pair<int32_t, TLConstructedValue>((int32_t)0xaac37694, value));
    }
    {
        TLConstructedValue value;
        value.type = TLConstructedValueTypeObject;
        value.nativeObject = self.mask_coords;
        values->insert(std::pair<int32_t, TLConstructedValue>((int32_t)0x84cb27ad, value));
    }
}


@end

@implementation TLDocumentAttribute$documentAttributeHasStickers : TLDocumentAttribute


- (int32_t)TLconstructorSignature
{
    return (int32_t)0x9801d2f7;
}

- (int32_t)TLconstructorName
{
    return (int32_t)0x2865c028;
}

- (id<TLObject>)TLbuildFromMetaObject:(std::shared_ptr<TLMetaObject>)__unused metaObject
{
    TLDocumentAttribute$documentAttributeHasStickers *object = [[TLDocumentAttribute$documentAttributeHasStickers alloc] init];
    return object;
}

- (void)TLfillFieldsWithValues:(std::map<int32_t, TLConstructedValue> *)__unused values
{
}


@end

@implementation TLDocumentAttribute$documentAttributeVideo : TLDocumentAttribute


- (int32_t)TLconstructorSignature
{
    return (int32_t)0xef02ce6;
}

- (int32_t)TLconstructorName
{
    return (int32_t)0xbd5974ef;
}

- (id<TLObject>)TLbuildFromMetaObject:(std::shared_ptr<TLMetaObject>)metaObject
{
    TLDocumentAttribute$documentAttributeVideo *object = [[TLDocumentAttribute$documentAttributeVideo alloc] init];
    object.flags = metaObject->getInt32((int32_t)0x81915c23);
    object.duration = metaObject->getInt32((int32_t)0xac00f752);
    object.w = metaObject->getInt32((int32_t)0x98407fc3);
    object.h = metaObject->getInt32((int32_t)0x27243f49);
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
        value.primitive.int32Value = self.duration;
        values->insert(std::pair<int32_t, TLConstructedValue>((int32_t)0xac00f752, value));
    }
    {
        TLConstructedValue value;
        value.type = TLConstructedValueTypePrimitiveInt32;
        value.primitive.int32Value = self.w;
        values->insert(std::pair<int32_t, TLConstructedValue>((int32_t)0x98407fc3, value));
    }
    {
        TLConstructedValue value;
        value.type = TLConstructedValueTypePrimitiveInt32;
        value.primitive.int32Value = self.h;
        values->insert(std::pair<int32_t, TLConstructedValue>((int32_t)0x27243f49, value));
    }
}


@end

