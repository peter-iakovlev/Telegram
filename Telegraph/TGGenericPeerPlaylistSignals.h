#import <Foundation/Foundation.h>
#import <SSignalKit/SSignalKit.h>

@class TGMusicPlayerItem;

@interface TGGenericPeerPlaylistSignals : NSObject

+ (SSignal *)playlistForPeerId:(int64_t)peerId important:(bool)important atMessageId:(int32_t)messageId voice:(bool)voice;
+ (SSignal *)playlistForItem:(TGMusicPlayerItem *)item voice:(bool)voice;

@end
