#import "TLInputMedia.h"

#import "../NSInputStream+TL.h"
#import "../NSOutputStream+TL.h"

#import "TLInputGeoPoint.h"
#import "TLInputAudio.h"
#import "TLInputDocument.h"
#import "TLInputFile.h"
#import "TLInputPhoto.h"
#import "TLInputVideo.h"

@implementation TLInputMedia


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

@implementation TLInputMedia$inputMediaEmpty : TLInputMedia


- (int32_t)TLconstructorSignature
{
    return (int32_t)0x9664f57f;
}

- (int32_t)TLconstructorName
{
    return (int32_t)0xb1217c38;
}

- (id<TLObject>)TLbuildFromMetaObject:(std::tr1::shared_ptr<TLMetaObject>)__unused metaObject
{
    TLInputMedia$inputMediaEmpty *object = [[TLInputMedia$inputMediaEmpty alloc] init];
    return object;
}

- (void)TLfillFieldsWithValues:(std::map<int32_t, TLConstructedValue> *)__unused values
{
}


@end

@implementation TLInputMedia$inputMediaGeoPoint : TLInputMedia


- (int32_t)TLconstructorSignature
{
    return (int32_t)0xf9c44144;
}

- (int32_t)TLconstructorName
{
    return (int32_t)0x222d34ba;
}

- (id<TLObject>)TLbuildFromMetaObject:(std::tr1::shared_ptr<TLMetaObject>)metaObject
{
    TLInputMedia$inputMediaGeoPoint *object = [[TLInputMedia$inputMediaGeoPoint alloc] init];
    object.geo_point = metaObject->getObject((int32_t)0xa4670371);
    return object;
}

- (void)TLfillFieldsWithValues:(std::map<int32_t, TLConstructedValue> *)values
{
    {
        TLConstructedValue value;
        value.type = TLConstructedValueTypeObject;
        value.nativeObject = self.geo_point;
        values->insert(std::pair<int32_t, TLConstructedValue>((int32_t)0xa4670371, value));
    }
}


@end

@implementation TLInputMedia$inputMediaContact : TLInputMedia


- (int32_t)TLconstructorSignature
{
    return (int32_t)0xa6e45987;
}

- (int32_t)TLconstructorName
{
    return (int32_t)0xcfb05079;
}

- (id<TLObject>)TLbuildFromMetaObject:(std::tr1::shared_ptr<TLMetaObject>)metaObject
{
    TLInputMedia$inputMediaContact *object = [[TLInputMedia$inputMediaContact alloc] init];
    object.phone_number = metaObject->getString((int32_t)0xaecb6c79);
    object.first_name = metaObject->getString((int32_t)0xa604f05d);
    object.last_name = metaObject->getString((int32_t)0x10662e0e);
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
}


@end

@implementation TLInputMedia$inputMediaAudio : TLInputMedia


- (int32_t)TLconstructorSignature
{
    return (int32_t)0x89938781;
}

- (int32_t)TLconstructorName
{
    return (int32_t)0x46376ff;
}

- (id<TLObject>)TLbuildFromMetaObject:(std::tr1::shared_ptr<TLMetaObject>)metaObject
{
    TLInputMedia$inputMediaAudio *object = [[TLInputMedia$inputMediaAudio alloc] init];
    object.n_id = metaObject->getObject((int32_t)0x7a5601fb);
    return object;
}

- (void)TLfillFieldsWithValues:(std::map<int32_t, TLConstructedValue> *)values
{
    {
        TLConstructedValue value;
        value.type = TLConstructedValueTypeObject;
        value.nativeObject = self.n_id;
        values->insert(std::pair<int32_t, TLConstructedValue>((int32_t)0x7a5601fb, value));
    }
}


@end

@implementation TLInputMedia$inputMediaDocument : TLInputMedia


- (int32_t)TLconstructorSignature
{
    return (int32_t)0xd184e841;
}

- (int32_t)TLconstructorName
{
    return (int32_t)0xe8c5765a;
}

