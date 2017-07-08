#import "TGEmbedPlayerController.h"
#import "TGOverlayControllerWindow.h"

#import "TGFont.h"
#import <pop/POP.h>
#import "TGHacks.h"
#import "TGImageUtils.h"
#import "TGPhotoEditorUtils.h"

#import "TGModernButton.h"
#import "TGEmbedPlayerView.h"
#import "TGEmbedPlayerScrubber.h"

#import "TGEmbedPlayerState.h"

#import "TGEmbedItemView.h"

#import "TGModernGalleryZoomableScrollViewSwipeGestureRecognizer.h"
#import "JNWSpringAnimation.h"
#import "TGAnimationBlockDelegate.h"

#import <MediaPlayer/MediaPlayer.h>

const CGFloat TGEmbedSwipeMinimumVelocity = 600.0f;
const CGFloat TGEmbedSwipeVelocityThreshold = 700.0f;
const CGFloat TGEmbedSwipeDistanceThreshold = 128.0f;

@interface TGEmbedPlayerController ()
{
    UIView *_backView;
    UIView *_curtainView;
    TGEmbedPlayerView *_playerView;
    
    SMetaDisposable *_stateDisposable;
    
    CGRect _initialPlayerFrame;
    
    UIButton *_wrapperView;
    UIView *_topPanelView;
    UILabel *_positionLabel;
    UILabel *_remainingLabel;
    TGEmbedPlayerScrubber *_scrubber;
    UIButton *_pipButton;
    UIButton *_doneButton;
    
    TGModernButton *_fitButton;
    
    UIView *_bottomPanelView;
    UIButton *_playButton;
    UIButton *_pauseButton;
    UIButton *_scanBackwardButton;
    UIButton *_scanForwardButton;
    UIButton *_exitFullscreenButton;
    UIView *_volumeView;
    
    TGModernGalleryZoomableScrollViewSwipeGestureRecognizer *_panGestureRecognizer;
    CGFloat _dismissProgress;
    bool _appearing;
    bool _dismissing;
    
    bool _aboveStatusBar;
    
    MPVolumeView *_volumeOverlayFix;

}

@property (nonatomic, copy) CGRect (^transitionSourceFrame)(void);

@end

@implementation TGEmbedPlayerController

- (instancetype)initWithParentController:(TGViewController *)parentController playerView:(TGEmbedPlayerView *)playerView transitionSourceFrame:(CGRect (^)(void))transitionSourceFrame
{
    self = [super init];
    if (self != nil)
    {
        _playerView = playerView;
        self.transitionSourceFrame = transitionSourceFrame;
        
        self.isImportant = true;
        
        TGOverlayControllerWindow *window = [[TGOverlayControllerWindow alloc] initWithParentController:parentController contentController:self keepKeyboard:true];
        window.windowLevel = UIWindowLevelStatusBar - 0.0001;
        window.hidden = false;
    }
    return self;
}

- (void)dealloc
{
    [_stateDisposable dispose];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)setAboveStatusBar
{
    _aboveStatusBar = true;
    self.view.window.windowLevel = 1000000100.0f;
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationDidBecomeActive:) name:UIApplicationDidBecomeActiveNotification object:nil];
}

- (void)applicationDidBecomeActive:(NSNotification *)__unused notification
{
    [self.view.window makeKeyAndVisible];
}

