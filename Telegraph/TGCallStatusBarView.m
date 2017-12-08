#import "TGCallStatusBarView.h"

#import <LegacyComponents/LegacyComponents.h>

#import "TGCallController.h"

@interface TGCallStatusBarWindow : UIWindow

@property (nonatomic, copy) void (^statusBarPressed)(void);

@end

@interface TGCallStatusBarView ()
{
    bool _targetHidden;
    
    UIView *_backgroundView;
    UILabel *_label;
    
    SMetaDisposable *_signalDisposable;
    
    TGCallStatusBarWindow *_window;
    
    id _didEnterBackgroundObserver;
    id _willEnterForegroundObserver;
}
@end

@implementation TGCallStatusBarView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self != nil)
    {
        _backgroundView = [[UIView alloc] initWithFrame:self.bounds];
        _backgroundView.alpha = 0.0f;
        _backgroundView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        _backgroundView.backgroundColor = UIColorRGB(0x4cd964);
        [self addSubview:_backgroundView];
        
        _label = [[UILabel alloc] initWithFrame:CGRectMake(0, 20, frame.size.width, 20)];
        _label.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        _label.font = TGSystemFontOfSize(14.0f);
        _label.textAlignment = NSTextAlignmentCenter;
        _label.textColor = [UIColor whiteColor];
        [_backgroundView addSubview:_label];
        
        if ((int)TGScreenSize().height == 812)
        {
            _label.hidden = true;
        }
        else
        {
            __weak TGCallStatusBarView *weakSelf = self;
            _didEnterBackgroundObserver = [[NSNotificationCenter defaultCenter] addObserverForName:UIApplicationDidEnterBackgroundNotification object:nil queue:nil usingBlock:^(__unused NSNotification *notification)
            {
                __strong TGCallStatusBarView *strongSelf = weakSelf;
                [strongSelf stopAnimation];
            }];
            
            _willEnterForegroundObserver = [[NSNotificationCenter defaultCenter] addObserverForName:UIApplicationWillEnterForegroundNotification object:nil queue:nil usingBlock:^(__unused NSNotification *notification)
            {
                __strong TGCallStatusBarView *strongSelf = weakSelf;
                if (!strongSelf->_targetHidden)
                    [strongSelf startAnimation];
            }];
        }
    }
    return self;
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:_didEnterBackgroundObserver];
    [[NSNotificationCenter defaultCenter] removeObserver:_willEnterForegroundObserver];
}

- (void)_setupWindows
{
    _window = [[TGCallStatusBarWindow alloc] init];
    _window.userInteractionEnabled = true;
    _window.frame = [UIApplication sharedApplication].keyWindow.frame;
    _window.windowLevel = UIWindowLevelStatusBar - 0.002;
    _window.hidden = false;
    _window.tag = 0xbeef;
    _window.statusBarPressed = _statusBarPressed;
    [_window addSubview:self];
}

- (void)_destroyWindows
{
    [self removeFromSuperview];
    _window = nil;
}

- (void)setStatusBarPressed:(void (^)(void))statusBarPressed
{
    _statusBarPressed = [statusBarPressed copy];
    _window.statusBarPressed = [statusBarPressed copy];
}

- (bool)realHidden
{
    return _targetHidden;
}

- (void)setHidden:(BOOL)hidden
{
    if (_targetHidden == hidden && !(!hidden && _window == nil))
        return;
    
    _targetHidden = hidden;
    
    if (!hidden)
        [self setActuallyHidden:false];
    
    [UIView animateWithDuration:0.25 animations:^
    {
        _backgroundView.alpha = hidden ? 0.0f : 1.0f;
        _backgroundView.frame = CGRectMake(0, hidden ? -20.0f : 0.0f, _backgroundView.frame.size.width, _backgroundView.frame.size.height);
    } completion:^(__unused BOOL finished)
    {
        if (hidden)
            [self setActuallyHidden:true];
    }];
    
    if (self.visiblilityChanged != nil)
        self.visiblilityChanged(hidden);
    
    if (!hidden)
        [self startAnimation];
    else
        [self stopAnimation];
}

