#import "TGMusicPlayer.h"

#import <AVFoundation/AVFoundation.h>
#import <MediaPlayer/MediaPlayer.h>

#import "TGPreparedLocalDocumentMessage.h"
#import "TGMessage.h"
#import "TGTimerTarget.h"
#import "TGObserverProxy.h"
#import "TGImageUtils.h"
#import "TGMusicPlayerPlaylist.h"

#import "TGAudioSessionManager.h"
#import "TGRemoteControlsManager.h"

#import "TGMusicPlayerItemSignals.h"

static TGMusicPlayerDownloadingStatus TGMusicPlayerDownloadingStatusMake(bool downloaded, bool downloading, CGFloat progress)
{
    return (TGMusicPlayerDownloadingStatus){.downloaded = downloaded, .downloading = downloading, .progress = progress};
}

@interface TGMusicPlayerStatus ()

@end

@implementation TGMusicPlayerStatus

- (instancetype)initWithItem:(TGMusicPlayerItem *)item position:(TGMusicPlayerItemPosition)position paused:(bool)paused offset:(CGFloat)offset duration:(CGFloat)duration albumArt:(SSignal *)albumArt albumArtSync:(SSignal *)albumArtSync downloadedStatus:(TGMusicPlayerDownloadingStatus)downloadedStatus
{
    self = [super init];
    if (self != nil)
    {
        _item = item;
        _position = position;
        _paused = paused;
        _offset = offset;
        _duration = duration;
        _timestamp = CACurrentMediaTime();
        _albumArt = albumArt;
        _albumArtSync = albumArtSync;
        _downloadedStatus = downloadedStatus;
    }
    return self;
}

@end

@interface TGMusicPlayer () <AVAudioPlayerDelegate>
{
    bool _initialized;
    SQueue *_queue;
    
    AVPlayer *_player;
    AVPlayerItem *_currentItem;
    
    STimer *_updateTimer;
    
    SPipe *_playingStatusPipe;
    TGMusicPlayerStatus *_currentStatus;
    SMetaDisposable *_currentItemDisposable;
    TGMusicPlayerItem *_currentNextItem;
    SMetaDisposable *_nextItemDisposable;
    
    SMetaDisposable *_currentAudioSession;
    SMetaDisposable *_currentRemoteControls;
    
    TGObserverProxy *_didPlayToEndObserver;
    SMetaDisposable *_currentAlbumArtDisposable;
    
    SMulticastSignalManager *_albumArtMulticastManager;
    SMetaDisposable *_playlistDisposable;
    TGMusicPlayerPlaylist *_currentPlaylist;
    
    id<SDisposable> _routeChangeDisposable;
}

@end

@implementation TGMusicPlayer

- (instancetype)init
{
    self = [super init];
    if (self != nil)
    {
        _playingStatusPipe = [[SPipe alloc] init];
        _queue = [[SQueue alloc] init];
        _albumArtMulticastManager = [[SMulticastSignalManager alloc] init];
        _currentAudioSession = [[SMetaDisposable alloc] init];
        _currentRemoteControls = [[SMetaDisposable alloc] init];
        
        __weak TGMusicPlayer *weakSelf = self;
        _routeChangeDisposable = [[[TGAudioSessionManager routeChange] deliverOn:_queue] startWithNext:^(id next)
        {
            __strong TGMusicPlayer *strongSelf = weakSelf;
            if (strongSelf != nil)
            {
                [strongSelf->_queue dispatch:^
                {
                    if ([next intValue] == TGAudioSessionRouteChangePause)
                        [strongSelf controlPause];
                    else
                    {
                        if (strongSelf->_currentStatus.item != nil && !strongSelf->_currentStatus.paused)
                        {
                            [strongSelf->_player pause];
                            [strongSelf->_player play];
                        }
                    }
                }];
            }
        }];
    }
    return self;
}

- (void)dealloc
{
    [_currentAudioSession dispose];
    [_currentRemoteControls dispose];
    [_routeChangeDisposable dispose];
}

