#import "TGCallInfoView.h"

#import "TGFont.h"
#import "TGImageUtils.h"

#import "TGUser.h"
#import "TGCallSession.h"

#import "TGMarqueeLabel.h"
#import "TGCallReceptionView.h"

const CGFloat TGCallInfoViewHeight = 86.0f;
const CGFloat TGCallInfoNamePadding = 25.0f;

const CGFloat TGCallInfoNormalSpacing = 9.0f;
const CGFloat TGCallInfoLargeSpacing = 11.0f;

const CGFloat TGCallInfoSmallNameFontSize = 28.0f;
const CGFloat TGCallInfoNormalNameFontSize = 36.0f;

const CGFloat TGCallInfoSmallStatusFontSize = 16.0f;
const CGFloat TGCallInfoNormalStatusFontSize = 18.0f;

@interface TGCallInfoView ()
{
    TGMarqueeLabel *_nameLabel;
    UILabel *_statusLabel;
    TGCallReceptionView *_receptionView;
    bool _needsFontUpdate;
    
    TGCallState _currentState;
}
@end

@implementation TGCallInfoView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self != nil)
    {
        _nameLabel = [[TGMarqueeLabel alloc] initWithFrame:CGRectZero];
        _nameLabel.font = TGLightSystemFontOfSize([TGCallInfoView nameFontSize]);
        _nameLabel.textAlignment = NSTextAlignmentCenter;
        _nameLabel.textColor = [UIColor whiteColor];
        _nameLabel.text = @"Name";
        _nameLabel.hidden = true;
        _nameLabel.scrollDuration = 15.0;
        _nameLabel.fadeLength = 25.0f;
        _nameLabel.trailingBuffer = 60.0f;
        _nameLabel.animationDelay = 2.0;
        [_nameLabel sizeToFit];
        [self addSubview:_nameLabel];
        
        _statusLabel = [[UILabel alloc] init];
        _statusLabel.font = TGSystemFontOfSize([TGCallInfoView statusFontSize]);
        _statusLabel.textAlignment = NSTextAlignmentCenter;
        _statusLabel.textColor = [UIColor whiteColor];
        _statusLabel.hidden = true;
        _statusLabel.text = @"Status";
        [_statusLabel sizeToFit];
        [self addSubview:_statusLabel];
        
        _receptionView = [[TGCallReceptionView alloc] init];
        _receptionView.alpha = 0.0f;
        //[self addSubview:_receptionView];
    }
    return self;
}

+ (CGFloat)spacing
{
    static dispatch_once_t onceToken;
    static CGFloat spacing;
    dispatch_once(&onceToken, ^
    {
        CGSize screenSize = TGScreenSize();
        int height = (int)screenSize.height;
        if (height == 736 || height == 768 || height == 1366)
            spacing = TGCallInfoLargeSpacing;
        else
            spacing = TGCallInfoNormalSpacing;
    });
    return spacing;
}

+ (CGFloat)nameFontSize
{
    static dispatch_once_t onceToken;
    static CGFloat size;
    dispatch_once(&onceToken, ^
    {
        CGSize screenSize = TGScreenSize();
        if ((int)screenSize.width == 320)
            size = TGCallInfoSmallNameFontSize;
        else
            size = TGCallInfoNormalNameFontSize;
    });
    return size;
}

+ (CGFloat)statusFontSize
{
    static dispatch_once_t onceToken;
    static CGFloat size;
    dispatch_once(&onceToken, ^
    {
        CGSize screenSize = TGScreenSize();
        if ((int)screenSize.width == 320)
            size = TGCallInfoSmallStatusFontSize;
        else
            size = TGCallInfoNormalStatusFontSize;
    });
    return size;
}

- (CGFloat)scaledSizeForName:(NSString *)name size:(CGSize)size
{
    UIFont *font = TGLightSystemFontOfSize([TGCallInfoView nameFontSize]);
    if (name.length == 0)
        return font.pointSize;
    
    NSStringDrawingContext *labelContext = [NSStringDrawingContext new];
    labelContext.minimumScaleFactor = 0.65f;
    
    NSAttributedString *attributedString = [[NSAttributedString alloc] initWithString:name attributes:@{ NSFontAttributeName: font }];
    [attributedString boundingRectWithSize:size options:NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading context:labelContext];
    
    return font.pointSize * labelContext.actualScaleFactor;
}

