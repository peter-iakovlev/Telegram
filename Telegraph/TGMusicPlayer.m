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

#import "TGModernConversationAudioPlayer.h"

#import "TGAppDelegate.h"

static TGMusicPlayerDownloadingStatus TGMusicPlayerDownloadingStatusMake(bool downloaded, bool downloading, CGFloat progress)
{
    return (TGMusicPlayerDownloadingStatus){.downloaded = downloaded, .downloading = downloading, .progress = progress};
}

@interface TGMusicPlayerStatus ()

@end

@implementation TGMusicPlayerStatus

- (instancetype)initWithItem:(TGMusicPlayerItem *)item player:(TGAudioPlayer *)player position:(TGMusicPlayerItemPosition)position paused:(bool)paused offset:(CGFloat)offset duration:(CGFloat)duration albumArt:(SSignal *)albumArt albumArtSync:(SSignal *)albumArtSync downloadedStatus:(TGMusicPlayerDownloadingStatus)downloadedStatus isVoice:(bool)isVoice shuffle:(bool)shuffle repeatType:(TGMusicPlayerRepeatType)repeatType
{
    self = [super init];
    if (self != nil)
    {
        _item = item;
        _player = player;
        _position = position;
        _paused = paused;
        _offset = offset;
        _duration = duration;
        _timestamp = CACurrentMediaTime();
        _albumArt = albumArt;
        _albumArtSync = albumArtSync;
        _downloadedStatus = downloadedStatus;
        _isVoice = isVoice;
        _shuffle = shuffle;
        _repeatType = repeatType;
    }
    return self;
}

@end

@interface TGMusicPlayer () <TGModernConversationAudioPlayerDelegate>
{
    bool _initialized;
    SQueue *_queue;
    
    TGModernConversationAudioPlayer *_player;
    
    STimer *_updateTimer;
    
    SPipe *_playingStatusPipe;
    SPipe *_playlistFinishedPipe;
    TGMusicPlayerStatus *_currentStatus;
    SMetaDisposable *_currentItemDisposable;
    TGMusicPlayerItem *_currentNextItem;
    SMetaDisposable *_nextItemDisposable;
    
    SMetaDisposable *_currentAudioSession;
    SMetaDisposable *_currentRemoteControls;
    
    SMetaDisposable *_currentAlbumArtDisposable;
    
    SMulticastSignalManager *_albumArtMulticastManager;
    
    SMetaDisposable *_currentPlaylistDisposable;
    TGMusicPlayerPlaylist *_currentPlaylist;
    
    TGMusicPlayerPlaylist *_currentTemporaryPlaylist;
    
    id<SDisposable> _routeChangeDisposable;
    TGHolder *_proximityChangeHolder;
    TGObserverProxy *_proximityChangedNotification;
    bool _proximityState;
    bool _changingProximity;
}

@end

@implementation TGMusicPlayer

@synthesize playlistMetadata = _playlistMetadata;

- (instancetype)init
{
    self = [super init];
    if (self != nil)
    {
        _playingStatusPipe = [[SPipe alloc] init];
        _playlistFinishedPipe = [[SPipe alloc] init];
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
                    if (!strongSelf->_changingProximity) {
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
                    }
                }];
            }
        }];
        
        _proximityChangedNotification = [[TGObserverProxy alloc] initWithTarget:self targetSelector:@selector(proximityChanged:) name:TGDeviceProximityStateChangedNotification object:nil];
        _proximityChangeHolder = [[TGHolder alloc] init];
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

- (SSignal *)playlistFinished {
    return _playlistFinishedPipe.signalProducer();
}

