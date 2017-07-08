#import "TLFoundGif.h"

#import "../NSInputStream+TL.h"
#import "../NSOutputStream+TL.h"

#import "TLPhoto.h"
#import "TLDocument.h"

@implementation TLFoundGif


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

@implementation TLFoundGif$foundGif : TLFoundGif


- (int32_t)TLconstructorSignature
{
    return (int32_t)0x162ecc1f;
}

- (int32_t)TLconstructorName
{
    return (int32_t)0xed32366;
}

- (id<TLObject>)TLbuildFromMetaObject:(std::shared_ptr<TLMetaObject>)metaObject
{
    TLFoundGif$foundGif *object = [[TLFoundGif$foundGif alloc] init];
    object.url = metaObject->getString((int32_t)0xeaf7861e);
    object.thumb_url = metaObject->getString((int32_t)0xd914f967);
    object.content_url = metaObject->getString((int32_t)0xfe0f4de6);
    object.content_type = metaObject->getString((int32_t)0xbe4160a9);
    object.w = metaObject->getInt32((int32_t)0x98407fc3);
    object.h = metaObject->getInt32((int32_t)0x27243f49);
    return object;
}

- (void)TLfillFieldsWithValues:(std::map<int32_t, TLConstructedValue> *)values
{
    {
        TLConstructedValue value;
        value.type = TLConstructedValueTypeString;
        value.nativeObject = self.url;
        values->insert(std::pair<int32_t, TLConstructedValue>((int32_t)0xeaf7861e, value));
    }
    {
        TLConstructedValue value;
        value.type = TLConstructedValueTypeString;
        value.nativeObject = self.thumb_url;
        values->insert(std::pair<int32_t, TLConstructedValue>((int32_t)0xd914f967, value));
    }
    {
        TLConstructedValue value;
        value.type = TLConstructedValueTypeString;
        value.nativeObject = self.content_url;
        values->insert(std::pair<int32_t, TLConstructedValue>((int32_t)0xfe0f4de6, value));
    }
    {
        TLConstructedValue value;
        value.type = TLConstructedValueTypeString;
        value.nativeObject = self.content_type;
        values->insert(std::pair<int32_t, TLConstructedValue>((int32_t)0xbe4160a9, value));
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

@implementation TLFoundGif$foundGifCached : TLFoundGif


- (int32_t)TLconstructorSignature
{
    return (int32_t)0x9c750409;
}

- (int32_t)TLconstructorName
{
    return (int32_t)0xa33e4eb3;
}

- (id<TLObject>)TLbuildFromMetaObject:(std::shared_ptr<TLMetaObject>)metaObject
{
    TLFoundGif$foundGifCached *object = [[TLFoundGif$foundGifCached alloc] init];
    object.url = metaObject->getString((int32_t)0xeaf7861e);
    object.photo = metaObject->getObject((int32_t)0xe6c52372);
    object.document = metaObject->getObject((int32_t)0xf1465b5f);
    return object;
}

- (void)TLfillFieldsWithValues:(std::map<int32_t, TLConstructedValue> *)values
{
    {
        TLConstructedValue value;
        value.type = TLConstructedValueTypeString;
        value.nativeObject = self.url;
        values->insert(std::pair<int32_t, TLConstructedValue>((int32_t)0xeaf7861e, value));
    }
    {
        TLConstructedValue value;
        value.type = TLConstructedValueTypeObject;
        value.nativeObject = self.photo;
        values->insert(std::pair<int32_t, TLConstructedValue>((int32_t)0xe6c52372, value));
    }
    {
        TLConstructedValue value;
        value.type = TLConstructedValueTypeObject;
        value.nativeObject = self.document;
        values->insert(std::pair<int32_t, TLConstructedValue>((int32_t)0xf1465b5f, value));
    }
}


@end

