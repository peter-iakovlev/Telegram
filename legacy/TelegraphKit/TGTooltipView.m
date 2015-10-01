#import "TGTooltipView.h"

#import <QuartzCore/QuartzCore.h>

@interface TGTooltipView ()

@end

@implementation TGTooltipView

- (id)initWithLeftImage:(UIImage *)leftImage centerImage:(UIImage *)centerImage centerUpImage:(UIImage *)centerUpImage rightImage:(UIImage *)rightImage
{
    self = [super initWithFrame:CGRectZero];
    if (self)
    {
        self.alpha = 0.0f;
        self.layer.anchorPoint = CGPointMake(0.5f, 1.0f);
        self.transform = CGAffineTransformMakeScale(0.1f, 0.1f);
        
        _leftView = [[UIImageView alloc] initWithImage:leftImage];
        [self addSubview:_leftView];
        
        _rightView = [[UIImageView alloc] initWithImage:rightImage];
        [self addSubview:_rightView];
        
        _centerView = [[UIImageView alloc] initWithImage:centerImage];
        [self addSubview:_centerView];
        
        _centerUpView = [[UIImageView alloc] initWithImage:centerUpImage];
        [self addSubview:_centerUpView];
        
        _minLeftWidth = leftImage.size.width;
        _minRightWidth = rightImage.size.width;
    }
    return self;
}

- (void)setArrowLocation:(CGPoint)arrowLocation
{
    _arrowLocation = arrowLocation;
    _centerView.hidden = arrowLocation.y < 0;
    _centerUpView.hidden = !_centerView.hidden;
    
    [self setNeedsLayout];
}

- (void)showInView:(UIView *)view fromRect:(CGRect)rect
{
    CGAffineTransform transform = self.transform;
    self.transform = CGAffineTransformIdentity;
    
    CGRect frame = self.frame;
    frame.origin.x = CGFloor(rect.origin.x + rect.size.width / 2 - frame.size.width / 2);
    if (frame.origin.x < 4)
        frame.origin.x = 4;
    if (frame.origin.x + frame.size.width > view.frame.size.width - 4)
        frame.origin.x = view.frame.size.width - 4 - frame.size.width;
    
    frame.origin.y = rect.origin.y - frame.size.height - 1;
    if (frame.origin.y < 2)
    {
        frame.origin.y = rect.origin.y + rect.size.height + 10;
        if (frame.origin.y + frame.size.height > view.frame.size.height - 14)
        {
            frame.origin.y = CGFloor((view.frame.size.height - frame.size.height) / 2);
        }
    }
    
    self.arrowLocation = CGPointMake(CGFloor(rect.origin.x + rect.size.width / 2) - frame.origin.x, CGFloor(rect.origin.y + rect.size.height / 2) - frame.origin.y);
    
    CGFloat arrowX = MAX(_minLeftWidth, MIN(frame.size.width - _minRightWidth - _centerView.frame.size.width, _arrowLocation.x));
    
    self.layer.anchorPoint = CGPointMake(MAX(0.0f, MIN(1.0f, arrowX / frame.size.width)), _arrowLocation.y < 0 ? -0.2f : 1.0f);
    
    self.frame = frame;
    [self setNeedsLayout];
    [self layoutIfNeeded];
    
    self.transform = transform;
    
    self.layer.rasterizationScale = [[UIScreen mainScreen] scale];
    self.layer.shouldRasterize = true;
    
    self.alpha = 1.0f;
    
    [UIView animateWithDuration:0.142 delay:0 options:UIViewAnimationOptionCurveEaseOut | UIViewAnimationOptionBeginFromCurrentState animations:^
    {
        self.transform = CGAffineTransformMakeScale(1.06f, 1.06f);
    } completion:^(BOOL finished)
    {
        if(finished)
        {
            [UIView animateWithDuration:0.1 delay:0 options:UIViewAnimationOptionBeginFromCurrentState animations:^
            {
                self.transform = CGAffineTransformMakeScale(0.97f, 0.97f);
            } completion:^(BOOL finished)
            {
                if (finished)
                {
                    [UIView animateWithDuration:0.065 delay:0 options:UIViewAnimationOptionCurveEaseOut | UIViewAnimationOptionBeginFromCurrentState animations:^
                    {
                        self.transform = CGAffineTransformIdentity;
                    } completion:^(BOOL finished)
                    {
                        if (finished)
                        {
                            self.layer.shouldRasterize = false;
                        }
                    }];
                }
            }];
        }
    }];
}
- (void)hide:(dispatch_block_t)completion
{
    [UIView animateWithDuration:0.2 delay:0 options:UIViewAnimationOptionBeginFromCurrentState animations:^
    {
        self.alpha = 0.0f;
    } completion:^(BOOL finished)
    {
        if (finished)
        {
            self.transform = CGAffineTransformMakeScale(0.1f, 0.1f);
            
            if (completion)
                completion();
        }
    }];
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    CGSize viewSize = self.bounds.size;
    
    CGFloat arrowX = MAX(_minLeftWidth, MIN(viewSize.width - _minRightWidth - _centerView.frame.size.width, CGFloor(_arrowLocation.x - _centerView.frame.size.width / 2)));
    _centerView.frame = CGRectMake(arrowX, 0, _centerView.frame.size.width, _centerView.frame.size.height);
    _centerUpView.frame = CGRectOffset(_centerView.frame, 0, -8);
    _leftView.frame = CGRectMake(0, 0, _centerView.frame.origin.x, _leftView.frame.size.height);
    _rightView.frame = CGRectMake(_centerView.frame.origin.x + _centerView.frame.size.width, 0, viewSize.width - (_centerView.frame.origin.x + _centerView.frame.size.width), _rightView.frame.size.height);
}

@end

@interface TGTooltipContainerView ()

@end

@implementation TGTooltipContainerView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self != nil)
    {
    }
    return self;
}

- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event
{
    UIView *result = [super hitTest:point withEvent:event];
    if (result == self || result == nil)
    {
        [self hideTooltip];
        
        return nil;
    }
    
    return result;
}

- (void)showTooltipFromRect:(CGRect)rect
{
    _isShowingTooltip = true;
    [_tooltipView showInView:self fromRect:rect];
}

- (void)setFrame:(CGRect)frame
{
    if (!CGSizeEqualToSize(frame.size, self.frame.size))
        [self hideTooltip];
    
    [super setFrame:frame];
}

- (void)hideTooltip
{
    if (_isShowingTooltip)
    {
        _isShowingTooltip = false;
        
        [_tooltipView.watcherHandle requestAction:@"menuWillHide" options:nil];
        
        [_tooltipView hide:^
        {
            [self removeFromSuperview];
        }];
    }
}

@end
