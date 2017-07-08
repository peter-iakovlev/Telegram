#import "TGShareToolbarView.h"

#import <LegacyDatabase/LegacyDatabase.h>

#import "TGShareToolbarButton.h"

@interface TGShareToolbarView ()
{
    UIView *_wrapperView;
    TGShareButton *_leftButton;
    TGShareButton *_rightButton;
    
    UIView *_buttonsWrapperView;
    
    TGShareToolbarTab _currentTabs;
}
@end

@implementation TGShareToolbarView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self != nil)
    {
        self.backgroundColor = [UIColor clearColor];
     
        _wrapperView = [[UIView alloc] initWithFrame:self.bounds];
        _wrapperView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        _wrapperView.backgroundColor = TGColorWithHex(0xf7f7f7);
        [self addSubview:_wrapperView];
        
        CGFloat separatorHeight = 1.0f / [[UIScreen mainScreen] scale];
        UIView *stripeView = [[UIView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, self.frame.size.width, separatorHeight)];
        stripeView.backgroundColor = TGColorWithHex(0xb2b2b2);
        stripeView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        [_wrapperView addSubview:stripeView];
        
        _buttonsWrapperView = [[UIView alloc] initWithFrame:self.bounds];
        _buttonsWrapperView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        [_wrapperView addSubview:_buttonsWrapperView];
        
        _leftButton = [[TGShareButton alloc] initWithFrame:CGRectMake(0, 0, 60, 44)];
        _leftButton.exclusiveTouch = true;
        [_leftButton setTitle:NSLocalizedString(@"Share.Cancel", nil) forState:UIControlStateNormal];
        [_leftButton setTitleColor:TGColorWithHex(0x007ee5)];
        _leftButton.titleLabel.font = [UIFont systemFontOfSize:17];
        _leftButton.contentEdgeInsets = UIEdgeInsetsMake(0, 10, 0, 0);
        [_leftButton sizeToFit];
        _leftButton.frame = CGRectMake(0, 0, MAX(60, _leftButton.frame.size.width), 44);
        _leftButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
        [_leftButton addTarget:self action:@selector(leftButtonPressed) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:_leftButton];
        
        _rightButton = [[TGShareButton alloc] initWithFrame:CGRectMake(0, 0, 40, 44)];
        _rightButton.exclusiveTouch = true;
        [_rightButton setTitle:NSLocalizedString(@"Share.Done", nil) forState:UIControlStateNormal];
        [_rightButton setTitleColor:TGColorWithHex(0x007ee5)];
        _rightButton.titleLabel.font = [UIFont systemFontOfSize:17 weight:UIFontWeightMedium];
        _rightButton.contentEdgeInsets = UIEdgeInsetsMake(0, 27, 0, 10);
        [_rightButton sizeToFit];
        
        CGFloat doneButtonWidth = MAX(40, _rightButton.frame.size.width);
        _rightButton.frame = CGRectMake(self.frame.size.width - doneButtonWidth, 0, doneButtonWidth, 44);
        _rightButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentRight;
        [_rightButton addTarget:self action:@selector(rightButtonPressed) forControlEvents:UIControlEventTouchUpInside];
        _rightButton.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin;
        [_wrapperView addSubview:_rightButton];
    }
    return self;
}

- (void)leftButtonPressed
{
    if (self.leftPressed != nil)
        self.leftPressed();
}

- (void)rightButtonPressed
{
    if (self.rightPressed != nil)
        self.rightPressed();
}

- (void)setHidden:(bool)hidden animated:(bool)animated
{
    self.userInteractionEnabled = !hidden;
    
    void (^changeBlock)(void) = ^
    {
        if (hidden)
            _wrapperView.frame = CGRectMake(0, _wrapperView.frame.size.height, _wrapperView.frame.size.width, _wrapperView.frame.size.height);
        else
            _wrapperView.frame = CGRectMake(0, 0, _wrapperView.frame.size.width, _wrapperView.frame.size.height);
    };
    
    void (^completionBlock)(BOOL) = ^(BOOL finished)
    {
        _wrapperView.hidden = hidden;
    };
    
    if (animated)
    {
        if (!hidden)
            _wrapperView.hidden = false;
        UIViewAnimationOptions options = hidden ? UIViewAnimationOptionCurveEaseInOut : (7 << 16);
        [UIView animateWithDuration:0.3 delay:0.0 options:options animations:changeBlock completion:completionBlock];
    }
    else
    {
        changeBlock();
        completionBlock(true);
    }
}

#pragma mark -

- (void)_setTitle:(NSString *)title forButton:(TGShareButton *)button
{
    NSString *currentTitle = [button titleForState:UIControlStateNormal];
    
    if ([currentTitle isEqualToString:title])
        return;
    
    button.userInteractionEnabled = (title.length > 0);
    
    if (currentTitle.length == 0 && title.length > 0)
    {
        button.alpha = 0.0f;
        [button setTitle:title forState:UIControlStateNormal];
        
        [UIView animateWithDuration:0.15 animations:^
        {
            button.alpha = 1.0f;
        }];
    }
    else if (currentTitle.length > 0 && title.length == 0)
    {
        [UIView animateWithDuration:0.15 animations:^
        {
            button.alpha = 0.0f;
        } completion:^(BOOL finished)
        {
            if (finished)
                [button setTitle:title forState:UIControlStateNormal];
        }];
    }
    else
    {
        [button setTitle:title forState:UIControlStateNormal];
    }
}