- (void)loadView
{
    [super loadView];
    
    _backView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 1280, 1280)];
    _backView.autoresizingMask = UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleBottomMargin;
    _backView.backgroundColor = [UIColor blackColor];
    _backView.center = self.view.center;
    _backView.hidden = true;
    [self.view addSubview:_backView];
    
    _curtainView = [[UIView alloc] initWithFrame:CGRectZero];
    _curtainView.backgroundColor = [UIColor blackColor];
    [self.view addSubview:_curtainView];
    
    _wrapperView = [[UIButton alloc] initWithFrame:self.view.bounds];
    _wrapperView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    _wrapperView.exclusiveTouch = true;
    [_wrapperView addTarget:self action:@selector(handleTap:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_wrapperView];
    
    UIBlurEffect *topPanelBlurEffect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleLight];
    _topPanelView = [[UIVisualEffectView alloc] initWithEffect:topPanelBlurEffect];
    _topPanelView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    _topPanelView.frame = CGRectMake(0, 0, self.view.bounds.size.width, 50);
    _topPanelView.alpha = 0.0f;
    _topPanelView.userInteractionEnabled = false;
    [_wrapperView addSubview:_topPanelView];
    
    _doneButton = [[UIButton alloc] initWithFrame:CGRectZero];
    _doneButton.exclusiveTouch = true;
    _doneButton.titleLabel.font = TGMediumSystemFontOfSize(18.0f);
    [_doneButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [_doneButton setTitleColor:[UIColor whiteColor] forState:UIControlStateHighlighted];
    [_doneButton setTitle:TGLocalized(@"Common.Done") forState:UIControlStateNormal];
    [_doneButton addTarget:self action:@selector(closeButtonPressed) forControlEvents:UIControlEventTouchUpInside];
    [_doneButton sizeToFit];
    [_topPanelView addSubview:_doneButton];
    
    CGFloat doneButtonWidth = MAX(74.0f, _doneButton.frame.size.width);
    _doneButton.frame = CGRectMake(-0.5f, 18.5f, doneButtonWidth, 30.0f);
    
    _positionLabel = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetMaxX(_doneButton.frame) - 4.0f, 13.0, 56.0f, 44.0f)];
    _positionLabel.backgroundColor = [UIColor clearColor];
    _positionLabel.font = TGSystemFontOfSize(13.0f);
    _positionLabel.text = @"0:00";
    _positionLabel.textAlignment = NSTextAlignmentCenter;
    _positionLabel.textColor = [UIColor blackColor];
    _positionLabel.userInteractionEnabled = false;
    [_topPanelView addSubview:_positionLabel];
    
    _remainingLabel = [[UILabel alloc] initWithFrame:CGRectMake(self.view.frame.size.width - 104.0f, 13.0f, 56, 44.0f)];
    _remainingLabel.backgroundColor = [UIColor clearColor];
    _remainingLabel.font = TGSystemFontOfSize(13.0f);
    _remainingLabel.text = @"-0:00";
    _remainingLabel.textAlignment = NSTextAlignmentCenter;
    _remainingLabel.textColor = [UIColor blackColor];
    _remainingLabel.userInteractionEnabled = false;
    [_topPanelView addSubview:_remainingLabel];
    
    __weak TGEmbedPlayerController *weakSelf = self;
    _scrubber = [[TGEmbedPlayerScrubber alloc] initWithFrame:CGRectMake(CGRectGetMaxX(_positionLabel.frame) - 7.0f, 33.5f, 100, 3)];
    _scrubber.onSeek = ^(CGFloat position)
    {
        __strong TGEmbedPlayerController *strongSelf = weakSelf;
        if (strongSelf != nil)
            [strongSelf->_playerView seekToFractPosition:position];
    };
    [_topPanelView addSubview:_scrubber];
    
    if ([_playerView supportsPIP] && !TGIsPad())
    {
        _pipButton = [[UIButton alloc] initWithFrame:CGRectMake(self.view.frame.size.width - 50.0f, 13.0f, 50.0f, 44.0f)];
        _pipButton.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin;
        [_pipButton setImage:TGTintedImage([UIImage imageNamed:@"EmbedVideoPIPIcon"], [UIColor blackColor]) forState:UIControlStateNormal];
        [_pipButton setImage:TGTintedImage([UIImage imageNamed:@"EmbedVideoPIPIcon"], [UIColor whiteColor]) forState:UIControlStateHighlighted];
        [_pipButton addTarget:self action:@selector(pipButtonPressed) forControlEvents:UIControlEventTouchUpInside];
        [_topPanelView addSubview:_pipButton];
    }

    UIBlurEffect *bottomPanelBlurEffect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleLight];
    _bottomPanelView = [[UIVisualEffectView alloc] initWithEffect:bottomPanelBlurEffect];
    _bottomPanelView.alpha = 0.0f;
    _bottomPanelView.userInteractionEnabled = false;
    [_wrapperView addSubview:_bottomPanelView];
    
    _playButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 50, 45)];
    _playButton.adjustsImageWhenHighlighted = false;
    _playButton.exclusiveTouch = true;
    [_playButton setImage:[UIImage imageNamed:@"EmbedPlayButton"] forState:UIControlStateNormal];
    [_playButton setImage:TGTintedImage([UIImage imageNamed:@"EmbedPlayButton"], [UIColor whiteColor]) forState:UIControlStateHighlighted];
    [_playButton addTarget:self action:@selector(playButtonPressed) forControlEvents:UIControlEventTouchUpInside];
    [_bottomPanelView addSubview:_playButton];
    
    _pauseButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 50, 45)];
    _pauseButton.adjustsImageWhenHighlighted = false;
    _pauseButton.exclusiveTouch = true;
    [_pauseButton setImage:[UIImage imageNamed:@"EmbedPauseButton"] forState:UIControlStateNormal];
    [_pauseButton setImage:TGTintedImage([UIImage imageNamed:@"EmbedPauseButton"], [UIColor whiteColor]) forState:UIControlStateHighlighted];
    [_pauseButton addTarget:self action:@selector(pauseButtonPressed) forControlEvents:UIControlEventTouchUpInside];
    [_bottomPanelView addSubview:_pauseButton];
    
    _scanBackwardButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 50, 45)];
    _scanBackwardButton.adjustsImageWhenHighlighted = false;
    _scanBackwardButton.exclusiveTouch = true;
    [_scanBackwardButton setImage:[UIImage imageNamed:@"EmbedScanBackwardButton"] forState:UIControlStateNormal];
    [_scanBackwardButton setImage:TGTintedImage([UIImage imageNamed:@"EmbedScanBackwardButton"], [UIColor whiteColor]) forState:UIControlStateHighlighted];
    [_scanBackwardButton addTarget:self action:@selector(scanBackwardButtonPressed) forControlEvents:UIControlEventTouchUpInside];
    [_bottomPanelView addSubview:_scanBackwardButton];
    
    _scanForwardButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 50, 45)];
    _scanForwardButton.adjustsImageWhenHighlighted = false;
    _scanForwardButton.exclusiveTouch = true;
    [_scanForwardButton setImage:[UIImage imageNamed:@"EmbedScanForwardButton"] forState:UIControlStateNormal];
    [_scanForwardButton setImage:TGTintedImage([UIImage imageNamed:@"EmbedScanForwardButton"], [UIColor whiteColor]) forState:UIControlStateHighlighted];
    [_scanForwardButton addTarget:self action:@selector(scanForwardButtonPressed) forControlEvents:UIControlEventTouchUpInside];
    [_bottomPanelView addSubview:_scanForwardButton];
    
    static UIImage *minimumTrackImage = nil;
    static UIImage *maximumTrackImage = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^
    {
        {
            UIGraphicsBeginImageContextWithOptions(CGSizeMake(6.0f, 3.0f), false, 0.0f);
            CGContextRef context = UIGraphicsGetCurrentContext();
            CGContextSetFillColorWithColor(context, UIColorRGB(0xffffff).CGColor);
            CGContextFillEllipseInRect(context, CGRectMake(0.0f, 0.0f, 3.0f, 3.0f));
            CGContextFillEllipseInRect(context, CGRectMake(3.0f, 0.0f, 3.0f, 3.0f));
            CGContextFillRect(context, CGRectMake(1.5f, 0.0f, 3.0f, 3.0f));
            minimumTrackImage = [UIGraphicsGetImageFromCurrentImageContext() stretchableImageWithLeftCapWidth:3.0f topCapHeight:0.0f];
            UIGraphicsEndImageContext();
        }
        {
            UIGraphicsBeginImageContextWithOptions(CGSizeMake(6.0f, 3.0f), false, 0.0f);
            CGContextRef context = UIGraphicsGetCurrentContext();
            CGContextSetFillColorWithColor(context, UIColorRGB(0x000000).CGColor);
            CGContextFillEllipseInRect(context, CGRectMake(0.0f, 0.0f, 3.0f, 3.0f));
            CGContextFillEllipseInRect(context, CGRectMake(3.0f, 0.0f, 3.0f, 3.0f));
            CGContextFillRect(context, CGRectMake(1.5f, 0.0f, 3.0f, 3.0f));
            maximumTrackImage = [UIGraphicsGetImageFromCurrentImageContext() stretchableImageWithLeftCapWidth:3.0f topCapHeight:0.0f];
            UIGraphicsEndImageContext();
        }
    });
    
