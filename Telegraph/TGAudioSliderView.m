#import "TGAudioSliderView.h"

#import <LegacyComponents/LegacyComponents.h>

#import "TGAudioSliderButton.h"
#import "TGAudioSliderArea.h"

#import "TGAudioWaveformView.h"

#import "TGSharedMediaUtils.h"

#import "TGMusicPlayer.h"

#import "TGPresentation.h"

@interface TGAudioSliderView () <TGAudioSliderAreaDelegate>
{
    TGAudioWaveformView *_waveformView;
    
    CGPoint _sliderButtonStartLocation;
    float _sliderButtonStartValue;
    TGAudioSliderArea *_sliderArea;
    
    UILabel *_durationLabel;
    int32_t _durationLabelSeconds;
    
    UIImageView *_statusIconView;
    
    bool _isScrubbing;
    
    CGFloat _scrubbingPosition;
    CGFloat _scrubbingAbsoluteDistance;
    
    SMetaDisposable *_waveformDisposable;
    
    TGMusicPlayerStatus *_status;
    CGFloat _immediateProgress;
}

@property (nonatomic, strong) NSString *viewIdentifier;
@property (nonatomic, strong) NSString *viewStateIdentifier;

@end

@implementation TGAudioSliderView

- (UIColor *)durationColor:(TGAudioSliderViewStyle)style presentation:(TGPresentation *)presentation
{
    switch (style)
    {
        case TGAudioSliderViewStyleIncoming:
            return presentation.pallete.chatIncomingSubtextColor;
            
        case TGAudioSliderViewStyleOutgoing:
            return presentation.pallete.chatOutgoingSubtextColor;
            
        case TGAudioSliderViewStyleNotification:
            return [UIColor whiteColor];
            
        default:
            return nil;
    }
}

- (UIImage *)listenedStatusImage:(TGAudioSliderViewStyle)style presentation:(TGPresentation *)presentation
{
    static UIImage *incomingImage = nil;
    static UIImage *outgoingImage = nil;
    static int32_t cachedPresentation;

    if (cachedPresentation != presentation.currentId)
    {
        cachedPresentation = presentation.currentId;
        incomingImage = TGCircleImage(3.0f, presentation.pallete.chatIncomingAudioDotColor);
        outgoingImage = TGCircleImage(3.0f, presentation.pallete.chatOutgoingAudioDotColor);
    };
    
    switch (style)
    {
        case TGAudioSliderViewStyleIncoming:
            return incomingImage;
            
        case TGAudioSliderViewStyleOutgoing:
            return outgoingImage;
            
        default:
            return nil;
    }
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
    {
        _waveformView = [[TGAudioWaveformView alloc] init];
        [self addSubview:_waveformView];
        
        switch (_style)
        {
            case TGAudioSliderViewStyleIncoming:
                [_waveformView setForegroundColor:TGAccentColor() backgroundColor:UIColorRGB(0xcacaca)];
                break;
                
            case TGAudioSliderViewStyleOutgoing:
                [_waveformView setForegroundColor:UIColorRGB(0x3fc33b) backgroundColor:UIColorRGB(0x93d987)];
                break;
                
            case TGAudioSliderViewStyleNotification:
                [_waveformView setForegroundColor:UIColorRGB(0xf6f6f6) backgroundColor:UIColorRGB(0x838282)];
                break;
                
            default:
                break;
        }
        //[self addSubview:_sliderButton];
        
        _sliderArea = [[TGAudioSliderArea alloc] init];
        _sliderArea.userInteractionEnabled = false;
        _sliderArea.delegate = self;
        [self addSubview:_sliderArea];
        
        _durationLabel = [[UILabel alloc] init];
        _durationLabel.textAlignment = NSTextAlignmentLeft;
        _durationLabel.backgroundColor = [UIColor clearColor];
        _durationLabel.font = TGSystemFontOfSize(11.0f);
        [self addSubview:_durationLabel];
        _durationLabelSeconds = -1;
        
        _statusIconView = [[UIImageView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 3.0f, 3.0f)];
        [self addSubview:_statusIconView];
        
        _waveformDisposable = [[SMetaDisposable alloc] init];
    }
    return self;
}

