#import "TGEmbedPIPView.h"
#import <SSignalKit/SSignalKit.h>

#import "TGImageUtils.h"
#import "TGTimerTarget.h"

#import "TGEmbedPIPButton.h"
#import "TGEmbedPIPScrubber.h"
#import "TGEmbedPIPPullArrowView.h"

#import "TGPIPAblePlayerView.h"

const CGSize TGEmbedPIPViewDefaultSize = { 220, 300 };
const CGSize TGEmbedPIPViewDefaultPadSize = { 300, 300 };
const CGFloat TGEmbedPIPSlipSize = 40.0f;

@interface TGEmbedPIPView ()
{
    UIImageView *_shadowView;
    UIView *_wrapperView;
        
    UIButton *_controlsView;
    TGEmbedPIPButton *_switchBackButton;
    TGEmbedPIPButton *_playPauseButton;
    TGEmbedPIPButton *_closeButton;
    
    TGEmbedPIPScrubber *_scrubber;
    
    UIVisualEffectView *_overlayBlurView;
    TGEmbedPIPPullArrowView *_arrowView;
    
    SMetaDisposable *_stateDisposable;
    bool _playing;
    
    NSTimer *_hideControlsTimer;
    bool _controlsHidden;
    
    bool _arrowOnRightSide;
    
    UITapGestureRecognizer *_gestureRecognizer;
}
@end

@implementation TGEmbedPIPView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self != nil)
    {
        _shadowView = [[UIImageView alloc] initWithImage:[[UIImage imageNamed:@"PictureInPictureShadow"] resizableImageWithCapInsets:UIEdgeInsetsMake(22, 25, 26, 25) resizingMode:UIImageResizingModeStretch]];
        [self addSubview:_shadowView];
        
        _wrapperView = [[UIView alloc] initWithFrame:self.bounds];
        _wrapperView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        _wrapperView.clipsToBounds = true;
        _wrapperView.layer.cornerRadius = 2.5f;
        [self addSubview:_wrapperView];
        
        _controlsView = [[UIButton alloc] initWithFrame:_wrapperView.bounds];
        _controlsView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        _controlsView.exclusiveTouch = true;
        [_controlsView addTarget:self action:@selector(areaPressed) forControlEvents:UIControlEventTouchUpInside];
        [_wrapperView addSubview:_controlsView];
        
        _switchBackButton = [[TGEmbedPIPButton alloc] initWithFrame:(CGRect){ CGPointZero, TGEmbedPIPButtonSize }];
        [_switchBackButton setIconImage:[UIImage imageNamed:@"PictureInPictureExit"]];
        [_switchBackButton addTarget:self action:@selector(switchBackButtonPressed) forControlEvents:UIControlEventTouchUpInside];
        [_controlsView addSubview:_switchBackButton];
        
        _playPauseButton = [[TGEmbedPIPButton alloc] initWithFrame:(CGRect){ CGPointZero, TGEmbedPIPButtonSize }];
        [_playPauseButton setIconImage:[UIImage imageNamed:@"PictureInPicturePause"]];
        [_playPauseButton addTarget:self action:@selector(playPauseButtonPressed) forControlEvents:UIControlEventTouchUpInside];
        [_controlsView addSubview:_playPauseButton];
        
        _closeButton = [[TGEmbedPIPButton alloc] initWithFrame:(CGRect){ CGPointZero, TGEmbedPIPButtonSize }];
        [_closeButton setIconImage:[UIImage imageNamed:@"PictureInPictureClose"]];
        [_closeButton addTarget:self action:@selector(closeButtonPressed) forControlEvents:UIControlEventTouchUpInside];
        [_controlsView addSubview:_closeButton];
        
        _scrubber = [[TGEmbedPIPScrubber alloc] initWithFrame:CGRectMake(0, 0, 0, 3)];
        [_controlsView addSubview:_scrubber];
        
        _overlayBlurView = [[UIVisualEffectView alloc] initWithEffect:nil];
        _overlayBlurView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        _overlayBlurView.frame = _wrapperView.bounds;
        _overlayBlurView.hidden = true;
        [_wrapperView addSubview:_overlayBlurView];
        
        _arrowView = [[TGEmbedPIPPullArrowView alloc] initWithFrame:CGRectMake(0, 0, 8, 38)];
        _arrowView.alpha = 0.0f;
        [_overlayBlurView.contentView addSubview:_arrowView];
        
        _gestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTap:)];
        [self addGestureRecognizer:_gestureRecognizer];
        
        _stateDisposable = [[SMetaDisposable alloc] init];
    }
    return self;
}