#if TARGET_IPHONE_SIMULATOR
    UISlider *sliderView = [[UISlider alloc] init];
    [sliderView setMinimumTrackImage:minimumTrackImage forState:UIControlStateNormal];
    [sliderView setMaximumTrackImage:maximumTrackImage forState:UIControlStateNormal];
    [sliderView setThumbImage:[UIImage imageNamed:@"VolumeControlSliderButton.png"] forState:UIControlStateNormal];
    [sliderView setValue:0.5f];
    _volumeView = sliderView;
#else
    MPVolumeView *volumeView = [[MPVolumeView alloc] init];
    [volumeView setMinimumVolumeSliderImage:minimumTrackImage forState:UIControlStateNormal];
    [volumeView setMaximumVolumeSliderImage:maximumTrackImage forState:UIControlStateNormal];
    [volumeView setVolumeThumbImage:[UIImage imageNamed:@"VolumeControlSliderButton.png"] forState:UIControlStateNormal];
    volumeView.showsRouteButton = false;
    _volumeView = volumeView;
#endif
    
    [_bottomPanelView addSubview:_volumeView];
    
    _exitFullscreenButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 50, 50)];
    _exitFullscreenButton.adjustsImageWhenHighlighted = false;
    _exitFullscreenButton.exclusiveTouch = true;
    [_exitFullscreenButton setImage:[UIImage imageNamed:@"EmbedExitFullScreenButton"] forState:UIControlStateNormal];
    [_exitFullscreenButton setImage:TGTintedImage([UIImage imageNamed:@"EmbedExitFullScreenButton"], [UIColor whiteColor]) forState:UIControlStateHighlighted];
    [_exitFullscreenButton addTarget:self action:@selector(closeButtonPressed) forControlEvents:UIControlEventTouchUpInside];
    [_bottomPanelView addSubview:_exitFullscreenButton];
    
    if ([_playerView _controlsType] == TGEmbedPlayerControlsTypeSimple)
    {
        _scanBackwardButton.hidden = true;
        _scanForwardButton.hidden = true;
        _scrubber.hidden = true;
        _positionLabel.hidden = true;
        _remainingLabel.hidden = true;
    }
    
    _stateDisposable = [[SMetaDisposable alloc] init];
    
    [self.view insertSubview:_playerView aboveSubview:_curtainView];
    
    if (self.transitionSourceFrame != nil)
    {
        _playerView.frame = self.transitionSourceFrame();
        _initialPlayerFrame = _playerView.frame;
        _curtainView.frame = _playerView.frame;
    }
    
    _appearing = true;
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    _appearing = false;
    
    [_playerView _prepareToEnterFullscreen];
    [self updateState:_playerView.state];
    
    __weak TGEmbedPlayerController *weakSelf = self;
    [_stateDisposable setDisposable:[_playerView.stateSignal startWithNext:^(id next)
    {
        __strong TGEmbedPlayerController *strongSelf = weakSelf;
        if (strongSelf != nil)
            [strongSelf updateState:next];
    }]];
    
    CGRect targetFrame = [self _playerRectForSize:self.view.frame.size];
    CGPoint targetCenter = CGPointMake(CGRectGetMidX(targetFrame), CGRectGetMidY(targetFrame));
    CGFloat scale = targetFrame.size.width / _playerView.frame.size.width;
    
    bool fromRotation = false;
    NSTimeInterval duration = 0.4;
    if (self.transitionDuration > DBL_EPSILON)
    {
        _requestedFromRotation = true;
        fromRotation = true;
        duration = self.transitionDuration;
        _curtainView.hidden = true;
    }
    
    [UIView animateWithDuration:duration animations:^
    {
        _playerView.center = targetCenter;
        _playerView.transform = CGAffineTransformMakeScale(scale, scale);
        _curtainView.center = targetCenter;
        _curtainView.bounds = self.view.bounds;
    } completion:^(__unused BOOL finished)
    {
        _backView.hidden = false;
        _curtainView.hidden = false;
        
        if (!fromRotation)
            [self setControlsHidden:false animated:true];
    }];

    _panGestureRecognizer = [[TGModernGalleryZoomableScrollViewSwipeGestureRecognizer alloc] initWithTarget:self action:@selector(handlePan:)];
    _panGestureRecognizer.delaysTouchesBegan = true;
    _panGestureRecognizer.cancelsTouchesInView = false;
    [_wrapperView addGestureRecognizer:_panGestureRecognizer];
    
    if (fromRotation && !_aboveStatusBar)
        [TGHacks setApplicationStatusBarAlpha:0.0f];
}

