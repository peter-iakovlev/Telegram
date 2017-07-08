/*
 * This is the source code of Telegram for iOS v. 1.1
 * It is licensed under GNU GPL v. 2 or later.
 * You should have received a copy of the license in this archive (see LICENSE).
 *
 * Copyright Peter Iakovlev, 2013.
 */

#import "TGAudioSliderView.h"

#import <MTProtoKit/MTTime.h>
#import "TGFont.h"

#import "TGAudioSliderButton.h"
#import "TGAudioSliderArea.h"

#import "TGImageUtils.h"

#import "TGAudioWaveformView.h"
#import "TGAudioWaveform.h"

#import "TGSharedMediaUtils.h"

#import "TGMusicPlayer.h"

#import <pop/POP.h>

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

- (UIImage *)trackImageWithColor:(UIColor *)color
{
    CGFloat radius = 2.0f;
    UIGraphicsBeginImageContextWithOptions(CGSizeMake(4.0f, 2.0f), false, 0.0f);
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGContextSetFillColorWithColor(context, color.CGColor);
    CGContextFillEllipseInRect(context, CGRectMake(0.0f, 0.0f, radius, radius));
    CGContextFillRect(context, CGRectMake(1.0f, 0.0f, 2.0f, 2.0f));
    CGContextFillEllipseInRect(context, CGRectMake(2.0f, 0.0f, radius, radius));
    
    UIImage *image = [UIGraphicsGetImageFromCurrentImageContext() stretchableImageWithLeftCapWidth:2 topCapHeight:0];
    UIGraphicsEndImageContext();
    
    return image;
}

- (UIImage *)trackImage:(TGAudioSliderViewStyle)style
{
    static UIImage *incomingImage = nil;
    static UIImage *outgoingImage = nil;
    static UIImage *notificationImage = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^
    {
        incomingImage = [self trackImageWithColor:UIColorRGB(0xd0d0d0)];
        outgoingImage = [self trackImageWithColor:UIColorRGB(0x9ce192)];
        notificationImage = [self trackImageWithColor:UIColorRGB(0x9c9c9c)];
    });
    
    switch (style)
    {
        case TGAudioSliderViewStyleIncoming:
            return incomingImage;
            
        case TGAudioSliderViewStyleOutgoing:
            return outgoingImage;
            
        case TGAudioSliderViewStyleNotification:
            return notificationImage;
            
        default:
            return nil;
    }
}

- (UIImage *)trackForegroundImage:(TGAudioSliderViewStyle)style
{
    static UIImage *incomingImage = nil;
    static UIImage *outgoingImage = nil;
    static UIImage *notificationImage = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^
    {
        incomingImage = [self trackImageWithColor:TGAccentColor()];
        outgoingImage = [self trackImageWithColor:UIColorRGB(0x3fc33b)];
        notificationImage = [self trackImageWithColor:[UIColor whiteColor]];
    });
    
    switch (style)
    {
        case TGAudioSliderViewStyleIncoming:
            return incomingImage;
            
        case TGAudioSliderViewStyleOutgoing:
            return outgoingImage;
            
        case TGAudioSliderViewStyleNotification:
            return notificationImage;
            
        default:
            return nil;
    }
}

- (UIImage *)thumbImageWithColor:(UIColor *)color
{
    UIGraphicsBeginImageContextWithOptions(CGSizeMake(5.0f, 14.0f), false, 0.0f);
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGContextSetFillColorWithColor(context, color.CGColor);
    CGContextFillRect(context, CGRectMake(2.0f, 0.0f, 1.5f, 14.0f));
    
    UIImage *image = [UIGraphicsGetImageFromCurrentImageContext() stretchableImageWithLeftCapWidth:2 topCapHeight:0];
    UIGraphicsEndImageContext();
    
    return image;
}