- (void)dealloc
{
    [_stateDisposable dispose];
}

- (void)handleTap:(UITapGestureRecognizer *)__unused gestureRecognizer
{
    if (self.arrowPressed != nil)
        self.arrowPressed();
}

#pragma mark -

- (void)setPlayerView:(UIView<TGPIPAblePlayerView> *)playerView
{
    if (_playerView != nil)
    {
        [_playerView removeFromSuperview];
        _playerView = nil;
    }
    
    _playerView = playerView;
    [_playerView _prepareToEnterFullscreen];
    [_wrapperView insertSubview:playerView belowSubview:_controlsView];
    
    [self setState:_playerView.state];
    
    __weak TGEmbedPIPView *weakSelf = self;
    [_stateDisposable setDisposable:[_playerView.stateSignal startWithNext:^(id next)
    {
        __strong TGEmbedPIPView *strongSelf = weakSelf;
        if (strongSelf != nil)
            [strongSelf setState:next];
    }]];
}

- (void)setFrame:(CGRect)frame
{
    CGFloat scale = frame.size.width / _playerView.initialFrame.size.width;
    [super setFrame:frame];
    
    _playerView.transform = CGAffineTransformMakeScale(scale, scale);
    _playerView.center = CGPointMake(CGRectGetMidX(self.bounds), CGRectGetMidY(self.bounds));
}

#pragma mark -

- (void)setState:(id<TGPIPAblePlayerState>)state
{
    NSTimeInterval duration = state.duration > FLT_EPSILON ? state.duration : 1.0f;
    _scrubber.playProgress = state.position / duration;
    _scrubber.downloadProgress = state.downloadProgress;
    _scrubber.hidden = (state.duration < FLT_EPSILON);
    
    _playing = state.isPlaying;
    [_playPauseButton setIconImage:[UIImage imageNamed:_playing ? @"PictureInPicturePause" : @"PictureInPicturePlay"]];
    
    if (!_playing && _controlsHidden)
    {
        [self setControlsHidden:false animated:true];
    }
    else
    {
        if (!_playing && _hideControlsTimer != nil)
            [self _invalidateTimer];
        else
            [self _startTimerIfNeeded];
    }
}

- (void)setPanning:(bool)panning
{
    [_arrowView setAngled:!panning animated:true];
}

- (void)setArrowOnRightSide:(bool)flag
{
    _arrowOnRightSide = flag;
    [self setNeedsLayout];
}

- (void)setClosing
{
    [self _invalidateTimer];
    [_controlsView removeFromSuperview];
}

- (void)invalidate
{
    [self removeGestureRecognizer:_gestureRecognizer];
}

#pragma mark -

- (void)hideControlsEvent
{
    [self _invalidateTimer];
    [self setControlsHidden:true animated:true];
}

- (void)_startTimer
{
    _hideControlsTimer = [TGTimerTarget scheduledMainThreadTimerWithTarget:self action:@selector(hideControlsEvent) interval:3.0 repeat:false];
}

- (void)_startTimerIfNeeded
{
    if (_playing && !_controlsHidden && _hideControlsTimer == nil)
        [self _startTimer];
}

- (void)_invalidateTimer
{
    [_hideControlsTimer invalidate];
    _hideControlsTimer = nil;
}

#pragma mark - 

- (void)areaPressed
{
    if (_playing)
        [self setControlsHidden:!_controlsHidden animated:true];
}

- (void)switchBackButtonPressed
{
    _switchBackButton.userInteractionEnabled = false;
    [self invalidate];
    
    if (self.switchBackPressed != nil)
        self.switchBackPressed();
}

- (void)playPauseButtonPressed
{
    if (_playerView.state.isPlaying)
        [_playerView pauseVideo];
    else
        [_playerView playVideo];
}

