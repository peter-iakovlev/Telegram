#import <Foundation/Foundation.h>

#import "TGFileReference.h"

@interface TGImageFileReference : NSObject <TGFileReference>

@property (nonatomic, readonly) int32_t datacenterId;
@property (nonatomic, readonly) int64_t volumeId;
@property (nonatomic, readonly) int32_t localId;
@property (nonatomic, readonly) int64_t secret;

- (instancetype)initWithDatacenterId:(int32_t)datacenterId volumeId:(int64_t)volumeId localId:(int32_t)localId secret:(int64_t)secret;

- (instancetype)initWithUrl:(NSString *)url;

@end
