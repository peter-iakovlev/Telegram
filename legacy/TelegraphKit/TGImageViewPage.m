#import "TGImageViewPage.h"

#import "TGImageUtils.h"
#import "TGViewController.h"

#import "TGLinearProgressView.h"

#import "TGImageTransitionHelper.h"
#import "TGHacks.h"

#import "TGDoubleTapGestureRecognizer.h"

#import "SGraphObjectNode.h"

#import "TGImageViewControllerInterfaceView.h"
#import "TGImagePagingScrollView.h"

#import "TGDownloadManager.h"

#import "TGObserverProxy.h"

#import "TGFont.h"
#import "TGTimerTarget.h"

#import <QuartzCore/QuartzCore.h>
#import <MediaPlayer/MediaPlayer.h>

#define TG_ZOOM_ADJUSTMENT_THRESHOLD_HORIZONTAL 60.0f
#define TG_ZOOM_ADJUSTMENT_THRESHOLD_VERTICAL -60.0f

@interface TGVideoContainerView : UIView <ASWatcher>

@property (nonatomic, weak) id delegate;

@property (nonatomic, strong) ASHandle *actionHandle;

@property (nonatomic, strong) UIButton *playButton;
@property (nonatomic, strong) UIView *containerView;
@property (nonatomic, strong) MPMoviePlayerController *moviePlayer;

@property (nonatomic, strong) TGVideoMediaAttachment *videoAttachment;
@property (nonatomic) int messageId;

@property (nonatomic, strong) UIView *controlsContainer;
@property (nonatomic, strong) UISlider *sliderView;
@property (nonatomic, strong) UIImageView *disabledSliderView;
@property (nonatomic, strong) UILabel *forwardTimeLabel;
@property (nonatomic, strong) UILabel *backwardTimeLabel;

@property (nonatomic) bool shouldHideInterfaceByTimeout;
@property (nonatomic) NSTimeInterval playbackStartTime;

@property (nonatomic, strong) NSTimer *playbackTimer;
@property (nonatomic) bool isScrubbing;

@property (nonatomic, strong) TGObserverProxy *scalingModeChangedProxy;
@property (nonatomic, strong) TGObserverProxy *playbackStateChangedProxy;
@property (nonatomic, strong) TGObserverProxy *movieDurationAvailableProxy;

@end

@implementation TGVideoContainerView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self != nil)
    {
        _actionHandle = [[ASHandle alloc] initWithDelegate:self releaseOnMainThread:true];
        
        self.clipsToBounds = true;
        
        _containerView = [[UIView alloc] initWithFrame:self.bounds];
        [self addSubview:_containerView];
        
        TGDoubleTapGestureRecognizer *doubleTapRecognizer = [[TGDoubleTapGestureRecognizer alloc] initWithTarget:self action:@selector(doubleTapGestureRecognized:)];
        [_containerView addGestureRecognizer:doubleTapRecognizer];
        
        UITapGestureRecognizer *tapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapGestureRecognized:)];
        [tapRecognizer requireGestureRecognizerToFail:doubleTapRecognizer];
        [_containerView addGestureRecognizer:tapRecognizer];
        
        UIImage *playButtonImage = [UIImage imageNamed:@"PlayButtonBig.png"];
        
        _playButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, playButtonImage.size.width, playButtonImage.size.height)];
        _playButton.exclusiveTouch = true;
        [_playButton setBackgroundImage:playButtonImage forState:UIControlStateNormal];
        [_playButton setBackgroundImage:[UIImage imageNamed:@"PlayButtonBig_Highlighted.png"] forState:UIControlStateHighlighted];
        [_playButton addTarget:self action:@selector(playButtonPressed) forControlEvents:UIControlEventTouchUpInside];
        [self setPlayButtonHidden:true];
        [self addSubview:_playButton];
        
        _playButton.frame = CGRectMake(floorf((frame.size.width - _playButton.frame.size.width) / 2), floorf((frame.size.height - _playButton.frame.size.height) / 2), _playButton.frame.size.width, _playButton.frame.size.height);
        
        _controlsContainer = [[UIView alloc] initWithFrame:CGRectMake(0, 20 + (self.frame.size.width < 400 ? 44 : 32), self.frame.size.width, 33)];
        
        if (iosMajorVersion() >= 7)
        {
            if (false)
            {
                TGToolbar *toolbar = [[TGToolbar alloc] initWithFrame:_controlsContainer.bounds];
                toolbar.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
                toolbar.barTintColor = [UIColor whiteColor];
                UIView *barTintView = [[UIView alloc] initWithFrame:toolbar.bounds];
                barTintView.backgroundColor = UIColorRGBA(0x000000, 0.5f);
                barTintView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
                [toolbar addSubview:barTintView];
                [_controlsContainer addSubview:toolbar];
            }
            else
            {
                _controlsContainer.backgroundColor = UIColorRGBA(0x000000, 0.6f);
            }
        }
        else
        {
            _controlsContainer.backgroundColor = UIColorRGBA(0x000000, 0.6f);
        }
        
        _controlsContainer.alpha = 0.0f;
        _controlsContainer.tag = ((int)0x6FC81BDB);
        [self addSubview:_controlsContainer];
        
        UIImage *normalTrackImage = [UIImage imageNamed:@"VideoSliderBackground.png"];
        UIImage *disabledTrackImage = [UIImage imageNamed:@"VideoSliderBackground_Disabled.png"];
        UIImage *trackForegroundImage = [UIImage imageNamed:@"VideoSliderForeground.png"];
        
        _disabledSliderView = [[UIImageView alloc] initWithImage:[disabledTrackImage stretchableImageWithLeftCapWidth:(int)(disabledTrackImage.size.width / 2) topCapHeight:0]];
        _disabledSliderView.alpha = 0.0f;
        _disabledSliderView.frame = CGRectMake(38, 14 + (TGIsRetina() ? 0.5f : 0.0f), _controlsContainer.frame.size.width - 38 * 2, disabledTrackImage.size.height);
        _disabledSliderView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        [_controlsContainer addSubview:_disabledSliderView];
        
        _sliderView = [[UISlider alloc] init];
        _sliderView.exclusiveTouch = true;
        _sliderView.frame = CGRectMake(38, 2 + (TGIsRetina() ? 0.5f : 0.0f), _controlsContainer.frame.size.width - (38 * 2), _sliderView.frame.size.height);
        _sliderView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        [_sliderView setMaximumTrackImage:[normalTrackImage stretchableImageWithLeftCapWidth:(int)(normalTrackImage.size.width / 2) topCapHeight:0] forState:UIControlStateNormal];
        [_sliderView setMinimumTrackImage:[trackForegroundImage stretchableImageWithLeftCapWidth:(int)(trackForegroundImage.size.width / 2) topCapHeight:0] forState:UIControlStateNormal];
        [_sliderView setThumbImage:[UIImage imageNamed:@"VideoSliderHandle.png"] forState:UIControlStateNormal];
        [_sliderView setThumbImage:[UIImage imageNamed:@"VideoSliderHandle_Highlighted.png"] forState:UIControlStateHighlighted];
        _sliderView.continuous = true;
        [_sliderView addTarget:self action:@selector(sliderValueChanged) forControlEvents:UIControlEventValueChanged];
        [_sliderView addTarget:self action:@selector(sliderPressed) forControlEvents:UIControlEventTouchDown];
        [_sliderView addTarget:self action:@selector(sliderReleased) forControlEvents:UIControlEventTouchUpInside];
        [_sliderView addTarget:self action:@selector(sliderReleased) forControlEvents:UIControlEventTouchUpOutside];
        [_sliderView addTarget:self action:@selector(sliderReleased) forControlEvents:UIControlEventTouchCancel];
        [_controlsContainer addSubview:_sliderView];
        
        _forwardTimeLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 5, 37, 28)];
        _forwardTimeLabel.backgroundColor = [UIColor clearColor];
        _forwardTimeLabel.textAlignment = UITextAlignmentCenter;
        _forwardTimeLabel.font = TGSystemFontOfSize(12);
        _forwardTimeLabel.textColor = [UIColor whiteColor];
        _forwardTimeLabel.text = @"-:--";
        [_controlsContainer addSubview:_forwardTimeLabel];
        
        _backwardTimeLabel = [[UILabel alloc] initWithFrame:CGRectMake(_controlsContainer.frame.size.width - 37, 5, 37, 28)];
        _backwardTimeLabel.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin;
        _backwardTimeLabel.textAlignment = UITextAlignmentCenter;
        _backwardTimeLabel.backgroundColor = [UIColor clearColor];
        _backwardTimeLabel.font = TGSystemFontOfSize(12);
        _backwardTimeLabel.textColor = [UIColor whiteColor];
        _backwardTimeLabel.text = @"-:--";
        [_controlsContainer addSubview:_backwardTimeLabel];
    }
    return self;
}

