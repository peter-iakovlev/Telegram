#import "TGModernGalleryVideoPlayerView.h"

#import <AVFoundation/AVFoundation.h>
#import <AVKit/AVKit.h>

#import "TGImageUtils.h"
#import "TGObserverProxy.h"
#import "TGTimerTarget.h"

#import "TGImageView.h"
#import "TGModernGalleryVideoView.h"

#import "TGAudioSessionManager.h"
#import "TGEmbedPIPController.h"

#import "TransformImageView.h"

@interface TGModernGalleryVideoPlayerView () <AVPictureInPictureControllerDelegate>
{
    TGImageView *_legacyImageView;
    TransformImageView *_transformImageView;
    
    NSString *_videoPath;
    AVPlayer *_player;
    TGModernGalleryVideoView *_videoView;
    
    NSTimer *_positionTimer;
    NSTimer *_videoFlickerTimer;
    
    TGObserverProxy *_didPlayToEndObserver;
    
    SPipe *_statePipe;
    
    bool _pausedManually;
    bool _shouldResumePIPPlayback;
    
    SMetaDisposable *_currentAudioSession;
    
    AVPictureInPictureController *_systemPIPController;
}
@end

@implementation TGModernGalleryVideoPlayerView

@synthesize requestPictureInPicture = _requestPictureInPicture;
@synthesize disallowPIP = _disallowPIP;
@synthesize initialFrame = _initialFrame;

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self != nil)
    {
        _statePipe = [[SPipe alloc] init];
        _state = [TGModernGalleryVideoPlayerState stateWithPlaying:false duration:0.0 position:0.0];
        
        _legacyImageView = [[TGImageView alloc] init];
        _legacyImageView.contentMode = UIViewContentModeScaleToFill;
        [self addSubview:_legacyImageView];
        
        _transformImageView = [[TransformImageView alloc] init];
        _transformImageView.contentMode = UIViewContentModeScaleToFill;
        [_transformImageView setArguments:[[TransformImageArguments alloc] initWithImageSize:CGSizeZero boundingSize:CGSizeZero cornerRadius:0.0 scaleToFit:true]];
        [self addSubview:_transformImageView];
    }
    return self;
}

- (void)dealloc
{
    [_currentAudioSession dispose];
    
    [TGEmbedPIPController resumePictureInPicturePlayback];
}

- (void)loadImageWithUri:(NSString *)uri update:(bool)update synchronously:(bool)synchronously
{
    NSDictionary *options = @{};
    if (update)
        options = @{TGImageViewOptionKeepCurrentImageAsPlaceholder: @true};
    else
        options = @{TGImageViewOptionSynchronous: @(synchronously)};
    
    [_legacyImageView loadUri:uri withOptions:options];
}

- (void)loadImageWithSignal:(SSignal *)signal {
    [_transformImageView setSignal:signal];
}

- (void)setVideoPath:(NSString *)videoPath duration:(NSTimeInterval)duration
{
    _videoPath = videoPath;
    [self updateState:[TGModernGalleryVideoPlayerState stateWithPlaying:false duration:duration position:0.0]];
}

- (bool)isLoaded
{
    return (_videoView != nil);
}

- (SSignal *)stateSignal
{
    return _statePipe.signalProducer();
}

- (void)updateState:(TGModernGalleryVideoPlayerState *)state
{
    _state = state;
    _statePipe.sink(state);
}

- (void)reset
{
    [_legacyImageView reset];
    [_transformImageView setSignal:[SSignal never]];
    [self stop];
}

