#import "TGSwitchView.h"

@interface TGSwitchView ()

@property (nonatomic, strong) UIImageView *backgroundView;

@property (nonatomic, strong) UIView *foregroundContainer;
@property (nonatomic, strong) UIImageView *foregroundView;

@property (nonatomic, strong) UIView *textContainer;
@property (nonatomic, strong) UIImageView *onTextView;
@property (nonatomic, strong) UIImageView *offTextView;

@property (nonatomic, strong) UIImageView *shadowView;
@property (nonatomic, strong) UIImageView *maskView;

@property (nonatomic, strong) UIImageView *handleView;
@property (nonatomic, strong) UIImageView *transitionView;

@property (nonatomic, strong) UIPanGestureRecognizer *panRecognizer;
@property (nonatomic) bool gestureInProgress;

@property (nonatomic) CGFloat initialHandlePosition;
@property (nonatomic) CGFloat initialHandleTouchPosition;
@property (nonatomic) CGFloat onHandlePosition;

@end

@implementation TGSwitchView

- (id)init
{
    return [self initWithFrame:CGRectMake(0, 0, 77, 27)];
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
    {
        self.exclusiveTouch = true;
        self.multipleTouchEnabled = false;
        
        _backgroundView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 77, 27)];
        _backgroundView.image = [UIImage imageNamed:@"SwitchBackground.png"];
        [self addSubview:_backgroundView];
        
        _foregroundContainer = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 13, 27)];
        _foregroundContainer.clipsToBounds = true;
        [self addSubview:_foregroundContainer];
        
        _foregroundView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"SwitchBlue.png"]];
        [_foregroundContainer addSubview:_foregroundView];
        
        _textContainer = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 77, 27)];
        _textContainer.clipsToBounds = true;
        [self addSubview:_textContainer];
        
        _onTextView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"SwitchOnText.png"]];
        [_textContainer addSubview:_onTextView];
        
        _offTextView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"SwitchOffText.png"]];
        [_textContainer addSubview:_offTextView];
        
        UIView *transitionContainer = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 77 - 7, 27)];
        transitionContainer.clipsToBounds = true;
        [self addSubview:transitionContainer];
        
        _transitionView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"SwitchBlueTransition.png"]];
        [transitionContainer addSubview:_transitionView];
        
        _shadowView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 77, 27)];
        _shadowView.image = [UIImage imageNamed:@"SwitchShadow.png"];
        [self addSubview:_shadowView];
        
        UIImage *rawMaskImage = [UIImage imageNamed:@"SwitchMask.png"];
        _maskView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 77, 27)];
        _maskView.image = [rawMaskImage stretchableImageWithLeftCapWidth:(int)(rawMaskImage.size.width / 2) topCapHeight:0];
        [self addSubview:_maskView];
        
        _handleView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"SwitchBulb.png"] highlightedImage:[UIImage imageNamed:@"SwitchBulb_Highlighted.png"]];
        [self addSubview:_handleView];
        
        _onHandlePosition = 77 - _handleView.frame.size.width + 2;
        
        [self setHandlePosition:-1];
        [self updateBlueVisibility];
        
        _panRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panGestureRecognized:)];
        [self addGestureRecognizer:_panRecognizer];
        [self addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapGestureRecognized:)]];
    }
    return self;
}

- (void)setOn:(bool)on animated:(bool)animated
{
    [self setOn:on duration:animated ? 0.25 : 0 notifyDelegate:false];
}

- (void)setOn:(bool)on animated:(bool)animated notifyOnCompletion:(bool)notifyOnCompletion
{
    [self setOn:on duration:animated ? 0.25 : 0 notifyDelegate:notifyOnCompletion];
}

- (void)setOn:(bool)on duration:(NSTimeInterval)duration notifyDelegate:(bool)notifyDelegate
{
    _isOn = on;
    
    CGFloat handlePosition = !on ? -1 : _onHandlePosition;
    
    if (duration > DBL_EPSILON)
    {
        if (handlePosition > -1 + FLT_EPSILON)
            [self updateBlueVisibility:true];
        
        [UIView animateWithDuration:duration animations:^
        {
            [self setHandlePosition:handlePosition];
        } completion:^(BOOL finished)
        {
            if (finished)
            {
                [self updateBlueVisibility];
                if (notifyDelegate)
                    [self _notifyDelegate];
            }
        }];
    }
    else
    {
        [self setHandlePosition:handlePosition];
        [self updateBlueVisibility];
    }
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    _handleView.highlighted = true;
    
    UITouch *touch = [touches anyObject];
    _initialHandleTouchPosition = [touch locationInView:self].x;
    
    [super touchesBegan:touches withEvent:event];
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    if (!_gestureInProgress)
        _handleView.highlighted = false;
    
    [super touchesEnded:touches withEvent:event];
}

- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event
{
    if (!_gestureInProgress)
        _handleView.highlighted = false;
    
    [super touchesCancelled:touches withEvent:event];
}

- (void)setHandlePosition:(CGFloat)position
{
    _handleView.frame = CGRectMake(position, -1, _handleView.frame.size.width, _handleView.frame.size.height);
    _transitionView.frame = _handleView.frame;
    _foregroundContainer.frame = CGRectMake(0, 0, _handleView.frame.origin.x + 14, 27);
    
    _onTextView.frame = CGRectMake(position - _onTextView.frame.size.width - 9, 7, _onTextView.frame.size.width, _onTextView.frame.size.height);
    _offTextView.frame = CGRectMake(position + _handleView.frame.size.width + 6, 7, _offTextView.frame.size.width, _offTextView.frame.size.height);
}

- (void)panGestureRecognized:(UIPanGestureRecognizer *)recognizer
{
    if (recognizer.state == UIGestureRecognizerStateBegan)
    {
        _gestureInProgress = true;
        
        _handleView.highlighted = true;
        
        _initialHandlePosition = _handleView.frame.origin.x;
    }
    else if (recognizer.state == UIGestureRecognizerStateChanged)
    {
        _gestureInProgress = true;
        
        CGFloat translation = [recognizer translationInView:self].x + _initialHandlePosition;
        translation = MAX(0, MIN(translation, _onHandlePosition));
        [self setHandlePosition:translation - 1];
        [self updateBlueVisibility];
    }
    else if (recognizer.state == UIGestureRecognizerStateEnded || recognizer.state == UIGestureRecognizerStateCancelled)
    {
        _gestureInProgress = false;
        _handleView.highlighted = false;
        
        if (recognizer.state == UIGestureRecognizerStateEnded)
        {
            bool isOn = _handleView.frame.origin.x > (-1 + _onHandlePosition) / 2;
            [self setOn:isOn duration:0.1 notifyDelegate:isOn != _isOn];
        }
        else
        {
            [self setOn:_isOn duration:0.1 notifyDelegate:false];
        }
    }
}

- (void)tapGestureRecognized:(UITapGestureRecognizer *)recognizer
{
    if (recognizer.state == UIGestureRecognizerStateRecognized)
    {
        [self setOn:!_isOn duration:0.25 notifyDelegate:true];
    }
}

- (void)updateBlueVisibility
{
    [self updateBlueVisibility:_handleView.frame.origin.x > 0 - FLT_EPSILON];
}

- (void)updateBlueVisibility:(bool)visible
{
    _foregroundView.alpha = visible ? 1.0f : 0.0f;
    _transitionView.alpha = _foregroundView.alpha;
}

- (void)_notifyDelegate
{
    __strong id<TGSwitchViewDelegate> delegate = _delegate;
    [delegate switchView:self didChangeIsOn:_isOn];
}

@end
