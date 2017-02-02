#import "TGCallStatusBarView.h"

#import "TGOverlayControllerWindow.h"
#import "TGFont.h"

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
    
    TGCallStatusBarWindow *_lowerWindow;
    TGCallStatusBarWindow *_upperWindow;
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
    }
    return self;
}

- (void)_setupWindows
{
    _lowerWindow = [[TGCallStatusBarWindow alloc] init];
    _lowerWindow.userInteractionEnabled = false;
    _lowerWindow.windowLevel = UIWindowLevelStatusBar - 0.002;
    _lowerWindow.hidden = false;
    [_lowerWindow addSubview:self];
    
    _upperWindow = [[TGCallStatusBarWindow alloc] init];
    _upperWindow.windowLevel = UIWindowLevelStatusBar + 0.00001;
    _upperWindow.statusBarPressed = _statusBarPressed;
    _upperWindow.hidden = false;
}

- (void)_destroyWindows
{
    [self removeFromSuperview];
    _lowerWindow = nil;
    _upperWindow = nil;
}

- (void)setStatusBarPressed:(void (^)(void))statusBarPressed
{
    _statusBarPressed = [statusBarPressed copy];
    _upperWindow.statusBarPressed = [statusBarPressed copy];
}

- (bool)realHidden
{
    return _targetHidden;
}

- (void)setHidden:(BOOL)hidden
{
    if (_targetHidden == hidden)
        return;
    
    _targetHidden = hidden;
    
    if (!hidden)
        [self setActuallyHidden:false];
    
    [UIView animateWithDuration:0.25 animations:^
    {
        _backgroundView.alpha = hidden ? 0.0f : 1.0f;
        _backgroundView.frame = CGRectMake(0, hidden ? -20.0f : 0.0f, _backgroundView.frame.size.width, _backgroundView.frame.size.height);
    } completion:^(BOOL finished)
    {
        if (finished && hidden)
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
    NSString *durationString = @"";
    if (duration > DBL_EPSILON)
    {
        durationString = duration >= 60 * 60 ? [NSString stringWithFormat:@"%02d:%02d:%02d", (int)(duration / 3600.0), (int)(duration / 60.0) % 60, (int)duration % 60] : [NSString stringWithFormat:@"%02d:%02d", (int)(duration / 60.0) % 60, (int)duration % 60];
    }
    _label.text = [[NSString stringWithFormat:@"Touch to return to call %@", durationString] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    //_label.text = [NSString stringWithFormat:TGLocalized(@"Call.StatusBar"), durationString];
}

- (void)startAnimation
{
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
