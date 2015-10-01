#import <Foundation/Foundation.h>
#import <SSignalKit/SSignalKit.h>

#import "TGMusicPlayerPlaylist.h"
#import "TGMusicPlayerItem.h"

typedef struct {
    bool downloaded;
    bool downloading;
    CGFloat progress;
} TGMusicPlayerDownloadingStatus;

typedef struct {
    NSUInteger index;
    NSUInteger count;
} TGMusicPlayerItemPosition;

@interface TGMusicPlayerStatus : NSObject

@property (nonatomic, strong, readonly) TGMusicPlayerItem *item;
@property (nonatomic, readonly) TGMusicPlayerItemPosition position;

@property (nonatomic, readonly) bool paused;
@property (nonatomic, readonly) CGFloat offset;
@property (nonatomic, readonly) TGMusicPlayerDownloadingStatus downloadedStatus;

@property (nonatomic, readonly) CGFloat duration;

@property (nonatomic, readonly) NSTimeInterval timestamp;

@property (nonatomic, strong, readonly) SSignal *albumArt;
@property (nonatomic, strong, readonly) SSignal *albumArtSync;

@end

@interface TGMusicPlayer : NSObject

- (SSignal *)playingStatus;

- (void)setPlaylist:(SSignal *)playlist initialItemKey:(id<NSCopying>)initialItemKey;

- (void)controlPlay;
- (void)controlPause;
- (void)controlNext;
- (void)controlPrevious;
- (void)controlSeekToPosition:(CGFloat)position;

@end
