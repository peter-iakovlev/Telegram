#import <Foundation/Foundation.h>

@interface TGRemoteRecentPeer: NSObject

@property (nonatomic, readonly) int64_t peerId;
@property (nonatomic, readonly) double rating;
@property (nonatomic, readonly) int32_t timestamp;

- (instancetype)initWithPeerId:(int64_t)peerId rating:(double)rating timestamp:(int32_t)timestamp;

@end
