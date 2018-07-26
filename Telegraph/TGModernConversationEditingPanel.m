#import "TGModernConversationEditingPanel.h"

#import <LegacyComponents/LegacyComponents.h>

#import <LegacyComponents/TGModernButton.h>

#import "TGPresentation.h"

@interface TGModernConversationEditingPanel ()
{
    UIEdgeInsets _safeAreaInset;
 
    UIButton *_reportButton;
    UIButton *_deleteButton;
    UIButton *_forwardButton;
    UIButton *_shareButton;
    
    CALayer *_stripeLayer;
}

@end

@implementation TGModernConversationEditingPanel

- (CGFloat)baseHeight
{
    static CGFloat value = 0.0f;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^
    {
        value = UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone ? 45.0f : 56.0f;
    });
    
    return value;
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:CGRectMake(frame.origin.x, frame.origin.y, frame.size.width, [self baseHeight])];
    if (self)
    {
        self.backgroundColor = UIColorRGB(0xf7f7f7);
        
        _stripeLayer = [[CALayer alloc] init];
        _stripeLayer.backgroundColor = UIColorRGB(0xb2b2b2).CGColor;
        [self.layer addSublayer:_stripeLayer];
        
        _deleteButton = [[TGModernButton alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 52.0f, [self baseHeight])];
        _deleteButton.adjustsImageWhenDisabled = false;
        _deleteButton.adjustsImageWhenHighlighted = false;
        [_deleteButton addTarget:self action:@selector(deleteButtonPressed) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:_deleteButton];
        
        _reportButton = [[TGModernButton alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 52.0f, [self baseHeight])];
        _reportButton.adjustsImageWhenDisabled = false;
        _reportButton.adjustsImageWhenHighlighted = false;
        [_reportButton addTarget:self action:@selector(reportButtonPressed) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:_reportButton];
        
        _forwardButton = [[TGModernButton alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 56.0f, [self baseHeight])];
        _forwardButton.adjustsImageWhenDisabled = false;
        _forwardButton.adjustsImageWhenHighlighted = false;
        [_forwardButton addTarget:self action:@selector(forwardButtonPressed) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:_forwardButton];
        
        _shareButton = [[TGModernButton alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 56.0f, [self baseHeight])];
        _shareButton.adjustsImageWhenDisabled = false;
        _shareButton.adjustsImageWhenHighlighted = false;
        [_shareButton addTarget:self action:@selector(shareButtonPressed) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:_shareButton];
    }
    return self;
}

- (void)setPresentation:(TGPresentation *)presentation
{
    [super setPresentation:presentation];
    
    self.backgroundColor = presentation.pallete.barBackgroundColor;
    _stripeLayer.backgroundColor = presentation.pallete.barSeparatorColor.CGColor;
    
    [_reportButton setImage:presentation.images.chatTitleReportIcon forState:UIControlStateNormal];
    
    [_deleteButton setImage:presentation.images.chatEditDeleteIcon forState:UIControlStateNormal];
    [_deleteButton setImage:presentation.images.chatEditDeleteDisabledIcon forState:UIControlStateDisabled];
    
    [_forwardButton setImage:presentation.images.chatEditForwardIcon forState:UIControlStateNormal];
    [_forwardButton setImage:presentation.images.chatEditForwardDisabledIcon forState:UIControlStateDisabled];
    
    [_shareButton setImage:presentation.images.chatEditShareIcon forState:UIControlStateNormal];
    [_shareButton setImage:presentation.images.chatEditShareDisabledIcon forState:UIControlStateDisabled];
}

- (void)setReportingEnabled:(bool)reportingEnabled
{
    _reportButton.hidden = !reportingEnabled;
    [self setNeedsLayout];
}

- (void)setForwardingEnabled:(bool)forwardingEnabled
{
    _forwardButton.hidden = !forwardingEnabled;
}

- (void)setDeleteEnabled:(bool)deleteEnabled {
    _deleteButton.hidden = !deleteEnabled;
}

- (void)setShareEnabled:(bool)shareEnabled
{
    _shareButton.hidden = !shareEnabled;
}

- (void)setActionsEnabled:(bool)actionsEnabled
{
    _deleteButton.enabled = actionsEnabled;
    _reportButton.enabled = actionsEnabled;
    _forwardButton.enabled = actionsEnabled;
    _shareButton.enabled = actionsEnabled;
}

- (void)adjustForSize:(CGSize)size keyboardHeight:(CGFloat)keyboardHeight duration:(NSTimeInterval)duration animationCurve:(int)animationCurve contentAreaHeight:(CGFloat)contentAreaHeight safeAreaInset:(UIEdgeInsets)safeAreaInset
{
    [self _adjustForSize:size keyboardHeight:keyboardHeight duration:duration animationCurve:animationCurve contentAreaHeight:contentAreaHeight safeAreaInset:safeAreaInset];
}