#pragma mark -

- (void)handleTap:(id)__unused sender
{
    [self setControlsHidden:_topPanelView.userInteractionEnabled animated:true updateStatusBar:true];
}

- (void)handlePan:(TGModernGalleryZoomableScrollViewSwipeGestureRecognizer *)gestureRecognizer
{
    switch (gestureRecognizer.state)
    {
        case UIGestureRecognizerStateChanged:
        {
            _dismissProgress = [self dismissProgressForSwipeDistance:[gestureRecognizer swipeDistance]];
            [self _updateDismissTransitionWithProgress:_dismissProgress animated:false];
            [self _updateDismissTransitionMovementWithDistance:[gestureRecognizer swipeDistance] animated:false];
        }
            break;
            
        case UIGestureRecognizerStateEnded:
        {
            CGFloat swipeVelocity = [gestureRecognizer swipeVelocity];
            if (ABS(swipeVelocity) < TGEmbedSwipeMinimumVelocity)
                swipeVelocity = (swipeVelocity < 0.0f ? -1.0f : 1.0f) * TGEmbedSwipeMinimumVelocity;
            
            __weak TGEmbedPlayerController *weakSelf = self;
            bool(^transitionOut)(CGFloat) = ^bool(CGFloat swipeVelocity)
            {
                __strong TGEmbedPlayerController *strongSelf = weakSelf;
                if (strongSelf == nil)
                    return false;
                
                [strongSelf beginTransitionOutWithVelocity:swipeVelocity];
                
                return true;
            };
            
            if ((ABS(swipeVelocity) < TGEmbedSwipeVelocityThreshold && ABS([gestureRecognizer swipeDistance]) < TGEmbedSwipeDistanceThreshold) || !transitionOut(swipeVelocity))
            {
                _dismissProgress = 0.0f;
                [self _updateDismissTransitionWithProgress:0.0f animated:true];
                [self _updateDismissTransitionMovementWithDistance:0.0f animated:true];
            }
        }
            break;
            
        case UIGestureRecognizerStateCancelled:
        {
            _dismissProgress = 0.0f;
            [self _updateDismissTransitionWithProgress:0.0f animated:true];
            [self _updateDismissTransitionMovementWithDistance:0.0f animated:true];
        }
            break;
            
        default:
            break;
    }
}

