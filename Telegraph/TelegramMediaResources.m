#import "TelegramMediaResources.h"

#import "TL/TLMetaScheme.h"

@interface CloudFileMediaResourceId : NSObject <MediaResourceId>

@property (nonatomic, readonly) int32_t datacenterId;
@property (nonatomic, readonly) int64_t volumeId;
@property (nonatomic, readonly) int32_t localId;
@property (nonatomic, readonly) int64_t secret;

@end

@implementation CloudFileMediaResourceId

- (instancetype)initWithDatacenterId:(int32_t)datacenterId volumeId:(int64_t)volumeId localId:(int32_t)localId secret:(int64_t)secret {
    self = [super init];
    if (self != nil) {
        _datacenterId = datacenterId;
        _volumeId = volumeId;
        _localId = localId;
        _secret = secret;
    }
    return self;
}

- (NSUInteger)hash {
    return _volumeId ^ _localId;
}

- (BOOL)isEqual:(id)object {
    return [object isKindOfClass:[CloudFileMediaResourceId class]] && _datacenterId == ((CloudFileMediaResourceId *)object)->_datacenterId && _volumeId == ((CloudFileMediaResourceId *)object)->_volumeId && _localId == ((CloudFileMediaResourceId *)object)->_localId && _secret == ((CloudFileMediaResourceId *)object)->_secret;
}

- (NSString *)uniqueId {
    return [[NSString alloc] initWithFormat:@"telegram-cloud-file-%d-%lld-%d-%lld", _datacenterId, _volumeId, _localId, _secret];
}

- (instancetype)copyWithZone:(NSZone *)__unused zone {
    return self;
}

@end

@implementation CloudFileMediaResource

- (instancetype)initWithDatacenterId:(int32_t)datacenterId volumeId:(int64_t)volumeId localId:(int32_t)localId secret:(int64_t)secret size:(NSNumber *)size legacyCacheUrl:(NSString *)legacyCacheUrl legacyCachePath:(NSString *)legacyCachePath mediaType:(id)mediaType {
    self = [super init];
    if (self != nil) {
        _datacenterId = datacenterId;
        _volumeId = volumeId;
        _localId = localId;
        _secret = secret;
        _size = size;
        _legacyCacheUrl = legacyCacheUrl;
        _legacyCachePath = legacyCachePath;
        _mediaType = mediaType;
    }
    return self;
}

- (BOOL)isEqual:(id)object {
    return [object isKindOfClass:[CloudFileMediaResource class]] && _datacenterId == ((CloudFileMediaResource *)object)->_datacenterId && _volumeId == ((CloudFileMediaResource *)object)->_volumeId && _localId == ((CloudFileMediaResource *)object)->_localId && _secret == ((CloudFileMediaResource *)object)->_secret;
}

- (id<MediaResourceId>)resourceId {
    return [[CloudFileMediaResourceId alloc] initWithDatacenterId:_datacenterId volumeId:_volumeId localId:_localId secret:_secret];
}

- (TLInputFileLocation *)apiInputLocation {
    TLInputFileLocation$inputFileLocation *location = [[TLInputFileLocation$inputFileLocation alloc] init];
    location.volume_id = _volumeId;
    location.local_id = _localId;
    location.secret = _secret;
    return location;
}

@end

@interface CloudDocumentMediaResourceId : NSObject <MediaResourceId>

@property (nonatomic, readonly) int64_t fileId;

@end

@implementation CloudDocumentMediaResourceId

- (instancetype)initWithFileId:(int64_t)fileId {
    self = [super init];
    if (self != nil) {
        _fileId = fileId;
    }
    return self;
}

- (NSUInteger)hash {
    return _fileId;
}

- (BOOL)isEqual:(id)object {
    return [object isKindOfClass:[CloudDocumentMediaResourceId class]] && _fileId == ((CloudDocumentMediaResourceId *)object)->_fileId;
}

- (NSString *)uniqueId {
    return [[NSString alloc] initWithFormat:@"telegram-cloud-document-%lld", _fileId];
}

- (instancetype)copyWithZone:(NSZone *)__unused zone {
    return self;
}

@end

@implementation CloudDocumentMediaResource

- (instancetype)initWithDatacenterId:(int32_t)datacenterId fileId:(int64_t)fileId accessHash:(int64_t)accessHash size:(NSNumber *)size mediaType:(id)mediaType {
    self = [super init];
    if (self != nil) {
        _datacenterId = datacenterId;
        _fileId = fileId;
        _accessHash = accessHash;
        _size = size;
        _mediaType = mediaType;
    }
    return self;
}

- (BOOL)isEqual:(id)object {
    return [object isKindOfClass:[CloudDocumentMediaResource class]] && _datacenterId == ((CloudDocumentMediaResource *)object)->_datacenterId && _fileId == ((CloudDocumentMediaResource *)object)->_fileId && _accessHash == ((CloudDocumentMediaResource *)object)->_accessHash;
}

- (id<MediaResourceId>)resourceId {
    return [[CloudDocumentMediaResourceId alloc] initWithFileId:_fileId];
}

- (TLInputFileLocation *)apiInputLocation {
    TLInputFileLocation$inputDocumentFileLocation *location = [[TLInputFileLocation$inputDocumentFileLocation alloc] init];
    location.n_id = _fileId;
    location.access_hash = _accessHash;
    return location;
}

@end

