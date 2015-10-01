#import "TGQueuedDeleteChannelMessages.h"

@implementation TGQueuedDeleteChannelMessages

- (instancetype)initWithPeerId:(int64_t)peerId accessHash:(int64_t)accessHash messageIds:(NSArray *)messageIds {
    self = [super init];
    if (self != nil) {
        _peerId = peerId;
        _accessHash = accessHash;
        _messageIds = messageIds;
    }
    return self;
}

@end
