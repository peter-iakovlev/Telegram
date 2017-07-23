#import "TLMessageMedia.h"

#import "../NSInputStream+TL.h"
#import "../NSOutputStream+TL.h"

#import "TLGeoPoint.h"
#import "TLWebPage.h"
#import "TLGame.h"
#import "TLWebDocument.h"
#import "TLPhoto.h"
#import "TLDocument.h"

@implementation TLMessageMedia


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

@implementation TLMessageMedia$messageMediaEmpty : TLMessageMedia


- (int32_t)TLconstructorSignature
{
    return (int32_t)0x3ded6320;
}

- (int32_t)TLconstructorName
{
    return (int32_t)0xfb752ca9;
}

- (id<TLObject>)TLbuildFromMetaObject:(std::shared_ptr<TLMetaObject>)__unused metaObject
{
    TLMessageMedia$messageMediaEmpty *object = [[TLMessageMedia$messageMediaEmpty alloc] init];
    return object;
}

- (void)TLfillFieldsWithValues:(std::map<int32_t, TLConstructedValue> *)__unused values
{
}


@end

@implementation TLMessageMedia$messageMediaGeo : TLMessageMedia


- (int32_t)TLconstructorSignature
{
    return (int32_t)0x56e0d474;
}

- (int32_t)TLconstructorName
{
    return (int32_t)0x7f81253;
}

- (id<TLObject>)TLbuildFromMetaObject:(std::shared_ptr<TLMetaObject>)metaObject
{
    TLMessageMedia$messageMediaGeo *object = [[TLMessageMedia$messageMediaGeo alloc] init];
    object.geo = metaObject->getObject((int32_t)0x3c803e05);
    return object;
}

- (void)TLfillFieldsWithValues:(std::map<int32_t, TLConstructedValue> *)values
{
    {
        TLConstructedValue value;
        value.type = TLConstructedValueTypeObject;
        value.nativeObject = self.geo;
        values->insert(std::pair<int32_t, TLConstructedValue>((int32_t)0x3c803e05, value));
    }
}


@end

@implementation TLMessageMedia$messageMediaContact : TLMessageMedia


- (int32_t)TLconstructorSignature
{
    return (int32_t)0x5e7d2f39;
}

- (int32_t)TLconstructorName
{
    return (int32_t)0xbe4c9bee;
}

