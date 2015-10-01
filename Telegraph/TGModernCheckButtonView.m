#import "TGModernCheckButtonView.h"

@interface TGModernCheckButtonView ()
{
    UIImageView *_checkView;
}

@property (nonatomic, strong) NSString *viewIdentifier;
@property (nonatomic, strong) NSString *viewStateIdentifier;

@end

@implementation TGModernCheckButtonView

+ (UIImage *)buttonImage:(bool)checked
{
    if (checked)
    {
        static UIImage *image = nil;
        static dispatch_once_t onceToken;
        dispatch_once(&onceToken, ^
        {
            image = [UIImage imageNamed:@"ModernMessageSelectionChecked.png"];
        });
        return image;
    }
    else
    {
        static UIImage *image = nil;
        static dispatch_once_t onceToken;
        dispatch_once(&onceToken, ^
        {
            image = [UIImage imageNamed:@"ModernMessageSelectionUnchecked.png"];
        });
        return image;
    }
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self != nil)
    {
        [self _commonInit];
    }
    return self;
}

- (void)_commonInit
{
    self.exclusiveTouch = true;
    
    _checkView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 30, 30)];
    [self addSubview:_checkView];
}

- (void)willBecomeRecycled
{
}

- (void)setHighlighted:(BOOL)highlighted
{
    [super setHighlighted:highlighted];
    
    if (highlighted)
        _checkView.transform = CGAffineTransformMakeScale(0.8f, 0.8f);
}

- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event
{
    _checkView.transform = CGAffineTransformIdentity;
    
    [super touchesCancelled:touches withEvent:event];
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    UITouch *touch = [touches anyObject];
    
    if (!CGRectContainsPoint(self.bounds, [touch locationInView:self]))
    {
        _checkView.transform = CGAffineTransformIdentity;
    }
    else
    {
        _checkView.transform = CGAffineTransformMakeScale(0.8f, 0.8f);
    }
    
    [super touchesEnded:touches withEvent:event];
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    UITouch *touch = [touches anyObject];
    
    if (!CGRectContainsPoint(self.bounds, [touch locationInView:self]))
    {
        _checkView.transform = CGAffineTransformIdentity;
    }
    else
    {
        _checkView.transform = CGAffineTransformMakeScale(0.8f, 0.8f);
    }
    
    [super touchesMoved:touches withEvent:event];
}

- (void)setChecked:(bool)checked animated:(bool)animated
{
    _checkView.image = [TGModernCheckButtonView buttonImage:checked];
    
    if (animated)
    {
        _checkView.transform = CGAffineTransformMakeScale(0.8f, 0.8f);
        if (checked)
        {
            [UIView animateWithDuration:0.12 delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^
            {
                _checkView.transform = CGAffineTransformMakeScale(1.16f, 1.16f);
            } completion:^(BOOL finished)
            {
                if (finished)
                {
                    [UIView animateWithDuration:0.08 delay:0 options:UIViewAnimationOptionCurveEaseIn animations:^
                    {
                        _checkView.transform = CGAffineTransformIdentity;
                    } completion:nil];
                }
            }];
        }
        else
        {
            [UIView animateWithDuration:0.16 delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^
            {
                _checkView.transform = CGAffineTransformIdentity;
            } completion:nil];
        }
    }
    else
    {
        _checkView.transform = CGAffineTransformIdentity;
    }
}


@end