- (void)dismissForPIP
{
    _dismissing = true;
    self.view.userInteractionEnabled = false;
    
    [self setControlsHidden:true animated:true];
    [UIView animateWithDuration:0.3 animations:^
    {
        _backView.alpha = 0.0f;
        _curtainView.alpha = 0.0f;
    } completion:^(__unused BOOL finished)
    {
        [self dismiss];
    }];
}

- (void)dismissFullscreen:(bool)fromRotation duration:(NSTimeInterval)duration
{
    _dismissing = true;
    
    [self setControlsHidden:true animated:true];
    
    _backView.hidden = true;
    [_playerView _prepareToLeaveFullscreen];
    
    CGRect targetFrame = self.transitionSourceFrame();
    CGPoint targetCenter = CGPointMake(CGRectGetMidX(targetFrame), CGRectGetMidY(targetFrame));
    
    if (fromRotation)
    {
        targetCenter.x = CGRectGetMidX(_initialPlayerFrame);
        targetCenter.y = CGRectGetMidY(_initialPlayerFrame);
        
        _curtainView.hidden = true;
        if (!_aboveStatusBar)
            [TGHacks setApplicationStatusBarAlpha:1.0f];
    }
    
    [UIView animateWithDuration:duration animations:^{
        _playerView.center = targetCenter;
        _playerView.transform = CGAffineTransformIdentity;
        _curtainView.center = targetCenter;
        _curtainView.bounds = _playerView.bounds;
    } completion:^(__unused BOOL finished)
    {
        [self.embedWrapperView reattachPlayerView];
        
        dispatch_async(dispatch_get_main_queue(), ^
        {
            [self dismiss];
        });
    }];
}

- (void)beginTransitionOutWithVelocity:(CGFloat)__unused velocity
{
    __weak TGEmbedPlayerController *weakSelf = self;
    self.view.userInteractionEnabled = false;
    [_playerView _prepareToLeaveFullscreen];
    [_playerView beginLeavingFullscreen];
    [self animateView:_playerView to:self.transitionSourceFrame() completion:^(__unused bool finished)
    {
        __strong TGEmbedPlayerController *strongSelf = weakSelf;
        if (strongSelf == nil)
            return;
        
        [strongSelf->_playerView finishedLeavingFullscreen];
        [strongSelf.embedWrapperView reattachPlayerView];
        
        dispatch_async(dispatch_get_main_queue(), ^
        {
            [strongSelf dismiss];            
        });
    }];
    
    if (!_aboveStatusBar)
        [TGHacks setApplicationStatusBarAlpha:1.0f];
}

