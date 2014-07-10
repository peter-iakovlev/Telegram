#import "TGButtonMenuItemCell.h"

#import "TGInterfaceAssets.h"

#import "TGViewController.h"

@interface TGButtonMenuItemCell ()

@property (nonatomic, strong) UIButton *button;
@property (nonatomic) TGButtonMenuItemSubtype subtype;

@property (nonatomic, strong) UIImageView *iconView;

@end

@implementation TGButtonMenuItemCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self)
    {
        self.backgroundColor = nil;
        self.opaque = false;
        
        self.clipsToBounds = false;
        self.contentView.superview.clipsToBounds = false;
        
        _button = [[UIButton alloc] initWithFrame:CGRectMake(9, 0, self.frame.size.width - 18, 45)];
        _button.adjustsImageWhenDisabled = false;
        _button.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        [self addSubview:_button];
        
        _button.titleLabel.font = [UIFont boldSystemFontOfSize:17];
        _button.exclusiveTouch = true;
        
        [_button addTarget:self action:@selector(buttonPressed) forControlEvents:UIControlEventTouchUpInside];
    }
    return self;
}

- (void)setTitle:(NSString *)title
{
    [_button setTitle:title forState:UIControlStateNormal];
}

- (void)setTitleIcon:(UIImage *)icon
{
    if (icon != nil)
    {
        if (_iconView == nil)
        {
            _iconView = [[UIImageView alloc] init];
            [_button.titleLabel addSubview:_iconView];
        }
        
        _iconView.image = icon;
        _iconView.frame = CGRectMake(1, 3, icon.size.width, icon.size.height);
        
        _iconView.hidden = false;
    }
    else if (_iconView != nil)
    {
        _iconView.hidden = true;
    }
}