- (SSignal *)currentStatusAsync
{
    __weak TGMusicPlayer *weakSelf = self;
    return [[SSignal alloc] initWithGenerator:^id<SDisposable>(SSubscriber *subscriber)
    {
        __strong TGMusicPlayer *strongSelf = weakSelf;
        if (strongSelf != nil)
        {
            [strongSelf->_queue dispatch:^
            {
                [subscriber putNext:strongSelf->_currentStatus];
                [subscriber putCompletion];
            }];
        }
        return nil;
    }];
}

- (SSignal *)playingStatus
{
    return [[[self currentStatusAsync] then:_playingStatusPipe.signalProducer()] deliverOn:[SQueue mainQueue]];
}

- (void)requestAudioSessionWithPlay:(bool)play
{
    [_queue dispatch:^
    {
        __weak TGMusicPlayer *weakSelf = self;
        [_currentAudioSession setDisposable:[[TGAudioSessionManager instance] requestSessionWithType:TGAudioSessionTypePlayMusic interrupted:^
        {
            __strong TGMusicPlayer *strongSelf = weakSelf;
            if (strongSelf != nil)
                [strongSelf pauseMedia];
        }]];

        [_currentRemoteControls setDisposable:[[TGRemoteControlsManager instance] requestControlsWithPrevious:^
        {
            __strong TGMusicPlayer *strongSelf = weakSelf;
            if (strongSelf != nil)
                [strongSelf controlPrevious];
        } next:^
        {
            __strong TGMusicPlayer *strongSelf = weakSelf;
            if (strongSelf != nil)
                [strongSelf controlNext];
        } play:play ? ^
        {
            __strong TGMusicPlayer *strongSelf = weakSelf;
            if (strongSelf != nil)
                [strongSelf controlPlay];
        } : nil pause: !play ? ^
        {
            __strong TGMusicPlayer *strongSelf = weakSelf;
            if (strongSelf != nil)
                [strongSelf controlPause];
        } : nil]];
    }];
}

- (void)cancelAudioSessionRequest
{
    [_queue dispatch:^
    {
        [_currentAudioSession setDisposable:nil];
        [_currentRemoteControls setDisposable:nil];
    }];
}

- (void)pauseMedia
{
    [_queue dispatch:^
    {
        if (_currentStatus != nil && !_currentStatus.paused)
        {
            [_updateTimer invalidate];
            _updateTimer = nil;
            
            CGFloat duration = (CGFloat)CMTimeGetSeconds(_player.currentItem.duration);
            CGFloat position = (CGFloat)CMTimeGetSeconds(_player.currentItem.currentTime);
            CGFloat offset = 0.0f;
            if (duration != duration || duration < FLT_EPSILON)
                duration = [[TGMusicPlayer attributesForItem:_currentStatus.item][@"duration"] intValue];
            if (!isnan(duration) && duration > FLT_EPSILON)
            {
                if (!isnan(position) && position > FLT_EPSILON)
                    offset = position / duration;
                else
                    offset = 0.0f;
            }
            else
                duration = 0.0f;
            
            [self setCurrentStatus:[[TGMusicPlayerStatus alloc] initWithItem:_currentStatus.item position:_currentStatus.position paused:true offset:offset duration:duration albumArt:_currentStatus.albumArt albumArtSync:_currentStatus.albumArtSync downloadedStatus:_currentStatus.downloadedStatus]];
        }
        
        [_player pause];
    }];
}

- (CGFloat)updatePositionTimerTimeout
{
    return 0.2f;
}

- (void)startUpdatePositionTimer
{
    [_updateTimer invalidate];
    
    __weak TGMusicPlayer *weakSelf = self;
    _updateTimer = [[STimer alloc] initWithTimeout:[self updatePositionTimerTimeout] repeat:true completion:^
    {
        __strong TGMusicPlayer *strongSelf = weakSelf;
        if (strongSelf != nil)
            [strongSelf updateScrubbingPosition];
    } queue:_queue];
    [_updateTimer start];
}

