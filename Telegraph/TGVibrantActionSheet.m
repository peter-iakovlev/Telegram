#import "TGVibrantActionSheet.h"

#import "TGModernButton.h"
#import "TGFont.h"
#import "TGImageUtils.h"
#import "TGViewController.h"

@interface TGVibrantActionSheetAction ()

@property (nonatomic, strong) NSString *title;
@property (nonatomic, strong) NSString *action;

@end

@implementation TGVibrantActionSheetAction

- (instancetype)initWithTitle:(NSString *)title action:(NSString *)action
{
    self = [super init];
    if (self != nil)
    {
        _title = title;
        _action = action;
    }
    return self;
}

@end

@interface TGVibrantActionSheet ()
{
    NSArray *_actions;
    NSArray *_buttons;
    void (^_actionActivated)(NSString *);
 
    UILabel *_titleView;
    UIView *_firstGroupView;
    UIView *_secondGroupView;
    UIView *_buttonSeparatorView;
}

@end

@implementation TGVibrantActionSheet

- (instancetype)initWithTitle:(NSString *)title actions:(NSArray *)actions actionActivated:(void (^)(NSString *action))actionActivated
{
    self = [super init];
    if (self != nil)
    {
        self.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        
        _titleView = [[UILabel alloc] init];
        _titleView.text = title;
        _titleView.font = TGSystemFontOfSize(15.0f);
        _titleView.numberOfLines = 0;
        _titleView.textAlignment = NSTextAlignmentCenter;
        _titleView.textColor = [UIColor whiteColor];
        _titleView.backgroundColor = [UIColor clearColor];
        _titleView.lineBreakMode = NSLineBreakByWordWrapping;
        
        _actionActivated = [actionActivated copy];
        
        _firstGroupView = [[UIImageView alloc] initWithImage:[self buttonFrameImage]];
        [self addSubview:_firstGroupView];
        _secondGroupView = [[UIImageView alloc] initWithImage:[self buttonFrameImage]];
        [self addSubview:_secondGroupView];
        _buttonSeparatorView = [[UIView alloc] init];
        _buttonSeparatorView.backgroundColor = UIColorRGBA(0xffffff, 0.3f);
        [self addSubview:_buttonSeparatorView];
        
        [self _setActions:actions];
    }
    return self;
}

- (void)showInView:(UIView *)view
{
    self.frame = CGRectOffset(view.bounds, 0.0f, [self contentHeight]);
    [view addSubview:self];
    
    [UIView animateWithDuration:0.2 delay:0.0 options:[TGViewController preferredAnimationCurve] << 16 animations:^
    {
        self.frame = view.bounds;
    } completion:nil];
}

- (void)dismissAnimated:(bool)animated
{
    if (animated)
    {
        [UIView animateWithDuration:0.3 delay:0.0 options:[TGViewController preferredAnimationCurve] << 16 animations:^
        {
            self.frame = CGRectOffset(self.superview.bounds, 0.0f, [self contentHeight]);
        } completion:^(__unused BOOL finished)
        {
            [self removeFromSuperview];
        }];
    }
    else
    {
        [self removeFromSuperview];
    }
}

- (UIImage *)buttonFrameImage
{
    static UIImage *image = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^
    {
        CGFloat radius = 4.0f;
        UIGraphicsBeginImageContextWithOptions(CGSizeMake(radius * 2.0f, radius * 2.0f), false, 0.0f);
        CGContextRef context = UIGraphicsGetCurrentContext();
        
        CGContextSetStrokeColorWithColor(context, UIColorRGBA(0xffffff, 0.6f).CGColor);
        CGContextSetLineWidth(context, 1.0f);
        CGContextStrokeEllipseInRect(context, CGRectMake(0.5f, 0.5f, radius * 2.0f - 1.0f, radius * 2.0f - 1.0f));
        
        image = [UIGraphicsGetImageFromCurrentImageContext() stretchableImageWithLeftCapWidth:(NSInteger)radius topCapHeight:(NSInteger)radius];
        UIGraphicsEndImageContext();
    });
    return image;
}

- (UIImage *)buttonTopHighlightImage
{
    static UIImage *image = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^
    {
        CGFloat radius = 4.0f;
        UIGraphicsBeginImageContextWithOptions(CGSizeMake(radius * 2.0f, radius * 2.0f), false, 0.0f);
        CGContextRef context = UIGraphicsGetCurrentContext();
        
        CGContextSetBlendMode(context, kCGBlendModeCopy);
        
        CGContextSetFillColorWithColor(context, UIColorRGBA(0xffffff, 0.4f).CGColor);
        CGContextSetLineWidth(context, 1.0f);
        CGContextFillEllipseInRect(context, CGRectMake(0.5f + 0.5f, 0.5f + 0.5f, radius * 2.0f - 1.0f - 1.0f, radius * 2.0f - 1.0f - 1.0f));
        CGContextFillRect(context, CGRectMake(1.0f, 1.0f + radius, radius * 2.0f - 2.0f, radius - 1.0f));
        
        image = [UIGraphicsGetImageFromCurrentImageContext() stretchableImageWithLeftCapWidth:(NSInteger)radius topCapHeight:(NSUInteger)radius];
        UIGraphicsEndImageContext();
    });
    return image;
}

