#import "TGPassportFile.h"
#import "TLSecureFile.h"
#import "TLInputSecureFile.h"

@implementation TGPassportFile

- (instancetype)initWithTL:(TLSecureFile$secureFile *)file fileSecret:(NSData *)fileSecret
{
    self = [super init];
    if (self != nil)
    {
        _fileId = file.n_id;
        _accessHash = file.access_hash;
        _size = file.size;
        _dcId = file.dc_id;
        _date = file.date;
        _fileHash = file.file_hash;
        _fileSecret = fileSecret;
        _encryptedFileSecret = file.secret;
    }
    return self;
}

- (instancetype)initForUploadedFileWithId:(int64_t)fileId parts:(int32_t)parts md5Checksum:(NSString *)md5Checksum fileHash:(NSData *)fileHash fileSecret:(NSData *)fileSecret encryptedFileSecret:(NSData *)encryptedFileSecret date:(int32_t)date
{
    self = [super init];
    if (self != nil)
    {
        _uploaded = true;
        _fileId = fileId;
        _parts = parts;
        _md5Checksum = md5Checksum;
        _fileHash = fileHash;
        _fileSecret = fileSecret;
        _encryptedFileSecret = encryptedFileSecret;
        _date = date;
    }
    return self;
}

- (BOOL)isEqual:(id)object
{
    if (object == self)
        return true;
    
    if (!object || ![object isKindOfClass:[self class]])
        return false;
    
    TGPassportFile *file = (TGPassportFile *)object;
    
    if (![self.fileHash isEqual:file.fileHash])
        return false;
    
    return true;
}

@end


@implementation TGPassportFileUpload

- (instancetype)initWithImage:(UIImage *)image thumbnailImage:(UIImage *)thumbnailImage date:(int32_t)date
{
    self = [super init];
    if (self != nil)
    {
        _image = image;
        _thumbnailImage = thumbnailImage;
        _date = date;
    }
    return self;
}

@end