- (id<TLObject>)TLbuildFromMetaObject:(std::tr1::shared_ptr<TLMetaObject>)metaObject
{
    TLInputMedia$inputMediaDocument *object = [[TLInputMedia$inputMediaDocument alloc] init];
    object.n_id = metaObject->getObject((int32_t)0x7a5601fb);
    return object;
}

- (void)TLfillFieldsWithValues:(std::map<int32_t, TLConstructedValue> *)values
{
    {
        TLConstructedValue value;
        value.type = TLConstructedValueTypeObject;
        value.nativeObject = self.n_id;
        values->insert(std::pair<int32_t, TLConstructedValue>((int32_t)0x7a5601fb, value));
    }
}


@end

@implementation TLInputMedia$inputMediaUploadedAudio : TLInputMedia


- (int32_t)TLconstructorSignature
{
    return (int32_t)0x4e498cab;
}

- (int32_t)TLconstructorName
{
    return (int32_t)0x9d3a976c;
}

- (id<TLObject>)TLbuildFromMetaObject:(std::tr1::shared_ptr<TLMetaObject>)metaObject
{
    TLInputMedia$inputMediaUploadedAudio *object = [[TLInputMedia$inputMediaUploadedAudio alloc] init];
    object.file = metaObject->getObject((int32_t)0x3187ec9);
    object.duration = metaObject->getInt32((int32_t)0xac00f752);
    object.mime_type = metaObject->getString((int32_t)0xcd8e470b);
    return object;
}

- (void)TLfillFieldsWithValues:(std::map<int32_t, TLConstructedValue> *)values
{
    {
        TLConstructedValue value;
        value.type = TLConstructedValueTypeObject;
        value.nativeObject = self.file;
        values->insert(std::pair<int32_t, TLConstructedValue>((int32_t)0x3187ec9, value));
    }
    {
        TLConstructedValue value;
        value.type = TLConstructedValueTypePrimitiveInt32;
        value.primitive.int32Value = self.duration;
        values->insert(std::pair<int32_t, TLConstructedValue>((int32_t)0xac00f752, value));
    }
    {
        TLConstructedValue value;
        value.type = TLConstructedValueTypeString;
        value.nativeObject = self.mime_type;
        values->insert(std::pair<int32_t, TLConstructedValue>((int32_t)0xcd8e470b, value));
    }
}


@end

@implementation TLInputMedia$inputMediaUploadedDocument : TLInputMedia


- (int32_t)TLconstructorSignature
{
    return (int32_t)0xffe76b78;
}

- (int32_t)TLconstructorName
{
    return (int32_t)0xd9639385;
}

- (id<TLObject>)TLbuildFromMetaObject:(std::tr1::shared_ptr<TLMetaObject>)metaObject
{
    TLInputMedia$inputMediaUploadedDocument *object = [[TLInputMedia$inputMediaUploadedDocument alloc] init];
    object.file = metaObject->getObject((int32_t)0x3187ec9);
    object.mime_type = metaObject->getString((int32_t)0xcd8e470b);
    object.attributes = metaObject->getArray((int32_t)0xb339a07a);
    return object;
}

- (void)TLfillFieldsWithValues:(std::map<int32_t, TLConstructedValue> *)values
{
    {
        TLConstructedValue value;
        value.type = TLConstructedValueTypeObject;
        value.nativeObject = self.file;
        values->insert(std::pair<int32_t, TLConstructedValue>((int32_t)0x3187ec9, value));
    }
    {
        TLConstructedValue value;
        value.type = TLConstructedValueTypeString;
        value.nativeObject = self.mime_type;
        values->insert(std::pair<int32_t, TLConstructedValue>((int32_t)0xcd8e470b, value));
    }
    {
        TLConstructedValue value;
        value.type = TLConstructedValueTypeVector;
        value.nativeObject = self.attributes;
        values->insert(std::pair<int32_t, TLConstructedValue>((int32_t)0xb339a07a, value));
    }
}


@end

@implementation TLInputMedia$inputMediaUploadedThumbDocument : TLInputMedia


