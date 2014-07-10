#import "TGModernColorViewModel.h"

#import "TGModernColorView.h"

@interface TGModernColorViewModel ()
{
    UIColor *_color;
}

@end

@implementation TGModernColorViewModel

- (instancetype)initWithColor:(UIColor *)color
{
    self = [super init];
    if (self != nil)
    {
        _color = color;
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
        CGContextFillRect(context, self.bounds);
    }
}

@end
