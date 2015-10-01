#import "TGButtonGroupView.h"

static UIImage *buttonLeftNormal()
{
    static UIImage *image = nil;
    if (image == nil)
        image = [[UIImage imageNamed:@"ButtonGroupLeft.png"] stretchableImageWithLeftCapWidth:8 topCapHeight:0];
    return image;
}

static UIImage *buttonLeftHighlighted()
{
    static UIImage *image = nil;
    if (image == nil)
        image = [[UIImage imageNamed:@"ButtonGroupLeft_Highlighted.png"] stretchableImageWithLeftCapWidth:8 topCapHeight:0];
    return image;
}

static UIImage *buttonCenterNormal()
{
    static UIImage *image = nil;
    if (image == nil)
        image = [[UIImage imageNamed:@"ButtonGroupCenter.png"] stretchableImageWithLeftCapWidth:1 topCapHeight:0];
    return image;
}

static UIImage *buttonCenterHighlighted()
{
    static UIImage *image = nil;
    if (image == nil)
        image = [[UIImage imageNamed:@"ButtonGroupCenter_Highlighted.png"] stretchableImageWithLeftCapWidth:1 topCapHeight:0];
    return image;
}

static UIImage *buttonRightNormal()
{
    static UIImage *image = nil;
    if (image == nil)
        image = [[UIImage imageNamed:@"ButtonGroupRight.png"] stretchableImageWithLeftCapWidth:1 topCapHeight:0];
    return image;
}

static UIImage *buttonRightHighlighted()
{
    static UIImage *image = nil;
    if (image == nil)
        image = [[UIImage imageNamed:@"ButtonGroupRight_Highlighted.png"] stretchableImageWithLeftCapWidth:1 topCapHeight:0];
    return image;
}

static UIImage *separatorImageNormal()
{
    static UIImage *image = nil;
    if (image == nil)
        image = [[UIImage imageNamed:@"ButtonGroupDivider.png"] stretchableImageWithLeftCapWidth:6 topCapHeight:0];
    return image;
}

static UIImage *separatorImageLeftHighlighted()
{
    static UIImage *image = nil;
    if (image == nil)
        image = [[UIImage imageNamed:@"ButtonGroupDivider_LeftHighlighted.png"] stretchableImageWithLeftCapWidth:6 topCapHeight:0];
    return image;
}

static UIImage *separatorImageRightHighlighted()
{
    static UIImage *image = nil;
    if (image == nil)
        image = [[UIImage imageNamed:@"ButtonGroupDivider_RightHighlighted.png"] stretchableImageWithLeftCapWidth:6 topCapHeight:0];
    return image;
}

@class TGButtonGroupButton;

@protocol TGButtonGroupButtonDelegate <NSObject>

- (void)buttonGroupButtonHighlighted;

@end

@interface TGButtonGroupButton : UIButton

@property (nonatomic) bool animateHighlight;

@property (nonatomic, weak) id<TGButtonGroupButtonDelegate> delegate;

@end

@implementation TGButtonGroupButton

@synthesize delegate = _delegate;

@synthesize animateHighlight = _animateHighlight;

- (void)setHighlighted:(BOOL)highlighted
{
    [super setHighlighted:highlighted];
    
    __strong id delegate = _delegate;
    [delegate buttonGroupButtonHighlighted];
}

- (void)setSelected:(BOOL)selected
{
    [super setSelected:selected];
    
    __strong id delegate = _delegate;
    [delegate buttonGroupButtonHighlighted];
}

@end

@interface TGButtonGroupView () <TGButtonGroupButtonDelegate>

@property (nonatomic) int validHighlightedIndex;
@property (nonatomic) bool validImages;

@property (nonatomic, strong) NSMutableArray *buttonList;
@property (nonatomic, strong) NSMutableArray *separatorList;

@end

@implementation TGButtonGroupView