- (void)updateAudioSession {
    [_queue dispatch:^{
        if (_currentPlaylist == nil) {
            [TGAppDelegateInstance.deviceProximityListeners removeHolder:_proximityChangeHolder];
            [_currentAudioSession setDisposable:nil];
        } else {
            __weak TGMusicPlayer *weakSelf = self;
            bool headset = [TGMusicPlayer isHeadsetPluggedIn];
            bool overridePort = _currentPlaylist.voice && _proximityState && !headset;
            if (_currentPlaylist.voice && !headset) {
                [TGAppDelegateInstance.deviceProximityListeners addHolder:_proximityChangeHolder];
            } else {
                [TGAppDelegateInstance.deviceProximityListeners removeHolder:_proximityChangeHolder];
            }
            [_currentAudioSession setDisposable:[[TGAudioSessionManager instance] requestSessionWithType:overridePort ? TGAudioSessionTypePlayAndRecordHeadphones : (_currentPlaylist.voice && !headset ? TGAudioSessionTypePlayAndRecord : TGAudioSessionTypePlayMusic) interrupted:^{
                __strong TGMusicPlayer *strongSelf = weakSelf;
                if (strongSelf != nil && !strongSelf->_changingProximity) {
                    [strongSelf pauseMedia];
                }
            }]];
        }
    }];
}

- (void)requestControlsWithPlay:(bool)play
{
    [_queue dispatch:^
    {
        if (_currentPlaylist.voice || _currentPlaylist == nil) {
            [_currentRemoteControls setDisposable:nil];
        } else {
            __weak TGMusicPlayer *weakSelf = self;
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
                    [strongSelf controlPlayPause];
            } : nil pause: !play ? ^
            {
                __strong TGMusicPlayer *strongSelf = weakSelf;
                if (strongSelf != nil)
                    [strongSelf controlPlayPause];
            } : nil
            position:^(NSTimeInterval position)
            {
                __strong TGMusicPlayer *strongSelf = weakSelf;
                if (strongSelf != nil)
                {
                    NSTimeInterval fracPosition = strongSelf->_player.duration > FLT_EPSILON ? position / strongSelf->_player.duration : 0.0f;
                    [strongSelf controlSeekToPosition:fracPosition];
                }
            }]];
        }
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
            
            CGFloat duration = _player.duration;
            CGFloat position = _player.playbackPosition;
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
            
            [self setCurrentStatus:[[TGMusicPlayerStatus alloc] initWithItem:_currentStatus.item player:_player.audioPlayer position:_currentStatus.position paused:true offset:offset duration:duration albumArt:_currentStatus.albumArt albumArtSync:_currentStatus.albumArtSync downloadedStatus:_currentStatus.downloadedStatus isVoice:_currentStatus.isVoice shuffle:_currentStatus.shuffle repeatType:_currentStatus.repeatType]];
        }
        
        [_player pause:^{
            
        }];
    }];
}

- (CGFloat)updatePositionTimerTimeout
{
    return 10.0 / 60.0f;
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
    [self updateScrubbingPosition];
    [_updateTimer start];
}

- (void)playMediaFromItem:(TGMusicPlayerItem *)item
{
    [self playMediaFromItem:item force:false];
}

