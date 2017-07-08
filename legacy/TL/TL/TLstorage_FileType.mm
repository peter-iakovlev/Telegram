#import "TLstorage_FileType.h"

#import "../NSInputStream+TL.h"
#import "../NSOutputStream+TL.h"


@implementation TLstorage_FileType


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

@implementation TLstorage_FileType$storage_fileUnknown : TLstorage_FileType


- (int32_t)TLconstructorSignature
{
    return (int32_t)0xaa963b05;
}

- (int32_t)TLconstructorName
{
    return (int32_t)0xdaaa77af;
}

- (id<TLObject>)TLbuildFromMetaObject:(std::shared_ptr<TLMetaObject>)__unused metaObject
{
    TLstorage_FileType$storage_fileUnknown *object = [[TLstorage_FileType$storage_fileUnknown alloc] init];
    return object;
}

- (void)TLfillFieldsWithValues:(std::map<int32_t, TLConstructedValue> *)__unused values
{
}


@end

@implementation TLstorage_FileType$storage_fileJpeg : TLstorage_FileType


- (int32_t)TLconstructorSignature
{
    return (int32_t)0x7efe0e;
}

- (int32_t)TLconstructorName
{
    return (int32_t)0x30e964f3;
}

- (id<TLObject>)TLbuildFromMetaObject:(std::shared_ptr<TLMetaObject>)__unused metaObject
{
    TLstorage_FileType$storage_fileJpeg *object = [[TLstorage_FileType$storage_fileJpeg alloc] init];
    return object;
}

- (void)TLfillFieldsWithValues:(std::map<int32_t, TLConstructedValue> *)__unused values
{
}


@end

@implementation TLstorage_FileType$storage_fileGif : TLstorage_FileType


- (int32_t)TLconstructorSignature
{
    return (int32_t)0xcae1aadf;
}

- (int32_t)TLconstructorName
{
    return (int32_t)0xf76b52ef;
}

- (id<TLObject>)TLbuildFromMetaObject:(std::shared_ptr<TLMetaObject>)__unused metaObject
{
    TLstorage_FileType$storage_fileGif *object = [[TLstorage_FileType$storage_fileGif alloc] init];
    return object;
}

- (void)TLfillFieldsWithValues:(std::map<int32_t, TLConstructedValue> *)__unused values
{
}


@end

@implementation TLstorage_FileType$storage_filePng : TLstorage_FileType


- (int32_t)TLconstructorSignature
{
    return (int32_t)0xa4f63c0;
}

- (int32_t)TLconstructorName
{
    return (int32_t)0x66b8981;
}

- (id<TLObject>)TLbuildFromMetaObject:(std::shared_ptr<TLMetaObject>)__unused metaObject
{
    TLstorage_FileType$storage_filePng *object = [[TLstorage_FileType$storage_filePng alloc] init];
    return object;
}

- (void)TLfillFieldsWithValues:(std::map<int32_t, TLConstructedValue> *)__unused values
{
}


@end

@implementation TLstorage_FileType$storage_filePdf : TLstorage_FileType


- (int32_t)TLconstructorSignature
{
    return (int32_t)0xae1e508d;
}

- (int32_t)TLconstructorName
{
    return (int32_t)0x19ddb5ca;
}

- (id<TLObject>)TLbuildFromMetaObject:(std::shared_ptr<TLMetaObject>)__unused metaObject
{
    TLstorage_FileType$storage_filePdf *object = [[TLstorage_FileType$storage_filePdf alloc] init];
    return object;
}

- (void)TLfillFieldsWithValues:(std::map<int32_t, TLConstructedValue> *)__unused values
{
}


@end

@implementation TLstorage_FileType$storage_fileMp3 : TLstorage_FileType


- (int32_t)TLconstructorSignature
{
    return (int32_t)0x528a0677;
}

- (int32_t)TLconstructorName
{
    return (int32_t)0x4f837c26;
}

- (id<TLObject>)TLbuildFromMetaObject:(std::shared_ptr<TLMetaObject>)__unused metaObject
{
    TLstorage_FileType$storage_fileMp3 *object = [[TLstorage_FileType$storage_fileMp3 alloc] init];
    return object;
}

- (void)TLfillFieldsWithValues:(std::map<int32_t, TLConstructedValue> *)__unused values
{
}


@end

@implementation TLstorage_FileType$storage_fileMov : TLstorage_FileType


- (int32_t)TLconstructorSignature
{
    return (int32_t)0x4b09ebbc;
}

- (int32_t)TLconstructorName
{
    return (int32_t)0xbfa46836;
}

- (id<TLObject>)TLbuildFromMetaObject:(std::shared_ptr<TLMetaObject>)__unused metaObject
{
    TLstorage_FileType$storage_fileMov *object = [[TLstorage_FileType$storage_fileMov alloc] init];
    return object;
}

- (void)TLfillFieldsWithValues:(std::map<int32_t, TLConstructedValue> *)__unused values
{
}


@end

@implementation TLstorage_FileType$storage_filePartial : TLstorage_FileType


- (int32_t)TLconstructorSignature
{
    return (int32_t)0x40bc6f52;
}

- (int32_t)TLconstructorName
{
    return (int32_t)0x17b5e28e;
}

- (id<TLObject>)TLbuildFromMetaObject:(std::shared_ptr<TLMetaObject>)__unused metaObject
{
    TLstorage_FileType$storage_filePartial *object = [[TLstorage_FileType$storage_filePartial alloc] init];
    return object;
}

- (void)TLfillFieldsWithValues:(std::map<int32_t, TLConstructedValue> *)__unused values
{
}


@end

@implementation TLstorage_FileType$storage_fileMp4 : TLstorage_FileType


- (int32_t)TLconstructorSignature
{
    return (int32_t)0xb3cea0e4;
}

- (int32_t)TLconstructorName
{
    return (int32_t)0x14eef747;
}

- (id<TLObject>)TLbuildFromMetaObject:(std::shared_ptr<TLMetaObject>)__unused metaObject
{
    TLstorage_FileType$storage_fileMp4 *object = [[TLstorage_FileType$storage_fileMp4 alloc] init];
    return object;
}

- (void)TLfillFieldsWithValues:(std::map<int32_t, TLConstructedValue> *)__unused values
{
}


@end

@implementation TLstorage_FileType$storage_fileWebp : TLstorage_FileType


- (int32_t)TLconstructorSignature
{
    return (int32_t)0x1081464c;
}

- (int32_t)TLconstructorName
{
    return (int32_t)0x8aebc1a6;
}

- (id<TLObject>)TLbuildFromMetaObject:(std::shared_ptr<TLMetaObject>)__unused metaObject
{
    TLstorage_FileType$storage_fileWebp *object = [[TLstorage_FileType$storage_fileWebp alloc] init];
    return object;
}

- (void)TLfillFieldsWithValues:(std::map<int32_t, TLConstructedValue> *)__unused values
{
}


@end

