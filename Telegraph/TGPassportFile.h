#import <Foundation/Foundation.h>
#import <SSignalKit/SSignalKit.h>

@class TLSecureFile$secureFile;
@class TLInputSecureFile$inputSecureFileUploaded;

@interface TGPassportFile : NSObject

@property (nonatomic) int64_t fileId;
@property (nonatomic) int64_t accessHash;
@property (nonatomic) int32_t size;
@property (nonatomic) int32_t dcId;
@property (nonatomic) int32_t date;
@property (nonatomic, retain) NSData *fileHash;
@property (nonatomic, retain) NSData *fileSecret;
@property (nonatomic, retain) NSData *encryptedFileSecret;

@property (nonatomic) bool uploaded;
@property (nonatomic) int32_t parts;
@property (nonatomic) NSString *md5Checksum;

- (instancetype)initWithTL:(TLSecureFile$secureFile *)file fileSecret:(NSData *)fileSecret;
- (instancetype)initForUploadedFileWithId:(int64_t)fileId parts:(int32_t)parts md5Checksum:(NSString *)md5Checksum fileHash:(NSData *)fileHash fileSecret:(NSData *)fileSecret encryptedFileSecret:(NSData *)encryptedFileSecret date:(int32_t)date;

@end


@interface TGPassportFileUpload : NSObject

@property (nonatomic, retain) UIImage *image;
@property (nonatomic, retain) UIImage *thumbnailImage;
@property (nonatomic) int32_t date;

@property (nonatomic, strong) SVariable *progress;
@property (nonatomic, strong) SMetaDisposable *disposable;

- (instancetype)initWithImage:(UIImage *)image thumbnailImage:(UIImage *)thumbnailImage date:(int32_t)date;

@end