- (void)playMediaFromItem:(TGMusicPlayerItem *)item
{
    [_queue dispatch:^
    {
        if (_currentStatus != nil && [_currentStatus.item.key isEqual:item.key])
        {
            if (_currentStatus.downloadedStatus.downloaded)
            {
                if (_currentStatus.paused)
                {
                    CGFloat duration = (CGFloat)CMTimeGetSeconds(_player.currentItem.duration);
                    CGFloat position = (CGFloat)CMTimeGetSeconds(_player.currentItem.currentTime);
                    CGFloat offset = 0.0f;
                    if (duration != duration || duration < FLT_EPSILON)
                        duration = [[TGMusicPlayer attributesForItem:item][@"duration"] intValue];
                    if (!isnan(duration) && duration > FLT_EPSILON)
                    {
                        if (!isnan(position) && position > FLT_EPSILON)
                            offset = position / duration;
                        else
                            offset = 0.0f;
                    }
                    else
                        duration = 0.0f;
                    
                    [self setCurrentStatus:[[TGMusicPlayerStatus alloc] initWithItem:_currentStatus.item position:_currentStatus.position paused:false offset:offset duration:duration albumArt:_currentStatus.albumArt albumArtSync:_currentStatus.albumArtSync downloadedStatus:_currentStatus.downloadedStatus]];
                    
                    [self requestAudioSessionWithPlay:false];
                    [_player play];
                    
                    [self startUpdatePositionTimer];
                }
                else
                {
                    [_updateTimer invalidate];
                    _updateTimer = nil;
                    
                    CGFloat duration = (CGFloat)CMTimeGetSeconds(_player.currentItem.duration);
                    CGFloat position = (CGFloat)CMTimeGetSeconds(_player.currentItem.currentTime);
                    CGFloat offset = 0.0f;
                    if (duration != duration || duration < FLT_EPSILON)
                        duration = [[TGMusicPlayer attributesForItem:item][@"duration"] intValue];
                    if (!isnan(duration) && duration > FLT_EPSILON)
                    {
                        if (!isnan(position) && position > FLT_EPSILON)
                            offset = position / duration;
                        else
                            offset = 0.0f;
                    }
                    else
                        duration = 0.0f;
                    
                    [self setCurrentStatus:[[TGMusicPlayerStatus alloc] initWithItem:_currentStatus.item position:_currentStatus.position paused:true offset:offset duration:duration albumArt:_currentStatus.albumArt albumArtSync:_currentStatus.albumArtSync downloadedStatus:_currentStatus.downloadedStatus]];
                    
                    [self requestAudioSessionWithPlay:true];
                    [_player pause];
                }
            }
        }
        else
        {
            [_player pause];
            [_player removeObserver:self forKeyPath:@"rate" context:nil];
            _player = nil;
            [_updateTimer invalidate];
            _updateTimer = nil;
            
            if (item == nil)
            {
                [_currentItemDisposable setDisposable:nil];
                [self cancelAudioSessionRequest];
                [self setCurrentStatus:nil];
                [self updateNextItemAvailability];
            }
            else
            {
                __weak TGMusicPlayer *weakSelf = self;
                
                CGFloat duration = [[TGMusicPlayer attributesForItem:item][@"duration"] intValue];
                TGMusicPlayerItemPosition itemPosition = [TGMusicPlayer itemPosition:item inArray:_currentPlaylist.items];
                
                [_nextItemDisposable setDisposable:nil];
                
                if (_currentItemDisposable == nil)
                    _currentItemDisposable = [[SMetaDisposable alloc] init];
                [_currentItemDisposable setDisposable:[[[TGMusicPlayerItemSignals itemAvailability:item priority:true] deliverOn:_queue] startWithNext:^(id next)
                {
                    TGMusicPlayerItemAvailability availability = TGMusicPlayerItemAvailabilityUnpack([next longLongValue]);
                    __strong TGMusicPlayer *strongSelf = weakSelf;
                    if (strongSelf != nil)
                    {
                        if (availability.downloaded)
                        {
                            if (strongSelf->_player == nil)
                                [strongSelf playItem:item];
                        }
                        else
                        {
                            [strongSelf setCurrentStatus:[[TGMusicPlayerStatus alloc] initWithItem:item position:itemPosition paused:true offset:0.0f duration:duration albumArt:nil albumArtSync:nil downloadedStatus:TGMusicPlayerDownloadingStatusMake(false, availability.downloading, availability.progress)]];
                        }
                    }
                }]];
                
                [self updateNextItemAvailability];
            }
        }
    }];
}

