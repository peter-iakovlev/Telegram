#import "TGInputAccessoryView.h"

@implementation TGInputAccessoryView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:CGRectMake(frame.origin.x, frame.origin.y, frame.size.width, 0.1f)];
    if (self != nil)
    {
        self.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        self.userInteractionEnabled = false;
    }
    return self;
}

- (CGSize)intrinsicContentSize
{
    return CGSizeMake(UIViewNoIntrinsicMetric, self.height);
}

- (void)setHeight:(CGFloat)height
{
    if (height < FLT_EPSILON)
        height = 0.1f;
    
    _height = height;
    [self invalidateIntrinsicContentSize];
    [self.superview layoutSubviews];
}

- (void)willMoveToSuperview:(UIView *)newSuperview
{
    if (self.superview)
        [self.superview removeObserver:self forKeyPath:@"center"];
    
    [newSuperview addObserver:self forKeyPath:@"center" options:0 context:NULL];
    [super willMoveToSuperview:newSuperview];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)__unused object change:(NSDictionary *)__unused change context:(void *)__unused context
{
    if ([keyPath isEqualToString:@"center"])
    {
        if (self.didPan != nil && self.initialPosition > 0.0f && self.height > 1.0f)
            self.didPan(self.superview.center.y - self.initialPosition);
    }
}

@end
