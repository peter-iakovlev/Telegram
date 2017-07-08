#import "TGVolumeBarView.h"

#import <MediaPlayer/MediaPlayer.h>

#import "TGTelegraph.h"
#import "TGInterfaceManager.h"

#import "TGHacks.h"
#import "TGTimerTarget.h"

#import "TGEmbedPIPController.h"

#import "TGOverlayControllerWindow.h"

@interface TGVolumeBarView ()
{
    id _notificationObserver;
    
    UIView *_wrapperView;
    UIProgressView *_progressView;
    UIWindow *_volumeWindow;
    
    NSTimer *_timer;
    
    CGFloat _initialStatusBarAlpha;
}
@end

@implementation TGVolumeBarView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self != nil)
    {
        self.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        self.backgroundColor = [UIColor clearColor];
        self.userInteractionEnabled = false;
        
        _wrapperView = [[UIView alloc] initWithFrame:CGRectOffset(self.bounds, 0.0f, -self.bounds.size.height)];
        _wrapperView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        _wrapperView.backgroundColor = UIColorRGB(0xf7f7f7);
        [self addSubview:_wrapperView];
        
        _progressView = [[UIProgressView alloc] initWithFrame:CGRectMake(5.0f, 7.0f, frame.size.width - 10.0f, 2.0f)];
        _progressView.progress = 0.4f;
        _progressView.trackTintColor = UIColorRGB(0xededed);
        _progressView.progressTintColor = [UIColor blackColor];
        [_wrapperView addSubview:_progressView];
        
        [self subscribe];
    }
    return self;
}

- (void)setVolume:(CGFloat)volume
{
    [self _setVolume:volume];
    [self show];
}

- (void)subscribe
{
    UIWindow *keyWindow = [UIApplication sharedApplication].keyWindow;
    UIView *rootView = keyWindow.rootViewController.view;
    
    MPVolumeView *volumeView = [[MPVolumeView alloc] initWithFrame:CGRectMake(10000, 10000, 20, 20)];
    [rootView addSubview:volumeView];
    
    __weak TGVolumeBarView *weakSelf = self;
    _notificationObserver = [[NSNotificationCenter defaultCenter] addObserverForName:@"AVSystemController_SystemVolumeDidChangeNotification" object:nil queue:nil usingBlock:^(NSNotification *notification)
    {
        __strong TGVolumeBarView *strongSelf = weakSelf;
        if (strongSelf == nil)
            return;
        
        NSNumber *volume = notification.userInfo[@"AVSystemController_AudioVolumeNotificationParameter"];
        NSString *reason = notification.userInfo[@"AVSystemController_AudioVolumeChangeReasonNotificationParameter"];
        if (volume != nil && [reason isEqualToString:@"ExplicitVolumeChange"])
        {
            [[TGTelegraphInstance.musicPlayer.playingStatus take:1] startWithNext:^(TGMusicPlayerStatus *next)
            {
                if (![TGInterfaceManager instance].hasCallControllerInForeground && (next != nil || [TGEmbedPIPController hasPlayerViews] || [strongSelf hasVolumeOverlayInhibitor]))
                {
                    [strongSelf setVolume:volume.doubleValue];
                }
            }];
        }
    }];

    [volumeView removeFromSuperview];
}

- (bool)hasVolumeOverlayInhibitor
{
    UIWindow *keyWindow = [UIApplication sharedApplication].keyWindow;
    UIView *rootView = keyWindow.rootViewController.view;
    
    for (UIView *view in rootView.subviews)
    {
        if ([view isKindOfClass:[MPVolumeView class]])
            return true;
    }
    
    __block bool found = false;
    [[UIApplication sharedApplication].windows enumerateObjectsWithOptions:NSEnumerationReverse usingBlock:^(UIWindow *window, __unused NSUInteger index, BOOL *stop)
    {
        if ([window isKindOfClass:[TGOverlayControllerWindow class]])
        {
            UIView *rootView = window.rootViewController.view;
            for (UIView *view in rootView.subviews)
            {
                if ([view isKindOfClass:[MPVolumeView class]])
                {
                    found = true;
                    break;
                }
            }
            
            *stop = true;
        }
    }];
    
    return found;
}

- (void)show
{
    [self invalidateTimer];
    
    _timer = [TGTimerTarget scheduledMainThreadTimerWithTarget:self action:@selector(hide) interval:1.0 repeat:false];
    
    if (_volumeWindow == nil)
        [self _setupWindow];
    
    [UIView animateWithDuration:0.25 animations:^
    {
        _wrapperView.frame = self.bounds;
        [TGHacks setApplicationStatusBarAlpha:0.0f];
    }];
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    _progressView.frame = CGRectMake(_progressView.frame.origin.x, _progressView.frame.origin.y, self.frame.size.width - _progressView.frame.origin.x * 2.0f, _progressView.frame.size.height);
}

- (void)hide
{
    [UIView animateWithDuration:0.25 animations:^
    {
        _wrapperView.frame = CGRectOffset(self.bounds, 0.0f, -self.bounds.size.height);
        
        if ([TGHacks applicationStatusBarAlpha] < FLT_EPSILON)
            [TGHacks setApplicationStatusBarAlpha:_initialStatusBarAlpha];
    } completion:^(BOOL finished)
    {
        if (finished && _wrapperView.layer.animationKeys.count == 0)
            [self _destroyWindow];
    }];
}

- (void)_setupWindow
{
    _initialStatusBarAlpha = [TGHacks applicationStatusBarAlpha];
    
    _volumeWindow = [[UIWindow alloc] init];
    _volumeWindow.backgroundColor = [UIColor clearColor];
    _volumeWindow.userInteractionEnabled = false;
    _volumeWindow.frame = [UIApplication sharedApplication].keyWindow.frame;
    _volumeWindow.windowLevel = UIWindowLevelStatusBar + 0.00001;
    _volumeWindow.rootViewController = [[TGOverlayWindowViewController alloc] init];
    _volumeWindow.hidden = false;
    [_volumeWindow addSubview:self];
    
    self.frame = CGRectMake(0.0f, 0.0f, _volumeWindow.frame.size.width, self.frame.size.height);
}

- (void)_destroyWindow
{
    [self removeFromSuperview];
    _volumeWindow = nil;
}

- (void)invalidateTimer
{
    if (_timer == nil)
        return;
    
    [_timer invalidate];
    _timer = nil;
}

- (void)_setVolume:(CGFloat)volume
{
    _progressView.progress = (float)volume;
}

@end