- (void)playItem:(TGMusicPlayerItem *)item
{
    NSString *path = [TGMusicPlayerItemSignals pathForItem:item];
    if ([path pathExtension].length == 0)
    {
        [[NSFileManager defaultManager] createSymbolicLinkAtPath:[path stringByAppendingString:@".mp3"] withDestinationPath:path error:nil];
        path = [path stringByAppendingString:@".mp3"];
    }
    _player = [AVPlayer playerWithURL:[NSURL fileURLWithPath:path]];
    _player.actionAtItemEnd = AVPlayerActionAtItemEndNone;
    [_player addObserver:self forKeyPath:@"rate" options:NSKeyValueObservingOptionNew context:nil];
    
    CGFloat duration = (CGFloat)CMTimeGetSeconds(_player.currentItem.duration);
    CGFloat position = (CGFloat)CMTimeGetSeconds(_player.currentItem.currentTime);
    CGFloat offset = 0.0f;
    
    if (isnan(duration) || duration < FLT_EPSILON)
        duration = [[TGMusicPlayer attributesForItem:item][@"duration"] intValue];
    
    if (!isnan(duration) && duration > FLT_EPSILON)
    {
        if (!isnan(position) && position > FLT_EPSILON)
            offset = position / duration;
        else
            offset = 0.0f;
    }
    else
        duration = 0.0f;
    
    NSURL *itemUrl = [NSURL fileURLWithPath:path];
    TGMusicPlayerItemPosition itemPosition = [TGMusicPlayer itemPosition:item inArray:_currentPlaylist.items];
    [self setCurrentStatus:[[TGMusicPlayerStatus alloc] initWithItem:item position:itemPosition paused:false offset:offset duration:duration albumArt:[TGMusicPlayer albumArtForUrl:itemUrl multicastManager:_albumArtMulticastManager] albumArtSync:[TGMusicPlayer albumArtSyncForUrl:itemUrl] downloadedStatus:TGMusicPlayerDownloadingStatusMake(true, false, 1.0f)]];
    
    _didPlayToEndObserver = [[TGObserverProxy alloc] initWithTarget:self targetSelector:@selector(playerItemDidPlayToEndTime:) name:AVPlayerItemDidPlayToEndTimeNotification object:[_player currentItem]];
    [self requestAudioSessionWithPlay:false];
    [_player play];
    
    [self startUpdatePositionTimer];
}

- (void)updateNextItemAvailability
{
    TGMusicPlayerItem *nextItem = nil;
    
    if (_currentStatus.item != nil)
    {
        NSInteger index = -1;
        for (TGMusicPlayerItem *item in _currentPlaylist.items)
        {
            index++;
            if (TGObjectCompare(_currentStatus.item.key, item.key))
            {
                if (index + 1 < (NSInteger)_currentPlaylist.items.count)
                    nextItem = _currentPlaylist.items[index + 1];
                break;
            }
        }
    }
    
    if (!TGObjectCompare(nextItem.key, _currentNextItem.key))
    {
        _currentNextItem = nextItem;
        
        if (_currentNextItem != nil)
        {
            if (_nextItemDisposable == nil)
                _nextItemDisposable = [[SMetaDisposable alloc] init];
            
            [_nextItemDisposable setDisposable:nil];
            [_nextItemDisposable setDisposable:[[[TGMusicPlayerItemSignals itemAvailability:_currentNextItem priority:false] deliverOn:_queue] startWithNext:^(__unused id next)
            {
                
            }]];
        }
        else
            [_nextItemDisposable setDisposable:nil];
    }
}

+ (TGMusicPlayerItemPosition)itemPosition:(TGMusicPlayerItem *)item inArray:(NSArray *)array
{
    NSInteger index = -1;
    for (TGMusicPlayerItem *listItem in array)
    {
        index++;
        if (TGObjectCompare(listItem.key, item.key))
            return (TGMusicPlayerItemPosition){.index = (NSUInteger)index, .count = array.count};
    }
    return (TGMusicPlayerItemPosition){.index = 0, .count = 1};
}

