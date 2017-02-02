#import "TGCallButtonsView.h"

#import "TGImageUtils.h"
#import "TGCallSession.h"

#import "TGCallButton.h"
#import "TGCallAcceptButton.h"

const CGFloat TGCallButtonsSpacing = 28.0f;

@interface TGCallButtonsView ()
{
    TGCallButton *_declineButton;
    TGCallAcceptButton *_callButton;
    
    TGCallButton *_muteButton;
    TGCallButton *_messageButton;
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
        
        
        if (TGScreenSize().height > 480)
        {
            [_callButton setTitle:@"Accept" forState:UIControlStateNormal];
            [_declineButton setTitle:@"Decline" forState:UIControlStateNormal];
            //[_callButton setTitle:TGLocalized(@"Call.Accept") forState:UIControlStateNormal];
            //[_declineButton setTitle:TGLocalized(@"Call.Decline") forState:UIControlStateNormal];
        }
        
        _declineButton.hidden = true;
        
        _muteButton = [[TGCallButton alloc] init];
        _muteButton.hasBorder = true;
        [_muteButton setImage:[UIImage imageNamed:@"CallMuteIcon"] forState:UIControlStateNormal];
        [_muteButton addTarget:self action:@selector(muteButtonPressed) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:_muteButton];
        
        _messageButton = [[TGCallButton alloc] init];
        _messageButton.hasBorder = true;
        [_messageButton setImage:[UIImage imageNamed:@"CallMessageIcon"] forState:UIControlStateNormal];
        [_messageButton addTarget:self action:@selector(messageButtonPressed) forControlEvents:UIControlEventTouchUpInside];
        //[self addSubview:_messageButton];
        
        _speakerButton = [[TGCallButton alloc] init];
        _speakerButton.hasBorder = true;
        [_speakerButton setImage:[UIImage imageNamed:@"CallSpeakerIcon"] forState:UIControlStateNormal];
        [_speakerButton addTarget:self action:@selector(speakerButtonPressed) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:_speakerButton];
        
        [_callButton setState:TGCallAcceptButtonStateEnd];
    }
    return self;
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
            
            _muteButton.hidden = true;
            _messageButton.hidden = true;
            _speakerButton.hidden = true;
            break;
            
        case TGCallStateAccepting:
        case TGCallStateOngoing:
        {
            _muteButton.hidden = false;
            _messageButton.hidden = false;
            _speakerButton.hidden = false;
            
            if (previousState == TGCallStateReady)
            {
                _muteButton.alpha = 0.0f;
                _messageButton.alpha = 0.0f;
                _speakerButton.alpha = 0.0f;
                
                [UIView animateWithDuration:0.2 animations:^
                {
                    _muteButton.alpha = 1.0f;
                    _messageButton.alpha = 1.0f;
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
                _messageButton.hidden = false;
                _speakerButton.hidden = false;
            }
        }
            break;
         
        case TGCallStateEnding:
        case TGCallStateEnded:
        case TGCallStateBusy:
        case TGCallStateInterrupted:
            if (previousState == TGCallStateOngoing)
            {
                _muteButton.hidden = false;
                _messageButton.hidden = false;
                _speakerButton.hidden = false;
                
                [_callButton setState:TGCallAcceptButtonStateEnd];
            }
            else if (previousState == TGCallStateReady || previousState == TGCallStateHandshake)
            {
                _twoButtons = true;
            }
            
            _declineButton.userInteractionEnabled = false;
            _callButton.userInteractionEnabled = false;
            
            _muteButton.userInteractionEnabled = false;
            _messageButton.userInteractionEnabled = false;
            _speakerButton.userInteractionEnabled = false;
            
            self.alpha = 0.5f;
            break;
            
        case TGCallStateRequesting:
        case TGCallStateWaiting:
        case TGCallStateWaitingReceived:
            _declineButton.hidden = true;
            _callButton.hidden = false;
            [_callButton setState:TGCallAcceptButtonStateEnd];
            
            _muteButton.hidden = false;
            _messageButton.hidden = false;
            _speakerButton.hidden = false;
            
            break;
        
        default:
            break;
    }
    
    if (maybeNeedsLayout)
        [self setNeedsLayout];
    
    _muteButton.selected = state.mute;
    _speakerButton.selected = state.speaker;
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

- (void)muteButtonPressed
{
    if (self.mutePressed != nil)
        self.mutePressed();
}

- (void)messageButtonPressed
{
    if (self.messagePressed != nil)
        self.messagePressed();
}

- (void)speakerButtonPressed
{
    if (self.speakerPressed != nil)
        self.speakerPressed();
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
    CGFloat offset = [TGCallButtonsView bottomButtonsOffset];
    
    _muteButton.frame = CGRectMake(0, _muteButton.frame.size.height + offset, _muteButton.frame.size.width, _muteButton.frame.size.height);
    //_messageButton.frame = CGRectMake(_declineButton.frame.size.width + TGCallButtonsSpacing, 0, _messageButton.frame.size.width, _messageButton.frame.size.height);
    _speakerButton.frame = CGRectMake(_declineButton.frame.size.width + _speakerButton.frame.size.width + 2 * TGCallButtonsSpacing, _speakerButton.frame.size.height + offset, _speakerButton.frame.size.width, _speakerButton.frame.size.height);
    
    for (TGCallButton *button in self.subviews)
    {
        if (![button isKindOfClass:[TGCallButton class]] || !button.hasBorder)
            continue;
        
        [button setAbsoluteOffset:CGPointMake(self.frame.origin.x + button.frame.origin.x, self.frame.origin.y + button.frame.origin.y)];
    }
    
    
    
    _declineButton.frame = CGRectMake((self.frame.size.width - _declineButton.frame.size.width) / 2.0f - 90.0f, CGRectGetMaxY(_messageButton.frame) + offset, _declineButton.frame.size.width, _declineButton.frame.size.height);
    
    bool twoButtons = _twoButtons || _currentState == TGCallStateHandshake || _currentState == TGCallStateReady;
    if (twoButtons)
    {
        _callButton.frame = CGRectMake((self.frame.size.width - _callButton.frame.size.width) / 2.0f + 90.0f, CGRectGetMaxY(_messageButton.frame) + offset, _callButton.frame.size.width, _callButton.frame.size.height);
    }
    else
    {
        _callButton.frame = CGRectMake((self.frame.size.width - _callButton.frame.size.width) / 2.0f, CGRectGetMaxY(_messageButton.frame) + offset, _callButton.frame.size.width, _callButton.frame.size.height);
    }
}

@end
