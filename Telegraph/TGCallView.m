#import "TGCallView.h"

#import "TGImageUtils.h"
#import "TGFont.h"

#import "TGWallpaperManager.h"
#import "TGWallpaperInfo.h"
#import "TGBuiltinWallpaperInfo.h"

#import "TGDefaultPasscodeBackground.h"
#import "TGImageBasedPasscodeBackground.h"

#import "UIControl+HitTestEdgeInsets.h"
#import "TGModernButton.h"
#import "TGCallInfoView.h"
#import "TGCallAvatarView.h"
#import "TGCallButtonsView.h"
#import "TGCallBackgroundView.h"
#import "TGCallIdenticonView.h"
#import "TGCallEncryptionKeyView.h"

#import "TGCallSession.h"

@interface TGCallView ()
{
    UIImage *_backgroundImage;
    TGCallBackgroundView *_backgroundView;
    
    TGModernButton *_backButton;
    TGModernButton *_keyButton;
    TGCallIdenticonView *_identiconView;
    TGCallInfoView *_infoView;
    TGCallButtonsView *_buttonsView;
    
    TGCallEncryptionKeyView *_keyView;
    
    TGCallState _currentState;
    
    UIScreenEdgePanGestureRecognizer *_gestureRecognizer;
}
@end

@implementation TGCallView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self != nil)
    {
        __weak TGCallView *weakSelf = self;
        
        _backgroundView = [[TGCallBackgroundView alloc] init];
        _backgroundView.imageChanged = ^(UIImage *image)
        {
            __strong TGCallView *strongSelf = weakSelf;
            if (strongSelf != nil)
            {
                strongSelf->_backgroundImage = image;
                [strongSelf _updateBackground];
            }
        };
        [self addSubview:_backgroundView];
        
        _infoView = [[TGCallInfoView alloc] init];
        [self addSubview:_infoView];
        
        _buttonsView = [[TGCallButtonsView alloc] init];
        _buttonsView.mutePressed = ^
        {
            __strong TGCallView *strongSelf = weakSelf;
            if (strongSelf != nil && strongSelf.mutePressed != nil)
                strongSelf.mutePressed();
        };
        _buttonsView.messagePressed = ^
        {
            __strong TGCallView *strongSelf = weakSelf;
            if (strongSelf != nil && strongSelf.messagePressed != nil)
                strongSelf.messagePressed();
        };
        _buttonsView.speakerPressed = ^
        {
            __strong TGCallView *strongSelf = weakSelf;
            if (strongSelf != nil && strongSelf.speakerPressed != nil)
                strongSelf.speakerPressed();
        };
        _buttonsView.declinePressed = ^
        {
            __strong TGCallView *strongSelf = weakSelf;
            if (strongSelf != nil && strongSelf.declinePressed != nil)
                strongSelf.declinePressed();
        };
        _buttonsView.callPressed = ^
        {
            __strong TGCallView *strongSelf = weakSelf;
            if (strongSelf != nil && strongSelf.callPressed != nil)
                strongSelf.callPressed();
        };
        [self addSubview:_buttonsView];
        
        _keyView = [[TGCallEncryptionKeyView alloc] init];
        _keyView.hidden = true;
        _keyView.backPressed = ^
        {
            __strong TGCallView *strongSelf = weakSelf;
            if (strongSelf != nil)
                [strongSelf closeKeyView];
        };
        [self addSubview:_keyView];
        
        _backButton = [[TGModernButton alloc] initWithFrame:CGRectZero];
        _backButton.exclusiveTouch = true;
        _backButton.hitTestEdgeInsets = UIEdgeInsetsMake(-5, -20, -5, -5);
        _backButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
        _backButton.titleLabel.textAlignment = NSTextAlignmentLeft;
        _backButton.titleLabel.font = TGSystemFontOfSize(17);
        [_backButton setTitle:TGLocalized(@"Common.Back") forState:UIControlStateNormal];
        [_backButton setTitleColor:[UIColor whiteColor]];
        [_backButton addTarget:self action:@selector(backButtonPressed) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:_backButton];
        
        UIImageView *arrowView = [[UIImageView alloc] initWithFrame:CGRectMake(-19, 5.5f, 13, 22)];
        arrowView.image = [UIImage imageNamed:@"NavigationBackArrow"];
        [_backButton addSubview:arrowView];
        
        _keyButton = [[TGModernButton alloc] initWithFrame:CGRectMake(0, 0, 44.0f, 44.0f)];
        _keyButton.hidden = true;
        [_keyButton addTarget:self action:@selector(keyButtonPressed) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:_keyButton];
        
        _identiconView = [[TGCallIdenticonView alloc] initWithFrame:CGRectMake(10.0f, 10.0f, 24.0f, 24.0f)];
        [_keyButton addSubview:_identiconView];
        
        _keyView.identiconView = _identiconView;
        
        _gestureRecognizer = [[UIScreenEdgePanGestureRecognizer alloc] initWithTarget:self action:@selector(handleEdgePan:)];
        _gestureRecognizer.edges = UIRectEdgeLeft;
        [self addGestureRecognizer:_gestureRecognizer];
    }
    return self;
}

