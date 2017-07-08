#import "TGModernColorViewModel.h"

#import "TGModernColorView.h"

@interface TGModernColorViewModel ()
{
    UIColor *_color;
    CGFloat _cornerRadius;
}

@end

@implementation TGModernColorViewModel

- (instancetype)initWithColor:(UIColor *)color
{
    return [self initWithColor:color cornerRadius:0.0f];
}

- (instancetype)initWithColor:(UIColor *)color cornerRadius:(CGFloat)cornerRadius
{
    self = [super init];
    if (self != nil)
    {
        _color = color;
        _cornerRadius = cornerRadius;
    }
    return self;
}

- (Class)viewClass
{
    return [TGModernColorView class];
}

- (void)bindViewToContainer:(UIView *)container viewStorage:(TGModernViewStorage *)viewStorage
{
    [super bindViewToContainer:container viewStorage:viewStorage];
    
    [self boundView].backgroundColor = _color;
}

- (void)drawInContext:(CGContextRef)context
{
    [super drawInContext:context];
    
    if (!self.skipDrawInContext && _color != nil && self.alpha > FLT_EPSILON)
    {
        CGContextSetFillColorWithColor(context, _color.CGColor);
        if (_cornerRadius > FLT_EPSILON) {
            CGContextAddPath(context, [UIBezierPath bezierPathWithRoundedRect:self.bounds cornerRadius:_cornerRadius].CGPath);
            CGContextFillPath(context);
        } else {
            CGContextFillRect(context, self.bounds);
        }
    }
}

@end
