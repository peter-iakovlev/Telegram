#import <Foundation/Foundation.h>

#import "MediaResource.h"

@class TLInputFileLocation;

@protocol TelegramCloudMediaResource <MediaResource>

- (int32_t)datacenterId;
- (TLInputFileLocation *)apiInputLocation;
- (NSNumber *)size;

@end
