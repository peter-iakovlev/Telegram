#import "TLDecryptedMessageMedia.h"

#import "../NSInputStream+TL.h"
#import "../NSOutputStream+TL.h"


@implementation TLDecryptedMessageMedia


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

- (id<TLObject>)TLbuildFromMetaObject:(std::tr1::shared_ptr<TLMetaObject>)__unused metaObject
{
    TGLog(@"TLbuildFromMetaObject is not implemented for base type");
    return nil;
}

- (void)TLfillFieldsWithValues:(std::map<int32_t, TLConstructedValue> *)__unused values
{
    TGLog(@"TLfillFieldsWithValues is not implemented for base type");
}


@end

@implementation TLDecryptedMessageMedia$decryptedMessageMediaEmpty : TLDecryptedMessageMedia


- (int32_t)TLconstructorSignature
{
    return (int32_t)0x89f5c4a;
}

- (int32_t)TLconstructorName
{
    return (int32_t)0xcea058f6;
}

- (id<TLObject>)TLbuildFromMetaObject:(std::tr1::shared_ptr<TLMetaObject>)__unused metaObject
{
    TLDecryptedMessageMedia$decryptedMessageMediaEmpty *object = [[TLDecryptedMessageMedia$decryptedMessageMediaEmpty alloc] init];
    return object;
}

- (void)TLfillFieldsWithValues:(std::map<int32_t, TLConstructedValue> *)__unused values
{
}


@end

@implementation TLDecryptedMessageMedia$decryptedMessageMediaPhoto : TLDecryptedMessageMedia


- (int32_t)TLconstructorSignature
{
    return (int32_t)0x32798a8c;
}

- (int32_t)TLconstructorName
{
    return (int32_t)0x543a2fdf;
}

- (id<TLObject>)TLbuildFromMetaObject:(std::tr1::shared_ptr<TLMetaObject>)metaObject
{
    TLDecryptedMessageMedia$decryptedMessageMediaPhoto *object = [[TLDecryptedMessageMedia$decryptedMessageMediaPhoto alloc] init];
    object.thumb = metaObject->getBytes((int32_t)0x712c4d9);
    object.thumb_w = metaObject->getInt32((int32_t)0x1d395235);
    object.thumb_h = metaObject->getInt32((int32_t)0xcda65d7d);
    object.w = metaObject->getInt32((int32_t)0x98407fc3);
    object.h = metaObject->getInt32((int32_t)0x27243f49);
    object.size = metaObject->getInt32((int32_t)0x5a228f5e);
    object.key = metaObject->getBytes((int32_t)0x6d6f838d);
    object.iv = metaObject->getBytes((int32_t)0xe38b40a9);
    return object;
}