- (void)dealloc
{
    [_actionHandle reset];
    
    _videoAttachment = nil;
    [self resetPlayer:false];
    
    [ActionStageInstance() removeWatcherByHandle:_actionHandle];
}

- (void)setVideoAttachment:(TGVideoMediaAttachment *)videoAttachment
{
    _videoAttachment = videoAttachment;
    
    [self playbackTimerEvent];
}

- (void)setFrame:(CGRect)frame
{
    [super setFrame:frame];
    
    if (!CGRectEqualToRect(CGRectMake(0, 0, frame.size.width, frame.size.height), _containerView.frame))
        _containerView.frame = CGRectMake(0, 0, frame.size.width, frame.size.height);
    if (!CGRectEqualToRect(CGRectMake(0, 0, frame.size.width, frame.size.height), _moviePlayer.view.frame))
    {
        _moviePlayer.view.frame = CGRectMake(0, 0, frame.size.width, frame.size.height);
        
        bool preferScaleToFill = false;
        __strong id delegate = self.delegate;
        if (delegate != nil && [delegate conformsToProtocol:@protocol(TGImageScrollViewDelegate)])
            preferScaleToFill = [(id<TGImageScrollViewDelegate>)delegate preferScaleToFill];
        
        _moviePlayer.scalingMode = !preferScaleToFill ? MPMovieScalingModeAspectFill : MPMovieScalingModeAspectFit;
        _moviePlayer.scalingMode = preferScaleToFill ? MPMovieScalingModeAspectFill : MPMovieScalingModeAspectFit;
    }
    
    _playButton.frame = CGRectMake(floorf((frame.size.width - _playButton.frame.size.width) / 2), floorf((frame.size.height - _playButton.frame.size.height) / 2), _playButton.frame.size.width, _playButton.frame.size.height);
    
    float statusBarHeight = 20;
    if ([self.superview isKindOfClass:[TGImageViewPage class]])
        statusBarHeight = ((TGImageViewPage *)self.superview).statusBarHeight;
    _controlsContainer.frame = CGRectMake(0, statusBarHeight + (frame.size.width < 400 ? 44 : 32), frame.size.width, _controlsContainer.frame.size.height);
}

- (void)updateScaleMode
{
    bool preferScaleToFill = false;
    __strong id delegate = self.delegate;
    if (delegate != nil && [delegate conformsToProtocol:@protocol(TGImageScrollViewDelegate)])
        preferScaleToFill = [(id<TGImageScrollViewDelegate>)delegate preferScaleToFill];
    
    _moviePlayer.scalingMode = preferScaleToFill ? MPMovieScalingModeAspectFill : MPMovieScalingModeAspectFit;
}

- (void)updateControlsAlpha:(float)alpha
{
    _controlsContainer.alpha = alpha;
}

- (void)setSliderEnabled:(bool)enabled animated:(bool)animated
{
    if (!enabled)
        animated = false;
    
    UIView *sliderView = _sliderView;
    UIView *disabledSliderView = _disabledSliderView;
    
    if (enabled != sliderView.alpha > 0.0f + FLT_EPSILON)
    {
        if (animated)
        {
            if (!enabled)
                disabledSliderView.alpha = 1.0f;
            
            [UIView animateWithDuration:0.2 animations:^
            {
                sliderView.alpha = enabled ? 1.0f : 0.0f;
            } completion:^(BOOL finished)
            {
                if (finished)
                {
                    if (enabled)
                        disabledSliderView.alpha = 0.0f;
                }
            }];
        }
        else
        {
            sliderView.alpha = enabled ? 1.0f : 0.0f;
            disabledSliderView.alpha = enabled ? 0.0f : 1.0f;
        }
    }
}

- (void)createPlayer:(NSURL *)fileUrl
{
    [self setPlayButtonHidden:true];
    
    bool preferScaleToFill = false;
    __strong id delegate = self.delegate;
    if (delegate != nil && [delegate conformsToProtocol:@protocol(TGImageScrollViewDelegate)])
        preferScaleToFill = [(id<TGImageScrollViewDelegate>)delegate preferScaleToFill];
    
    _moviePlayer = [[MPMoviePlayerController alloc] initWithContentURL:fileUrl];
    _moviePlayer.useApplicationAudioSession = NO;
    
    _moviePlayer.controlStyle = MPMovieControlStyleNone;
    _moviePlayer.movieSourceType = MPMovieSourceTypeFile;
    _moviePlayer.scalingMode = preferScaleToFill ? MPMovieScalingModeAspectFill : MPMovieScalingModeAspectFit;
    
    _scalingModeChangedProxy = nil;
    _playbackStateChangedProxy = nil;
    _movieDurationAvailableProxy = nil;
    
    _scalingModeChangedProxy = [[TGObserverProxy alloc] initWithTarget:self targetSelector:@selector(scalingModeChanged:) name:MPMoviePlayerScalingModeDidChangeNotification object:_moviePlayer];
    _playbackStateChangedProxy = [[TGObserverProxy alloc] initWithTarget:self targetSelector:@selector(playbackStateChanged:) name:MPMoviePlayerPlaybackStateDidChangeNotification object:_moviePlayer];
    _movieDurationAvailableProxy = [[TGObserverProxy alloc] initWithTarget:self targetSelector:@selector(movieDurationAvailable:) name:MPMovieDurationAvailableNotification object:_moviePlayer];
    
    [_moviePlayer.view setFrame:self.bounds];
    [_containerView insertSubview:_moviePlayer.view atIndex:0];
    
    [_moviePlayer prepareToPlay];
    [_moviePlayer play];
    
    _moviePlayer.view.userInteractionEnabled = false;
    
    _moviePlayer.view.backgroundColor = [UIColor clearColor];
    
    for (UIView *view in _moviePlayer.view.subviews)
    {
        view.backgroundColor = [UIColor clearColor];
    }
}

- (void)scalingModeChanged:(NSNotification *)__unused notification
{
    __strong id delegate = self.delegate;
    if (delegate != nil && [delegate conformsToProtocol:@protocol(TGImageScrollViewDelegate)])
        [(id<TGImageScrollViewDelegate>)delegate scalingModeChanged:_moviePlayer.scalingMode == MPMovieScalingModeAspectFill];
}

- (void)playbackStateChanged:(NSNotification *)__unused notification
{
    if (_playbackTimer != nil)
    {
        [_playbackTimer invalidate];
        _playbackTimer = nil;
    }
    
    [self movieSizeAvailable:nil];
    
    switch (_moviePlayer.playbackState)
    {
        case MPMoviePlaybackStateStopped:
        case MPMoviePlaybackStatePaused:
        case MPMoviePlaybackStateInterrupted:
        {
            if (!_isScrubbing)
                [self setPlayButtonHidden:false];
            
            [self playbackTimerEvent];
            break;
        }
        default:
        {   
            [self playbackTimerEvent];
            _playbackTimer = [TGTimerTarget scheduledMainThreadTimerWithTarget:self action:@selector(playbackTimerEvent) interval:0.5 repeat:true];
            
            [self setPlayButtonHidden:true];
            break;
        }
    }
}

- (void)movieDurationAvailable:(NSNotification *)__unused notification
{
    [self setSliderEnabled:true animated:true];
    
    [self movieSizeAvailable:nil];
    
    [self playbackTimerEvent];
}

- (void)movieSizeAvailable:(NSNotification *)__unused notification
{
    if (_moviePlayer.naturalSize.width > FLT_EPSILON)
    {
        __strong id delegate = self.delegate;
        if (delegate != nil && [delegate conformsToProtocol:@protocol(TGImageScrollViewDelegate)])
            [(id<TGImageScrollViewDelegate>)delegate videoDimensionsAvailable:_moviePlayer.naturalSize];
    }
}

