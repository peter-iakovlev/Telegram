#import "TGModernConversationGenericTitlePanel.h"

#import "TGImageUtils.h"
#import "TGFont.h"

#import "TGBackdropView.h"
#import "TGViewController.h"

#import "TGModernButton.h"

#import "ASHandle.h"

@interface TGModernConversationGenericTitleButton : TGModernButton

- (instancetype)initWithTitle:(NSString *)title icon:(UIImage *)icon;

@end


@interface TGModernConversationGenericTitlePanel ()
{
    CALayer *_stripeLayer;
    
    NSArray *_buttons;
    NSArray *_buttonActions;
    
    UIView *_backgroundView;
}

@end

@implementation TGModernConversationGenericTitlePanel

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:CGRectMake(frame.origin.x, frame.origin.y, frame.size.width, MAX(36.0f, frame.size.height))];
    if (self)
    {
        if (!TGBackdropEnabled())
        {
            _backgroundView = [TGBackdropView viewWithLightNavigationBarStyle];
            [self addSubview:_backgroundView];
        }
        else
        {
            UIToolbar *toolbar = [[UIToolbar alloc] init];
            _backgroundView = toolbar;
            [self addSubview:_backgroundView];
        }
        
        _stripeLayer = [[CALayer alloc] init];
        _stripeLayer.backgroundColor = UIColorRGB(0xb2b2b2).CGColor;
        [self.layer addSublayer:_stripeLayer];
    }
    return self;
}

- (void)setButtonsWithTitlesAndActions:(NSArray *)buttonsDesc
{
    for (TGModernButton *button in _buttons)
    {
        [button removeTarget:self action:@selector(buttonPressed:) forControlEvents:UIControlEventTouchUpInside];
        [button removeFromSuperview];
    }
    
    NSMutableArray *buttons = [[NSMutableArray alloc] init];
    NSMutableArray *buttonActions = [[NSMutableArray alloc] init];
    
    for (NSDictionary *desc in buttonsDesc)
    {
        TGModernConversationGenericTitleButton *button = [[TGModernConversationGenericTitleButton alloc] initWithTitle:desc[@"title"] icon:desc[@"icon"]];
        [button addTarget:self action:@selector(buttonPressed:) forControlEvents:UIControlEventTouchUpInside];
        [buttons addObject:button];
        [buttonActions addObject:desc[@"action"] == nil ? @"" : desc[@"action"]];
        [self addSubview:button];
    }
    
    _buttons = buttons;
    _buttonActions = buttonActions;
    
    [self setNeedsLayout];
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    _backgroundView.frame = self.bounds;
    
    _stripeLayer.frame = CGRectMake(0.0f, self.frame.size.height - TGScreenPixel, self.frame.size.width, TGScreenPixel);
    
    if (_buttons.count != 0)
    {
        CGSize buttonSize = CGSizeMake(76.0f, 54.0f);
        CGFloat spacing = (self.frame.size.width - buttonSize.width * _buttons.count) / (_buttons.count + 1);
        CGFloat sideSpacing = floor(spacing * 0.8f);
        spacing = floor((self.frame.size.width - sideSpacing * 2.0f - buttonSize.width * _buttons.count) / (_buttons.count - 1));
        
        int index = -1;
        for (UIView *view in _buttons)
        {
            index++;
            view.frame = CGRectMake(sideSpacing + index * (buttonSize.width + spacing), 0.0f, buttonSize.width, buttonSize.height);
        }
    }
}

- (void)buttonPressed:(id)button
{
    int index = -1;
    for (id view in _buttons)
    {
        index++;
        
        if (view == button)
        {
            [_companionHandle requestAction:@"titlePanelAction" options:@{@"action": _buttonActions[index]}];
            
            break;
        }
    }
}

- (void)tintColorDidChange
{
    [super tintColorDidChange];
}

@end


@implementation TGModernConversationGenericTitleButton

- (instancetype)initWithTitle:(NSString *)title icon:(UIImage *)icon
{
    self = [super initWithFrame:CGRectMake(0, 0, 76.0f, 54.0f)];
    if (self != nil)
    {
        self.adjustsImageWhenHighlighted = false;
        [self setTitle:title forState:UIControlStateNormal];
        [self setImage:icon forState:UIControlStateNormal];
        self.imageView.contentMode = UIViewContentModeCenter;
        self.titleLabel.font = TGSystemFontOfSize(10.0f);
        self.titleLabel.textAlignment = NSTextAlignmentCenter;
        [self setTitleColor:TGAccentColor()];
    }
    return self;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    CGRect frame = self.imageView.frame;
    frame.origin.x = floor((self.frame.size.width - frame.size.width) / 2.0f) + TGScreenPixel;
    frame.origin.y -= 8.0f;
    self.imageView.frame = frame;
    
    frame = self.titleLabel.frame;
    frame = CGRectMake(0, self.bounds.size.height - ceil(frame.size.height) - 5.0f, self.bounds.size.width, ceil(frame.size.height));
    self.titleLabel.frame = frame;
}

@end