- (void)stop
{
    if (_player != nil)
    {
        _didPlayToEndObserver = nil;
        
        [_player pause];
        [_player replaceCurrentItemWithPlayerItem:nil];
        _player = nil;
    }
    
    if (_videoView != nil)
    {
        SMetaDisposable *currentAudioSession = _currentAudioSession;
        if (currentAudioSession)
        {
            _videoView.deallocBlock = ^
            {
                [[SQueue concurrentDefaultQueue] dispatch:^
                {
                    [currentAudioSession setDisposable:nil];
                }];
            };
        }
        [_videoView cleanupPlayer];
        [_videoView removeFromSuperview];
        _videoView = nil;
    }
    
    _systemPIPController = nil;
    
    [self updateState:[TGModernGalleryVideoPlayerState stateWithPlaying:false duration:self.state.duration position:self.state.position]];
    
    [_videoFlickerTimer invalidate];
    _videoFlickerTimer = nil;
    
    [_positionTimer invalidate];
    _positionTimer = nil;
}

- (void)disposeAudioSession
{
    [_currentAudioSession dispose];
}

- (void)playVideo
{
    if (_videoPath == nil)
        return;
    
    if (_player == nil)
    {
        _currentAudioSession = [[SMetaDisposable alloc] init];
        
        __weak TGModernGalleryVideoPlayerView *weakSelf = self;
        [[SQueue concurrentDefaultQueue] dispatch:^
        {
            [_currentAudioSession setDisposable:[[TGAudioSessionManager instance] requestSessionWithType:TGAudioSessionTypePlayVideo interrupted:^
            {
                TGDispatchOnMainThread(^
                {
                    __strong TGModernGalleryVideoPlayerView *strongSelf = weakSelf;
                    if (strongSelf != nil)
                        [strongSelf pauseVideo:false];
                });
            }]];
        }];
        
        _player = [[AVPlayer alloc] initWithURL:[NSURL fileURLWithPath:_videoPath]];
        _player.actionAtItemEnd = AVPlayerActionAtItemEndNone;
        
        _didPlayToEndObserver = [[TGObserverProxy alloc] initWithTarget:self targetSelector:@selector(playerItemDidPlayToEndTime:) name:AVPlayerItemDidPlayToEndTimeNotification object:[_player currentItem]];

        _videoView = [[TGModernGalleryVideoView alloc] initWithFrame:self.bounds player:_player];
        _videoView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        _videoView.playerLayer.videoGravity = AVLayerVideoGravityResizeAspectFill;
        
        _videoView.playerLayer.opaque = false;
        _videoView.playerLayer.backgroundColor = nil;
        [self addSubview:_videoView];
        
        _videoView.alpha = 0.0f;
        _videoFlickerTimer = [TGTimerTarget scheduledMainThreadTimerWithTarget:self action:@selector(videoFlickerTimerEvent) interval:0.1 repeat:false];
        
        [self _setupSystemPIP];
        
        [self _didBeginPlayback];
        
        Float64 seconds = 0.0f;
        CMTime targetTime = CMTimeMakeWithSeconds(seconds, NSEC_PER_SEC);
        [_player seekToTime:targetTime toleranceBefore:kCMTimeZero toleranceAfter:kCMTimeZero];
    }
    
    [self updateState:[TGModernGalleryVideoPlayerState stateWithPlaying:true duration:self.state.duration position:self.state.position]];
    
    [_player play];
    
    _positionTimer = [TGTimerTarget scheduledMainThreadTimerWithTarget:self action:@selector(positionTimerEvent) interval:0.25 repeat:true];
    [self positionTimerEvent];
}

- (void)pauseVideo
{
    [self pauseVideo:true];
}

- (void)pauseVideo:(bool)manually
{
    _pausedManually = manually;
    
    [self updateState:[TGModernGalleryVideoPlayerState stateWithPlaying:false duration:self.state.duration position:self.state.position]];
    
    [_player pause];
    
    [_positionTimer invalidate];
    _positionTimer = nil;
}

- (void)videoFlickerTimerEvent
{
    [_videoFlickerTimer invalidate];
    _videoFlickerTimer = nil;
    
    _videoView.alpha = 1.0f;
}

