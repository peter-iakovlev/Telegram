#import <Foundation/Foundation.h>
#import <SSignalKit/SSignalKit.h>

@interface TGRecentPeersSignals : NSObject

+ (SSignal *)recentPeers;
+ (SSignal *)updateRecentPeers;
+ (SSignal *)resetGenericPeerRating:(int64_t)peerId accessHash:(int64_t)accessHash;

@end