- (void)setPlaylist:(SSignal *)playlist initialItemKey:(id<NSObject, NSCopying>)initialItemKey
{
    [_queue dispatch:^
    {
        if (_playlistDisposable == nil)
            _playlistDisposable = [[SMetaDisposable alloc] init];
        [_playlistDisposable setDisposable:nil];
        
        if (playlist == nil)
            [self _setPlaylist:nil initialItemKey:nil forceRestart:true];
        else
        {
            __weak TGMusicPlayer *weakSelf = self;
            id<SDisposable> delayedSwitchItemDisposable = [[[[SSignal complete] onStart:^
            {
                __strong TGMusicPlayer *strongSelf = weakSelf;
                if (strongSelf != nil)
                    [strongSelf playMediaFromItem:nil];
            }] delay:1.0 onQueue:_queue] startWithNext:nil];
            __block bool firstValue = true;
            [_playlistDisposable setDisposable:[[playlist deliverOn:_queue] startWithNext:^(TGMusicPlayerPlaylist *value)
            {
                [delayedSwitchItemDisposable dispose];
                
                __strong TGMusicPlayer *strongSelf = weakSelf;
                if (strongSelf != nil)
                {
                    [strongSelf _setPlaylist:value initialItemKey:initialItemKey forceRestart:firstValue];
                    firstValue = false;
                }
            }]];
        }
    }];
}

- (void)_setPlaylist:(TGMusicPlayerPlaylist *)playlist initialItemKey:(id<NSCopying>)initialItemKey forceRestart:(bool)forceRestart
{
    [_queue dispatch:^
    {
        if (!TGObjectCompare(_currentPlaylist, playlist))
        {
            _currentPlaylist = playlist;
            
            if (_currentPlaylist == nil || _currentPlaylist.items.count == 0)
                [self playMediaFromItem:nil];
            else
            {
                bool currentItemFound = false;
                if (!forceRestart && _currentStatus != nil)
                {
                    for (TGMusicPlayerItem *item in _currentPlaylist.items)
                    {
                        if ([item.key isEqual:_currentStatus.item.key])
                        {
                            TGMusicPlayerItemPosition itemPosition = [TGMusicPlayer itemPosition:item inArray:_currentPlaylist.items];
                            
                            [self setCurrentStatus:[[TGMusicPlayerStatus alloc] initWithItem:item position:itemPosition paused:_currentStatus.paused offset:_currentStatus.offset duration:_currentStatus.duration albumArt:_currentStatus.albumArt albumArtSync:_currentStatus.albumArtSync downloadedStatus:_currentStatus.downloadedStatus]];
                            
                            currentItemFound = true;
                            break;
                        }
                    }
                    
                    if (!currentItemFound)
                    {
                        id<NSObject, NSCopying> aliasKey = _currentPlaylist.itemKeyAliases[_currentStatus.item.key];
                        if (aliasKey != nil)
                        {
                            for (TGMusicPlayerItem *item in _currentPlaylist.items)
                            {
                                if ([aliasKey isEqual:_currentStatus.item.key])
                                {
                                    TGMusicPlayerItemPosition itemPosition = [TGMusicPlayer itemPosition:item inArray:_currentPlaylist.items];
                                    
                                    [self setCurrentStatus:[[TGMusicPlayerStatus alloc] initWithItem:item position:itemPosition paused:_currentStatus.paused offset:_currentStatus.offset duration:_currentStatus.duration albumArt:_currentStatus.albumArt albumArtSync:_currentStatus.albumArtSync downloadedStatus:_currentStatus.downloadedStatus]];
                                    
                                    currentItemFound = true;
                                    break;
                                }
                            }
                        }
                    }
                }
                
                if (!currentItemFound && initialItemKey != nil)
                {
                    for (TGMusicPlayerItem *item in _currentPlaylist.items)
                    {
                        if ([item.key isEqual:initialItemKey])
                        {
                            [self playMediaFromItem:item];
                            currentItemFound = true;
                            break;
                        }
                    }
                }
                
                if (!currentItemFound)
                    [self playMediaFromItem:_currentPlaylist.items.firstObject];
            }
            
            [self updateNextItemAvailability];
        }
    }];
}

- (void)controlPlay
{
    [_queue dispatch:^
    {
        if (_currentStatus != nil && _currentStatus.paused)
            [self playMediaFromItem:_currentStatus.item];
    }];
}

