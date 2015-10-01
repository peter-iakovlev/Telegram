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

@interface TGAudioSliderView () <TGAudioSliderAreaDelegate>
{
    UIImageView *_sliderBackgroundView;
    UIView *_sliderForegroundContainer;
    UIImageView *_sliderForegroundView;
    
    CGPoint _sliderButtonStartLocation;
    float _sliderButtonStartValue;
    TGAudioSliderButton *_sliderButton;
    TGAudioSliderArea *_sliderArea;
    
    UILabel *_durationLabel;
    
    UIImageView *_statusIconView;
    
    bool _isScrubbing;
    
    CGFloat _scrubbingPosition;
    
    bool _isPlaying;
    float _audioPosition;
    MTAbsoluteTime _audioPositionTimestamp;
    
    bool _immediatePositionOnLayout;
    CGFloat _previousWidth;
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

- (UIImage *)trackImage:(bool)incoming
{
    static UIImage *incomingImage = nil;
    static UIImage *outgoingImage = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^
    {
        incomingImage = [self trackImageWithColor:UIColorRGB(0xd0d0d0)];
        outgoingImage = [self trackImageWithColor:UIColorRGB(0x9ce192)];
    });
    
    return incoming ? incomingImage : outgoingImage;
}

- (UIImage *)trackForegroundImage:(bool)incoming
{
    static UIImage *incomingImage = nil;
    static UIImage *outgoingImage = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^
    {
        incomingImage = [self trackImageWithColor:TGAccentColor()];
        outgoingImage = [self trackImageWithColor:UIColorRGB(0x3fc33b)];
    });
    
    return incoming ? incomingImage : outgoingImage;
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

- (UIImage *)thumbImage:(bool)incoming
{
    static UIImage *incomingImage = nil;
    static UIImage *outgoingImage = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^
    {
        incomingImage = [self thumbImageWithColor:TGAccentColor()];
        outgoingImage = [self thumbImageWithColor:UIColorRGB(0x3fc33b)];
    });
    
    return incoming ? incomingImage : outgoingImage;
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

- (UIColor *)durationColor:(bool)incoming
{
    static UIColor *incomingColor = nil;
    static UIColor *outgoingColor = nil;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^
    {
        incomingColor = UIColorRGBA(0x525252, 0.6f);
        outgoingColor = UIColorRGBA(0x008c09, 0.8f);
    });
    
    return incoming ? incomingColor : outgoingColor;
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

- (UIImage *)listenedStatusImageForIncoming:(bool)incoming
{
    static UIImage *incomingImage = nil;
    static UIImage *outgoingImage = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^
    {
        incomingImage = [self circleImageWithColor:UIColorRGB(0x1581e2) radius:3.0f];
        outgoingImage = [self circleImageWithColor:UIColorRGB(0x19c700) radius:3.0f];
    });
    return incoming ? incomingImage : outgoingImage;
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
    {
        _sliderBackgroundView = [[UIImageView alloc] initWithImage:[self trackImage:_incoming]];
        [self addSubview:_sliderBackgroundView];
        
        _sliderForegroundView = [[UIImageView alloc] initWithImage:[self trackForegroundImage:_incoming]];
        _sliderForegroundContainer = [[UIView alloc] init];
        _sliderForegroundContainer.clipsToBounds = true;
        [_sliderForegroundContainer addSubview:_sliderForegroundView];
        [self addSubview:_sliderForegroundContainer];
        
        _sliderButton = [[TGAudioSliderButton alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 2.0f, 14.0f)];
        [_sliderButton setColor:_incoming ? TGAccentColor() : UIColorRGB(0x3fc33b)];
        [self addSubview:_sliderButton];
        
        _sliderArea = [[TGAudioSliderArea alloc] init];
        _sliderArea.userInteractionEnabled = false;
        _sliderArea.delegate = self;
        [self addSubview:_sliderArea];
        
        _durationLabel = [[UILabel alloc] init];
        _durationLabel.textAlignment = NSTextAlignmentLeft;
        _durationLabel.backgroundColor = [UIColor clearColor];
        _durationLabel.textColor = [self durationColor:_incoming];
        _durationLabel.font = TGSystemFontOfSize(11.0f);
        [self addSubview:_durationLabel];
        
        _statusIconView = [[UIImageView alloc] initWithImage:[self listenedStatusImageForIncoming:_incoming]];
        [self addSubview:_statusIconView];
    }
    return self;
}

- (void)dealloc
{
    
}

- (void)willBecomeRecycled
{
}

