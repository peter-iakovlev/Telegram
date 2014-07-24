#import "TGModernGalleryInterfaceView.h"

#import "TGModernBackToolbarButton.h"

#import "TGFont.h"

@interface TGModernGalleryInterfaceView ()
{
    TGModernBackToolbarButton *_closeButton;
    UILabel *_titleLabel;
    NSMutableArray *_itemHeaderViews;
    NSMutableArray *_itemFooterViews;
    
    TGModernButton *_leftButton;
    TGModernButton *_rightButton;
}

@end

@implementation TGModernGalleryInterfaceView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self != nil)
    {
        _itemHeaderViews = [[NSMutableArray alloc] init];
        _itemFooterViews = [[NSMutableArray alloc] init];
        
        _navigationBarView = [[UIView alloc] initWithFrame:[self navigationBarFrameForSize:frame.size]];
        _navigationBarView.backgroundColor = UIColorRGBA(0x000000, 0.65f);
        [self addSubview:_navigationBarView];
        
        _toolbarView = [[UIView alloc] initWithFrame:[self toolbarFrameForSize:frame.size]];
        _toolbarView.backgroundColor = UIColorRGBA(0x000000, 0.65f);
        [self addSubview:_toolbarView];
        
        _closeButton = [[TGModernBackToolbarButton alloc] init];
        [_closeButton sizeToFit];
        [_closeButton addTarget:self action:@selector(closeButtonPressed) forControlEvents:UIControlEventTouchUpInside];
        _closeButton.frame = [self closeButtonFrameForSize:frame.size];
        [_navigationBarView addSubview:_closeButton];
        
        _titleLabel = [[UILabel alloc] init];
        _titleLabel.font = TGMediumSystemFontOfSize(17);
        _titleLabel.textColor = [UIColor whiteColor];
        _titleLabel.backgroundColor = [UIColor clearColor];
        [_navigationBarView addSubview:_titleLabel];
        _titleLabel.frame = [self titleFrameForSize:frame.size];
        
        UIImage *actionImage = [UIImage imageNamed:@"ActionsWhiteIcon.png"];
        _leftButton = [[TGModernButton alloc] init];
        _leftButton.modernHighlight = true;
        _leftButton.exclusiveTouch = true;
        [_leftButton setImage:actionImage forState:UIControlStateNormal];
        //[_leftButton addTarget:self action:@selector(actionButtonPressed) forControlEvents:UIControlEventTouchUpInside];
        _leftButton.frame = [self toolbarLeftButtonFrameForSize:frame.size];
        [_toolbarView addSubview:_leftButton];
    
        UIImage *deleteImage = [UIImage imageNamed:@"DeleteWhiteIcon.png"];
        _rightButton = [[TGModernButton alloc] init];
        _rightButton.modernHighlight = true;
        _rightButton.exclusiveTouch = true;
        [_rightButton setImage:deleteImage forState:UIControlStateNormal];
        //[_rightButton addTarget:self action:@selector(deleteButtonPressed) forControlEvents:UIControlEventTouchUpInside];
        _rightButton.frame = [self toolbarRightButtonFrameForSize:frame.size];
        [_toolbarView addSubview:_rightButton];
    }
    return self;
}

- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event
{
    UIView *view = [super hitTest:point withEvent:event];
    
    if ([view isDescendantOfView:_navigationBarView] || [view isDescendantOfView:_toolbarView])
        return view;
    
    return nil;
}

- (CGRect)navigationBarFrameForSize:(CGSize)size
{
    return CGRectMake(0.0f, 0.0f, size.width, 20.0f + 44.0f);
}

- (CGRect)toolbarFrameForSize:(CGSize)size
{
    return CGRectMake(0.0f, size.height - 44.0f, size.width, 44.0f);
}

- (CGRect)itemHeaderViewFrameForSize:(CGSize)size
{
    CGFloat closeButtonMaxX = CGRectGetMaxX([self closeButtonFrameForSize:size]);
    CGFloat spacing = 10.0f;
    CGFloat padding = 4.0f;
    return CGRectMake(closeButtonMaxX + spacing, 20.0f, size.width - (closeButtonMaxX + spacing) - padding, 44.0f);
}

- (CGRect)itemFooterViewFrameForSize:(CGSize)size
{
    CGFloat padding = 44.0f;
    
    return CGRectMake(padding, 0.0f, size.width - padding * 2.0f, 44.0f);
}

