/*
 * This is the source code of Telegram for iOS v. 1.1
 * It is licensed under GNU GPL v. 2 or later.
 * You should have received a copy of the license in this archive (see LICENSE).
 *
 * Copyright Peter Iakovlev, 2013.
 */

#import "TGModernConversationEditingPanel.h"

#import "TGImageUtils.h"
#import "TGModernButton.h"

#import "TGViewController.h"

@interface TGModernConversationEditingPanel ()
{
    UIButton *_deleteButton;
    UIButton *_forwardButton;
    
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
        self.backgroundColor = UIColorRGBA(0xfafafa, 0.98f);
        
        _stripeLayer = [[CALayer alloc] init];
        _stripeLayer.backgroundColor = UIColorRGBA(0xb3aab2, 0.4f).CGColor;
        [self.layer addSublayer:_stripeLayer];
        
        UIImage *deleteImage = [UIImage imageNamed:@"ModernConversationActionDelete.png"];
        UIImage *deleteDisabledImage = [UIImage imageNamed:@"ModernConversationActionDelete_Disabled.png"];
        UIImage *forwardImage = [UIImage imageNamed:@"ModernConversationActionForward.png"];
        UIImage *forwardDisabledImage = [UIImage imageNamed:@"ModernConversationActionForward_Disabled.png"];
        
        _deleteButton = [[TGModernButton alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 52.0f, [self baseHeight])];
        [_deleteButton setImage:deleteImage forState:UIControlStateNormal];
        [_deleteButton setImage:deleteDisabledImage forState:UIControlStateDisabled];
        _deleteButton.adjustsImageWhenDisabled = false;
        _deleteButton.adjustsImageWhenHighlighted = false;
        [_deleteButton addTarget:self action:@selector(deleteButtonPressed) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:_deleteButton];
        
        _forwardButton = [[TGModernButton alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 56.0f, [self baseHeight])];
        [_forwardButton setImage:forwardImage forState:UIControlStateNormal];
        [_forwardButton setImage:forwardDisabledImage forState:UIControlStateDisabled];
        _forwardButton.adjustsImageWhenDisabled = false;
        _forwardButton.adjustsImageWhenHighlighted = false;
        [_forwardButton addTarget:self action:@selector(forwardButtonPressed) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:_forwardButton];
    }
    return self;
}

- (void)setForwardingEnabled:(bool)forwardingEnabled
{
    _forwardButton.hidden = !forwardingEnabled;
}

- (void)setDeleteEnabled:(bool)deleteEnabled {
    _deleteButton.hidden = !deleteEnabled;
}

- (void)setActionsEnabled:(bool)actionsEnabled
{
    _deleteButton.enabled = actionsEnabled;
    _forwardButton.enabled = actionsEnabled;
}

- (void)adjustForSize:(CGSize)size keyboardHeight:(CGFloat)keyboardHeight duration:(NSTimeInterval)duration animationCurve:(int)animationCurve
{
    [self _adjustForSize:size keyboardHeight:keyboardHeight duration:duration animationCurve:animationCurve];
}

- (void)_adjustForSize:(CGSize)size keyboardHeight:(CGFloat)keyboardHeight duration:(NSTimeInterval)duration animationCurve:(int)animationCurve
{
    dispatch_block_t block = ^
    {
        CGSize messageAreaSize = size;
        
        self.frame = CGRectMake(0, messageAreaSize.height - keyboardHeight - [self baseHeight], messageAreaSize.width, [self baseHeight]);
        [self layoutSubviews];
    };
    
    if (duration > DBL_EPSILON)
        [UIView animateWithDuration:duration delay:0 options:animationCurve << 16 animations:block completion:nil];
    else
        block();
}

- (void)changeToSize:(CGSize)size keyboardHeight:(CGFloat)keyboardHeight duration:(NSTimeInterval)duration
{
    [self _adjustForSize:size keyboardHeight:keyboardHeight duration:duration animationCurve:0];
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    _stripeLayer.frame = CGRectMake(0.0f, -TGRetinaPixel, self.frame.size.width, TGRetinaPixel);
    
    _forwardButton.frame = CGRectMake(self.frame.size.width - 56.0f, 0.0f, 56.0f, [self baseHeight]);
}

#pragma mark -

- (void)deleteButtonPressed
{
    id<TGModernConversationEditingPanelDelegate> delegate = (id<TGModernConversationEditingPanelDelegate>)self.delegate;
    if ([delegate respondsToSelector:@selector(editingPanelRequestedDeleteMessages:)])
        [delegate editingPanelRequestedDeleteMessages:self];
}

- (void)forwardButtonPressed
{
    id<TGModernConversationEditingPanelDelegate> delegate = (id<TGModernConversationEditingPanelDelegate>)self.delegate;
    if ([delegate respondsToSelector:@selector(editingPanelRequestedForwardMessages:)])
        [delegate editingPanelRequestedForwardMessages:self];
}

@end
