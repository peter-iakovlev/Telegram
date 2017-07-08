#import "TLInputEncryptedFile.h"

#import "../NSInputStream+TL.h"
#import "../NSOutputStream+TL.h"


@implementation TLInputEncryptedFile


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

@implementation TLInputEncryptedFile$inputEncryptedFileEmpty : TLInputEncryptedFile


- (int32_t)TLconstructorSignature
{
    return (int32_t)0x1837c364;
}

- (int32_t)TLconstructorName
{
    return (int32_t)0x5ade6b35;
}

- (id<TLObject>)TLbuildFromMetaObject:(std::shared_ptr<TLMetaObject>)__unused metaObject
{
    TLInputEncryptedFile$inputEncryptedFileEmpty *object = [[TLInputEncryptedFile$inputEncryptedFileEmpty alloc] init];
    return object;
}

- (void)TLfillFieldsWithValues:(std::map<int32_t, TLConstructedValue> *)__unused values
{
}


@end

@implementation TLInputEncryptedFile$inputEncryptedFileUploaded : TLInputEncryptedFile


- (int32_t)TLconstructorSignature
{
    return (int32_t)0x64bd0306;
}

- (int32_t)TLconstructorName
{
    return (int32_t)0xa2934e84;
}

- (id<TLObject>)TLbuildFromMetaObject:(std::shared_ptr<TLMetaObject>)metaObject
{
    TLInputEncryptedFile$inputEncryptedFileUploaded *object = [[TLInputEncryptedFile$inputEncryptedFileUploaded alloc] init];
    object.n_id = metaObject->getInt64((int32_t)0x7a5601fb);
    object.parts = metaObject->getInt32((int32_t)0xd88278ed);
    object.md5_checksum = metaObject->getString((int32_t)0x48bc9943);
    object.key_fingerprint = metaObject->getInt32((int32_t)0x3633de43);
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
        value.type = TLConstructedValueTypePrimitiveInt32;
        value.primitive.int32Value = self.parts;
        values->insert(std::pair<int32_t, TLConstructedValue>((int32_t)0xd88278ed, value));
    }
    {
        TLConstructedValue value;
        value.type = TLConstructedValueTypeString;
        value.nativeObject = self.md5_checksum;
        values->insert(std::pair<int32_t, TLConstructedValue>((int32_t)0x48bc9943, value));
    }
    {
        TLConstructedValue value;
        value.type = TLConstructedValueTypePrimitiveInt32;
        value.primitive.int32Value = self.key_fingerprint;
        values->insert(std::pair<int32_t, TLConstructedValue>((int32_t)0x3633de43, value));
    }
}


@end

@implementation TLInputEncryptedFile$inputEncryptedFile : TLInputEncryptedFile


- (int32_t)TLconstructorSignature
{
    return (int32_t)0x5a17b5e5;
}

- (int32_t)TLconstructorName
{
    return (int32_t)0xd60eda43;
}

- (id<TLObject>)TLbuildFromMetaObject:(std::shared_ptr<TLMetaObject>)metaObject
{
    TLInputEncryptedFile$inputEncryptedFile *object = [[TLInputEncryptedFile$inputEncryptedFile alloc] init];
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

@implementation TLInputEncryptedFile$inputEncryptedFileBigUploaded : TLInputEncryptedFile


- (int32_t)TLconstructorSignature
{
    return (int32_t)0x2dc173c8;
}

- (int32_t)TLconstructorName
{
    return (int32_t)0xb131c22b;
}

- (id<TLObject>)TLbuildFromMetaObject:(std::shared_ptr<TLMetaObject>)metaObject
{
    TLInputEncryptedFile$inputEncryptedFileBigUploaded *object = [[TLInputEncryptedFile$inputEncryptedFileBigUploaded alloc] init];
    object.n_id = metaObject->getInt64((int32_t)0x7a5601fb);
    object.parts = metaObject->getInt32((int32_t)0xd88278ed);
    object.key_fingerprint = metaObject->getInt32((int32_t)0x3633de43);
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
        value.type = TLConstructedValueTypePrimitiveInt32;
        value.primitive.int32Value = self.parts;
        values->insert(std::pair<int32_t, TLConstructedValue>((int32_t)0xd88278ed, value));
    }
    {
        TLConstructedValue value;
        value.type = TLConstructedValueTypePrimitiveInt32;
        value.primitive.int32Value = self.key_fingerprint;
        values->insert(std::pair<int32_t, TLConstructedValue>((int32_t)0x3633de43, value));
    }
}


@end