- (void)dealloc
{
    [_waveformDisposable dispose];
}

- (void)setPresentation:(TGPresentation *)presentation
{
    _presentation = presentation;
    if (_presentation == nil)
        return;
    
    _durationLabel.textColor = [self durationColor:_style presentation:presentation];
    _statusIconView.image = [self listenedStatusImage:_style presentation:presentation];
    
    switch (_style)
    {
        case TGAudioSliderViewStyleIncoming:
            [_waveformView setForegroundColor:presentation.pallete.chatIncomingAudioForegroundColor backgroundColor:presentation.pallete.chatIncomingAudioBackgroundColor];
            break;
            
        case TGAudioSliderViewStyleOutgoing:
            [_waveformView setForegroundColor:presentation.pallete.chatOutgoingAudioForegroundColor backgroundColor:presentation.pallete.chatOutgoingAudioBackgroundColor];
            break;
            
        default:
            break;
    }
}

- (void)willBecomeRecycled
{
    [_waveformDisposable setDisposable:nil];
    [_waveformView setWaveform:nil];
    
    [self pop_removeAnimationForKey:@"scrubbingIndicator"];
    
    _immediateProgress = 0.0f;
}

- (void)setStyle:(TGAudioSliderViewStyle)style
{
    if (_style != style)
    {
        _style = style;
        
        switch (_style)
        {
            case TGAudioSliderViewStyleIncoming:
                [_waveformView setForegroundColor:_presentation.pallete.chatIncomingAudioForegroundColor backgroundColor:_presentation.pallete.chatIncomingAudioBackgroundColor];
                break;
                
            case TGAudioSliderViewStyleOutgoing:
                [_waveformView setForegroundColor:_presentation.pallete.chatOutgoingAudioForegroundColor backgroundColor:_presentation.pallete.chatOutgoingAudioBackgroundColor];
                
            case TGAudioSliderViewStyleNotification:
                [_waveformView setForegroundColor:UIColorRGB(0xf6f6f6) backgroundColor:UIColorRGB(0xf6f6f6)];
                break;
                
            default:
                break;
        }
        
        _durationLabel.textColor = [self durationColor:_style presentation:_presentation];
        if (_style == TGAudioSliderViewStyleNotification)
        {
            _durationLabel.font = TGSystemFontOfSize(13.0f);
            _durationLabel.textAlignment = NSTextAlignmentCenter;
        }
        
        _statusIconView.image = [self listenedStatusImage:_style presentation:_presentation];
    }
    
    [self setNeedsLayout];
}

- (void)setDurationLabelFromSeconds:(int32_t)seconds {
    if (_durationLabelSeconds != seconds) {
        _durationLabelSeconds = seconds;
        _durationLabel.text = [[NSString alloc] initWithFormat:@"%d:%02d", seconds / 60, seconds % 60];
        [_durationLabel sizeToFit];
    }
}

- (void)setDuration:(int32_t)duration
{
    _duration = duration;
    int32_t seconds = (int32_t)duration;
    if (_status == nil) {
        [self setDurationLabelFromSeconds:seconds];
    }
}

