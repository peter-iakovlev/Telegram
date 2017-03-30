#import "TGSharedMediaMenuView.h"

#import "TGFont.h"
#import "TGImageUtils.h"
#import "TGModernButton.h"

#import "TGViewController.h"

@interface TGSharedMediaMenuView ()
{
    UIView *_backgroundView;
    UIView *_dimView;
    NSArray *_buttons;
    NSArray *_separatorViews;
    UIImageView *_highlightedItemCheckView;
}

@end

@implementation TGSharedMediaMenuView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self != nil)
    {
        _dimView = [[UIView alloc] init];
        _dimView.backgroundColor = UIColorRGBA(0x000000, 0.4f);
        [_dimView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dimViewTapGesture:)]];
        [self addSubview:_dimView];
        
        _backgroundView = [[UIView alloc] init];
        _backgroundView.backgroundColor = UIColorRGB(0xfafafa);
        [self addSubview:_backgroundView];
        
        _highlightedItemCheckView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"ModernMenuCheck.png"]];
        [_backgroundView addSubview:_highlightedItemCheckView];
        
        _dimView.hidden = true;
        _backgroundView.hidden = true;
    }
    return self;
}

- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event
{
    if (_dimView.hidden)
        return nil;
    
    return [super hitTest:point withEvent:event];
}

- (void)dimViewTapGesture:(UITapGestureRecognizer *)recognizer
{
    if (recognizer.state == UIGestureRecognizerStateEnded)
    {
        [self hideAnimated:true];
    }
}

- (void)setItems:(NSArray *)items
{
    for (UIView *view in _buttons)
    {
        [view removeFromSuperview];
    }
    
    for (UIView *view in _separatorViews)
    {
        [view removeFromSuperview];
    }
    
    _buttons = nil;
    _separatorViews = nil;
    
    NSMutableArray *buttons = [[NSMutableArray alloc] init];
    NSMutableArray *separatorViews = [[NSMutableArray alloc] init];
    
    for (__unused NSString *item in items)
    {
        UIView *separatorView = [[UIView alloc] init];
        separatorView.backgroundColor = TGSeparatorColor();
        [_backgroundView addSubview:separatorView];
        [separatorViews addObject:separatorView];
    }
    
    CGFloat separatorHeight = TGScreenPixel;
    
    for (NSString *item in items)
    {
        TGModernButton *button = [[TGModernButton alloc] init];
        button.titleLabel.font = TGSystemFontOfSize(17.0f);
        [button setTitle:item forState:UIControlStateNormal];
        button.contentEdgeInsets = UIEdgeInsetsMake(0.0f, 16.0f, 0.0f, 0.0f);
        button.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;

        button.backgroundSelectionInsets = UIEdgeInsetsMake(separatorHeight, 0.0f, 0.0f, 0.0f);
        button.highlightBackgroundColor = TGSelectionColor();
        button.highlighted = false;
        [button addTarget:self action:@selector(buttonPressed:) forControlEvents:UIControlEventTouchUpInside];
        
        [buttons addObject:button];
        [_backgroundView addSubview:button];
    }
    
    _buttons = buttons;
    _separatorViews = separatorViews;
    
    [_backgroundView bringSubviewToFront:_highlightedItemCheckView];
    
    [self updateItemHighlights];
    
    [self setNeedsLayout];
}

- (void)showAnimated:(bool)animated
{
    if (animated)
    {
        _backgroundView.hidden = false;
        _dimView.hidden = false;
        _dimView.alpha = 0.0f;
        _backgroundView.frame = CGRectMake(0.0f, -_backgroundView.frame.size.height, _backgroundView.frame.size.width, _backgroundView.frame.size.height);
        [UIView animateWithDuration:0.18 delay:0.0 options:[TGViewController preferredAnimationCurve] << 16 | UIViewAnimationOptionAllowUserInteraction animations:^
        {
            _dimView.alpha = 1.0f;
            _backgroundView.frame = CGRectMake(0.0f, 0.0f, _backgroundView.frame.size.width, _backgroundView.frame.size.height);
        } completion:nil];
    }
    else
    {
        _backgroundView.hidden = false;
        _dimView.hidden = false;
        _dimView.alpha = 1.0f;
        _backgroundView.frame = CGRectMake(0.0f, 0.0f, _backgroundView.frame.size.width, _backgroundView.frame.size.height);
    }
}

- (void)hideAnimated:(bool)animated
{
    if (_willHide)
        _willHide();
    
    if (animated)
    {
        [UIView animateWithDuration:0.17 delay:0.0 options:0 animations:^
        {
            _dimView.alpha = 0.0f;
            _backgroundView.frame = CGRectMake(0.0f, -_backgroundView.frame.size.height, _backgroundView.frame.size.width, _backgroundView.frame.size.height);
        } completion:^(BOOL finished)
        {
            if (finished)
            {
                _dimView.alpha = 1.0f;
                _backgroundView.frame = CGRectMake(0.0f, 0.0f, _backgroundView.frame.size.width, _backgroundView.frame.size.height);
                
                _backgroundView.hidden = true;
                _dimView.hidden = true;
            }
        }];
    }
    else
    {
        _backgroundView.hidden = true;
        _dimView.hidden = true;
    }
}

- (void)buttonPressed:(UIButton *)button
{
    NSUInteger index = 0;
    for (UIButton *listButton in _buttons)
    {
        if (listButton == button)
        {
            if (index != _selectedItemIndex)
            {
                [self setSelectedItemIndex:index];
                if (_selectedItemIndexChanged)
                    _selectedItemIndexChanged(_selectedItemIndex);
            }
            break;
        }
        index++;
    }
    
    [self hideAnimated:true];
}

- (void)setSelectedItemIndex:(NSUInteger)selectedItemIndex
{
    _selectedItemIndex = selectedItemIndex;
    [self updateItemHighlights];
}

- (void)updateItemHighlights
{
    NSUInteger index = 0;
    for (UIButton *button in _buttons)
    {
        if (index == _selectedItemIndex)
        {
            [button setTitleColor:TGAccentColor() forState:UIControlStateNormal];
        }
        else
            [button setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        index++;
    }
    
    [self setNeedsLayout];
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    _dimView.frame = self.bounds;
    
    CGFloat contentHeight = 0.0f;
    
    CGFloat separatorHeight = TGScreenPixel;
    
    NSUInteger index = 0;
    for (UIButton *button in _buttons)
    {
        button.frame = CGRectMake(-separatorHeight, contentHeight, self.frame.size.width, 44.0f + separatorHeight);
        if (index == _selectedItemIndex)
        {
            CGSize checkSize = _highlightedItemCheckView.frame.size;
            _highlightedItemCheckView.frame = CGRectMake(self.frame.size.width - 15.0f - checkSize.width, contentHeight + 16.0f, checkSize.width, checkSize.height);
        }
        contentHeight += 44.0f;
        index++;
    }
    
    CGFloat separatorOffset = -separatorHeight;
    for (UIView *separatorView in _separatorViews)
    {
        separatorView.frame = CGRectMake(15.0f, separatorOffset, self.frame.size.width - 15.0f, separatorHeight);
        separatorOffset += 44.0f;
    }
    
    _backgroundView.frame = CGRectMake(_backgroundView.frame.origin.x, _backgroundView.frame.origin.y, self.frame.size.width, contentHeight);
}

@end
