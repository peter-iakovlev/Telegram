#import "TGCommandKeyboardView.h"

#import "TGFont.h"
#import "TGImageUtils.h"

#import "TGBotComandInfo.h"

#import "TGBotReplyMarkup.h"

#import "TGViewController.h"

@interface TGCommandKeyboardScrollView : UIScrollView

@end

@implementation TGCommandKeyboardScrollView

- (BOOL)touchesShouldCancelInContentView:(UIView *)__unused view
{
    return true;
}

@end

@interface TGCommandKeyboardView ()
{
    UIView *_topSeparatorView;
    TGBotReplyMarkup *_replyMarkup;
    NSMutableArray *_buttons;
    
    TGCommandKeyboardScrollView *_scrollView;
    
    UIView *_backgroundView;
}

@end

@implementation TGCommandKeyboardView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self != nil)
    {   
        _buttons = [[NSMutableArray alloc] init];
        
        _backgroundView = [[UIView alloc] init];
        _backgroundView.backgroundColor = UIColorRGB(0xdee2e6);
        [self addSubview:_backgroundView];
        
        _scrollView = [[TGCommandKeyboardScrollView alloc] init];
        _scrollView.delaysContentTouches = false;
        _scrollView.canCancelContentTouches = true;
        [self addSubview:_scrollView];
        
        _topSeparatorView = [[UIView alloc] init];
        _topSeparatorView.backgroundColor = UIColorRGB(0xe0e0e0);
        [self addSubview:_topSeparatorView];
    }
    return self;
}

+ (UIImage *)buttonImage
{
    static UIImage *image = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^
    {
        CGFloat radius = 5.0f;
        CGFloat shadowSize = 1.0f;
        UIGraphicsBeginImageContextWithOptions(CGSizeMake(radius * 2.0f, radius * 2.0f + shadowSize), false, 0.0f);
        CGContextRef context = UIGraphicsGetCurrentContext();
        CGContextSetFillColorWithColor(context, UIColorRGB(0xc3c7c9).CGColor);
        CGContextFillEllipseInRect(context, CGRectMake(0.0f, shadowSize, radius * 2.0f, radius * 2.0f));
        CGContextSetFillColorWithColor(context, [UIColor whiteColor].CGColor);
        CGContextFillEllipseInRect(context, CGRectMake(0.0f, 0.0f, radius * 2.0f, radius * 2.0f));
        image = [UIGraphicsGetImageFromCurrentImageContext() stretchableImageWithLeftCapWidth:(NSInteger)radius topCapHeight:(NSInteger)radius];
        UIGraphicsEndImageContext();
    });
    return image;
}

+ (UIImage *)buttonHighlightedImage
{
    static UIImage *image = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^
    {
        CGFloat radius = 5.0f;
        CGFloat shadowSize = 1.0f;
        UIGraphicsBeginImageContextWithOptions(CGSizeMake(radius * 2.0f, radius * 2.0f + shadowSize), false, 0.0f);
        CGContextRef context = UIGraphicsGetCurrentContext();
        CGContextSetFillColorWithColor(context, UIColorRGB(0xc3c7c9).CGColor);
        CGContextFillEllipseInRect(context, CGRectMake(0.0f, shadowSize, radius * 2.0f, radius * 2.0f));
        CGContextSetFillColorWithColor(context, UIColorRGB(0xa8b3c0).CGColor);
        CGContextFillEllipseInRect(context, CGRectMake(0.0f, 0.0f, radius * 2.0f, radius * 2.0f));
        image = [UIGraphicsGetImageFromCurrentImageContext() stretchableImageWithLeftCapWidth:(NSInteger)radius topCapHeight:(NSInteger)radius];
        UIGraphicsEndImageContext();
    });
    return image;
}

- (void)setReplyMarkup:(TGBotReplyMarkup *)replyMarkup
{
    for (UIButton *button in _buttons)
    {
        [button removeFromSuperview];
    }
    [_buttons removeAllObjects];
    
    _replyMarkup = replyMarkup;
    
    for (TGBotReplyMarkupRow *row in _replyMarkup.rows)
    {
        for (TGBotReplyMarkupButton *button in row.buttons)
        {
            [self addButton:button.text];
        }
    }
    
    [self setNeedsLayout];
}

- (void)animateTransitionIn
{
    _backgroundView.alpha = 0.0f;
    [UIView animateWithDuration:0.2 animations:^
    {
        _backgroundView.alpha = 1.0f;
    }];
}

