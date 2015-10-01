#import "TGPhotoEditorGenericToolView.h"

#import "UIControl+HitTestEdgeInsets.h"
#import "TGPhotoEditorSliderView.h"

@interface TGPhotoEditorGenericToolView ()
{
    TGPhotoEditorSliderView *_sliderView;
}

@end

@implementation TGPhotoEditorGenericToolView

@synthesize titleChanged = _titleChanged;
@synthesize valueChanged = _valueChanged;
@synthesize value = _value;
@dynamic interactionEnded;
@synthesize actualAreaSize;
@synthesize isLandscape;
@synthesize toolbarLandscapeSize;

- (instancetype)initWithEditorItem:(id<PGPhotoEditorItem>)editorItem
{
    self = [super initWithFrame:CGRectZero];
    if (self != nil)
    {
        _sliderView = [[TGPhotoEditorSliderView alloc] initWithFrame:CGRectZero];
        _sliderView.minimumValue = editorItem.minimumValue;
        _sliderView.maximumValue = editorItem.maximumValue;
        _sliderView.startValue = 0;
        if (editorItem.value != nil && [editorItem.value isKindOfClass:[NSNumber class]])
            _sliderView.value = [(NSNumber *)editorItem.value integerValue];
        [_sliderView addTarget:self action:@selector(sliderValueChanged:) forControlEvents:UIControlEventValueChanged];
        [self addSubview:_sliderView];
    }
    return self;
}

- (void)setInteractionEnded:(void (^)(void))interactionEnded
{
    _sliderView.interactionEnded = interactionEnded;
}

- (bool)isTracking
{
    return _sliderView.isTracking;
}

- (void)sliderValueChanged:(TGPhotoEditorSliderView *)sender
{
    dispatch_async(dispatch_get_main_queue(), ^
    {
        NSInteger value = (NSInteger)(CGFloor(sender.value));
        if (self.valueChanged != nil)
            self.valueChanged(@(value), false);
    });
}

- (void)setValue:(id)value
{
    _value = value;
    [_sliderView setValue:[value integerValue]];
}

- (bool)hideTitle
{
    return false;
}

- (void)layoutSubviews
{
    _sliderView.interfaceOrientation = [UIApplication sharedApplication].statusBarOrientation;
    
    if (self.frame.size.width > self.frame.size.height)
    {
        _sliderView.frame = CGRectMake(TGPhotoEditorSliderViewMargin, (self.frame.size.height - 32) / 2, self.frame.size.width - 2 * TGPhotoEditorSliderViewMargin, 32);
    }
    else
    {
        _sliderView.frame = CGRectMake((self.frame.size.width - 32) / 2, TGPhotoEditorSliderViewMargin, 32, self.frame.size.height - 2 * TGPhotoEditorSliderViewMargin);
    }
    
    _sliderView.hitTestEdgeInsets = UIEdgeInsetsMake(-_sliderView.frame.origin.x,
                                                     -_sliderView.frame.origin.y,
                                                     -(self.frame.size.height - _sliderView.frame.origin.y - _sliderView.frame.size.height),
                                                     -_sliderView.frame.origin.x);
}

- (bool)buttonPressed:(bool)__unused cancelButton
{
    return true;
}

@end