- (void)setIncoming:(bool)incoming
{
    if (_incoming != incoming)
    {
        _incoming = incoming;
        
        _sliderBackgroundView.image = [self trackImage:_incoming];
        _sliderForegroundView.image = [self trackForegroundImage:_incoming];
        [_sliderButton setColor:_incoming ? TGAccentColor() : UIColorRGB(0x3fc33b)];
        
        _durationLabel.textColor = [self durationColor:_incoming];
        
        _statusIconView.image = [self listenedStatusImageForIncoming:_incoming];
    }
}

- (void)setAudioDurationText:(NSString *)audioDurationText
{
    if (!TGStringCompare(audioDurationText, _audioDurationText))
    {
        _audioDurationText = audioDurationText;
        
        if (!_isScrubbing || _duration < DBL_EPSILON)
        {
            _durationLabel.text = _audioDurationText;
            [_durationLabel sizeToFit];
            [self setNeedsLayout];
        }
    }
}

- (void)setAudioPosition:(float)audioPosition animated:(bool)animated timestamp:(NSTimeInterval)timestamp isPlaying:(bool)isPlaying immediate:(bool)immediate
{
    if (ABS(_audioPosition - audioPosition) > FLT_EPSILON || ABS(_audioPositionTimestamp - timestamp) > DBL_EPSILON || _isPlaying != isPlaying)
    {
        _audioPosition = audioPosition;
        _audioPositionTimestamp = timestamp;
        _isPlaying = isPlaying;
        
        if (!_isScrubbing)
        {
            if (_isPlaying && _preciseDuration > FLT_EPSILON)
                [self updatePositionAnimations:immediate];
            else
            {
                if (animated)
                {
                    [UIView animateWithDuration:0.2 delay:0 options:UIViewAnimationOptionBeginFromCurrentState animations:^
                    {
                        _sliderForegroundContainer.frame = [self foregdoundFrameForProgress:audioPosition];
                        _sliderButton.frame = [self sliderButtonFrameForProgress:audioPosition];
                    } completion:nil];
                }
                else
                    [self layoutProgress];
            }
        }
    }
}

- (void)stopAnimations
{
    [_sliderButton.layer removeAnimationForKey:@"position"];
    [_sliderForegroundContainer.layer removeAnimationForKey:@"position"];
    [_sliderForegroundContainer.layer removeAnimationForKey:@"bounds"];
    _immediatePositionOnLayout = true;
}

- (void)addPositionAnimationToLayer:(CALayer *)layer from:(CGPoint)fromPoint to:(CGPoint)toPoint duration:(NSTimeInterval)duration
{
    layer.position = fromPoint;
    CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"position"];
    animation.fromValue = [NSValue valueWithCGPoint:fromPoint];
    animation.toValue = [NSValue valueWithCGPoint:toPoint];
    animation.duration = duration;
    animation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionLinear];
    animation.removedOnCompletion = true;
    animation.fillMode = kCAFillModeForwards;
    [layer addAnimation:animation forKey:@"position"];
    layer.position = toPoint;
}

- (void)addBoundsAnimationToLayer:(CALayer *)layer from:(CGRect)fromBounds to:(CGRect)toBounds duration:(NSTimeInterval)duration
{
    layer.bounds = fromBounds;
    CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"bounds"];
    animation.fromValue = [NSValue valueWithCGRect:fromBounds];
    animation.toValue = [NSValue valueWithCGRect:toBounds];
    animation.duration = duration;
    animation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionLinear];
    animation.removedOnCompletion = true;
    animation.fillMode = kCAFillModeForwards;
    [layer addAnimation:animation forKey:@"bounds"];
    layer.bounds = toBounds;
}

