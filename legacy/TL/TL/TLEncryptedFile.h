#import <Foundation/Foundation.h>

#import "TLObject.h"
#import "TLMetaRpc.h"


@interface TLEncryptedFile : NSObject <TLObject>


@end

@interface TLEncryptedFile$encryptedFileEmpty : TLEncryptedFile


@end

@interface TLEncryptedFile$encryptedFile : TLEncryptedFile

@property (nonatomic) int64_t n_id;
@property (nonatomic) int64_t access_hash;
@property (nonatomic) int32_t size;
@property (nonatomic) int32_t dc_id;
@property (nonatomic) int32_t key_fingerprint;

@end

