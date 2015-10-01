#import "TGPhotoEditorSliderView.h"

#import "TGPhotoEditorInterfaceAssets.h"

const CGFloat TGPhotoEditorSliderViewLineSize = 3.0f;
const CGFloat TGPhotoEditorSliderViewMargin = 21.0f;

@interface TGPhotoEditorSliderView ()
{
    UIView *_backView;
    UIView *_trackView;
    UIView *_startView;
    UIImageView *_knobView;
    UILabel *_valueLabel;
    
    CGFloat _knobTouchStart;
    
    CGFloat _knobTouchCenterStart;
    CGFloat _knobDragCenter;
    
    UIPanGestureRecognizer *_panGestureRecognizer;
}
@end

@implementation TGPhotoEditorSliderView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self != nil)
    {
        _minimumValue = 0.0f;
        _maximumValue = 1.0f;
        _startValue = 0.0f;
        _value = _startValue;
        
        _backView = [[UIView alloc] initWithFrame:CGRectZero];
        _backView.backgroundColor = [TGPhotoEditorInterfaceAssets sliderBackColor];
        [self addSubview:_backView];
        
        _trackView = [[UIView alloc] initWithFrame:CGRectZero];
        _trackView.backgroundColor = [TGPhotoEditorInterfaceAssets sliderTrackColor];
        [self addSubview:_trackView];
        
        static UIImage *knobViewImage = nil;
        static dispatch_once_t onceToken;
        dispatch_once(&onceToken, ^
        {
            UIGraphicsBeginImageContextWithOptions(CGSizeMake(21.0f, 21.0f), false, 0.0f);
            CGContextRef context = UIGraphicsGetCurrentContext();
            CGContextSetShadowWithColor(context, CGSizeMake(0, 0.5f), 1.5f, [UIColor colorWithWhite:0.0f alpha:0.5f].CGColor);
            CGContextSetFillColorWithColor(context, [UIColor whiteColor].CGColor);
            CGContextFillEllipseInRect(context, CGRectMake(2.0f, 2.0f, 17.0f, 17.0f));
            knobViewImage = UIGraphicsGetImageFromCurrentImageContext();
            UIGraphicsEndImageContext();
        });
        
        _startView = [[UIView alloc] initWithFrame:CGRectZero];
        _startView.backgroundColor = [TGPhotoEditorInterfaceAssets sliderTrackColor];
        [self addSubview:_startView];
        
        _knobView = [[UIImageView alloc] initWithFrame:CGRectZero];
        _knobView.image = knobViewImage;
        [self addSubview:_knobView];
        
        _valueLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _valueLabel.backgroundColor = [UIColor clearColor];
        _valueLabel.font = [TGFont systemFontOfSize:13];
        _valueLabel.textAlignment = NSTextAlignmentCenter;
        _valueLabel.textColor = UIColorRGB(0x4fbcff);
        [self addSubview:_valueLabel];
        
        _panGestureRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePan:)];
        [self addGestureRecognizer:_panGestureRecognizer];
    }
    return self;
}

#pragma mark - Properties

- (bool)isTracking
{
    return _knobView.highlighted;
}

- (void)setValue:(CGFloat)value
{
    [self setValue:value animated:NO];
}

- (void)setValue:(CGFloat)value animated:(BOOL)__unused animated
{
    _value = MIN(MAX(value, _minimumValue), _maximumValue);
    [self setNeedsLayout];
}

- (void)setStartValue:(CGFloat)startValue
{
    _startValue = startValue;
    if (ABS(_startValue - _minimumValue) < FLT_EPSILON)
        _startView.hidden = true;
    [self setNeedsLayout];
}

