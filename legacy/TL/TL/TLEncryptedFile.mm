#import "TLEncryptedFile.h"

#import "../NSInputStream+TL.h"
#import "../NSOutputStream+TL.h"


@implementation TLEncryptedFile


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

@implementation TLEncryptedFile$encryptedFileEmpty : TLEncryptedFile


- (int32_t)TLconstructorSignature
{
    return (int32_t)0xc21f497e;
}

- (int32_t)TLconstructorName
{
    return (int32_t)0xb946dbc2;
}

- (id<TLObject>)TLbuildFromMetaObject:(std::shared_ptr<TLMetaObject>)__unused metaObject
{
    TLEncryptedFile$encryptedFileEmpty *object = [[TLEncryptedFile$encryptedFileEmpty alloc] init];
    return object;
}

- (void)TLfillFieldsWithValues:(std::map<int32_t, TLConstructedValue> *)__unused values
{
}


@end

@implementation TLEncryptedFile$encryptedFile : TLEncryptedFile


- (int32_t)TLconstructorSignature
{
    return (int32_t)0x4a70994c;
}

- (int32_t)TLconstructorName
{
    return (int32_t)0xbdb37017;
}

- (id<TLObject>)TLbuildFromMetaObject:(std::shared_ptr<TLMetaObject>)metaObject
{
    TLEncryptedFile$encryptedFile *object = [[TLEncryptedFile$encryptedFile alloc] init];
    object.n_id = metaObject->getInt64((int32_t)0x7a5601fb);
    object.access_hash = metaObject->getInt64((int32_t)0x8f305224);
    object.size = metaObject->getInt32((int32_t)0x5a228f5e);
    object.dc_id = metaObject->getInt32((int32_t)0xae973dc4);
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
        value.type = TLConstructedValueTypePrimitiveInt64;
        value.primitive.int64Value = self.access_hash;
        values->insert(std::pair<int32_t, TLConstructedValue>((int32_t)0x8f305224, value));
    }
    {
        TLConstructedValue value;
        value.type = TLConstructedValueTypePrimitiveInt32;
        value.primitive.int32Value = self.size;
        values->insert(std::pair<int32_t, TLConstructedValue>((int32_t)0x5a228f5e, value));
    }
    {
        TLConstructedValue value;
        value.type = TLConstructedValueTypePrimitiveInt32;
        value.primitive.int32Value = self.dc_id;
        values->insert(std::pair<int32_t, TLConstructedValue>((int32_t)0xae973dc4, value));
    }
    {
        TLConstructedValue value;
        value.type = TLConstructedValueTypePrimitiveInt32;
        value.primitive.int32Value = self.key_fingerprint;
        values->insert(std::pair<int32_t, TLConstructedValue>((int32_t)0x3633de43, value));
    }
}


@end

