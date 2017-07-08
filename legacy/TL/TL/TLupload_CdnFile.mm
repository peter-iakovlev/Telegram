#import "TLupload_CdnFile.h"

#import "../NSInputStream+TL.h"
#import "../NSOutputStream+TL.h"


@implementation TLupload_CdnFile


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

@implementation TLupload_CdnFile$upload_cdnFileReuploadNeeded : TLupload_CdnFile


- (int32_t)TLconstructorSignature
{
    return (int32_t)0xeea8e46e;
}

- (int32_t)TLconstructorName
{
    return (int32_t)0xea5b6634;
}

- (id<TLObject>)TLbuildFromMetaObject:(std::shared_ptr<TLMetaObject>)metaObject
{
    TLupload_CdnFile$upload_cdnFileReuploadNeeded *object = [[TLupload_CdnFile$upload_cdnFileReuploadNeeded alloc] init];
    object.request_token = metaObject->getBytes((int32_t)0xc2bcf157);
    return object;
}

- (void)TLfillFieldsWithValues:(std::map<int32_t, TLConstructedValue> *)values
{
    {
        TLConstructedValue value;
        value.type = TLConstructedValueTypeBytes;
        value.nativeObject = self.request_token;
        values->insert(std::pair<int32_t, TLConstructedValue>((int32_t)0xc2bcf157, value));
    }
}


@end

@implementation TLupload_CdnFile$upload_cdnFile : TLupload_CdnFile


- (int32_t)TLconstructorSignature
{
    return (int32_t)0xa99fca4f;
}

- (int32_t)TLconstructorName
{
    return (int32_t)0xb9a72f80;
}

- (id<TLObject>)TLbuildFromMetaObject:(std::shared_ptr<TLMetaObject>)metaObject
{
    TLupload_CdnFile$upload_cdnFile *object = [[TLupload_CdnFile$upload_cdnFile alloc] init];
    object.bytes = metaObject->getBytes((int32_t)0xec5ef20a);
    return object;
}

- (void)TLfillFieldsWithValues:(std::map<int32_t, TLConstructedValue> *)values
{
    {
        TLConstructedValue value;
        value.type = TLConstructedValueTypeBytes;
        value.nativeObject = self.bytes;
        values->insert(std::pair<int32_t, TLConstructedValue>((int32_t)0xec5ef20a, value));
    }
}


@end