- (void)playMediaFromItem:(TGMusicPlayerItem *)item force:(bool)force
{
    [_queue dispatch:^
    {
        if (_currentStatus != nil && [_currentStatus.item.key isEqual:item.key] && !force)
        {
            if (_currentStatus.downloadedStatus.downloaded)
            {
                if (_currentStatus.paused)
                {
                    CGFloat duration = _player.duration;
                    CGFloat position = _player.absolutePlaybackPosition;
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
                    
                    [self setCurrentStatus:[[TGMusicPlayerStatus alloc] initWithItem:_currentStatus.item player:_player.audioPlayer position:_currentStatus.position paused:false offset:offset duration:duration albumArt:_currentStatus.albumArt albumArtSync:_currentStatus.albumArtSync downloadedStatus:_currentStatus.downloadedStatus isVoice:_currentStatus.isVoice shuffle:_currentStatus.shuffle repeatType:_currentStatus.repeatType]];
                    
                    [self requestControlsWithPlay:false];
                    [_player play];
                    
                    [self startUpdatePositionTimer];
                }
                else
                {
                    [_updateTimer invalidate];
                    _updateTimer = nil;
                    
                    CGFloat duration = _player.duration;
                    CGFloat position = (CGFloat)_player.absolutePlaybackPosition;
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
                    
                    [self setCurrentStatus:[[TGMusicPlayerStatus alloc] initWithItem:_currentStatus.item player:_player.audioPlayer position:_currentStatus.position paused:true offset:offset duration:duration albumArt:_currentStatus.albumArt albumArtSync:_currentStatus.albumArtSync downloadedStatus:_currentStatus.downloadedStatus isVoice:_currentStatus.isVoice shuffle:_currentStatus.shuffle repeatType:_currentStatus.repeatType]];
                    
                    if (_player != nil) {
                        [_player pause:^{
                            [self requestControlsWithPlay:true];
                        }];
                    } else {
                        [self requestControlsWithPlay:true];
                    }
                }
            }
        }
        else
        {
            [_updateTimer invalidate];
            _updateTimer = nil;
            
            if (item == nil)
            {
                [_currentItemDisposable setDisposable:nil];
                [self setCurrentStatus:nil];
                
                if (_player != nil) {
                    [_player pause:^{
                        [self cancelAudioSessionRequest];
                    }];
                } else {
                    [self cancelAudioSessionRequest];
                }
                _player = nil;
                
                [self updateNextItemAvailability];
            }
            else
            {
                [_player stop];
                _player = nil;
                
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
                            [strongSelf setCurrentStatus:[[TGMusicPlayerStatus alloc] initWithItem:item player:_player.audioPlayer position:itemPosition paused:true offset:0.0f duration:duration albumArt:nil albumArtSync:nil downloadedStatus:TGMusicPlayerDownloadingStatusMake(false, availability.downloading, availability.progress) isVoice:item.isVoice shuffle:_currentStatus.shuffle repeatType:_currentStatus.repeatType]];
                        }
                    }
                }]];
                
                [self updateNextItemAvailability];
            }
        }
    }];
}

- (bool)storedShuffleValue
{
    return [[[NSUserDefaults standardUserDefaults] objectForKey:@"musicPlayerShuffle_v1"] boolValue];
}

- (TGMusicPlayerRepeatType)storedRepeatTypeValue
{
    return (TGMusicPlayerRepeatType)[[[NSUserDefaults standardUserDefaults] objectForKey:@"musicPlayerRepeatType_v1"] integerValue];
}

- (void)playItem:(TGMusicPlayerItem *)item
{
    if (_currentPlaylist.markItemAsViewed) {
        _currentPlaylist.markItemAsViewed(item);
    }
    
    NSString *path = [TGMusicPlayerItemSignals pathForItem:item];
    if ([path pathExtension].length == 0)
    {
        if (item.isVideo)
        {
            [[NSFileManager defaultManager] createSymbolicLinkAtPath:[path stringByAppendingString:@".mov"] withDestinationPath:[path lastPathComponent] error:nil];
            path = [path stringByAppendingString:@".mov"];
        }
        else
        {
            [[NSFileManager defaultManager] createSymbolicLinkAtPath:[path stringByAppendingString:@".mp3"] withDestinationPath:[path lastPathComponent] error:nil];
            path = [path stringByAppendingString:@".mp3"];
        }
    }
    _player = [[TGModernConversationAudioPlayer alloc] initWithFilePath:path music:!_currentPlaylist.voice controlAudioSession:false];
    _player.delegate = self;
    
    CGFloat duration = _player.duration;
    CGFloat position = (CGFloat)_player.absolutePlaybackPosition;
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
    
    bool shuffle = [self storedShuffleValue];
    TGMusicPlayerRepeatType repeatType = [self storedRepeatTypeValue];
    
    NSURL *itemUrl = [NSURL fileURLWithPath:path];
    TGMusicPlayerItemPosition itemPosition = [TGMusicPlayer itemPosition:item inArray:_currentPlaylist.items];
    [self setCurrentStatus:[[TGMusicPlayerStatus alloc] initWithItem:item player:_player.audioPlayer position:itemPosition paused:false offset:offset duration:duration albumArt:[TGMusicPlayer albumArtForUrl:itemUrl multicastManager:_albumArtMulticastManager] albumArtSync:[TGMusicPlayer albumArtSyncForUrl:itemUrl] downloadedStatus:TGMusicPlayerDownloadingStatusMake(true, false, 1.0f) isVoice:item.isVoice shuffle:(!item.isVoice && shuffle) repeatType:!item.isVoice ? repeatType : TGMusicPlayerRepeatTypeNone]];
    
    [self requestControlsWithPlay:false];
    [_player play];
    
    [self startUpdatePositionTimer];
}