- (void)setState:(TGCallSessionState *)state duration:(NSTimeInterval)duration
{
    if (state.peer.displayName.length > 0)
        _nameLabel.hidden = false;
    
    if (![state.peer.displayName isEqualToString:_nameLabel.text])
    {
        _nameLabel.text = state.peer.displayName;
        _needsFontUpdate = true;
        [self setNeedsLayout];
    }
    
    _statusLabel.hidden = false;
    
    TGCallState previousState = _currentState;
    _currentState = state.state;
    
    switch (_currentState)
    {
        case TGCallStateRequesting:
        case TGCallStateWaiting:
        case TGCallStateWaitingReceived:
        case TGCallStateHandshake:
        case TGCallStateReady:
        case TGCallStateAccepting:
        {
            _statusLabel.text = @"Telegram Call...";
            //_statusLabel.text = TGLocalized(@"Call.StatusRequesting");
            _receptionView.hidden = true;
        }
            break;
            
        
        case TGCallStateOngoing:
        {
            switch (state.transmissionState)
            {
                case TGCallTransmissionStateInitializing:
                {
                    _statusLabel.text = @"Connecting...";
                    //_statusLabel.text = TGLocalized(@"Call.StatusConnecting");
                }
                    break;
                    
                case TGCallTransmissionStateEstablished:
                {
                    NSString *durationString = duration >= 60 * 60 ? [NSString stringWithFormat:@"%02d:%02d:%02d", (int)(duration / 3600.0), (int)(duration / 60.0) % 60, (int)duration % 60] : [NSString stringWithFormat:@"%02d:%02d", (int)(duration / 60.0) % 60, (int)duration % 60];
                    _statusLabel.text = [NSString stringWithFormat:@"Telegram Call %@", durationString];
                    //_statusLabel.text = [NSString stringWithFormat:TGLocalized(@"Call.StatusOngoing"), durationString];
                }
                    break;
                    
                case TGCallTransmissionStateFailed:
                {
                    _statusLabel.text = @"Failed";
                    //_statusLabel.text = TGLocalized(@"Call.StatusFailed");
                }
                    break;
                    
                default:
                    break;
            }
            
            if (previousState != TGCallStateOngoing)
            {
                _receptionView.hidden = false;
                _receptionView.alpha = 0.0f;
                [UIView animateWithDuration:0.2 animations:^
                {
                    _receptionView.alpha = 1.0f;
                }];
            }
        }
            break;
        
        case TGCallStateEnding:
        case TGCallStateEnded:
        case TGCallStateBusy:
        case TGCallStateInterrupted:
        {
            if (state.transmissionState == TGCallTransmissionStateFailed)
                _statusLabel.text = @"Failed";
                //_statusLabel.text = TGLocalized(@"Call.StatusFailed");
            else if (state.state == TGCallStateBusy)
                _statusLabel.text = @"Busy";
            else
                _statusLabel.text = @"Call Ended";
                //_statusLabel.text = TGLocalized(@"Call.StatusEnded");
            
            if (previousState != _currentState)
            {
                _nameLabel.alpha = 0.5f;
                _statusLabel.alpha = 0.5f;
                
                [UIView animateWithDuration:0.2 animations:^
                {
                    _receptionView.alpha = 0.0f;
                } completion:^(__unused BOOL finished)
                {
                    _receptionView.hidden = true;
                    _receptionView.alpha = 1.0f;
                }];
            }
        }
            break;
            
        default:
            break;
    }
}

- (void)onPause
{
    [_nameLabel shutdownLabel];
}

- (void)onResume
{
    [_nameLabel restartLabel];
}

- (void)layoutSubviews
{
    _nameLabel.frame = CGRectMake(TGCallInfoNamePadding, 0, self.frame.size.width - TGCallInfoNamePadding * 2, ceil(_nameLabel.frame.size.height));
    
    if (_needsFontUpdate)
    {
        CGFloat fontSize = [self scaledSizeForName:_nameLabel.text size:_nameLabel.frame.size];
        _nameLabel.font = TGLightSystemFontOfSize(fontSize);
        
        _needsFontUpdate = false;
    }
    _statusLabel.frame = CGRectMake(0, _nameLabel.frame.size.height + [TGCallInfoView spacing], self.frame.size.width, ceil(_statusLabel.frame.size.height));
    
    CGSize qualitySize = TGCallQualityViewSize;
    _receptionView.frame = CGRectMake((self.frame.size.width - qualitySize.width) / 2.0f, CGRectGetMaxY(_statusLabel.frame) + 15.0f, qualitySize.width, qualitySize.height);
}

@end