- (id)initWithFrame:(CGRect)frame buttonLeftImage:(UIImage *)buttonLeftImage buttonLeftHighlightedImage:(UIImage *)buttonLeftHighlightedImage buttonCenterImage:(UIImage *)buttonCenterImage buttonCenterHighlightedImage:(UIImage *)buttonCenterHighlightedImage buttonRightImage:(UIImage *)buttonRightImage buttonRightHighlightedImage:(UIImage *)buttonRightHighlightedImage buttonSeparatorImage:(UIImage *)buttonSeparatorImage buttonSeparatorLeftHighlightedImage:(UIImage *)buttonSeparatorLeftHighlightedImage buttonSeparatorRightHighlightedImage:(UIImage *)buttonSeparatorRightHighlightedImage
{
    self = [super initWithFrame:frame];
    if (self)
    {
        _buttonLeftImage = buttonLeftImage;
        _buttonLeftHighlightedImage = buttonLeftHighlightedImage;
        _buttonCenterImage = buttonCenterImage;
        _buttonCenterHighlightedImage = buttonCenterHighlightedImage;
        _buttonRightImage = buttonRightImage;
        _buttonRightHighlightedImage = buttonRightHighlightedImage;
        _buttonSeparatorImage = buttonSeparatorImage;
        _buttonSeparatorLeftHighlightedImage = buttonSeparatorLeftHighlightedImage;
        _buttonSeparatorRightHighlightedImage = buttonSeparatorRightHighlightedImage;
        
        [self commonInit];
    }
    return self;
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
    {
        _buttonLeftImage = buttonLeftNormal();
        _buttonLeftHighlightedImage = buttonLeftHighlighted();
        _buttonCenterImage = buttonCenterNormal();
        _buttonCenterHighlightedImage = buttonCenterHighlighted();
        _buttonRightImage = buttonRightNormal();
        _buttonRightHighlightedImage = buttonRightHighlighted();
        _buttonSeparatorImage = separatorImageNormal();
        _buttonSeparatorLeftHighlightedImage = separatorImageLeftHighlighted();
        _buttonSeparatorRightHighlightedImage = separatorImageRightHighlighted();
        
        [self commonInit];
    }
    return self;
}

- (void)commonInit
{
    _validHighlightedIndex = -1;
    
    _buttonList = [[NSMutableArray alloc] init];
    _separatorList = [[NSMutableArray alloc] init];
    
    _buttonFont = [UIFont boldSystemFontOfSize:12];
    _buttonTextColor = [UIColor whiteColor];
    _buttonShadowColor =  UIColorRGBA(0x0e284d, 0.4f);
    _buttonShadowOffset = CGSizeMake(0, -1);
}

- (void)addButton:(NSString *)text
{
    TGButtonGroupButton *button = [[TGButtonGroupButton alloc] init];
    button.exclusiveTouch = true;
    [button setTitle:text forState:UIControlStateNormal];
    [button addTarget:self action:@selector(buttonPressed:) forControlEvents:UIControlEventTouchDown];
    button.delegate = self;
    button.animateHighlight = _buttonsAreAlwaysDeselected;
    
    button.titleLabel.font = _buttonFont;
    
    [button setTitleColor:_buttonTextColor forState:UIControlStateNormal];
    [button setTitleColor:_buttonTextColorHighlighted != nil ? _buttonTextColorHighlighted : _buttonTextColor forState:UIControlStateHighlighted];
    [button setTitleColor:_buttonTextColorHighlighted != nil ? _buttonTextColorHighlighted : _buttonTextColor forState:UIControlStateSelected];
    [button setTitleColor:_buttonTextColorHighlighted != nil ? _buttonTextColorHighlighted : _buttonTextColor forState:UIControlStateSelected | UIControlStateHighlighted];
    
    [button setTitleShadowColor:_buttonShadowColor forState:UIControlStateNormal];
    [button setTitleShadowColor:_buttonShadowColor forState:UIControlStateHighlighted];
    
    if (_buttonShadowColorHighlighted != nil)
    {
        [button setTitleShadowColor:_buttonShadowColorHighlighted forState:UIControlStateSelected];
        [button setTitleShadowColor:_buttonShadowColorHighlighted forState:UIControlStateSelected | UIControlStateHighlighted];
    }
    
    button.titleLabel.shadowOffset = _buttonShadowOffset;
    
    button.adjustsImageWhenDisabled = false;
    button.adjustsImageWhenHighlighted = false;
    
    [_buttonList addObject:button];
    [self addSubview:button];
    
    if (_buttonList.count > 1)
    {
        UIView *separatorView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, _buttonSeparatorImage.size.width, _buttonSeparatorImage.size.height)];
        
        UIImageView *normalImageView = [[UIImageView alloc] initWithImage:_buttonSeparatorImage];
        normalImageView.tag = 100;
        normalImageView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        [separatorView addSubview:normalImageView];
        
        UIImageView *leftHighlightedImageView = [[UIImageView alloc] initWithImage:_buttonSeparatorLeftHighlightedImage];
        leftHighlightedImageView.tag = 101;
        leftHighlightedImageView.alpha = 0.0f;
        leftHighlightedImageView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        [separatorView addSubview:leftHighlightedImageView];
        
        UIImageView *rightHighlightedImageView = [[UIImageView alloc] initWithImage:_buttonSeparatorRightHighlightedImage];
        rightHighlightedImageView.tag = 102;
        rightHighlightedImageView.alpha = 0.0f;
        rightHighlightedImageView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        [separatorView addSubview:rightHighlightedImageView];
        
        [_separatorList addObject:separatorView];
        [self addSubview:separatorView];
    }
    
    _validImages = false;
    [self setNeedsLayout];
}

