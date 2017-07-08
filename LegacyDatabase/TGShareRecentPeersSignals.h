#import <SSignalKit/SSignalKit.h>
#import "TGPeerId.h"

@class TGShareContext;

@interface TGShareRecentPeersSignals : NSObject

+ (void)clearRecentResults;
+ (void)addRecentPeerResult:(TGPeerId)peerId;
+ (void)removeRecentPeerResult:(TGPeerId)peerId;
+ (SSignal *)recentPeerResultsWithContext:(TGShareContext *)context cachedChats:(NSArray *)cachedChats;

@end
