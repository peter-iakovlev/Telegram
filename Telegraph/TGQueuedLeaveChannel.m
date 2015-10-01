#import "TGQueuedLeaveChannel.h"

@implementation TGQueuedLeaveChannel

- (instancetype)initWithPeerId:(int64_t)peerId accessHash:(int64_t)accessHash {
    self = [super init];
    if (self != nil) {
        _peerId = peerId;
        _accessHash = accessHash;
    }
    return self;
}

@end