- (void)setSelectedIndex:(int)selectedIndex
{
    _selectedIndex = selectedIndex;
    
    [self updateImages];
}

- (void)updateImages
{
    NSInteger index = -1;
    for (UIButton *button in _buttonList)
    {
        index++;
        UIImage *image = nil;
        UIImage *highlightedImage = nil;
        
        UIEdgeInsets titleInset = UIEdgeInsetsZero;
        
        titleInset.top = _buttonTopTextInset;
        
        if (index == 0)
        {
            image = _buttonLeftImage;
            highlightedImage = _buttonLeftHighlightedImage;
            
            titleInset.left = _buttonSideTextInset;
        }
        else if (index == (NSInteger)(_buttonList.count - 1))
        {
            image = _buttonRightImage;
            highlightedImage = _buttonRightHighlightedImage;
            
            titleInset.right = _buttonSideTextInset;
        }
        else
        {
            image = _buttonCenterImage;
            highlightedImage = _buttonCenterHighlightedImage;
        }
        
        [button setTitleEdgeInsets:titleInset];
        
        [button setBackgroundImage:image forState:UIControlStateNormal];
        if (_buttonsAreAlwaysDeselected)
            [button setBackgroundImage:highlightedImage forState:UIControlStateHighlighted];
        else
            [button setBackgroundImage:image forState:UIControlStateHighlighted];
        [button setBackgroundImage:highlightedImage forState:UIControlStateSelected];
        [button setBackgroundImage:highlightedImage forState:UIControlStateSelected | UIControlStateHighlighted];
    }
}

- (void)updateSelection
{
    int index = -1;
    for (UIButton *button in _buttonList)
    {
        index++;
        
        if (index == _selectedIndex)
        {
            if (!_buttonsAreAlwaysDeselected)
                button.selected = true;
            [button setTitleColor:_buttonTextColorHighlighted != nil ? _buttonTextColorHighlighted : _buttonTextColor forState:UIControlStateNormal];
        }
        else
        {
            button.highlighted = false;
            button.selected = false;
            [button setTitleColor:_buttonTextColor forState:UIControlStateNormal];
        }
    }
}

- (void)buttonGroupButtonHighlighted
{
    [self buttonGroupButtonHighlighted:-1];
}

