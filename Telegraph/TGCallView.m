#import "TGCallView.h"

#import "ActionStage.h"

#import "TGFont.h"
#import "TGImageUtils.h"
#import "TGStringUtils.h"
#import "TGTimerTarget.h"

#import "TGDefaultPasscodeBackground.h"
#import "TGImageBasedPasscodeBackground.h"

#import "UIControl+HitTestEdgeInsets.h"
#import "TGMenuView.h"
#import "TGModernButton.h"
#import "TGCallInfoView.h"
#import "TGCallAvatarView.h"
#import "TGCallButtonsView.h"
#import "TGCallBackgroundView.h"
#import "TGCallIdenticonView.h"
#import "TGCallEncryptionKeyView.h"

#import "TGModernGalleryZoomableScrollViewSwipeGestureRecognizer.h"

#import "TGCallSession.h"
#import "TGUser.h"

const CGFloat TGCallSwipeMinimumVelocity = 600.0f;
const CGFloat TGCallSwipeVelocityThreshold = 700.0f;
const CGFloat TGCallSwipeDistanceThreshold = 128.0f;

@interface TGCallView () <ASWatcher, UIGestureRecognizerDelegate>
{
    TGCallState _currentState;
    
    UIView *_dimView;
    UIView *_mainView;
    UIView *_wrapperView;
    UIImage *_backgroundImage;
    TGCallBackgroundView *_backgroundView;
    
    TGModernButton *_backButton;
    UILabel *_emojiLabel;
    TGCallInfoView *_infoView;
    TGCallButtonsView *_buttonsView;
    TGCallEncryptionKeyView *_keyView;
    
    bool _panning;
    TGModernGalleryZoomableScrollViewSwipeGestureRecognizer *_panGestureRecognizer;
    
    TGMenuContainerView *_tooltipContainerView;
    NSTimer *_tooltipTimer;
}

@property (nonatomic, strong) ASHandle *actionHandle;

@end

@implementation TGCallView

