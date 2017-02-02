#import "TGScrollIndicatorView.h"

const UIEdgeInsets TGScrollIndicatorViewInsets = { 3.0f, 3.0f, 3.0f, 3.0f };
const CGFloat TGScrollIndicatorViewWidth = 2.5f;
const CGFloat TGScrollIndicatorViewMinimalHeight = 7.0f;

@interface TGScrollIndicatorView ()
{
    bool _hidden;
}
@end

@implementation TGScrollIndicatorView

- (instancetype)init
{
    _color = [UIColor colorWithWhite:0.0f alpha:0.35f];
    
    static dispatch_once_t onceToken;
    static UIImage *image;
    dispatch_once(&onceToken, ^
    {
        CGRect rect = CGRectMake(0, 0, 2.5f, 2.5f);
        UIGraphicsBeginImageContextWithOptions(rect.size, false, 2.0f);
        CGContextRef context = UIGraphicsGetCurrentContext();
        
        CGContextSetFillColorWithColor(context, _color.CGColor);
        [[UIBezierPath bezierPathWithRoundedRect:rect cornerRadius:1.0f] fill];
        
        image = [UIGraphicsGetImageFromCurrentImageContext() resizableImageWithCapInsets:UIEdgeInsetsMake(1, 1, 1, 1)];
        UIGraphicsEndImageContext();
    });
    
    self = [super initWithImage:image];
    if (self != nil)
    {
        self.alpha = 0.0f;
    }
    return self;
}

- (void)setColor:(UIColor *)color
{
    _color = color;
    
    CGRect rect = CGRectMake(0, 0, 2.5f, 2.5f);
    UIGraphicsBeginImageContextWithOptions(rect.size, false, 2.0f);
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGContextSetFillColorWithColor(context, _color.CGColor);
    [[UIBezierPath bezierPathWithRoundedRect:rect cornerRadius:1.0f] fill];
    
    UIImage *image = [UIGraphicsGetImageFromCurrentImageContext() resizableImageWithCapInsets:UIEdgeInsetsMake(1, 1, 1, 1)];
    UIGraphicsEndImageContext();
    
    self.image = image;
}

- (void)updateScrollViewDidScroll
{
    UIScrollView *scrollView = (UIScrollView *)self.superview;
    [self updatePositionWithScrollView:scrollView];
 
    if (_hidden)
        return;
    
    self.alpha = 1.0f;
}

- (void)updateScrollViewDidEndScrolling
{
    if (_hidden)
        return;
    
    [UIView animateWithDuration:0.25f animations:^
    {
        self.alpha = 0.0f;
    }];
}

- (void)updatePositionWithScrollView:(UIScrollView *)scrollView
{
    if (scrollView.frame.size.height < FLT_EPSILON || scrollView.contentSize.height < FLT_EPSILON || isnan(scrollView.contentOffset.y))
        return;
    
    CGRect viewportFrame = CGRectMake(TGScrollIndicatorViewInsets.left, scrollView.contentOffset.y + TGScrollIndicatorViewInsets.top, scrollView.frame.size.width - TGScrollIndicatorViewInsets.left - TGScrollIndicatorViewInsets.right, scrollView.frame.size.height - TGScrollIndicatorViewInsets.top - TGScrollIndicatorViewInsets.bottom);
    
    CGFloat height = viewportFrame.size.height * (scrollView.frame.size.height / scrollView.contentSize.height);
    CGFloat position = scrollView.contentOffset.y / (scrollView.contentSize.height - scrollView.frame.size.height) * (viewportFrame.size.height - height);
    if (position < 0.0f)
    {
        position = 0.0f;
        height -= scrollView.contentOffset.y * - 1.0f;
    }
    else if (position > viewportFrame.size.height - height)
    {
        CGFloat overscroll = scrollView.contentOffset.y - (scrollView.contentSize.height - scrollView.frame.size.height);
        position = viewportFrame.size.height - height + overscroll;
        height -= overscroll;
    }
    height = MAX(TGScrollIndicatorViewMinimalHeight, height);
    
    if (isnan(height))
        height = 0.0f;
    if (isnan(position)) {
        position = 0.0f;
    }
    
    self.frame = CGRectMake(CGRectGetMaxX(viewportFrame) - TGScrollIndicatorViewWidth, CGRectGetMinY(viewportFrame) + position, TGScrollIndicatorViewWidth, height);
}

- (void)setHidden:(bool)hidden animated:(bool)animated
{
    if (_hidden == hidden)
        return;
    
    _hidden = hidden;
    
    if (!hidden)
        return;
    
    if (animated)
    {
        [UIView animateWithDuration:0.25f animations:^
        {
            self.alpha = 0.0f;
        }];
    }
    else
    {
        self.alpha = 0.0f;
    }
}

@end