- (id<TLObject>)TLbuildFromMetaObject:(std::shared_ptr<TLMetaObject>)metaObject
{
    TLMessageMedia$messageMediaContact *object = [[TLMessageMedia$messageMediaContact alloc] init];
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

@implementation TLMessageMedia$messageMediaUnsupported : TLMessageMedia


- (int32_t)TLconstructorSignature
{
    return (int32_t)0x9f84f49e;
}

- (int32_t)TLconstructorName
{
    return (int32_t)0x8bdaec28;
}

- (id<TLObject>)TLbuildFromMetaObject:(std::shared_ptr<TLMetaObject>)__unused metaObject
{
    TLMessageMedia$messageMediaUnsupported *object = [[TLMessageMedia$messageMediaUnsupported alloc] init];
    return object;
}

- (void)TLfillFieldsWithValues:(std::map<int32_t, TLConstructedValue> *)__unused values
{
}


@end

@implementation TLMessageMedia$messageMediaWebPage : TLMessageMedia


- (int32_t)TLconstructorSignature
{
    return (int32_t)0xa32dd600;
}

- (int32_t)TLconstructorName
{
    return (int32_t)0x7b38c3eb;
}

- (id<TLObject>)TLbuildFromMetaObject:(std::shared_ptr<TLMetaObject>)metaObject
{
    TLMessageMedia$messageMediaWebPage *object = [[TLMessageMedia$messageMediaWebPage alloc] init];
    object.webpage = metaObject->getObject((int32_t)0x9ae475f8);
    return object;
}

- (void)TLfillFieldsWithValues:(std::map<int32_t, TLConstructedValue> *)values
{
    {
        TLConstructedValue value;
        value.type = TLConstructedValueTypeObject;
        value.nativeObject = self.webpage;
        values->insert(std::pair<int32_t, TLConstructedValue>((int32_t)0x9ae475f8, value));
    }
}


@end

@implementation TLMessageMedia$messageMediaVenue : TLMessageMedia


- (int32_t)TLconstructorSignature
{
    return (int32_t)0x7912b71f;
}

- (int32_t)TLconstructorName
{
    return (int32_t)0x7c9dd24f;
}

- (id<TLObject>)TLbuildFromMetaObject:(std::shared_ptr<TLMetaObject>)metaObject
{
    TLMessageMedia$messageMediaVenue *object = [[TLMessageMedia$messageMediaVenue alloc] init];
    object.geo = metaObject->getObject((int32_t)0x3c803e05);
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
        value.nativeObject = self.geo;
        values->insert(std::pair<int32_t, TLConstructedValue>((int32_t)0x3c803e05, value));
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

@implementation TLMessageMedia$messageMediaGame : TLMessageMedia


- (int32_t)TLconstructorSignature
{
    return (int32_t)0xfdb19008;
}

- (int32_t)TLconstructorName
{
    return (int32_t)0x5c9f29a3;
}

- (id<TLObject>)TLbuildFromMetaObject:(std::shared_ptr<TLMetaObject>)metaObject
{
    TLMessageMedia$messageMediaGame *object = [[TLMessageMedia$messageMediaGame alloc] init];
    object.game = metaObject->getObject((int32_t)0x1ed73bd7);
    return object;
}

- (void)TLfillFieldsWithValues:(std::map<int32_t, TLConstructedValue> *)values
{
    {
        TLConstructedValue value;
        value.type = TLConstructedValueTypeObject;
        value.nativeObject = self.game;
        values->insert(std::pair<int32_t, TLConstructedValue>((int32_t)0x1ed73bd7, value));
    }
}


@end

@implementation TLMessageMedia$messageMediaInvoiceMeta : TLMessageMedia


- (int32_t)TLconstructorSignature
{
    return (int32_t)0xb0e774bd;
}

- (int32_t)TLconstructorName
{
    return (int32_t)0x127e5278;
}

- (id<TLObject>)TLbuildFromMetaObject:(std::shared_ptr<TLMetaObject>)metaObject
{
    TLMessageMedia$messageMediaInvoiceMeta *object = [[TLMessageMedia$messageMediaInvoiceMeta alloc] init];
    object.flags = metaObject->getInt32((int32_t)0x81915c23);
    object.title = metaObject->getString((int32_t)0xcdebf414);
    object.n_description = metaObject->getString((int32_t)0x9e47ce86);
    object.photo = metaObject->getObject((int32_t)0xe6c52372);
    object.receipt_msg_id = metaObject->getInt32((int32_t)0x33b4dedb);
    object.currency = metaObject->getString((int32_t)0xd2a84177);
    object.total_amount = metaObject->getInt64((int32_t)0x662699d7);
    object.start_param = metaObject->getString((int32_t)0x90d398cb);
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
        value.nativeObject = self.title;
        values->insert(std::pair<int32_t, TLConstructedValue>((int32_t)0xcdebf414, value));
    }
    {
        TLConstructedValue value;
        value.type = TLConstructedValueTypeString;
        value.nativeObject = self.n_description;
        values->insert(std::pair<int32_t, TLConstructedValue>((int32_t)0x9e47ce86, value));
    }
    {
        TLConstructedValue value;
        value.type = TLConstructedValueTypeObject;
        value.nativeObject = self.photo;
        values->insert(std::pair<int32_t, TLConstructedValue>((int32_t)0xe6c52372, value));
    }
    {
        TLConstructedValue value;
        value.type = TLConstructedValueTypePrimitiveInt32;
        value.primitive.int32Value = self.receipt_msg_id;
        values->insert(std::pair<int32_t, TLConstructedValue>((int32_t)0x33b4dedb, value));
    }
    {
        TLConstructedValue value;
        value.type = TLConstructedValueTypeString;
        value.nativeObject = self.currency;
        values->insert(std::pair<int32_t, TLConstructedValue>((int32_t)0xd2a84177, value));
    }
    {
        TLConstructedValue value;
        value.type = TLConstructedValueTypePrimitiveInt64;
        value.primitive.int64Value = self.total_amount;
        values->insert(std::pair<int32_t, TLConstructedValue>((int32_t)0x662699d7, value));
    }
    {
        TLConstructedValue value;
        value.type = TLConstructedValueTypeString;
        value.nativeObject = self.start_param;
        values->insert(std::pair<int32_t, TLConstructedValue>((int32_t)0x90d398cb, value));
    }
}


@end

@implementation TLMessageMedia$messageMediaPhotoMeta : TLMessageMedia


- (int32_t)TLconstructorSignature
{
    return (int32_t)0x17dace6c;
}

- (int32_t)TLconstructorName
{
    return (int32_t)0xaa0b9bcc;
}

- (id<TLObject>)TLbuildFromMetaObject:(std::shared_ptr<TLMetaObject>)metaObject
{
    TLMessageMedia$messageMediaPhotoMeta *object = [[TLMessageMedia$messageMediaPhotoMeta alloc] init];
    object.flags = metaObject->getInt32((int32_t)0x81915c23);
    object.photo = metaObject->getObject((int32_t)0xe6c52372);
    object.caption = metaObject->getString((int32_t)0x9bcfcf5a);
    object.ttl_seconds = metaObject->getInt32((int32_t)0x401ae035);
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
        value.type = TLConstructedValueTypeObject;
        value.nativeObject = self.photo;
        values->insert(std::pair<int32_t, TLConstructedValue>((int32_t)0xe6c52372, value));
    }
    {
        TLConstructedValue value;
        value.type = TLConstructedValueTypeString;
        value.nativeObject = self.caption;
        values->insert(std::pair<int32_t, TLConstructedValue>((int32_t)0x9bcfcf5a, value));
    }
    {
        TLConstructedValue value;
        value.type = TLConstructedValueTypePrimitiveInt32;
        value.primitive.int32Value = self.ttl_seconds;
        values->insert(std::pair<int32_t, TLConstructedValue>((int32_t)0x401ae035, value));
    }
}


