#import "TGImageFileReference.h"
#import "TGImageInfo+Telegraph.h"

@implementation TGImageFileReference

- (instancetype)initWithDatacenterId:(int32_t)datacenterId volumeId:(int64_t)volumeId localId:(int32_t)localId secret:(int64_t)secret
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

- (instancetype)initWithUrl:(NSString *)url
{
    self = [super init];
    if (self != nil)
    {
        if (!extractFileUrlComponents(url, &_datacenterId, &_volumeId, &_localId, &_secret))
            return nil;
    }
    return self;
}

@end