- (void)setActuallyHidden:(bool)hidden
{
    if (hidden)
        [self _destroyWindows];
    else
        [self _setupWindows];
    
    [super setHidden:hidden];
}

- (void)setSignal:(SSignal *)signal
{
    __weak TGCallStatusBarView *weakSelf = self;
    [_signalDisposable setDisposable:[signal startWithNext:^(id next)
    {
        __strong TGCallStatusBarView *strongSelf = weakSelf;
        if (strongSelf == nil)
            return;
        
        if ([next isKindOfClass:[NSNumber class]])
        {
            [strongSelf setHidden:false];
            [strongSelf setDuration:[next doubleValue]];
        }
        else
        {
            [strongSelf setHidden:true];
        }
    }]];
}

- (void)setOffset:(CGFloat)offset
{
    CGRect bounds = self.bounds;
    bounds.origin.y = -offset;
    self.bounds = bounds;
}

- (void)setDuration:(NSTimeInterval)duration
{
    if (self.frame.size.width > self.window.frame.size.width)
        self.frame = CGRectMake(self.frame.origin.x, self.frame.origin.y, self.window.frame.size.width, self.frame.size.height);
    
    NSString *durationString = @"";
    if (duration > DBL_EPSILON)
    {
        durationString = duration >= 60 * 60 ? [NSString stringWithFormat:@"%02d:%02d:%02d", (int)(duration / 3600.0), (int)(duration / 60.0) % 60, (int)duration % 60] : [NSString stringWithFormat:@"%02d:%02d", (int)(duration / 60.0) % 60, (int)duration % 60];
    }
    _label.text = [[NSString stringWithFormat:TGLocalized(@"Call.StatusBar"), durationString] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
}

- (void)startAnimation
{
    if (_label.hidden)
        return;
    
    CAKeyframeAnimation *blinkAnim = [CAKeyframeAnimation animationWithKeyPath:@"opacity"];
    blinkAnim.duration = 1.8;
    blinkAnim.autoreverses = false;
    blinkAnim.fillMode = kCAFillModeForwards;
    blinkAnim.repeatCount = HUGE_VALF;
    blinkAnim.keyTimes = @[ @0.0f, @0.1f, @0.5f, @0.9f, @1.0f ];
    blinkAnim.values = @[ @1.0f, @1.0f, @0.0f, @1.0f, @1.0f ];
    
    [_label.layer addAnimation:blinkAnim forKey:@"opacity"];
}

- (void)stopAnimation
{
    if (_label.hidden)
        return;
    
    [_label.layer removeAllAnimations];
}

@end


@interface TGCallStatusBarWindowViewController : UIViewController

@end


@implementation TGCallStatusBarWindow

- (instancetype)init
{
    self = [super init];
    if (self != nil)
    {
        self.backgroundColor = [UIColor clearColor];
        self.opaque = false;
        self.rootViewController = [[TGCallStatusBarWindowViewController alloc] init];
    }
    return self;
}

- (BOOL)pointInside:(CGPoint)point withEvent:(UIEvent *)__unused event
{
    for (UIWindow *window in [[UIApplication sharedApplication] windows])
    {
        if ([window.rootViewController isKindOfClass:[TGCallController class]])
        {
            if (window.rootViewController.view.userInteractionEnabled)
                return false;
        }
    }
    return point.y < 40.0f;
}

- (void)touchesEnded:(NSSet<UITouch *> *)__unused touches withEvent:(UIEvent *)__unused event
{
    if (self.statusBarPressed != nil)
        self.statusBarPressed();
}

@end


@implementation TGCallStatusBarWindowViewController

- (BOOL)prefersStatusBarHidden
{
    return false;
}

- (UIStatusBarStyle)preferredStatusBarStyle
{
    return UIStatusBarStyleLightContent;
}

@end
