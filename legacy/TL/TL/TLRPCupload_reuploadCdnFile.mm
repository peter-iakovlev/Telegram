#import "TLRPCupload_reuploadCdnFile.h"

#import "../NSInputStream+TL.h"
#import "../NSOutputStream+TL.h"

#import "NSArray_CdnFileHash.h"

@implementation TLRPCupload_reuploadCdnFile


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

@implementation TLRPCupload_reuploadCdnFile$upload_reuploadCdnFile : TLRPCupload_reuploadCdnFile


- (int32_t)TLconstructorSignature
{
    return (int32_t)0x1af91c09;
}

- (int32_t)TLconstructorName
{
    return (int32_t)0xe88add26;
}

- (id<TLObject>)TLbuildFromMetaObject:(std::shared_ptr<TLMetaObject>)metaObject
{
    TLRPCupload_reuploadCdnFile$upload_reuploadCdnFile *object = [[TLRPCupload_reuploadCdnFile$upload_reuploadCdnFile alloc] init];
    object.file_token = metaObject->getBytes((int32_t)0x12624663);
    object.request_token = metaObject->getBytes((int32_t)0xc2bcf157);
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
        value.type = TLConstructedValueTypeBytes;
        value.nativeObject = self.request_token;
        values->insert(std::pair<int32_t, TLConstructedValue>((int32_t)0xc2bcf157, value));
    }
}


@end

