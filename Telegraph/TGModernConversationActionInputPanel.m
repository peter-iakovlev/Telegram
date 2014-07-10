#import "TGModernConversationActionInputPanel.h"

#import "TGImageUtils.h"
#import "TGViewController.h"

#import "TGModernButton.h"

#import "ASHandle.h"

@interface TGModernConversationActionInputPanel ()
{
    NSString *_action;
    
    CALayer *_stripeLayer;
    TGModernButton *_actionButton;
}

@end

@implementation TGModernConversationActionInputPanel

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
        
        _actionButton = [[TGModernButton alloc] initWithFrame:CGRectZero];
        _actionButton.adjustsImageWhenDisabled = false;
        _actionButton.adjustsImageWhenHighlighted = false;
        [_actionButton setTitleColor:TGDestructiveAccentColor()];
        [_actionButton addTarget:self action:@selector(actionButtonPressed) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:_actionButton];
    }
    return self;
}

- (void)setActionWithTitle:(NSString *)title action:(NSString *)action
{
    _action = action;
    
    [_actionButton setTitle:title forState:UIControlStateNormal];
}

- (void)adjustForOrientation:(UIInterfaceOrientation)orientation keyboardHeight:(float)keyboardHeight duration:(NSTimeInterval)duration animationCurve:(int)animationCurve
{
    [self _adjustForOrientation:orientation keyboardHeight:keyboardHeight duration:duration animationCurve:animationCurve];
}

- (void)_adjustForOrientation:(UIInterfaceOrientation)orientation keyboardHeight:(float)keyboardHeight duration:(NSTimeInterval)duration animationCurve:(int)animationCurve
{
    dispatch_block_t block = ^
    {
        id<TGModernConversationInputPanelDelegate> delegate = self.delegate;
        CGSize messageAreaSize = [delegate messageAreaSizeForInterfaceOrientation:orientation];
        
        self.frame = CGRectMake(0, messageAreaSize.height - keyboardHeight - [self baseHeight], messageAreaSize.width, [self baseHeight]);
        [self layoutSubviews];
    };
    
    if (duration > DBL_EPSILON)
        [UIView animateWithDuration:duration delay:0 options:animationCurve << 16 animations:block completion:nil];
    else
        block();
}

- (void)changeOrientationToOrientation:(UIInterfaceOrientation)orientation keyboardHeight:(float)keyboardHeight duration:(NSTimeInterval)duration
{
    [self _adjustForOrientation:orientation keyboardHeight:keyboardHeight duration:duration animationCurve:0];
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    _stripeLayer.frame = CGRectMake(0.0f, -TGRetinaPixel, self.frame.size.width, TGRetinaPixel);
    _actionButton.frame = CGRectMake(0.0f, 0.0f, self.frame.size.width, self.frame.size.height);
}

- (void)actionButtonPressed
{
    if (_action != nil)
        [_companionHandle requestAction:@"actionPanelAction" options:@{@"action": _action}];
}

@end