- (void)controlPause
{
    [_queue dispatch:^
    {
        if (_currentStatus != nil && !_currentStatus.paused)
            [self playMediaFromItem:_currentStatus.item];
    }];
}

- (void)controlAdvance:(bool)forward
{
    [_queue dispatch:^
    {
        if (_currentPlaylist.items.count != 0)
        {
            if (_currentStatus.item != nil)
            {
                NSInteger index = -1;
                for (TGMusicPlayerItem *item in _currentPlaylist.items)
                {
                    index++;
                    
                    if (TGObjectCompare(item.key, _currentStatus.item.key))
                    {
                        NSInteger nextIndex = 0;
                        if (forward)
                        {
                            nextIndex = index + 1;
                            if (nextIndex >= (NSInteger)_currentPlaylist.items.count)
                                nextIndex = 0;
                        }
                        else
                        {
                            if (_currentStatus.duration == _currentStatus.duration && _currentStatus.duration > FLT_EPSILON && _currentStatus.offset * _currentStatus.duration > 5.0)
                            {
                                nextIndex = index;
                            }
                            else
                            {
                                nextIndex = index - 1;
                                if (nextIndex < 0)
                                    nextIndex = _currentPlaylist.items.count - 1;
                            }
                        }
                        
                        if (nextIndex == index)
                        {
                            [self _seekToPosition:0.0];
                            [self controlPlay];
                        }
                        else
                            [self playMediaFromItem:_currentPlaylist.items[nextIndex]];
                        break;
                    }
                }
            }
            else
                [self playMediaFromItem:_currentPlaylist.items.firstObject];
        }
    }];
}

- (void)controlNext
{
    [self controlAdvance:true];
}

- (void)controlPrevious
{
    [self controlAdvance:false];
}

- (void)controlSeekToPosition:(CGFloat)position
{
    [_queue dispatch:^
    {
        CGFloat duration = (CGFloat)CMTimeGetSeconds(_player.currentItem.duration);
        if (!isnan(duration) && duration > FLT_EPSILON)
            [self _seekToPosition:duration * position];
    }];
}

- (void)setCurrentStatus:(TGMusicPlayerStatus *)currentStatus
{
    TGMusicPlayerStatus *previousStatus = _currentStatus;
    _currentStatus = currentStatus;
    _playingStatusPipe.sink(currentStatus);
    
    if (!TGObjectCompare(currentStatus.item.key, previousStatus.item.key))
    {
        if (currentStatus.item == nil)
        {
            [_currentAlbumArtDisposable dispose];
            [[MPNowPlayingInfoCenter defaultCenter] setNowPlayingInfo:nil];
        }
        else
        {
            NSDictionary *attributes = [TGMusicPlayer attributesForItem:currentStatus.item];
            
            if (_currentAlbumArtDisposable == nil)
                _currentAlbumArtDisposable = [[SMetaDisposable alloc] init];
            
            NSString *path = [TGMusicPlayerItemSignals pathForItem:currentStatus.item];
            [_currentAlbumArtDisposable setDisposable:[[[[SSignal single:nil] then:[TGMusicPlayer albumArtForUrl:[NSURL fileURLWithPath:path] multicastManager:_albumArtMulticastManager]] deliverOn:[SQueue mainQueue]] startWithNext:^(UIImage *image)
            {
                NSMutableDictionary *songInfo = [[NSMutableDictionary alloc] init];
                
                if (image != nil)
                {
                    MPMediaItemArtwork *albumArt = [[MPMediaItemArtwork alloc] initWithImage:image];
                    [songInfo setObject:albumArt forKey:MPMediaItemPropertyArtwork];
                }
                
                NSString *title = @"";
                NSString *performer = @"";
                
                if (attributes[@"title"] != nil)
                    title = attributes[@"title"];
                if (attributes[@"performer"] != nil)
                    performer = attributes[@"performer"];
                
                if (title.length == 0)
                {
                    title = currentStatus.item.document.fileName;
                    if (title.length == 0)
                        title = @"Unknown Track";
                }
                
                if (performer.length == 0)
                    performer = @"Unknown Artist";
                
                [songInfo setObject:title forKey:MPMediaItemPropertyTitle];
                [songInfo setObject:performer forKey:MPMediaItemPropertyArtist];
                
                [[MPNowPlayingInfoCenter defaultCenter] setNowPlayingInfo:songInfo];
            }]];
        }
    }
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)__unused change context:(void *)__unused context
{
    if (object == _player && [keyPath isEqualToString:@"rate"])
    {
        /*if (_player.rate > FLT_EPSILON)
            [_scrubberView setIsPlaying:true];
        else
            [_scrubberView setIsPlaying:false];*/
    }
}

