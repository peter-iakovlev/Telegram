/*
 * This is the source code of Telegram for iOS v. 1.1
 * It is licensed under GNU GPL v. 2 or later.
 * You should have received a copy of the license in this archive (see LICENSE).
 *
 * Copyright Peter Iakovlev, 2013.
 */

#import "TGModernConversationInputMicButton.h"

#import "TGOverlayController.h"
#import "TGOverlayControllerWindow.h"

static const CGFloat innerCircleRadius = 110.0f;
static const CGFloat outerCircleRadius = innerCircleRadius + 50.0f;
static const CGFloat outerCircleMinScale = innerCircleRadius / outerCircleRadius;

@interface TGModernConversationInputMicButtonOverlayController : TGOverlayController

@end

@implementation TGModernConversationInputMicButtonOverlayController

- (void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    [super willAnimateRotationToInterfaceOrientation:toInterfaceOrientation duration:duration];
    
    [self.view.window.layer removeAnimationForKey:@"backgroundColor"];
    [CATransaction begin];
    [CATransaction setDisableActions:true];
    self.view.window.layer.backgroundColor = [UIColor clearColor].CGColor;
    [CATransaction commit];
    
    for (UIView *view in self.view.window.subviews)
    {
        if (view != self.view)
        {
            [view removeFromSuperview];
            break;
        }
    }
}

@end

@interface TGModernConversationInputMicButton () <UIGestureRecognizerDelegate>
{
    CGPoint _touchLocation;
    UIPanGestureRecognizer *_panRecognizer;
    
    CGFloat _lastVelocity;
    
    bool _processCurrentTouch;
    CFAbsoluteTime _lastTouchTime;
    bool _acceptTouchDownAsTouchUp;
    
    UIWindow *_overlayWindow;
    
    UIImageView *_innerCircleView;
    UIImageView *_outerCircleView;
    UIImageView *_innerIconView;
    
    CFAbsoluteTime _animationStartTime;
    
    CADisplayLink *_displayLink;
    CGFloat _currentLevel;
    CGFloat _inputLevel;
    bool _animatedIn;
}

@end

@implementation TGModernConversationInputMicButton

- (UIImage *)innerCircleImage {
    static UIImage *image = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        UIGraphicsBeginImageContextWithOptions(CGSizeMake(innerCircleRadius, innerCircleRadius), false, 0.0f);
        CGContextRef context = UIGraphicsGetCurrentContext();
        CGContextSetFillColorWithColor(context, TGAccentColor().CGColor);
        CGContextFillEllipseInRect(context, CGRectMake(0.0f, 0.0f, innerCircleRadius, innerCircleRadius));
        image = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
    });
    return image;
}

- (UIImage *)outerCircleImage {
    static UIImage *image = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        UIGraphicsBeginImageContextWithOptions(CGSizeMake(outerCircleRadius, outerCircleRadius), false, 0.0f);
        CGContextRef context = UIGraphicsGetCurrentContext();
        CGContextSetFillColorWithColor(context, [TGAccentColor() colorWithAlphaComponent:0.2f].CGColor);
        CGContextFillEllipseInRect(context, CGRectMake(0.0f, 0.0f, outerCircleRadius, outerCircleRadius));
        image = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
    });
    return image;
}

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self != nil)
    {
        self.exclusiveTouch = true;
        self.multipleTouchEnabled = false;
        
        _panRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panGesture:)];
        _panRecognizer.cancelsTouchesInView = false;
        _panRecognizer.delegate = self;
        [self addGestureRecognizer:_panRecognizer];
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

