#import "PSCoding.h"

@interface TGMtFileLocation : NSObject <PSCoding>

- (instancetype)initWithVolumeId:(int64_t)volumeId localId:(int32_t)localId secret:(int64_t)secret;

@end
