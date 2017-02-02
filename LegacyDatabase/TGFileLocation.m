#import "TGFileLocation.h"

@implementation TGFileLocation

- (instancetype)initWithDatacenterId:(NSInteger)datacenterId volumeId:(int64_t)volumeId localId:(int32_t)localId secret:(int64_t)secret
{
    self = [super init];
    if (self != nil)
    {
        _datacenterId = datacenterId;
        _volumeId = volumeId;
        _localId = localId;
        _secret = secret;
    }
    return self;
}

- (NSString *)description
{
    return [[NSString alloc] initWithFormat:@"(TGFileLocation datacenterId: %" PRId32 ", %" PRId64 ", %" PRId32 ", %" PRId64, (int32_t)_datacenterId, _volumeId, _localId, _secret];
}

@end
