#import "PSCoding.h"

@interface TGStoredIncomingMessageFileInfo : NSObject <PSCoding>

@property (nonatomic, readonly) int64_t n_id;
@property (nonatomic, readonly) int64_t accessHash;
@property (nonatomic, readonly) int32_t size;
@property (nonatomic, readonly) int32_t datacenterId;
@property (nonatomic, readonly) int32_t keyFingerprint;

- (instancetype)initWithId:(int64_t)n_id accessHash:(int64_t)accessHash size:(int32_t)size datacenterId:(int32_t)datacenterId keyFingerprint:(int32_t)keyFingerprint;

@end
