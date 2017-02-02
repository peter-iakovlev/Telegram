#import "TGRemoteRecentPeerSet.h"

@implementation TGRemoteRecentPeerSet

- (instancetype)initWithPeers:(NSArray<TGRemoteRecentPeer *> *)peers {
    self = [super init];
    if (self != nil) {
        _peers = peers;
    }
    return self;
}

@end
