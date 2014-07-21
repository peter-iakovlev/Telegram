#import "TGModernGalleryVideoScrubbingInterfaceView.h"

#import "TGFont.h"

#import <MTProtoKit/MTTime.h>

static CGFloat insetLeft = 4.0f;
static CGFloat insetRight = 4.0f;
static CGFloat scrubberPadding = 5.0f;
static CGFloat scrubberHeight = 2.0f;
static CGFloat scrubberHandleWidth = 1.0f;
static CGFloat scrubberHandleHeight = 10.0f;

@interface TGModernGalleryVideoScrubbingInterfaceView ()
{
    UILabel *_currentTimeLabel;
    UILabel *_durationLabel;
    
    UIView *_scrubberBackground;
    UIView *_scrubberHandle;
    
    CGFloat _position;
    bool _isScrubbing;
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
        
        _scrubberBackground = [[UIView alloc] init];
        _scrubberBackground.backgroundColor = UIColorRGB(0x111111);
        [self addSubview:_scrubberBackground];
        
        _scrubberHandle = [[UIView alloc] init];
        _scrubberHandle.backgroundColor = [UIColor whiteColor];
        [self addSubview:_scrubberHandle];
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

- (CGRect)sliderButtonFrameForProgress:(CGFloat)progress
{
    CGFloat scrubberOriginX = CGRectGetMaxX(_currentTimeLabel.frame) + scrubberPadding;
    return (CGRect){{scrubberOriginX + CGFloor((_scrubberBackground.frame.size.width - scrubberHandleWidth)  * progress), CGFloor((self.frame.size.height - scrubberHandleHeight) / 2.0f) - 1.0f}, {scrubberHandleWidth, scrubberHandleHeight}};
}

- (void)updatePositionAnimations:(bool)immediate
{
    if (_isPlaying && !_isScrubbing && _duration > 0.1)
    {
        CGPoint handleStartPosition = ((CALayer *)_scrubberHandle.layer.presentationLayer).position;
        [_scrubberHandle.layer removeAnimationForKey:@"position"];
        
        float playedProgress = MAX(0.0f, MIN(1.0f, (float)((MTAbsoluteSystemTime() - _positionTimestamp) / _duration)));
        
        CGRect handlePositionFrame = [self sliderButtonFrameForProgress:_position + playedProgress];
        CGPoint handlePositionPosition = CGPointMake(CGRectGetMidX(handlePositionFrame), CGRectGetMidY(handlePositionFrame));
        
        if (immediate || (handlePositionFrame.origin.x > [self sliderButtonFrameForProgress:0.0f].origin.x + FLT_EPSILON && (handlePositionPosition.x < handleStartPosition.x - 50.0f)))
        {
            handleStartPosition = handlePositionPosition;
        }
        
        CGRect handleEndFrame = [self sliderButtonFrameForProgress:1.0f];
        CGPoint handleEndPosition = CGPointMake(CGRectGetMidX(handleEndFrame), CGRectGetMidY(handleEndFrame));
        
        NSTimeInterval duration = MAX(0.0, _duration - _position * _duration);
        
        [self addPositionAnimationToLayer:_scrubberHandle.layer from:handleStartPosition to:handleEndPosition duration:duration];
    }
    else
    {
        float progressValue = _isScrubbing ? _scrubbingPosition : _position;
        
        [_scrubberHandle.layer removeAnimationForKey:@"position"];
        CGRect handleCurrentFrame = [self sliderButtonFrameForProgress:progressValue];
        CGPoint handleCurrentPosition = CGPointMake(CGRectGetMidX(handleCurrentFrame), CGRectGetMidY(handleCurrentFrame));
        _scrubberHandle.layer.position = handleCurrentPosition;
    }
}

- (void)setDuration:(NSTimeInterval)duration currentTime:(NSTimeInterval)currentTime isPlaying:(bool)isPlaying animated:(bool)animated
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
    
    _currentTimeLabel.frame = (CGRect){{insetLeft, CGFloor((self.frame.size.height - _currentTimeLabel.frame.size.height) / 2.0f)}, _currentTimeLabel.frame.size};
    
    _durationLabel.frame = (CGRect){{self.frame.size.width - insetRight - _durationLabel.frame.size.width, CGFloor((self.frame.size.height - _durationLabel.frame.size.height) / 2.0f)}, _durationLabel.frame.size};
    
    CGFloat scrubberOriginX = CGRectGetMaxX(_currentTimeLabel.frame) + scrubberPadding;
    _scrubberBackground.frame = (CGRect){{scrubberOriginX, CGFloor((self.frame.size.height - scrubberHeight) / 2.0f) - 1.0f}, {_durationLabel.frame.origin.x - scrubberPadding - scrubberOriginX, scrubberHeight}};
    
    [_scrubberHandle.layer removeAnimationForKey:@"position"];
    _scrubberHandle.frame = [self sliderButtonFrameForProgress:_position];
    [self updatePositionAnimations:false];
}

@end
