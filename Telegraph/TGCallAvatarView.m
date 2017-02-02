#import "TGCallAvatarView.h"

#import "TGImageUtils.h"

#import "TGUser.h"
#import "TGCallSession.h"

#import "TGLetteredAvatarView.h"

const NSInteger TGCallSpeechRippleMaxCount = 2;
const NSTimeInterval TGCallSpeechRippleInterval = 0.25;
const NSTimeInterval TGCallSpeechRippleThreshold = 0.32;
const NSTimeInterval TGCallSpeechRippleDifference = 0.1;

@interface TGCallSpeechRipple : NSObject

@property (nonatomic, assign) NSTimeInterval creationTime;
@property (nonatomic, assign) CGFloat startLevel;
@property (nonatomic, assign) CGFloat progress;

@end


@interface TGCallSpeechCircleView : UIView

@property (nonatomic, strong) UIColor *color;
@property (nonatomic, assign) CGFloat strokeWidth;
@property (nonatomic, strong) UIColor *strokeColor;

@end

@interface TGCallSpeechVolumeView : UIView
{
    TGCallSpeechCircleView *_levelView;
    
    CADisplayLink *_displayLink;
    CGFloat _currentLevel;
    CGFloat _inputLevel;
    
    NSMutableArray *_ripples;
    NSArray *_rippleViews;
    
    NSMutableIndexSet *_completedRipples;
}

- (void)setLevel:(CGFloat)level;

@end


const CGSize TGCallAvatarLargeSize = { 120.0f, 120.0f };
const CGFloat TGCallAvatarNormalScale = 0.75f;

@interface TGCallAvatarView ()
{
    TGCallSpeechVolumeView *_volumeView;
    TGLetteredAvatarView *_avatarView;
    
    int32_t _currentPeerId;
    bool _largeAvatar;
    bool _forcedLargeAvatar;
    
    TGCallState _currentState;
}
@end

@implementation TGCallAvatarView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self != nil)
    {
        self.clipsToBounds = false;
        
        _volumeView = [[TGCallSpeechVolumeView alloc] init];
        [self addSubview:_volumeView];
        
        _avatarView = [[TGLetteredAvatarView alloc] init];
        [_avatarView setSingleFontSize:36.0f doubleFontSize:36.0f useBoldFont:false];
        [self addSubview:_avatarView];
    }
    return self;
}

+ (CGFloat)normalScale
{
    static dispatch_once_t onceToken;
    static CGFloat scale;
    dispatch_once(&onceToken, ^
    {
        CGSize screenSize = TGScreenSize();
        //int width = (int)screenSize.width;
        int height = (int)screenSize.height;
        if (height == 736)
            scale = 1.0f;
        else
            scale = TGCallAvatarNormalScale;
    });
    return scale;
}

- (void)setState:(TGCallSessionState *)state
{
    bool largeAvatar = false;
    bool volumeHidden = true;
    switch (state.state)
    {
        case TGCallStateHandshake:
        case TGCallStateReady:
            largeAvatar = true;
            break;
            
        case TGCallStateOngoing:
            volumeHidden = false;
            break;
        
        default:
            largeAvatar = false;
            break;
    }
    
    _volumeView.hidden = volumeHidden;
    
    TGCallState previousState = _currentState;
    _currentState = state.state;
    if ((_currentState == TGCallStateEnded || _currentState == TGCallStateEnding)
        && (previousState == TGCallStateHandshake || previousState == TGCallStateReady)) {
        largeAvatar = true;
        _forcedLargeAvatar = true;
    }
    
    if (_largeAvatar != largeAvatar)
    {
        _largeAvatar = largeAvatar;
        if (!largeAvatar)
        {
            [UIView animateWithDuration:0.3 delay:0.0 options:7 << 16 animations:^
            {
                [self layoutSubviews];
            } completion:nil];
        }
        else
        {
            [self setNeedsLayout];
        }
    }
    
    if (_currentPeerId != state.peer.uid)
    {
        _currentPeerId = state.peer.uid;
        
        CGSize size = TGCallAvatarLargeSize;
        static UIImage *placeholder = nil;
        static dispatch_once_t onceToken;
        dispatch_once(&onceToken, ^
        {
            UIGraphicsBeginImageContextWithOptions(size, false, 0.0f);
            CGContextRef context = UIGraphicsGetCurrentContext();
            CGContextSetFillColorWithColor(context, [UIColor whiteColor].CGColor);
            CGContextFillEllipseInRect(context, CGRectMake(0.0f, 0.0f, size.width, size.height));
            CGContextSetStrokeColorWithColor(context, UIColorRGBA(0xffffff, 0.4f).CGColor);
            CGContextSetLineWidth(context, 1.0f);
            CGContextStrokeEllipseInRect(context, CGRectMake(0.5f, 0.5f, size.width - 1.0f, size.height - 1.0f));
            placeholder = UIGraphicsGetImageFromCurrentImageContext();
            UIGraphicsEndImageContext();
        });
        
        if (state.peer.photoUrlSmall.length > 0)
        {
            [_avatarView loadImage:state.peer.photoUrlBig filter:@"circle:128x128" placeholder:placeholder];
        }
        else
        {
            [_avatarView loadUserPlaceholderWithSize:TGCallAvatarLargeSize uid:state.peer.uid firstName:state.peer.firstName lastName:state.peer.lastName placeholder:placeholder];
        }
    }
}

- (void)setLevel:(CGFloat)level
{
    [_volumeView setLevel:level];
}

