#import "TGPhotoEditorGenericToolView.h"

#import "UIControl+HitTestEdgeInsets.h"
#import "TGPhotoEditorInterfaceAssets.h"

#import "TGPhotoEditorSliderView.h"

@interface TGPhotoEditorGenericToolView ()
{
    TGPhotoEditorSliderView *_sliderView;
    UILabel *_titleLabel;
    
    id<PGPhotoEditorItem> _editorItem;
    bool _showingValue;
}

@end

@implementation TGPhotoEditorGenericToolView

@synthesize valueChanged = _valueChanged;
@synthesize value = _value;
@synthesize interactionEnded = _interactionEnded;
@synthesize actualAreaSize;
@synthesize isLandscape;
@synthesize toolbarLandscapeSize;

- (instancetype)initWithEditorItem:(id<PGPhotoEditorItem>)editorItem
{
    self = [super initWithFrame:CGRectZero];
    if (self != nil)
    {
        _editorItem = editorItem;
        
        __weak TGPhotoEditorGenericToolView *weakSelf = self;
        _sliderView = [[TGPhotoEditorSliderView alloc] initWithFrame:CGRectZero];
        if (editorItem.segmented)
            _sliderView.positionsCount = (NSInteger)editorItem.maximumValue + 1;
        _sliderView.minimumValue = editorItem.minimumValue;
        _sliderView.maximumValue = editorItem.maximumValue;
        _sliderView.startValue = 0;
        if (editorItem.value != nil && [editorItem.value isKindOfClass:[NSNumber class]])
            _sliderView.value = [(NSNumber *)editorItem.value integerValue];
        _sliderView.interactionBegan = ^
        {
            __strong TGPhotoEditorGenericToolView *strongSelf = weakSelf;
            if (strongSelf != nil)
                [strongSelf showValue];
        };
        [_sliderView addTarget:self action:@selector(sliderValueChanged:) forControlEvents:UIControlEventValueChanged];
        [self addSubview:_sliderView];
        
        _titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 8, 160, 20)];
        _titleLabel.backgroundColor = [UIColor clearColor];
        _titleLabel.font = [TGPhotoEditorInterfaceAssets editorItemTitleFont];
        _titleLabel.text = [editorItem.title uppercaseString];
        _titleLabel.textAlignment = NSTextAlignmentCenter;
        _titleLabel.textColor = [TGPhotoEditorInterfaceAssets editorItemTitleColor];
        _titleLabel.userInteractionEnabled = false;
        [self addSubview:_titleLabel];
    }
    return self;
}

- (void)setInteractionEnded:(void (^)(void))interactionEnded
{
    _interactionEnded = [interactionEnded copy];

    __weak TGPhotoEditorGenericToolView *weakSelf = self;
    _sliderView.interactionEnded = ^
    {
        __strong TGPhotoEditorGenericToolView *strongSelf = weakSelf;
        if (strongSelf != nil)
        {
            [strongSelf scheduleHideValue];
            
            if (strongSelf.interactionEnded != nil)
                strongSelf.interactionEnded();
        }
    };
}

- (bool)isTracking
{
    return _sliderView.isTracking;
}

- (void)sliderValueChanged:(TGPhotoEditorSliderView *)sender
{
    NSInteger value = (NSInteger)(CGFloor(sender.value));
    if (self.valueChanged != nil)
        self.valueChanged(@(value), false);
        
    if (_showingValue)
        _titleLabel.text = [self _value];
}

- (NSString *)_value
{
    NSString *value = [_editorItem stringValue];
    if (value.length == 0)
        value = @"0.00";
    
    return value;
}

- (void)showValue
{
    [NSObject cancelPreviousPerformRequestsWithTarget:self];
    
    _showingValue = true;
    
    _titleLabel.textColor = UIColorRGB(0x4fbcff);
    _titleLabel.text = [self _value];
}

- (void)scheduleHideValue
{
    if (_editorItem.segmented)
        return;
    
    [NSObject cancelPreviousPerformRequestsWithTarget:self];
    [self performSelector:@selector(hideValue) withObject:nil afterDelay:1.0];
}

- (void)hideValue
{
    _showingValue = false;
    
    [UIView transitionWithView:_titleLabel duration:0.2 options:UIViewAnimationOptionTransitionCrossDissolve animations:^
    {
        _titleLabel.textColor = [TGPhotoEditorInterfaceAssets editorItemTitleColor];
        _titleLabel.text = [_editorItem.title uppercaseString];
    } completion:nil];
}

- (void)setValue:(id)value
{
    _value = value;
    [_sliderView setValue:[value integerValue]];
}

- (void)layoutSubviews
{
    UIInterfaceOrientation orientation = [UIApplication sharedApplication].statusBarOrientation;
    _sliderView.interfaceOrientation = orientation;
    
    if (CGRectIsEmpty(self.frame))
        return;
    
    if (!self.isLandscape)
    {
        _sliderView.frame = CGRectMake(TGPhotoEditorSliderViewMargin, (self.frame.size.height - 32) / 2, self.frame.size.width - 2 * TGPhotoEditorSliderViewMargin, 32);
        
        _titleLabel.frame = CGRectMake((self.frame.size.width - _titleLabel.frame.size.width) / 2, 8, _titleLabel.frame.size.width, _titleLabel.frame.size.height);
    }
    else
    {
        _sliderView.frame = CGRectMake((self.frame.size.width - 32) / 2, TGPhotoEditorSliderViewMargin, 32, self.frame.size.height - 2 * TGPhotoEditorSliderViewMargin);
        
        [UIView performWithoutAnimation:^
        {
            if (orientation == UIInterfaceOrientationLandscapeLeft)
            {
                _titleLabel.transform = CGAffineTransformMakeRotation(M_PI_2);
                _titleLabel.frame = CGRectMake(self.frame.size.width - _titleLabel.frame.size.width - 8, (self.frame.size.height - _titleLabel.frame.size.height) / 2, _titleLabel.frame.size.width, _titleLabel.frame.size.height);
            }
            else if (orientation == UIInterfaceOrientationLandscapeRight)
            {
                _titleLabel.transform = CGAffineTransformMakeRotation(-M_PI_2);
                _titleLabel.frame = CGRectMake(8, (self.frame.size.height - _titleLabel.frame.size.height) / 2, _titleLabel.frame.size.width, _titleLabel.frame.size.height);
            }
        }];
    }
    
    _sliderView.hitTestEdgeInsets = UIEdgeInsetsMake(-_sliderView.frame.origin.x, -_sliderView.frame.origin.y, -(self.frame.size.height - _sliderView.frame.origin.y - _sliderView.frame.size.height), -_sliderView.frame.origin.x);
}

- (bool)buttonPressed:(bool)__unused cancelButton
{
    return true;
}

@end
