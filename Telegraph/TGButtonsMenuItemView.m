#import "TGButtonsMenuItemView.h"

#import "TGHighlightableButton.h"

@interface TGButtonsMenuItemView ()

@property (nonatomic, strong) TGHighlightableButton *leftButton;
@property (nonatomic, strong) TGHighlightableButton *rightButton;

@end

@implementation TGButtonsMenuItemView

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self)
    {
        self.backgroundColor = nil;
        self.opaque = false;
        
        _leftButton = [self createButtonWithTitle:@""];
        [_leftButton addTarget:self action:@selector(buttonPressed:) forControlEvents:UIControlEventTouchUpInside];
        
        _rightButton = [self createButtonWithTitle:@""];
        [_rightButton addTarget:self action:@selector(buttonPressed:) forControlEvents:UIControlEventTouchUpInside];
        
        [self.contentView addSubview:_leftButton];
        [self.contentView addSubview:_rightButton];
    }
    return self;
}

- (void)dealloc
{
    [_leftButton removeTarget:self action:@selector(buttonPressed:) forControlEvents:UIControlEventTouchUpInside];
    [_rightButton removeTarget:self action:@selector(buttonPressed:) forControlEvents:UIControlEventTouchUpInside];
}

- (void)setButtons:(NSArray *)buttons
{
    if ((buttons != nil) == (_buttons != nil) && _buttons.count == buttons.count)
    {
        bool foundDifference = false;
        
        int count = (int)buttons.count;
        for (int i = 0; i < count; i++)
        {
            NSDictionary *dict1 = [_buttons objectAtIndex:i];
            NSDictionary *dict2 = [buttons objectAtIndex:i];
            
            NSString *title1 = [dict1 objectForKey:@"title"];
            NSString *title2 = [dict2 objectForKey:@"title"];
            
            if ((title1 != nil) != (title2 != nil) || (title1 != nil && ![title1 isEqualToString:title2]))
            {
                foundDifference = true;
                break;
            }
            
            if ([[dict1 objectForKey:@"disabled"] boolValue] != [[dict2 objectForKey:@"disabled"] boolValue])
            {
                foundDifference = true;
                break;
            }
        }
        
        if (!foundDifference)
            return;
    }
    
    _buttons = buttons;
    
    int visibleButtons = 0;
    for (NSDictionary *button in _buttons)
    {
        visibleButtons++;
        
        UIButton *buttonView = visibleButtons == 1 ? _leftButton : _rightButton;
        
        [buttonView setTitle:[button objectForKey:@"title"] forState:UIControlStateNormal];
        bool disabled = [[button objectForKey:@"disabled"] boolValue];
        buttonView.alpha = disabled ? 0.7f : 1.0f;
        buttonView.enabled = !disabled;
        
        if ([[button objectForKey:@"green"] boolValue])
        {
            UIImage *rawButtonImage = [UIImage imageNamed:@"GroupedActionButtonGreen.png"];
            UIImage *rawButtonHighlightedImage = [UIImage imageNamed:@"GroupedActionButtonGreen_Highlighted.png"];
            
            UIImage *buttonImage = [rawButtonImage stretchableImageWithLeftCapWidth:(int)(rawButtonImage.size.width / 2) topCapHeight:0];
            UIImage *buttonHighightedImage = [rawButtonHighlightedImage stretchableImageWithLeftCapWidth:(int)(rawButtonHighlightedImage.size.width / 2) topCapHeight:0];
            
            [buttonView setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
            [buttonView setTitleShadowColor:[UIColor whiteColor] forState:UIControlStateNormal];
            [buttonView setTitleColor:[UIColor whiteColor] forState:UIControlStateHighlighted];
            [buttonView setBackgroundImage:buttonImage forState:UIControlStateNormal];
            [buttonView setBackgroundImage:buttonHighightedImage forState:UIControlStateHighlighted];
            [buttonView setTitleShadowColor:UIColorRGBA(0x124606, 0.3f) forState:UIControlStateNormal];
            [buttonView setTitleShadowColor:UIColorRGBA(0x124606, 0.3f) forState:UIControlStateHighlighted];
            buttonView.titleLabel.font = [UIFont boldSystemFontOfSize:16];
            buttonView.titleLabel.shadowOffset = CGSizeMake(0, -1);
            ((TGHighlightableButton *)buttonView).normalTitleShadowOffset = CGSizeMake(0, -1);
            ((TGHighlightableButton *)buttonView).reverseTitleShadow = false;
        }
    }
    
    _leftButton.hidden = visibleButtons < 1;
    _rightButton.hidden = visibleButtons < 2;
    
    [self setNeedsLayout];
}

- (TGHighlightableButton *)createButtonWithTitle:(NSString *)title
{
    UIImage *rawButtonImage = [UIImage imageNamed:@"GroupedActionButton.png"];
    UIImage *rawButtonHighlightedImage = [UIImage imageNamed:@"GroupedActionButton_Highlighted.png"];
    
    UIImage *buttonImage = [rawButtonImage stretchableImageWithLeftCapWidth:(int)(rawButtonImage.size.width / 2) topCapHeight:0];
    UIImage *buttonHighightedImage = [rawButtonHighlightedImage stretchableImageWithLeftCapWidth:(int)(rawButtonHighlightedImage.size.width / 2) topCapHeight:0];
    
    TGHighlightableButton *button = [[TGHighlightableButton alloc] initWithFrame:CGRectMake(0, 0, 100, rawButtonImage.size.height)];
    [button setBackgroundImage:buttonImage forState:UIControlStateNormal];
    [button setBackgroundImage:buttonHighightedImage forState:UIControlStateHighlighted];
    [button setTitleColor:UIColorRGB(0x4a6587) forState:UIControlStateNormal];
    [button setTitleShadowColor:UIColorRGBA(0xffffff, 0.45f) forState:UIControlStateNormal];
    [button setTitleColor:[UIColor whiteColor] forState:UIControlStateHighlighted];
    [button setTitleShadowColor:[UIColor clearColor] forState:UIControlStateHighlighted];
    button.titleLabel.font = [UIFont boldSystemFontOfSize:14];
    button.titleLabel.shadowOffset = CGSizeMake(0, 1);
    button.normalTitleShadowOffset = CGSizeMake(0, 1);
    button.adjustsImageWhenDisabled = false;
    button.exclusiveTouch = true;
    [button setTitle:title forState:UIControlStateNormal];
    
    return button;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    if (!_rightButton.hidden && !_leftButton.hidden)
    {
        CGFloat buttonWidth = CGFloor((self.contentView.frame.size.width - 10) / 2);
        _leftButton.frame = CGRectMake(0, 0, buttonWidth, _leftButton.frame.size.height);
        _rightButton.frame = CGRectMake(self.contentView.frame.size.width - buttonWidth, 0, buttonWidth, _rightButton.frame.size.height);
    }
    else if (!_leftButton.hidden)
    {
        _leftButton.frame = CGRectMake(0, 0, self.contentView.frame.size.width, _leftButton.frame.size.height);
    }
}

- (void)buttonPressed:(id)button
{
    NSString *action = nil;
    if (button == _leftButton && _buttons.count >= 1)
    {
        action = [[_buttons objectAtIndex:0] objectForKey:@"action"];
    }
    else if (button == _rightButton && _buttons.count >= 2)
    {
        action = [[_buttons objectAtIndex:1] objectForKey:@"action"];
    }
    
    if (action == nil)
        return;
    
    id<ASWatcher> watcher = _watcherHandle.delegate;
    if (watcher != nil && [watcher respondsToSelector:@selector(actionStageActionRequested:options:)])
    {
        [watcher actionStageActionRequested:@"buttonsMenuItemAction" options:[[NSDictionary alloc] initWithObjectsAndKeys:action, @"action", nil]];
    }
}

@end