- (BOOL)beginTrackingWithTouch:(UITouch *)touch withEvent:(UIEvent *)event
{
    if ([super beginTrackingWithTouch:touch withEvent:event])
    {
        if (_acceptTouchDownAsTouchUp)
        {
            _acceptTouchDownAsTouchUp = false;
            _processCurrentTouch = false;
            
            [self _commitCompleted];
        }
        else
        {
            _lastVelocity = 0.0;
            
            if (ABS(CFAbsoluteTimeGetCurrent() - _lastTouchTime) < 1.0)
            {
                _processCurrentTouch = false;
                
                return false;
            }
            else
            {
                _processCurrentTouch = true;
                _lastTouchTime = CFAbsoluteTimeGetCurrent();
            
                id<TGModernConversationInputMicButtonDelegate> delegate = _delegate;
                if ([delegate respondsToSelector:@selector(micButtonInteractionBegan)])
                    [delegate micButtonInteractionBegan];
                
                _touchLocation = [touch locationInView:self];
            }
        }
        
        return true;
    }
    
    return false;
}

- (void)animateIn {
    _animatedIn = true;
    _animationStartTime = CACurrentMediaTime();
    
    if (_overlayWindow == nil) {
        _overlayWindow = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
        _overlayWindow.windowLevel = 1000000000.0f;
        _overlayWindow.rootViewController = [[TGModernConversationInputMicButtonOverlayController alloc] init];

        _innerCircleView = [[UIImageView alloc] initWithImage:[self innerCircleImage]];
        _innerCircleView.alpha = 0.0f;
        [_overlayWindow.rootViewController.view addSubview:_innerCircleView];
        
        _outerCircleView = [[UIImageView alloc] initWithImage:[self outerCircleImage]];
        _outerCircleView.alpha = 0.0f;
        [_overlayWindow.rootViewController.view addSubview:_outerCircleView];
        
        _innerIconView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"InputMicRecordingOverlay.png"]];
        _innerIconView.alpha = 0.0f;
        [_overlayWindow.rootViewController.view addSubview:_innerIconView];
    }
    
    _overlayWindow.hidden = false;
    
    dispatch_block_t block = ^{
        CGPoint centerPoint = [self.superview convertPoint:self.center toView:_overlayWindow.rootViewController.view];
        _innerCircleView.center = centerPoint;
        _outerCircleView.center = centerPoint;
        _innerIconView.center = centerPoint;
    };
    
    block();
    dispatch_async(dispatch_get_main_queue(), block);
    
    _innerCircleView.transform = CGAffineTransformMakeScale(0.2f, 0.2f);
    _outerCircleView.transform = CGAffineTransformMakeScale(0.2f, 0.2f);
    _innerCircleView.alpha = 0.2f;
    _outerCircleView.alpha = 0.2f;
    if (iosMajorVersion() >= 8) {
        [UIView animateWithDuration:0.50 delay:0.0 usingSpringWithDamping:0.55f initialSpringVelocity:0.0f options:UIViewAnimationOptionBeginFromCurrentState animations:^{
            _innerCircleView.transform = CGAffineTransformIdentity;
            _outerCircleView.transform = CGAffineTransformMakeScale(outerCircleMinScale, outerCircleMinScale);
        } completion:nil];
        
        [UIView animateWithDuration:0.1 animations:^{
            _innerCircleView.alpha = 1.0f;
            self.iconView.alpha = 0.0f;
            _innerIconView.alpha = 1.0f;
            _outerCircleView.alpha = 1.0f;
        }];
    }
    [self displayLink].paused = false;
}

- (void)animateOut {
    _animatedIn = false;
    _displayLink.paused = true;
    _currentLevel = 0.0f;
    [UIView animateWithDuration:0.18 animations:^{
        _innerCircleView.transform = CGAffineTransformMakeScale(0.2f, 0.2f);
    _outerCircleView.transform = CGAffineTransformMakeScale(0.2f, 0.2f);
        _innerCircleView.alpha = 0.0f;
        _outerCircleView.alpha = 0.0f;
        self.iconView.alpha = 1.0f;
        _innerIconView.alpha = 0.0f;
    } completion:^(BOOL finished) {
        if (finished) {
            _overlayWindow.hidden = true;
        }
    }];
}