- (void)TLfillFieldsWithValues:(std::map<int32_t, TLConstructedValue> *)values
{
    {
        TLConstructedValue value;
        value.type = TLConstructedValueTypeBytes;
        value.nativeObject = self.thumb;
        values->insert(std::pair<int32_t, TLConstructedValue>((int32_t)0x712c4d9, value));
    }
    {
        TLConstructedValue value;
        value.type = TLConstructedValueTypePrimitiveInt32;
        value.primitive.int32Value = self.thumb_w;
        values->insert(std::pair<int32_t, TLConstructedValue>((int32_t)0x1d395235, value));
    }
    {
        TLConstructedValue value;
        value.type = TLConstructedValueTypePrimitiveInt32;
        value.primitive.int32Value = self.thumb_h;
        values->insert(std::pair<int32_t, TLConstructedValue>((int32_t)0xcda65d7d, value));
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
    {
        TLConstructedValue value;
        value.type = TLConstructedValueTypePrimitiveInt32;
        value.primitive.int32Value = self.size;
        values->insert(std::pair<int32_t, TLConstructedValue>((int32_t)0x5a228f5e, value));
    }
    {
        TLConstructedValue value;
        value.type = TLConstructedValueTypeBytes;
        value.nativeObject = self.key;
        values->insert(std::pair<int32_t, TLConstructedValue>((int32_t)0x6d6f838d, value));
    }
    {
        TLConstructedValue value;
        value.type = TLConstructedValueTypeBytes;
        value.nativeObject = self.iv;
        values->insert(std::pair<int32_t, TLConstructedValue>((int32_t)0xe38b40a9, value));
    }
}


@end

@implementation TLDecryptedMessageMedia$decryptedMessageMediaVideo : TLDecryptedMessageMedia


- (int32_t)TLconstructorSignature
{
    return (int32_t)0x4cee6ef3;
}

- (int32_t)TLconstructorName
{
    return (int32_t)0x90bb9307;
}

- (id<TLObject>)TLbuildFromMetaObject:(std::tr1::shared_ptr<TLMetaObject>)metaObject
{
    TLDecryptedMessageMedia$decryptedMessageMediaVideo *object = [[TLDecryptedMessageMedia$decryptedMessageMediaVideo alloc] init];
    object.thumb = metaObject->getBytes((int32_t)0x712c4d9);
    object.thumb_w = metaObject->getInt32((int32_t)0x1d395235);
    object.thumb_h = metaObject->getInt32((int32_t)0xcda65d7d);
    object.duration = metaObject->getInt32((int32_t)0xac00f752);
    object.w = metaObject->getInt32((int32_t)0x98407fc3);
    object.h = metaObject->getInt32((int32_t)0x27243f49);
    object.size = metaObject->getInt32((int32_t)0x5a228f5e);
    object.key = metaObject->getBytes((int32_t)0x6d6f838d);
    object.iv = metaObject->getBytes((int32_t)0xe38b40a9);
    return object;
}

- (void)TLfillFieldsWithValues:(std::map<int32_t, TLConstructedValue> *)values
{
    {
        TLConstructedValue value;
        value.type = TLConstructedValueTypeBytes;
        value.nativeObject = self.thumb;
        values->insert(std::pair<int32_t, TLConstructedValue>((int32_t)0x712c4d9, value));
    }
    {
        TLConstructedValue value;
        value.type = TLConstructedValueTypePrimitiveInt32;
        value.primitive.int32Value = self.thumb_w;
        values->insert(std::pair<int32_t, TLConstructedValue>((int32_t)0x1d395235, value));
    }
    {
        TLConstructedValue value;
        value.type = TLConstructedValueTypePrimitiveInt32;
        value.primitive.int32Value = self.thumb_h;
        values->insert(std::pair<int32_t, TLConstructedValue>((int32_t)0xcda65d7d, value));
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
    {
        TLConstructedValue value;
        value.type = TLConstructedValueTypePrimitiveInt32;
        value.primitive.int32Value = self.size;
        values->insert(std::pair<int32_t, TLConstructedValue>((int32_t)0x5a228f5e, value));
    }
    {
        TLConstructedValue value;
        value.type = TLConstructedValueTypeBytes;
        value.nativeObject = self.key;
        values->insert(std::pair<int32_t, TLConstructedValue>((int32_t)0x6d6f838d, value));
    }
    {
        TLConstructedValue value;
        value.type = TLConstructedValueTypeBytes;
        value.nativeObject = self.iv;
        values->insert(std::pair<int32_t, TLConstructedValue>((int32_t)0xe38b40a9, value));
    }
}


@end

@implementation TLDecryptedMessageMedia$decryptedMessageMediaGeoPoint : TLDecryptedMessageMedia


- (int32_t)TLconstructorSignature
{
    return (int32_t)0x35480a59;
}

- (int32_t)TLconstructorName
{
    return (int32_t)0xb6fdd253;
}

- (id<TLObject>)TLbuildFromMetaObject:(std::tr1::shared_ptr<TLMetaObject>)metaObject
{
    TLDecryptedMessageMedia$decryptedMessageMediaGeoPoint *object = [[TLDecryptedMessageMedia$decryptedMessageMediaGeoPoint alloc] init];
    object.lat = metaObject->getDouble((int32_t)0x8161c7a1);
    object.n_long = metaObject->getDouble((int32_t)0x682f3647);
    return object;
}

- (void)TLfillFieldsWithValues:(std::map<int32_t, TLConstructedValue> *)values
{
    {
        TLConstructedValue value;
        value.type = TLConstructedValueTypePrimitiveDouble;
        value.primitive.doubleValue = self.lat;
        values->insert(std::pair<int32_t, TLConstructedValue>((int32_t)0x8161c7a1, value));
    }
    {
        TLConstructedValue value;
        value.type = TLConstructedValueTypePrimitiveDouble;
        value.primitive.doubleValue = self.n_long;
        values->insert(std::pair<int32_t, TLConstructedValue>((int32_t)0x682f3647, value));
    }
}


@end

@implementation TLDecryptedMessageMedia$decryptedMessageMediaContact : TLDecryptedMessageMedia


- (int32_t)TLconstructorSignature
{
    return (int32_t)0x588a0a97;
}

- (int32_t)TLconstructorName
{
    return (int32_t)0x36f6c12b;
}

- (id<TLObject>)TLbuildFromMetaObject:(std::tr1::shared_ptr<TLMetaObject>)metaObject
{
    TLDecryptedMessageMedia$decryptedMessageMediaContact *object = [[TLDecryptedMessageMedia$decryptedMessageMediaContact alloc] init];
    object.phone_number = metaObject->getString((int32_t)0xaecb6c79);
    object.first_name = metaObject->getString((int32_t)0xa604f05d);
    object.last_name = metaObject->getString((int32_t)0x10662e0e);
    object.user_id = metaObject->getInt32((int32_t)0xafdf4073);
    return object;
}

- (void)TLfillFieldsWithValues:(std::map<int32_t, TLConstructedValue> *)values
{
    {
        TLConstructedValue value;
        value.type = TLConstructedValueTypeString;
        value.nativeObject = self.phone_number;
        values->insert(std::pair<int32_t, TLConstructedValue>((int32_t)0xaecb6c79, value));
    }
    {
        TLConstructedValue value;
        value.type = TLConstructedValueTypeString;
        value.nativeObject = self.first_name;
        values->insert(std::pair<int32_t, TLConstructedValue>((int32_t)0xa604f05d, value));
    }
    {
        TLConstructedValue value;
        value.type = TLConstructedValueTypeString;
        value.nativeObject = self.last_name;
        values->insert(std::pair<int32_t, TLConstructedValue>((int32_t)0x10662e0e, value));
    }
    {
        TLConstructedValue value;
        value.type = TLConstructedValueTypePrimitiveInt32;
        value.primitive.int32Value = self.user_id;
        values->insert(std::pair<int32_t, TLConstructedValue>((int32_t)0xafdf4073, value));
    }
}


@end

@implementation TLDecryptedMessageMedia$decryptedMessageMediaDocument : TLDecryptedMessageMedia


- (int32_t)TLconstructorSignature
{
    return (int32_t)0xb095434b;
}

- (int32_t)TLconstructorName
{
    return (int32_t)0x99a8bbd4;
}

- (id<TLObject>)TLbuildFromMetaObject:(std::tr1::shared_ptr<TLMetaObject>)metaObject
{
    TLDecryptedMessageMedia$decryptedMessageMediaDocument *object = [[TLDecryptedMessageMedia$decryptedMessageMediaDocument alloc] init];
    object.thumb = metaObject->getBytes((int32_t)0x712c4d9);
    object.thumb_w = metaObject->getInt32((int32_t)0x1d395235);
    object.thumb_h = metaObject->getInt32((int32_t)0xcda65d7d);
    object.file_name = metaObject->getString((int32_t)0x3fa248c4);
    object.mime_type = metaObject->getString((int32_t)0xcd8e470b);
    object.size = metaObject->getInt32((int32_t)0x5a228f5e);
    object.key = metaObject->getBytes((int32_t)0x6d6f838d);
    object.iv = metaObject->getBytes((int32_t)0xe38b40a9);
    return object;
}

- (void)TLfillFieldsWithValues:(std::map<int32_t, TLConstructedValue> *)values
{
    {
        TLConstructedValue value;
        value.type = TLConstructedValueTypeBytes;
        value.nativeObject = self.thumb;
        values->insert(std::pair<int32_t, TLConstructedValue>((int32_t)0x712c4d9, value));
    }
    {
        TLConstructedValue value;
        value.type = TLConstructedValueTypePrimitiveInt32;
        value.primitive.int32Value = self.thumb_w;
        values->insert(std::pair<int32_t, TLConstructedValue>((int32_t)0x1d395235, value));
    }
    {
        TLConstructedValue value;
        value.type = TLConstructedValueTypePrimitiveInt32;
        value.primitive.int32Value = self.thumb_h;
        values->insert(std::pair<int32_t, TLConstructedValue>((int32_t)0xcda65d7d, value));
    }
    {
        TLConstructedValue value;
        value.type = TLConstructedValueTypeString;
        value.nativeObject = self.file_name;
        values->insert(std::pair<int32_t, TLConstructedValue>((int32_t)0x3fa248c4, value));
    }
    {
        TLConstructedValue value;
        value.type = TLConstructedValueTypeString;
        value.nativeObject = self.mime_type;
        values->insert(std::pair<int32_t, TLConstructedValue>((int32_t)0xcd8e470b, value));
    }
    {
        TLConstructedValue value;
        value.type = TLConstructedValueTypePrimitiveInt32;
        value.primitive.int32Value = self.size;
        values->insert(std::pair<int32_t, TLConstructedValue>((int32_t)0x5a228f5e, value));
    }
    {
        TLConstructedValue value;
        value.type = TLConstructedValueTypeBytes;
        value.nativeObject = self.key;
        values->insert(std::pair<int32_t, TLConstructedValue>((int32_t)0x6d6f838d, value));
    }
    {
        TLConstructedValue value;
        value.type = TLConstructedValueTypeBytes;
        value.nativeObject = self.iv;
        values->insert(std::pair<int32_t, TLConstructedValue>((int32_t)0xe38b40a9, value));
    }
}


@end

@implementation TLDecryptedMessageMedia$decryptedMessageMediaAudio : TLDecryptedMessageMedia


- (int32_t)TLconstructorSignature
{
    return (int32_t)0x6080758f;
}

- (int32_t)TLconstructorName
{
    return (int32_t)0x89af9707;
}

- (id<TLObject>)TLbuildFromMetaObject:(std::tr1::shared_ptr<TLMetaObject>)metaObject
{
    TLDecryptedMessageMedia$decryptedMessageMediaAudio *object = [[TLDecryptedMessageMedia$decryptedMessageMediaAudio alloc] init];
    object.duration = metaObject->getInt32((int32_t)0xac00f752);
    object.size = metaObject->getInt32((int32_t)0x5a228f5e);
    object.key = metaObject->getBytes((int32_t)0x6d6f838d);
    object.iv = metaObject->getBytes((int32_t)0xe38b40a9);
    return object;
}

- (void)TLfillFieldsWithValues:(std::map<int32_t, TLConstructedValue> *)values
{
    {
        TLConstructedValue value;
        value.type = TLConstructedValueTypePrimitiveInt32;
        value.primitive.int32Value = self.duration;
        values->insert(std::pair<int32_t, TLConstructedValue>((int32_t)0xac00f752, value));
    }
    {
        TLConstructedValue value;
        value.type = TLConstructedValueTypePrimitiveInt32;
        value.primitive.int32Value = self.size;
        values->insert(std::pair<int32_t, TLConstructedValue>((int32_t)0x5a228f5e, value));
    }
    {
        TLConstructedValue value;
        value.type = TLConstructedValueTypeBytes;
        value.nativeObject = self.key;
        values->insert(std::pair<int32_t, TLConstructedValue>((int32_t)0x6d6f838d, value));
    }
    {
        TLConstructedValue value;
        value.type = TLConstructedValueTypeBytes;
        value.nativeObject = self.iv;
        values->insert(std::pair<int32_t, TLConstructedValue>((int32_t)0xe38b40a9, value));
    }
}


@end

