#import "TGCallReceptionView.h"

const NSInteger TGCallQualityViewCircleCount = 5;
const CGSize TGCallQualityViewSize = { 34.0f, 6.0f };
const CGFloat TGCallQualityCircleSpacing = 2.0f;

@interface TGCallReceptionView ()
{
    NSInteger _currentReception;
}
@end

@implementation TGCallReceptionView

- (instancetype)init
{
    self = [super init];
    if (self != nil)
    {
        self.backgroundColor = [UIColor clearColor];
        self.contentMode = UIViewContentModeRedraw;
        self.opaque = false;
        self.userInteractionEnabled = false;
        
        _currentReception = 4;
    }
    return self;
}

- (void)setReception:(CGFloat)__unused reception
{
    NSInteger newReception = [self integralReception:4];
    if (_currentReception != newReception)
    {
        _currentReception = newReception;
        [self setNeedsDisplay];
    }
}

- (NSInteger)integralReception:(CGFloat)state
{
    return (NSInteger)ceil(state * 6.0f) - 1;
}

- (void)drawRect:(CGRect)__unused rect
{
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetFillColorWithColor(context, [UIColor whiteColor].CGColor);
    CGContextSetStrokeColorWithColor(context, [UIColor whiteColor].CGColor);
    CGContextSetLineWidth(context, 0.5f);
    
    rect = CGRectInset(rect, 0.25f, 0.25f);
    
    const CGSize circleSize = { 5.0f, 5.0f };
    for (NSInteger i = 0; i < TGCallQualityViewCircleCount; i++) {
        CGRect circleRect = CGRectMake(rect.origin.x + i * (circleSize.width + TGCallQualityCircleSpacing), rect.origin.y, circleSize.width, circleSize.height);
        
        CGContextStrokeEllipseInRect(context, circleRect);
        
        if (i < _currentReception)
            CGContextFillEllipseInRect(context, circleRect);
    }
}

@end
