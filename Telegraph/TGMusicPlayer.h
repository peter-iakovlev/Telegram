#import <Foundation/Foundation.h>
#import <SSignalKit/SSignalKit.h>

#import "TGMusicPlayerPlaylist.h"
#import "TGMusicPlayerItem.h"

#import "TGAudioPlayer.h"

typedef struct {
    bool downloaded;
    bool downloading;
    CGFloat progress;
} TGMusicPlayerDownloadingStatus;

typedef struct {
    NSUInteger index;
    NSUInteger count;
} TGMusicPlayerItemPosition;

typedef enum {
    TGMusicPlayerRepeatTypeNone,
    TGMusicPlayerRepeatTypeAll,
    TGMusicPlayerRepeatTypeOne
} TGMusicPlayerRepeatType;

@interface TGMusicPlayerStatus : NSObject

@property (nonatomic, strong, readonly) TGAudioPlayer *player;
@property (nonatomic, strong, readonly) TGMusicPlayerItem *item;
@property (nonatomic, readonly) TGMusicPlayerItemPosition position;

@property (nonatomic, readonly) bool paused;
@property (nonatomic, readonly) CGFloat offset;
@property (nonatomic, readonly) TGMusicPlayerDownloadingStatus downloadedStatus;
@property (nonatomic, readonly) bool isVoice;
@property (nonatomic, readonly) bool isRoundMessage;

@property (nonatomic, readonly) CGFloat duration;

@property (nonatomic, readonly) NSTimeInterval timestamp;

@property (nonatomic, readonly) bool shuffle;
@property (nonatomic, readonly) TGMusicPlayerRepeatType repeatType;

@property (nonatomic, strong, readonly) SSignal *albumArt;
@property (nonatomic, strong, readonly) SSignal *albumArtSync;

@end

@interface TGMusicPlayer : NSObject

@property (nonatomic, strong, readonly) id playlistMetadata;

- (SSignal *)playingStatus;
- (SSignal *)playlistFinished;

- (void)setPlaylist:(SSignal *)playlist initialItemKey:(id<NSCopying>)initialItemKey metadata:(id)metadata;

- (void)controlPlay;
- (void)controlPause;
- (void)controlPause:(void (^)())completion;
- (void)controlPlayPause;
- (void)controlNext;
- (void)controlPrevious;
- (void)controlSeekToPosition:(CGFloat)position;
- (void)_dispatch:(dispatch_block_t)block;

- (void)controlShuffle;
- (void)controlRepeat;

+ (bool)isHeadsetPluggedIn;

@end