- (void)_seekToPosition:(NSTimeInterval)position
{
    [_queue dispatch:^
    {
        CMTime targetTime = CMTimeMakeWithSeconds(position, NSEC_PER_SEC);
        [_player.currentItem seekToTime:targetTime toleranceBefore:kCMTimeZero toleranceAfter:kCMTimeZero];
    }];
}

- (void)updateScrubbingPosition
{
    if (_player != nil)
    {
        CGFloat duration = (CGFloat)CMTimeGetSeconds(_player.currentItem.duration);
        CGFloat position = (CGFloat)CMTimeGetSeconds(_player.currentItem.currentTime);
        CGFloat offset = 0.0f;
        if (duration != duration || duration < FLT_EPSILON)
            duration = [[TGMusicPlayer attributesForItem:_currentStatus.item][@"duration"] intValue];
        if (!isnan(duration) && duration > FLT_EPSILON)
        {
            if (!isnan(position) && position > FLT_EPSILON)
                offset = position / duration;
            else
                offset = 0.0f;
        }
        
        [self setCurrentStatus:[[TGMusicPlayerStatus alloc] initWithItem:_currentStatus.item position:_currentStatus.position paused:false offset:offset duration:duration albumArt:_currentStatus.albumArt albumArtSync:_currentStatus.albumArtSync downloadedStatus:_currentStatus.downloadedStatus]];
    }
}

- (void)playerItemDidPlayToEndTime:(NSNotification *)__unused notification
{
    [_queue dispatch:^
    {
        if (_currentStatus.item != nil)
        {
            NSInteger index = -1;
            for (TGMusicPlayerItem *item in _currentPlaylist.items)
            {
                index++;
                if (TGObjectCompare(item.key, _currentStatus.item.key))
                {
                    if (index == (NSInteger)_currentPlaylist.items.count - 1)
                    {
                        [self _seekToPosition:0.0f];
                        
                        [_player pause];
                        
                        [_updateTimer invalidate];
                        _updateTimer = nil;
                        
                        CGFloat duration = (CGFloat)CMTimeGetSeconds(_player.currentItem.duration);
                        if (isnan(duration) || duration < FLT_EPSILON)
                            duration = 0.0f;
                        
                        [self setCurrentStatus:[[TGMusicPlayerStatus alloc] initWithItem:_currentStatus.item position:_currentStatus.position paused:true offset:0.0f duration:duration albumArt:_currentStatus.albumArt albumArtSync:_currentStatus.albumArtSync downloadedStatus:_currentStatus.downloadedStatus]];
                        
                        [self requestAudioSessionWithPlay:true];
                    }
                    else
                        [self controlAdvance:true];
                    break;
                }
            }
        }
    }];
}

