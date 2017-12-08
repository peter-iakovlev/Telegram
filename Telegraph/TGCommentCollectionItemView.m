#import "TGCommentCollectionItemView.h"

#import <LegacyComponents/LegacyComponents.h>

#import "TGPresentation.h"

@interface TGCommentCollectionItemView ()
{
    UILabel *_label;
    UIActivityIndicatorView *_activityIndicator;
    
    UIColor *_customTextColor;
}

@end

@implementation TGCommentCollectionItemView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
    {
        _label = [[UILabel alloc] init];
        _label.backgroundColor = [UIColor clearColor];
        _label.numberOfLines = 0;
        [self addSubview:_label];
        
        [_label addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapGesture:)]];
    }
    return self;
}

- (void)setPresentation:(TGPresentation *)presentation
{
    [super setPresentation:presentation];
    
    if (_customTextColor == nil)
        _label.textColor = presentation.pallete.collectionMenuCommentColor;
}

- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event
{
    if (CGRectContainsPoint(_label.frame, point))
        return _label;
    
    return [super hitTest:point withEvent:event];
}

- (void)tapGesture:(UITapGestureRecognizer *)recognizer
{
    if (recognizer.state == UIGestureRecognizerStateRecognized)
    {
        if (_action)
            _action();
    }
}

- (void)setTextColor:(UIColor *)textColor
{
    _customTextColor = textColor;
    _label.textColor = textColor ?: self.presentation.pallete.collectionMenuCommentColor;
}

- (void)setLabelAlpha:(CGFloat)labelAlpha
{
    _labelAlpha = labelAlpha;
    _label.alpha = labelAlpha;
    _activityIndicator.alpha = labelAlpha;
}

- (void)setAttributedText:(NSAttributedString *)text
{
    _label.attributedText = text;
    [self setNeedsLayout];
}

- (void)setTopInset:(CGFloat)topInset
{
    _topInset = topInset;
    [self setNeedsLayout];
}

- (void)setCalculatedSize:(CGSize)calculatedSize
{
    _calculatedSize = calculatedSize;
    [self setNeedsLayout];
}

- (void)setShowProgress:(bool)showProgress
{
    _showProgress = showProgress;
    
    if (_showProgress && _activityIndicator == nil)
    {
        _activityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
        _activityIndicator.hidden = true;
        _activityIndicator.alpha = _label.alpha;
        [self addSubview:_activityIndicator];
        [self setNeedsLayout];
    }
    
    if (_showProgress)
    {
        _activityIndicator.hidden = false;
        [_activityIndicator startAnimating];
    }
    else
    {
        _activityIndicator.hidden = true;
        [_activityIndicator stopAnimating];
    }
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    _label.frame = CGRectMake(15.0f + self.safeAreaInset.left, 7.0f + _topInset, self.bounds.size.width - 30.0f - self.safeAreaInset.left - self.safeAreaInset.right, _calculatedSize.height - 7.0f - 7.0f);
    _activityIndicator.frame = CGRectMake(15.0f + self.safeAreaInset.left, 14.0f, _activityIndicator.frame.size.width, _activityIndicator.frame.size.height);
}

@end
