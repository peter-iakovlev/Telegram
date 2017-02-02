#import "TLInputMedia.h"

#import "../NSInputStream+TL.h"
#import "../NSOutputStream+TL.h"

#import "TLInputGeoPoint.h"
#import "TLInputPhoto.h"
#import "TLInputDocument.h"
#import "TLInputFile.h"
#import "TLInputGame.h"

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

@implementation TLInputMedia$inputMediaGifExternal : TLInputMedia


- (int32_t)TLconstructorSignature
{
    return (int32_t)0x4843b0fd;
}

- (int32_t)TLconstructorName
{
    return (int32_t)0x80fe5c41;
}

- (id<TLObject>)TLbuildFromMetaObject:(std::tr1::shared_ptr<TLMetaObject>)metaObject
{
    TLInputMedia$inputMediaGifExternal *object = [[TLInputMedia$inputMediaGifExternal alloc] init];
    object.url = metaObject->getString((int32_t)0xeaf7861e);
    object.q = metaObject->getString((int32_t)0xcd45cb1c);
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
        value.nativeObject = self.q;
        values->insert(std::pair<int32_t, TLConstructedValue>((int32_t)0xcd45cb1c, value));
    }
}


@end

@implementation TLInputMedia$inputMediaDocument : TLInputMedia


- (int32_t)TLconstructorSignature
{
    return (int32_t)0x1a77f29c;
}

- (int32_t)TLconstructorName
{
    return (int32_t)0xe8c5765a;
}

- (id<TLObject>)TLbuildFromMetaObject:(std::tr1::shared_ptr<TLMetaObject>)metaObject
{
    TLInputMedia$inputMediaDocument *object = [[TLInputMedia$inputMediaDocument alloc] init];
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

@implementation TLInputMedia$inputMediaPhotoExternal : TLInputMedia


- (int32_t)TLconstructorSignature
{
    return (int32_t)0x3b7c62be;
}

- (int32_t)TLconstructorName
{
    return (int32_t)0x37524dc0;
}

- (id<TLObject>)TLbuildFromMetaObject:(std::tr1::shared_ptr<TLMetaObject>)metaObject
{
    TLInputMedia$inputMediaPhotoExternal *object = [[TLInputMedia$inputMediaPhotoExternal alloc] init];
    object.url = metaObject->getString((int32_t)0xeaf7861e);
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
}


@end

@implementation TLInputMedia$inputMediaDocumentExternal : TLInputMedia


- (int32_t)TLconstructorSignature
{
    return (int32_t)0x7477f92c;
}

- (int32_t)TLconstructorName
{
    return (int32_t)0xb14ffa16;
}

- (id<TLObject>)TLbuildFromMetaObject:(std::tr1::shared_ptr<TLMetaObject>)metaObject
{
    TLInputMedia$inputMediaDocumentExternal *object = [[TLInputMedia$inputMediaDocumentExternal alloc] init];
    object.url = metaObject->getObject((int32_t)0xeaf7861e);
    return object;
}

- (void)TLfillFieldsWithValues:(std::map<int32_t, TLConstructedValue> *)values
{
    {
        TLConstructedValue value;
        value.type = TLConstructedValueTypeObject;
        value.nativeObject = self.url;
        values->insert(std::pair<int32_t, TLConstructedValue>((int32_t)0xeaf7861e, value));
    }
}


@end

@implementation TLInputMedia$inputMediaGame : TLInputMedia


- (int32_t)TLconstructorSignature
{
    return (int32_t)0xd33f43f3;
}

- (int32_t)TLconstructorName
{
    return (int32_t)0xb4710a06;
}

- (id<TLObject>)TLbuildFromMetaObject:(std::tr1::shared_ptr<TLMetaObject>)metaObject
{
    TLInputMedia$inputMediaGame *object = [[TLInputMedia$inputMediaGame alloc] init];
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

