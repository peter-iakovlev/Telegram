#import "TGQueuedPeerPoll.h"

#import "TGFeedPosition.h"

@implementation TGQueuedPeerPoll

- (instancetype)initWithPeerId:(int64_t)peerId feedPosition:(TGFeedPosition *)feedPosition
{
    self = [super init];
    if (self != nil)
    {
        _peerId = peerId;
        _feedPosition = feedPosition;
    }
    return self;
}

- (instancetype)initWithKeyValueCoder:(PSKeyValueCoder *)coder
{
    return [self initWithPeerId:[coder decodeInt64ForCKey:"i"] feedPosition:(TGFeedPosition *)[coder decodeObjectForCKey:"p"]];
}

- (void)encodeWithKeyValueCoder:(PSKeyValueCoder *)coder
{
    [coder encodeInt64:_peerId forCKey:"i"];
    [coder encodeObject:_feedPosition forCKey:"p"];
}

@end