- (void)sliderPressed
{
    _isScrubbing = true;
    
    if (_moviePlayer != nil)
    {
        [_moviePlayer pause];
    }
    
    [self playbackTimerEvent];
}

- (void)sliderReleased
{
    _isScrubbing = false;
    
    if (_moviePlayer != nil)
    {
        [_moviePlayer play];
    }
    
    [self playbackTimerEvent];
}

- (void)sliderValueChanged
{
    if (_isScrubbing)
    {
        if (_moviePlayer != nil)
        {
            NSTimeInterval movieDuration = _moviePlayer.duration;
            _moviePlayer.currentPlaybackTime = MIN(MAX(0.0, _sliderView.value * movieDuration), movieDuration);
        }
        
        [self playbackTimerEvent];
    }
}

- (void)playbackTimerEvent
{
    if (_shouldHideInterfaceByTimeout && CFAbsoluteTimeGetCurrent() > _playbackStartTime + 1.4)
    {
        _shouldHideInterfaceByTimeout = false;
        
        __strong id delegate = self.delegate;
        if (delegate != nil && [delegate conformsToProtocol:@protocol(TGImageScrollViewDelegate)])
            [(id<TGImageScrollViewDelegate>)delegate hideInterface];
    }
    
    NSTimeInterval movieDuration = 0.0;
    NSTimeInterval moviePlaybackTime = 0.0;
    
    if (_moviePlayer != nil)
    {
        movieDuration = _moviePlayer.duration;
        moviePlaybackTime = MAX(0.0, _moviePlayer.currentPlaybackTime);
    }
    
    if (movieDuration < FLT_EPSILON)
        movieDuration = _videoAttachment.duration;
    
    if (movieDuration > FLT_EPSILON)
    {
        if (_isScrubbing)
            moviePlaybackTime = _sliderView.value * movieDuration;
        
        [self setSliderEnabled:_moviePlayer != nil animated:true];
        
        int absoluteDuration = (int)movieDuration;
        
        int absoluteSeconds = (int)moviePlaybackTime;
        int absoluteRemainingSeconds = (int)((int)movieDuration - (int)moviePlaybackTime);
        
        if (movieDuration - moviePlaybackTime < 1.0)
        {
            absoluteSeconds = (int)movieDuration;
            absoluteRemainingSeconds = 0;
        }
        
        if (!_isScrubbing)
        {
            if (absoluteDuration > 0)
            {
                if (absoluteRemainingSeconds == 0)
                    [_sliderView setValue:1.0f];
                else
                    [_sliderView setValue:(((int)moviePlaybackTime) * 60 / absoluteDuration) / 60.0f];
            }
            else
                [_sliderView setValue:0.0f];
        }
        
        bool useHours = (((int)_moviePlayer.duration) / 60 / 60) != 0;
        
        int seconds = absoluteSeconds % 60;
        int minutes = (absoluteSeconds / 60) % 60;
        int hours = (absoluteSeconds / 60 / 60);
        if (!useHours)
            _forwardTimeLabel.text = [[NSString alloc] initWithFormat:@"%d:%02d", minutes, seconds];
        else
            _forwardTimeLabel.text = [[NSString alloc] initWithFormat:@"%d:%02d:%02d", hours, minutes, seconds];
        
        int remainingSeconds = absoluteRemainingSeconds % 60;
        int remainingMinutes = (absoluteRemainingSeconds / 60) % 60;
        int remainingHours = (absoluteRemainingSeconds / 60 / 60);
        if (!useHours)
            _backwardTimeLabel.text = [[NSString alloc] initWithFormat:@"-%d:%02d", remainingMinutes, remainingSeconds];
        else
            _backwardTimeLabel.text = [[NSString alloc] initWithFormat:@"-%d:%02d:%02d", remainingHours, remainingMinutes, remainingSeconds];
    }
    else
    {
        [self setSliderEnabled:false animated:true];
        
        [_sliderView setValue:0.0f];
        
        _forwardTimeLabel.text = @"-:--";
        _backwardTimeLabel.text = @"-:--";
    }
}

- (void)pausePlayer
{
    _shouldHideInterfaceByTimeout = false;
    [_moviePlayer pause];
    
    [self setPlayButtonHidden:false];
}

- (void)prepareForDestruction
{
    [ActionStageInstance() removeWatcherByHandle:_actionHandle];
}

- (id<TGMediaPlayerRecycler>)findRecycler:(UIView *)view
{
    if (view == nil)
        return nil;
    
    if ([view conformsToProtocol:@protocol(TGMediaPlayerRecycler)])
        return (id<TGMediaPlayerRecycler>)view;
    
    return [self findRecycler:view.superview];
}

- (void)setProgressContainerAlpha:(float)alpha progress:(float)progress animated:(bool)animated
{
    __strong id delegate = _delegate;
    if ([delegate respondsToSelector:@selector(updateProgressAlpha:progress:animated:)])
        [(id<TGImageScrollViewDelegate>)delegate updateProgressAlpha:alpha progress:progress animated:animated];
}

- (void)resetPlayer:(bool)delay
{   
    _shouldHideInterfaceByTimeout = false;
    
    if (_videoAttachment != nil)
        [self setProgressContainerAlpha:0.0f progress:0.0f animated:false];
    
    [self setSliderEnabled:false animated:false];
    
    _scalingModeChangedProxy = nil;
    _playbackStateChangedProxy = nil;
    _movieDurationAvailableProxy = nil;
    
    if (_playbackTimer != nil)
    {
        [_playbackTimer invalidate];
        _playbackTimer = nil;
    }
    
    [self playbackTimerEvent];
    
    bool recycled = false;
    
    if (delay)
    {
        id<TGMediaPlayerRecycler> mediaRecycler = [self findRecycler:self.superview];
        if (mediaRecycler != nil)
        {
            [mediaRecycler recycleMediaPlayer:_moviePlayer];
            recycled = true;
        }
    }
    
    MPMoviePlayerController *moviePlayer = _moviePlayer;
    _moviePlayer = nil;

    moviePlayer.view.hidden = true;
    
    if (!recycled)
    {
        [moviePlayer stop];
    }
    
    [self setPlayButtonHidden:false];
    _playButton.alpha = 1.0f;
    
    ASHandle *actionHandle = _actionHandle;
    [ActionStageInstance() dispatchOnStageQueue:^
    {
        [ActionStageInstance() removeWatcherByHandle:actionHandle];
    }];
}

- (void)setPlayButtonHidden:(bool)hidden
{
    _playButton.hidden = hidden;
    
    __strong id delegate = self.delegate;
    if ([delegate respondsToSelector:@selector(pageMediaPlaybackStateChanged:)])
        [(id<TGImageScrollViewDelegate>)delegate pageMediaPlaybackStateChanged:!hidden];
}

- (void)play
{    
    [self setPlayButtonHidden:true];
    _playButton.alpha = 0.0f;
    
    if (_moviePlayer != nil)
    {
        _shouldHideInterfaceByTimeout = true;
        _playbackStartTime = CFAbsoluteTimeGetCurrent();
        [_moviePlayer play];
    }
    else
    {
        TGVideoMediaAttachment *videoAttachment = _videoAttachment;
        [self requestVideo:videoAttachment];
    }
}

- (void)requestVideo:(TGVideoMediaAttachment *)videoAttachment
{
    [ActionStageInstance() dispatchOnStageQueue:^
    {
        NSString *url = [videoAttachment.videoInfo urlWithQuality:1 actualQuality:NULL actualSize:NULL];
        if (false)
        {
            [ActionStageInstance() requestActor:[[NSString alloc] initWithFormat:@"/as/streamingProxy/(%@)", url] options:nil watcher:self];
        }
        else
        {
            [ActionStageInstance() requestActor:[[NSString alloc] initWithFormat:@"/as/media/video/(%@)", url] options:[[NSDictionary alloc] initWithObjectsAndKeys:videoAttachment, @"videoAttachment", nil] watcher:self];
        }
    }];
}