- (void)layoutSubviews
{
    if (CGRectIsEmpty(self.frame))
        return;
    
    CGFloat totalLength = self.frame.size.width;
    CGFloat sideLength = self.frame.size.height;
    bool vertical = false;
    if (self.frame.size.width < self.frame.size.height)
    {
        totalLength = self.frame.size.height;
        sideLength = self.frame.size.width;
        vertical = true;
    }
    
    CGFloat knobPosition = _knobView.highlighted ? _knobDragCenter : [self centerPositionForValue:_value totalLength:totalLength knobSize:_knobView.image.size.width vertical:vertical];
    knobPosition = MAX(0, MIN(knobPosition, totalLength));
    CGFloat startPosition = totalLength / (_maximumValue - _minimumValue) * (ABS(_minimumValue) + _startValue);
    if (vertical)
        startPosition = totalLength - startPosition;
    
    CGFloat origin = startPosition;
    CGFloat track = knobPosition - startPosition;
    if (track < 0)
    {
        track = ABS(track);
        origin -= track;
    }
    
    CGRect trackViewFrame = CGRectMake(origin, (sideLength - TGPhotoEditorSliderViewLineSize) / 2, track, TGPhotoEditorSliderViewLineSize);
    
    CGRect knobViewFrame = CGRectMake(knobPosition - _knobView.image.size.width / 2,
                                      (sideLength - _knobView.image.size.height) / 2,
                                      _knobView.image.size.width,
                                      _knobView.image.size.height);
    
    if (self.frame.size.width > self.frame.size.height)
    {
        _backView.frame = CGRectMake(0, (sideLength - TGPhotoEditorSliderViewLineSize) / 2, totalLength, TGPhotoEditorSliderViewLineSize);
        _trackView.frame = trackViewFrame;
        _knobView.frame = knobViewFrame;
        _startView.frame = CGRectMake(startPosition - 2 / 2, (self.frame.size.height - 13) / 2, 2, 13);
        _valueLabel.frame = CGRectMake(_knobView.center.x - 20 - 2, 34, 40, 20);
    }
    else
    {
        _backView.frame = CGRectMake((sideLength - TGPhotoEditorSliderViewLineSize) / 2, 0, TGPhotoEditorSliderViewLineSize, totalLength);
        _trackView.frame = CGRectMake(trackViewFrame.origin.y, trackViewFrame.origin.x, trackViewFrame.size.height, trackViewFrame.size.width);
        _knobView.frame = CGRectMake(knobViewFrame.origin.y, knobViewFrame.origin.x, knobViewFrame.size.width, knobViewFrame.size.height);
        _startView.frame = CGRectMake((self.frame.size.width - 13) / 2, startPosition - 2 / 2, 13, 2);
        if (self.interfaceOrientation == UIInterfaceOrientationLandscapeLeft)
            _valueLabel.frame = CGRectMake(-32, _knobView.center.y - 10 - 1.5f, 40, 20);
        else
            _valueLabel.frame = CGRectMake(24, _knobView.center.y - 10 - 1.5f, 40, 20);
    }
    
    _valueLabel.text = [self _dotStringValue];
    _valueLabel.hidden = (CGFloor(ABS(self.value)) == 0);
}

- (NSString *)_dotStringValue
{
    if (self.value >= 0)
        return [NSString stringWithFormat:@"+%0.2f", CGFloor(self.value) / ABS(self.maximumValue)];
    else
        return [NSString stringWithFormat:@"%0.2f", CGFloor(self.value) / ABS(self.minimumValue)];
}

#pragma mark -

- (CGFloat)centerPositionForValue:(CGFloat)value totalLength:(CGFloat)totalLength knobSize:(CGFloat)knobSize vertical:(bool)vertical
{
    if (_minimumValue < 0)
    {
        CGFloat knob = knobSize;
        if ((NSInteger)value == 0)
        {
            return totalLength / 2;
        }
        else
        {
            CGFloat edgeValue = (value > 0 ? _maximumValue : _minimumValue);
            if ((value < 0 && vertical) || (value > 0 && !vertical))
            {
                return ((totalLength + knob) / 2) + ((totalLength - knob) / 2) * ABS(value / edgeValue);
            }
            else
            {
                return ((totalLength - knob) / 2) * ABS((edgeValue - _value) / edgeValue);
            }
        }
    }

    CGFloat position = totalLength / (_maximumValue - _minimumValue) * (ABS(_minimumValue) + value);
    if (vertical)
        position = totalLength - position;
    
    return position;
}

