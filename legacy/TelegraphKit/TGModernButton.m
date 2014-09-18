/*
 * This is the source code of Telegram for iOS v. 1.1
 * It is licensed under GNU GPL v. 2 or later.
 * You should have received a copy of the license in this archive (see LICENSE).
 *
 * Copyright Peter Iakovlev, 2013.
 */

#import "TGModernButton.h"

@interface TGModernButton ()
{
    bool _animateHighlight;
    
    UIColor *_titleColor;
    
    UIImageView *_highlightImageView;
}

@end

@implementation TGModernButton

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
    {
        _modernHighlight = true;
    }
    return self;
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    _animateHighlight = true;
    [super touchesMoved:touches withEvent:event];
    _animateHighlight = false;
}

- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event
{
    _animateHighlight = true;
    [super touchesCancelled:touches withEvent:event];
    _animateHighlight = false;
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    _animateHighlight = true;
    [super touchesEnded:touches withEvent:event];
    _animateHighlight = false;
}

- (void)setHighlightImage:(UIImage *)highlightImage
{
    _highlightImage = highlightImage;
    
    if (_highlightImage != nil && _highlightImageView == nil)
    {
        _highlightImageView = [[UIImageView alloc] init];
        _highlightImageView.alpha = 0.0f;
        [self addSubview:_highlightImageView];
    }
    
    _highlightImageView.image = _highlightImage;
    if (_stretchHighlightImage)
        _highlightImageView.frame = self.bounds;
    else
    {
        _highlightImageView.frame = CGRectMake(CGFloor((self.bounds.size.width - _highlightImage.size.width) / 2.0f), CGFloor((self.bounds.size.height - _highlightImage.size.height) / 2.0f), _highlightImage.size.width, _highlightImage.size.height);
    }
}

- (void)setFrame:(CGRect)frame
{
    [super setFrame:frame];
    
    if (_highlightImageView != nil)
    {
        if (_stretchHighlightImage)
            _highlightImageView.frame = self.bounds;
        else
        {
            _highlightImageView.frame = CGRectMake(CGFloor((frame.size.width - _highlightImage.size.width) / 2.0f), CGFloor((frame.size.height - _highlightImage.size.height) / 2.0f), _highlightImage.size.width, _highlightImage.size.height);
        }
    }
}

- (void)setHighlighted:(BOOL)highlighted
{
    [super setHighlighted:highlighted];
    
    if (_modernHighlight)
    {
        if (_highlightImage != nil)
        {
            CGFloat alpha = (highlighted ? 1.0f : 0.0f);
            
            if (ABS(alpha - _highlightImageView.alpha) > FLT_EPSILON)
            {
                if (_animateHighlight)
                {
                    [UIView animateWithDuration:0.2 animations:^
                    {
                        _highlightImageView.alpha = alpha;
                    }];
                }
                else
                    _highlightImageView.alpha = alpha;
            }
        }
        else
        {
            CGFloat alpha = (highlighted ? 0.4f : 1.0f) * (self.enabled ? 1.0f : 0.5f);
            
            if (ABS(alpha - self.alpha) > FLT_EPSILON)
            {
                if (_animateHighlight)
                {
                    [UIView animateWithDuration:0.2 animations:^
                    {
                        self.alpha = alpha;
                    }];
                }
                else
                    self.alpha = alpha;
            }
        }
    }
}

- (void)setTitleColor:(UIColor *)color
{
    _titleColor = color;
    
    if (iosMajorVersion() >= 7)
        [self setTintColor:color];
    else
        [self setTitleColor:color forState:UIControlStateNormal];
    
    if (_modernHighlight && _highlightImage == nil)
    {
        CGFloat alpha = (self.highlighted ? 0.4f : 1.0f) * (self.enabled ? 1.0f : 0.5f);
        self.alpha = alpha;
    }
}

- (void)setEnabled:(BOOL)enabled
{
    [super setEnabled:enabled];
    
    if (_modernHighlight && _highlightImage == nil)
    {
        CGFloat alpha = (self.highlighted ? 0.4f : 1.0f) * (self.enabled ? 1.0f : 0.5f);
        self.alpha = alpha;
    }
}

- (void)tintColorDidChange
{
    [super tintColorDidChange];
    
    if (_modernHighlight && _highlightImage == nil)
        [self setTitleColor:self.tintColor forState:UIControlStateNormal];
}

@end