- (void)joinDownload:(bool)force
{
    if (_videoAttachment == nil)
        return;
    
    TGVideoMediaAttachment *videoAttachment = _videoAttachment;
    [ActionStageInstance() dispatchOnStageQueue:^
    {
        NSString *url = [videoAttachment.videoInfo urlWithQuality:1 actualQuality:NULL actualSize:NULL];
        NSString *path = [[NSString alloc] initWithFormat:@"/as/media/video/(%@)", url];
        if ([ActionStageInstance() requestActorStateNow:path])
        {
            dispatch_async(dispatch_get_main_queue(), ^
            {
                [self setPlayButtonHidden:true];
                _playButton.alpha = 0.0f;
            });
            
            [ActionStageInstance() requestActor:path options:nil watcher:self];
        }
        else if (force)
        {
            //[ActionStageInstance() requestActor:path options:nil watcher:self];
        }
    }];
}

- (void)playButtonPressed
{
    if (_videoAttachment == nil)
        return;
    
    [self play];
}

- (void)tapGestureRecognized:(UITapGestureRecognizer *)recognizer
{
    if (recognizer.state == UIGestureRecognizerStateRecognized)
    {
        __strong id delegate = self.delegate;
        if (delegate != nil && [delegate conformsToProtocol:@protocol(TGImageScrollViewDelegate)])
            [(id<TGImageScrollViewDelegate>)delegate scrollViewTapped];
    }
}

- (void)doubleTapGestureRecognized:(TGDoubleTapGestureRecognizer *)recognizer
{
    if (recognizer.state == UIGestureRecognizerStateRecognized && recognizer.doubleTapped)
    {
        bool shouldChange = true;
        
        __strong id delegate = self.delegate;
        if (delegate != nil && [delegate conformsToProtocol:@protocol(TGImageScrollViewDelegate)])
            shouldChange = [(id<TGImageScrollViewDelegate>)delegate shouldChangeScalingMode];
        
        if (shouldChange)
        {
            MPMoviePlayerController *moviePlayer = _moviePlayer;
            [UIView animateWithDuration:0.25 animations:^
            {
                if (moviePlayer.scalingMode == MPMovieScalingModeAspectFit)
                    moviePlayer.scalingMode = MPMovieScalingModeAspectFill;
                else
                    moviePlayer.scalingMode = MPMovieScalingModeAspectFit;
            }];
        }
    }
}

- (void)actorMessageReceived:(NSString *)path messageType:(NSString *)messageType message:(id)message
{
    if ([path hasPrefix:@"/as/streamingProxy"])
    {
        if ([messageType isEqualToString:@"url"])
        {
            dispatch_async(dispatch_get_main_queue(), ^
            {
                [self createPlayer:[NSURL URLWithString:message]];
            });
        }
    }
    else if ([path hasPrefix:@"/as/media/video/"])
    {
        if ([messageType isEqualToString:@"willDownloadVideo"])
        {
            int64_t groupId = 0;
            
            id delegate = _delegate;
            if ([delegate isKindOfClass:[TGImageViewPage class]])
                groupId = [(TGImageViewPage *)delegate groupIdForDownloadingItems];
            
            [[TGDownloadManager instance] enqueueItem:path messageId:_messageId itemId:[message objectForKey:@"mediaId"] groupId:groupId itemClass:TGDownloadItemClassVideo];
        }
        else if ([messageType isEqualToString:@"progress"])
        {
            float progress = [message floatValue];
            dispatch_async(dispatch_get_main_queue(), ^
            {
                [self setProgressContainerAlpha:1.0f progress:progress animated:true];
            });
        }
    }
}

- (void)actorCompleted:(int)status path:(NSString *)path result:(id)result
{
    if ([path hasPrefix:@"/as/media/video/"])
    {
        dispatch_async(dispatch_get_main_queue(), ^
        {
            if (_videoAttachment == nil)
                return;
            
            if (status == ASStatusSuccess)
            {
                [self setProgressContainerAlpha:0.0f progress:1.0f animated:true];
                
                _shouldHideInterfaceByTimeout = true;
                _playbackStartTime = CFAbsoluteTimeGetCurrent();
                
                NSString *filePath = [result objectForKey:@"filePath"];
                [self createPlayer:[NSURL fileURLWithPath:filePath]];
            }
        });
    }
}

@end

@interface TGImageViewPage () <UIScrollViewDelegate, TGImageScrollViewDelegate>

@property (nonatomic, strong) TGRemoteImageView *imageView;
@property (nonatomic) CGSize imageSize;
@property (nonatomic, strong) TGImageScrollView *scrollView;
@property (nonatomic, strong) TGVideoContainerView *videoContainerView;

@property (nonatomic, strong) UIView *topProgressViewContainer;
@property (nonatomic, strong) TGLinearProgressView *topProgressView;
@property (nonatomic, strong) UIView *bottomProgressViewContainer;
@property (nonatomic, strong) TGLinearProgressView *bottomProgressView;

@property (nonatomic, strong) TGImageTransitionHelper *transitionHelper;

@property (nonatomic, strong) NSString *currentThumbnailPath;

@property (nonatomic) bool willPlay;
@property (nonatomic) float controlsAlpha;
@property (nonatomic) float controlsOffset;

@end

@implementation TGImageViewPage

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
    {
        _statusBarHeight = 20;
        
        _actionHandle = [[ASHandle alloc] initWithDelegate:self releaseOnMainThread:true];
        
        _scrollView = [[TGImageScrollView alloc] initWithFrame:self.bounds];

        _scrollView.delegate = self;
        [self addSubview:_scrollView];
        
        _scrollView.delaysContentTouches = false;
        _scrollView.scrollsToTop = false;
        _scrollView.showsHorizontalScrollIndicator = false;
        _scrollView.showsVerticalScrollIndicator = false;
        _scrollView.alwaysBounceHorizontal = false;
        _scrollView.alwaysBounceVertical = false;
        
        _imageView = [[TGRemoteImageView alloc] initWithFrame:CGRectMake(0, 0, 100, 100)];
        _imageView.useCache = false;
        _imageView.contentHints = TGRemoteImageContentHintLargeFile;
        
        _videoContainerView = [[TGVideoContainerView alloc] initWithFrame:self.bounds];
        _videoContainerView.delegate = self;
        _videoContainerView.hidden = true;
        [self addSubview:_videoContainerView];
        
        static UIImage *progressBackgroundImage = nil;
        static UIImage *progressForegroundImage = nil;
        static dispatch_once_t onceToken;
        dispatch_once(&onceToken, ^
        {
            UIImage *rawBackground = [UIImage imageNamed:@"LinearProgressBackground.png"];
            progressBackgroundImage = [rawBackground stretchableImageWithLeftCapWidth:(int)(rawBackground.size.width / 2) topCapHeight:0];
            UIImage *rawForeground = [UIImage imageNamed:@"LinearProgressForeground.png"];
            progressForegroundImage = [rawForeground stretchableImageWithLeftCapWidth:(int)(rawForeground.size.width / 2) topCapHeight:0];
        });
        
        _topProgressViewContainer = [[UIView alloc] initWithFrame:CGRectMake(8, self.frame.size.height - 54, self.frame.size.width - 16, progressBackgroundImage.size.height)];
        _topProgressViewContainer.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleTopMargin;
        [self addSubview:_topProgressViewContainer];
        
        _topProgressView = [[TGLinearProgressView alloc] initWithBackgroundImage:progressBackgroundImage progressImage:progressForegroundImage];
        _topProgressView.frame = _topProgressViewContainer.bounds;
        _topProgressView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        _topProgressView.alpha = 0.0f;
        
        [_topProgressViewContainer addSubview:_topProgressView];
        
        _bottomProgressViewContainer = [[UIView alloc] initWithFrame:CGRectMake(8, self.frame.size.height - 10, self.frame.size.width - 16, progressBackgroundImage.size.height)];
        _bottomProgressViewContainer.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleTopMargin;
        [self addSubview:_bottomProgressViewContainer];
        
        _bottomProgressView = [[TGLinearProgressView alloc] initWithBackgroundImage:progressBackgroundImage progressImage:progressForegroundImage];
        _bottomProgressView.frame = _bottomProgressViewContainer.bounds;
        _bottomProgressView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        _bottomProgressView.alpha = 0.0f;
        
        [_bottomProgressViewContainer addSubview:_bottomProgressView];
        
        _imageView.hidden = false;
        _imageView.fadeTransition = true;
        _imageView.fadeTransitionDuration = 0.1;
        _imageView.contentMode = UIViewContentModeScaleAspectFill;
        
        ASHandle *progressHandle = _actionHandle;
        
        _imageView.progressHandler = ^(__unused TGRemoteImageView *imageView, float progress)
        {
            [progressHandle requestAction:@"updateProgress" options:[[NSNumber alloc] initWithFloat:progress]];
        };
        
        [ActionStageInstance() watchForPath:@"/as/media/previewReady" watcher:self];
    }
    return self;
}

