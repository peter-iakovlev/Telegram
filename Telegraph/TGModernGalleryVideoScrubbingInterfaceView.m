#import "TGModernGalleryVideoScrubbingInterfaceView.h"

#import "TGFont.h"
#import "TGImageUtils.h"

#import "TGAudioSliderArea.h"
#import "TGModernButton.h"

#import <MTProtoKit/MTTime.h>

#import <POP/pop.h>

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
    
    TGModernButton *_pipButton;
    
    CGFloat _position;
    bool _isScrubbing;
    CGPoint _sliderButtonStartLocation;
    CGFloat _sliderButtonStartValue;
    CGFloat _scrubbingPosition;
    bool _isPlaying;
    CFAbsoluteTime _positionTimestamp;
    NSTimeInterval _duration;
    
    CGFloat _currentTimeMinWidth;
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
        
        static dispatch_once_t onceToken;
        static CGFloat currentTimeMinWidth;
        dispatch_once(&onceToken, ^
        {
            currentTimeMinWidth = floor([[[NSAttributedString alloc] initWithString:@"0:00" attributes:@{ NSFontAttributeName: _currentTimeLabel.font }] boundingRectWithSize:CGSizeMake(FLT_MAX, FLT_MAX) options:NSStringDrawingUsesLineFragmentOrigin context:nil].size.width) + TGRetinaPixel;
        });
        _currentTimeMinWidth = currentTimeMinWidth;
        
        _pipButton = [[TGModernButton alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 50.0f, 44.0f)];
        _pipButton.hidden = true;
        [_pipButton setImage:TGTintedImage([UIImage imageNamed:@"EmbedVideoPIPIcon"], [UIColor whiteColor]) forState:UIControlStateNormal];
        [_pipButton addTarget:self action:@selector(pipButtonPressed) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:_pipButton];
    }
    return self;
}

- (void)setFrame:(CGRect)frame
{
    //bool sizeUpdated = CGSizeEqualToSize(self.frame.size, frame.size);
    [super setFrame:CGRectOffset(frame, 5.0f, 0.0f)];
    
    [self _layout];
}

- (void)removeRelevantAnimationsFromView:(UIView *)layer
{
    [layer pop_removeAnimationForKey:@"progress"];
}

- (void)addFrameAnimationToView:(UIView *)view from:(CGRect)fromFrame to:(CGRect)toFrame duration:(NSTimeInterval)duration
{
    [self removeRelevantAnimationsFromView:view];

    {
        POPBasicAnimation *animation = [POPBasicAnimation linearAnimation];
        animation.fromValue = [NSValue valueWithCGRect:fromFrame];
        animation.toValue = [NSValue valueWithCGRect:toFrame];
        animation.duration = duration;
        animation.clampMode = kPOPAnimationClampBoth;
        animation.property = [POPAnimatableProperty propertyWithName:@"frame" initializer:^(POPMutableAnimatableProperty *prop) {
            prop.readBlock = ^(UIView *view, CGFloat *values) {
                CGRect frame = view.frame;
                memcpy(values, &frame, sizeof(CGFloat) * 4);
            };
            prop.writeBlock = ^(UIView *view, CGFloat const *values) {
                CGRect frame;
                memcpy(&frame, values, sizeof(CGFloat) * 4);
                view.frame = frame;
            };
            prop.threshold = 0.5f;
        }];
        [view pop_addAnimation:animation forKey:@"progress"];
    }
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
        CGPoint handleStartPosition = CGPointMake(CGRectGetMidX(_scrubberHandle.frame), CGRectGetMidY(_scrubberHandle.frame));
        CGRect foregroundStartFrame = _scrubberForegroundContainer.frame;
        
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
        CGRect foregroundEndFrame = [self sliderForegroundFrameForProgress:1.0f];
        
        NSTimeInterval duration = MAX(0.0, _duration - _position * _duration);
        
        CGRect handleStartFrame = CGRectMake(handleStartPosition.x - _scrubberHandle.frame.size.width / 2.0f, handleStartPosition.y - _scrubberHandle.frame.size.height / 2.0f, _scrubberHandle.frame.size.width, _scrubberHandle.frame.size.height);
        
        [self addFrameAnimationToView:_scrubberHandle from:handleStartFrame to:handleEndFrame duration:duration];
        [self addFrameAnimationToView:_scrubberForegroundContainer from:foregroundStartFrame to:foregroundEndFrame duration:duration];
    }
    else
    {
        CGFloat progressValue = _isScrubbing ? _scrubbingPosition : _position;
        
        [self removeRelevantAnimationsFromView:_scrubberHandle];
        [self removeRelevantAnimationsFromView:_scrubberForegroundContainer];
        
        CGRect handleCurrentFrame = [self sliderButtonFrameForProgress:progressValue];
        _scrubberHandle.frame = handleCurrentFrame;
        _scrubberForegroundContainer.frame = [self sliderForegroundFrameForProgress:progressValue];
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
        [self _layout];
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
                [self _layout];
        }
    }
}