- (int32_t)TLconstructorSignature
{
    return (int32_t)0x41481486;
}

- (int32_t)TLconstructorName
{
    return (int32_t)0x97d078e3;
}

- (id<TLObject>)TLbuildFromMetaObject:(std::tr1::shared_ptr<TLMetaObject>)metaObject
{
    TLInputMedia$inputMediaUploadedThumbDocument *object = [[TLInputMedia$inputMediaUploadedThumbDocument alloc] init];
    object.file = metaObject->getObject((int32_t)0x3187ec9);
    object.thumb = metaObject->getObject((int32_t)0x712c4d9);
    object.mime_type = metaObject->getString((int32_t)0xcd8e470b);
    object.attributes = metaObject->getArray((int32_t)0xb339a07a);
    return object;
}

- (void)TLfillFieldsWithValues:(std::map<int32_t, TLConstructedValue> *)values
{
    {
        TLConstructedValue value;
        value.type = TLConstructedValueTypeObject;
        value.nativeObject = self.file;
        values->insert(std::pair<int32_t, TLConstructedValue>((int32_t)0x3187ec9, value));
    }
    {
        TLConstructedValue value;
        value.type = TLConstructedValueTypeObject;
        value.nativeObject = self.thumb;
        values->insert(std::pair<int32_t, TLConstructedValue>((int32_t)0x712c4d9, value));
    }
    {
        TLConstructedValue value;
        value.type = TLConstructedValueTypeString;
        value.nativeObject = self.mime_type;
        values->insert(std::pair<int32_t, TLConstructedValue>((int32_t)0xcd8e470b, value));
    }
    {
        TLConstructedValue value;
        value.type = TLConstructedValueTypeVector;
        value.nativeObject = self.attributes;
        values->insert(std::pair<int32_t, TLConstructedValue>((int32_t)0xb339a07a, value));
    }
}


@end

@implementation TLInputMedia$inputMediaUploadedPhoto : TLInputMedia


- (int32_t)TLconstructorSignature
{
    return (int32_t)0xf7aff1c0;
}

- (int32_t)TLconstructorName
{
    return (int32_t)0x7527a4be;
}

- (id<TLObject>)TLbuildFromMetaObject:(std::tr1::shared_ptr<TLMetaObject>)metaObject
{
    TLInputMedia$inputMediaUploadedPhoto *object = [[TLInputMedia$inputMediaUploadedPhoto alloc] init];
    object.file = metaObject->getObject((int32_t)0x3187ec9);
    object.caption = metaObject->getString((int32_t)0x9bcfcf5a);
    return object;
}

- (void)TLfillFieldsWithValues:(std::map<int32_t, TLConstructedValue> *)values
{
    {
        TLConstructedValue value;
        value.type = TLConstructedValueTypeObject;
        value.nativeObject = self.file;
        values->insert(std::pair<int32_t, TLConstructedValue>((int32_t)0x3187ec9, value));
    }
    {
        TLConstructedValue value;
        value.type = TLConstructedValueTypeString;
        value.nativeObject = self.caption;
        values->insert(std::pair<int32_t, TLConstructedValue>((int32_t)0x9bcfcf5a, value));
    }
}


@end

@implementation TLInputMedia$inputMediaPhoto : TLInputMedia


- (int32_t)TLconstructorSignature
{
    return (int32_t)0xe9bfb4f3;
}

- (int32_t)TLconstructorName
{
    return (int32_t)0x813364f2;
}

- (id<TLObject>)TLbuildFromMetaObject:(std::tr1::shared_ptr<TLMetaObject>)metaObject
{
    TLInputMedia$inputMediaPhoto *object = [[TLInputMedia$inputMediaPhoto alloc] init];
    object.n_id = metaObject->getObject((int32_t)0x7a5601fb);
    object.caption = metaObject->getString((int32_t)0x9bcfcf5a);
    return object;
}