- (void)setCustomCache:(TGCache *)customCache
{
    _customCache = customCache;
    
    _imageView.cache = _customCache;
    _imageView.useCache = _customCache != nil;
}

- (void)dealloc
{
    _videoContainerView.delegate = nil;
    _imageView.progressHandler = nil;
    
    [_actionHandle reset];
    [ActionStageInstance() removeWatcher:self];
}

- (void)setSaveToGallery:(bool)saveToGallery
{
    _saveToGallery = saveToGallery;
}

- (void)loadItem:(id<TGMediaItem>)mediaItem placeholder:(UIImage *)placeholder willAnimateAppear:(bool)willAnimateAppear
{
    if (_imageItem == mediaItem || [_imageItem isEqual:mediaItem])
        return;
    
    _imageItem = mediaItem;
    _currentThumbnailPath = nil;
    
    //[self updateProgressAlpha:0.0f progress:0.0f animated:false];
    
    [_videoContainerView resetPlayer:false];
    [_videoContainerView setVideoAttachment:nil];
    _videoContainerView.messageId = 0;
    
    if ([mediaItem type] == TGMediaItemTypePhoto && [mediaItem imageInfo] != nil)
    {
        CGSize size = CGSizeZero;
        NSString *url = [[mediaItem imageInfo] closestImageUrlWithSize:(CGSizeMake(1136, 1136)) resultingSize:&size pickLargest:true];
        
        //TGLog(@"Image size: %dx%d", (int)size.width, (int)size.height);
        
        if (TGIsRetina())
        {
            size.width = (int)(size.width / 2.0f);
            size.height = (int)(size.height / 2.0f);
        }
        
        _imageSize = size;
        _imageView.frame = CGRectMake(0, 0, size.width, size.height);
        _imageView.hidden = false;
        
        UIImage *thumbnailImage = placeholder;
        
        if (thumbnailImage == nil)
        {
            CGSize thumbnailSelectionSize = CGSizeZero;
            
            NSString *thumbnailUrl = [mediaItem.imageInfo closestImageUrlWithSize:thumbnailSelectionSize resultingSize:NULL];
            
            thumbnailImage = [TGRemoteImageView imageFromCache:thumbnailUrl filter:nil cache:[TGRemoteImageView sharedCache]];
            if (thumbnailImage == nil)
                thumbnailImage = [mediaItem immediateThumbnail];
            
            if (thumbnailImage == nil)
            {
                _currentThumbnailPath = [TGRemoteImageView preloadImage:thumbnailUrl filter:nil blurIfRemote:true cache:[TGRemoteImageView sharedCache] allowThumbnailCache:false watcher:self];
            }
        }
        
        if (_saveToGallery && [mediaItem authorUid] != _ignoreSaveToGalleryUid)
            _imageView.contentHints = TGRemoteImageContentHintLargeFile | TGRemoteImageContentHintSaveToGallery;
        else
            _imageView.contentHints = TGRemoteImageContentHintLargeFile;
        
        NSDictionary *userProperties = nil;
        if ([_imageItem respondsToSelector:@selector(itemMessageId)] && [_imageItem respondsToSelector:@selector(itemMediaId)])
        {
            int messageId = [_imageItem itemMessageId];
            id mediaId = [_imageItem itemMediaId];
            
            if (messageId != 0 && mediaId != nil)
            {
                userProperties = [[NSDictionary alloc] initWithObjectsAndKeys:[[NSNumber alloc] initWithInt:messageId], @"messageId", mediaId, @"mediaId", [mediaItem imageInfo], @"imageInfo", nil];
            }
        }
        _imageView.userProperties = userProperties;
        
        if (_imageView.currentUrl == nil || ![_imageView.currentUrl isEqualToString:url] || _imageView.currentFilter == nil || ![_imageView.currentFilter isEqualToString:@"maybeScale"])
        {
            [_imageView loadImage:url filter:@"maybeScale" placeholder:thumbnailImage];
        }
        
        [self updateInterfaceView];
        
        _scrollView.scrollEnabled = true;
        _videoContainerView.hidden = true;
    }
    else if ([mediaItem type] == TGMediaItemTypeVideo && [mediaItem videoAttachment] != nil)
    {
        TGVideoMediaAttachment *videoAttachment = [mediaItem videoAttachment];
        
        CGSize screenSize = [TGViewController screenSize:UIDeviceOrientationPortrait];
        
        CGSize size = CGSizeZero;
        [videoAttachment.thumbnailInfo closestImageUrlWithHeight:(int)(MAX(screenSize.width, screenSize.height) * 2) resultingSize:&size];
        
        NSString *url = nil;
        if (videoAttachment.videoId != 0)
            url = [[NSString alloc] initWithFormat:@"video-thumbnail-remote%llx.jpg", videoAttachment.videoId];
        else if (videoAttachment.localVideoId != 0)
            url = [[NSString alloc] initWithFormat:@"video-thumbnail-local%llx.jpg", videoAttachment.localVideoId];
        
        if (TGIsRetina())
        {
            size.width = (int)(size.width / 2.0f);
            size.height = (int)(size.height / 2.0f);
        }
        
        if (videoAttachment.dimensions.width > FLT_EPSILON)
        {
            size = videoAttachment.dimensions;
        }
        
        _imageSize = size;
        _imageView.frame = CGRectMake(0, 0, size.width, size.height);
        _imageView.hidden = false;
        
        UIImage *thumbnailImage = placeholder;
        
        if (thumbnailImage == nil)
        {
            CGSize thumbnailSelectionSize = CGSizeZero;
            
            NSString *thumbnailUrl = [videoAttachment.thumbnailInfo closestImageUrlWithSize:thumbnailSelectionSize resultingSize:NULL];
            
            thumbnailImage = [TGRemoteImageView imageFromCache:thumbnailUrl filter:nil cache:[TGRemoteImageView sharedCache]];
            if (thumbnailImage == nil)
                thumbnailImage = [mediaItem immediateThumbnail];
            
            if (thumbnailImage == nil)
            {
                _currentThumbnailPath = [TGRemoteImageView preloadImage:thumbnailUrl filter:nil blurIfRemote:true cache:[TGRemoteImageView sharedCache] allowThumbnailCache:false watcher:self];
            }
        }
        
        [_imageView loadImage:url filter:@"maybeScale" placeholder:thumbnailImage];
        
        [_videoContainerView setVideoAttachment:videoAttachment];
        _videoContainerView.messageId = [[mediaItem itemId] isKindOfClass:[NSNumber class]] ? [[mediaItem itemId] intValue] : 0;
        
        _scrollView.scrollEnabled = false;
        _videoContainerView.hidden = false;
        
        if (willAnimateAppear)
            [_videoContainerView setPlayButtonHidden:true];
        
        if (_willPlay)
            [_videoContainerView setPlayButtonHidden:true];
        
        _willPlay = false;
    }
    else
    {
        _imageView.hidden = true;
        [_imageView loadImage:nil];
        
        _scrollView.scrollEnabled = false;
        _videoContainerView.hidden = true;
    }
}

- (void)reloadVideoPreview:(NSString *)__unused url
{
}

- (void)animateAppearFromImage:(UIImage *)image fromView:(UIView *)fromView aboveView:(UIView *)aboveView fromRect:(CGRect)fromRect toInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation completion:(dispatch_block_t)completion keepAspect:(bool)keepAspect
{
    [self animateAppearFromImage:image fromView:fromView aboveView:aboveView transform:CGAffineTransformIdentity fromRect:fromRect toInterfaceOrientation:interfaceOrientation completion:completion keepAspect:keepAspect];
}

- (void)animateAppearFromImage:(UIImage *)image fromView:(UIView *)fromView aboveView:(UIView *)aboveView transform:(CGAffineTransform)transform fromRect:(CGRect)fromRect toInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation completion:(dispatch_block_t)completion keepAspect:(bool)keepAspect
{
    [self animateAppearFromImage:image fromView:fromView aboveView:aboveView transform:transform fromRect:fromRect toInterfaceOrientation:interfaceOrientation completion:completion keepAspect:keepAspect duration:0.23];
}

