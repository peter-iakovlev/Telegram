#import "TGProxyWindow.h"
#import "TGPresentationAssets.h"
#import <LegacyComponents/TGFont.h>

static bool TGProxyWindowIsLight = true;

@interface TGProxySpinnerView : UIView

@property (nonatomic, copy) void (^onSuccess)(void);

- (instancetype)initWithFrame:(CGRect)frame light:(bool)light;

- (void)setSucceed;

@end

@interface TGProxyWindowController ()
{
    bool _light;
    UIVisualEffectView *_effectView;
    UIView *_backgroundView;
    TGProxySpinnerView *_spinner;
}

@property (nonatomic, weak) UIWindow *weakWindow;
@property (nonatomic, strong) UIView *containerView;

@end

@implementation TGProxyWindowController

- (instancetype)init
{
    self = [super init];
    if (self != nil)
    {
        _light = TGProxyWindowIsLight;
    }
    return self;
}

- (void)loadView
{
    [super loadView];
    
    _containerView = [[UIView alloc] initWithFrame:CGRectMake(CGFloor(self.view.frame.size.width - 156) / 2, CGFloor(self.view.frame.size.height - 176) / 2, 156, 176)];
    _containerView.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin;
    _containerView.alpha = 0.0f;
    _containerView.clipsToBounds = true;
    _containerView.layer.cornerRadius = 20.0f;
    [self.view addSubview:_containerView];
    
    if (iosMajorVersion() >= 9)
    {
        _effectView = [[UIVisualEffectView alloc] initWithEffect:_light ? [UIBlurEffect effectWithStyle:UIBlurEffectStyleLight] : [UIBlurEffect effectWithStyle:UIBlurEffectStyleDark]];
        _effectView.frame = _containerView.bounds;
        [_containerView addSubview:_effectView];
        
        if (_light)
        {
            UIView *tintView = [[UIView alloc] initWithFrame:_effectView.bounds];
            tintView.backgroundColor = UIColorRGBA(0xf4f4f4, 0.75f);
            [_containerView addSubview:tintView];
        }
    }
    else
    {
        _backgroundView = [[UIView alloc] initWithFrame:_containerView.bounds];
        _backgroundView.backgroundColor = _light ? UIColorRGBA(0xeaeaea, 0.92f) : UIColorRGBA(0x000000, 0.9f);
        [_containerView addSubview:_backgroundView];
    }
    
    UIColor *color = _light ? UIColorRGB(0x5a5a5a) : [UIColor whiteColor];
    UIImageView *shield = [[UIImageView alloc] initWithImage:[TGPresentationAssets proxyShieldImage:color]];
    shield.frame = CGRectMake((_containerView.frame.size.width - shield.frame.size.width) / 2.0f, 23.0f, shield.frame.size.width, shield.frame.size.height);
    [_containerView addSubview:shield];
    
    _spinner = [[TGProxySpinnerView alloc] initWithFrame:CGRectMake((_containerView.frame.size.width - 48.0f) / 2.0f, 40.0f, 48.0f, 48.0f) light:_light];
    [_containerView addSubview:_spinner];
    
    NSMutableParagraphStyle *style = [[NSMutableParagraphStyle alloc] init];
    style.lineBreakMode = NSLineBreakByWordWrapping;
    style.lineSpacing = 2.0f;
    style.alignment = NSTextAlignmentCenter;
    
    NSDictionary *attributes = @{NSForegroundColorAttributeName:_light ? UIColorRGB(0x5a5a5a) : [UIColor whiteColor], NSFontAttributeName:TGMediumSystemFontOfSize(17.0f), NSParagraphStyleAttributeName:style};
    NSAttributedString *string = [[NSAttributedString alloc] initWithString:TGLocalized(@"SocksProxySetup.ProxyEnabled") attributes:attributes];
    
    UILabel *label = [[UILabel alloc] init];
    label.font = TGSystemFontOfSize(15.0f);
    label.numberOfLines = 2;
    label.textAlignment = NSTextAlignmentCenter;
    label.attributedText = string;
    [label sizeToFit];
    label.frame = CGRectMake((_containerView.frame.size.width - label.frame.size.width) / 2.0f, _containerView.frame.size.height - label.frame.size.height - 18.0f, label.frame.size.width, label.frame.size.height);
    [_containerView addSubview:label];
}

