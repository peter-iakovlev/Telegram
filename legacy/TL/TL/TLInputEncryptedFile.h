#import <Foundation/Foundation.h>

#import "TLObject.h"
#import "TLMetaRpc.h"


@interface TLInputEncryptedFile : NSObject <TLObject>


@end

@interface TLInputEncryptedFile$inputEncryptedFileEmpty : TLInputEncryptedFile


@end

@interface TLInputEncryptedFile$inputEncryptedFileUploaded : TLInputEncryptedFile

@property (nonatomic) int64_t n_id;
@property (nonatomic) int32_t parts;
@property (nonatomic, retain) NSString *md5_checksum;
@property (nonatomic) int32_t key_fingerprint;

@end

@interface TLInputEncryptedFile$inputEncryptedFile : TLInputEncryptedFile

@property (nonatomic) int64_t n_id;
@property (nonatomic) int64_t access_hash;

@end

@interface TLInputEncryptedFile$inputEncryptedFileBigUploaded : TLInputEncryptedFile

@property (nonatomic) int64_t n_id;
@property (nonatomic) int32_t parts;
@property (nonatomic) int32_t key_fingerprint;

@end

