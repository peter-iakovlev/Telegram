#import "TGMtFileLocation.h"

#import "PSKeyValueCoder.h"

@interface TGMtFileLocation ()
{
    int64_t _volumeId;
    int32_t _localId;
    int64_t _secret;
}

@end

@implementation TGMtFileLocation

- (instancetype)initWithVolumeId:(int64_t)volumeId localId:(int32_t)localId secret:(int64_t)secret
{
    self = [super init];
    if (self != nil)
    {
        _volumeId = volumeId;
        _localId = localId;
        _secret = secret;
    }
    return self;
}

- (instancetype)initWithKeyValueCoder:(PSKeyValueCoder *)coder
{
    int64_t volumeId = [coder decodeInt64ForCKey:"volumeId"];
    int32_t localId = [coder decodeInt32ForCKey:"localId"];
    int64_t secret = [coder decodeInt64ForCKey:"secret"];
    
    return [self initWithVolumeId:volumeId localId:localId secret:secret];
}

- (void)encodeWithKeyValueCoder:(PSKeyValueCoder *)coder
{
    [coder encodeInt64:_volumeId forCKey:"volumeId"];
    [coder encodeInt32:_localId forCKey:"localId"];
    [coder encodeInt64:_secret forCKey:"secret"];
}

@end
