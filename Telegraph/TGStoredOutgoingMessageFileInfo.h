#import "PSCoding.h"

@interface TGStoredOutgoingMessageFileInfo : NSObject <PSCoding>

@end

@interface TGStoredOutgoingMessageFileInfoUploaded : TGStoredOutgoingMessageFileInfo

@property (nonatomic) int64_t n_id;
@property (nonatomic) int32_t parts;
@property (nonatomic, retain) NSString *md5_checksum;
@property (nonatomic) int32_t key_fingerprint;

- (instancetype)initWithN_id:(int64_t)n_id parts:(int32_t)parts md5_checksum:(NSString *)md5_checksum key_fingerprint:(int32_t)key_fingerprint;

@end

@interface TGStoredOutgoingMessageFileInfoExisting : TGStoredOutgoingMessageFileInfo

@property (nonatomic) int64_t n_id;
@property (nonatomic) int64_t access_hash;

- (instancetype)initWithN_id:(int64_t)n_id accessHash:(int64_t)accessHash;

@end

@interface TGStoredOutgoingMessageFileInfoBigUploaded : TGStoredOutgoingMessageFileInfo

@property (nonatomic) int64_t n_id;
@property (nonatomic) int32_t parts;
@property (nonatomic) int32_t key_fingerprint;

- (instancetype)initWithN_id:(int64_t)n_id parts:(int32_t)parts key_fingerprint:(int32_t)key_fingerprint;

@end