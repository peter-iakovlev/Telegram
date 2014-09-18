#import "TGCircularProgressView.h"

@interface TGCircularProgressView ()

@property (nonatomic) float progress;

@property (nonatomic, strong) UIColor *progressColor;

@end

@implementation TGCircularProgressView

- (void)setProgress:(float)progress
{
    if (ABS(progress - _progress) > FLT_EPSILON)
    {
        _progress = progress;
        [self setNeedsDisplay];
    }
}

#pragma mark - Lifecycle

- (id)init
{
	return [self initWithFrame:CGRectMake(0, 0, 50, 50)];
}

- (id)initWithFrame:(CGRect)frame
{
	self = [super initWithFrame:frame];
	if (self)
    {
		self.backgroundColor = [UIColor clearColor];
		self.opaque = false;
		_progress = 0.0f;
		_progressColor = [[UIColor alloc] initWithWhite:1.f alpha:1.f];
	}
	return self;
}

- (void)drawRect:(CGRect)__unused rect
{   
	CGRect allRect = self.bounds;
	CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGPoint center = CGPointMake(allRect.size.width / 2, allRect.size.height / 2);
    CGFloat radius = (allRect.size.width) / 2;
    CGFloat startAngle = - ((float)M_PI / 2);
    CGFloat endAngle = (self.progress * 2 * (float)M_PI) + startAngle;
    CGContextSetRGBFillColor(context, 1.0f, 1.0f, 1.0f, 1.0f);
    CGContextMoveToPoint(context, center.x, center.y);
    CGContextAddArc(context, center.x, center.y, radius, startAngle, endAngle, 0);
    CGContextClosePath(context);
    CGContextFillPath(context);
}

@end
