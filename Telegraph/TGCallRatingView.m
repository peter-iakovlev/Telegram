#import "TGCallRatingView.h"

#import "TGShareCommentView.h"

@interface TGCallRatingView ()
{
    UIView *_starsView;
    TGShareCommentView *_commentView;
    CGFloat _textHeight;
    UIPanGestureRecognizer *_gestureRecognizer;
}
@end

@implementation TGCallRatingView

- (instancetype)init
{
    self = [super initWithFrame:CGRectMake(0.0f, 0.0f, 246.0f, 38.0f)];
    if (self != nil)
    {
        _starsView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 246.0f, 38.0f)];
        [self addSubview:_starsView];
        
        for (NSInteger i = 0; i < 5; i++)
        {
            UIButton *starButton = [[UIButton alloc] initWithFrame:CGRectMake(18 + 42.0f * i, 0, 42.0f, 38.0f)];
            starButton.tag = i;
            starButton.adjustsImageWhenDisabled = false;
            starButton.adjustsImageWhenHighlighted = false;
            starButton.contentMode = UIViewContentModeCenter;
            [starButton setImage:[UIImage imageNamed:@"CallStar"] forState:UIControlStateNormal];
            [starButton setImage:[UIImage imageNamed:@"CallStar_Highlighted"] forState:UIControlStateSelected];
            [starButton setImage:[UIImage imageNamed:@"CallStar_Highlighted"] forState:UIControlStateSelected | UIControlStateHighlighted];
            [starButton addTarget:self action:@selector(starPressed:) forControlEvents:UIControlEventTouchUpInside];
            [_starsView addSubview:starButton];
        }
        
        _gestureRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePan:)];
        [_starsView addGestureRecognizer:_gestureRecognizer];
        
        __weak TGCallRatingView *weakSelf = self;
        _commentView = [[TGShareCommentView alloc] initWithFrame:CGRectZero];
        _commentView.alpha = 0.0f;
        _commentView.userInteractionEnabled = false;
        _commentView.placeholder = TGLocalized(@"Calls.RatingFeedback");
        _commentView.heightChanged = ^(CGFloat height)
        {
            __strong TGCallRatingView *strongSelf = weakSelf;
            if (strongSelf == nil)
                return;
            
            strongSelf->_textHeight = height;
            [strongSelf updateHeight:true];
        };
        [self addSubview:_commentView];
    }
    return self;
}

- (void)handlePan:(UIPanGestureRecognizer *)gestureRecognizer
{
    if (gestureRecognizer.state == UIGestureRecognizerStateChanged)
    {
        CGPoint location = [gestureRecognizer locationInView:gestureRecognizer.view];
        location.x = MAX(0.0f, MIN(gestureRecognizer.view.frame.size.width, location.x));
        location.y = 0;
        for (UIButton *view in _starsView.subviews)
        {
            if ([view pointInside:[gestureRecognizer.view convertPoint:location toView:view] withEvent:nil])
                [self starPressed:view];
        }
    }
}

- (NSString *)comment
{
    return _commentView.text;
}

- (void)starPressed:(UIButton *)sender
{
    NSInteger previousStars = _selectedStars;
    _selectedStars = sender.tag + 1;
    
    for (UIButton *button in _starsView.subviews)
    {
        button.selected = button.tag < _selectedStars;
    }
    
    if (self.onStarsSelected != nil)
        self.onStarsSelected();
    
    if (_selectedStars < 5)
    {
        _commentView.userInteractionEnabled = true;
        [UIView animateWithDuration:0.15 delay:0.05 options:UIViewAnimationOptionCurveLinear animations:^
        {
            _commentView.alpha = 1.0f;
        } completion:nil];
    }
    else
    {
        [_commentView.textView resignFirstResponder];
        _commentView.userInteractionEnabled = false;
        [UIView animateWithDuration:0.15 animations:^
        {
            _commentView.alpha = 0.0f;
        }];
    }
    
    if (_selectedStars > 0 && _selectedStars < 4)
        _commentView.placeholder = TGLocalized(@"Call.ReportPlaceholder");
    else
        _commentView.placeholder = TGLocalized(@"Calls.RatingFeedback");
    
    if ((previousStars < 5 && _selectedStars == 5) || (_selectedStars < 5 && (previousStars == 5 || previousStars == 0)))
        [self updateHeight:true];
}

- (void)updateHeight:(bool)animated
{
    CGFloat height = 38.0f;
    if (_commentView.userInteractionEnabled)
        height += _textHeight + 9.0f;
 
    void (^changeBlock)(void) = ^
    {
        if (self.onHeightChanged != nil)
            self.onHeightChanged(height);
    };
    
    if (animated)
    {
        UIViewAnimationOptions options = UIViewAnimationOptionAllowAnimatedContent | UIViewAnimationOptionAllowUserInteraction | UIViewAnimationOptionLayoutSubviews;
        if (iosMajorVersion() >= 7)
            options = options | (7 << 16);
        
        [UIView animateWithDuration:0.3 delay:0.0 options:options animations:changeBlock completion:nil];
    }
    else
    {
        changeBlock();
    }
}

- (void)layoutSubviews
{
    _commentView.frame = CGRectMake(0.0f, 55.0f, self.frame.size.width, _commentView.frame.size.height);
}

@end
