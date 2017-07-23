#import "TLRPCupload_getCdnFileHashes.h"

#import "../NSInputStream+TL.h"
#import "../NSOutputStream+TL.h"

#import "NSArray_CdnFileHash.h"

@implementation TLRPCupload_getCdnFileHashes


- (Class)responseClass
{
    return [NSArray class];
}

- (int)impliedResponseSignature
{
    return (int)0xc05bcc69;
}

- (int)layerVersion
{
    return 70;
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

@implementation TLRPCupload_getCdnFileHashes$upload_getCdnFileHashes : TLRPCupload_getCdnFileHashes


- (int32_t)TLconstructorSignature
{
    return (int32_t)0xf715c87b;
}

- (int32_t)TLconstructorName
{
    return (int32_t)0x1ccd5960;
}

- (id<TLObject>)TLbuildFromMetaObject:(std::shared_ptr<TLMetaObject>)metaObject
{
    TLRPCupload_getCdnFileHashes$upload_getCdnFileHashes *object = [[TLRPCupload_getCdnFileHashes$upload_getCdnFileHashes alloc] init];
    object.file_token = metaObject->getBytes((int32_t)0x12624663);
    object.offset = metaObject->getInt32((int32_t)0xfc56269);
    return object;
}

- (void)TLfillFieldsWithValues:(std::map<int32_t, TLConstructedValue> *)values
{
    {
        TLConstructedValue value;
        value.type = TLConstructedValueTypeBytes;
        value.nativeObject = self.file_token;
        values->insert(std::pair<int32_t, TLConstructedValue>((int32_t)0x12624663, value));
    }
    {
        TLConstructedValue value;
        value.type = TLConstructedValueTypePrimitiveInt32;
        value.primitive.int32Value = self.offset;
        values->insert(std::pair<int32_t, TLConstructedValue>((int32_t)0xfc56269, value));
    }
}


@end

