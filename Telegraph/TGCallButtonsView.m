#import "TGCallButtonsView.h"

#import "TGImageUtils.h"
#import "TGCallSession.h"

#import "TGCallButton.h"
#import "TGCallAcceptButton.h"
#import "TGCallMessageButton.h"

const CGFloat TGCallButtonsSpacing = 28.0f;

@interface TGCallButtonsView ()
{
    TGCallButton *_declineButton;
    TGCallAcceptButton *_callButton;
    
    TGCallMessageButton *_messageButton;
    TGCallButton *_cancelButton;
    TGCallButton *_muteButton;
    TGCallButton *_speakerButton;
    
    TGCallState _currentState;
    bool _twoButtons;
}
@end

@implementation TGCallButtonsView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self != nil)
    {
        _declineButton = [[TGCallButton alloc] init];
        _declineButton.backColor = [TGCallAcceptButton redColor];
        [_declineButton setImage:[UIImage imageNamed:@"CallPhoneIcon"] forState:UIControlStateNormal];
        [_declineButton addTarget:self action:@selector(declineButtonPressed) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:_declineButton];
        
        _callButton = [[TGCallAcceptButton alloc] init];
        [_callButton addTarget:self action:@selector(callButtonPressed) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:_callButton];
        
        _declineButton.hidden = true;

        _cancelButton = [[TGCallButton alloc] init];
        _cancelButton.hasBorder = true;
        [_cancelButton setImage:[UIImage imageNamed:@"CallCancelIcon"] forState:UIControlStateNormal];
        [_cancelButton addTarget:self action:@selector(cancelButtonPressed) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:_cancelButton];
        
        _muteButton = [[TGCallButton alloc] init];
        _muteButton.hasBorder = true;
        [_muteButton setImage:[UIImage imageNamed:@"CallMuteIcon"] forState:UIControlStateNormal];
        [_muteButton addTarget:self action:@selector(muteButtonPressed) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:_muteButton];
        
        _speakerButton = [[TGCallButton alloc] init];
        _speakerButton.hasBorder = true;
        [_speakerButton setImage:[UIImage imageNamed:@"CallSpeakerIcon"] forState:UIControlStateNormal];
        [_speakerButton addTarget:self action:@selector(speakerButtonPressed) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:_speakerButton];
        
        _messageButton = [[TGCallMessageButton alloc] init];
        [_messageButton setImage:[UIImage imageNamed:@"CallQuickMessageIcon"] forState:UIControlStateNormal];
        [_messageButton addTarget:self action:@selector(messageButtonPressed) forControlEvents:UIControlEventTouchUpInside];
        [_messageButton setTitle:TGLocalized(@"Call.Message") forState:UIControlStateNormal];
        [self addSubview:_messageButton];
        
        [_callButton setState:TGCallAcceptButtonStateEnd];
        
        if (TGScreenSize().height > 480)
        {
            [_cancelButton setTitle:TGLocalized(@"Common.Cancel") forState:UIControlStateNormal];
            [_callButton setTitle:TGLocalized(@"Call.Accept") forState:UIControlStateNormal];
            [_declineButton setTitle:TGLocalized(@"Call.Decline") forState:UIControlStateNormal];
        }
    }
    return self;
}

- (UIButton *)speakerButton
{
    return _speakerButton;
}