- (void)_adjustForSize:(CGSize)size keyboardHeight:(CGFloat)keyboardHeight duration:(NSTimeInterval)duration animationCurve:(int)animationCurve contentAreaHeight:(CGFloat)__unused contentAreaHeight safeAreaInset:(UIEdgeInsets)safeAreaInset
{
    _safeAreaInset = safeAreaInset;
    
    dispatch_block_t block = ^
    {
        CGSize messageAreaSize = size;
        
        self.frame = CGRectMake(0, messageAreaSize.height - keyboardHeight - [self baseHeight] - safeAreaInset.bottom, messageAreaSize.width, [self baseHeight] + safeAreaInset.bottom);
        [self layoutSubviews];
    };
    
    if (duration > DBL_EPSILON)
        [UIView animateWithDuration:duration delay:0 options:animationCurve << 16 animations:block completion:nil];
    else
        block();
}

- (void)changeToSize:(CGSize)size keyboardHeight:(CGFloat)keyboardHeight duration:(NSTimeInterval)duration contentAreaHeight:(CGFloat)contentAreaHeight safeAreaInset:(UIEdgeInsets)safeAreaInset
{
    [self _adjustForSize:size keyboardHeight:keyboardHeight duration:duration animationCurve:0 contentAreaHeight:contentAreaHeight safeAreaInset:safeAreaInset];
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    _stripeLayer.frame = CGRectMake(0.0f, -TGRetinaPixel, self.frame.size.width, TGRetinaPixel);
    
    if (_deleteButton.hidden && !_reportButton.hidden)
    {
        _reportButton.frame = CGRectMake(_safeAreaInset.left, 0.0f, 56.0f, [self baseHeight]);
        _shareButton.frame = CGRectMake(floor((self.frame.size.width - 56.0f) / 2.0f), 0.0f, 56.0f, [self baseHeight]);
        _forwardButton.frame = CGRectMake(self.frame.size.width - 56.0f - _safeAreaInset.right, 0.0f, 56.0f, [self baseHeight]);
    }
    else
    {
        if (_reportButton.hidden)
        {
            _deleteButton.frame = CGRectMake(_safeAreaInset.left, 0.0f, 56.0f, [self baseHeight]);
            _shareButton.frame = CGRectMake(floor((self.frame.size.width - 56.0f) / 2.0f), 0.0f, 56.0f, [self baseHeight]);
            _forwardButton.frame = CGRectMake(self.frame.size.width - 56.0f - _safeAreaInset.right, 0.0f, 56.0f, [self baseHeight]);
        }
        else
        {
            CGFloat spacing = (self.frame.size.width - _safeAreaInset.left - _safeAreaInset.right - 56.0f) / 5.0f;
            
            _deleteButton.frame = CGRectMake(_safeAreaInset.left, 0.0f, 56.0f, [self baseHeight]);
            _reportButton.frame = CGRectMake(floor((self.frame.size.width - 56.0f) / 2.0f) - spacing, 0.0f, 56.0f, [self baseHeight]);
            _shareButton.frame = CGRectMake(floor((self.frame.size.width - 56.0f) / 2.0f) + spacing, 0.0f, 56.0f, [self baseHeight]);
            _forwardButton.frame = CGRectMake(self.frame.size.width - 56.0f - _safeAreaInset.right, 0.0f, 56.0f, [self baseHeight]);
        }
    }
}

#pragma mark -

- (void)deleteButtonPressed
{
    id<TGModernConversationEditingPanelDelegate> delegate = (id<TGModernConversationEditingPanelDelegate>)self.delegate;
    if ([delegate respondsToSelector:@selector(editingPanelRequestedDeleteMessages:)])
        [delegate editingPanelRequestedDeleteMessages:self];
}

- (void)reportButtonPressed
{
    id<TGModernConversationEditingPanelDelegate> delegate = (id<TGModernConversationEditingPanelDelegate>)self.delegate;
    if ([delegate respondsToSelector:@selector(editingPanelRequestedReportMessages:)])
        [delegate editingPanelRequestedReportMessages:self];
}

- (void)forwardButtonPressed
{
    id<TGModernConversationEditingPanelDelegate> delegate = (id<TGModernConversationEditingPanelDelegate>)self.delegate;
    if ([delegate respondsToSelector:@selector(editingPanelRequestedForwardMessages:)])
        [delegate editingPanelRequestedForwardMessages:self];
}

- (void)shareButtonPressed
{
    id<TGModernConversationEditingPanelDelegate> delegate = (id<TGModernConversationEditingPanelDelegate>)self.delegate;
    if ([delegate respondsToSelector:@selector(editingPanelRequestedShareMessages:)])
        [delegate editingPanelRequestedShareMessages:self];
}

@end
