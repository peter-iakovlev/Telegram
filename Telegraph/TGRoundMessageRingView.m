#import "TGRoundMessageRingView.h"

#import <pop/POP.h>

#import "TGMusicPlayer.h"

@interface TGRoundMessageRingView ()
{
    CGFloat _immediateProgress;
}

@property (nonatomic, strong) NSString *viewIdentifier;
@property (nonatomic, strong) NSString *viewStateIdentifier;

@end

@implementation TGRoundMessageRingView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self != nil)
    {
        self.backgroundColor = [UIColor clearColor];
        self.userInteractionEnabled = false;
    }
    return self;
}

- (void)willBecomeRecycled
{
    [self pop_removeAnimationForKey:@"indicator"];
    
    _immediateProgress = 0.0f;
    [self setNeedsDisplay];
}

- (void)setImmediateProgress:(CGFloat)value
{
    CGFloat delta = fabs(_immediateProgress - value);
    _immediateProgress = value;
    
    if (delta > DBL_EPSILON)
        [self setNeedsDisplay];
}

- (void)setStatus:(TGMusicPlayerStatus *)status
{
    static POPAnimatableProperty *property = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^
    {
        property = [POPAnimatableProperty propertyWithName:@"playbackOffset" initializer:^(POPMutableAnimatableProperty *prop)
        {
            prop.readBlock = ^(TGRoundMessageRingView *strongSelf, CGFloat *values)
            {
                values[0] = strongSelf->_immediateProgress;
            };
            
            prop.writeBlock = ^(TGRoundMessageRingView *strongSelf, CGFloat const *values)
            {
                [strongSelf setImmediateProgress:values[0]];
            };
        }];
    });
    
    if (status == nil || status.paused || status.duration < FLT_EPSILON || status.offset < 0.01)
    {
        [self pop_removeAnimationForKey:@"indicator"];
        
        if (status == nil)
            [self setImmediateProgress:0.0f];
        else
            [self setImmediateProgress:status.offset];
    }
    else
    {
        [self pop_removeAnimationForKey:@"indicator"];
        POPBasicAnimation *animation = [self pop_animationForKey:@"indicator"];
        if (animation == nil)
        {
            animation = [POPBasicAnimation linearAnimation];
            [animation setProperty:property];
            animation.removedOnCompletion = true;
            if (ABS(status.offset - _immediateProgress) < 0.3) {
                animation.fromValue = @(_immediateProgress);
            } else {
                animation.fromValue = @(status.offset);
            }
            animation.toValue = @(1.0f);
            animation.beginTime = status.timestamp;
            animation.duration = (1.0f - status.offset) * status.duration;
            [self pop_addAnimation:animation forKey:@"indicator"];
        }
    }
}


- (void)drawRect:(CGRect)rect
{
    if (_immediateProgress < DBL_EPSILON)
        return;
    
    CGPoint centerPoint = CGPointMake(rect.size.width / 2.0f, rect.size.height / 2.0f);
    CGFloat lineWidth = 4.0f;
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetStrokeColorWithColor(context, UIColorRGBA(0xffffff, 0.6f).CGColor);
    CGContextSetLineWidth(context, 4.0f);
    CGContextSetLineCap(context, kCGLineCapRound);
    CGContextSetLineJoin(context, kCGLineJoinMiter);
    CGContextSetMiterLimit(context, 10);
    
    CGMutablePathRef path = CGPathCreateMutable();
    CGPathAddArc(path, NULL, centerPoint.x, centerPoint.y, rect.size.width / 2.0f - lineWidth / 2.0f, -M_PI_2, -M_PI_2 + 2 * M_PI * _immediateProgress, false);
    CGContextAddPath(context, path);
    CGPathRelease(path);
    
    CGContextStrokePath(context);
}

@end