- (void)setState:(TGCallSessionState *)state
{
    bool maybeNeedsLayout = false;
    
    TGCallState previousState = _currentState;
    if (_currentState != state.state)
    {
        _currentState = state.state;
        maybeNeedsLayout = true;
    }
    
    switch (state.state)
    {
        case TGCallStateReady:
        case TGCallStateHandshake:
            _declineButton.hidden = false;
            _callButton.hidden = false;
            [_callButton setState:TGCallAcceptButtonStateAccept];
            
            _messageButton.hidden = true;
            _cancelButton.hidden = true;
            _muteButton.hidden = true;
            _speakerButton.hidden = true;
            break;
            
        case TGCallStateAccepting:
        case TGCallStateOngoing:
        {
            _messageButton.hidden = true;
            _cancelButton.hidden = true;
            
            _muteButton.hidden = false;
            _speakerButton.hidden = false;
            
            if (previousState == TGCallStateReady)
            {
                _muteButton.alpha = 0.0f;
                _speakerButton.alpha = 0.0f;
                
                [UIView animateWithDuration:0.2 animations:^
                {
                    _muteButton.alpha = 1.0f;
                    _speakerButton.alpha = 1.0f;
                    _declineButton.alpha = 0.0f;
                } completion:^(__unused BOOL finished)
                {
                    _declineButton.hidden = true;
                    _declineButton.alpha = 1.0f;
                }];
                
                [UIView animateWithDuration:0.3 delay:0.0 options:7 << 16 animations:^
                {
                    [_callButton setState:TGCallAcceptButtonStateEnd];
                    [self layoutSubviews];
                } completion:nil];
                
                maybeNeedsLayout = false;
            }
            else
            {
                _declineButton.hidden = true;
                _callButton.hidden = false;
                [_callButton setState:TGCallAcceptButtonStateEnd];
                
                _muteButton.hidden = false;
                _speakerButton.hidden = false;
            }
        }
            break;
         
        case TGCallStateEnding:
        case TGCallStateEnded:
        case TGCallStateMissed:
            if (previousState == TGCallStateOngoing)
            {
                _muteButton.hidden = false;
                _speakerButton.hidden = false;
                _cancelButton.hidden = true;
                _messageButton.hidden = true;
                
                [_callButton setState:TGCallAcceptButtonStateEnd];
            }
            else if (previousState == TGCallStateReady || previousState == TGCallStateHandshake)
            {
                _twoButtons = true;
            }
            break;
            
        case TGCallStateBusy:
        case TGCallStateNoAnswer:
            if (previousState == TGCallStateWaiting || previousState == TGCallStateWaitingReceived)
            {
                _twoButtons = true;
                
                _cancelButton.hidden = false;
                _cancelButton.alpha = 0.0f;
                
                _messageButton.hidden = false;
                _messageButton.alpha = 0.0f;
                
                [UIView animateWithDuration:0.2 animations:^
                {
                    _muteButton.alpha = 0.0f;
                    _speakerButton.alpha = 0.0f;
                    _cancelButton.alpha = 1.0f;
                    _messageButton.alpha = 1.0f;
                } completion:^(__unused BOOL finished)
                {
                    _messageButton.hidden = false;
                    _cancelButton.hidden = false;
                    _muteButton.hidden = true;
                    _speakerButton.hidden = true;
                    _muteButton.alpha = 1.0f;
                    _speakerButton.alpha = 1.0f;
                }];
                
                [UIView animateWithDuration:0.3 delay:0.0 options:7 << 16 animations:^
                {
                     [_callButton setState:TGCallAcceptButtonStateAccept];
                     [self layoutSubviews];
                } completion:nil];
                
                maybeNeedsLayout = false;
            }
            break;
            
        case TGCallStateRequesting:
        case TGCallStateWaiting:
        case TGCallStateWaitingReceived:
            if (previousState == TGCallStateBusy || previousState == TGCallStateNoAnswer)
            {
                _twoButtons = false;
                
                _muteButton.alpha = 0.0f;
                _speakerButton.alpha = 0.0f;
                _muteButton.hidden = false;
                _speakerButton.hidden = false;
                
                [UIView animateWithDuration:0.2 animations:^
                {
                    _muteButton.alpha = 1.0f;
                    _speakerButton.alpha = 1.0f;
                    _cancelButton.alpha = 0.0f;
                    _messageButton.alpha = 0.0f;
                } completion:^(__unused BOOL finished)
                {
                    if (finished)
                    {
                        _cancelButton.hidden = true;
                        _messageButton.hidden = true;
                    }
                    
                    _cancelButton.alpha = 1.0f;
                    _messageButton.alpha = 1.0f;
                }];
                
                [UIView animateWithDuration:0.3 delay:0.0 options:7 << 16 animations:^
                {
                    [_callButton setState:TGCallAcceptButtonStateEnd];
                    [self layoutSubviews];
                } completion:nil];
                
                maybeNeedsLayout = false;
            }
            else
            {
                _messageButton.hidden = true;
                _cancelButton.hidden = true;
                _declineButton.hidden = true;
                _callButton.hidden = false;
                [_callButton setState:TGCallAcceptButtonStateEnd];
                
                _muteButton.hidden = false;
                _speakerButton.hidden = false;
            }
            break;
        
        default:
            break;
    }
    
    if (maybeNeedsLayout)
        [self setNeedsLayout];
    
    NSString *currentTitle = [_callButton titleForState:UIControlStateNormal];
    if (currentTitle.length > 0)
    {
        NSString *title = TGLocalized(@"Call.Accept");
        if (state.state == TGCallStateBusy || state.state == TGCallStateNoAnswer)
            title = TGLocalized(@"Call.CallAgain");
        
        if (![currentTitle isEqualToString:title])
            [_callButton setTitle:title forState:UIControlStateNormal];
    }
    
    _muteButton.selected = state.mute;
    
    bool hasBluetoothRoute = false;
    for (TGAudioRoute *route in state.audioRoutes)
    {
        if (route.isBluetooth)
        {
            hasBluetoothRoute = true;
            break;
        }
    }
    
    if (hasBluetoothRoute)
    {
        [_speakerButton setImage:[UIImage imageNamed:@"CallBluetoothIcon"] forState:UIControlStateNormal];
        _speakerButton.selected = false;
    }
    else
    {
        [_speakerButton setImage:[UIImage imageNamed:@"CallSpeakerIcon"] forState:UIControlStateNormal];
        _speakerButton.selected = state.speaker;
        
        if (TGIsPad())
            _speakerButton.hidden = true;
    }
}