@dynamic debugPressed;

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self != nil)
    {
        _actionHandle = [[ASHandle alloc] initWithDelegate:self releaseOnMainThread:true];
        
        __weak TGCallView *weakSelf = self;
        
        _dimView = [[UIView alloc] init];
        _dimView.backgroundColor = [UIColor blackColor];
        _dimView.hidden = true;
        [self addSubview:_dimView];
        
        _mainView = [[UIView alloc] init];
        [self addSubview:_mainView];
        
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
        [_mainView addSubview:_backgroundView];
        
        _wrapperView = [[UIView alloc] init];
        [_mainView addSubview:_wrapperView];
        
        _keyView = [[TGCallEncryptionKeyView alloc] init];
        _keyView.hidden = true;
        _keyView.backPressed = ^
        {
            __strong TGCallView *strongSelf = weakSelf;
            if (strongSelf != nil)
                [strongSelf closeKeyView];
        };
        _keyView.emojiInitialCenter = ^CGPoint
        {
            __strong TGCallView *strongSelf = weakSelf;
            if (strongSelf != nil)
                return [strongSelf->_wrapperView convertPoint:strongSelf->_emojiLabel.center toView:strongSelf->_keyView];
            
            return CGPointZero;
        };
        [_wrapperView addSubview:_keyView];
        
        _backButton = [[TGModernButton alloc] initWithFrame:CGRectZero];
        _backButton.exclusiveTouch = true;
        _backButton.hitTestEdgeInsets = UIEdgeInsetsMake(-5, -20, -5, -5);
        _backButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
        _backButton.titleLabel.textAlignment = NSTextAlignmentLeft;
        _backButton.titleLabel.font = TGSystemFontOfSize(17);
        [_backButton setTitle:TGLocalized(@"Common.Back") forState:UIControlStateNormal];
        [_backButton setTitleColor:[UIColor whiteColor]];
        [_backButton addTarget:self action:@selector(backButtonPressed) forControlEvents:UIControlEventTouchUpInside];
        [_wrapperView addSubview:_backButton];
        
        UIImageView *arrowView = [[UIImageView alloc] initWithFrame:CGRectMake(-19, 5.5f, 13, 22)];
        arrowView.image = [UIImage imageNamed:@"NavigationBackArrow"];
        [_backButton addSubview:arrowView];
        
        _buttonsView = [[TGCallButtonsView alloc] init];
        _buttonsView.mutePressed = ^
        {
            __strong TGCallView *strongSelf = weakSelf;
            if (strongSelf != nil && strongSelf.mutePressed != nil)
                strongSelf.mutePressed();
        };
        _buttonsView.speakerPressed = ^
        {
            __strong TGCallView *strongSelf = weakSelf;
            if (strongSelf != nil && strongSelf.speakerPressed != nil)
                strongSelf.speakerPressed();
        };
        _buttonsView.cancelPressed = ^
        {
            __strong TGCallView *strongSelf = weakSelf;
            if (strongSelf != nil && strongSelf.cancelPressed != nil)
                strongSelf.cancelPressed();
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
        _buttonsView.messagePressed = ^
        {
            __strong TGCallView *strongSelf = weakSelf;
            if (strongSelf != nil && strongSelf.messagePressed != nil)
                strongSelf.messagePressed();
        };
        [_wrapperView addSubview:_buttonsView];
        
        _emojiLabel = [[UILabel alloc] init];
        _emojiLabel.alpha = 0.0f;
        _emojiLabel.backgroundColor = [UIColor clearColor];
        _emojiLabel.font = TGSystemFontOfSize(22);
        _emojiLabel.userInteractionEnabled = true;
        _emojiLabel.textAlignment = NSTextAlignmentCenter;
        [_wrapperView addSubview:_emojiLabel];
        
        _infoView = [[TGCallInfoView alloc] init];
        [_wrapperView addSubview:_infoView];
        
        UITapGestureRecognizer *gestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleEmojiTap:)];
        [_emojiLabel addGestureRecognizer:gestureRecognizer];
        
        if (!TGIsPad())
        {
            _panGestureRecognizer = [[TGModernGalleryZoomableScrollViewSwipeGestureRecognizer alloc] initWithTarget:self action:@selector(handlePan:)];
            _panGestureRecognizer.delegate = self;
            _panGestureRecognizer.delaysTouchesBegan = true;
            _panGestureRecognizer.cancelsTouchesInView = false;
            [self addGestureRecognizer:_panGestureRecognizer];
        }
    }
    return self;
}

- (void)dealloc
{
    [_actionHandle reset];
}

- (void)setDebugPressed:(void (^)(void))debugPressed
{
    _infoView.debugPressed = debugPressed;
}

