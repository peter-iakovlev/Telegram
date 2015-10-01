#import "TGMenuView.h"

#import <QuartzCore/QuartzCore.h>

#import "TGFont.h"

#pragma mark -

@protocol TGMenuButtonViewDelegate <NSObject>

- (void)menuButtonHighlighted;

@end

@interface TGMenuButtonView : UIButton

@property (nonatomic, weak) id<TGMenuButtonViewDelegate> delegate;

@property (nonatomic, strong) UIImageView *leftView;
@property (nonatomic, strong) UIImageView *centerView;
@property (nonatomic, strong) UIImageView *rightView;

@end

@implementation TGMenuButtonView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self != nil)
    {
        _leftView = [[UIImageView alloc] init];
        [self addSubview:_leftView];
        _centerView = [[UIImageView alloc] init];
        [self addSubview:_centerView];
        _rightView = [[UIImageView alloc] init];
        [self addSubview:_rightView];
    }
    return self;
}

- (void)setHighlighted:(BOOL)highlighted
{
    [super setHighlighted:highlighted];
    bool selected = self.selected;
    
    __strong id<TGMenuButtonViewDelegate> delegate = _delegate;
    [delegate menuButtonHighlighted];
    
    highlighted = highlighted || selected;
    
    _leftView.highlighted = highlighted;
    _centerView.highlighted = highlighted;
    _rightView.highlighted = highlighted;
}

- (void)setSelected:(BOOL)selected
{
    [super setSelected:selected];
    bool highlighted = self.highlighted;
    
    __strong id<TGMenuButtonViewDelegate> delegate = _delegate;
    [delegate menuButtonHighlighted];
    
    selected = selected || highlighted;
    
    _leftView.highlighted = selected;
    _centerView.highlighted = selected;
    _rightView.highlighted = selected;
}

- (void)sizeToFit
{
    self.frame = CGRectMake(self.frame.origin.x, self.frame.origin.y, [[self titleForState:UIControlStateNormal] sizeWithFont:self.titleLabel.font].width + 34, 41);
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    CGSize viewSize = self.frame.size;
    
    _leftView.frame = CGRectMake(0, 0, _leftView.image.size.width, viewSize.height);
    _rightView.frame = CGRectMake(viewSize.width - _rightView.image.size.width, 0, _rightView.image.size.width, viewSize.height);
    _centerView.frame = CGRectMake(_leftView.frame.size.width, 0, _rightView.frame.origin.x - _leftView.frame.size.width, viewSize.height);
}

@end

#pragma mark -

@interface TGMenuView () <TGMenuButtonViewDelegate>
{
    NSDictionary *_userInfo;
}

@property (nonatomic, strong) NSMutableArray *buttonViews;
@property (nonatomic, strong) NSMutableArray *separatorViews;
@property (nonatomic, strong) NSArray *buttonDescriptions;

@property (nonatomic) CGFloat arrowLocation;
@property (nonatomic) bool arrowOnTop;

@property (nonatomic, strong) UIImageView *arrowTopView;
@property (nonatomic, strong) UIImageView *arrowBottomView;

@property (nonatomic, strong) ASHandle *watcherHandle;

@end

@implementation TGMenuView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
    {
        self.alpha = 0.0f;
        self.layer.anchorPoint = CGPointMake(0.5f, 1.0f);
        self.transform = CGAffineTransformMakeScale(0.1f, 0.1f);
        
        _buttonViews = [[NSMutableArray alloc] init];
        _separatorViews = [[NSMutableArray alloc] init];
        
        _arrowTopView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"MenuArrowTop.png"] highlightedImage:[UIImage imageNamed:@"MenuArrowTop_Highlighted.png"]];
        [self addSubview:_arrowTopView];
        
        _arrowBottomView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"MenuArrowBottom.png"] highlightedImage:[UIImage imageNamed:@"MenuArrowBottom_Highlighted.png"]];
        [self addSubview:_arrowBottomView];
        
        _arrowLocation = 50;
    }
    return self;
}

