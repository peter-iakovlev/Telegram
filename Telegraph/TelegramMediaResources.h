#import <Foundation/Foundation.h>

#import "MediaResource.h"
#import "TelegramCloudMediaResource.h"

@interface CloudFileMediaResource: NSObject <TelegramCloudMediaResource>

@property (nonatomic, readonly) int32_t datacenterId;
@property (nonatomic, readonly) int64_t volumeId;
@property (nonatomic, readonly) int32_t localId;
@property (nonatomic, readonly) int64_t secret;
@property (nonatomic, strong, readonly) NSNumber *size;

@property (nonatomic, strong, readonly) NSString *legacyCacheUrl;
@property (nonatomic, strong, readonly) NSString *legacyCachePath;

@property (nonatomic, strong, readonly) id mediaType;

- (instancetype)initWithDatacenterId:(int32_t)datacenterId volumeId:(int64_t)volumeId localId:(int32_t)localId secret:(int64_t)secret size:(NSNumber *)size legacyCacheUrl:(NSString *)legacyCacheUrl legacyCachePath:(NSString *)legacyCachePath mediaType:(id)mediaType;

@end

@interface CloudDocumentMediaResource: NSObject <TelegramCloudMediaResource>

@property (nonatomic, readonly) int32_t datacenterId;
@property (nonatomic, readonly) int64_t fileId;
@property (nonatomic, readonly) int64_t accessHash;
@property (nonatomic, strong, readonly) NSNumber *size;

@property (nonatomic, strong, readonly) id mediaType;

- (instancetype)initWithDatacenterId:(int32_t)datacenterId fileId:(int64_t)fileId accessHash:(int64_t)accessHash size:(NSNumber *)size mediaType:(id)mediaType;

@end
