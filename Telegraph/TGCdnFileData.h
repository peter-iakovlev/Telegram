#import <Foundation/Foundation.h>

@interface TGCdnFileData : NSObject

@property (nonatomic, readonly) int32_t cdnId;
@property (nonatomic, strong, readonly) NSData *token;
@property (nonatomic, strong, readonly) NSData *encryptionKey;
@property (nonatomic, strong, readonly) NSData *encryptionIv;

- (instancetype)initWithCdnId:(int32_t)cdnId token:(NSData *)token encryptionKey:(NSData *)encryptionKey encryptionIv:(NSData *)encryptionIv;

@end