- (void)setUserInfo:(NSDictionary *)userInfo
{
    _userInfo = userInfo;
}

- (void)setButtonsAndActions:(NSArray *)buttonsAndActions watcherHandle:(ASHandle *)watcherHandle
{
    _watcherHandle = watcherHandle;
    
    _buttonDescriptions = buttonsAndActions;
    
    int index = -1;
    for (NSDictionary *dict in buttonsAndActions)
    {
        index++;
        
        NSString *title = [dict objectForKey:@"title"];
        
        TGMenuButtonView *buttonView = nil;
        
        if (index < (int)_buttonViews.count)
            buttonView = [_buttonViews objectAtIndex:index];
        else
        {
            buttonView = [[TGMenuButtonView alloc] init];
            //buttonView.userInteractionEnabled = false;
            buttonView.delegate = self;
            [buttonView setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
            [buttonView setTitleColor:UIColorRGBA(0xffffff, 0.5f) forState:UIControlStateDisabled];
            buttonView.titleLabel.font = TGSystemFontOfSize(14);
            [buttonView addTarget:self action:@selector(buttonPressed:) forControlEvents:UIControlEventTouchUpInside];
            [_buttonViews addObject:buttonView];
            [self addSubview:buttonView];
        }
        
        [buttonView setTitle:title forState:UIControlStateNormal];
        buttonView.selected = false;
    }
    
    while ((int)_buttonViews.count > index + 1)
    {
        TGMenuButtonView *buttonView = [_buttonViews lastObject];
        buttonView.delegate = nil;
        [buttonView removeFromSuperview];
        [_buttonViews removeLastObject];
    }
    
    if (_buttonViews.count != 0) {
        while (_separatorViews.count < _buttonViews.count - 1)
        {
            UIImageView *separatorView = [[UIImageView alloc] init];
            separatorView.image = [UIImage imageNamed:@"MenuButtonSeparator.png"];
            [self addSubview:separatorView];
            [_separatorViews addObject:separatorView];
        }
    }
    
    if (_buttonViews.count != 0) {
        while (_separatorViews.count > _buttonViews.count - 1)
        {
            UIImageView *separatorView = [_separatorViews lastObject];
            [separatorView removeFromSuperview];
            [_separatorViews removeLastObject];
        }
    }
    
    index = -1;
    for (TGMenuButtonView *buttonView in _buttonViews)
    {
        index++;
        
        [buttonView sizeToFit];
        if (index == 0 || index == (int)_buttonViews.count - 1)
        {
            CGRect buttonFrame = buttonView.frame;
            buttonFrame.size.width += 1;
            buttonView.frame = buttonFrame;
        }
    }
    
    [self updateBackgrounds];
    
    [self setNeedsLayout];
}

- (void)menuButtonHighlighted
{
    static UIImage *separatorNormal = nil;
    static UIImage *separatorLeft = nil;
    static UIImage *separatorRight = nil;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^
    {
        separatorNormal = [UIImage imageNamed:@"MenuButtonSeparator.png"];
        separatorLeft = [UIImage imageNamed:@"MenuButtonSeparatorLeft.png"];
        separatorRight = [UIImage imageNamed:@"MenuButtonSeparatorRight.png"];
    });
    
    NSInteger highlightedIndex = -1;
    
    bool arrowHighlighted = false;
    
    NSInteger index = -1;
    for (TGMenuButtonView *buttonView in _buttonViews)
    {
        index++;
        
        bool containsArrow = _arrowLocation >= buttonView.frame.origin.x && _arrowLocation < buttonView.frame.origin.x + buttonView.frame.size.width;
        
        if (index == 0)
        {
            if (_arrowLocation < buttonView.frame.size.width)
                containsArrow = true;
        }
        
        if (index == (NSInteger)_buttonViews.count - 1)
        {
            if (_arrowLocation >= buttonView.frame.origin.x)
                containsArrow = true;
        }
        
        if (buttonView.highlighted || buttonView.selected)
        {
            arrowHighlighted = containsArrow;
            highlightedIndex = index;
            break;
        }
    }
    
    if (highlightedIndex == -1)
    {
        for (UIImageView *view in _separatorViews)
            view.image = separatorNormal;
    }
    else
    {
        NSInteger separatorIndex = -1;
        for (UIImageView *view in _separatorViews)
        {
            separatorIndex++;
            
            if (separatorIndex == highlightedIndex - 1)
                view.image = separatorLeft;
            else if (separatorIndex == highlightedIndex)
                view.image = separatorRight;
            else
                view.image = separatorNormal;
        }
    }
    
    _arrowTopView.highlighted = arrowHighlighted;
    _arrowBottomView.highlighted = arrowHighlighted;
}

