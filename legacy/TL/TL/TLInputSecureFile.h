#import <Foundation/Foundation.h>

#import "TLObject.h"
#import "TLMetaRpc.h"


@interface TLInputSecureFile : NSObject <TLObject>

@end

@interface TLInputSecureFile$inputSecureFileUploaded : TLInputSecureFile

@property (nonatomic) int64_t n_id;
@property (nonatomic) int32_t parts;
@property (nonatomic, retain) NSString *md5_checksum;
@property (nonatomic, retain) NSData *file_hash;
@property (nonatomic, retain) NSData *secret;

@end

@interface TLInputSecureFile$inputSecureFile : TLInputSecureFile

@property (nonatomic) int64_t n_id;
@property (nonatomic) int64_t access_hash;

@end