@end

@implementation TLMessageMedia$messageMediaDocumentMeta : TLMessageMedia


- (int32_t)TLconstructorSignature
{
    return (int32_t)0xfac83deb;
}

- (int32_t)TLconstructorName
{
    return (int32_t)0x634056b1;
}

- (id<TLObject>)TLbuildFromMetaObject:(std::shared_ptr<TLMetaObject>)metaObject
{
    TLMessageMedia$messageMediaDocumentMeta *object = [[TLMessageMedia$messageMediaDocumentMeta alloc] init];
    object.flags = metaObject->getInt32((int32_t)0x81915c23);
    object.document = metaObject->getObject((int32_t)0xf1465b5f);
    object.caption = metaObject->getString((int32_t)0x9bcfcf5a);
    object.ttl_seconds = metaObject->getInt32((int32_t)0x401ae035);
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
        value.type = TLConstructedValueTypeObject;
        value.nativeObject = self.document;
        values->insert(std::pair<int32_t, TLConstructedValue>((int32_t)0xf1465b5f, value));
    }
    {
        TLConstructedValue value;
        value.type = TLConstructedValueTypeString;
        value.nativeObject = self.caption;
        values->insert(std::pair<int32_t, TLConstructedValue>((int32_t)0x9bcfcf5a, value));
    }
    {
        TLConstructedValue value;
        value.type = TLConstructedValueTypePrimitiveInt32;
        value.primitive.int32Value = self.ttl_seconds;
        values->insert(std::pair<int32_t, TLConstructedValue>((int32_t)0x401ae035, value));
    }
}


@end