- (void)dismissWithSuccess
{
    TGProxyWindow *window = (TGProxyWindow *)_weakWindow;
    
    window.userInteractionEnabled = false;
    
    void (^dismissBlock)(void) = ^
    {
        [UIView animateWithDuration:0.3 delay:0.55 options:0 animations:^
         {
             _containerView.alpha = 0.0f;
         } completion:^(BOOL finished)
         {
             if (finished)
             {
                 window.hidden = true;
                 
//                 if (window.skipMakeKeyWindowOnDismiss)
//                     return;
                 
//                 NSArray *windows = [[LegacyComponentsGlobals provider] applicationWindows];
//                 for (int i = (int)windows.count - 1; i >= 0; i--)
//                 {
//                     if ([windows objectAtIndex:i] != window) {
//                         [[windows objectAtIndex:i] makeKeyWindow];
//                     }
//                 }
             }
         }];
    };
    
    if (window.hidden)
    {
        window.hidden = false;
        _containerView.transform = CGAffineTransformMakeScale(0.6f, 0.6f);
        
        if (iosMajorVersion() >= 7)
        {
            [UIView animateWithDuration:0.3 delay:0.0 options:7 << 16 animations:^{
                _containerView.transform = CGAffineTransformIdentity;
            } completion:nil];
        }
        
        [UIView animateWithDuration:0.3f animations:^
         {
             _containerView.alpha = 1.0f;
             if (iosMajorVersion() < 7)
                 _containerView.transform = CGAffineTransformIdentity;
         } completion:^(__unused BOOL finished) {
             dismissBlock();
         }];
        
        TGDispatchAfter(0.15, dispatch_get_main_queue(), ^{
            [_spinner setSucceed];
        });
    }
    else
    {
        _spinner.onSuccess = ^{
            dismissBlock();
        };
        [_spinner setSucceed];
    }
}

- (BOOL)canBecomeFirstResponder {
    return false;
}

@end

@interface TGProxyWindow () {
    bool _dismissed;
    bool _appeared;
}

@end

@implementation TGProxyWindow

- (instancetype)init {
    return [self initWithFrame:[[UIScreen mainScreen] bounds]];
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
    {
        self.windowLevel = UIWindowLevelStatusBar;
        self.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        
        TGProxyWindowController *controller = [[TGProxyWindowController alloc] init];
        controller.weakWindow = self;
        self.rootViewController = controller;
        
        self.opaque = false;
    }
    return self;
}

- (void)dismissWithSuccess
{
    if (!_dismissed) {
        _dismissed = true;
        [((TGProxyWindowController *)self.rootViewController) dismissWithSuccess];
    }
}

+ (void)setDarkStyle:(bool)dark
{
    TGProxyWindowIsLight = !dark;
}

@end


@interface TGProxySpinnerViewInternal : UIView

@property (nonatomic, copy) void (^onDraw)(void);
@property (nonatomic, copy) void (^onSuccess)(void);

- (instancetype)initWithFrame:(CGRect)frame light:(bool)light;

- (void)setSucceed:(bool)fromRotation progress:(CGFloat)progress;

@end

@interface TGProxySpinnerView ()
{
    TGProxySpinnerViewInternal *_internalView;
    
    bool _progressing;
}
@end

@implementation TGProxySpinnerView

- (instancetype)initWithFrame:(CGRect)frame light:(bool)light {
    self = [super initWithFrame:frame];
    if (self != nil) {
        self.backgroundColor = [UIColor clearColor];
        self.opaque = false;
        self.userInteractionEnabled = false;
        
        _internalView = [[TGProxySpinnerViewInternal alloc] initWithFrame:self.bounds light:light];
        _internalView.hidden = true;
        [self addSubview:_internalView];
    }
    return self;
}

- (void)setSucceed {
    _internalView.hidden = false;
    
    [_internalView setSucceed:false progress:0.0f];
}

@end

@interface TGProxySpinnerViewInternal ()
{
    CADisplayLink *_displayLink;
    
    bool _light;
    
    bool _isProgressing;
    CGFloat _rotationValue;
    bool _isRotating;
    
    CGFloat _checkValue;
    bool _delay;
    bool _isSucceed;
    bool _isChecking;
    
    NSTimeInterval _previousTime;
}
@end

@implementation TGProxySpinnerViewInternal

- (instancetype)initWithFrame:(CGRect)frame light:(bool)light {
    self = [super initWithFrame:frame];
    if (self != nil) {
        _light = light;
        
        self.backgroundColor = [UIColor clearColor];
        self.opaque = false;
        self.userInteractionEnabled = false;
    }
    return self;
}

- (void)dealloc {
    _displayLink.paused = true;
    [_displayLink removeFromRunLoop:[NSRunLoop mainRunLoop] forMode:NSRunLoopCommonModes];
}

- (CADisplayLink *)displayLink {
    if (_displayLink == nil) {
        _displayLink = [CADisplayLink displayLinkWithTarget:self selector:@selector(displayLinkUpdate)];
        _displayLink.paused = true;
        [_displayLink addToRunLoop:[NSRunLoop mainRunLoop] forMode:NSRunLoopCommonModes];
    }
    return _displayLink;
}