- (void)setState:(TGCallSessionState *)state duration:(NSTimeInterval)duration
{
    [_backgroundView setState:state];
    [_infoView setState:state duration:duration];
    [_buttonsView setState:state];
    [_keyView setState:state];
    
    TGCallState previousState = _currentState;
    _currentState = state.state;
    
    if (previousState != _currentState)
    {
        bool animated = state.state == TGCallStateAccepting && previousState == TGCallStateReady;
     
        bool backHidden = (_currentState == TGCallStateHandshake || _currentState == TGCallStateReady || _currentState == TGCallStateBusy || _currentState == TGCallStateNoAnswer) || ((_currentState == TGCallStateEnded || _currentState == TGCallStateEnding || _currentState == TGCallStateBusy || _currentState == TGCallStateMissed) && duration < DBL_EPSILON && !state.outgoing);
        [self setBackButtonHidden:backHidden];
        
        if ((_currentState == TGCallStateEnding || _currentState == TGCallStateEnded || _currentState == TGCallStateMissed) && _wrapperView.alpha > 1.0f - FLT_EPSILON)
        {
            _wrapperView.userInteractionEnabled = false;
            [UIView animateWithDuration:0.3 animations:^
            {
                _wrapperView.alpha = 0.5f;
            }];
        }
        
        if (state.keySha256 != nil && _emojiLabel.text.length == 0)
        {
            NSString *text = [TGStringUtils stringForEmojiHashOfData:state.keySha256 count:4 positionExtractor:^int32_t(uint8_t *bytes, int32_t i, int32_t count) {
                int offset = i * 8;
                int64_t num = (((int64_t)bytes[offset] & 0x7F) << 56) | (((int64_t)bytes[offset+1] & 0xFF) << 48) | (((int64_t)bytes[offset+2] & 0xFF) << 40) | (((int64_t)bytes[offset+3] & 0xFF) << 32) | (((int64_t)bytes[offset+4] & 0xFF) << 24) | (((int64_t)bytes[offset+5] & 0xFF) << 16) | (((int64_t)bytes[offset+6] & 0xFF) << 8) | (((int64_t)bytes[offset+7] & 0xFF));
                return num % count;
            }];
            
            NSAttributedString *attributedString = [[NSAttributedString alloc] initWithString:text attributes:@{ NSFontAttributeName: _emojiLabel.font, NSKernAttributeName: @2.5f }];
            
            _emojiLabel.attributedText = attributedString;
            [_emojiLabel sizeToFit];
            _emojiLabel.alpha = 0.0f;
            
            [UIView animateWithDuration:0.2 animations:^
            {
                _emojiLabel.alpha = 1.0f;
            } completion:^(__unused BOOL finished)
            {
                [self setupTooltip:false name:state.peer.displayFirstName];
            }];
            
            [_keyView setEmoji:text];
        }
        
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
    if (self.backPressed != nil)
        self.backPressed();
}

- (void)setBackButtonHidden:(bool)hidden
{
    _backButton.hidden = hidden;
    _panGestureRecognizer.enabled = !hidden;
}

- (void)showKeyView
{
    if ([_keyView present])
    {
        [self setBackButtonHidden:true];
        _emojiLabel.hidden = true;
    }
}

- (void)closeKeyView
{
    [_keyView dismiss:^
    {
        _emojiLabel.hidden = false;
    }];
    [self setBackButtonHidden:false];
}

- (UIButton *)speakerButton
{
    return _buttonsView.speakerButton;
}

- (void)handlePan:(TGModernGalleryZoomableScrollViewSwipeGestureRecognizer *)gestureRecognizer
{
    switch (gestureRecognizer.state)
    {
        case UIGestureRecognizerStateChanged:
        {
            _panning = true;
            _dimView.hidden = false;
            [self _updateDismissTransitionMovementWithDistance:[gestureRecognizer swipeDistance] animated:false completion:nil];
        }
            break;
            
        case UIGestureRecognizerStateEnded:
        {
            CGFloat swipeVelocity = [gestureRecognizer swipeVelocity];
            if (ABS(swipeVelocity) < TGCallSwipeMinimumVelocity)
                swipeVelocity = (swipeVelocity < 0.0f ? -1.0f : 1.0f) * TGCallSwipeMinimumVelocity;
            
            __weak TGCallView *weakSelf = self;
            bool(^transitionOut)(CGFloat) = ^bool(__unused CGFloat swipeVelocity)
            {
                __strong TGCallView *strongSelf = weakSelf;
                if (strongSelf == nil)
                    return false;
                
                [self performMinimize];
            
                return true;
            };
            
            if ((ABS(swipeVelocity) < TGCallSwipeVelocityThreshold && ABS([gestureRecognizer swipeDistance]) < TGCallSwipeDistanceThreshold) || !transitionOut(swipeVelocity))
            {
                [self _updateDismissTransitionMovementWithDistance:0.0f animated:true completion:^
                {
                    _panning = false;
                    _dimView.hidden = true;
                }];
            }
        }
            break;
            
        case UIGestureRecognizerStateCancelled:
        {
            [self _updateDismissTransitionMovementWithDistance:0.0f animated:true completion:^
            {
                _panning = false;
                _dimView.hidden = true;
            }];
        }
            break;
            
        default:
            break;
    }
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)__unused touch
{
    UIView *hitTest = [self hitTest:[touch locationInView:self] withEvent:nil];
    if (gestureRecognizer.state == UIGestureRecognizerStatePossible && [hitTest isKindOfClass:[UIButton class]])
        return false;
    
    return true;
}

- (void)performMinimize
{
    if (self.minimizeRequested != nil)
        self.minimizeRequested();
}

- (void)centralize
{
    _mainView.transform = CGAffineTransformIdentity;
}

- (void)resetPan
{
    _panning = false;
}

- (CGFloat)dismissProgressForSwipeDistance:(CGFloat)distance
{
    return MAX(0.0f, MIN(1.0f, ABS(distance / 150.0f)));
}

- (void)_updateDismissTransitionMovementWithDistance:(CGFloat)distance animated:(bool)animated completion:(void (^)(void))completion
{
    CGFloat scale = 1.0f + 0.06f * MIN(1.0f, (fabs(distance) / 200.0f));
    
    CGAffineTransform transform = CGAffineTransformMakeTranslation(0, distance);
    transform = CGAffineTransformScale(transform, scale, scale);
    
    if (animated)
    {
        [UIView animateWithDuration:0.3 animations:^
        {
            _mainView.transform = transform;
        } completion:^(__unused BOOL finished)
        {
            if (completion != nil)
                completion();
        }];
    }
    else
    {
        _mainView.transform = transform;
    }
}

- (void)setupTooltip:(bool)manual name:(NSString *)name
{
    if (UIInterfaceOrientationIsLandscape([UIApplication sharedApplication].statusBarOrientation))
        return;
    
    NSInteger displayed = manual ? 0 : [[[NSUserDefaults standardUserDefaults] objectForKey:@"TG_displayedCallEmojiTooltip_v0"] integerValue];
#if defined(INTERNAL_RELEASE)
//    displayed = 0;
#endif
    if (displayed > 2)
        return;
    
    if (_tooltipContainerView != nil)
        return;
    
    NSString *textFormat = TGLocalized(@"Call.EmojiDescription");
    NSString *baseText = [[NSString alloc] initWithFormat:textFormat, name];
    
    NSDictionary *attrs = @{NSFontAttributeName: TGSystemFontOfSize(14), NSForegroundColorAttributeName: [UIColor whiteColor]};
    NSDictionary *subAttrs = @{NSFontAttributeName:[UIFont boldSystemFontOfSize:14], NSForegroundColorAttributeName: [UIColor whiteColor]};
    
    NSMutableAttributedString *attributedText = [[NSMutableAttributedString alloc] initWithString:baseText attributes:attrs];
    [attributedText setAttributes:subAttrs range:NSMakeRange([textFormat rangeOfString:@"%@"].location, name.length)];
    
    _tooltipTimer = [TGTimerTarget scheduledMainThreadTimerWithTarget:self action:@selector(tooltipTimerTick) interval:5.5 repeat:false];
    
    _tooltipContainerView = [[TGMenuContainerView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, self.frame.size.width, self.frame.size.height)];
    [self addSubview:_tooltipContainerView];
    
    _tooltipContainerView.menuView.multiline = true;
    [_tooltipContainerView.menuView setButtonsAndActions:@[ @{ @"title": attributedText } ] watcherHandle:self.actionHandle];
    [_tooltipContainerView.menuView sizeToFit];
    _tooltipContainerView.menuView.buttonHighlightDisabled = true;
    
    CGRect frame = _emojiLabel.frame;
    frame.origin.y -= 6.0f;
    [_tooltipContainerView showMenuFromRect:frame animated:false];
    
    if (!manual)
        [[NSUserDefaults standardUserDefaults] setObject:@(displayed + 1) forKey:@"TG_displayedCallEmojiTooltip_v0"];
}

- (void)tooltipTimerTick
{
    [_tooltipTimer invalidate];
    _tooltipTimer = nil;
    
    [_tooltipContainerView hideMenu];
    _tooltipContainerView = nil;
}

- (void)actionStageActionRequested:(NSString *)action options:(id)__unused options
{
    if ([action isEqualToString:@"menuAction"])
    {
        [_tooltipTimer invalidate];
        _tooltipTimer = nil;
        
        [_tooltipContainerView hideMenu];
        _tooltipContainerView = nil;
    }
    else if ([action isEqualToString:@"menuWillHide"])
    {
        [_tooltipTimer invalidate];
        _tooltipTimer = nil;
        
        _tooltipContainerView = nil;
    }
}

- (void)handleEmojiTap:(UITapGestureRecognizer *)__unused gestureRecognizer
{
    [self showKeyView];
}

+ (CGFloat)infoTopOffset
{
    CGFloat offset = 0.0f;
    if (TGIsPad())
    {
        static dispatch_once_t onceToken;
        static CGFloat staticOffset;
        dispatch_once(&onceToken, ^
        {
            CGSize screenSize = TGScreenSize();
            int height = (int)screenSize.height;
            if (height == 1366)
            {
                staticOffset = 160.0f;
            }
            else
            {
                staticOffset = 120.0f;
            }
        });
        offset = staticOffset;
    }
    else
    {
        static dispatch_once_t onceToken;
        static CGFloat staticOffset;
        dispatch_once(&onceToken, ^
        {
            CGSize screenSize = TGScreenSize();
            int width = (int)screenSize.width;
            int height = (int)screenSize.height;
            if (height == 736)
                staticOffset = 80; //plus
            else if (width == 320)
                staticOffset = 60; // 4/5
            else
                staticOffset = 64; // 6/7
        });
        offset = staticOffset;
    }
    return offset;
}

+ (CGFloat)buttonsTopOffset:(CGRect)bounds
{
    CGFloat offset = 0.0f;
    static dispatch_once_t onceToken;
    static CGFloat screenHeight;
    dispatch_once(&onceToken, ^
    {
        screenHeight = TGScreenSize().height;
    });
    
    if (TGIsPad())
    {
        int height = (int)screenHeight;
        if (height == 1366)
            offset = bounds.size.height - 420.0f;
        else
            offset = bounds.size.height - 375.0f;
    }
    else
    {
        static dispatch_once_t onceToken;
        static CGFloat staticOffset;
        dispatch_once(&onceToken, ^
        {
            int height = (int)screenHeight;
            if (height == 736)
                staticOffset = 410;
            else if (height == 480)
                staticOffset = 270;
            else if (height == 568)
                staticOffset = 306;
            else
                staticOffset = 385;
        });
        offset = staticOffset;
    }
    return offset;
}

- (void)layoutSubviews
{
    _dimView.frame = self.bounds;
    
    if (!_panning)
        _mainView.frame = self.bounds;
    
    _backgroundView.frame = self.bounds;
    _wrapperView.frame = self.bounds;
    _keyView.frame = self.bounds;
    
    if (!_panning)
    {
        [_backButton sizeToFit];
        _backButton.frame = CGRectMake(27, 25, ceil(_backButton.frame.size.width), ceil(_backButton.frame.size.height));
        _infoView.frame = CGRectMake(0, [TGCallView infoTopOffset], self.frame.size.width, TGCallInfoViewHeight);
        
        CGFloat buttonsTop = [TGCallView buttonsTopOffset:self.bounds];
        CGFloat buttonsWidth = [TGCallButton buttonSize].width * 3 + TGCallButtonsSpacing * 2;
        _buttonsView.frame = CGRectMake(floor((self.frame.size.width - buttonsWidth) / 2.0f), buttonsTop, buttonsWidth, 232);
        
        _emojiLabel.frame = CGRectMake(self.frame.size.width - _emojiLabel.frame.size.width - 8.0f, 28.0f, _emojiLabel.frame.size.width, _emojiLabel.frame.size.height);
    }
}

@end
