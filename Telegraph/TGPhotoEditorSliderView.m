#import "TGPhotoEditorSliderView.h"

#import "TGPhotoEditorInterfaceAssets.h"

const CGFloat TGPhotoEditorSliderViewLineSize = 3.0f;
const CGFloat TGPhotoEditorSliderViewMargin = 15.0f;
const CGFloat TGPhotoEditorSliderViewInternalMargin = 14.0f / 2.0f;

@interface TGPhotoEditorSliderView ()
{
    UIImageView *_knobView;
    
    CGFloat _knobTouchStart;
    
    CGFloat _knobTouchCenterStart;
    CGFloat _knobDragCenter;
    
    UIPanGestureRecognizer *_panGestureRecognizer;
    UITapGestureRecognizer *_tapGestureRecognizer;
    
    UIColor *_backColor;
    UIColor *_trackColor;
    UIColor *_startColor;
    
    bool _startHidden;
    
    UISelectionFeedbackGenerator *_feedbackGenerator;
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
        
        _lineSize = TGPhotoEditorSliderViewLineSize;
        _knobPadding = TGPhotoEditorSliderViewInternalMargin;
        
        _backColor = [TGPhotoEditorInterfaceAssets sliderBackColor];
        _trackColor = [TGPhotoEditorInterfaceAssets sliderTrackColor];
        _startColor = [TGPhotoEditorInterfaceAssets sliderTrackColor];
        
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
        
        _knobView = [[UIImageView alloc] initWithFrame:CGRectZero];
        _knobView.image = knobViewImage;
        [self addSubview:_knobView];
        
        _panGestureRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePan:)];
        [self addGestureRecognizer:_panGestureRecognizer];
        
        _tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTap:)];
        _tapGestureRecognizer.enabled = false;
        [self addGestureRecognizer:_tapGestureRecognizer];
        
        if (iosMajorVersion() >= 10)
            _feedbackGenerator = [[UISelectionFeedbackGenerator alloc] init];
    }
    return self;
}

#pragma mark -

- (void)setPositionsCount:(NSInteger)positionsCount
{
    _positionsCount = positionsCount;
    _tapGestureRecognizer.enabled = _positionsCount > 1;
}

- (void)drawRect:(CGRect)__unused rect
{
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGFloat margin = TGPhotoEditorSliderViewInternalMargin;
    CGFloat totalLength = self.frame.size.width - margin * 2;
    CGFloat sideLength = self.frame.size.height;
    bool vertical = false;
    if (self.frame.size.width < self.frame.size.height)
    {
        totalLength = self.frame.size.height - margin * 2;
        sideLength = self.frame.size.width;
        vertical = true;
    }
    
    CGFloat knobPosition = _knobPadding + (_knobView.highlighted ? _knobDragCenter : [self centerPositionForValue:_value totalLength:totalLength knobSize:_knobView.image.size.width vertical:vertical]);
    knobPosition = MAX(_knobPadding, MIN(knobPosition, _knobPadding + totalLength));
    
    CGFloat startPosition = margin + totalLength / (_maximumValue - _minimumValue) * (ABS(_minimumValue) + _startValue);
    if (vertical)
        startPosition = 2 * margin + totalLength - startPosition;
    
    CGFloat origin = startPosition;
    CGFloat track = knobPosition - startPosition;
    if (track < 0)
    {
        track = fabs(track);
        origin -= track;
    }
    
    CGRect backFrame = CGRectMake(margin, (sideLength - _lineSize) / 2, totalLength, _lineSize);
    CGRect trackFrame = CGRectMake(origin, (sideLength - _lineSize) / 2, track, _lineSize);
    CGRect startFrame = CGRectMake(startPosition - 2 / 2, (sideLength - 13) / 2, 2, 13);
    if (vertical)
    {
        backFrame = CGRectMake(backFrame.origin.y, backFrame.origin.x, backFrame.size.height, backFrame.size.width);
        trackFrame = CGRectMake(trackFrame.origin.y, trackFrame.origin.x, trackFrame.size.height, trackFrame.size.width);
        startFrame = CGRectMake(startFrame.origin.y, startFrame.origin.x, startFrame.size.height, startFrame.size.width);
    }
    
    CGContextSetFillColorWithColor(context, _backColor.CGColor);
    CGContextFillRect(context, backFrame);
    
    CGContextSetFillColorWithColor(context, _trackColor.CGColor);
    CGContextFillRect(context, trackFrame);
    
    if (!_startHidden)
    {
        CGContextSetFillColorWithColor(context, _startColor.CGColor);
        CGContextFillRect(context, startFrame);
    }
    
    if (self.positionsCount > 1)
    {
        for (NSInteger i = 0; i < self.positionsCount; i++)
        {
            CGContextSetBlendMode(context, kCGBlendModeClear);
            CGContextSetFillColorWithColor(context, [UIColor clearColor].CGColor);
            
            CGRect dotRect = CGRectMake(totalLength / (self.positionsCount - 1) * i, (sideLength - 13.5f) / 2, 13.5f, 13.5f);
            if (vertical)
                dotRect = CGRectMake(dotRect.origin.y, dotRect.origin.x, dotRect.size.height, dotRect.size.width);
            
            CGContextFillEllipseInRect(context, dotRect);
            
            dotRect = CGRectInset(dotRect, 1.5f, 1.5f);
        
            CGContextSetBlendMode(context, kCGBlendModeNormal);
            bool highlighted = CGRectGetMidX(dotRect) < CGRectGetMaxX(trackFrame);
            if (vertical)
                highlighted = CGRectGetMidY(dotRect) > CGRectGetMinY(trackFrame);
            
            CGContextSetFillColorWithColor(context, highlighted ? _trackColor.CGColor : _backColor.CGColor);
            CGContextFillEllipseInRect(context, dotRect);
        }
    }
}