- (void)TLfillFieldsWithValues:(std::map<int32_t, TLConstructedValue> *)values
{
    {
        TLConstructedValue value;
        value.type = TLConstructedValueTypeObject;
        value.nativeObject = self.n_id;
        values->insert(std::pair<int32_t, TLConstructedValue>((int32_t)0x7a5601fb, value));
    }
    {
        TLConstructedValue value;
        value.type = TLConstructedValueTypeString;
        value.nativeObject = self.caption;
        values->insert(std::pair<int32_t, TLConstructedValue>((int32_t)0x9bcfcf5a, value));
    }
}


@end

@implementation TLInputMedia$inputMediaVideo : TLInputMedia


- (int32_t)TLconstructorSignature
{
    return (int32_t)0x936a4ebd;
}

- (int32_t)TLconstructorName
{
    return (int32_t)0xb54dc1e3;
}

- (id<TLObject>)TLbuildFromMetaObject:(std::tr1::shared_ptr<TLMetaObject>)metaObject
{
    TLInputMedia$inputMediaVideo *object = [[TLInputMedia$inputMediaVideo alloc] init];
    object.n_id = metaObject->getObject((int32_t)0x7a5601fb);
    object.caption = metaObject->getString((int32_t)0x9bcfcf5a);
    return object;
}

- (void)TLfillFieldsWithValues:(std::map<int32_t, TLConstructedValue> *)values
{
    {
        TLConstructedValue value;
        value.type = TLConstructedValueTypeObject;
        value.nativeObject = self.n_id;
        values->insert(std::pair<int32_t, TLConstructedValue>((int32_t)0x7a5601fb, value));
    }
    {
        TLConstructedValue value;
        value.type = TLConstructedValueTypeString;
        value.nativeObject = self.caption;
        values->insert(std::pair<int32_t, TLConstructedValue>((int32_t)0x9bcfcf5a, value));
    }
}


@end

@implementation TLInputMedia$inputMediaVenue : TLInputMedia


- (int32_t)TLconstructorSignature
{
    return (int32_t)0x2827a81a;
}

- (int32_t)TLconstructorName
{
    return (int32_t)0xaad6ab5b;
}

- (id<TLObject>)TLbuildFromMetaObject:(std::tr1::shared_ptr<TLMetaObject>)metaObject
{
    TLInputMedia$inputMediaVenue *object = [[TLInputMedia$inputMediaVenue alloc] init];
    object.geo_point = metaObject->getObject((int32_t)0xa4670371);
    object.title = metaObject->getString((int32_t)0xcdebf414);
    object.address = metaObject->getString((int32_t)0x1a893fea);
    object.provider = metaObject->getString((int32_t)0x49eaf8ed);
    object.venue_id = metaObject->getString((int32_t)0x8aaa3ed3);
    return object;
}

- (void)TLfillFieldsWithValues:(std::map<int32_t, TLConstructedValue> *)values
{
    {
        TLConstructedValue value;
        value.type = TLConstructedValueTypeObject;
        value.nativeObject = self.geo_point;
        values->insert(std::pair<int32_t, TLConstructedValue>((int32_t)0xa4670371, value));
    }
    {
        TLConstructedValue value;
        value.type = TLConstructedValueTypeString;
        value.nativeObject = self.title;
        values->insert(std::pair<int32_t, TLConstructedValue>((int32_t)0xcdebf414, value));
    }
    {
        TLConstructedValue value;
        value.type = TLConstructedValueTypeString;
        value.nativeObject = self.address;
        values->insert(std::pair<int32_t, TLConstructedValue>((int32_t)0x1a893fea, value));
    }
    {
        TLConstructedValue value;
        value.type = TLConstructedValueTypeString;
        value.nativeObject = self.provider;
        values->insert(std::pair<int32_t, TLConstructedValue>((int32_t)0x49eaf8ed, value));
    }
    {
        TLConstructedValue value;
        value.type = TLConstructedValueTypeString;
        value.nativeObject = self.venue_id;
        values->insert(std::pair<int32_t, TLConstructedValue>((int32_t)0x8aaa3ed3, value));
    }
}


