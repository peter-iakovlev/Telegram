#import "TGStoredOutgoingMessageFileInfo.h"

#import "PSKeyValueCoder.h"

@implementation TGStoredOutgoingMessageFileInfo

- (instancetype)initWithKeyValueCoder:(PSKeyValueCoder *)__unused coder
{
    return [super init];
}

- (void)encodeWithKeyValueCoder:(PSKeyValueCoder *)__unused coder
{
}

@end

@implementation TGStoredOutgoingMessageFileInfoUploaded

- (instancetype)initWithN_id:(int64_t)n_id parts:(int32_t)parts md5_checksum:(NSString *)md5_checksum key_fingerprint:(int32_t)key_fingerprint
{
    self = [super init];
    if (self != nil)
    {
        _n_id = n_id;
        _parts = parts;
        _md5_checksum = md5_checksum;
        _key_fingerprint = key_fingerprint;
    }
    return self;
}

- (instancetype)initWithKeyValueCoder:(PSKeyValueCoder *)coder
{
    self = [super init];
    if (self != nil)
    {
        _n_id = [coder decodeInt64ForCKey:"n_id"];
        _parts = [coder decodeInt32ForCKey:"parts"];
        _md5_checksum = [coder decodeStringForCKey:"md5_checksum"];
        _key_fingerprint = [coder decodeInt32ForCKey:"key_fingerprint"];
    }
    return self;
}

- (void)encodeWithKeyValueCoder:(PSKeyValueCoder *)coder
{
    [coder encodeInt64:_n_id forCKey:"n_id"];
    [coder encodeInt32:_parts forCKey:"parts"];
    [coder encodeString:_md5_checksum forCKey:"md5_checksum"];
    [coder encodeInt32:_key_fingerprint forCKey:"key_fingerprint"];
}

@end

@implementation TGStoredOutgoingMessageFileInfoExisting

- (instancetype)initWithN_id:(int64_t)n_id accessHash:(int64_t)accessHash
{
    self = [super init];
    if (self != nil)
    {
        _n_id = n_id;
        _access_hash = accessHash;
    }
    return self;
}

- (instancetype)initWithKeyValueCoder:(PSKeyValueCoder *)coder
{
    self = [super init];
    if (self != nil)
    {
        _n_id = [coder decodeInt64ForCKey:"n_id"];
        _access_hash = [coder decodeInt64ForCKey:"access_hash"];
    }
    return self;
}

- (void)encodeWithKeyValueCoder:(PSKeyValueCoder *)coder
{
    [coder encodeInt64:_n_id forCKey:"n_id"];
    [coder encodeInt64:_access_hash forCKey:"access_hash"];
}

@end

@implementation TGStoredOutgoingMessageFileInfoBigUploaded

- (instancetype)initWithN_id:(int64_t)n_id parts:(int32_t)parts key_fingerprint:(int32_t)key_fingerprint
{
    self = [super init];
    if (self != nil)
    {
        _n_id = n_id;
        _parts = parts;
        _key_fingerprint = key_fingerprint;
    }
    return self;
}

- (instancetype)initWithKeyValueCoder:(PSKeyValueCoder *)coder
{
    self = [super init];
    if (self != nil)
    {
        _n_id = [coder decodeInt64ForCKey:"n_id"];
        _parts = [coder decodeInt32ForCKey:"parts"];
        _key_fingerprint = [coder decodeInt32ForCKey:"key_fingerprint"];
    }
    return self;
}

- (void)encodeWithKeyValueCoder:(PSKeyValueCoder *)coder
{
    [coder encodeInt64:_n_id forCKey:"n_id"];
    [coder encodeInt32:_parts forCKey:"parts"];
    [coder encodeInt32:_key_fingerprint forCKey:"key_fingerprint"];
}

@end
