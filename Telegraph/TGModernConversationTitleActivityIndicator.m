#import "TGModernConversationTitleActivityIndicator.h"

#import <pop/POP.h>
#import <math.h>

typedef enum {
    TGModernConversationTitleActivityIndicatorTypeNone = 0,
    TGModernConversationTitleActivityIndicatorTypeTyping = 1,
    TGModernConversationTitleActivityIndicatorTypeAudioRecording = 2,
    TGModernConversationTitleActivityIndicatorTypeUploading = 3
} TGModernConversationTitleActivityIndicatorType;

@interface TGModernConversationTitleActivityIndicator ()
{
    TGModernConversationTitleActivityIndicatorType _type;
}

@property (nonatomic) CGFloat animationValue;

@end

@implementation TGModernConversationTitleActivityIndicator

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self != nil)
    {
        self.opaque = false;
        self.backgroundColor = [UIColor clearColor];
    }
    return self;
}

- (void)setNone
{
    [self pop_removeAnimationForKey:@"animationValue"];
    _type = TGModernConversationTitleActivityIndicatorTypeNone;
    _animationValue = 0.0f;
}

- (void)_beginAnimationWithDuration:(NSTimeInterval)duration linear:(bool)linear
{
    if ([self pop_animationForKey:@"animationValue"] != nil)
        [self pop_removeAnimationForKey:@"animationValue"];
    
    POPBasicAnimation *animation = [POPBasicAnimation animation];
    animation.property = [POPAnimatableProperty propertyWithName:@"animationValue" initializer:^(POPMutableAnimatableProperty *prop)
    {
        prop.readBlock = ^(TGModernConversationTitleActivityIndicator *view, CGFloat values[])
        {
            if (view != nil)
                values[0] = view.animationValue;
        };
        
        prop.writeBlock = ^(TGModernConversationTitleActivityIndicator *view, const CGFloat values[])
        {
            if (view != nil)
                view.animationValue = values[0];
        };
        
        prop.threshold = 0.01f;
    }];
    animation.fromValue = @(0.0f);
    animation.toValue = @(1.0f);
    animation.timingFunction = [CAMediaTimingFunction functionWithName:linear ? kCAMediaTimingFunctionLinear : kCAMediaTimingFunctionEaseInEaseOut];
    animation.duration = duration;
    animation.repeatForever = true;
    
    [self pop_addAnimation:animation forKey:@"animationValue"];
}

- (void)setTyping
{
    if (_type != TGModernConversationTitleActivityIndicatorTypeTyping)
    {
        _type = TGModernConversationTitleActivityIndicatorTypeTyping;
        [self setNeedsDisplay];
        [self _beginAnimationWithDuration:0.7 linear:true];
    }
}

- (void)setAudioRecording
{
    if (_type != TGModernConversationTitleActivityIndicatorTypeAudioRecording)
    {
        _type = TGModernConversationTitleActivityIndicatorTypeAudioRecording;
        [self setNeedsDisplay];
        [self _beginAnimationWithDuration:0.7 linear:true];
    }
}

- (void)setUploading
{
    if (_type != TGModernConversationTitleActivityIndicatorTypeUploading)
    {
        _type = TGModernConversationTitleActivityIndicatorTypeUploading;
        [self setNeedsDisplay];
        [self _beginAnimationWithDuration:1.75 linear:false];
    }
}

- (void)setAnimationValue:(CGFloat)animationValue
{
    _animationValue = animationValue;
    [self setNeedsDisplay];
}

const CGFloat minDiameter = 3.0f;
const CGFloat maxDiameter = 4.5f;

- (CGFloat)interpolateFrom:(CGFloat)from to:(CGFloat)to value:(CGFloat)value
{
    return (1.0f - value) * from + value * to;
}

- (CGFloat)radiusFunction:(CGFloat)value timeOffset:(CGFloat)timeOffset
{
    CGFloat clampedValue = value + timeOffset;
    if (clampedValue > 1.0f)
    {
        clampedValue = clampedValue - CGFloor(clampedValue);
    }
    
    if (clampedValue < 0.4f)
    {
        return [self interpolateFrom:minDiameter to:maxDiameter value:clampedValue / 0.4f];
    }
    else if (clampedValue < 0.8f)
    {
        return [self interpolateFrom:maxDiameter to:minDiameter value:(clampedValue - 0.4f) / 0.4f];
    }
    else
        return minDiameter;
}