- (void)updateBackgrounds
{
    UIImage *rawLeftImage = [UIImage imageNamed:@"MenuButtonLeft.png"];
    UIImage *leftImage = [rawLeftImage stretchableImageWithLeftCapWidth:(int)(rawLeftImage.size.width - 1) topCapHeight:0];
    UIImage *rightImage = [[UIImage imageNamed:@"MenuButtonRight.png"] stretchableImageWithLeftCapWidth:0 topCapHeight:0];
    UIImage *rawCenterImage = [UIImage imageNamed:@"MenuButtonCenter.png"];
    UIImage *centerImage = [rawCenterImage stretchableImageWithLeftCapWidth:(int)(rawCenterImage.size.width / 2) topCapHeight:0];
    
    UIImage *rawLeftHighlightedImage = [UIImage imageNamed:@"MenuButtonLeft_Highlighted.png"];
    UIImage *leftHighlightedImage = [rawLeftHighlightedImage stretchableImageWithLeftCapWidth:(int)(rawLeftHighlightedImage.size.width - 1) topCapHeight:0];
    UIImage *rightHighlightedImage = [[UIImage imageNamed:@"MenuButtonRight_Highlighted.png"] stretchableImageWithLeftCapWidth:0 topCapHeight:0];
    UIImage *rawCenterHighlightedImage = [UIImage imageNamed:@"MenuButtonCenter_Highlighted.png"];
    UIImage *centerHighlightedImage = [rawCenterHighlightedImage stretchableImageWithLeftCapWidth:(int)(rawCenterHighlightedImage.size.width / 2) topCapHeight:0];
    
    NSInteger index = -1;
    for (TGMenuButtonView *buttonView in _buttonViews)
    {
        index++;
        
        buttonView.centerView.image = centerImage;
        buttonView.leftView.image = centerImage;
        buttonView.rightView.image = centerImage;
        
        buttonView.centerView.highlightedImage = centerHighlightedImage;
        buttonView.leftView.highlightedImage = centerHighlightedImage;
        buttonView.rightView.highlightedImage = centerHighlightedImage;
        
        UIEdgeInsets titleInset = UIEdgeInsetsMake(0, 0, 1, 0);
        
        if (index == 0)
        {
            buttonView.leftView.image = leftImage;
            buttonView.leftView.highlightedImage = leftHighlightedImage;
            titleInset.left += 2;
        }
        
        if (index == (NSInteger)_buttonViews.count - 1)
        {
            buttonView.rightView.image = rightImage;
            buttonView.rightView.highlightedImage = rightHighlightedImage;
            titleInset.right += 2;
        }
        
        buttonView.titleEdgeInsets = titleInset;
    }
}

- (void)sizeToFit
{
    CGAffineTransform transform = self.transform;
    self.transform = CGAffineTransformIdentity;
    
    float width = 0;
    for (TGMenuButtonView *buttonView in _buttonViews)
    {
        width += buttonView.frame.size.width;
    }
    self.frame = CGRectMake(self.frame.origin.x, self.frame.origin.y, width, 41);
    
    self.transform = transform;
}

- (void)showInView:(UIView *)view fromRect:(CGRect)rect
{
    [self showInView:view fromRect:rect animated:true];
}