- (UIImage *)buttonBottomHighlightImage
{
    static UIImage *image = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^
    {
        CGFloat radius = 4.0f;
        UIGraphicsBeginImageContextWithOptions(CGSizeMake(radius * 2.0f, radius * 2.0f), false, 0.0f);
        CGContextRef context = UIGraphicsGetCurrentContext();
        
        CGContextSetBlendMode(context, kCGBlendModeCopy);
        
        CGContextSetFillColorWithColor(context, UIColorRGBA(0xffffff, 0.4f).CGColor);
        CGContextSetLineWidth(context, 1.0f);
        CGContextFillEllipseInRect(context, CGRectMake(0.5f + 0.5f, 0.5f + 0.5f, radius * 2.0f - 1.0f - 1.0f, radius * 2.0f - 1.0f - 1.0f));
        CGContextFillRect(context, CGRectMake(1.0f, 0.0f, radius * 2.0f - 2.0f, radius));
        
        image = [UIGraphicsGetImageFromCurrentImageContext() stretchableImageWithLeftCapWidth:(NSInteger)radius topCapHeight:(NSUInteger)radius];
        UIGraphicsEndImageContext();
    });
    return image;
}

- (UIImage *)buttonSingleHighlightImage
{
    static UIImage *image = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^
    {
        CGFloat radius = 4.0f;
        UIGraphicsBeginImageContextWithOptions(CGSizeMake(radius * 2.0f, radius * 2.0f), false, 0.0f);
        CGContextRef context = UIGraphicsGetCurrentContext();
        
        CGContextSetFillColorWithColor(context, UIColorRGBA(0xffffff, 0.4f).CGColor);
        CGContextSetLineWidth(context, 1.0f);
        CGContextFillEllipseInRect(context, CGRectMake(0.5f + 0.5f, 0.5f + 0.5f, radius * 2.0f - 1.0f - 1.0f, radius * 2.0f - 1.0f - 1.0f));
        
        image = [UIGraphicsGetImageFromCurrentImageContext() stretchableImageWithLeftCapWidth:(NSInteger)radius topCapHeight:(NSUInteger)radius];
        UIGraphicsEndImageContext();
    });
    return image;
}

- (void)_setActions:(NSArray *)actions
{
    for (TGModernButton *button in _buttons)
    {
        [button removeTarget:self action:@selector(buttonPressed:) forControlEvents:UIControlEventTouchUpInside];
        [button removeFromSuperview];
    }
    
    _actions = actions;
    NSMutableArray *newButtons = [[NSMutableArray alloc] init];
    for (NSUInteger i = 0; i < _actions.count; i++)
    {
        TGModernButton *button = [[TGModernButton alloc] init];
        [button setTitle:((TGVibrantActionSheetAction *)_actions[i]).title forState:UIControlStateNormal];
        [button setTitleColor:[UIColor whiteColor]];
        button.titleLabel.font = TGMediumSystemFontOfSize(17.0f);
        button.stretchHighlightImage = true;
        if (i == 0)
            button.highlightImage = [self buttonTopHighlightImage];
        else if (i == 1)
            button.highlightImage = [self buttonBottomHighlightImage];
        else
            button.highlightImage = [self buttonSingleHighlightImage];
        [button addTarget:self action:@selector(buttonPressed:) forControlEvents:UIControlEventTouchUpInside];
        [newButtons addObject:button];
        [self addSubview:button];
    }
    _buttons = newButtons;
    
    [self setNeedsLayout];
}

- (CGFloat)contentHeight
{
    return 10.0f + 10.0f + _buttons.count * 44.0f + 16.0f;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    CGFloat bottomInset = 10.0f;
    CGFloat sideInset = 8.0f;
    CGFloat buttonHeight = 44.0f;
    CGFloat groupSpacing = 16.0f;
    CGFloat separatorHeight = TGIsRetina() ? 0.5f : 1.0f;
    
    CGFloat currentOffset = self.frame.size.height - bottomInset;
    
    NSInteger firstGroupCount = 1;
    NSInteger secondGroupCount = _buttons.count - firstGroupCount;
    
    for (NSInteger i = ((NSInteger)_buttons.count) - 1; i >= 0; i--)
    {
        TGModernButton *button = _buttons[i];
        button.frame = CGRectMake(sideInset, currentOffset - buttonHeight, self.frame.size.width - sideInset * 2.0f, buttonHeight);
        currentOffset -= buttonHeight;
        
        if (i == 0)
        {
            _buttonSeparatorView.frame = CGRectMake(sideInset + 1.0f, CGRectGetMaxY(button.frame), self.frame.size.width - sideInset* 2.0f - 2.0f, separatorHeight);
        }
        
        if (i == secondGroupCount)
            currentOffset -= groupSpacing;
    }
    
    CGFloat firstGroupY = ((TGModernButton *)_buttons[_buttons.count - firstGroupCount]).frame.origin.y;
    CGRect firstGroupFrame = CGRectMake(sideInset, firstGroupY, self.frame.size.width - sideInset * 2.0f, CGRectGetMaxY(((TGModernButton *)_buttons[_buttons.count - 1]).frame) - firstGroupY);
    _firstGroupView.frame = firstGroupFrame;
    
    CGFloat secondGroupY = ((TGModernButton *)_buttons[0]).frame.origin.y;
    CGRect secondGroupFrame = CGRectMake(sideInset, secondGroupY, self.frame.size.width - sideInset * 2.0f, CGRectGetMaxY(((TGModernButton *)_buttons[secondGroupCount - 1]).frame) - secondGroupY);
    _secondGroupView.frame = secondGroupFrame;
}

- (void)buttonPressed:(TGModernButton *)button
{
    NSUInteger index = [_buttons indexOfObject:button];
    if (index != NSNotFound)
    {
        if (_actionActivated != nil)
            _actionActivated(((TGVibrantActionSheetAction *)_actions[index]).action);
    }
    
    [self dismissAnimated:true];
}

@end