- (void)setStatus:(TGMusicPlayerStatus *)status {
    _status = status;
    
    static POPAnimatableProperty *property = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^
    {
        property = [POPAnimatableProperty propertyWithName:@"playbackOffset" initializer:^(POPMutableAnimatableProperty *prop)
        {
            prop.readBlock = ^(TGAudioSliderView *strongSelf, CGFloat *values)
            {
                values[0] = strongSelf->_immediateProgress;
            };
            
            prop.writeBlock = ^(TGAudioSliderView *strongSelf, CGFloat const *values)
            {
                [strongSelf setImmediateProgress:values[0]];
                [strongSelf layoutProgress];
            };
        }];
    });
    
    if (status == nil || status.paused || status.duration < FLT_EPSILON || status.offset < 0.01)
    {
        [self pop_removeAnimationForKey:@"scrubbingIndicator"];
        
        if (status == nil) {
            if (_style == TGAudioSliderViewStyleIncoming && !_listenedStatus) {
                [self setImmediateProgress:1.0f];
            } else {
                [self setImmediateProgress:0.0f];
            }
        } else {
            [self setImmediateProgress:status.offset];
        }
        [self layoutProgress];
    }
    else
    {
        [self pop_removeAnimationForKey:@"scrubbingIndicator"];
        POPBasicAnimation *animation = [self pop_animationForKey:@"scrubbingIndicator"];
        if (animation == nil)
        {
            animation = [POPBasicAnimation linearAnimation];
            [animation setProperty:property];
            animation.removedOnCompletion = true;
            if (ABS(status.offset - _immediateProgress) < 0.3) {
                animation.fromValue = @(_immediateProgress);
            } else {
                animation.fromValue = @(status.offset);
            }
            animation.toValue = @(1.0f);
            animation.beginTime = status.timestamp;
            animation.duration = (1.0f - status.offset) * status.duration;
            [self pop_addAnimation:animation forKey:@"scrubbingIndicator"];
        }
    }
}

- (void)setWaveformSignal:(SSignal *)waveformSignal {
    __weak TGAudioSliderView *weakSelf = self;
    [_waveformDisposable setDisposable:[[waveformSignal deliverOn:[SQueue mainQueue]] startWithNext:^(TGAudioWaveform *waveform) {
        __strong TGAudioSliderView *strongSelf = weakSelf;
        if (strongSelf != nil) {
            [strongSelf->_waveformView setWaveform:waveform];
        }
    }]];
}

- (void)setImmediateProgress:(CGFloat)immediateProgress {
    _immediateProgress = immediateProgress;
    _waveformView.foregroundClippingView.frame = [self waveformClippingFrameForProgress:immediateProgress];
    
    if (_status == nil) {
        [self setDurationLabelFromSeconds:_duration];
    } else {
        [self setDurationLabelFromSeconds:(int32_t)(_status.duration - _status.offset * _status.duration)];
    }
}

- (void)setManualPositionAdjustmentEnabled:(bool)manualPositionAdjustmentEnabled
{
    if (_manualPositionAdjustmentEnabled != manualPositionAdjustmentEnabled)
    {
        _manualPositionAdjustmentEnabled = manualPositionAdjustmentEnabled;
        _sliderArea.userInteractionEnabled = _manualPositionAdjustmentEnabled;
    }
}

- (CGRect)waveformClippingFrameForProgress:(CGFloat)progress
{
    return CGRectMake(0.0f, 0.0f, CGFloor(_waveformView.backgroundView.frame.size.width * progress), 22.0f);
}

- (void)layoutProgress
{
    CGRect bounds = self.bounds;
    
    CGFloat progressValue = 0.0f;
    if (_isScrubbing) {
        progressValue = _scrubbingPosition;
    } else {
        progressValue = _immediateProgress;
    }
    
    CGRect sliderFrame = CGRectMake(2.0f, CGFloor((bounds.size.height - 22.0f) / 2.0f), bounds.size.width - 2.0f, 2.0f);
    
    _waveformView.frame = CGRectMake(2.0f, CGFloor((bounds.size.height - 22.0f) / 2.0f), bounds.size.width - 2.0f, 22.0f);
    
    [_waveformView backgroundView].frame = CGRectMake(0.0f, 0.0f, bounds.size.width - 2.0f, 22.0f);
    [_waveformView foregroundView].frame = CGRectMake(0.0f, 0.0f, bounds.size.width - 2.0f, 22.0f);
    
    _waveformView.foregroundClippingView.frame = [self waveformClippingFrameForProgress:progressValue];
    
    _sliderArea.frame = CGRectMake(sliderFrame.origin.x, 0.0f, sliderFrame.size.width, bounds.size.height);
}

