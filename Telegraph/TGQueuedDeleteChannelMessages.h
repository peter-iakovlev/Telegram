#import <Foundation/Foundation.h>

@interface TGQueuedDeleteChannelMessages : NSObject

@property (nonatomic, readonly) int64_t peerId;
@property (nonatomic, readonly) int64_t accessHash;
@property (nonatomic, strong, readonly) NSArray *messageIds;

- (instancetype)initWithPeerId:(int64_t)peerId accessHash:(int64_t)accessHash messageIds:(NSArray *)messageIds;

@end