- (void)_layout
{
    [_durationLabel sizeToFit];
    [_currentTimeLabel sizeToFit];
    
    CGFloat progressValue = _isScrubbing ? _scrubbingPosition : _position;
    
    _currentTimeLabel.frame = (CGRect){{insetLeft, CGFloor((self.frame.size.height - _currentTimeLabel.frame.size.height) / 2.0f)}, { MAX(_currentTimeMinWidth, _currentTimeLabel.frame.size.width), _currentTimeLabel.frame.size.height }};
    
    _durationLabel.frame = (CGRect){{self.frame.size.width - insetRight - _durationLabel.frame.size.width, CGFloor((self.frame.size.height - _durationLabel.frame.size.height) / 2.0f)}, _durationLabel.frame.size};
    
    CGFloat scrubberOriginX = CGRectGetMaxX(_currentTimeLabel.frame) + scrubberPadding;
    _scrubberBackground.frame = (CGRect){{scrubberOriginX, CGFloor((self.frame.size.height - _scrubberBackground.frame.size.height) / 2.0f)}, {_durationLabel.frame.origin.x - scrubberPadding - scrubberOriginX, _scrubberBackground.frame.size.height}};
    
    _sliderArea.frame = CGRectMake(0.0f, 0.0f, self.frame.size.width, self.frame.size.height);
    
    _scrubberForegroundImage.frame = _scrubberBackground.bounds;
    
    [self removeRelevantAnimationsFromView:_scrubberHandle];
    [self removeRelevantAnimationsFromView:_scrubberForegroundContainer];
    
    _scrubberForegroundContainer.frame = [self sliderForegroundFrameForProgress:progressValue];
    _scrubberHandle.frame = [self sliderButtonFrameForProgress:progressValue];
    
    _pipButton.frame = CGRectMake(self.frame.size.width + 23.0f, _pipButton.frame.origin.y, _pipButton.frame.size.width, _pipButton.frame.size.height);
    
    [self updatePositionAnimations:false];
}

- (void)audioSliderDidBeginDragging:(TGAudioSliderArea *)__unused sliderArea withTouch:(UITouch *)touch
{
    _isScrubbing = true;
    
    _sliderButtonStartLocation = [touch locationInView:self];
    _sliderButtonStartValue = _position;
    _scrubbingPosition = _position;
    
    [self removeRelevantAnimationsFromView:_scrubberHandle];
    [self removeRelevantAnimationsFromView:_scrubberForegroundContainer];
    [self updatePositionAnimations:false];
    
    if (_scrubbingBegan)
        _scrubbingBegan();
}

- (void)audioSliderDidFinishDragging:(TGAudioSliderArea *)__unused sliderArea
{
    [self removeRelevantAnimationsFromView:_scrubberHandle];
    [self removeRelevantAnimationsFromView:_scrubberForegroundContainer];
    [self updatePositionAnimations:false];
    
    _isScrubbing = false;
    
    if (_scrubbingFinished)
        _scrubbingFinished(_scrubbingPosition);
}

- (void)audioSliderDidCancelDragging:(TGAudioSliderArea *)__unused sliderArea
{
    _isScrubbing = false;
    
    int currentPosition = (int)(_duration * _position);
    
    _currentTimeLabel.text = [[NSString alloc] initWithFormat:@"%d:%02d", currentPosition / 60, currentPosition % 60];
    [_currentTimeLabel sizeToFit];
    
    [self _layout];
    
    if (_scrubbingCancelled)
        _scrubbingCancelled();
}

- (void)audioSliderWillMove:(TGAudioSliderArea *)__unused sliderArea withTouch:(UITouch *)touch
{
    if (_isScrubbing && _scrubberBackground.frame.size.width > 1.0f)
    {
        CGFloat positionDistance = [touch locationInView:self].x - _sliderButtonStartLocation.x;
        
        CGFloat newValue = MAX(0.0f, MIN(1.0f, _sliderButtonStartValue + positionDistance / _scrubberBackground.frame.size.width));
        _scrubbingPosition = newValue;
        int currentPosition = (int)(_duration * _scrubbingPosition);

        _currentTimeLabel.text = [[NSString alloc] initWithFormat:@"%d:%02d", currentPosition / 60, currentPosition % 60];
        [_currentTimeLabel sizeToFit];
        
        [self removeRelevantAnimationsFromView:_scrubberHandle];
        [self removeRelevantAnimationsFromView:_scrubberForegroundContainer];
        [self _layout];
        
        if (_scrubbingChanged)
            _scrubbingChanged(_scrubbingPosition);
    }
}

- (BOOL)pointInside:(CGPoint)point withEvent:(UIEvent *)event
{
    if (!_pipButton.hidden && CGRectContainsPoint(_pipButton.frame, point))
        return true;
    
    return [super pointInside:point withEvent:event];
}

- (void)setPictureInPictureHidden:(bool)hidden
{
    _pipButton.hidden = hidden;
}

- (void)setPictureInPictureEnabled:(bool)enabled
{
    _pipButton.enabled = enabled;
}

- (void)pipButtonPressed
{
    if (self.pipPressed != nil)
        self.pipPressed();
}

@end