#pragma mark -

- (void)setLineSize:(CGFloat)lineSize
{
    _lineSize = lineSize;
    [self setNeedsLayout];
}

- (UIColor *)backColor
{
    return _backColor;
}

- (void)setBackColor:(UIColor *)backColor
{
    _backColor = backColor;
}

- (UIColor *)trackColor
{
    return _trackColor;
}

- (void)setTrackColor:(UIColor *)trackColor
{
    _trackColor = trackColor;
}

- (UIImage *)knobImage
{
    return _knobView.image;
}

- (void)setKnobImage:(UIImage *)knobImage
{
    _knobView.image = knobImage;
    [self setNeedsLayout];
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
        _startHidden = true;

    [self setNeedsLayout];
}

- (void)layoutSubviews
{
    if (CGRectIsEmpty(self.frame))
        return;
    
    CGFloat margin = TGPhotoEditorSliderViewInternalMargin;
    CGFloat totalLength = self.frame.size.width - margin * 2;
    CGFloat sideLength = self.frame.size.height;
    bool vertical = false;
    if (self.frame.size.width < self.frame.size.height)
    {
        totalLength = self.frame.size.height - margin * 2;
        sideLength = self.frame.size.width;
        vertical = true;
    }
    
    CGFloat knobPosition = _knobPadding + (_knobView.highlighted ? _knobDragCenter : [self centerPositionForValue:_value totalLength:totalLength knobSize:_knobView.image.size.width vertical:vertical]);
    knobPosition = MAX(_knobPadding, MIN(knobPosition, _knobPadding + totalLength));
    
    CGRect knobViewFrame = CGRectMake(knobPosition - _knobView.image.size.width / 2, (sideLength - _knobView.image.size.height) / 2, _knobView.image.size.width, _knobView.image.size.height);
    
    if (self.frame.size.width > self.frame.size.height)
        _knobView.frame = knobViewFrame;
    else
        _knobView.frame = CGRectMake(knobViewFrame.origin.y, knobViewFrame.origin.x, knobViewFrame.size.width, knobViewFrame.size.height);
    
    [self setNeedsDisplay];
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
                return ((totalLength + knob) / 2) + ((totalLength - knob) / 2) * ABS(value / edgeValue);
            else
                return ((totalLength - knob) / 2) * ABS((edgeValue - _value) / edgeValue);
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
            
            if (self.interactionBegan != nil)
                self.interactionBegan();
            
            [_feedbackGenerator prepare];
        }
        case UIGestureRecognizerStateChanged:
        {
            _knobDragCenter = _knobTouchCenterStart - _knobTouchStart - _knobPadding;
            
            CGFloat totalLength = self.frame.size.width;
            bool vertical = false;
            
            if (self.frame.size.width > self.frame.size.height)
            {
                _knobDragCenter += touchLocation.x;
            }
            else
            {
                vertical = true;
                totalLength = self.frame.size.height;
                _knobDragCenter += touchLocation.y;
            }
            totalLength -= _knobPadding * 2;
            
            CGFloat previousValue = self.value;
            if (self.positionsCount > 1)
            {
                NSInteger position = (NSInteger)round((_knobDragCenter / totalLength) * (self.positionsCount - 1));
                _knobDragCenter = position * totalLength / (self.positionsCount - 1);
            }
            
            [self setValue:[self valueForCenterPosition:_knobDragCenter totalLength:totalLength knobSize:_knobView.image.size.width vertical:vertical]];
            if (previousValue != self.value && (self.positionsCount > 1 || self.value == self.minimumValue || self.value == self.maximumValue || (self.minimumValue != self.startValue && self.value == self.startValue)))
            {
                [_feedbackGenerator selectionChanged];
                [_feedbackGenerator prepare];
            }
            
            [self setNeedsLayout];
            [self sendActionsForControlEvents:UIControlEventValueChanged];
        }
            break;
            
        case UIGestureRecognizerStateEnded:
        case UIGestureRecognizerStateCancelled:
        {
            _knobView.highlighted = false;
            
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

- (void)handleTap:(UITapGestureRecognizer *)gestureRecognizer
{
    CGPoint touchLocation = [gestureRecognizer locationInView:self];
    CGFloat totalLength = self.frame.size.width;
    CGFloat location = touchLocation.x;
    
    if (self.frame.size.width < self.frame.size.height)
    {
        totalLength = self.frame.size.height;
        location = touchLocation.y;
    }
    
    CGFloat position = ((location / totalLength) * (self.positionsCount - 1));
    CGFloat previousPosition = MAX(0, floor(position));
    CGFloat nextPosition = MIN(self.positionsCount - 1, ceil(position));
    
    bool changed = false;
    if (fabs(position - previousPosition) < 0.3f)
    {
        [self setValue:previousPosition];
        changed = true;
    }
    else if (fabs(position - nextPosition) < 0.3f)
    {
        [self setValue:nextPosition];
        changed = true;
    }
    
    if (changed)
    {
        if (self.interactionBegan != nil)
            self.interactionBegan();
        
        [self setNeedsLayout];
        [self sendActionsForControlEvents:UIControlEventValueChanged];
        
        if (self.interactionEnded != nil)
            self.interactionEnded();
        
        [_feedbackGenerator selectionChanged];
        [_feedbackGenerator prepare];
    }
}

@end