- (UIImage *)thumbImage:(TGAudioSliderViewStyle)style
{
    static UIImage *incomingImage = nil;
    static UIImage *outgoingImage = nil;
    static UIImage *notificationImage = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^
    {
        incomingImage = [self thumbImageWithColor:TGAccentColor()];
        outgoingImage = [self thumbImageWithColor:UIColorRGB(0x3fc33b)];
        notificationImage = [self thumbImageWithColor:UIColorRGB(0xf6f6f6)];
    });
    
    switch (style)
    {
        case TGAudioSliderViewStyleIncoming:
            return incomingImage;
            
        case TGAudioSliderViewStyleOutgoing:
            return outgoingImage;
            
        case TGAudioSliderViewStyleNotification:
            return notificationImage;
            
        default:
            return nil;
    }
}

- (UIImage *)emptyThumbImage
{
    static UIImage *image = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^
    {
        image = [self thumbImageWithColor:[UIColor clearColor]];
    });
    
    return image;
}

- (UIColor *)durationColor:(TGAudioSliderViewStyle)style
{
    static UIColor *incomingColor = nil;
    static UIColor *outgoingColor = nil;
    static UIColor *notificationColor = nil;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^
    {
        incomingColor = UIColorRGBA(0x525252, 0.6f);
        outgoingColor = UIColorRGBA(0x008c09, 0.8f);
        notificationColor = [UIColor whiteColor];
    });
    
    
    switch (style)
    {
        case TGAudioSliderViewStyleIncoming:
            return incomingColor;
            
        case TGAudioSliderViewStyleOutgoing:
            return outgoingColor;
            
        case TGAudioSliderViewStyleNotification:
            return notificationColor;
            
        default:
            return nil;
    }
}

- (UIImage *)circleImageWithColor:(UIColor *)color radius:(CGFloat)radius
{
    UIGraphicsBeginImageContextWithOptions(CGSizeMake(radius, radius), false, 0.0f);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetFillColorWithColor(context, [color CGColor]);
    CGContextFillEllipseInRect(context, CGRectMake(0.0f, 0.0f, radius, radius));
    UIImage *result = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return result;
}

- (UIImage *)listenedStatusImage:(TGAudioSliderViewStyle)style
{
    static UIImage *incomingImage = nil;
    static UIImage *outgoingImage = nil;

    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^
    {
        incomingImage = [self circleImageWithColor:UIColorRGB(0x1581e2) radius:3.0f];
        outgoingImage = [self circleImageWithColor:UIColorRGB(0x19c700) radius:3.0f];
    });
    

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
        _durationLabel.textColor = [self durationColor:_style];
        _durationLabel.font = TGSystemFontOfSize(11.0f);
        [self addSubview:_durationLabel];
        _durationLabelSeconds = -1;
        
        _statusIconView = [[UIImageView alloc] initWithImage:[self listenedStatusImage:_style]];
        [self addSubview:_statusIconView];
        
        _waveformDisposable = [[SMetaDisposable alloc] init];
    }
    return self;
}

- (void)dealloc
{
    [_waveformDisposable dispose];
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
                [_waveformView setForegroundColor:TGAccentColor() backgroundColor:UIColorRGB(0xced9e0)];
                break;
                
            case TGAudioSliderViewStyleOutgoing:
                [_waveformView setForegroundColor:UIColorRGB(0x3fc33b) backgroundColor:UIColorRGB(0x93d987)];
                break;
                
            case TGAudioSliderViewStyleNotification:
                [_waveformView setForegroundColor:UIColorRGB(0xf6f6f6) backgroundColor:UIColorRGB(0xf6f6f6)];
                break;
                
            default:
                break;
        }
        
        _durationLabel.textColor = [self durationColor:_style];
        if (_style == TGAudioSliderViewStyleNotification)
        {
            _durationLabel.font = TGSystemFontOfSize(13.0f);
            _durationLabel.textAlignment = NSTextAlignmentCenter;
        }
        
        _statusIconView.image = [self listenedStatusImage:_style];
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