+ (SSignal *)albumArtSyncForUrl:(NSURL *)url
{
    return [[[SSignal alloc] initWithGenerator:^id<SDisposable>(SSubscriber *subscriber)
    {
        AVAsset *asset = [AVURLAsset URLAssetWithURL:url options:nil];
        if (asset == nil)
            [subscriber putError:nil];
        
        NSArray *artworks = [AVMetadataItem metadataItemsFromArray:asset.commonMetadata withKey:AVMetadataCommonKeyArtwork keySpace:AVMetadataKeySpaceCommon];
        if (artworks == nil)
            [subscriber putError:nil];
        else
        {
            UIImage *image = nil;
            for (AVMetadataItem *item in artworks)
            {
                if ([item.keySpace isEqualToString:AVMetadataKeySpaceID3])
                {
                    if ([item.value respondsToSelector:@selector(objectForKey:)])
                        image = [UIImage imageWithData:[(id)item.value objectForKey:@"data"]];
                    else if ([item.value isKindOfClass:[NSData class]])
                        image = [UIImage imageWithData:(id)item.value];
                }
                else if ([item.keySpace isEqualToString:AVMetadataKeySpaceiTunes])
                    image = [UIImage imageWithData:(id)item.value];
            }
            
            if (image != nil)
            {
                CGSize screenSize = TGScreenSize();
                CGFloat screenSide = MIN(screenSize.width, screenSize.height);
                CGFloat scale = TGIsRetina() ? 1.7f : 1.0f;
                CGSize pixelSize = CGSizeMake(screenSide * scale, screenSide * scale);
                image = TGScaleImageToPixelSize(image, TGFitSize(CGSizeMake(image.size.width * image.scale, image.size.height * image.scale), pixelSize));
                [subscriber putNext:image];
                [subscriber putCompletion];
            }
            else
                [subscriber putError:nil];
        }
        
        return nil;
    }] catch:^SSignal *(__unused id error)
    {
        return [self albumArtForUrl:url multicastManager:nil];
    }];
}

+ (SSignal *)albumArtForUrl:(NSURL *)url multicastManager:(SMulticastSignalManager *)__unused multicastManager
{
    /*return [multicastManager multicastedSignalForKey:url.absoluteString producer:^SSignal *
    {*/
        return [[SSignal alloc] initWithGenerator:^id<SDisposable>(SSubscriber *subscriber)
        {
            __block bool cancelled = false;
            
            AVAsset *asset = [AVURLAsset URLAssetWithURL:url options:nil];
            if (asset == nil)
                [subscriber putError:nil];
            else
            {
                [asset loadValuesAsynchronouslyForKeys:@[@"commonMetadata"] completionHandler:^
                {
                    if (cancelled)
                        return;
                    
                    NSArray *artworks = [AVMetadataItem metadataItemsFromArray:asset.commonMetadata withKey:AVMetadataCommonKeyArtwork keySpace:AVMetadataKeySpaceCommon];
                    
                    UIImage *image = nil;
                    for (AVMetadataItem *item in artworks)
                    {
                        if ([item.keySpace isEqualToString:AVMetadataKeySpaceID3])
                        {
                            if ([item.value respondsToSelector:@selector(objectForKey:)])
                                image = [UIImage imageWithData:[(id)item.value objectForKey:@"data"]];
                            else if ([item.value isKindOfClass:[NSData class]])
                                image = [UIImage imageWithData:(id)item.value];
                        }
                        else if ([item.keySpace isEqualToString:AVMetadataKeySpaceiTunes])
                            image = [UIImage imageWithData:(id)item.value];
                    }
                    
                    if (image != nil)
                    {
                        CGSize screenSize = TGScreenSize();
                        CGFloat screenSide = MIN(screenSize.width, screenSize.height);
                        CGFloat scale = TGIsRetina() ? 1.7f : 1.0f;
                        CGSize pixelSize = CGSizeMake(screenSide * scale, screenSide * scale);
                        image = TGScaleImageToPixelSize(image, TGFitSize(CGSizeMake(image.size.width * image.scale, image.size.height * image.scale), pixelSize));
                        [subscriber putNext:image];
                        [subscriber putCompletion];
                    }
                    else
                    {
                        [subscriber putError:nil];
                    }
                }];
            }
            
            return [[SBlockDisposable alloc] initWithBlock:^
            {
                cancelled = true;
            }];
        }];
    //}];
}

+ (NSDictionary *)attributesForItem:(TGMusicPlayerItem *)item
{
    for (id attribute in item.document.attributes)
    {
        if ([attribute isKindOfClass:[TGDocumentAttributeAudio class]])
        {
            TGDocumentAttributeAudio *audioAttribute = attribute;
            NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
            if (audioAttribute.title != nil)
                dict[@"title"] = audioAttribute.title;
            if (audioAttribute.performer != nil)
                dict[@"performer"] = audioAttribute.performer;
            dict[@"duration"] = @(audioAttribute.duration);
            
            return dict;
        }
    }
    
    return @{};
}

@end