- (BOOL)continueTrackingWithTouch:(UITouch *)touch withEvent:(UIEvent *)event
{
    if ([super continueTrackingWithTouch:touch withEvent:event])
    {
        _lastVelocity = [_panRecognizer velocityInView:self].x;
        
        if (_processCurrentTouch)
        {
            CGFloat distance = [touch locationInView:self].x - _touchLocation.x;
            
            CGFloat value = (-distance) / 100.0f;
            value = MAX(0.0f, MIN(1.0f, value));
            
            CGFloat velocity = [_panRecognizer velocityInView:self].x;
            
            if (CACurrentMediaTime() > _animationStartTime + 0.50) {
                CGFloat scale = MAX(0.4f, MIN(1.0f, 1.0f - value));
                if (scale > 0.8f) {
                    scale = 1.0f;
                } else {
                    scale /= 0.8f;
                }
                _innerCircleView.transform = CGAffineTransformMakeScale(scale, scale);
            }
            
            if (distance < -100.0f)
            {
                id<TGModernConversationInputMicButtonDelegate> delegate = _delegate;
                if ([delegate respondsToSelector:@selector(micButtonInteractionCancelled:)])
                    [delegate micButtonInteractionCancelled:velocity];
                
                return false;
            }
            
            id<TGModernConversationInputMicButtonDelegate> delegate = _delegate;
            if ([delegate respondsToSelector:@selector(micButtonInteractionUpdate:)])
                [delegate micButtonInteractionUpdate:value];
        
            return true;
        }
    }
    
    return false;
}

- (void)cancelTrackingWithEvent:(UIEvent *)event
{
    if (_processCurrentTouch)
    {
        TGDispatchAfter(1.0, dispatch_get_main_queue(), ^{
            id<TGModernConversationInputMicButtonDelegate> delegate = _delegate;
            if ([[UIApplication sharedApplication] applicationState] == UIApplicationStateActive) {
                if ([delegate respondsToSelector:@selector(micButtonInteractionCancelled:)])
                    [delegate micButtonInteractionCancelled:_lastVelocity];
            } else {
                if ([delegate respondsToSelector:@selector(micButtonInteractionCancelled:)])
                    [delegate micButtonInteractionCancelled:_lastVelocity];
            }
        });
    }
    
    [super cancelTrackingWithEvent:event];
}

- (void)endTrackingWithTouch:(UITouch *)touch withEvent:(UIEvent *)event
{
    if (_processCurrentTouch)
    {   
        CGFloat velocity = _lastVelocity;
        
        id<TGModernConversationInputMicButtonDelegate> delegate = _delegate;
        if (velocity < -400.0f)
        {
            if ([delegate respondsToSelector:@selector(micButtonInteractionCancelled:)])
                [delegate micButtonInteractionCancelled:_lastVelocity];
        }
        else
        {
            [self _commitCompleted];
        }
    }
    
    [super endTrackingWithTouch:touch withEvent:event];
}

- (void)_commitCompleted
{
    id<TGModernConversationInputMicButtonDelegate> delegate = _delegate;
    if ([delegate respondsToSelector:@selector(micButtonInteractionCompleted:)])
        [delegate micButtonInteractionCompleted:_lastVelocity];
}

- (void)panGesture:(UIPanGestureRecognizer *)__unused recognizer
{
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    /*_innerCircleView.center = CGPointMake(self.bounds.size.width / 2.0f, self.bounds.size.height / 2.0f);
    _outerCircleView.center = CGPointMake(self.bounds.size.width / 2.0f, self.bounds.size.height / 2.0f);
    _innerIconView.center = CGPointMake(self.bounds.size.width / 2.0f, self.bounds.size.height / 2.0f);*/
}

- (void)displayLinkUpdate {
    NSTimeInterval t = CACurrentMediaTime();
    if (t > _animationStartTime + 0.5) {
        _currentLevel = _currentLevel * 0.8f + _inputLevel * 0.2f;
        
        CGFloat scale = outerCircleMinScale + _currentLevel * (1.0f - outerCircleMinScale);
        _outerCircleView.transform = CGAffineTransformMakeScale(scale, scale);
    }
}

- (void)addMicLevel:(CGFloat)level {
    _inputLevel = level;
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer {
    return true;
}

@end
