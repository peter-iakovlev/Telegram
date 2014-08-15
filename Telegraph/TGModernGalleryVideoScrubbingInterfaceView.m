#import "TGModernGalleryVideoScrubbingInterfaceView.h"

#import "TGFont.h"

#import "TGAudioSliderArea.h"

#import <MTProtoKit/MTTime.h>

static CGFloat insetLeft = 4.0f;
static CGFloat insetRight = 4.0f;
static CGFloat scrubberPadding = 5.0f;
static CGFloat scrubberInternalInset = 4.0f;

@interface TGModernGalleryVideoScrubbingInterfaceView () <TGAudioSliderAreaDelegate>
{
    UILabel *_currentTimeLabel;
    UILabel *_durationLabel;
    
    UIImageView *_scrubberBackground;
    UIImageView *_scrubberForegroundImage;
    UIView *_scrubberForegroundContainer;
    UIImageView *_scrubberHandle;
    TGAudioSliderArea *_sliderArea;
    
    CGFloat _position;
    bool _isScrubbing;
    CGPoint _sliderButtonStartLocation;
    float _sliderButtonStartValue;
    CGFloat _scrubbingPosition;
    bool _isPlaying;
    MTAbsoluteTime _positionTimestamp;
    NSTimeInterval _duration;
}

@end

@implementation TGModernGalleryVideoScrubbingInterfaceView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self != nil)
    {
        _currentTimeLabel = [[UILabel alloc] init];
        _currentTimeLabel.font = TGSystemFontOfSize(12.0f);
        _currentTimeLabel.backgroundColor = [UIColor clearColor];
        _currentTimeLabel.textColor = [UIColor whiteColor];
        [self addSubview:_currentTimeLabel];

        _durationLabel = [[UILabel alloc] init];
        _durationLabel.font = TGSystemFontOfSize(12.0f);
        _durationLabel.backgroundColor = [UIColor clearColor];
        _durationLabel.textColor = [UIColor whiteColor];
        [self addSubview:_durationLabel];
        
        UIImage *scrubberBackgroundImageRaw = [UIImage imageNamed:@"VideoSliderBackground.png"];
        _scrubberBackground = [[UIImageView alloc] initWithImage:[scrubberBackgroundImageRaw stretchableImageWithLeftCapWidth:(int)(scrubberBackgroundImageRaw.size.width / 2.0f) topCapHeight:0]];
        [self addSubview:_scrubberBackground];
        
        UIImage *scrubberForegroundImageRaw = [UIImage imageNamed:@"VideoSliderForeground.png"];
        _scrubberForegroundImage = [[UIImageView alloc] initWithImage:[scrubberForegroundImageRaw stretchableImageWithLeftCapWidth:(int)(scrubberForegroundImageRaw.size.width / 2.0f) topCapHeight:0]];
        
        _scrubberForegroundContainer = [[UIView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 0.0f, scrubberForegroundImageRaw.size.height)];
        _scrubberForegroundContainer.clipsToBounds = true;
        [self addSubview:_scrubberForegroundContainer];
        
        [_scrubberForegroundContainer addSubview:_scrubberForegroundImage];
        
        _scrubberHandle = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"VideoSliderHandle.png"]];
        [self addSubview:_scrubberHandle];
        
        _sliderArea = [[TGAudioSliderArea alloc] init];
        _sliderArea.delegate = self;
        _sliderArea.userInteractionEnabled = false;
        [self addSubview:_sliderArea];
    }
    return self;
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

- (void)addBoundsAnimationToLayer:(CALayer *)layer from:(CGRect)fromFrame to:(CGRect)toFrame duration:(NSTimeInterval)duration
{
    layer.bounds = fromFrame;
    CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"bounds"];
    animation.fromValue = [NSValue valueWithCGRect:fromFrame];
    animation.toValue = [NSValue valueWithCGRect:toFrame];
    animation.duration = duration;
    animation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionLinear];
    animation.removedOnCompletion = true;
    animation.fillMode = kCAFillModeForwards;
    [layer addAnimation:animation forKey:@"bounds"];
    layer.bounds = toFrame;
}

- (void)removeRelevantAnimationsFromLayer:(CALayer *)layer
{
    [layer removeAnimationForKey:@"position"];
    [layer removeAnimationForKey:@"bounds"];
}

- (void)addFrameAnimationToLayer:(CALayer *)layer from:(CGRect)fromFrame to:(CGRect)toFrame duration:(NSTimeInterval)duration
{
    [self addPositionAnimationToLayer:layer from:CGPointMake(CGRectGetMidX(fromFrame), CGRectGetMidY(fromFrame)) to:CGPointMake(CGRectGetMidX(toFrame), CGRectGetMidY(toFrame)) duration:duration];
    [self addBoundsAnimationToLayer:layer from:(CGRect){CGPointZero, fromFrame.size} to:(CGRect){CGPointZero, toFrame.size} duration:duration];
}

