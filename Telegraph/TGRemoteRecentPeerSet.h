#import <Foundation/Foundation.h>

@class TGRemoteRecentPeer;

@interface TGRemoteRecentPeerSet: NSObject

@property (nonatomic, strong, readonly) NSArray<TGRemoteRecentPeer *> *peers;

- (instancetype)initWithPeers:(NSArray<TGRemoteRecentPeer *> *)peers;

@end