- (void)updatePositionAnimations:(bool)immediate
{
    if (_isPlaying && !_isScrubbing && _preciseDuration > 0.1)
    {
        CGPoint handleStartPosition = (_sliderButton.layer.presentationLayer == nil ? _sliderButton.layer : ((CALayer *)_sliderButton.layer.presentationLayer)).position;
        CGPoint foregroundStartPosition = (_sliderForegroundContainer.layer.presentationLayer == nil ? _sliderForegroundContainer.layer : ((CALayer *)_sliderForegroundContainer.layer.presentationLayer)).position;
        CGRect foregroundStartBounds = (_sliderForegroundContainer.layer.presentationLayer == nil ? _sliderForegroundContainer.layer : ((CALayer *)_sliderForegroundContainer.layer.presentationLayer)).bounds;
        [_sliderButton.layer removeAnimationForKey:@"position"];
        [_sliderForegroundContainer.layer removeAnimationForKey:@"position"];
        [_sliderForegroundContainer.layer removeAnimationForKey:@"bounds"];

        float playedProgress = MAX(0.0f, MIN(1.0f, (float)((MTAbsoluteSystemTime() - _audioPositionTimestamp) / _preciseDuration)));
        
        CGRect handlePositionFrame = [self sliderButtonFrameForProgress:_audioPosition + playedProgress];
        CGPoint handlePositionPosition = CGPointMake(CGRectGetMidX(handlePositionFrame), CGRectGetMidY(handlePositionFrame));
        
        CGRect foregroundPositionFrame = [self foregdoundFrameForProgress:_audioPosition + playedProgress];
        CGPoint foregroundPositionPosition = CGPointMake(foregroundPositionFrame.origin.x + foregroundPositionFrame.size.width / 2.0f, foregroundPositionFrame.origin.y + foregroundPositionFrame.size.height / 2.0f);
        CGRect foregroundPositionBounds = CGRectMake(0.0f, 0.0f, foregroundPositionFrame.size.width, foregroundPositionFrame.size.height);

        if (immediate || (handlePositionFrame.origin.x > [self sliderButtonFrameForProgress:0.0f].origin.x + FLT_EPSILON && (handlePositionPosition.x < handleStartPosition.x - 50.0f)))
        {
            handleStartPosition = handlePositionPosition;
            foregroundStartPosition = foregroundPositionPosition;
            foregroundStartBounds = foregroundPositionBounds;
        }

        CGRect handleEndFrame = [self sliderButtonFrameForProgress:1.0f];
        CGPoint handleEndPosition = CGPointMake(CGRectGetMidX(handleEndFrame), CGRectGetMidY(handleEndFrame));
        
        CGRect foregroundEndFrame = [self foregdoundFrameForProgress:1.0f];
        CGPoint foregroundEndPosition = CGPointMake(foregroundEndFrame.origin.x + foregroundEndFrame.size.width / 2.0f, foregroundEndFrame.origin.y + foregroundEndFrame.size.height / 2.0f);
        CGRect foregroundEndBounds = CGRectMake(0.0f, 0.0f, foregroundEndFrame.size.width, foregroundEndFrame.size.height);

        NSTimeInterval duration = MAX(0.0, _preciseDuration - _audioPosition * _preciseDuration);
        
        [self addPositionAnimationToLayer:_sliderButton.layer from:handleStartPosition to:handleEndPosition duration:duration];
        [self addPositionAnimationToLayer:_sliderForegroundContainer.layer from:foregroundStartPosition to:foregroundEndPosition duration:duration];
        [self addBoundsAnimationToLayer:_sliderForegroundContainer.layer from:foregroundStartBounds to:foregroundEndBounds duration:duration];
    }
    else
    {
        CGFloat progressValue = _isScrubbing ? _scrubbingPosition : _audioPosition;
        
        [_sliderButton.layer removeAnimationForKey:@"position"];
        CGRect handleCurrentFrame = [self sliderButtonFrameForProgress:progressValue];
        CGPoint handleCurrentPosition = CGPointMake(CGRectGetMidX(handleCurrentFrame), CGRectGetMidY(handleCurrentFrame));
        _sliderButton.layer.position = handleCurrentPosition;
        
        [_sliderForegroundContainer.layer removeAnimationForKey:@"position"];
        [_sliderForegroundContainer.layer removeAnimationForKey:@"bounds"];
        _sliderForegroundContainer.layer.frame = [self foregdoundFrameForProgress:progressValue];
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

- (void)setProgressMode:(bool)progressMode
{
    if (_progressMode != progressMode)
    {
        _progressMode = progressMode;
        _sliderButton.hidden = progressMode;
    }
}

- (CGRect)sliderButtonFrameForProgress:(CGFloat)progress
{
    return CGRectMake(_sliderBackgroundView.frame.origin.x + CGFloor((_sliderBackgroundView.frame.size.width - 1.0f) * progress) - 0.5f, CGFloor((self.bounds.size.height - _sliderButton.frame.size.height) / 2.0f), _sliderButton.frame.size.width, _sliderButton.frame.size.height);
}

- (CGRect)foregdoundFrameForProgress:(CGFloat)progress
{
    return CGRectMake(_sliderBackgroundView.frame.origin.x, _sliderBackgroundView.frame.origin.y, CGFloor(_sliderBackgroundView.frame.size.width * progress), _sliderBackgroundView.frame.size.height);
}

- (void)layoutProgress
{
    if (!_progressMode)
    {
        [_sliderButton.layer removeAnimationForKey:@"position"];
        [_sliderForegroundContainer.layer removeAnimationForKey:@"position"];
        [_sliderForegroundContainer.layer removeAnimationForKey:@"bounds"];
    }
    
    CGRect bounds = self.bounds;
    
    CGFloat progressValue = _isScrubbing ? _scrubbingPosition : _audioPosition;
    
    CGRect sliderFrame = CGRectMake(2.0f, CGFloor((bounds.size.height - _sliderBackgroundView.frame.size.height) / 2.0f), bounds.size.width - 2.0f, 2.0f);
    _sliderBackgroundView.frame = sliderFrame;
    _sliderForegroundView.frame = CGRectMake(0.0f, 0.0f, sliderFrame.size.width, sliderFrame.size.height);
    _sliderForegroundContainer.frame = [self foregdoundFrameForProgress:progressValue];
    _sliderButton.frame = [self sliderButtonFrameForProgress:progressValue];
    
    _sliderArea.frame = CGRectMake(sliderFrame.origin.x, 0.0f, sliderFrame.size.width, bounds.size.height);
    
    if (!_progressMode)
    {
        [self updatePositionAnimations:_immediatePositionOnLayout];
        _immediatePositionOnLayout = false;
    }
}

- (void)setListenedStatus:(bool)listenedStatus
{
    _listenedStatus = listenedStatus;
    
    _statusIconView.hidden = listenedStatus;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    CGRect bounds = self.bounds;
    bool previousImmediatePositionOnLayout = _immediatePositionOnLayout;
    _previousWidth = bounds.size.width;
    
    CGSize durationSize = _durationLabel.frame.size;
    _durationLabel.frame = CGRectMake(0.0f, CGFloor((bounds.size.height - durationSize.height) / 2.0f) + 20.0f, durationSize.width, durationSize.height);
    _statusIconView.frame = CGRectMake(CGRectGetMaxX(_durationLabel.frame) + 2.0f + TGRetinaPixel, _durationLabel.frame.origin.y + 5.0f + TGRetinaPixel, _statusIconView.frame.size.width, _statusIconView.frame.size.height);
    
    [self layoutProgress];
    _immediatePositionOnLayout = previousImmediatePositionOnLayout;
}

- (void)audioSliderDidBeginDragging:(TGAudioSliderArea *)__unused sliderArea withTouch:(UITouch *)touch
{
    _isScrubbing = true;
    
    _sliderButtonStartLocation = [touch locationInView:self];
    _sliderButtonStartValue = _audioPosition;
    _scrubbingPosition = _audioPosition;
    
    [self updatePositionAnimations:false];
    
    id<TGAudioSliderViewDelegate> delegate = _delegate;
    if ([delegate respondsToSelector:@selector(audioSliderViewDidBeginPositionAdjustment:)])
        [delegate audioSliderViewDidBeginPositionAdjustment:self];
}

- (void)audioSliderDidFinishDragging:(TGAudioSliderArea *)__unused sliderArea
{
    _isScrubbing = false;
    
    [self updatePositionAnimations:false];
    
    id<TGAudioSliderViewDelegate> delegate = _delegate;
    if ([delegate respondsToSelector:@selector(audioSliderViewDidEndPositionAdjustment:atPosition:)])
        [delegate audioSliderViewDidEndPositionAdjustment:self atPosition:_scrubbingPosition];
}

- (void)audioSliderDidCancelDragging:(TGAudioSliderArea *)__unused sliderArea
{
    _isScrubbing = false;
    
    [self updatePositionAnimations:false];
    
    _durationLabel.text = _audioDurationText;
    [_durationLabel sizeToFit];
    [self setNeedsLayout];
    
    id<TGAudioSliderViewDelegate> delegate = _delegate;
    if ([delegate respondsToSelector:@selector(audioSliderViewDidCancelPositionAdjustment:)])
        [delegate audioSliderViewDidCancelPositionAdjustment:self];
}

- (void)audioSliderWillMove:(TGAudioSliderButton *)__unused button withTouch:(UITouch *)touch
{
    if (_isScrubbing && _sliderBackgroundView.frame.size.width > 1.0f)
    {
        CGFloat positionDistance = [touch locationInView:self].x - _sliderButtonStartLocation.x;
        
        CGFloat newValue = MAX(0.0f, MIN(1.0f, _sliderButtonStartValue + positionDistance / _sliderBackgroundView.frame.size.width));
        _scrubbingPosition = newValue;
        int currentPosition = (int)(_duration * _scrubbingPosition);
        if (_duration > DBL_EPSILON)
            _durationLabel.text = [[NSString alloc] initWithFormat:@"%d:%02d", currentPosition / 60, currentPosition % 60];
        [_durationLabel sizeToFit];

        [self updatePositionAnimations:false];
    }
}

@end