- (CGRect)sliderForegroundFrameForProgress:(CGFloat)progress
{
    CGFloat scrubberOriginX = CGRectGetMaxX(_currentTimeLabel.frame) + scrubberPadding;
    return (CGRect){{scrubberOriginX, CGFloor((self.frame.size.height - _scrubberForegroundContainer.frame.size.height) / 2.0f)}, {CGFloor((_scrubberBackground.frame.size.width) * progress), _scrubberForegroundContainer.frame.size.height}};
}

- (CGRect)sliderButtonFrameForProgress:(CGFloat)progress
{
    CGFloat scrubberOriginX = CGRectGetMaxX(_currentTimeLabel.frame) + scrubberPadding;
    return (CGRect){{scrubberOriginX - scrubberInternalInset + CGFloor((_scrubberBackground.frame.size.width - (_scrubberHandle.frame.size.width - scrubberInternalInset * 2.0f))  * progress), CGFloor((self.frame.size.height - _scrubberHandle.frame.size.height) / 2.0f)}, _scrubberHandle.frame.size};
}

- (void)updatePositionAnimations:(bool)immediate
{
    if (_isPlaying && !_isScrubbing && _duration > 0.1)
    {
        CGPoint handleStartPosition = ((CALayer *)_scrubberHandle.layer.presentationLayer).position;
        CGRect foregroundStartFrame = ((CALayer *)_scrubberForegroundContainer.layer.presentationLayer).frame;
        
        [self removeRelevantAnimationsFromLayer:_scrubberHandle.layer];
        [self removeRelevantAnimationsFromLayer:_scrubberForegroundContainer.layer];
        
        float playedProgress = MAX(0.0f, MIN(1.0f, (float)((MTAbsoluteSystemTime() - _positionTimestamp) / _duration)));
        
        CGRect handlePositionFrame = [self sliderButtonFrameForProgress:_position + playedProgress];
        CGRect foregroundFrame = [self sliderForegroundFrameForProgress:_position + playedProgress];
        CGPoint handlePositionPosition = CGPointMake(CGRectGetMidX(handlePositionFrame), CGRectGetMidY(handlePositionFrame));
        
        if (immediate || (handlePositionFrame.origin.x > [self sliderButtonFrameForProgress:0.0f].origin.x + FLT_EPSILON && (handlePositionPosition.x < handleStartPosition.x - 50.0f)))
        {
            handleStartPosition = handlePositionPosition;
            foregroundStartFrame = foregroundFrame;
        }
        
        CGRect handleEndFrame = [self sliderButtonFrameForProgress:1.0f];
        CGPoint handleEndPosition = CGPointMake(CGRectGetMidX(handleEndFrame), CGRectGetMidY(handleEndFrame));
        CGRect foregroundEndFrame = [self sliderForegroundFrameForProgress:1.0f];
        
        NSTimeInterval duration = MAX(0.0, _duration - _position * _duration);
        
        [self addPositionAnimationToLayer:_scrubberHandle.layer from:handleStartPosition to:handleEndPosition duration:duration];
        [self addFrameAnimationToLayer:_scrubberForegroundContainer.layer from:foregroundStartFrame to:foregroundEndFrame duration:duration];
    }
    else
    {
        float progressValue = _isScrubbing ? _scrubbingPosition : _position;
        
        [self removeRelevantAnimationsFromLayer:_scrubberHandle.layer];
        [self removeRelevantAnimationsFromLayer:_scrubberForegroundContainer.layer];
        
        CGRect handleCurrentFrame = [self sliderButtonFrameForProgress:progressValue];
        CGPoint handleCurrentPosition = CGPointMake(CGRectGetMidX(handleCurrentFrame), CGRectGetMidY(handleCurrentFrame));
        _scrubberHandle.layer.position = handleCurrentPosition;
        
        _scrubberForegroundContainer.layer.frame = [self sliderForegroundFrameForProgress:progressValue];
    }
}