- (CGFloat)valueForCenterPosition:(CGFloat)position totalLength:(CGFloat)totalLength knobSize:(CGFloat)knobSize vertical:(bool)vertical
{
    CGFloat value = 0;
    if (_minimumValue < 0)
    {
        CGFloat knob = knobSize;
        if (position < (totalLength - knob) / 2)
        {
            CGFloat edgeValue = _minimumValue;
            if (vertical)
            {
                edgeValue = _maximumValue;
                position *= -1;
            }

            value = edgeValue + position / ((totalLength - knob) / 2) * ABS(edgeValue);
        }
        else if (position >= (totalLength - knob) / 2 && position <= (totalLength + knob) / 2)
        {
            value = 0;
        }
        else if (position > (totalLength + knob) / 2)
        {
            CGFloat edgeValue = (vertical ? _minimumValue : _maximumValue);
            value = (position - ((totalLength + knob) / 2)) / ((totalLength - knob) / 2) * edgeValue;
        }
    }
    else
    {
        value = _minimumValue + (!vertical ? position : (totalLength - position)) / totalLength * (_maximumValue - _minimumValue);
    }
    
    return MIN(MAX(value, _minimumValue), _maximumValue);
}

#pragma mark - Touch Handling

- (void)handlePan:(UIPanGestureRecognizer *)gestureRecognizer
{
    CGPoint touchLocation = [gestureRecognizer locationInView:self];
    CGPoint touchVelocity = [gestureRecognizer velocityInView:self];
    
    switch (gestureRecognizer.state)
    {
        case UIGestureRecognizerStateBegan:
        {
            _knobView.highlighted = true;
            
            if (self.frame.size.width > self.frame.size.height)
            {
                _knobTouchCenterStart = _knobView.center.x;
                _knobTouchStart = _knobDragCenter = touchLocation.x;
            }
            else
            {
                _knobTouchCenterStart = _knobView.center.y;
                _knobTouchStart = _knobDragCenter = touchLocation.y;
            }
        }
        case UIGestureRecognizerStateChanged:
        {
            CGFloat value = 0;
            if (self.frame.size.width > self.frame.size.height)
            {
                _knobDragCenter =_knobTouchCenterStart + touchLocation.x - _knobTouchStart;
                value = [self valueForCenterPosition:_knobDragCenter totalLength:self.frame.size.width knobSize:_knobView.image.size.width vertical:false];
            }
            else
            {
                _knobDragCenter =_knobTouchCenterStart + touchLocation.y - _knobTouchStart;
                value = [self valueForCenterPosition:_knobDragCenter totalLength:self.frame.size.height knobSize:_knobView.image.size.width vertical:true];
            }
            
            [self setValue:value];
            
            [self setNeedsLayout];
            [self sendActionsForControlEvents:UIControlEventValueChanged];
        }
            break;
            
        case UIGestureRecognizerStateEnded:
        case UIGestureRecognizerStateCancelled:
        {
            _knobView.highlighted = false;
            
            if (self.frame.size.width > self.frame.size.height)
            {
                if (ABS(touchVelocity.x) > 100)
                {
                    
                }
            }
            else
            {
                if (ABS(touchVelocity.y) > 100)
                {
                    
                }
            }
            
            [self sendActionsForControlEvents:UIControlEventValueChanged];
            [self setNeedsLayout];
            
            if (self.interactionEnded != nil)
                self.interactionEnded();
        }
            break;
            
        default:
            break;
    }
}

@end
