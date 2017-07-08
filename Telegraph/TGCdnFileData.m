#import "TGCdnFileData.h"

@implementation TGCdnFileData
    
- (instancetype)initWithCdnId:(int32_t)cdnId token:(NSData *)token encryptionKey:(NSData *)encryptionKey encryptionIv:(NSData *)encryptionIv {
    self = [super init];
    if (self != nil) {
        _cdnId = cdnId;
        _token = token;
        _encryptionKey = encryptionKey;
        _encryptionIv = encryptionIv;
    }
    return self;
}

@end
