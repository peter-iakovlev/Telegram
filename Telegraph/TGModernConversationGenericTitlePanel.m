#import "TGModernConversationGenericTitlePanel.h"

#import "TGImageUtils.h"
#import "TGFont.h"

#import "TGBackdropView.h"
#import "TGViewController.h"

#import "TGModernButton.h"

#import "ASHandle.h"

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
        TGModernButton *button = [[TGModernButton alloc] init];
        button.adjustsImageWhenDisabled = false;
        button.adjustsImageWhenHighlighted = false;
        button.titleLabel.font = TGSystemFontOfSize(17.0f);
        [button setTitle:desc[@"title"] forState:UIControlStateNormal];
        [button setTitleColor:TGAccentColor()];
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
    
    _stripeLayer.frame = CGRectMake(0.0f, self.frame.size.height - TGRetinaPixel, self.frame.size.width, TGRetinaPixel);
    
    if (_buttons.count != 0)
    {
        CGSize buttonSize = CGSizeMake(CGFloor(self.frame.size.width / _buttons.count), self.frame.size.height);
        
        int index = -1;
        for (UIView *view in _buttons)
        {
            index++;
            view.frame = CGRectMake(index * buttonSize.width, 0.0f, buttonSize.width, buttonSize.height);
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