- (void)closeButtonPressed
{
    _closeButton.userInteractionEnabled = false;
    
    if (self.closePressed != nil)
        self.closePressed();
}

- (void)setControlsHidden:(bool)hidden animated:(bool)animated
{
    if (_controlsHidden == hidden)
        return;
    
    _controlsHidden = hidden;
    
    CGFloat targetAlpha = hidden ? 0.0f : 1.0f;
    
    void (^changeBlock)(void) = ^
    {
        _switchBackButton.alpha = targetAlpha;
        _playPauseButton.alpha = targetAlpha;
        _closeButton.alpha = targetAlpha;
        _scrubber.alpha = targetAlpha;
    };
    
    _switchBackButton.userInteractionEnabled = !hidden;
    _playPauseButton.userInteractionEnabled = !hidden;
    _closeButton.userInteractionEnabled = !hidden;
    
    if (animated)
        [UIView animateWithDuration:0.25 animations:changeBlock];
    else
        changeBlock();
}

#pragma mark - 

- (void)setBlurred:(bool)blurred animated:(bool)animated
{
    if ((blurred && _overlayBlurView.effect != nil) || (!blurred && _overlayBlurView.effect == nil))
        return;
    
    UIVisualEffect *effect = blurred ? [UIBlurEffect effectWithStyle:UIBlurEffectStyleLight] : nil;
    if (animated)
    {
        if (blurred)
            _overlayBlurView.hidden = false;
        
        [UIView animateWithDuration:0.35 animations:^
        {
            _overlayBlurView.effect = effect;
            _arrowView.alpha = blurred ? 1.0f : 0.0f;
        } completion:^(BOOL finished)
        {
            if (finished && !blurred)
                _overlayBlurView.hidden = true;
        }];
    }
    else
    {
        _overlayBlurView.effect = effect;
        _overlayBlurView.hidden = !blurred;
        _arrowView.alpha = blurred ? 1.0f : 0.0f;
    }
}

#pragma mark -

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    CGFloat arrowX = 0;
    if (_arrowOnRightSide)
    {
        _arrowView.transform = CGAffineTransformMakeScale(-1.0f, 1.0f);
        arrowX = floor((TGEmbedPIPSlipSize - _arrowView.frame.size.width) / 2.0f);
    }
    else
    {
        _arrowView.transform = CGAffineTransformIdentity;
        arrowX = _wrapperView.frame.size.width - TGEmbedPIPSlipSize + floor((TGEmbedPIPSlipSize - _arrowView.frame.size.width) / 2.0f);
    }
    
    _arrowView.frame = CGRectMake(arrowX, floor((_wrapperView.frame.size.height - _arrowView.frame.size.height) / 2.0f), _arrowView.frame.size.width, _arrowView.frame.size.height);
    
    _shadowView.frame = CGRectMake(-13.5f, -11.5f, _wrapperView.frame.size.width + 27.0f, _wrapperView.frame.size.height + 27.0f);
    _scrubber.frame = CGRectMake(0, _controlsView.frame.size.height - _scrubber.frame.size.height, _controlsView.frame.size.width, _scrubber.frame.size.height);
    
    CGFloat forth = floor(self.frame.size.width / 4.0f);
    
    _switchBackButton.frame = CGRectMake(forth - floor(_switchBackButton.frame.size.width / 2.0f) - 10.0f, self.frame.size.height - _switchBackButton.frame.size.height - 15.0f, _switchBackButton.frame.size.width, _switchBackButton.frame.size.height);
    
    _playPauseButton.frame = CGRectMake(floor((self.frame.size.width - _playPauseButton.frame.size.width) / 2.0f), self.frame.size.height - _playPauseButton.frame.size.height - 15.0f, _playPauseButton.frame.size.width, _playPauseButton.frame.size.height);
    
    _closeButton.frame = CGRectMake(_playPauseButton.frame.origin.x + forth + 10.0f, self.frame.size.height - _closeButton.frame.size.height - 15.0f, _closeButton.frame.size.width, _closeButton.frame.size.height);
}

#pragma mark - 

+ (CGSize)defaultSize
{
    if (TGIsPad())
        return TGEmbedPIPViewDefaultPadSize;
    else
        return TGEmbedPIPViewDefaultSize;
}

@end
