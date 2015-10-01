#import <Foundation/Foundation.h>

@interface TGQueuedReadChannelMessages : NSObject

@property (nonatomic, readonly) int64_t peerId;
@property (nonatomic, readonly) int64_t accessHash;
@property (nonatomic, readonly) int32_t maxId;

- (instancetype)initWithPeerId:(int64_t)peerId accessHash:(int64_t)accessHash maxId:(int32_t)maxId;

@end
