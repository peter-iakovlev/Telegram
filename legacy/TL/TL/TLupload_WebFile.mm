#import "TLupload_WebFile.h"

#import "../NSInputStream+TL.h"
#import "../NSOutputStream+TL.h"

#import "TLstorage_FileType.h"

@implementation TLupload_WebFile


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

@implementation TLupload_WebFile$upload_webFile : TLupload_WebFile


- (int32_t)TLconstructorSignature
{
    return (int32_t)0x21e753bc;
}

- (int32_t)TLconstructorName
{
    return (int32_t)0x603a91fd;
}

- (id<TLObject>)TLbuildFromMetaObject:(std::shared_ptr<TLMetaObject>)metaObject
{
    TLupload_WebFile$upload_webFile *object = [[TLupload_WebFile$upload_webFile alloc] init];
    object.size = metaObject->getInt32((int32_t)0x5a228f5e);
    object.mime_type = metaObject->getString((int32_t)0xcd8e470b);
    object.file_type = metaObject->getObject((int32_t)0xa39cf6eb);
    object.mtime = metaObject->getInt32((int32_t)0x4384994e);
    object.bytes = metaObject->getBytes((int32_t)0xec5ef20a);
    return object;
}

- (void)TLfillFieldsWithValues:(std::map<int32_t, TLConstructedValue> *)values
{
    {
        TLConstructedValue value;
        value.type = TLConstructedValueTypePrimitiveInt32;
        value.primitive.int32Value = self.size;
        values->insert(std::pair<int32_t, TLConstructedValue>((int32_t)0x5a228f5e, value));
    }
    {
        TLConstructedValue value;
        value.type = TLConstructedValueTypeString;
        value.nativeObject = self.mime_type;
        values->insert(std::pair<int32_t, TLConstructedValue>((int32_t)0xcd8e470b, value));
    }
    {
        TLConstructedValue value;
        value.type = TLConstructedValueTypeObject;
        value.nativeObject = self.file_type;
        values->insert(std::pair<int32_t, TLConstructedValue>((int32_t)0xa39cf6eb, value));
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

