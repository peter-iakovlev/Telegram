#import "TLInputSecureFile.h"

@implementation TLInputSecureFile

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

@implementation TLInputSecureFile$inputSecureFileUploaded : TLInputSecureFile


- (int32_t)TLconstructorSignature
{
    return (int32_t)0x3334b0f0;
}

- (int32_t)TLconstructorName
{
    return (int32_t)0x4a90394d;
}

- (id<TLObject>)TLbuildFromMetaObject:(std::shared_ptr<TLMetaObject>)metaObject
{
    TLInputSecureFile$inputSecureFileUploaded *object = [[TLInputSecureFile$inputSecureFileUploaded alloc] init];
    object.n_id = metaObject->getInt64((int32_t)0x7a5601fb);
    object.parts = metaObject->getInt32((int32_t)0xd88278ed);
    object.md5_checksum = metaObject->getString((int32_t)0x48bc9943);
    object.file_hash = metaObject->getBytes((int32_t)0xde1902e1);
    object.secret = metaObject->getBytes((int32_t)0x6706b4b7);
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
        value.type = TLConstructedValueTypeBytes;
        value.nativeObject = self.file_hash;
        values->insert(std::pair<int32_t, TLConstructedValue>((int32_t)0xde1902e1, value));
    }
    {
        TLConstructedValue value;
        value.type = TLConstructedValueTypeBytes;
        value.nativeObject = self.secret;
        values->insert(std::pair<int32_t, TLConstructedValue>((int32_t)0x6706b4b7, value));
    }
}


@end

@implementation TLInputSecureFile$inputSecureFile : TLInputSecureFile


- (int32_t)TLconstructorSignature
{
    return (int32_t)0x5367e5be;
}

- (int32_t)TLconstructorName
{
    return (int32_t)0x8ac73306;
}

- (id<TLObject>)TLbuildFromMetaObject:(std::shared_ptr<TLMetaObject>)metaObject
{
    TLInputSecureFile$inputSecureFile *object = [[TLInputSecureFile$inputSecureFile alloc] init];
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
