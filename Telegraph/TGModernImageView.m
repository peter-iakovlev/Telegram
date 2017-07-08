#import "TGModernImageView.h"

@interface TGModernImageView ()
{
    bool _accountForTransform;
}

@property (nonatomic, strong) NSString *viewIdentifier;
@property (nonatomic, strong) NSString *viewStateIdentifier;

@end

@implementation TGModernImageView

- (void)willBecomeRecycled
{
}

- (NSString *)viewStateIdentifier
{
    if (_viewStateIdentifier)
    {
    }
    
    return [[NSString alloc] initWithFormat:@"TGModernImageView/%lx", (long)self.image];
}

- (void)setAccountForTransform:(bool)accountForTransform
{
    _accountForTransform = accountForTransform;
}

- (void)setFrame:(CGRect)frame
{
    if (!_accountForTransform)
    {
        [super setFrame:frame];
    }
    else
    {
        CGAffineTransform transform = self.transform;
        self.transform = CGAffineTransformIdentity;
        [super setFrame:frame];
        self.transform = transform;
    }
}

- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event
{
    if (!UIEdgeInsetsEqualToEdgeInsets(_extendedEdges, UIEdgeInsetsZero))
    {
        CGRect extendedFrame = self.bounds;
        
        extendedFrame.origin.x -= _extendedEdges.left;
        extendedFrame.size.width += _extendedEdges.left;
        extendedFrame.origin.y -= _extendedEdges.top;
        extendedFrame.size.height += _extendedEdges.top;
        
        extendedFrame.size.width += _extendedEdges.right;
        extendedFrame.size.height += _extendedEdges.bottom;
        
        if (CGRectContainsPoint(extendedFrame, point))
            return self;
    }
        
    return [super hitTest:point withEvent:event];
}

@end
