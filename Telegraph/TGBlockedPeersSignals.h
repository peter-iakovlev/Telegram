#import <Foundation/Foundation.h>

#import <SSignalKit/SSignalKit.h>

@interface TGBlockedPeersSignals : NSObject

+ (SSignal *)peerBlockedStatusWithPeerId:(int64_t)peerId;
+ (SSignal *)updatePeerBlockedStatusWithPeerId:(int64_t)peerId blocked:(bool)blocked;

@end