- (void)updateNextItemAvailability
{
    TGMusicPlayerItem *nextItem = nil;
    
    NSArray *items = (_currentStatus.shuffle ? _currentPlaylist.shuffledItems : _currentPlaylist.items);
    
    if (_currentStatus.item != nil)
    {
        NSInteger index = -1;
        for (TGMusicPlayerItem *item in items)
        {
            index++;
            if (TGObjectCompare(_currentStatus.item.key, item.key))
            {
                if (index + 1 < (NSInteger)items.count)
                    nextItem = items[index + 1];
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

- (id)playlistMetadata {
    id result = nil;
    @synchronized(self) {
        result = _playlistMetadata;
    }
    return result;
}

- (void)setPlaylist:(SSignal *)playlist initialItemKey:(id<NSCopying>)initialItemKey metadata:(id)metadata {
    @synchronized(self) {
        _playlistMetadata = metadata;
    }
    
    [_queue dispatch:^{
        if (_currentPlaylistDisposable == nil)
            _currentPlaylistDisposable = [[SMetaDisposable alloc] init];
        [_currentPlaylistDisposable setDisposable:nil];
        
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
            [_currentPlaylistDisposable setDisposable:[[playlist deliverOn:_queue] startWithNext:^(TGMusicPlayerPlaylist *value)
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
            TGMusicPlayerPlaylist *previousPlaylist = _currentPlaylist;
            bool shuffle = [self storedShuffleValue];
            
            _currentPlaylist = (previousPlaylist.items.count == 0 && shuffle) ? [playlist playlistWithShuffledItems] : playlist;
            if (playlist != nil) {
                [self updateAudioSession];
            }
            
            if (_currentPlaylist == nil || _currentPlaylist.items.count == 0)
                [self playMediaFromItem:nil];
            else
            {
                bool currentItemFound = false;
                id<NSObject> nextItemKey = nil;
                if (!forceRestart && _currentStatus != nil)
                {
                    bool match = false;
                    bool found = false;
                    for (TGMusicPlayerItem *previousItem in previousPlaylist.items)
                    {
                        if ([previousItem.key isEqual:_currentStatus.item.key]) {
                            match = true;
                        }
                        
                        if (match) {
                            for (TGMusicPlayerItem *item in _currentPlaylist.items)
                            {
                                if ([item.key isEqual:_currentStatus.item.key])
                                {
                                    if (shuffle)
                                        _currentPlaylist = [_currentPlaylist playlistWithShuffleFromPlaylist:previousPlaylist currentItem:item];
                                    
                                    TGMusicPlayerItemPosition itemPosition = [TGMusicPlayer itemPosition:item inArray:_currentPlaylist.items];
                                    
                                    [self setCurrentStatus:[[TGMusicPlayerStatus alloc] initWithItem:item player:_player.audioPlayer position:itemPosition paused:_currentStatus.paused offset:_currentStatus.offset duration:_currentStatus.duration albumArt:_currentStatus.albumArt albumArtSync:_currentStatus.albumArtSync downloadedStatus:_currentStatus.downloadedStatus isVoice:_currentStatus.isVoice shuffle:_currentStatus.shuffle repeatType:_currentStatus.repeatType]];
                                    
                                    currentItemFound = true;
                                    found = true;
                                    break;
                                } else if ([item.key isEqual:previousItem.key]) {
                                    nextItemKey = item.key;
                                    found = true;
                                    break;
                                }
                            }
                        }
                        
                        if (found) {
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
                                    if (shuffle)
                                        _currentPlaylist = [_currentPlaylist playlistWithShuffleFromPlaylist:previousPlaylist currentItem:item];
                                    
                                    TGMusicPlayerItemPosition itemPosition = [TGMusicPlayer itemPosition:item inArray:_currentPlaylist.items];
                                    
                                    [self setCurrentStatus:[[TGMusicPlayerStatus alloc] initWithItem:item player:_player.audioPlayer position:itemPosition paused:_currentStatus.paused offset:_currentStatus.offset duration:_currentStatus.duration albumArt:_currentStatus.albumArt albumArtSync:_currentStatus.albumArtSync downloadedStatus:_currentStatus.downloadedStatus isVoice:_currentStatus.isVoice shuffle:_currentStatus.shuffle repeatType:_currentStatus.repeatType]];
                                    
                                    currentItemFound = true;
                                    break;
                                }
                            }
                        }
                    }
                }
                
                if (!currentItemFound) {
                    if (shuffle)
                        _currentPlaylist = [_currentPlaylist playlistWithShuffledItems];
                    
                    if (nextItemKey != nil) {
                        for (TGMusicPlayerItem *item in _currentPlaylist.items)
                        {
                            if ([item.key isEqual:nextItemKey])
                            {
                                [self playMediaFromItem:item];
                                currentItemFound = true;
                                break;
                            }
                        }
                    } else if (initialItemKey != nil) {
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
                }
                
                NSArray *items = shuffle ? _currentPlaylist.shuffledItems : _currentPlaylist.items;
                
                if (!currentItemFound)
                    [self playMediaFromItem:items.firstObject];
            }
            
            [self updateNextItemAvailability];
            
            if (playlist == nil) {
                [self updateAudioSession];
                [_currentRemoteControls setDisposable:nil];
            }
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

- (void)controlPlayPause {
    [_queue dispatch:^ {
        if (_currentStatus != nil) {
            if (_currentStatus.paused) {
                [self playMediaFromItem:_currentStatus.item];
            } else {
                [self playMediaFromItem:_currentStatus.item];
            }
        }
    }];
}

- (void)controlPause {
    [self controlPause:nil];
}

- (void)controlPause:(void (^)())completion
{
    [_queue dispatch:^
    {
        if (_currentStatus != nil && !_currentStatus.paused)
            [self playMediaFromItem:_currentStatus.item];
        if (completion) {
            completion();
        }
    }];
}

- (void)controlAdvance:(bool)forward
{
    [_queue dispatch:^
    {
        NSArray *items = _currentStatus.shuffle ? _currentPlaylist.shuffledItems : _currentPlaylist.items;
        
        if (items.count != 0)
        {
            if (_currentStatus.item != nil)
            {
                NSInteger index = -1;
                for (TGMusicPlayerItem *item in items)
                {
                    index++;
                    
                    if (TGObjectCompare(item.key, _currentStatus.item.key))
                    {
                        NSInteger nextIndex = 0;
                        if (forward)
                        {
                            nextIndex = index + 1;
                            if (nextIndex >= (NSInteger)items.count)
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
                                    nextIndex = items.count - 1;
                            }
                        }
                        
                        if (nextIndex == index)
                        {
                            [self _seekToPosition:0.0];
                            [self controlPlay];
                        }
                        else
                            [self playMediaFromItem:items[nextIndex]];
                        break;
                    }
                }
            }
            else
                [self playMediaFromItem:items.firstObject];
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
        CGFloat duration = _player.duration;
        if (!isnan(duration) && duration > FLT_EPSILON)
            [self _seekToPosition:duration * position];
    }];
}

- (void)_dispatch:(dispatch_block_t)block {
    [_queue dispatch:^{
        if (block) {
            block();
        }
    }];
}

- (void)controlShuffle {
    [_queue dispatch:^{
        bool shuffle = !_currentStatus.shuffle;
        
        [[NSUserDefaults standardUserDefaults] setObject:@(shuffle) forKey:@"musicPlayerShuffle_v1"];
        
        if (shuffle && ![_currentPlaylist hasShuffle])
            [self _setPlaylist:[_currentPlaylist playlistWithShuffledItems] initialItemKey:nil forceRestart:false];
        
        [self setCurrentStatus:[[TGMusicPlayerStatus alloc] initWithItem:_currentStatus.item player:_player.audioPlayer position:_currentStatus.position paused:_currentStatus.paused offset:_currentStatus.offset duration:_currentStatus.duration albumArt:_currentStatus.albumArt albumArtSync:_currentStatus.albumArtSync downloadedStatus:_currentStatus.downloadedStatus isVoice:_currentStatus.isVoice shuffle:shuffle repeatType:_currentStatus.repeatType]];
    }];
}

- (void)controlRepeat {
    [_queue dispatch:^ {
        TGMusicPlayerRepeatType repeatType = _currentStatus.repeatType;
        switch (repeatType) {
            case TGMusicPlayerRepeatTypeNone:
                repeatType = TGMusicPlayerRepeatTypeAll;
                break;
                 
            case TGMusicPlayerRepeatTypeAll:
                repeatType = TGMusicPlayerRepeatTypeOne;
                break;
                 
            default:
                repeatType = TGMusicPlayerRepeatTypeNone;
                break;
        }
        
        [[NSUserDefaults standardUserDefaults] setObject:@(repeatType) forKey:@"musicPlayerRepeatType_v1"];
         
        [self setCurrentStatus:[[TGMusicPlayerStatus alloc] initWithItem:_currentStatus.item player:_player.audioPlayer position:_currentStatus.position paused:_currentStatus.paused offset:_currentStatus.offset duration:_currentStatus.duration albumArt:_currentStatus.albumArt albumArtSync:_currentStatus.albumArtSync downloadedStatus:_currentStatus.downloadedStatus isVoice:_currentStatus.isVoice shuffle:_currentStatus.shuffle repeatType:repeatType]];
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
            
            TGDispatchOnMainThread(^{
                [[MPNowPlayingInfoCenter defaultCenter] setNowPlayingInfo:nil];
            });
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
                    if ([currentStatus.item.media isKindOfClass:[TGDocumentMediaAttachment class]]) {
                        title = ((TGDocumentMediaAttachment *)currentStatus.item.media).fileName;
                        
                        for (id attribute in ((TGDocumentMediaAttachment *)currentStatus.item.media).attributes) {
                            if ([attribute isKindOfClass:[TGDocumentAttributeAudio class]]) {
                                if (((TGDocumentAttributeAudio *)attribute).isVoice) {
                                    title = TGLocalized(@"MusicPlayer.VoiceNote");
                                    performer = @"Telegram";
                                }
                                break;
                            }
                        }
                    }
                }
                
                if (title.length == 0)
                    title = @"Unknown Track";
                
                if (performer.length == 0)
                    performer = @"Unknown Artist";
                
                [songInfo setObject:title forKey:MPMediaItemPropertyTitle];
                [songInfo setObject:performer forKey:MPMediaItemPropertyArtist];
                [songInfo setObject:@1.0f forKey:MPNowPlayingInfoPropertyPlaybackRate];
                [songInfo setObject:@(currentStatus.duration) forKey:MPMediaItemPropertyPlaybackDuration];
                
                [[MPNowPlayingInfoCenter defaultCenter] setNowPlayingInfo:songInfo];
            }]];
        }
    }
}

- (void)_seekToPosition:(NSTimeInterval)position
{
    [_queue dispatch:^
    {
        NSTimeInterval duration = _player.duration;
        
        if (duration > DBL_EPSILON) {
            [_player play:(float)(position / duration)];
            
            NSMutableDictionary *info = [[[MPNowPlayingInfoCenter defaultCenter] nowPlayingInfo] mutableCopy];
            info[MPNowPlayingInfoPropertyElapsedPlaybackTime] = @(position);
            [[MPNowPlayingInfoCenter defaultCenter] setNowPlayingInfo:info];
        }
    }];
}

- (void)updateScrubbingPosition
{
    if (_player != nil)
    {
        CGFloat duration = _player.duration;
        CGFloat position = _player.absolutePlaybackPosition;
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
        
        [self setCurrentStatus:[[TGMusicPlayerStatus alloc] initWithItem:_currentStatus.item player:_player.audioPlayer position:_currentStatus.position paused:false offset:offset duration:duration albumArt:_currentStatus.albumArt albumArtSync:_currentStatus.albumArtSync downloadedStatus:_currentStatus.downloadedStatus isVoice:_currentStatus.isVoice shuffle:_currentStatus.shuffle repeatType:_currentStatus.repeatType]];
    }
}

- (void)audioPlayerDidFinish
{
    [_queue dispatch:^
    {
        if (_currentStatus.item != nil)
        {
            if (_currentStatus.repeatType == TGMusicPlayerRepeatTypeOne)
            {
                [self playMediaFromItem:_currentStatus.item force:true];
            }
            else
            {
                NSInteger index = -1;
                for (TGMusicPlayerItem *item in _currentPlaylist.items)
                {
                    index++;
                    if (TGObjectCompare(item.key, _currentStatus.item.key))
                    {
                        if (index == (NSInteger)_currentPlaylist.items.count - 1)
                        {
                            if (_currentPlaylist.voice) {
                                id metadata = [self playlistMetadata];
                                [self setPlaylist:nil initialItemKey:nil metadata:nil];
								[self requestControlsWithPlay:true];
                                
                                _playlistFinishedPipe.sink(metadata);
                            } else {
                                if (_currentStatus.repeatType == TGMusicPlayerRepeatTypeNone)
                                {
                                    [self _seekToPosition:0.0f];
                                    
                                    if (_player != nil) {
                                	[_player pause:^{
                                    	[self requestControlsWithPlay:true];
                                	}];
                            		} else {
                                		[self requestControlsWithPlay:true];
                            		}
                                    
                                    [_updateTimer invalidate];
                                    _updateTimer = nil;
                                    
                                    CGFloat duration = _player.duration;
                                    if (isnan(duration) || duration < FLT_EPSILON)
                                        duration = 0.0f;
                                    
                                    [self setCurrentStatus:[[TGMusicPlayerStatus alloc] initWithItem:_currentStatus.item player:_player.audioPlayer position:_currentStatus.position paused:true offset:0.0f duration:duration albumArt:_currentStatus.albumArt albumArtSync:_currentStatus.albumArtSync downloadedStatus:_currentStatus.downloadedStatus isVoice:_currentStatus.isVoice shuffle:_currentStatus.shuffle repeatType:_currentStatus.repeatType]];
                                }
                                else
                                {
                                    [self playMediaFromItem:_currentPlaylist.items.firstObject];
                                }
                            }
                        }
                        else
                            [self controlAdvance:true];
                        break;
                    }
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
    NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
    
    if (item.performer.length != 0) {
        dict[@"performer"] = item.performer;
    }
    
    if (item.title.length != 0) {
        dict[@"title"] = item.title;
    }
    
    dict[@"duration"] = @(item.duration);
    
    return dict;
}

+ (bool)isHeadsetPluggedIn
{
    AVAudioSessionRouteDescription* route = [[AVAudioSession sharedInstance] currentRoute];
    for (AVAudioSessionPortDescription *desc in [route outputs])
    {
        if ([[desc portType] isEqualToString:AVAudioSessionPortHeadphones])
            return true;
        if ([[desc portType] isEqualToString:AVAudioSessionPortBluetoothA2DP])
            return true;
    }
    return false;
}

- (void)proximityChanged:(NSNotification *)__unused notification
{
    bool proximityState = TGAppDelegateInstance.deviceProximityState;
    [_queue dispatch:^{
        _proximityState = proximityState;
        if (_currentPlaylist.voice && _currentStatus != nil && ![TGMusicPlayer isHeadsetPluggedIn]) {
            _changingProximity = true;
            [self updateAudioSession];
            _changingProximity = false;
            
            if (_proximityState) {
                if (_currentStatus.paused) {
                    [self controlPlay];
                }
            } else {
                [self controlPause];
            }
        }
    }];
}

@end
