#import "TLRPCupload_saveFilePart.h"

#import "../NSInputStream+TL.h"
#import "../NSOutputStream+TL.h"


@implementation TLRPCupload_saveFilePart


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
    return 8;
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

@implementation TLRPCupload_saveFilePart$upload_saveFilePart : TLRPCupload_saveFilePart


- (int32_t)TLconstructorSignature
{
    return (int32_t)0xb304a621;
}

- (int32_t)TLconstructorName
{
    return (int32_t)0x179429e6;
}

- (id<TLObject>)TLbuildFromMetaObject:(std::shared_ptr<TLMetaObject>)metaObject
{
    TLRPCupload_saveFilePart$upload_saveFilePart *object = [[TLRPCupload_saveFilePart$upload_saveFilePart alloc] init];
    object.file_id = metaObject->getInt64((int32_t)0x9ce3ad26);
    object.file_part = metaObject->getInt32((int32_t)0x79fe76b5);
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
        value.type = TLConstructedValueTypeBytes;
        value.nativeObject = self.bytes;
        values->insert(std::pair<int32_t, TLConstructedValue>((int32_t)0xec5ef20a, value));
    }
}


@end