- (UIButton *)addButton:(NSString *)title
{
    UIButton *button = [[UIButton alloc] init];
    [button setBackgroundImage:[TGCommandKeyboardView buttonImage] forState:UIControlStateNormal];
    [button setBackgroundImage:[TGCommandKeyboardView buttonHighlightedImage] forState:UIControlStateHighlighted];
    [button setTitle:title forState:UIControlStateNormal];
    [button setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    button.titleLabel.font = TGSystemFontOfSize(16.0f);
    [button addTarget:self action:@selector(buttonPressed:) forControlEvents:UIControlEventTouchUpInside];
    [button setTitleEdgeInsets:UIEdgeInsetsMake(0.0f, 6.0f, 0.0f, 6.0f)];
    button.exclusiveTouch = true;
    [_scrollView addSubview:button];
    [_buttons addObject:button];
    
    return button;
}

- (void)buttonPressed:(UIButton *)button
{
    NSUInteger i = 0;
    NSUInteger index = NSNotFound;
    for (UIButton *listButton in _buttons)
    {
        if (listButton == button)
        {
            index = i;
            break;
        }
        i++;
    }
    
    if (index != NSNotFound)
    {
        i = 0;
        bool found = false;
        for (TGBotReplyMarkupRow *row in _replyMarkup.rows)
        {
            for (TGBotReplyMarkupButton *button in row.buttons)
            {
                if (i == index)
                {
                    if (_commandActivated)
                        _commandActivated(button, _replyMarkup.userId, _replyMarkup.messageId);
                    found = true;
                    break;
                }
                i++;
            }
            if (found)
                break;
        }
    }
}

- (UIEdgeInsets)insets
{
    return UIEdgeInsetsMake(10.0f, 6.0f, 10.0f, 6.0f);
}

- (CGSize)buttonSize
{
    return CGSizeMake(151.0f, 43.0f);
}

- (CGFloat)rowSpacing
{
    return 5.0f;
}

- (CGFloat)columnSpacing
{
    return 6.0f;
}

- (CGSize)sizeThatFits:(CGSize)size
{
    CGSize contentSize = CGSizeZero;
    contentSize.width = size.width;
    UIEdgeInsets insets = [self insets];
    CGSize buttonSize = [self buttonSize];
    CGFloat rowSpacing = [self rowSpacing];
    
    contentSize.height += insets.top + insets.bottom;
    
    contentSize.height += _replyMarkup.rows.count * buttonSize.height + MAX((int)_replyMarkup.rows.count - 1, 0) * rowSpacing;
    
    return CGSizeMake(contentSize.width, MIN(190.0f, contentSize.height));
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    CGSize bounds = self.bounds.size;
    
    _backgroundView.frame = CGRectMake(0.0f, 0.0f, bounds.width, bounds.height + 210.0f);
    
    _topSeparatorView.frame = CGRectMake(0.0f, 0.0f, bounds.width, TGScreenPixel);
    
    _scrollView.frame = CGRectMake(0.0f, 0.0f, bounds.width, bounds.height);
    
    CGSize contentSize = CGSizeZero;
    contentSize.width = bounds.width;
    UIEdgeInsets insets = [self insets];
    CGSize buttonSize = [self buttonSize];
    
    CGFloat rowSpacing = [self rowSpacing];
    CGFloat columnSpacing = [self columnSpacing];
    
    contentSize.height = insets.top + insets.bottom + _replyMarkup.rows.count * buttonSize.height + MAX((int)_replyMarkup.rows.count - 1, 0) * rowSpacing;
    
    if (contentSize.height < self.frame.size.height)
    {
        CGFloat spacingHeight = 0.0f;
        CGFloat availableHeight = self.frame.size.height - contentSize.height - spacingHeight;
        buttonSize.height += CGFloor(availableHeight / _replyMarkup.rows.count);
        
        contentSize.height = insets.top + insets.bottom + _replyMarkup.rows.count * buttonSize.height + MAX((int)_replyMarkup.rows.count - 1, 0) * rowSpacing;
    }
    
    _scrollView.contentSize = contentSize;
    
    NSInteger buttonIndex = 0;
    NSInteger rowIndex = 0;
    for (TGBotReplyMarkupRow *row in _replyMarkup.rows)
    {
        NSInteger columnCount = row.buttons.count;
        buttonSize.width = CGFloor(((bounds.width - insets.left - insets.right) + columnSpacing - columnCount * columnSpacing) / columnCount);
        
        CGFloat topEdge = insets.top + rowIndex * (buttonSize.height + rowSpacing);
        NSInteger columnIndex = 0;
        for (__unused TGBotReplyMarkupButton *button in row.buttons)
        {
            CGFloat leftEdge = insets.left + columnIndex * (buttonSize.width + columnSpacing);
            
            UIButton *buttonView = _buttons[buttonIndex];
            buttonView.frame = CGRectMake(leftEdge, topEdge, buttonSize.width, buttonSize.height);
            
            buttonIndex++;
            columnIndex++;
        }
        rowIndex++;
    }
}

- (bool)isExpanded
{
    return false;
}

- (void)setExpanded:(bool)__unused expanded
{
    
}

- (CGFloat)preferredHeight:(bool)landscape
{
    if (!self.matchDefaultHeight)
    {
        CGFloat height = [self sizeThatFits:CGSizeZero].height;
        return height;
    }
    
    if (TGIsPad())
        return landscape ? 398.0f : 313.0f;
    
    if ([TGViewController hasVeryLargeScreen])
        return landscape ? 194.0f : 271.0f;
    else if ([TGViewController hasLargeScreen])
        return landscape ? 194.0f : 258.0f;
    else if ([TGViewController isWidescreen])
        return landscape ? 193.0f : 253.0f;
    
    return landscape ? 193.0f : 253.0f;
}

- (bool)isInteracting
{
    return false;
}

@end