- (void)drawRect:(CGRect)__unused rect
{
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    switch (_type)
    {
        case TGModernConversationTitleActivityIndicatorTypeTyping:
        {
            CGFloat leftPadding = 6.0f;
            CGFloat topPadding = 9.0f;
            CGFloat distance = 11.0f / 2.0f;
            
            CGFloat minAlpha = 0.75f;
            CGFloat deltaAlpha = 1.0f - minAlpha;
            
            CGFloat radius = 0.0f;
            
            radius = [self radiusFunction:_animationValue timeOffset:0.4f];
            radius = (MAX(minDiameter, radius) - minDiameter) / (maxDiameter - minDiameter);
            radius = radius * 1.5f;
            
            UIColor *dotsColor = nil;
            
            dotsColor = [UIColor colorWithRed:0 green:123.0f / 255.0f blue:255.0f / 255.0f alpha:(radius * deltaAlpha + minAlpha)];
            CGContextSetFillColorWithColor(context, dotsColor.CGColor);
            CGContextFillEllipseInRect(context, CGRectMake(leftPadding-minDiameter / 2.0f - radius / 2.0f, topPadding -minDiameter / 2.0f - radius / 2.0f, minDiameter + radius, minDiameter + radius));
            
            radius = [self radiusFunction:_animationValue timeOffset:0.2f];
            radius = (MAX(minDiameter, radius) - minDiameter) / (maxDiameter - minDiameter);
            radius = radius * 1.5f;
            
            dotsColor = [UIColor colorWithRed:0 green:123.0f/255.0f blue:255.0f/255.0f alpha:(radius * deltaAlpha + minAlpha)];
            CGContextSetFillColorWithColor(context, dotsColor.CGColor);
            CGContextFillEllipseInRect(context, CGRectMake(leftPadding + distance - minDiameter / 2.0f - radius / 2.0f, topPadding - minDiameter / 2.0f - radius / 2.0f, minDiameter + radius, minDiameter + radius));
            
            radius = [self radiusFunction:_animationValue timeOffset:0.0f];
            radius = (MAX(minDiameter, radius) - minDiameter)/(maxDiameter-minDiameter);
            radius = radius * 1.5f;
            
            dotsColor = [UIColor colorWithRed:0 green:123.0f / 255.0f blue:255.0f / 255.0f alpha:(radius * deltaAlpha + minAlpha)];
            CGContextSetFillColorWithColor(context, dotsColor.CGColor);
            CGContextFillEllipseInRect(context, CGRectMake(leftPadding + distance * 2.0f - minDiameter / 2.0f - radius / 2.0f, topPadding - minDiameter / 2.0f - radius / 2.0f, minDiameter + radius, minDiameter + radius));
            
            break;
        }
        case TGModernConversationTitleActivityIndicatorTypeAudioRecording:
        {
            CGContextRef context = UIGraphicsGetCurrentContext();
            
            CGFloat color[4] = {0.0f, 123.0f / 255.0f, 1.0f, 1.0f};
            CGContextSetStrokeColor(context, color);
            CGContextSetLineCap(context, kCGLineCapRound);
            
            CGContextSetLineWidth(context, 2);
            
            CGFloat delta = 5.0f;
            CGFloat x = 3.0f;
            CGFloat y = self.bounds.size.height / 2.0f + 1.0f;
            CGFloat angle = (CGFloat)(18.0f * M_PI / 180.0);
            
            CGFloat animationValue = _animationValue * delta;
            
            CGFloat radius;
            CGFloat alpha;
            
            radius = animationValue;
            
            alpha = radius/(3*delta);
            alpha = 1.0f - (CGFloat)pow(cos(alpha * M_PI), 50);
            CGContextSetAlpha(context, alpha);
            
            CGContextBeginPath(context);
            CGContextAddArc(context, x, y, radius, -angle, angle, 0);
            CGContextStrokePath(context);
            
            radius = animationValue + delta;
            
            alpha = radius / (3.0f * delta);
            alpha = 1.0f - (CGFloat)pow(cos(alpha * M_PI), 10);
            CGContextSetAlpha(context, alpha);
            
            CGContextBeginPath(context);
            CGContextAddArc(context, x, y, radius, -angle, angle, 0);
            CGContextStrokePath(context);
            
            radius = animationValue + delta*2;
            
            alpha = radius / (3.0f * delta);
            alpha = 1.0f - (CGFloat)pow(cos(alpha * M_PI), 10);
            CGContextSetAlpha(context, alpha);
            
            CGContextBeginPath(context);
            CGContextAddArc(context, x, y, radius, -angle, angle, 0);
            CGContextStrokePath(context);
            
            break;
        }
        case TGModernConversationTitleActivityIndicatorTypeUploading:
        {
            CGFloat leftPadding = 11.0f / 2.0f - 1.0f;
            CGFloat topPadding = 12.0f / 2.0f + 1.0f;
            
            CGFloat progressWidth = 26.0f / 2.0f;
            CGFloat progressHeight = 8.0f / 2.0f;
            
            CGFloat progress;
            CGFloat round = 1.25;
            
            UIBezierPath *path;
            
            UIColor *dotsColor = [UIColor colorWithWhite:247.0f / 255.0f alpha:1.0f];
            CGContextSetFillColorWithColor(context, dotsColor.CGColor);
            
            path = [UIBezierPath bezierPathWithRoundedRect:CGRectMake(leftPadding, topPadding, progressWidth, progressHeight) cornerRadius:round];
            [path fillWithBlendMode:kCGBlendModeNormal alpha:1.0f];
            
            dotsColor = [UIColor colorWithRed:0.0f green:123.0f / 255.0f blue:255.0f / 255.0f alpha:0.3f];
            CGContextSetFillColorWithColor(context, dotsColor.CGColor);
            
            path = [UIBezierPath bezierPathWithRoundedRect:CGRectMake(leftPadding, topPadding, progressWidth, progressHeight) cornerRadius:round];
            [path fillWithBlendMode:kCGBlendModeNormal alpha:1.0f];
            
            progress = [self interpolateFrom:0.0f to:progressWidth * 2.0f value:_animationValue];
            
            dotsColor = [UIColor colorWithRed:0 green:123 / 255.0f blue:255.0f / 255.0f alpha:1.0f];
            CGContextSetFillColorWithColor(context, dotsColor.CGColor);
            
            path = [UIBezierPath bezierPathWithRoundedRect:CGRectMake(leftPadding - progressWidth + progress, topPadding, progressWidth, progressHeight) cornerRadius:round];
            [path fillWithBlendMode:kCGBlendModeSourceIn alpha:1.0f];
            
            break;
        }
        default:
            break;
    }
}

@end