- (void)setBackground:(NSObject<TGPasscodeBackground> *)background
{
    for (TGCallButton *button in self.subviews)
    {
        if (![button isKindOfClass:[TGCallButton class]] || !button.hasBorder)
            continue;
        
        [button setBackground:background];
        [button setAbsoluteOffset:CGPointMake(self.frame.origin.x + button.frame.origin.x, self.frame.origin.y + button.frame.origin.y)];
    }
}

- (void)declineButtonPressed
{
    if (self.declinePressed != nil)
        self.declinePressed();
}

- (void)callButtonPressed
{
    if (self.callPressed != nil)
        self.callPressed();
}

- (void)cancelButtonPressed
{
    if (self.cancelPressed != nil)
        self.cancelPressed();
}

- (void)muteButtonPressed
{
    if (self.mutePressed != nil)
        self.mutePressed();
}

- (void)speakerButtonPressed
{
    if (self.speakerPressed != nil)
        self.speakerPressed();
}

- (void)messageButtonPressed
{
    if (self.messagePressed != nil)
        self.messagePressed();
}

+ (CGFloat)bottomButtonsOffset
{
    static dispatch_once_t onceToken;
    static CGFloat offset;
    dispatch_once(&onceToken, ^
    {
        CGSize screenSize = TGScreenSize();
        if ((int)screenSize.width == 320)
            if ((int)screenSize.height == 480)
                offset = 53;
            else
                offset = 63;
        else
            offset = 83;
    });
    return offset;
}

- (void)layoutSubviews
{
    CGFloat offset = _muteButton.frame.size.height + [TGCallButtonsView bottomButtonsOffset];
    
    _muteButton.frame = CGRectMake(0, offset, _muteButton.frame.size.width, _muteButton.frame.size.height);
    _cancelButton.frame = _muteButton.frame;
    _speakerButton.frame = CGRectMake(_declineButton.frame.size.width + _speakerButton.frame.size.width + 2 * TGCallButtonsSpacing, offset, _speakerButton.frame.size.width, _speakerButton.frame.size.height);
    
    _messageButton.frame = CGRectMake(floor((self.frame.size.width - _callButton.frame.size.width) / 2.0f) + 90.0f, _speakerButton.frame.origin.y - 90.0f, _speakerButton.frame.size.width, 55.0f);
    
    for (TGCallButton *button in self.subviews)
    {
        if (![button isKindOfClass:[TGCallButton class]] || !button.hasBorder)
            continue;
        
        [button setAbsoluteOffset:CGPointMake(self.frame.origin.x + button.frame.origin.x, self.frame.origin.y + button.frame.origin.y)];
    }
    
    _declineButton.frame = CGRectMake(floor((self.frame.size.width - _declineButton.frame.size.width) / 2.0f) - 90.0f, offset, _declineButton.frame.size.width, _declineButton.frame.size.height);
    
    bool twoButtons = _twoButtons || _currentState == TGCallStateHandshake || _currentState == TGCallStateReady;
    if (twoButtons)
    {
        _callButton.frame = CGRectMake(floor((self.frame.size.width - _callButton.frame.size.width) / 2.0f) + 90.0f, offset, _callButton.frame.size.width, _callButton.frame.size.height);
    }
    else
    {
        _callButton.frame = CGRectMake(floor((self.frame.size.width - _callButton.frame.size.width) / 2.0f), offset, _callButton.frame.size.width, _callButton.frame.size.height);
    }
}

@end