- (void)positionTimerEvent
{
    NSTimeInterval duration = self.state.duration;
    NSTimeInterval actualDuration = CMTimeGetSeconds(_player.currentItem.duration);
    if (actualDuration > 0.1f)
        duration = actualDuration;
    NSTimeInterval position = CMTimeGetSeconds(_player.currentItem.currentTime);
    
    [self updateState:[TGModernGalleryVideoPlayerState stateWithPlaying:self.state.isPlaying duration:duration position:position]];
}

- (void)_didBeginPlayback
{
    [TGEmbedPIPController pausePictureInPicturePlayback];
}

- (void)playerItemDidPlayToEndTime:(NSNotification *)__unused notification
{
    [_player pause];
    
    AVPlayerItem *p = [notification object];
    [p seekToTime:kCMTimeZero];
    
    [_positionTimer invalidate];
    _positionTimer = nil;
    
    [self updateState:[TGModernGalleryVideoPlayerState stateWithPlaying:false duration:self.state.duration position:0.0]];
}

- (void)seekToPosition:(NSTimeInterval)position
{
    [_player.currentItem seekToTime:CMTimeMake((int64_t)(position * 1000.0), 1000.0)];
}

- (void)seekToFractPosition:(CGFloat)position
{
    NSTimeInterval timePosition = self.state.duration * position;
    [self seekToPosition:timePosition];
}

- (void)switchToPictureInPicture
{
    if (self.requestPictureInPicture != nil)
        self.requestPictureInPicture(TGEmbedPIPCornerNone);
}

- (void)_setupSystemPIP
{
    if (_systemPIPController != nil)
        return;
    
    AVPictureInPictureController *controller = [[AVPictureInPictureController alloc] initWithPlayerLayer:_videoView.playerLayer];
    controller.delegate = self;
    _systemPIPController = controller;
}

- (void)_requestSystemPictureInPictureMode
{
    if (iosMajorVersion() < 9 || !TGIsPad() || ![AVPictureInPictureController isPictureInPictureSupported])
        return;
    
    if ([_systemPIPController isPictureInPicturePossible])
        [_systemPIPController startPictureInPicture];
}

- (void)beginLeavingFullscreen
{
    
}

- (void)finishedLeavingFullscreen
{
    
}

- (void)_prepareToEnterFullscreen
{
    
}

- (void)_prepareToLeaveFullscreen
{
    
}

- (void)pictureInPictureController:(AVPictureInPictureController *)__unused pictureInPictureController restoreUserInterfaceForPictureInPictureStopWithCompletionHandler:(void (^)(BOOL))completionHandler
{
    [TGEmbedPIPController _cancelSystemPIPWithCompletion:^
    {
        completionHandler(true);
    }];
}

- (void)pictureInPictureControllerDidStartPictureInPicture:(AVPictureInPictureController *)__unused pictureInPictureController
{
    [TGEmbedPIPController _systemPictureInPictureDidStart];
}

- (void)pictureInPictureControllerDidStopPictureInPicture:(AVPictureInPictureController *)__unused pictureInPictureController
{
    [TGEmbedPIPController _systemPictureInPictureDidStop];
}

- (void)pictureInPictureController:(AVPictureInPictureController *)__unused pictureInPictureController failedToStartPictureInPictureWithError:(NSError *)error
{
    TGLog(@"AVPictureInPictureController error: %@", error.localizedDescription);
}

- (void)pausePIPPlayback
{
    if (_pausedManually)
        return;
    
    _shouldResumePIPPlayback = true;
    [self pauseVideo:false];
}

- (void)resumePIPPlayback
{
    //if (_shouldResumePIPPlayback)
    //    [self playVideo];
    
    _shouldResumePIPPlayback = false;
}

- (bool)supportsPIP
{
    CGSize screenSize = TGScreenSize();
    return !self.disallowPIP && (int)screenSize.height != 480;
}
#pragma mark - 

- (void)layoutSubviews
{
    _legacyImageView.frame = self.bounds;
    _transformImageView.frame = self.bounds;
    _videoView.frame = self.bounds;
}

@end
