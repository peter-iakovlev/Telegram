#import "TGQueuedReadChannelMessages.h"

@implementation TGQueuedReadChannelMessages

- (instancetype)initWithPeerId:(int64_t)peerId accessHash:(int64_t)accessHash maxId:(int32_t)maxId {
    self = [super init];
    if (self != nil) {
        _peerId = peerId;
        _accessHash = accessHash;
        _maxId = maxId;
    }
    return self;
}

@end
