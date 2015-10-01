#import <Foundation/Foundation.h>
#import "PSCoding.h"

@interface TGMessageViewCountContentProperty : NSObject <PSCoding>

@property (nonatomic, readonly) int32_t viewCount;

- (instancetype)initWithViewCount:(int32_t)viewCount;

@end