- (void)showInView:(UIView *)view fromRect:(CGRect)rect animated:(bool)animated
{
    CGAffineTransform transform = self.transform;
    self.transform = CGAffineTransformIdentity;
    
    CGRect frame = self.frame;
    frame.origin.x = CGFloor(rect.origin.x + rect.size.width / 2 - frame.size.width / 2);
    if (frame.origin.x < 4)
        frame.origin.x = 4;
    if (frame.origin.x + frame.size.width > view.frame.size.width - 4)
        frame.origin.x = view.frame.size.width - 4 - frame.size.width;
    
    frame.origin.y = rect.origin.y - frame.size.height - 14;
    if (frame.origin.y < 2)
    {
        frame.origin.y = rect.origin.y + rect.size.height + 17;
        if (frame.origin.y + frame.size.height > view.frame.size.height - 14)
        {
            frame.origin.y = CGFloor((view.frame.size.height - frame.size.height) / 2);
            _arrowOnTop = false;
        }
        else
            _arrowOnTop = true;
    }
    else
    {
        _arrowOnTop = false;
    }
    
    _arrowLocation = CGFloor(rect.origin.x + rect.size.width / 2) - frame.origin.x;
    
    self.layer.anchorPoint = CGPointMake(MAX(0.0f, MIN(1.0f, _arrowLocation / frame.size.width)), _arrowOnTop ? -0.2f : 1.2f);
    
    self.frame = frame;
    [self setNeedsLayout];
    [self layoutIfNeeded];
    
    self.transform = transform;
    
    self.layer.rasterizationScale = [[UIScreen mainScreen] scale];
    self.layer.shouldRasterize = true;
    
    self.alpha = 1.0f;
 
    if (animated)
    {
        [UIView animateWithDuration:0.142 delay:0 options:UIViewAnimationOptionCurveEaseOut | UIViewAnimationOptionBeginFromCurrentState animations:^
        {
            self.transform = CGAffineTransformMakeScale(1.07f, 1.07f);
        } completion:^(BOOL finished)
        {
            if(finished)
            {
                [UIView animateWithDuration:0.08 delay:0 options:UIViewAnimationOptionBeginFromCurrentState animations:^
                {
                    self.transform = CGAffineTransformMakeScale(0.967f, 0.967f);
                } completion:^(BOOL finished)
                {
                    if (finished)
                    {
                        [UIView animateWithDuration:0.06 delay:0 options:UIViewAnimationOptionCurveEaseOut | UIViewAnimationOptionBeginFromCurrentState animations:^
                        {
                            self.transform = CGAffineTransformIdentity;
                        } completion:^(BOOL finished)
                        {
                            if (finished)
                            {
                                self.layer.shouldRasterize = false;
                            }
                        }];
                    }
                }];
            }
        }];
    }
    else
    {
        self.transform = CGAffineTransformIdentity;
        self.alpha = 0.0f;
        [UIView animateWithDuration:0.3 animations:^
        {
            self.alpha = 1.0f;
        }];
    }
}

