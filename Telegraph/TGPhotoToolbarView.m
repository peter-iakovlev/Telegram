#import "TGPhotoToolbarView.h"

#import "TGModernButtonView.h"
#import "TGPhotoEditorButton.h"

@interface TGPhotoToolbarView ()
{
    UIView *_backgroundView;
    
    UIView *_buttonsWrapperView;
    TGModernButton *_cancelButton;
    TGModernButton *_doneButton;

    NSArray *_buttons;
    
    CGFloat _landscapeSize;
}
@end

@implementation TGPhotoToolbarView

- (instancetype)initWithBackButtonTitle:(NSString *)backButtonTitle doneButtonTitle:(NSString *)doneButtonTitle accentedDone:(bool)accentedDone solidBackground:(bool)solidBackground tabs:(NSArray *)tabs
{
    self = [super initWithFrame:CGRectZero];
    if (self != nil)
    {
        self.clipsToBounds = true;
        
        _backgroundView = [[UIView alloc] initWithFrame:CGRectZero];
        _backgroundView.backgroundColor = (solidBackground ? [TGPhotoEditorInterfaceAssets toolbarBackgroundColor] : [TGPhotoEditorInterfaceAssets toolbarTransparentBackgroundColor]);
        [self addSubview:_backgroundView];
        
        _buttonsWrapperView = [[UIView alloc] initWithFrame:_backgroundView.bounds];
        [_backgroundView addSubview:_buttonsWrapperView];
        
        _cancelButton = [[TGModernButton alloc] initWithFrame:CGRectMake(0, 0, 60, 44)];
        _cancelButton.exclusiveTouch = true;
        [_cancelButton setTitle:backButtonTitle forState:UIControlStateNormal];
        [_cancelButton setTitleColor:[UIColor whiteColor]];
        _cancelButton.titleLabel.font = TGSystemFontOfSize(17);
        _cancelButton.contentEdgeInsets = UIEdgeInsetsMake(0, 10, 0, 0);
        [_cancelButton sizeToFit];
        _cancelButton.frame = CGRectMake(0, 0.5f, MAX(60.0f, _cancelButton.frame.size.width), 44);
        _cancelButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
        [_cancelButton addTarget:self action:@selector(cancelButtonPressed) forControlEvents:UIControlEventTouchUpInside];
        [_backgroundView addSubview:_cancelButton];
        
        _doneButton = [[TGModernButton alloc] initWithFrame:CGRectMake(0, 0, 40, 44)];
        _doneButton.exclusiveTouch = true;
        [_doneButton setTitle:doneButtonTitle forState:UIControlStateNormal];
        [_doneButton setTitleColor:(accentedDone ? [TGPhotoEditorInterfaceAssets accentColor] : [UIColor whiteColor])];
        _doneButton.titleLabel.font = TGMediumSystemFontOfSize(17);
        _doneButton.contentEdgeInsets = UIEdgeInsetsMake(0, 27, 0, 10);
        [_doneButton sizeToFit];
        CGFloat doneButtonWidth = MAX(40, _doneButton.frame.size.width);
        _doneButton.frame = CGRectMake(self.frame.size.width - doneButtonWidth, 0.5f, doneButtonWidth, 44);
        _doneButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentRight;
        [_doneButton addTarget:self action:@selector(doneButtonPressed) forControlEvents:UIControlEventTouchUpInside];
        [_backgroundView addSubview:_doneButton];
        
        NSMutableArray *buttons = [[NSMutableArray alloc] init];
        for (NSNumber *editorTab in tabs)
        {
            TGPhotoEditorButton *button = [TGPhotoToolbarView buttonForEditorTab:(int)editorTab.integerValue];
            if (button == nil)
                continue;
            
            [button addTarget:self action:@selector(tabButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
            
            [buttons addObject:button];
            [_buttonsWrapperView addSubview:button];
        }
        _buttons = buttons;
    }
    return self;
}

+ (TGPhotoEditorButton *)buttonForEditorTab:(TGPhotoEditorTab)editorTab
{
    TGPhotoEditorButton *button = [[TGPhotoEditorButton alloc] initWithFrame:CGRectMake(0, 0, 28, 28)];
    button.tag = editorTab;
    
    switch (editorTab)
    {
        case TGPhotoEditorCaptionTab:
            button.iconImage = [TGPhotoEditorInterfaceAssets captionIcon];
            button.dontHighlightOnSelection = true;
            break;

        case TGPhotoEditorCropTab:
            button.iconImage = [TGPhotoEditorInterfaceAssets cropIcon];
            break;

        case TGPhotoEditorToolsTab:
            button.iconImage = [TGPhotoEditorInterfaceAssets toolsIcon];
            break;

        case TGPhotoEditorRotateTab:
            button.iconImage = [TGPhotoEditorInterfaceAssets rotateIcon];
            button.dontHighlightOnSelection = true;
            break;
            
        default:
            button = nil;
            break;
    }
    
    return button;
}

- (CGRect)cancelButtonFrame
{
    return _cancelButton.frame;
}

- (void)cancelButtonPressed
{
    if (self.cancelPressed != nil)
        self.cancelPressed();
}

- (void)doneButtonPressed
{
    if (self.donePressed != nil)
        self.donePressed();
}

- (void)tabButtonPressed:(TGPhotoEditorButton *)sender
{
    if (self.tabPressed != nil)
        self.tabPressed((int)sender.tag);
}

- (void)setActiveTab:(TGPhotoEditorTab)tab
{
    for (TGPhotoEditorButton *button in _buttons)
        [button setSelected:(button.tag == tab) animated:false];
}

- (void)setDoneButtonEnabled:(bool)enabled animated:(bool)animated
{
    _doneButton.userInteractionEnabled = enabled;
    
    if (animated)
    {
        [UIView animateWithDuration:0.2f delay:0.0f options:UIViewAnimationOptionBeginFromCurrentState animations:^
         {
             _doneButton.alpha = enabled ? 1.0f : 0.2f;
         } completion:nil];
    }
    else
    {
        _doneButton.alpha = enabled ? 1.0f : 0.2f;
    }
}

- (void)setEditButtonsEnabled:(bool)enabled animated:(bool)animated
{
    _buttonsWrapperView.userInteractionEnabled = enabled;
    
    if (animated)
    {
        [UIView animateWithDuration:0.2f delay:0.0f options:UIViewAnimationOptionBeginFromCurrentState animations:^
        {
            _buttonsWrapperView.alpha = enabled ? 1.0f : 0.2f;
        } completion:nil];
    }
    else
    {
        _buttonsWrapperView.alpha = enabled ? 1.0f : 0.2f;
    }
}

- (void)setEditButtonsHidden:(bool)hidden animated:(bool)animated
{
    CGFloat targetAlpha = hidden ? 0.0f : 1.0f;
    
    if (animated)
    {
        for (TGPhotoEditorButton *button in _buttons)
            button.hidden = false;
        
        [UIView animateWithDuration:0.2f
                         animations:^
        {
            for (TGPhotoEditorButton *button in _buttons)
                button.alpha = (float)targetAlpha;
        } completion:^(__unused BOOL finished)
        {
            for (TGPhotoEditorButton *button in _buttons)
                button.hidden = hidden;
        }];
    }
    else
    {
        for (TGPhotoEditorButton *button in _buttons)
        {
            button.alpha = (float)targetAlpha;
            button.hidden = hidden;
        }
    }
}

- (void)setEditButtonsHighlighted:(NSInteger)buttons
{
    for (TGPhotoEditorButton *button in _buttons)
        button.active = (buttons & button.tag);
}

- (void)setTab:(TGPhotoEditorTab)tab hidden:(bool)hidden
{
    TGPhotoEditorButton *tabButton = nil;
    for (TGPhotoEditorButton *button in _buttons)
    {
        if (button.tag == tab)
        {
            tabButton = button;
            break;
        }
    }
    
    if (tabButton == nil)
        return;
         
    if (hidden)
    {
        if (tabButton.superclass != nil)
            [tabButton removeFromSuperview];
    }
    else
    {
        if (tabButton.superview == nil)
            [_buttonsWrapperView addSubview:tabButton];
    }
}

- (void)layoutSubviews
{
    _backgroundView.frame = self.bounds;
    _buttonsWrapperView.frame = _backgroundView.bounds;
    
    NSArray *buttons = _buttons;
    
    if (self.frame.size.width > self.frame.size.height)
    {
        if (buttons.count == 1)
        {
            UIView *button = buttons.firstObject;
            button.frame = CGRectMake(CGFloor(self.frame.size.width / 2 - button.frame.size.width / 2), (self.frame.size.height - button.frame.size.height) / 2, button.frame.size.width, button.frame.size.height);
        }
        else if (buttons.count == 2)
        {
            UIView *leftButton = buttons.firstObject;
            UIView *rightButton = buttons.lastObject;
            
            leftButton.frame = CGRectMake(CGFloor(self.frame.size.width / 5 * 2 - 5 - leftButton.frame.size.width / 2), (self.frame.size.height - leftButton.frame.size.height) / 2, leftButton.frame.size.width, leftButton.frame.size.height);
            rightButton.frame = CGRectMake(CGCeil(self.frame.size.width - leftButton.frame.origin.x - rightButton.frame.size.width), (self.frame.size.height - rightButton.frame.size.height) / 2, rightButton.frame.size.width, rightButton.frame.size.height);
        }
        else if (buttons.count == 3)
        {
            UIView *leftButton = buttons.firstObject;
            UIView *centerButton = [buttons objectAtIndex:1];
            UIView *rightButton = buttons.lastObject;
            
            centerButton.frame = CGRectMake(CGFloor(self.frame.size.width / 2 - centerButton.frame.size.width / 2), (self.frame.size.height - centerButton.frame.size.height) / 2, centerButton.frame.size.width, centerButton.frame.size.height);

            leftButton.frame = CGRectMake(CGFloor(self.frame.size.width / 6 * 2 - 5 - leftButton.frame.size.width / 2), (self.frame.size.height - leftButton.frame.size.height) / 2, leftButton.frame.size.width, leftButton.frame.size.height);
            
            rightButton.frame = CGRectMake(CGCeil(self.frame.size.width - leftButton.frame.origin.x - rightButton.frame.size.width), (self.frame.size.height - rightButton.frame.size.height) / 2, rightButton.frame.size.width, rightButton.frame.size.height);
        }
    
        _cancelButton.titleLabel.font = TGSystemFontOfSize(17);
        _cancelButton.contentEdgeInsets = UIEdgeInsetsMake(0, 10, 0, 0);
        [_cancelButton sizeToFit];
        _cancelButton.frame = CGRectMake(0, 0, MAX(60.0f, CGCeil(_cancelButton.frame.size.width)), 44);
        _cancelButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
        
        _doneButton.titleLabel.font = TGMediumSystemFontOfSize(17);
        _doneButton.contentEdgeInsets = UIEdgeInsetsMake(0, 27, 0, 10);
        [_doneButton sizeToFit];
        CGFloat doneButtonWidth = MAX(40, CGCeil(_doneButton.frame.size.width));
        _doneButton.frame = CGRectMake(self.frame.size.width - doneButtonWidth, 0, doneButtonWidth, 44);
        _doneButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentRight;
    }
    else
    {
        if (buttons.count == 1)
        {
            UIView *button = buttons.firstObject;
            button.frame = CGRectMake((self.frame.size.width - button.frame.size.width) / 2, CGFloor((self.frame.size.height - button.frame.size.height) / 2), button.frame.size.width, button.frame.size.height);
        }
        else if (buttons.count == 2)
        {
            UIView *topButton = buttons.firstObject;
            UIView *bottomButton = buttons.lastObject;
            
            topButton.frame = CGRectMake((self.frame.size.width - topButton.frame.size.width) / 2, CGFloor(self.frame.size.height / 5 * 2 - 10 - topButton.frame.size.height / 2), topButton.frame.size.width, topButton.frame.size.height);
            bottomButton.frame = CGRectMake((self.frame.size.width - bottomButton.frame.size.width) / 2, CGCeil(self.frame.size.height - topButton.frame.origin.y - bottomButton.frame.size.height), bottomButton.frame.size.width, bottomButton.frame.size.height);
        }
        else if (buttons.count == 3)
        {
            UIView *topButton = buttons.firstObject;
            UIView *centerButton = [buttons objectAtIndex:1];
            UIView *bottomButton = buttons.lastObject;
            
            topButton.frame = CGRectMake((self.frame.size.width - topButton.frame.size.width) / 2, CGFloor(self.frame.size.height / 6 * 2 - 10 - topButton.frame.size.height / 2), topButton.frame.size.width, topButton.frame.size.height);
            centerButton.frame = CGRectMake((self.frame.size.width - centerButton.frame.size.width) / 2, CGFloor((self.frame.size.height - centerButton.frame.size.height) / 2), centerButton.frame.size.width, centerButton.frame.size.height);
            bottomButton.frame = CGRectMake((self.frame.size.width - bottomButton.frame.size.width) / 2, CGCeil(self.frame.size.height - topButton.frame.origin.y - bottomButton.frame.size.height), bottomButton.frame.size.width, bottomButton.frame.size.height);
        }
    
        _cancelButton.titleLabel.font = TGSystemFontOfSize(13);
        _cancelButton.contentEdgeInsets = UIEdgeInsetsMake(0, 0, 0, 0);
        [_cancelButton sizeToFit];
        _cancelButton.frame = CGRectMake(0, self.frame.size.height - 44, self.frame.size.width, 44);
        _cancelButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentCenter;
        
        _doneButton.titleLabel.font = TGMediumSystemFontOfSize(13);
        _doneButton.contentEdgeInsets = UIEdgeInsetsMake(0, 0, 0, 0);
        [_doneButton sizeToFit];
        _doneButton.frame = CGRectMake(0, 0, self.frame.size.width, 44);
        _doneButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentCenter;
    }
}

- (void)transitionInAnimated:(bool)animated
{
    [self transitionInAnimated:animated transparent:false];
}

- (void)transitionInAnimated:(bool)animated transparent:(bool)transparent
{
    self.backgroundColor = transparent ? [UIColor clearColor] : [UIColor blackColor];
    
    void (^animationBlock)(void) = ^
    {
        if (self.frame.size.width > self.frame.size.height)
        {
            _backgroundView.frame = CGRectMake(_backgroundView.frame.origin.x,
                                               0,
                                               _backgroundView.frame.size.width,
                                               _backgroundView.frame.size.height);
        }
        else
        {
            _backgroundView.frame = CGRectMake(0,
                                               _backgroundView.frame.origin.y,
                                               _backgroundView.frame.size.width,
                                               _backgroundView.frame.size.height);
        }
    };
    
    void (^completionBlock)(BOOL) = ^(BOOL finished)
    {
        if (finished)
            self.backgroundColor = [UIColor clearColor];
    };
    
    if (animated)
    {
        if (self.frame.size.width > self.frame.size.height)
        {
            _backgroundView.frame = CGRectMake(_backgroundView.frame.origin.x,
                                               _backgroundView.frame.size.height,
                                               _backgroundView.frame.size.width,
                                               _backgroundView.frame.size.height);
        }
        else
        {
            if (_interfaceOrientation == UIInterfaceOrientationLandscapeLeft)
            {
                _backgroundView.frame = CGRectMake(-_backgroundView.frame.size.width,
                                                   _backgroundView.frame.origin.y,
                                                   _backgroundView.frame.size.width,
                                                   _backgroundView.frame.size.height);
            }
            else
            {
                _backgroundView.frame = CGRectMake(_backgroundView.frame.size.width,
                                                   _backgroundView.frame.origin.y,
                                                   _backgroundView.frame.size.width,
                                                   _backgroundView.frame.size.height);
            }
        }
        
        if (iosMajorVersion() >= 7)
            [UIView animateWithDuration:0.4f delay:0.0f usingSpringWithDamping:1.0f initialSpringVelocity:0.0f options:UIViewAnimationOptionCurveLinear animations:animationBlock completion:completionBlock];
        else
            [UIView animateWithDuration:0.3f delay:0.0f options:UIViewAnimationOptionAllowUserInteraction animations:animationBlock completion:completionBlock];
    }
    else
    {
        animationBlock();
        completionBlock(true);
    }
}

- (void)transitionOutAnimated:(bool)animated
{
    [self transitionOutAnimated:animated transparent:false hideOnCompletion:false];
}

- (void)transitionOutAnimated:(bool)animated transparent:(bool)transparent hideOnCompletion:(bool)hideOnCompletion
{
    void (^animationBlock)(void) = ^
    {
        if (self.frame.size.width > self.frame.size.height)
        {
            _backgroundView.frame = CGRectMake(_backgroundView.frame.origin.x,
                                               _backgroundView.frame.size.height,
                                               _backgroundView.frame.size.width,
                                               _backgroundView.frame.size.height);
        }
        else
        {
            if (_interfaceOrientation == UIInterfaceOrientationLandscapeLeft)
            {
                _backgroundView.frame = CGRectMake(-_backgroundView.frame.size.width,
                                                   _backgroundView.frame.origin.y,
                                                   _backgroundView.frame.size.width,
                                                   _backgroundView.frame.size.height);
            }
            else
            {
                _backgroundView.frame = CGRectMake(_backgroundView.frame.size.width,
                                                   _backgroundView.frame.origin.y,
                                                   _backgroundView.frame.size.width,
                                                   _backgroundView.frame.size.height);
            }
        }
    };
    
    void (^completionBlock)(BOOL) = ^(__unused BOOL finished)
    {
        if (hideOnCompletion)
            self.hidden = true;
    };
    
    self.backgroundColor = transparent ? [UIColor clearColor] : [UIColor blackColor];
    
    if (animated)
    {
        if (iosMajorVersion() >= 7)
            [UIView animateWithDuration:0.4f delay:0.0f usingSpringWithDamping:1.0f initialSpringVelocity:0.0f options:UIViewAnimationOptionCurveLinear animations:animationBlock completion:completionBlock];
        else
            [UIView animateWithDuration:0.3f delay:0.0f options:UIViewAnimationOptionAllowUserInteraction animations:animationBlock completion:completionBlock];
    }
    else
    {
        animationBlock();
        completionBlock(true);
    }
}

- (void)calculateLandscapeSizeForPossibleButtonTitles:(NSArray *)possibleButtonTitles
{
    CGFloat maxWidth = 0.0f;
    
    for (NSString *title in possibleButtonTitles)
    {
        CGFloat width = 0.0f;
        if ([title respondsToSelector:@selector(sizeWithAttributes:)])
            width = CGCeil([title sizeWithAttributes:@{ NSFontAttributeName:TGSystemFontOfSize(17) }].width - 1);
        else
            width = CGCeil([title sizeWithFont:TGSystemFontOfSize(17)].width - 1);
        
        if (width > maxWidth)
            maxWidth = width;
    }
    
    _landscapeSize = maxWidth;
}

- (CGFloat)landscapeSize
{
    if (_landscapeSize < FLT_EPSILON)
    {
        [self calculateLandscapeSizeForPossibleButtonTitles:@[ [_cancelButton titleForState:UIControlStateNormal], [_doneButton titleForState:UIControlStateNormal] ]];
    }
         
    return _landscapeSize;
}

@end
