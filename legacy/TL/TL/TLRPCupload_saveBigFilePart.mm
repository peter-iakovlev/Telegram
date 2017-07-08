#import "TLRPCupload_saveBigFilePart.h"

#import "../NSInputStream+TL.h"
#import "../NSOutputStream+TL.h"


@implementation TLRPCupload_saveBigFilePart


- (Class)responseClass
{
    return [NSNumber class];
}

- (int)impliedResponseSignature
{
    return 0;
}

- (int)layerVersion
{
    return 9;
}

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

@implementation TLRPCupload_saveBigFilePart$upload_saveBigFilePart : TLRPCupload_saveBigFilePart


- (int32_t)TLconstructorSignature
{
    return (int32_t)0xde7b673d;
}

- (int32_t)TLconstructorName
{
    return (int32_t)0xd80f6162;
}

- (id<TLObject>)TLbuildFromMetaObject:(std::shared_ptr<TLMetaObject>)metaObject
{
    TLRPCupload_saveBigFilePart$upload_saveBigFilePart *object = [[TLRPCupload_saveBigFilePart$upload_saveBigFilePart alloc] init];
    object.file_id = metaObject->getInt64((int32_t)0x9ce3ad26);
    object.file_part = metaObject->getInt32((int32_t)0x79fe76b5);
    object.file_total_parts = metaObject->getInt32((int32_t)0x2af67e99);
    object.bytes = metaObject->getBytes((int32_t)0xec5ef20a);
    return object;
}

- (void)TLfillFieldsWithValues:(std::map<int32_t, TLConstructedValue> *)values
{
    {
        TLConstructedValue value;
        value.type = TLConstructedValueTypePrimitiveInt64;
        value.primitive.int64Value = self.file_id;
        values->insert(std::pair<int32_t, TLConstructedValue>((int32_t)0x9ce3ad26, value));
    }
    {
        TLConstructedValue value;
        value.type = TLConstructedValueTypePrimitiveInt32;
        value.primitive.int32Value = self.file_part;
        values->insert(std::pair<int32_t, TLConstructedValue>((int32_t)0x79fe76b5, value));
    }
    {
        TLConstructedValue value;
        value.type = TLConstructedValueTypePrimitiveInt32;
        value.primitive.int32Value = self.file_total_parts;
        values->insert(std::pair<int32_t, TLConstructedValue>((int32_t)0x2af67e99, value));
    }
    {
        TLConstructedValue value;
        value.type = TLConstructedValueTypeBytes;
        value.nativeObject = self.bytes;
        values->insert(std::pair<int32_t, TLConstructedValue>((int32_t)0xec5ef20a, value));
    }
}


@end

