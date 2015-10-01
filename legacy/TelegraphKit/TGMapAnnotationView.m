#import "TGMapAnnotationView.h"

@interface TGMapAnnotationView ()

@end

@implementation TGMapAnnotationView

@synthesize watcherHandle = _watcherHandle;

@synthesize calloutView = _calloutView;

- (id)initWithAnnotation:(id<MKAnnotation>)annotation reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithAnnotation:annotation reuseIdentifier:reuseIdentifier];
    if (self != nil)
    {
        _calloutView = [[TGCalloutView alloc] init];
        [_calloutView sizeToFit];
        [_calloutView addTarget:self action:@selector(calloutPressed) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:_calloutView];
    }
    return self;
}

- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event
{
    UIView *result = [_calloutView hitTest:CGPointMake(point.x - _calloutView.frame.origin.x, point.y - _calloutView.frame.origin.y) withEvent:event];
    if (result != nil)
        return result;
    
    return nil;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    CGRect calloutFrame = _calloutView.frame;
    calloutFrame.origin.x = CGFloor((self.frame.size.width - calloutFrame.size.width) / 2) - 9;
    calloutFrame.origin.y = -calloutFrame.size.height;
    _calloutView.frame = calloutFrame;
}

- (void)calloutPressed
{
    [_watcherHandle requestAction:@"calloutPressed" options:self];
}

@end