- (void)animateView:(UIView *)view to:(CGRect)toFrame completion:(void (^)(bool))completion
{
    [CATransaction begin];
    
    CGRect fromFrame = _playerView.frame;
    
    CGFloat damping = 30.0f;
    CGFloat mass = 0.8f;
    CGFloat durationFactor = 2.0f;
    
    CGPoint fromPosition = CGPointMake(CGRectGetMidX(fromFrame), CGRectGetMidY(fromFrame));
    CGPoint toPosition = CGPointMake(CGRectGetMidX(toFrame), CGRectGetMidY(toFrame));
    JNWSpringAnimation *positionAnimation = [JNWSpringAnimation animationWithKeyPath:@"position"];
    positionAnimation.fromValue = [NSValue valueWithCGPoint:fromPosition];
    positionAnimation.toValue = [NSValue valueWithCGPoint:toPosition];
    positionAnimation.damping = damping;
    positionAnimation.mass = mass;
    positionAnimation.removedOnCompletion = true;
    positionAnimation.fillMode = kCAFillModeForwards;
    positionAnimation.durationFactor = durationFactor;
    TGAnimationBlockDelegate *delegate = [[TGAnimationBlockDelegate alloc] initWithLayer:view.layer];
    delegate.completion = ^(BOOL finished)
    {
        if (completion)
            completion(finished);
    };
    positionAnimation.delegate = (id<CAAnimationDelegate>)delegate;
    view.layer.position = toPosition;
    [view.layer addAnimation:positionAnimation forKey:@"position"];
    
    CGPoint fromScale = CGPointMake(fromFrame.size.width / view.bounds.size.width, fromFrame.size.height/ view.bounds.size.height);
    CGPoint toScale = CGPointMake(1.0f, 1.0f);
    view.layer.transform = CATransform3DMakeScale(toFrame.size.width / view.bounds.size.width, toFrame.size.height / view.bounds.size.height, 1.0f);
    {
        JNWSpringAnimation *scaleAnimation = [JNWSpringAnimation animationWithKeyPath:@"transform.scale.x"];
        scaleAnimation.fromValue = @(fromScale.x);
        scaleAnimation.toValue = @(toScale.x);
        scaleAnimation.damping = damping;
        scaleAnimation.mass = mass;
        scaleAnimation.removedOnCompletion = true;
        scaleAnimation.fillMode = kCAFillModeForwards;
        scaleAnimation.durationFactor = durationFactor;
        [view.layer addAnimation:scaleAnimation forKey:@"transform.scale.x"];
    }
    {
        JNWSpringAnimation *scaleAnimation = [JNWSpringAnimation animationWithKeyPath:@"transform.scale.y"];
        scaleAnimation.fromValue = @(fromScale.y);
        scaleAnimation.toValue = @(toScale.y);
        scaleAnimation.damping = damping;
        scaleAnimation.mass = mass;
        scaleAnimation.removedOnCompletion = true;
        scaleAnimation.fillMode = kCAFillModeForwards;
        scaleAnimation.durationFactor = durationFactor;
        [view.layer addAnimation:scaleAnimation forKey:@"transform.scale.y"];
    }
    
    [CATransaction commit];
}

- (CGFloat)dismissProgressForSwipeDistance:(CGFloat)distance
{
    return MAX(0.0f, MIN(1.0f, ABS(distance / 150.0f)));
}

- (void)_updateDismissTransitionMovementWithDistance:(CGFloat)distance animated:(bool)animated
{
    CGRect originalFrame = [self _playerRectForSize:self.view.frame.size];
    CGRect frame = (CGRect){ { originalFrame.origin.x, originalFrame.origin.y + distance }, originalFrame.size };
    if (animated)
    {
        [UIView animateWithDuration:0.3 animations:^
        {
            _playerView.frame = frame;
        }];
    }
    else
    {
        _playerView.frame = frame;
    }
}

- (void)_updateDismissTransitionWithProgress:(CGFloat)progress animated:(bool)animated
{
    CGFloat alpha = 1.0f - MAX(0.0f, MIN(1.0f, progress * 4.0f));
    CGFloat transitionProgress = MAX(0.0f, MIN(1.0f, progress * 2.0f));
    
    if (transitionProgress > FLT_EPSILON)
    {
        _curtainView.hidden = true;
        [self setControlsHidden:true animated:true updateStatusBar:true];
    }
    
    if (animated)
    {
        [UIView animateWithDuration:0.3 animations:^
        {
            _backView.alpha = alpha;
        }];
    }
    else
    {
        _backView.alpha = alpha;
    }
}

#pragma mark -

- (void)setControlsHidden:(bool)hidden animated:(bool)animated
{
    [self setControlsHidden:hidden animated:animated updateStatusBar:false];
}