- (void)animateAppearFromImage:(UIImage *)image fromView:(UIView *)fromView aboveView:(UIView *)aboveView transform:(CGAffineTransform)transform fromRect:(CGRect)fromRect toInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation completion:(dispatch_block_t)completion keepAspect:(bool)keepAspect duration:(NSTimeInterval)duration
{
    [TGViewController disableAutorotationFor:duration + 0.05f];
    
    CGSize screenSize = [TGViewController screenSizeForInterfaceOrientation:interfaceOrientation];
    if (!CGSizeEqualToSize(CGSizeZero, _referenceScreenSize))
        screenSize = _referenceScreenSize;
    
    screenSize.height -= _bottomAnimationPadding;
    
    CGFloat scaleWidth = screenSize.width / _imageSize.width;
    CGFloat scaleHeight = screenSize.height / _imageSize.height;
    CGFloat minScale = MIN(scaleWidth, scaleHeight);
    
    CGSize boundsSize = screenSize;
    
    if (ABS(minScale - scaleHeight) > FLT_EPSILON && boundsSize.height - _imageSize.height * minScale < TG_ZOOM_ADJUSTMENT_THRESHOLD_HORIZONTAL)
        minScale = scaleHeight;
    else if (ABS(minScale - scaleWidth) > FLT_EPSILON && boundsSize.width - _imageSize.width * minScale < TG_ZOOM_ADJUSTMENT_THRESHOLD_VERTICAL)
        minScale = scaleWidth;
    
    CGRect contentsFrame = CGRectMake(0, 0, _imageSize.width * minScale, _imageSize.height * minScale);
    
    //if (boundsSize.width > contentsFrame.size.width)
        contentsFrame.origin.x = (boundsSize.width - contentsFrame.size.width) / 2.0f;
    //else
    //    contentsFrame.origin.x = 0;
    
    //if (boundsSize.height > contentsFrame.size.height)
        contentsFrame.origin.y = (boundsSize.height - contentsFrame.size.height) / 2.0f;
    //else
    //    contentsFrame.origin.y = 0;
    
    _imageView.hidden = false;
    [_imageView removeFromSuperview];
    [self insertSubview:_imageView belowSubview:_videoContainerView];
    
    //_imageView.contentMode = keepAspect ? UIViewContentModeScaleAspectFill : UIViewContentModeScaleToFill;
    
    _transitionHelper = [[TGImageTransitionHelper alloc] init];
    _imageView.contentMode = UIViewContentModeScaleAspectFill;
    _imageView.clipsToBounds = true;
    [_transitionHelper beginTransitionIn:_imageView fromImage:image fromView:fromView transform:transform fromRectInWindowSpace:fromRect aboveView:aboveView toView:self toRectInWindowSpace:[self convertRect:contentsFrame toView:self.window] toInterfaceOrientation:interfaceOrientation completion:^
    {
        _imageView.contentMode = UIViewContentModeScaleToFill;
        _imageView.clipsToBounds = false;
        [self createScrollView];
        
        _transitionHelper = nil;
        
        if (completion)
            completion();
    } keepAspect:keepAspect duration:duration];
}

- (void)animateDisappearToImage:(UIImage *)__unused toImage toView:(UIView *)toView aboveView:(UIView *)aboveView toRect:(CGRect)toRect toContainerImage:(UIImage *)toContainerImage toInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation keepAspect:(bool)keepAspect backgroundAlpha:(float)backgroundAlpha swipeVelocity:(float)swipeVelocity completion:(dispatch_block_t)completion
{
    [self animateDisappearToImage:toImage toView:toView aboveView:aboveView transform:CGAffineTransformIdentity toRect:toRect toContainerImage:toContainerImage toInterfaceOrientation:toInterfaceOrientation keepAspect:keepAspect backgroundAlpha:backgroundAlpha swipeVelocity:swipeVelocity completion:completion];
}
- (void)animateDisappearToImage:(UIImage *)__unused toImage toView:(UIView *)toView aboveView:(UIView *)aboveView transform:(CGAffineTransform)transform toRect:(CGRect)toRect toContainerImage:(UIImage *)toContainerImage toInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation keepAspect:(bool)keepAspect backgroundAlpha:(float)backgroundAlpha swipeVelocity:(float)swipeVelocity completion:(dispatch_block_t)completion
{
    [self animateDisappearToImage:toImage toView:toView aboveView:aboveView transform:transform toRect:toRect toContainerImage:toContainerImage toInterfaceOrientation:toInterfaceOrientation keepAspect:keepAspect backgroundAlpha:backgroundAlpha swipeVelocity:swipeVelocity completion:completion duration:0.3];
}

- (void)animateDisappearToImage:(UIImage *)__unused toImage toView:(UIView *)toView aboveView:(UIView *)aboveView transform:(CGAffineTransform)transform toRect:(CGRect)toRect toContainerImage:(UIImage *)toContainerImage toInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation keepAspect:(bool)keepAspect backgroundAlpha:(float)backgroundAlpha swipeVelocity:(float)swipeVelocity completion:(dispatch_block_t)completion duration:(NSTimeInterval)duration
{
    _videoContainerView.hidden = true;
    [_videoContainerView pausePlayer];
    [_videoContainerView prepareForDestruction];
    
    [TGViewController disableAutorotationFor:0.31];
    
    [UIView animateWithDuration:duration - 0.1 animations:^
    {
        _topProgressViewContainer.alpha = 0.0f;
        _bottomProgressViewContainer.alpha = 0.0f;
    }];
    
    CGRect imageFrame = [self convertRect:_imageView.frame fromView:_scrollView];
    [_imageView removeFromSuperview];
    [self insertSubview:_imageView belowSubview:_videoContainerView];
    _imageView.frame = imageFrame;
    
    _imageView.contentMode = UIViewContentModeScaleAspectFill;
    _imageView.clipsToBounds = true;
    
    _transitionHelper = [[TGImageTransitionHelper alloc] init];
    _transitionHelper.fadingColor = [[UIColor blackColor] colorWithAlphaComponent:backgroundAlpha];
    [_transitionHelper beginTransitionOut:_imageView fromView:self transform:transform toView:toView aboveView:aboveView interfaceOrientation:toInterfaceOrientation toRectInWindowSpace:toRect toImage:toContainerImage keepAspect:keepAspect swipeVelocity:swipeVelocity completion:completion duration:duration];
}

- (void)createScrollView
{
    _imageView.hidden = false;
    [_imageView removeFromSuperview];
    [_scrollView addSubview:_imageView];
    
    UIImage *mediumImage = [((TGRemoteImageView *)_imageView).currentImage mediumImage];
    if (mediumImage != nil)
    {
        [((TGRemoteImageView *)_imageView).currentImage setMediumImage:nil];
        [(TGRemoteImageView *)_imageView loadImage:mediumImage];
    }
    
    if (((TGRemoteImageView *)_imageView).fadeTransition)
        ((TGRemoteImageView *)_imageView).fadeTransitionDuration = 0.15;
    
    [self resetScrollView];
}

- (void)resetScrollView
{
    _imageView.contentMode = UIViewContentModeScaleToFill;
    
    _scrollView.minimumZoomScale = 1.0f;
    _scrollView.maximumZoomScale = 1.0f;
    _scrollView.zoomScale = 1.0f;
    _scrollView.contentSize = _imageSize;
    _imageView.frame = CGRectMake(0, 0, _imageSize.width, _imageSize.height);
    
    [self adjustScrollView];
    
    _scrollView.zoomScale = _scrollView.adjustedZoomScale;
    CGSize contentSize = _scrollView.contentSize;
    CGSize viewSize = _scrollView.frame.size;
    _scrollView.contentOffset = CGPointMake(MAX(0, floorf((contentSize.width - viewSize.width) / 2)), MAX(0, floorf((contentSize.height - viewSize.height) / 2)));
}

- (void)resetMedia
{
    //if (!_willPlay)
    {
        [_videoContainerView resetPlayer:true];
    }
}