- (NSString *)leftButtonTitle
{
    return [_leftButton titleForState:UIControlStateNormal];
}

- (void)setLeftButtonTitle:(NSString *)title
{
    [self _setTitle:title forButton:_leftButton];
}

- (NSString *)rightButtonTitle
{
    return [_rightButton titleForState:UIControlStateNormal];
}

- (void)setRightButtonTitle:(NSString *)title
{
    [self _setTitle:title forButton:_rightButton];
}

- (void)setRightButtonHidden:(bool)hidden
{
    _rightButton.hidden = hidden;
}

- (void)setRightButtonEnabled:(bool)enabled animated:(bool)__unused animated
{
    _rightButton.enabled = enabled;
}

- (void)setToolbarTabs:(TGShareToolbarTab)tabs animated:(bool)animated
{
    if (tabs == _currentTabs)
        return;
    
    UIView *transitionView = nil;
    if (_currentTabs != TGShareToolbarTabNone)
    {
        transitionView = [_buttonsWrapperView snapshotViewAfterScreenUpdates:false];
        transitionView.frame = _buttonsWrapperView.frame;
        [_buttonsWrapperView.superview addSubview:transitionView];
    }
    
    _currentTabs = tabs;
    
    NSArray *buttons = [_buttonsWrapperView.subviews copy];
    for (UIView *view in buttons)
        [view removeFromSuperview];
    
    if (_currentTabs & TGShareToolbarTabCaption)
        [_buttonsWrapperView addSubview:[TGShareToolbarView buttonForTab:TGShareToolbarTabCaption]];
    if (_currentTabs & TGShareToolbarTabCrop)
        [_buttonsWrapperView addSubview:[TGShareToolbarView buttonForTab:TGShareToolbarTabCrop]];
    if (_currentTabs & TGShareToolbarTabAdjustments)
        [_buttonsWrapperView addSubview:[TGShareToolbarView buttonForTab:TGShareToolbarTabAdjustments]];
    if (_currentTabs & TGShareToolbarTabRotate)
        [_buttonsWrapperView addSubview:[TGShareToolbarView buttonForTab:TGShareToolbarTabRotate]];
    
    [self setNeedsLayout];
        
    _buttonsWrapperView.alpha = 0.0f;
    [UIView animateWithDuration:0.15 animations:^
    {
        _buttonsWrapperView.alpha = 1.0f;
        transitionView.alpha = 0.0f;
    } completion:^(BOOL finished)
    {
        [transitionView removeFromSuperview];
    }];
}

#pragma mark - 

+ (TGShareToolbarButton *)buttonForTab:(TGShareToolbarTab)tab
{
    TGShareToolbarButton *button = [[TGShareToolbarButton alloc] initWithFrame:CGRectMake(0, 0, 28, 28)];
    button.tag = tab;
    
    switch (tab)
    {
        case TGShareToolbarTabCaption:
            button.iconImage = [UIImage imageNamed:@"PhotoEditorCaption"];
            break;
            
        case TGShareToolbarTabCrop:
            button.iconImage = [UIImage imageNamed:@"PhotoEditorCrop"];
            break;
            
        case TGShareToolbarTabAdjustments:
            button.iconImage = [UIImage imageNamed:@"PhotoEditorTools"];
            break;
            
        case TGShareToolbarTabRotate:
            button.iconImage = [UIImage imageNamed:@"PhotoEdtorRotate"];
            break;
            
        default:
            button = nil;
            break;
    }
    
    return button;
}

#pragma mark -

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    NSArray *buttons = _buttonsWrapperView.subviews;
    
    if (buttons.count == 1)
    {
        UIView *button = buttons.firstObject;
        button.frame = CGRectMake(floor(self.frame.size.width / 2 - button.frame.size.width / 2), (self.frame.size.height - button.frame.size.height) / 2, button.frame.size.width, button.frame.size.height);
    }
    else if (buttons.count == 2)
    {
        UIView *leftButton = buttons.firstObject;
        UIView *rightButton = buttons.lastObject;
        
        leftButton.frame = CGRectMake(floor(self.frame.size.width / 5 * 2 - 5 - leftButton.frame.size.width / 2), (self.frame.size.height - leftButton.frame.size.height) / 2, leftButton.frame.size.width, leftButton.frame.size.height);
        rightButton.frame = CGRectMake(floor(self.frame.size.width - leftButton.frame.origin.x - rightButton.frame.size.width), (self.frame.size.height - rightButton.frame.size.height) / 2, rightButton.frame.size.width, rightButton.frame.size.height);
    }
    else if (buttons.count == 3)
    {
        UIView *leftButton = buttons.firstObject;
        UIView *centerButton = [buttons objectAtIndex:1];
        UIView *rightButton = buttons.lastObject;
        
        centerButton.frame = CGRectMake(floor(self.frame.size.width / 2 - centerButton.frame.size.width / 2), (self.frame.size.height - centerButton.frame.size.height) / 2, centerButton.frame.size.width, centerButton.frame.size.height);
        
        leftButton.frame = CGRectMake(floor(self.frame.size.width / 6 * 2 - 5 - leftButton.frame.size.width / 2), (self.frame.size.height - leftButton.frame.size.height) / 2, leftButton.frame.size.width, leftButton.frame.size.height);
        
        rightButton.frame = CGRectMake(floor(self.frame.size.width - leftButton.frame.origin.x - rightButton.frame.size.width), (self.frame.size.height - rightButton.frame.size.height) / 2, rightButton.frame.size.width, rightButton.frame.size.height);
    }
}

@end
