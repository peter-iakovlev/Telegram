#import "TGDocumentFileReference.h"

@interface TGDocumentEncryptedFileReference : NSObject <TGDocumentFileReference>

@property (nonatomic, readonly) int32_t datacenterId;
@property (nonatomic, readonly) int64_t fileId;
@property (nonatomic, readonly) int64_t accessHash;
@property (nonatomic, readonly) int32_t encryptedSize;
@property (nonatomic, readonly) int32_t decryptedSize;
@property (nonatomic, readonly) int32_t keyFingerprint;
@property (nonatomic, readonly) NSData *key;
@property (nonatomic, readonly) NSData *iv;

- (instancetype)initWithDatacenterId:(int32_t)datacenterId fileId:(int64_t)fileId accessHash:(int64_t)accessHash encryptedSize:(int32_t)encryptedSize decryptedSize:(int32_t)decryptedSize keyFingerprint:(int32_t)keyFingerprint key:(NSData *)key iv:(NSData *)iv;

@end
