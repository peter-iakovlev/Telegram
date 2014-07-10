#import "TGModernClockProgressView.h"

#import <QuartzCore/QuartzCore.h>

@interface TGModernClockProgressView ()
{
    CALayer *_frameLayer;
    CALayer *_minLayer;
    CALayer *_hourLayer;
    
    bool _animating;
}

@property (nonatomic, strong) NSString *viewIdentifier;
@property (nonatomic, strong) NSString *viewStateIdentifier;

@end

@implementation TGModernClockProgressView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self != nil)
    {
        _frameLayer = [[CALayer alloc] init];
        _frameLayer.frame = CGRectMake(0, 0, 15, 15);
        [self.layer addSublayer:_frameLayer];
        
        _hourLayer = [[CALayer alloc] init];
        _hourLayer.frame = CGRectMake(0, 0, 15, 15);
        [self.layer addSublayer:_hourLayer];
        
        _minLayer = [[CALayer alloc] init];
        _minLayer.frame = CGRectMake(0, 0, 15, 15);
        [self.layer addSublayer:_minLayer];
        
        _frameLayer.actions = [NSDictionary dictionaryWithObject:[NSNull null] forKey:@"content"];
        _hourLayer.actions = [NSDictionary dictionaryWithObject:[NSNull null] forKey:@"content"];
        _minLayer.actions = [NSDictionary dictionaryWithObject:[NSNull null] forKey:@"content"];
    }
    return self;
}

- (void)setFrameImage:(CGImageRef)frameImage hourImage:(CGImageRef)hourImage minImage:(CGImageRef)minImage
{
    _frameLayer.contents = (__bridge id)frameImage;
    _hourLayer.contents = (__bridge id)hourImage;
    _minLayer.contents = (__bridge id)minImage;
}

- (void)willBecomeRecycled
{
    [self stopAnimating];
}

- (CAAnimation *)_createRotationAnimationWithDuration:(NSTimeInterval)duration
{
    CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"transform.rotation.z"];
    [animation setFromValue:@(0.0f)];
    [animation setToValue:@((float)M_PI * 2.0f)];
    [animation setDuration:duration];
    [animation setRepeatCount:INFINITY];
    [animation setAutoreverses:false];
    
    return animation;
}

- (void)didMoveToWindow
{
    if (_animating != (self.window != nil))
    {
        if (self.window == nil)
            [self stopAnimating];
        else
            [self startAnimating];
    }
    
    [super didMoveToWindow];
}

- (void)startAnimating
{
    if (_animating)
        [self stopAnimating];
    
    [_hourLayer addAnimation:[self _createRotationAnimationWithDuration:1.0 * 6.0] forKey:@"transform.rotation.z"];
    [_minLayer addAnimation:[self _createRotationAnimationWithDuration:1.0] forKey:@"transform.rotation.z"];
    
    _animating = true;
}

- (void)stopAnimating
{
    [_hourLayer removeAnimationForKey:@"transform.rotation.z"];
    [_minLayer removeAnimationForKey:@"transform.rotation.z"];
    
    _animating = false;
}

@end