- (void)buttonGroupButtonHighlighted:(int)forceIndex
{
    int selectedButtonIndex = -1;
    
    int index = -1;
    for (UIButton *listButton in _buttonList)
    {
        index++;
        
        if (listButton.selected || listButton.highlighted || index == forceIndex)
        {
            selectedButtonIndex = index;
            break;
        }
    }
    
    if (_validHighlightedIndex == selectedButtonIndex)
        return;
    
    bool animated = _buttonsAreAlwaysDeselected && _validHighlightedIndex != -1 && selectedButtonIndex == -1;
    int lastHighlightedIndex = _validHighlightedIndex;
    
    _validHighlightedIndex = selectedButtonIndex;
    
    void (^block)(bool show) = ^(bool show)
    {
        int index = -1;
        for (UIView *separatorView in _separatorList)
        {
            index++;
            
            UIView *normalView = [separatorView viewWithTag:100];
            UIView *leftView = [separatorView viewWithTag:101];
            UIView *rightView = [separatorView viewWithTag:102];
            
            if (selectedButtonIndex == index)
            {
                if (show)
                {
                    leftView.alpha = 1.0f;
                    [separatorView bringSubviewToFront:leftView];
                }
                else
                {
                    normalView.alpha = 0.0f;
                    rightView.alpha = 0.0f;
                }
            }
            else if (selectedButtonIndex == index + 1)
            {
                if (show)
                {
                    rightView.alpha = 1.0f;
                    [separatorView bringSubviewToFront:rightView];
                }
                else
                {
                    normalView.alpha = 0.0f;
                    leftView.alpha = 0.0f;
                }
            }
            else
            {
                if (show)
                {
                    normalView.alpha = 1.0f;
                    [separatorView bringSubviewToFront:normalView];
                }
                else
                {
                    leftView.alpha = 0.0f;
                    rightView.alpha = 0.0f;
                }
            }
        }
    };
    
    if (cpuCoreCount() > 1 && animated && lastHighlightedIndex != -1)
    {
        block(true);
        block(false);
        
        UIView *button = [_buttonList objectAtIndex:lastHighlightedIndex];
        
        [UIView transitionWithView:button duration:0.25 options:UIViewAnimationOptionTransitionCrossDissolve animations:^
        {
        } completion:nil];
        
        int index = -1;
        for (UIView *separatorView in _separatorList)
        {
            index++;
            if (index == lastHighlightedIndex || index == lastHighlightedIndex - 1)
            {
                [UIView transitionWithView:separatorView duration:0.25 options:UIViewAnimationOptionTransitionCrossDissolve animations:^
                {
                    
                } completion:nil];
            }
        }
    }
    else
    {
        block(true);
        block(false);
    }
}

- (void)buttonPressed:(UIButton *)button
{
    int index = -1;
    for (UIButton *currentButton in _buttonList)
    {
        index++;
        if (currentButton == button)
        {
            _selectedIndex = index;
            [self updateSelection];
            
            id<TGButtonGroupViewDelegate> delegate = _delegate;
            [delegate buttonGroupViewButtonPressed:self index:index];
            
            break;
        }
    }
}

- (void)sizeToFit
{
    CGFloat buttonWidth = 80;
    CGFloat separatorWidth = 2;
    CGFloat buttonHeight = _isLandscape ? 25 : 30;
    
    CGFloat overallWidth = buttonWidth * _buttonList.count + separatorWidth * MAX(0, (NSInteger)_buttonList.count - 1);
    
    self.frame = CGRectMake(self.frame.origin.x, self.frame.origin.y, overallWidth, buttonHeight);
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    if (!_validImages)
    {
        _validImages = true;
        
        [self updateImages];
        [self updateSelection];
    }
    
    NSInteger count = _buttonList.count;
    
    CGFloat separatorWidth = _buttonSeparatorImage.size.width;
    CGFloat buttonHeight = _buttonLeftImage.size.height;
    
    CGSize buttonSize = CGSizeMake((int)((self.frame.size.width - separatorWidth * MAX(0, count - 1)) / count), buttonHeight);
    
    float currentX = 0;
    for (int i = 0; i < count; i++)
    {
        UIButton *button  = [_buttonList objectAtIndex:i];
        button.frame = CGRectMake(currentX, 0, i == count - 1 ? self.frame.size.width - currentX : buttonSize.width, buttonSize.height);
        
        currentX += buttonSize.width;
        
        if (i + 1 < count)
        {
            UIView *separatorView = [_separatorList objectAtIndex:i];
            separatorView.frame = CGRectMake(currentX, 0, separatorWidth, buttonSize.height);
        }
        
        currentX += separatorWidth;
    }
}

@end