- (CGRect)closeButtonFrameForSize:(CGSize)__unused size
{
    return (CGRect){{10.0f, 17.0f + 12.0f}, _closeButton.frame.size};
}

- (CGRect)titleFrameForSize:(CGSize)__unused size
{
    [_titleLabel sizeToFit];
    return CGRectMake(CGFloor((size.width - _titleLabel.frame.size.width) / 2.0f), 20.0f + CGFloor((44.0f - _titleLabel.frame.size.height) / 2.0f), _titleLabel.frame.size.width, _titleLabel.frame.size.height);
}

- (CGRect)toolbarLeftButtonFrameForSize:(CGSize)__unused size
{
    return CGRectMake(0.0f, 0.0f, 44.0f, 44.0f);
}

- (CGRect)toolbarRightButtonFrameForSize:(CGSize)size
{
    return CGRectMake(size.width - 44.0f, 0.0f, 44.0f, 44.0f);
}

- (void)setFrame:(CGRect)frame
{
    [super setFrame:frame];
    
    _navigationBarView.frame = [self navigationBarFrameForSize:frame.size];
    _toolbarView.frame = [self toolbarFrameForSize:frame.size];
    
    CGRect itemHeaderViewFrame = [self itemHeaderViewFrameForSize:frame.size];
    for (UIView *itemHeaderView in _itemHeaderViews)
    {
        itemHeaderView.frame = itemHeaderViewFrame;
    }
    
    CGRect itemFooterViewFrame = [self itemFooterViewFrameForSize:frame.size];
    for (UIView *itemFooterView in _itemFooterViews)
    {
        itemFooterView.frame = itemFooterViewFrame;
    }
    
    _closeButton.frame = [self closeButtonFrameForSize:frame.size];
    _titleLabel.frame = [self titleFrameForSize:frame.size];
    
    _leftButton.frame = [self toolbarLeftButtonFrameForSize:frame.size];
    _rightButton.frame = [self toolbarRightButtonFrameForSize:frame.size];
}

- (void)addItemHeaderView:(UIView *)itemHeaderView
{
    if (itemHeaderView == nil)
        return;
    
    [_itemHeaderViews addObject:itemHeaderView];
    [_navigationBarView insertSubview:itemHeaderView belowSubview:_titleLabel];
    itemHeaderView.frame = [self itemHeaderViewFrameForSize:self.frame.size];
}

- (void)removeItemHeaderView:(UIView *)itemHeaderView
{
    if (itemHeaderView == nil)
        return;
    
    [itemHeaderView removeFromSuperview];
    [_itemHeaderViews removeObject:itemHeaderView];
}

- (void)addItemFooterView:(UIView *)itemFooterView
{
    if (itemFooterView == nil)
        return;
    
    [_itemFooterViews addObject:itemFooterView];
    [_toolbarView addSubview:itemFooterView];
    itemFooterView.frame = [self itemFooterViewFrameForSize:self.frame.size];
}

- (void)removeItemFooterView:(UIView *)itemFooterView
{
    if (itemFooterView == nil)
        return;
    
    [itemFooterView removeFromSuperview];
    [_itemFooterViews removeObject:itemFooterView];
}

- (void)setTitle:(NSString *)title
{
    _titleLabel.text = title;
    _titleLabel.frame = [self titleFrameForSize:self.frame.size];
}

- (void)setTitleAlpha:(CGFloat)titleAlpha
{
    _titleLabel.alpha = titleAlpha;
}

- (void)animateTransitionInWithDuration:(NSTimeInterval)dutation
{
    [UIView animateWithDuration:dutation animations:^
    {
        //_navigationBarView.frame = CGRectOffset(_navigationBarView.frame, 0.0f, -_navigationBarView.frame.size.height);
        //_toolbarView.frame = CGRectOffset(_toolbarView.frame, 0.0f, _toolbarView.frame.size.height);
    }];
}

- (void)animateTransitionOutWithDuration:(NSTimeInterval)dutation
{
    [UIView animateWithDuration:dutation animations:^
    {
        //_navigationBarView.frame = CGRectOffset(_navigationBarView.frame, 0.0f, -_navigationBarView.frame.size.height);
        //_toolbarView.frame = CGRectOffset(_toolbarView.frame, 0.0f, _toolbarView.frame.size.height);
    }];
}

- (void)closeButtonPressed
{
    if (_closePressed)
        _closePressed();
}

@end