@end

@implementation TLInputMedia$inputMediaUploadedVideo : TLInputMedia


- (int32_t)TLconstructorSignature
{
    return (int32_t)0x82713fdf;
}

- (int32_t)TLconstructorName
{
    return (int32_t)0x73df18bb;
}

- (id<TLObject>)TLbuildFromMetaObject:(std::tr1::shared_ptr<TLMetaObject>)metaObject
{
    TLInputMedia$inputMediaUploadedVideo *object = [[TLInputMedia$inputMediaUploadedVideo alloc] init];
    object.file = metaObject->getObject((int32_t)0x3187ec9);
    object.duration = metaObject->getInt32((int32_t)0xac00f752);
    object.w = metaObject->getInt32((int32_t)0x98407fc3);
    object.h = metaObject->getInt32((int32_t)0x27243f49);
    object.mime_type = metaObject->getString((int32_t)0xcd8e470b);
    object.caption = metaObject->getString((int32_t)0x9bcfcf5a);
    return object;
}

- (void)TLfillFieldsWithValues:(std::map<int32_t, TLConstructedValue> *)values
{
    {
        TLConstructedValue value;
        value.type = TLConstructedValueTypeObject;
        value.nativeObject = self.file;
        values->insert(std::pair<int32_t, TLConstructedValue>((int32_t)0x3187ec9, value));
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
        value.type = TLConstructedValueTypeString;
        value.nativeObject = self.mime_type;
        values->insert(std::pair<int32_t, TLConstructedValue>((int32_t)0xcd8e470b, value));
    }
    {
        TLConstructedValue value;
        value.type = TLConstructedValueTypeString;
        value.nativeObject = self.caption;
        values->insert(std::pair<int32_t, TLConstructedValue>((int32_t)0x9bcfcf5a, value));
    }
}


@end

@implementation TLInputMedia$inputMediaUploadedThumbVideo : TLInputMedia


- (int32_t)TLconstructorSignature
{
    return (int32_t)0x7780ddf9;
}

- (int32_t)TLconstructorName
{
    return (int32_t)0xacaa44e6;
}

- (id<TLObject>)TLbuildFromMetaObject:(std::tr1::shared_ptr<TLMetaObject>)metaObject
{
    TLInputMedia$inputMediaUploadedThumbVideo *object = [[TLInputMedia$inputMediaUploadedThumbVideo alloc] init];
    object.file = metaObject->getObject((int32_t)0x3187ec9);
    object.thumb = metaObject->getObject((int32_t)0x712c4d9);
    object.duration = metaObject->getInt32((int32_t)0xac00f752);
    object.w = metaObject->getInt32((int32_t)0x98407fc3);
    object.h = metaObject->getInt32((int32_t)0x27243f49);
    object.mime_type = metaObject->getString((int32_t)0xcd8e470b);
    object.caption = metaObject->getString((int32_t)0x9bcfcf5a);
    return object;
}

- (void)TLfillFieldsWithValues:(std::map<int32_t, TLConstructedValue> *)values
{
    {
        TLConstructedValue value;
        value.type = TLConstructedValueTypeObject;
        value.nativeObject = self.file;
        values->insert(std::pair<int32_t, TLConstructedValue>((int32_t)0x3187ec9, value));
    }
    {
        TLConstructedValue value;
        value.type = TLConstructedValueTypeObject;
        value.nativeObject = self.thumb;
        values->insert(std::pair<int32_t, TLConstructedValue>((int32_t)0x712c4d9, value));
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
        value.type = TLConstructedValueTypeString;
        value.nativeObject = self.mime_type;
        values->insert(std::pair<int32_t, TLConstructedValue>((int32_t)0xcd8e470b, value));
    }
    {
        TLConstructedValue value;
        value.type = TLConstructedValueTypeString;
        value.nativeObject = self.caption;
        values->insert(std::pair<int32_t, TLConstructedValue>((int32_t)0x9bcfcf5a, value));
    }
}


@end