- (void)setListenedStatus:(bool)listenedStatus
{
    _listenedStatus = listenedStatus;
    
    _statusIconView.hidden = listenedStatus;
    [self setNeedsLayout];
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    CGRect bounds = self.bounds;
    
    CGSize durationSize = _durationLabel.frame.size;
    if (_style == TGAudioSliderViewStyleNotification)
        _durationLabel.frame = CGRectMake(bounds.size.width, -1, 39, durationSize.height);
    else
        _durationLabel.frame = CGRectMake(0.0f, CGFloor((bounds.size.height - durationSize.height) / 2.0f) + 27.0f, durationSize.width, durationSize.height);
    _statusIconView.frame = CGRectMake(CGRectGetMaxX(_durationLabel.frame) + 2.0f + TGRetinaPixel, _durationLabel.frame.origin.y + 5.0f + TGRetinaPixel, _statusIconView.frame.size.width, _statusIconView.frame.size.height);
    
    [self layoutProgress];
}

- (void)audioSliderDidBeginDragging:(TGAudioSliderArea *)__unused sliderArea withTouch:(UITouch *)touch
{
    _isScrubbing = true;
    _scrubbingAbsoluteDistance = 0.0f;
    
    _sliderButtonStartLocation = [touch locationInView:self];
    _sliderButtonStartValue = (float)_status.offset;
    _scrubbingPosition = _sliderButtonStartValue;
    
    id<TGAudioSliderViewDelegate> delegate = _delegate;
    if ([delegate respondsToSelector:@selector(audioSliderViewDidBeginPositionAdjustment:)])
        [delegate audioSliderViewDidBeginPositionAdjustment:self];
}

- (void)audioSliderDidFinishDragging:(TGAudioSliderArea *)__unused sliderArea
{
    _isScrubbing = false;
    
    bool smallChange = ABS(_scrubbingAbsoluteDistance) < 2.0f;
    
    _scrubbingAbsoluteDistance = 0.0f;
    
    [self setDurationLabelFromSeconds:(int32_t)(_status.offset * _status.duration)];
    
    [self layoutProgress];
    
    id<TGAudioSliderViewDelegate> delegate = _delegate;
    if ([delegate respondsToSelector:@selector(audioSliderViewDidEndPositionAdjustment:atPosition:smallChange:)])
        [delegate audioSliderViewDidEndPositionAdjustment:self atPosition:_scrubbingPosition smallChange:smallChange];
}

- (void)audioSliderDidCancelDragging:(TGAudioSliderArea *)__unused sliderArea
{
    _isScrubbing = false;
    _scrubbingAbsoluteDistance = 0.0f;
    
    [self layoutProgress];
    
    [self setDurationLabelFromSeconds:(int32_t)(_status.offset * _status.duration)];
    
    id<TGAudioSliderViewDelegate> delegate = _delegate;
    if ([delegate respondsToSelector:@selector(audioSliderViewDidCancelPositionAdjustment:)])
        [delegate audioSliderViewDidCancelPositionAdjustment:self];
}

- (void)audioSliderWillMove:(TGAudioSliderButton *)__unused button withTouch:(UITouch *)touch
{
    if (_isScrubbing && _waveformView.frame.size.width > 1.0f)
    {
        CGFloat positionDistance = [touch locationInView:self].x - _sliderButtonStartLocation.x;
        if (ABS(_scrubbingAbsoluteDistance) < ABS(positionDistance)) {
            _scrubbingAbsoluteDistance = ABS(positionDistance);
        }
        
        CGRect bounds = self.bounds;
        CGRect sliderFrame = CGRectMake(2.0f, CGFloor((bounds.size.height - 22.0f) / 2.0f), bounds.size.width - 2.0f, 2.0f);
        
        CGFloat newValue = MAX(0.0f, MIN(1.0f, _sliderButtonStartValue + positionDistance / sliderFrame.size.width));
        _scrubbingPosition = newValue;
        int32_t currentPosition = (int32_t)(_status.duration * _scrubbingPosition);
        [self setDurationLabelFromSeconds:currentPosition];

        [self layoutProgress];
    }
}

@end
