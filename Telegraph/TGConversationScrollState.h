#import <Foundation/Foundation.h>

#import "PSCoding.h"

@interface TGConversationScrollState : NSObject <PSCoding>

@property (nonatomic, readonly) int32_t messageId;
@property (nonatomic, readonly) int32_t messageOffset;

- (instancetype)initWithMessageId:(int32_t)messageId messageOffset:(int32_t)messageOffset;

@end