- (void)setControlsHidden:(bool)hidden animated:(bool)animated updateStatusBar:(bool)updateStatusBar
{
    if (animated)
    {
        if (updateStatusBar && !_aboveStatusBar)
            [TGHacks setApplicationStatusBarAlpha:hidden ? 0.0f : 1.0f];
        
        _scrubber.layer.rasterizationScale = TGScreenScaling();
        _scrubber.layer.shouldRasterize = true;
        
        _volumeView.layer.rasterizationScale = TGScreenScaling();
        _volumeView.layer.shouldRasterize = true;
        
        _topPanelView.userInteractionEnabled = !hidden;
        _bottomPanelView.userInteractionEnabled = !hidden;
        [UIView animateWithDuration:0.3 animations:^
        {
            _topPanelView.alpha = hidden ? 0.0f : 1.0f;
            _bottomPanelView.alpha = hidden ? 0.0f : 1.0f;
        } completion:^(__unused BOOL finished)
        {
            _scrubber.layer.shouldRasterize = false;
            _volumeView.layer.shouldRasterize = false;
        }];
    }
    else
    {
        _topPanelView.userInteractionEnabled = !hidden;
        _bottomPanelView.userInteractionEnabled = !hidden;
        _topPanelView.alpha = hidden ? 0.0f : 1.0f;
        _bottomPanelView.alpha = hidden ? 0.0f : 1.0f;
    }
}

- (void)updateState:(TGEmbedPlayerState *)state
{
    bool playing = state.isPlaying;
    _playButton.hidden = playing;
    _pauseButton.hidden = !playing;
    
    NSInteger position = (NSInteger)state.position;
    NSString *positionString = [[NSString alloc] initWithFormat:@"%d:%02d", (int)position / 60, (int)position % 60];
    _positionLabel.text = positionString;
    
    NSInteger remaining = (NSInteger)(state.duration - state.position);
    NSString *remainingString = [[NSString alloc] initWithFormat:@"-%d:%02d", (int)remaining / 60, (int)remaining % 60];
    _remainingLabel.text = remainingString;
    
    CGFloat fractPosition = state.position / MAX(state.duration, 0.001);
    
    if (state.duration <= 0.01 || isnan(state.downloadProgress))
    {
        _remainingLabel.hidden = true;
        _scrubber.hidden = true;
    }
    else
    {
        _remainingLabel.hidden = false;
        _scrubber.hidden = false;
    }
    
    if (!_scrubber.hidden)
    {
        [_scrubber setDownloadProgress:state.downloadProgress];
        [_scrubber setPosition:fractPosition];
    }
}


- (void)playButtonPressed
{
    [_playerView playVideo];
}

- (void)pauseButtonPressed
{
    [_playerView pauseVideo];
}

- (void)closeButtonPressed
{
    [self dismissFullscreen:false duration:0.4];
}

- (void)scanBackwardButtonPressed
{
    [_playerView seekToPosition:0.0];
}

- (void)scanForwardButtonPressed
{
    [_playerView seekToFractPosition:1.0f];
}

- (void)pipButtonPressed
{
    [_playerView switchToPictureInPicture];
}

#pragma mark -

- (CGFloat)playerScale
{
    CGAffineTransform t = _playerView.transform;
    return sqrt(t.a * t.a + t.c * t.c);
}

