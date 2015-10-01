#import "TGDialogListTitleContainer.h"

@implementation TGDialogListTitleContainer

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self != nil)
    {
        [self addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapGesture:)]];   
    }
    return self;
}

- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)__unused event
{
    if (CGRectContainsPoint(CGRectInset(self.bounds, -70.0f, -44.0f), point))
        return self;
    return nil;
}

- (void)tapGesture:(UITapGestureRecognizer *)recognizer
{
    if (recognizer.state == UIGestureRecognizerStateEnded)
    {
        if (_tappped)
            _tappped();
    }
}

@end