- (void)pauseMedia
{
    if (_videoContainerView.moviePlayer != nil)
        [_videoContainerView pausePlayer];
}

- (void)prepareToPlay
{
    [_videoContainerView setPlayButtonHidden:true];
    _willPlay = true;
    [_videoContainerView joinDownload:true];
}

- (void)playMedia
{
    if (!_videoContainerView.hidden)
        [_videoContainerView play];
    _willPlay = false;
}

- (bool)isScrubbing
{
    return _videoContainerView.isScrubbing;
}

- (bool)isPlaying
{
    return _videoContainerView.playButton.hidden;
}

- (bool)isZoomed
{
    bool haveImage = _imageView.currentImage != nil;
    bool havePlaceholderImage = _imageView.currentPlaceholderImage != nil;
    
    return _scrollView.zoomScale > _scrollView.adjustedZoomScale + FLT_EPSILON || !(haveImage || havePlaceholderImage);
}

- (void)offsetContent:(CGPoint)offset
{
    _scrollView.scrollEnabled = false;
    _scrollView.contentOffset = CGPointMake(_scrollView.contentOffset.x + offset.x, _scrollView.contentOffset.y + offset.y);
}

- (void)controlsAlphaUpdated:(float)alpha
{
    CGRect statusBarFrame = [[UIApplication sharedApplication] statusBarFrame];
    float statusBarHeight = MIN(statusBarFrame.size.width, statusBarFrame.size.height);
    _statusBarHeight = statusBarHeight;
    
    [self updateControlsOffset:_controlsOffset];
    
    _controlsAlpha = alpha;
    [_videoContainerView updateControlsAlpha:alpha];
    
    _topProgressViewContainer.alpha = _controlsAlpha > FLT_EPSILON ? 1.0f : 0.0f;
    _bottomProgressViewContainer.alpha = _controlsAlpha > FLT_EPSILON ? 0.0f : 1.0f;
}

- (void)updateControlsOffset:(float)offsetY
{
    _controlsOffset = offsetY;
    
    CGRect frame = _videoContainerView.controlsContainer.frame;
    frame.origin.y = _statusBarHeight + (frame.size.width < 400 ? 44 : 32) - offsetY;
    _videoContainerView.controlsContainer.frame = frame;
    
    self.clipsToBounds = false;
    
    _topProgressViewContainer.frame = CGRectMake(8, self.frame.size.height - 54 - offsetY, self.frame.size.width - 16, _topProgressViewContainer.frame.size.height);
    _bottomProgressViewContainer.frame = CGRectMake(8, self.frame.size.height - 10 - offsetY, self.frame.size.width - 16, _bottomProgressViewContainer.frame.size.height);
}

- (void)updateProgressAlpha:(float)alpha progress:(float)progress animated:(bool)animated
{
    bool animateProgress = true;
    
    if (_topProgressView.alpha < FLT_EPSILON && alpha > FLT_EPSILON && progress > FLT_EPSILON)
        animateProgress = false;
    
    if (animated)
    {
        if (ABS(_topProgressView.alpha - alpha) > FLT_EPSILON || ABS(_topProgressView.progress - progress) > FLT_EPSILON)
        {
            TGLinearProgressView *topProgressView = _topProgressView;
            TGLinearProgressView *bottomProgressView = _bottomProgressView;
            [UIView animateWithDuration:0.3 delay:0 options:UIViewAnimationOptionBeginFromCurrentState | UIViewAnimationOptionCurveEaseOut animations:^
            {
                topProgressView.alpha = alpha;
                bottomProgressView.alpha = alpha;
                if (animateProgress)
                {
                    [topProgressView setProgress:progress];
                    [bottomProgressView setProgress:progress];
                }
            } completion:nil];
            
            if (!animateProgress)
            {
                [_topProgressView setProgress:progress];
                [_bottomProgressView setProgress:progress];
            }
        }
    }
    else
    {
        _topProgressView.alpha = alpha;
        _bottomProgressView.alpha = alpha;
        _topProgressView.progress = progress;
        _bottomProgressView.progress = progress;
    }
    
    [self updateInterfaceView];
}

- (UIImage *)currentImage
{
    return [_imageView currentImage];
}

- (CGRect)currentImageFrameInView:(UIView *)view
{
    return [_imageView convertRect:_imageView.bounds toView:view];
}

- (NSString *)currentImageUrl
{
    return [_imageView currentUrl];
}

- (NSString *)currentVideoUrl
{
    if ([_imageItem type] == TGMediaItemTypeVideo)
    {
        return [[_imageItem videoAttachment].videoInfo urlWithQuality:1 actualQuality:NULL actualSize:NULL];
    }
    
    return nil;
}

- (void)hideInterface
{
    [_watcherHandle requestAction:@"hideInterface" options:nil];
}

- (void)scrollViewTapped
{
    [_watcherHandle requestAction:@"pageTapped" options:nil];
}

- (void)setScrollViewScaleToFill:(bool)scaleToFill
{
    [_scrollView setZoomScale:scaleToFill ? _scrollView.adjustedZoomScale : _scrollView.minimumZoomScale animated:true];
    CGSize contentSize = _scrollView.contentSize;
    CGSize viewSize = _scrollView.frame.size;
    [_scrollView setContentOffset:CGPointMake(MAX(0, floorf((contentSize.width - viewSize.width) / 2)), MAX(0, floorf((contentSize.height - viewSize.height) / 2))) animated:true];
}

- (void)scrollViewDoubleTapped:(CGPoint)point
{
    if (_scrollView.zoomScale < _scrollView.adjustedZoomScale + FLT_EPSILON)
    {
        CGPoint pointInView = [_scrollView convertPoint:point toView:_imageView];
        
        CGFloat newZoomScale = _scrollView.maximumZoomScale;
        newZoomScale = MIN(newZoomScale, _scrollView.maximumZoomScale);
        
        CGSize scrollViewSize = _scrollView.bounds.size;
        
        CGFloat w = scrollViewSize.width / newZoomScale;
        CGFloat h = scrollViewSize.height / newZoomScale;
        CGFloat x = pointInView.x - (w / 2.0f);
        CGFloat y = pointInView.y - (h / 2.0f);
        
        CGRect rectToZoomTo = CGRectMake(x, y, w, h);
        
        [_scrollView zoomToRect:rectToZoomTo animated:true];
    }
    else
    {
        [self setScrollViewScaleToFill:true];
    }
}

- (void)scalingModeChanged:(bool)scaleToFill
{
    [TGHacks setAnimationDurationFactor:scaleToFill ? 2.0f : 0.5f];
    [self setScrollViewScaleToFill:scaleToFill];
    [TGHacks setAnimationDurationFactor:1.0f];
}

- (bool)preferScaleToFill
{
    return [_scrollView isAdjustedToFill];
}

- (bool)shouldChangeScalingMode
{
    float minimumZoomScale = _scrollView.minimumZoomScale;
    float adjustedZoomScale = _scrollView.maximumZoomScale;
    return ABS(minimumZoomScale - adjustedZoomScale) > 0.001;
}

- (void)videoDimensionsAvailable:(CGSize)__unused dimensions
{
}

- (void)videoPlayerIsActive:(bool)active
{
    _imageView.hidden = active;
}

- (void)pageMediaPlaybackStateChanged:(bool)__unused paused
{
    [self updateInterfaceView];
}

- (void)updateInterfaceView
{
    bool isPlaying = [self isPlaying];
    
    [_interfaceHandle requestAction:@"mediaPlaybackState" options:[[NSDictionary alloc] initWithObjectsAndKeys:[[NSNumber alloc] initWithBool:[_imageItem type] == TGMediaItemTypeVideo], @"mediaIsPlayable", [[NSNumber alloc] initWithBool:isPlaying], @"isPlaying", nil]];
    
    [_interfaceHandle requestAction:@"mediaDownloadState" options:[[NSDictionary alloc] initWithObjectsAndKeys:[[NSNumber alloc] initWithBool:_topProgressView.alpha > FLT_EPSILON], @"downloadProgressVisible", nil]];
}

