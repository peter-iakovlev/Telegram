#import <SSignalKit/SSignalKit.h>
#import "TGPeerId.h"

@interface TGShareRecentPeersSignals : NSObject

+ (void)clearRecentResults;
+ (void)addRecentPeerResult:(TGPeerId)peerId;
+ (void)removeRecentPeerResult:(TGPeerId)peerId;
+ (SSignal *)recentPeerResultsWithChats:(NSArray *)chats;

@end
