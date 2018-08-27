#import <Foundation/Foundation.h>

#import "MediaResource.h"

@class TLInputFileLocation;
@class TGMediaOriginInfo;

@protocol TelegramCloudMediaResource <MediaResource>

- (int32_t)datacenterId;
- (TLInputFileLocation *)apiInputLocation;
- (int64_t)identifier;
- (TGMediaOriginInfo *)originInfo;
- (NSNumber *)size;

@end