- (void)scrollViewLongPressed
{
    if (_imageView.currentUrl != nil && _imageView.currentImage != nil)
    {
        id<ASWatcher> watcher = _watcherHandle.delegate;
        if (watcher != nil && [watcher respondsToSelector:@selector(actionStageActionRequested:options:)])
        {
            [watcher actionStageActionRequested:@"pageLongPressed" options:[[NSDictionary alloc] initWithObjectsAndKeys:_itemId, @"itemId", nil]];
        }
    }
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    if (_delegate != nil)
        [_delegate pageWillBeginDragging:scrollView];
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    if (_delegate != nil)
        [_delegate pageDidScroll:scrollView];
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)__unused decelerate
{
    if (_delegate != nil)
        [_delegate pageDidEndDragging:scrollView];
}

- (void)scrollViewWillBeginZooming:(UIScrollView *)__unused scrollView withView:(UIView *)__unused view
{
}

- (void)scrollViewDidZoom:(UIScrollView *)__unused scrollView
{   
    [self adjustScrollView];
}

- (void)scrollViewDidEndZooming:(UIScrollView *)__unused scrollView withView:(UIView *)__unused view atScale:(float)__unused scale
{
    [self adjustScrollView];
}

- (UIView *)viewForZoomingInScrollView:(UIScrollView *)__unused scrollView
{
    return _imageView;
}

- (void)adjustScrollView
{
    if (_imageSize.width < FLT_EPSILON || _imageSize.height < FLT_EPSILON)
        return;
    
    CGFloat scaleWidth = _scrollView.frame.size.width / _imageSize.width;
    CGFloat scaleHeight = _scrollView.frame.size.height / _imageSize.height;
    CGFloat minScale = MIN(scaleWidth, scaleHeight);
    CGFloat maxScale = MAX(scaleWidth, scaleHeight);
    
    float adjustedScale = minScale;
    
    if (ABS(adjustedScale - scaleHeight) > FLT_EPSILON && _scrollView.frame.size.height - minScale * _imageSize.height < TG_ZOOM_ADJUSTMENT_THRESHOLD_HORIZONTAL)
        adjustedScale = scaleHeight;
    else if (ABS(adjustedScale - scaleWidth) > FLT_EPSILON && _scrollView.frame.size.width - minScale * _imageSize.width < TG_ZOOM_ADJUSTMENT_THRESHOLD_VERTICAL)
        adjustedScale = scaleWidth;
    
    bool isVideo = [_imageItem type] == TGMediaItemTypeVideo;
    
    if (_scrollView.minimumZoomScale != minScale)
        _scrollView.minimumZoomScale = minScale;
    
    if (!isVideo)
    {
        if (_scrollView.maximumZoomScale != minScale * 2.0f)
            _scrollView.maximumZoomScale = minScale * 2.0f;
    }
    else
    {
        if (ABS(maxScale - minScale) < 0.01)
            maxScale = minScale;
        
        if (_scrollView.maximumZoomScale != maxScale)
            _scrollView.maximumZoomScale = maxScale;
    }
    _scrollView.adjustedZoomScale = adjustedScale;
    
    CGSize boundsSize = _scrollView.bounds.size;
    CGRect contentsFrame = _imageView.frame;
    
    if (boundsSize.width > contentsFrame.size.width)
        contentsFrame.origin.x = (boundsSize.width - contentsFrame.size.width) / 2.0f;
    else
        contentsFrame.origin.x = 0;
    
    if (boundsSize.height > contentsFrame.size.height)
        contentsFrame.origin.y = (boundsSize.height - contentsFrame.size.height) / 2.0f;
    else
        contentsFrame.origin.y = 0;
    
    _imageView.frame = contentsFrame;
    
    [_scrollView updateZoomScale];
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    if (!CGRectEqualToRect(_scrollView.frame, self.bounds))
    {
        _scrollView.frame = self.bounds;
        [self adjustScrollView];
        
        bool scaleToFill = true;
        
        //if (!_videoContainerView.hidden && _videoContainerView.moviePlayer != nil)
        //    scaleToFill = _videoContainerView.moviePlayer.scalingMode == MPMovieScalingModeAspectFill;
        
        _scrollView.zoomScale = scaleToFill ? _scrollView.adjustedZoomScale : _scrollView.minimumZoomScale;
        CGSize contentSize = _scrollView.contentSize;
        CGSize viewSize = _scrollView.frame.size;
        _scrollView.contentOffset = CGPointMake(MAX(0, floorf((contentSize.width - viewSize.width) / 2)), MAX(0, floorf((contentSize.height - viewSize.height) / 2)));
        
        _videoContainerView.frame = self.bounds;
        [_videoContainerView updateScaleMode];
    }
}

- (void)willAnimateRotation
{
    if (!_videoContainerView.hidden && _videoContainerView.moviePlayer != nil)
    {
        _videoContainerView.moviePlayer.scalingMode = MPMovieScalingModeAspectFit;
        _imageView.hidden = true;
    }
}

- (void)didAnimateRotation
{
    if (!_videoContainerView.hidden && _videoContainerView.moviePlayer != nil)
    {
        _imageView.hidden = false;
        
        bool scaleToFill = true;
        
        if (!_videoContainerView.hidden && _videoContainerView.moviePlayer != nil)
            scaleToFill = _videoContainerView.moviePlayer.scalingMode == MPMovieScalingModeAspectFill;
        
        _scrollView.zoomScale = scaleToFill ? _scrollView.adjustedZoomScale : _scrollView.minimumZoomScale;
        CGSize contentSize = _scrollView.contentSize;
        CGSize viewSize = _scrollView.frame.size;
        _scrollView.contentOffset = CGPointMake(MAX(0, floorf((contentSize.width - viewSize.width) / 2)), MAX(0, floorf((contentSize.height - viewSize.height) / 2)));
    }
}

- (void)actionStageResourceDispatched:(NSString *)path resource:(id)resource arguments:(id)__unused arguments
{
    if ([path isEqualToString:@"/as/media/previewReady"])
    {
        dispatch_async(dispatch_get_main_queue(), ^
        {
            if ([_imageItem type] == TGMediaItemTypeVideo)
            {
                TGVideoMediaAttachment *videoAttachment = [_imageItem videoAttachment];
                if (videoAttachment != nil && videoAttachment.videoId == [[resource objectForKey:@"videoId"] longLongValue])
                    [_imageView loadImage:[resource objectForKey:@"image"]];
            }
        });
    }
}

- (void)actorCompleted:(int)resultCode path:(NSString *)path result:(id)result
{
    dispatch_async(dispatch_get_main_queue(), ^
    {
        if ([path isEqualToString:_currentThumbnailPath])
        {
            if (resultCode == ASStatusSuccess)
            {
                UIImage *image = ((SGraphObjectNode *)result).object;
                if (image != nil)
                {
                    [_imageView loadPlaceholder:image];
                }
            }
        }
    });
}

- (void)actionStageActionRequested:(NSString *)action options:(id)options
{
    if ([action isEqualToString:@"updateProgress"])
    {
        if ([_imageItem type] == TGMediaItemTypePhoto)
        {
            float progress = [options floatValue];
            [self updateProgressAlpha:progress < 1.0f - FLT_EPSILON progress:progress animated:true];
        }
    }
    else if ([action isEqualToString:@"bindInterfaceView"])
    {
        _interfaceHandle = options;
        
        if (_interfaceHandle != nil)
        {
            [self updateInterfaceView];
            [_videoContainerView joinDownload:false];
        }
    
        if ([_imageItem type] == TGMediaItemTypePhoto)
        {   
            CGSize size = CGSizeZero;
            NSString *url = [[_imageItem imageInfo] closestImageUrlWithSize:CGSizeMake(1136, 1136) resultingSize:&size pickLargest:true];
            
            [ActionStageInstance() changeActorPriority:[NSString stringWithFormat:@"/img/(download:{filter:%@}%@)", @"maybeScale", url]];
        }
        else if ([_imageItem type] == TGMediaItemTypeVideo)
        {
            NSString *url = [[_imageItem videoAttachment].videoInfo urlWithQuality:1 actualQuality:NULL actualSize:NULL];
            if (url != nil)
            {
                NSString *path = [[NSString alloc] initWithFormat:@"/as/media/video/(%@)", url];
                
                [ActionStageInstance() changeActorPriority:path];
            }
        }
    }
    else if ([action isEqualToString:@"playMedia"])
    {
        [self playMedia];
    }
    else if ([action isEqualToString:@"pauseMedia"])
    {
        [self pauseMedia];
    }
}

@end