- (void)setState:(TGCallSessionState *)state duration:(NSTimeInterval)duration
{
    [_backgroundView setState:state];
    [_infoView setState:state duration:duration];
    [_buttonsView setState:state];
    [_keyView setState:state duration:duration];
    
    TGCallState previousState = _currentState;
    _currentState = state.state;
    
    if (previousState != _currentState)
    {
        bool animated = state.state == TGCallStateAccepting && previousState == TGCallStateReady;
     
        _keyButton.hidden = (_currentState != TGCallStateOngoing);
        _backButton.hidden = (_currentState == TGCallStateHandshake || _currentState == TGCallStateReady) || ((_currentState == TGCallStateEnded || _currentState == TGCallStateEnding || _currentState == TGCallStateBusy) && duration < DBL_EPSILON && !state.outgoing);
        _backButton.alpha = (_currentState == TGCallStateEnding || _currentState == TGCallStateEnded || _currentState == TGCallStateBusy) ? 0.5f : 1.0f;
        
        if (state.keySha1 != nil)
            [_identiconView setSha1:state.keySha1 sha256:state.keySha256];
        
        if (animated)
        {
            [UIView animateWithDuration:0.3 delay:0.0 options:7 << 16 animations:^
            {
                [self layoutSubviews];
            } completion:nil];
        }
        else
        {
            [self setNeedsLayout];
        }
    }
}

- (void)setLevel:(CGFloat)__unused level
{

}

- (void)onPause
{
    [_infoView onPause];
}

- (void)onResume
{
    [_infoView onResume];
}

- (void)setFrame:(CGRect)frame
{    
    [super setFrame:frame];
    
    [self _updateBackground];
}

- (void)_updateBackground
{
    NSObject<TGPasscodeBackground> *background;
    if (_backgroundImage != nil)
        background = [[TGImageBasedPasscodeBackground alloc] initWithImage:_backgroundImage size:self.frame.size];
    else
        background = [[TGDefaultPasscodeBackground alloc] initWithSize:self.frame.size];
    
    [_buttonsView setBackground:background];
}

- (void)backButtonPressed
{
    if (self != nil && self.messagePressed != nil)
        self.messagePressed();
}

- (void)keyButtonPressed
{
    [_keyView present];
    
    _backButton.hidden = true;
    
    [UIView animateWithDuration:0.3 animations:^
    {
        _infoView.alpha = 0.0f;
        _buttonsView.alpha = 0.0f;
    } completion:^(__unused BOOL finished)
    {
        _infoView.hidden = true;
        _keyButton.hidden = true;
        _buttonsView.hidden = true;
    }];
}

- (void)closeKeyView
{
    [_keyView dismiss];
    
    _backButton.hidden = false;
    
    _infoView.hidden = false;
    _keyButton.hidden = false;
    _buttonsView.hidden = false;
    
    [UIView animateWithDuration:0.3 animations:^
    {
        _infoView.alpha = 1.0f;
        _buttonsView.alpha = 1.0f;
    } completion:^(__unused BOOL finished)
    {

    }];
}

- (void)handleEdgePan:(UIScreenEdgePanGestureRecognizer *)gestureRecognizer
{
    switch (gestureRecognizer.state)
    {
        case UIGestureRecognizerStateBegan:
            
            break;
            
        case UIGestureRecognizerStateChanged:
            
            break;
            
        case UIGestureRecognizerStateEnded:
            
            break;
            
        default:
            break;
    }
}

+ (CGFloat)infoTopOffset
{
    static dispatch_once_t onceToken;
    static CGFloat offset;
    dispatch_once(&onceToken, ^
    {
        CGSize screenSize = TGScreenSize();
        int width = (int)screenSize.width;
        int height = (int)screenSize.height;
        if (height == 736)
            offset = 80; //plus
        else if (width == 320)
            offset = 60; // 4/5
        else
            offset = 64; // 6/7
    });
    return offset;
}

+ (CGFloat)buttonsTopOffset
{
    static dispatch_once_t onceToken;
    static CGFloat offset;
    dispatch_once(&onceToken, ^
    {
        CGSize screenSize = TGScreenSize();
        int height = (int)screenSize.height;
        if (height == 736)
            offset = 410;
        else if (height == 480)
            offset = 270;
        else if (height == 568)
            offset = 306;
        else
            offset = 385;
    });
    return offset;
}

- (void)layoutSubviews
{
    _backgroundView.frame = self.bounds;
    _keyView.frame = self.bounds;
    
    [_backButton sizeToFit];
    _backButton.frame = CGRectMake(27, 25.5f, ceil(_backButton.frame.size.width), ceil(_backButton.frame.size.height));
    
    _keyButton.frame = CGRectMake(self.frame.size.width - _keyButton.frame.size.width - 1.0f, 20.0f, _keyButton.frame.size.width, _keyButton.frame.size.height);
    
    _infoView.frame = CGRectMake(0, [TGCallView infoTopOffset], self.frame.size.width, TGCallInfoViewHeight);
    
    CGFloat buttonsTop = [TGCallView buttonsTopOffset];
    CGFloat buttonsWidth = [TGCallButton buttonSize].width * 3 + TGCallButtonsSpacing * 2;
    _buttonsView.frame = CGRectMake((self.frame.size.width - buttonsWidth) / 2.0f, buttonsTop, buttonsWidth, 232);
}

@end