- (void)drawRect:(CGRect)rect {
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGPoint centerPoint = CGPointMake(rect.size.width / 2.0f, rect.size.height / 2.0f);
    CGFloat lineWidth = 4.0f;
    CGFloat inset = 3.0f;
    
    UIColor *foregroundColor = _light ? UIColorRGB(0x5a5a5a) : [UIColor whiteColor];
    CGContextSetFillColorWithColor(context, foregroundColor.CGColor);
    CGContextSetStrokeColorWithColor(context, foregroundColor.CGColor);
    
    if (_isProgressing)
    {
        CGMutablePathRef path = CGPathCreateMutable();
        CGFloat offset = -_rotationValue * 2.0f * M_PI;
        CGPathAddArc(path, NULL, centerPoint.x, centerPoint.y, (rect.size.width - inset * 2.0f - lineWidth) / 2.0f, offset, offset + (3.0f * M_PI_2) * (1.0f - _checkValue), false);
        CGPathRef strokedArc = CGPathCreateCopyByStrokingPath(path, NULL, lineWidth, kCGLineCapRound, kCGLineJoinMiter, 10);
        CGContextAddPath(context, strokedArc);
        CGPathRelease(strokedArc);
        CGPathRelease(path);
        
        CGContextFillPath(context);
    }
    
    if (_checkValue > FLT_EPSILON)
    {
        CGContextSetLineWidth(context, 4.0f);
        CGContextSetLineCap(context, kCGLineCapRound);
        CGContextSetLineJoin(context, kCGLineJoinRound);
        CGContextSetMiterLimit(context, 10);
        
        CGFloat firstSegment = MIN(1.0f, _checkValue * 3.0f);
        CGPoint s = CGPointMake(inset + 5.0f, centerPoint.y + 1.0f);
        CGPoint p1 = CGPointMake(10.0f, 10.0f);
        CGPoint p2 = CGPointMake(23.0f, -23.0f);
        
        if (firstSegment < 1.0f)
        {
            CGContextMoveToPoint(context, s.x + p1.x * firstSegment, s.y + p1.y * firstSegment);
            CGContextAddLineToPoint(context, s.x, s.y);
        }
        else
        {
            CGFloat secondSegment = (_checkValue - 0.33f) * 1.5f;
            CGContextMoveToPoint(context, s.x + p1.x + p2.x * secondSegment, s.y + p1.y + p2.y * secondSegment);
            CGContextAddLineToPoint(context, s.x + p1.x, s.y + p1.y);
            CGContextAddLineToPoint(context, s.x, s.y);
        }
        
        CGContextStrokePath(context);
    }
}

- (void)displayLinkUpdate
{
    NSTimeInterval previousTime = _previousTime;
    NSTimeInterval currentTime = CACurrentMediaTime();
    _previousTime = currentTime;
    
    NSTimeInterval delta = previousTime > DBL_EPSILON ? currentTime - previousTime : 0.0;
    if (delta < DBL_EPSILON)
        return;
    
    if (_isRotating)
    {
        _rotationValue += delta * 1.35f;
    }
    
    if (_isSucceed && _isRotating && !_delay && _rotationValue >= 0.5f)
    {
        _rotationValue = 0.5f;
        _isRotating = false;
        _isChecking = true;
    }
    
    if (_isChecking)
        _checkValue += delta * M_PI * 1.6f;
    
    if (_rotationValue > 1.0f)
    {
        _rotationValue = 0.0f;
        _delay = false;
    }
    
    if (_checkValue > 1.0f)
    {
        _checkValue = 1.0f;
        [self displayLink].paused = true;
        
        if (self.onSuccess != nil)
        {
            void (^onSuccess)(void) = [self.onSuccess copy];
            self.onSuccess = nil;
            onSuccess();
        }
    }
    
    [self setNeedsDisplay];
    
    if (self.onDraw != nil)
    {
        void (^onDraw)(void) = [self.onDraw copy];
        self.onDraw = nil;
        onDraw();
    }
}

- (void)setProgress {
    _isRotating = true;
    _isProgressing = true;
    
    [self displayLink].paused = false;
}

- (void)setSucceed:(bool)fromRotation progress:(CGFloat)progress {
    if (_isSucceed)
        return;
    
    if (fromRotation) {
        _isRotating = true;
        _isProgressing = true;
        _rotationValue = progress;
    }
    
    _isSucceed = true;
    
    if (!_isRotating)
        _isChecking = true;
    else if (_rotationValue > 0.5f)
        _delay = true;
    
    [self displayLink].paused = false;
}

- (bool)isSucceed
{
    return _isSucceed;
}

@end