- (void)viewWillLayoutSubviews
{
    [super viewWillLayoutSubviews];
    
    CGSize screenSize = TGScreenSize();
    
    if (self.view.frame.size.width > self.view.frame.size.height && (NSInteger)screenSize.height != 480)
    {
        _remainingLabel.frame = CGRectMake(self.view.frame.size.width - 104.0f, _remainingLabel.frame.origin.y, _remainingLabel.frame.size.width, _remainingLabel.frame.size.height);
        _scrubber.frame = CGRectMake(_scrubber.frame.origin.x, _scrubber.frame.origin.y, _remainingLabel.frame.origin.x - _scrubber.frame.origin.x, _scrubber.frame.size.height);
        
        _bottomPanelView.frame = CGRectMake(0, self.view.frame.size.height - 50.0f, self.view.frame.size.width, 50.0f);
        
        _playButton.frame = CGRectMake(CGFloor((self.view.frame.size.width - _playButton.frame.size.width) / 2.0f), CGFloor((_bottomPanelView.frame.size.height - _playButton.frame.size.height) / 2.0f), _playButton.frame.size.width, _playButton.frame.size.height);
        _pauseButton.frame = _playButton.frame;
        
        _scanBackwardButton.frame = CGRectMake(_playButton.frame.origin.x - _scanBackwardButton.frame.size.width - 34.0f, CGFloor((_bottomPanelView.frame.size.height - _scanBackwardButton.frame.size.height) / 2.0f), _scanBackwardButton.frame.size.width, _scanBackwardButton.frame.size.height);
        
        _scanForwardButton.frame = CGRectMake(CGRectGetMaxX(_playButton.frame) + 34.0f, CGFloor((_bottomPanelView.frame.size.height - _scanForwardButton.frame.size.height) / 2.0f), _scanForwardButton.frame.size.width, _scanForwardButton.frame.size.height);
        
        _exitFullscreenButton.frame = CGRectMake(self.view.frame.size.width - _exitFullscreenButton.frame.size.width, CGFloor((_bottomPanelView.frame.size.height - _exitFullscreenButton.frame.size.height) / 2.0f), _exitFullscreenButton.frame.size.width, _exitFullscreenButton.frame.size.height);
        
        CGFloat y = 15;
#if TARGET_IPHONE_SIMULATOR
        y -= 6.5f;
#endif
        _volumeView.frame = CGRectMake(13.0f, y, floor(self.view.frame.size.width / 2.0 - 125.0f - 13.0f), 34.0f);
    }
    else
    {
        _remainingLabel.frame = CGRectMake(self.view.frame.size.width - 104.0f, _remainingLabel.frame.origin.y, _remainingLabel.frame.size.width, _remainingLabel.frame.size.height);
        _scrubber.frame = CGRectMake(_scrubber.frame.origin.x, _scrubber.frame.origin.y, _remainingLabel.frame.origin.x - _scrubber.frame.origin.x, _scrubber.frame.size.height);
        
        _bottomPanelView.frame = CGRectMake(0, self.view.frame.size.height - 80.0f, self.view.frame.size.width, 80.0f);
        _playButton.frame = CGRectMake(CGFloor((self.view.frame.size.width - _playButton.frame.size.width) / 2.0f), 0, _playButton.frame.size.width, _playButton.frame.size.height);
        _pauseButton.frame = _playButton.frame;
        
        _scanBackwardButton.frame = CGRectMake(_playButton.frame.origin.x - _scanBackwardButton.frame.size.width - 34.0f, 0, _scanBackwardButton.frame.size.width, _scanBackwardButton.frame.size.height);
        
        _scanForwardButton.frame = CGRectMake(CGRectGetMaxX(_playButton.frame) + 34.0f, 0, _scanForwardButton.frame.size.width, _scanForwardButton.frame.size.height);
        
        CGFloat y = 48;
#if TARGET_IPHONE_SIMULATOR
        y -= 6.5f;
#endif
        _volumeView.frame = CGRectMake(13.0f, y, self.view.frame.size.width - 71.0f, 34.0f);
        
        _exitFullscreenButton.frame = CGRectMake(self.view.frame.size.width - _exitFullscreenButton.frame.size.width, 32.0f, _exitFullscreenButton.frame.size.width, _exitFullscreenButton.frame.size.height);
    }
}

- (void)layoutControllerForSize:(CGSize)size duration:(NSTimeInterval)duration
{
    if (_playerView.superview != self.view || _appearing || _dismissing)
        return;
    
    CGRect targetFrame = [self _playerRectForSize:size];
 
    _playerView.center = CGPointMake(CGRectGetMidX(targetFrame), CGRectGetMidY(targetFrame));
    
    CGFloat currentScale = [self playerScale];
    CGFloat targetScale = targetFrame.size.width / _initialPlayerFrame.size.width;
    
    POPBasicAnimation *scaleAnimation = [POPBasicAnimation animationWithPropertyNamed:kPOPViewScaleXY];
    scaleAnimation.fromValue = [NSValue valueWithCGSize:CGSizeMake(currentScale, currentScale)];
    scaleAnimation.toValue = [NSValue valueWithCGSize:CGSizeMake(targetScale, targetScale)];
    scaleAnimation.duration = duration;
    [_playerView pop_addAnimation:scaleAnimation forKey:@"scale"];
    
    _curtainView.frame = CGRectMake(0, 0, size.width, size.height);
}

- (CGRect)_playerRectForSize:(CGSize)size
{
    CGSize playerSize = TGScaleToSize(_initialPlayerFrame.size, size);
    return CGRectMake(CGFloor((size.width - playerSize.width) / 2.0f), CGFloor((size.height - playerSize.height) / 2.0f), playerSize.width, playerSize.height);
}

@end