- (void)setDuration:(NSTimeInterval)duration currentTime:(NSTimeInterval)currentTime isPlaying:(bool)isPlaying isPlayable:(bool)isPlayable animated:(bool)animated
{
    NSString *currentTimeString = @"-:--";
    NSString *durationString = @"-:--";
    if (duration < DBL_EPSILON)
    {
        _position = 0.0f;
    }
    else
    {
        currentTimeString = [[NSString alloc] initWithFormat:@"%d:%02d", ((int)currentTime) / 60, ((int)currentTime) % 60];
        durationString = [[NSString alloc] initWithFormat:@"%d:%02d", ((int)duration) / 60, ((int)duration) % 60];
        _position = MAX(0.0f, MIN(1.0f, (CGFloat)(currentTime / duration)));
    }
    
    if (!TGStringCompare(durationString, _durationLabel.text) || !TGStringCompare(currentTimeString, _currentTimeLabel.text))
    {
        _durationLabel.text = durationString;
        _currentTimeLabel.text = currentTimeString;
        [self setNeedsLayout];
    }
    
    _isPlaying = isPlaying;
    
    _sliderArea.userInteractionEnabled = isPlayable;
    
    _duration = duration;
    _positionTimestamp = MTAbsoluteSystemTime();
    
    if (!_isScrubbing)
    {
        if (_isPlaying && _duration > 0.1)
            [self updatePositionAnimations:false];
        else
        {
            if (animated)
            {
                [UIView animateWithDuration:0.2 delay:0 options:UIViewAnimationOptionBeginFromCurrentState animations:^
                {
                    _scrubberHandle.frame = [self sliderButtonFrameForProgress:_position];
                    _scrubberForegroundContainer.frame = [self sliderForegroundFrameForProgress:_position];
                } completion:nil];
            }
            else
                [self layoutSubviews];
        }
    }
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    [_durationLabel sizeToFit];
    [_currentTimeLabel sizeToFit];
    
    float progressValue = _isScrubbing ? _scrubbingPosition : _position;
    
    _currentTimeLabel.frame = (CGRect){{insetLeft, CGFloor((self.frame.size.height - _currentTimeLabel.frame.size.height) / 2.0f)}, _currentTimeLabel.frame.size};
    
    _durationLabel.frame = (CGRect){{self.frame.size.width - insetRight - _durationLabel.frame.size.width, CGFloor((self.frame.size.height - _durationLabel.frame.size.height) / 2.0f)}, _durationLabel.frame.size};
    
    CGFloat scrubberOriginX = CGRectGetMaxX(_currentTimeLabel.frame) + scrubberPadding;
    _scrubberBackground.frame = (CGRect){{scrubberOriginX, CGFloor((self.frame.size.height - _scrubberBackground.frame.size.height) / 2.0f)}, {_durationLabel.frame.origin.x - scrubberPadding - scrubberOriginX, _scrubberBackground.frame.size.height}};
    
    _sliderArea.frame = CGRectMake(0.0f, 0.0f, self.frame.size.width, self.frame.size.height);
    
    _scrubberForegroundImage.frame = _scrubberBackground.bounds;
    
    [self removeRelevantAnimationsFromLayer:_scrubberHandle.layer];
    [self removeRelevantAnimationsFromLayer:_scrubberForegroundContainer.layer];
    
    _scrubberForegroundContainer.frame = [self sliderForegroundFrameForProgress:progressValue];
    _scrubberHandle.frame = [self sliderButtonFrameForProgress:progressValue];
    
    [self updatePositionAnimations:false];
}

- (void)audioSliderDidBeginDragging:(TGAudioSliderArea *)__unused sliderArea withTouch:(UITouch *)touch
{
    _isScrubbing = true;
    
    _sliderButtonStartLocation = [touch locationInView:self];
    _sliderButtonStartValue = _position;
    _scrubbingPosition = _position;
    
    [self updatePositionAnimations:false];
    
    if (_scrubbingBegan)
        _scrubbingBegan();
}

- (void)audioSliderDidFinishDragging:(TGAudioSliderArea *)__unused sliderArea
{
    _isScrubbing = false;
    
    [self updatePositionAnimations:false];
    
    if (_scrubbingFinished)
        _scrubbingFinished(_scrubbingPosition);
}

- (void)audioSliderDidCancelDragging:(TGAudioSliderArea *)__unused sliderArea
{
    _isScrubbing = false;
    
    int currentPosition = (int)(_duration * _position);
    
    _currentTimeLabel.text = [[NSString alloc] initWithFormat:@"%d:%02d", currentPosition / 60, currentPosition % 60];
    [_currentTimeLabel sizeToFit];
    
    [self setNeedsLayout];
    
    if (_scrubbingCancelled)
        _scrubbingCancelled();
}

- (void)audioSliderWillMove:(TGAudioSliderArea *)__unused sliderArea withTouch:(UITouch *)touch
{
    if (_isScrubbing && _scrubberBackground.frame.size.width > 1.0f)
    {
        CGFloat positionDistance = [touch locationInView:self].x - _sliderButtonStartLocation.x;
        
        float newValue = MAX(0.0f, MIN(1.0f, _sliderButtonStartValue + positionDistance / _scrubberBackground.frame.size.width));
        _scrubbingPosition = newValue;
        int currentPosition = (int)(_duration * _scrubbingPosition);

        _currentTimeLabel.text = [[NSString alloc] initWithFormat:@"%d:%02d", currentPosition / 60, currentPosition % 60];
        [_currentTimeLabel sizeToFit];
        
        [self setNeedsLayout];
        
        if (_scrubbingChanged)
            _scrubbingChanged(_scrubbingPosition);
    }
}

@end
