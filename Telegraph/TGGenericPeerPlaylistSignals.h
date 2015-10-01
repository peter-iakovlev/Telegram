#import <Foundation/Foundation.h>
#import <SSignalKit/SSignalKit.h>

@interface TGGenericPeerPlaylistSignals : NSObject

+ (SSignal *)playlistForPeerId:(int64_t)peerId important:(bool)important atMessageId:(int32_t)messageId;

@end