- (void)setSubtype:(TGButtonMenuItemSubtype)subtype
{
    _subtype = subtype;
    
    if (subtype == TGButtonMenuItemSubtypeRedButton)
    {
        [_button setBackgroundImage:[TGInterfaceAssets menuButtonBackgroundRed] forState:UIControlStateNormal];
        [_button setBackgroundImage:[TGInterfaceAssets menuButtonBackgroundRedHighlighted] forState:UIControlStateHighlighted];
        
        [_button setTitleColor:UIColorRGB(0xffffff) forState:UIControlStateNormal];
        [_button setTitleColor:UIColorRGB(0xffffff) forState:UIControlStateHighlighted];
        [_button setTitleShadowColor:UIColorRGBA(0xa10603, 0.5f) forState:UIControlStateNormal];
        [_button setTitleShadowColor:UIColorRGBA(0xa10603, 0.5f) forState:UIControlStateHighlighted];
        _button.titleLabel.shadowOffset = CGSizeMake(0, -1);
    }
    else if (subtype == TGButtonMenuItemSubtypeGrayButton)
    {
        CGRect buttonFrame = _button.frame;
        buttonFrame.origin.y = 0;
        _button.frame = buttonFrame;
        
        [_button setBackgroundImage:[TGInterfaceAssets menuButtonBackgroundGray] forState:UIControlStateNormal];
        [_button setBackgroundImage:[TGInterfaceAssets menuButtonBackgroundGrayHighlighted] forState:UIControlStateHighlighted];
        
        [_button setTitleColor:UIColorRGB(0x4a6587) forState:UIControlStateNormal];
        [_button setTitleColor:[UIColor whiteColor] forState:UIControlStateHighlighted];
        [_button setTitleShadowColor:UIColorRGBA(0xffffff, 0.45f) forState:UIControlStateNormal];
        [_button setTitleShadowColor:[UIColor clearColor] forState:UIControlStateHighlighted];
        _button.titleLabel.shadowOffset = CGSizeMake(0, 1);
    }
    else if (subtype == TGButtonMenuItemSubtypeGreenButton)
    {
        static UIImage *buttonImage = nil;
        static UIImage *buttonHighightedImage = nil;
        
        static dispatch_once_t onceToken;
        dispatch_once(&onceToken, ^
        {
            UIImage *rawButtonImage = [UIImage imageNamed:@"GroupedActionButtonGreen.png"];
            UIImage *rawButtonHighlightedImage = [UIImage imageNamed:@"GroupedActionButtonGreen_Highlighted.png"];
            
            buttonImage = [rawButtonImage stretchableImageWithLeftCapWidth:(int)(rawButtonImage.size.width / 2) topCapHeight:0];
            buttonHighightedImage = [rawButtonHighlightedImage stretchableImageWithLeftCapWidth:(int)(rawButtonHighlightedImage.size.width / 2) topCapHeight:0];
        });
        
        [_button setBackgroundImage:buttonImage forState:UIControlStateNormal];
        [_button setBackgroundImage:buttonHighightedImage forState:UIControlStateHighlighted];
        
        [_button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [_button setTitleColor:[UIColor whiteColor] forState:UIControlStateHighlighted];
        [_button setTitleShadowColor:UIColorRGBA(0x124606, 0.3f) forState:UIControlStateNormal];
        [_button setTitleShadowColor:UIColorRGBA(0x124606, 0.3f) forState:UIControlStateHighlighted];
        _button.titleLabel.shadowOffset = CGSizeMake(0, -1);
    }
}

- (void)setEnabled:(bool)enabled
{
    _button.enabled = enabled;
    _button.alpha = enabled ? 1.0f : 0.7f;
}

- (void)buttonPressed
{
    id<ASWatcher> watcher = _watcherHandle.delegate;
    if (_itemId != nil && watcher != nil && [watcher respondsToSelector:@selector(actionStageActionRequested:options:)])
    {
        [watcher actionStageActionRequested:@"buttonItemPressed" options:[[NSDictionary alloc] initWithObjectsAndKeys:_itemId, @"itemId", nil]];
    }
}

- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event
{
    CGRect viewFrame = _button.frame;
    if (CGRectContainsPoint(viewFrame, point))
    {
        UIView *hitResult = [_button hitTest:CGPointMake(point.x - viewFrame.origin.x, point.y - viewFrame.origin.y) withEvent:event];
        if (hitResult != nil)
            return hitResult;
    }
    
    return [super hitTest:point withEvent:event];
}

- (void)setContentHidden:(bool)hidden
{
    _button.hidden = hidden;
}

- (void)updateFrame
{
    if (_subtype == TGButtonMenuItemSubtypeRedButton || _subtype == TGButtonMenuItemSubtypeGreenButton)
    {
        UIScrollView *superview = (UIScrollView *)[self superview];
        if ([superview isKindOfClass:[UIScrollView class]])
        {
            CGRect superviewFrame = superview.bounds;
            
            CGSize screenSize = [TGViewController screenSizeForInterfaceOrientation:UIInterfaceOrientationPortrait];
            
            if ((int)superviewFrame.size.height == (int)screenSize.height - 20 - 32)
                superviewFrame.size.height = (int)screenSize.height - 20 - 44;
            else if ((int)superviewFrame.size.height == (int)screenSize.width - 20 - 44)
                superviewFrame.size.height = (int)screenSize.width - 20 - 32;
            else if ((int)superviewFrame.size.height == (int)screenSize.height - 20 - 32 - 49)
                superviewFrame.size.height = (int)screenSize.height - 20 - 44 - 49;
            else if ((int)superviewFrame.size.height == (int)screenSize.width - 20 - 44 - 49)
                superviewFrame.size.height = (int)screenSize.width - 20 - 32 - 49;
            
            CGRect buttonFrame = _button.frame;
            buttonFrame.origin.y = MAX(0, superviewFrame.size.height - buttonFrame.size.height - self.frame.origin.y - superview.contentInset.bottom - superview.contentInset.top);
            _button.frame = buttonFrame;
        }
    }
}

@end
