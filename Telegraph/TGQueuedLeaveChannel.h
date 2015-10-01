#import <Foundation/Foundation.h>

@interface TGQueuedLeaveChannel : NSObject

@property (nonatomic, readonly) int64_t peerId;
@property (nonatomic, readonly) int64_t accessHash;

- (instancetype)initWithPeerId:(int64_t)peerId accessHash:(int64_t)accessHash;

@end
