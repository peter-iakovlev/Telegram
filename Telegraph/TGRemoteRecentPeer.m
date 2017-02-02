#import "TGRemoteRecentPeer.h"

@implementation TGRemoteRecentPeer

- (instancetype)initWithPeerId:(int64_t)peerId rating:(double)rating timestamp:(int32_t)timestamp {
    self = [super init];
    if (self != nil) {
        _peerId = peerId;
        _rating = rating;
        _timestamp = timestamp;
    }
    return self;
}

@end
