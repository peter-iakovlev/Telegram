#import "TGModernImageView.h"

@interface TGModernImageView ()

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
