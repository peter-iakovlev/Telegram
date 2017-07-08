#import <Foundation/Foundation.h>

#import "PSCoding.h"

@interface TGInstantPageScrollState : NSObject <PSCoding>

@property (nonatomic, readonly) int32_t blockId;
@property (nonatomic, readonly) int32_t blockOffset;

- (instancetype)initWithBlockId:(int32_t)blockId blockOffest:(int32_t)blockOffset;

@end
