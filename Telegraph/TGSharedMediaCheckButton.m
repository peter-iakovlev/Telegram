#import "TGSharedMediaCheckButton.h"

@interface TGSharedMediaCheckButton ()
{
    UIImageView *_checkView;
}

@end

@implementation TGSharedMediaCheckButton

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
    
    _checkView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 24, 24)];
    [self addSubview:_checkView];
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
        _checkView.transform = CGAffineTransformIdentity;
    else
        _checkView.transform = CGAffineTransformMakeScale(0.8f, 0.8f);
    
    [super touchesEnded:touches withEvent:event];
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    UITouch *touch = [touches anyObject];
    
    if (!CGRectContainsPoint(self.bounds, [touch locationInView:self]))
        _checkView.transform = CGAffineTransformIdentity;
    else
        _checkView.transform = CGAffineTransformMakeScale(0.8f, 0.8f);
    
    [super touchesMoved:touches withEvent:event];
}

- (UIImage *)checkedImage
{
    static UIImage *image = nil;
    if (image == nil)
        image = [UIImage imageNamed:@"SharedMediaListItemCheck_Checked.png"];
    return image;
}

- (UIImage *)uncheckedImage
{
    static UIImage *image = nil;
    if (image == nil)
        image = [UIImage imageNamed:@"SharedMediaListItemCheck.png"];
    return image;
}

- (void)setChecked:(bool)checked animated:(bool)animated
{
    _checkView.image = checked ? [self checkedImage] : [self uncheckedImage];
    
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