- (void)hide:(dispatch_block_t)completion
{
    [UIView animateWithDuration:0.2 delay:0 options:UIViewAnimationOptionBeginFromCurrentState animations:^
    {
        self.alpha = 0.0f;
    } completion:^(BOOL finished)
    {
        if (finished)
        {
            self.transform = CGAffineTransformMakeScale(0.1f, 0.1f);
            
            if (completion)
                completion();
        }
    }];
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    float currentX = 0;
    
    NSInteger index = -1;
    for (TGMenuButtonView *buttonView in _buttonViews)
    {
        index++;
        
        buttonView.frame = CGRectMake(currentX, 0, buttonView.frame.size.width, buttonView.frame.size.height);
        currentX += buttonView.frame.size.width;
        [buttonView layoutSubviews];
    }
    
    index = -1;
    for (TGMenuButtonView *buttonView in _buttonViews)
    {
        index++;
        
        CGFloat linePosition = 0.0f;
        CGFloat lineWidth = buttonView.frame.size.width;
        
        if (index > 0)
        {
            UIImageView *separatorView = [_separatorViews objectAtIndex:index - 1];
            separatorView.frame = CGRectMake(buttonView.frame.origin.x - 1, 2, separatorView.image.size.width, 36);
        }
        
        bool containsArrow = _arrowLocation >= buttonView.frame.origin.x && _arrowLocation < buttonView.frame.origin.x + buttonView.frame.size.width;
        
        if (index == 0)
        {
            linePosition += 10;
            lineWidth -= 10;
            
            if (_arrowLocation < buttonView.frame.size.width)
                containsArrow = true;
        }
        
        if (index == (NSInteger)_buttonViews.count - 1)
        {
            lineWidth -= 10;
            
            if (_arrowLocation >= buttonView.frame.origin.x)
                containsArrow = true;
        }
        
        if (containsArrow)
        {
            CGFloat minArrowX = buttonView.frame.origin.x + (index == 0 ? 10 : 0);
            CGFloat maxArrowX = buttonView.frame.origin.x + buttonView.frame.size.width - _arrowTopView.frame.size.width + (index == (NSInteger)_buttonViews.count - 1 ? (-10) : 0);

            CGFloat arrowX = CGFloor(_arrowLocation - _arrowTopView.frame.size.width / 2);
            arrowX = MIN(MAX(minArrowX, arrowX), maxArrowX);
            
            _arrowTopView.frame = CGRectMake(arrowX, -9, _arrowTopView.frame.size.width, _arrowTopView.frame.size.height);
            _arrowBottomView.frame = CGRectMake(arrowX, 37, _arrowBottomView.frame.size.width, _arrowBottomView.frame.size.height);
        }
    }
    
    _arrowTopView.hidden = !_arrowOnTop;
    _arrowBottomView.hidden = _arrowOnTop;
}

#pragma mark -

- (void)buttonPressed:(TGMenuButtonView *)buttonView
{
    NSInteger index = -1;
    for (TGMenuButtonView *listButtonView in _buttonViews)
    {
        index++;
        
        if (listButtonView == buttonView)
        {
            buttonView.selected = true;
            
            if (index < (NSInteger)_buttonDescriptions.count)
            {
                NSString *action = [[_buttonDescriptions objectAtIndex:index] objectForKey:@"action"];
                NSMutableDictionary *options = [[NSMutableDictionary alloc] init];
                options[@"action"] = action;
                if (_userInfo != nil)
                    options[@"userInfo"] = _userInfo;
                [_watcherHandle requestAction:@"menuAction" options:options];
            }
            
            if ([self.superview isKindOfClass:[TGMenuContainerView class]])
                [(TGMenuContainerView *)self.superview hideMenu];
            
            break;
        }
    }
}

@end

#pragma mark -

@interface TGMenuContainerView ()

@end

@implementation TGMenuContainerView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self != nil)
    {
        _menuView = [[TGMenuView alloc] init];
        [self addSubview:_menuView];
    }
    return self;
}

- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event
{
    UIView *result = [super hitTest:point withEvent:event];
    if (result == self || result == nil)
    {
        [self hideMenu];
        
        return nil;
    }
    
    return result;
}

- (void)showMenuFromRect:(CGRect)rect
{
    [self showMenuFromRect:rect animated:true];
}

- (void)showMenuFromRect:(CGRect)rect animated:(bool)animated
{
    _isShowingMenu = true;
    _showingMenuFromRect = rect;
    [_menuView showInView:self fromRect:rect animated:animated];
}

- (void)setFrame:(CGRect)frame
{
    if (!CGSizeEqualToSize(frame.size, self.frame.size))
        [self hideMenu];
    
    [super setFrame:frame];
}

- (void)hideMenu
{
    if (_isShowingMenu)
    {
        _isShowingMenu = false;
        _showingMenuFromRect = CGRectZero;
        
        [_menuView.watcherHandle requestAction:@"menuWillHide" options:nil];
        
        [_menuView hide:^
        {
            [self removeFromSuperview];
        }];
    }
}

@end
