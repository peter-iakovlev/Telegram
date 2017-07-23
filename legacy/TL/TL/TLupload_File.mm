#import "TLupload_File.h"

#import "../NSInputStream+TL.h"
#import "../NSOutputStream+TL.h"

#import "TLstorage_FileType.h"

@implementation TLupload_File


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

@implementation TLupload_File$upload_file : TLupload_File


- (int32_t)TLconstructorSignature
{
    return (int32_t)0x96a18d5;
}

- (int32_t)TLconstructorName
{
    return (int32_t)0x3c40a687;
}

- (id<TLObject>)TLbuildFromMetaObject:(std::shared_ptr<TLMetaObject>)metaObject
{
    TLupload_File$upload_file *object = [[TLupload_File$upload_file alloc] init];
    object.type = metaObject->getObject((int32_t)0x9211ab0a);
    object.mtime = metaObject->getInt32((int32_t)0x4384994e);
    object.bytes = metaObject->getBytes((int32_t)0xec5ef20a);
    return object;
}

- (void)TLfillFieldsWithValues:(std::map<int32_t, TLConstructedValue> *)values
{
    {
        TLConstructedValue value;
        value.type = TLConstructedValueTypeObject;
        value.nativeObject = self.type;
        values->insert(std::pair<int32_t, TLConstructedValue>((int32_t)0x9211ab0a, value));
    }
    {
        TLConstructedValue value;
        value.type = TLConstructedValueTypePrimitiveInt32;
        value.primitive.int32Value = self.mtime;
        values->insert(std::pair<int32_t, TLConstructedValue>((int32_t)0x4384994e, value));
    }
    {
        TLConstructedValue value;
        value.type = TLConstructedValueTypeBytes;
        value.nativeObject = self.bytes;
        values->insert(std::pair<int32_t, TLConstructedValue>((int32_t)0xec5ef20a, value));
    }
}


@end

@implementation TLupload_File$upload_fileCdnRedirect : TLupload_File


- (int32_t)TLconstructorSignature
{
    return (int32_t)0xea52fe5a;
}

- (int32_t)TLconstructorName
{
    return (int32_t)0xbb7ed5f1;
}

- (id<TLObject>)TLbuildFromMetaObject:(std::shared_ptr<TLMetaObject>)metaObject
{
    TLupload_File$upload_fileCdnRedirect *object = [[TLupload_File$upload_fileCdnRedirect alloc] init];
    object.dc_id = metaObject->getInt32((int32_t)0xae973dc4);
    object.file_token = metaObject->getBytes((int32_t)0x12624663);
    object.encryption_key = metaObject->getBytes((int32_t)0x6b414b69);
    object.encryption_iv = metaObject->getBytes((int32_t)0x551a79cf);
    object.cdn_file_hashes = metaObject->getArray((int32_t)0xc93a8c46);
    return object;
}

- (void)TLfillFieldsWithValues:(std::map<int32_t, TLConstructedValue> *)values
{
    {
        TLConstructedValue value;
        value.type = TLConstructedValueTypePrimitiveInt32;
        value.primitive.int32Value = self.dc_id;
        values->insert(std::pair<int32_t, TLConstructedValue>((int32_t)0xae973dc4, value));
    }
    {
        TLConstructedValue value;
        value.type = TLConstructedValueTypeBytes;
        value.nativeObject = self.file_token;
        values->insert(std::pair<int32_t, TLConstructedValue>((int32_t)0x12624663, value));
    }
    {
        TLConstructedValue value;
        value.type = TLConstructedValueTypeBytes;
        value.nativeObject = self.encryption_key;
        values->insert(std::pair<int32_t, TLConstructedValue>((int32_t)0x6b414b69, value));
    }
    {
        TLConstructedValue value;
        value.type = TLConstructedValueTypeBytes;
        value.nativeObject = self.encryption_iv;
        values->insert(std::pair<int32_t, TLConstructedValue>((int32_t)0x551a79cf, value));
    }
    {
        TLConstructedValue value;
        value.type = TLConstructedValueTypeVector;
        value.nativeObject = self.cdn_file_hashes;
        values->insert(std::pair<int32_t, TLConstructedValue>((int32_t)0xc93a8c46, value));
    }
}


@end