- (void)layoutSubviews
{
    CGSize avatarSize = TGCallAvatarLargeSize;
    CGSize originalSize = CGSizeApplyAffineTransform(_avatarView.frame.size, CGAffineTransformInvert(_avatarView.transform));
    if (!CGSizeEqualToSize(originalSize, avatarSize))
    {
        _avatarView.transform = CGAffineTransformIdentity;
        _avatarView.frame = CGRectMake(0, 0, avatarSize.width, avatarSize.height);
    }
    
    CGFloat scale = _largeAvatar || _forcedLargeAvatar ? 1.0f : [TGCallAvatarView normalScale];
    _avatarView.transform = CGAffineTransformMakeScale(scale, scale);

    _volumeView.frame = _avatarView.frame;
}

@end


@implementation TGCallSpeechVolumeView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self != nil)
    {
        self.clipsToBounds = false;
        
        _levelView = [[TGCallSpeechCircleView alloc] init];
        _levelView.color = UIColorRGBA(0xffffff, 0.4f);
        [self addSubview:_levelView];
        
        _ripples = [[NSMutableArray alloc] init];
        
        NSMutableArray *rippleViews = [[NSMutableArray alloc] init];
        for (NSInteger i = 0; i < TGCallSpeechRippleMaxCount; i++)
        {
            TGCallSpeechCircleView *rippleView = [[TGCallSpeechCircleView alloc] init];
            rippleView.alpha = 0.0f;
            rippleView.strokeColor = UIColorRGBA(0xffffff, 0.4f);
            rippleView.strokeWidth = 1.5f;
            [rippleViews addObject:rippleView];
            [self addSubview:rippleView];
        }
        _rippleViews = rippleViews;
        
        _completedRipples = [[NSMutableIndexSet alloc] init];
    }
    return self;
}

- (void)setLevel:(CGFloat)level
{
    CGFloat previousInputLevel = _inputLevel;
    _inputLevel = level;
    
    if (_ripples.count < TGCallSpeechRippleMaxCount)
    {
        NSTimeInterval currentTime = CFAbsoluteTimeGetCurrent();
        TGCallSpeechRipple *currentRipple = _ripples.firstObject;
        
        if (currentRipple == nil || (currentTime - currentRipple.creationTime) > TGCallSpeechRippleInterval)
        {
            if (previousInputLevel > TGCallSpeechRippleThreshold && _inputLevel < previousInputLevel - TGCallSpeechRippleDifference)
            {
                TGCallSpeechRipple *ripple = [[TGCallSpeechRipple alloc] init];
                ripple.creationTime = currentTime;
                ripple.startLevel = previousInputLevel;
                ripple.progress = 0.0f;
                [_ripples addObject:ripple];
            }
        }
    }
}

- (void)setHidden:(BOOL)hidden
{
    [super setHidden:hidden];
    
    [self displayLink].paused = hidden;
}

- (CADisplayLink *)displayLink
{
    if (_displayLink == nil)
    {
        _displayLink = [CADisplayLink displayLinkWithTarget:self selector:@selector(tick)];
        _displayLink.paused = true;
        [_displayLink addToRunLoop:[NSRunLoop mainRunLoop] forMode:NSRunLoopCommonModes];
    }
    return _displayLink;
}

- (void)tick
{
    _currentLevel = _currentLevel * 0.8f + _inputLevel * 0.2f;
    
    CGFloat scale = _currentLevel * 0.5f;
    CGFloat initialSize = TGCallAvatarLargeSize.width * [TGCallAvatarView normalScale] * 0.99f;
    CGFloat levelViewSize = (1 + scale) * initialSize;
    _levelView.frame = CGRectMake((self.frame.size.width - levelViewSize) / 2.0f, (self.frame.size.height - levelViewSize) / 2.0f, levelViewSize, levelViewSize);
    
    if (_ripples.count > 0)
    {
        [_rippleViews enumerateObjectsUsingBlock:^(TGCallSpeechCircleView *rippleView, NSUInteger index, __unused BOOL *stop) {
            if (_ripples.count > index)
            {
                TGCallSpeechRipple *ripple = _ripples[index];
                ripple.progress += 0.025f;
                rippleView.alpha = MIN(1.0f, MAX(1.0f - ripple.progress, 0.0f));
                
                CGFloat rippleScale = ripple.startLevel * 0.5f + (0.8f - ripple.startLevel * 0.5f) * ripple.progress;
                CGFloat rippleViewSize = (1 + rippleScale) * initialSize;
                rippleView.frame = CGRectMake((self.frame.size.width - rippleViewSize) / 2.0f, (self.frame.size.height - rippleViewSize) / 2.0f, rippleViewSize, rippleViewSize);
                
                if (ripple.progress >= 1.0f)
                    [_completedRipples addIndex:index];
            }
            else
            {
                rippleView.alpha = 0.0f;
            }
        }];
        
        [_ripples removeObjectsAtIndexes:_completedRipples];
        [_completedRipples removeAllIndexes];
    }
}

@end


@implementation TGCallSpeechCircleView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self != nil)
    {
        self.backgroundColor = [UIColor clearColor];
        self.contentMode = UIViewContentModeRedraw;
        self.opaque = false;
        self.userInteractionEnabled = false;
    }
    return self;
}

- (void)drawRect:(CGRect)rect
{
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    if (self.color != nil)
    {
        CGContextSetFillColorWithColor(context, self.color.CGColor);
        CGContextFillEllipseInRect(context, rect);
    }
    
    if (self.strokeColor != nil)
    {
        CGContextSetLineWidth(context, self.strokeWidth);
        CGContextSetStrokeColorWithColor(context, self.strokeColor.CGColor);
        CGContextStrokeEllipseInRect(context, CGRectInset(rect, self.strokeWidth / 2.0f, self.strokeWidth / 2.0f));
    }
}

@end


@implementation TGCallSpeechRipple

@end
