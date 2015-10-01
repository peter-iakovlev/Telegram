#import "TGStoredIncomingMessageFileInfo.h"

#import "PSKeyValueCoder.h"

@implementation TGStoredIncomingMessageFileInfo

- (instancetype)initWithId:(int64_t)n_id accessHash:(int64_t)accessHash size:(int32_t)size datacenterId:(int32_t)datacenterId keyFingerprint:(int32_t)keyFingerprint
{
    self = [super init];
    if (self != nil)
    {
        _n_id = n_id;
        _accessHash = accessHash;
        _size = size;
        _datacenterId = datacenterId;
        _keyFingerprint = keyFingerprint;
    }
    return self;
}

- (instancetype)initWithKeyValueCoder:(PSKeyValueCoder *)coder
{
    return [self initWithId:[coder decodeInt64ForCKey:"id"] accessHash:[coder decodeInt64ForCKey:"accessHash"] size:[coder decodeInt32ForCKey:"size"] datacenterId:[coder decodeInt32ForCKey:"datacenterId"] keyFingerprint:[coder decodeInt32ForCKey:"keyFingerprint"]];
}

- (void)encodeWithKeyValueCoder:(PSKeyValueCoder *)coder
{
    [coder encodeInt64:_n_id forCKey:"id"];
    [coder encodeInt64:_accessHash forCKey:"accessHash"];
    [coder encodeInt32:_size forCKey:"size"];
    [coder encodeInt32:_datacenterId forCKey:"datacenterId"];
    [coder encodeInt32:_keyFingerprint forCKey:"keyFingerprint"];
}

@end
