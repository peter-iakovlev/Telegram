#import "TGPhotoEditorTintToolView.h"
#import "TGModernButton.h"

#import "TGPhotoEditorTintSwatchView.h"
#import "TGPhotoEditorSliderView.h"

#import "TGPhotoEditorInterfaceAssets.h"
#import "UIControl+HitTestEdgeInsets.h"
#import "TGImageUtils.h"

#import "PGTintTool.h"

@interface TGPhotoEditorTintToolView ()
{
    UIView *_buttonsWrapper;
    NSArray *_swatchViews;
    
    TGModernButton *_shadowsButton;
    TGModernButton *_highlightsButton;
    UILabel *_intensityTitleLabel;
    
    UIPanGestureRecognizer *_panGestureRecognizer;
    
    TGPhotoEditorSliderView *_sliderView;
 
    bool _editingHighlights;
    bool _editingIntensity;
    
    CGFloat _startIntensity;
}

@property (nonatomic, weak) PGTintTool *tintTool;

@end

@implementation TGPhotoEditorTintToolView

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
        self.backgroundColor = [UIColor redColor];
        
        _buttonsWrapper = [[UIView alloc] initWithFrame:self.bounds];
        _buttonsWrapper.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        [self addSubview:_buttonsWrapper];
        
        NSArray *colors = [self shadowsColors];
        
        NSInteger i = 0;
        NSMutableArray *swatchViews = [[NSMutableArray alloc] init];
        
        for (UIColor *color in colors)
        {
            TGPhotoEditorTintSwatchView *swatchView = [[TGPhotoEditorTintSwatchView alloc] initWithFrame:CGRectMake(0, 0, 21, 21)];
            swatchView.color = color;
            [swatchView addTarget:self action:@selector(swatchPressed:) forControlEvents:UIControlEventTouchUpInside];
            [_buttonsWrapper addSubview:swatchView];
            
            if (i == 0)
                swatchView.selected = true;
            
            [swatchViews addObject:swatchView];
            i++;
        }
        _swatchViews = swatchViews;
        
        _panGestureRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePan:)];
        [_buttonsWrapper addGestureRecognizer:_panGestureRecognizer];
        
        _sliderView = [[TGPhotoEditorSliderView alloc] initWithFrame:CGRectZero];
        _sliderView.alpha = 0.0f;
        _sliderView.hidden = true;
        _sliderView.layer.rasterizationScale = TGScreenScaling();
        _sliderView.minimumValue = editorItem.minimumValue;
        _sliderView.maximumValue = editorItem.maximumValue;
        _sliderView.startValue = 0;
        if (editorItem.value != nil && [editorItem.value isKindOfClass:[NSNumber class]])
            _sliderView.value = [(NSNumber *)editorItem.value integerValue];
        [_sliderView addTarget:self action:@selector(sliderValueChanged:) forControlEvents:UIControlEventValueChanged];
        [self addSubview:_sliderView];
        
        if ([editorItem isKindOfClass:[PGTintTool class]])
        {
            PGTintTool *tintTool = (PGTintTool *)editorItem;
            self.tintTool = tintTool;
            [self setValue:editorItem.value];
        }
        
        _intensityTitleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 8, 160, 20)];
        _intensityTitleLabel.alpha = 0.0f;
        _intensityTitleLabel.backgroundColor = [UIColor clearColor];
        _intensityTitleLabel.font = [TGPhotoEditorInterfaceAssets editorItemTitleFont];
        _intensityTitleLabel.text = [TGLocalized(@"PhotoEditor.TintIntensity") uppercaseString];
        _intensityTitleLabel.textAlignment = NSTextAlignmentCenter;
        _intensityTitleLabel.textColor = [TGPhotoEditorInterfaceAssets editorItemTitleColor];
        _intensityTitleLabel.userInteractionEnabled = false;
        _intensityTitleLabel.hidden = true;
        [self addSubview:_intensityTitleLabel];
        
        _shadowsButton = [[TGModernButton alloc] initWithFrame:CGRectMake(0, 0, 120, 20)];
        _shadowsButton.selected = true;
        _shadowsButton.backgroundColor = [UIColor clearColor];
        _shadowsButton.titleLabel.font = [TGPhotoEditorInterfaceAssets editorItemTitleFont];
        [_shadowsButton setTitle:[TGLocalized(@"PhotoEditor.ShadowsTint") uppercaseString] forState:UIControlStateNormal];
        [_shadowsButton setTitleColor:UIColorRGB(0x808080) forState:UIControlStateNormal];
        [_shadowsButton setTitleColor:[UIColor whiteColor] forState:UIControlStateSelected];
        [_shadowsButton setTitleColor:[UIColor whiteColor] forState:UIControlStateSelected | UIControlStateHighlighted];
        [_shadowsButton addTarget:self action:@selector(modeButtonPressed:) forControlEvents:UIControlEventTouchDown];
        [self addSubview:_shadowsButton];
        
        _highlightsButton = [[TGModernButton alloc] initWithFrame:CGRectMake(0, 0, 120, 20)];
        _highlightsButton.backgroundColor = [UIColor clearColor];
        _highlightsButton.titleLabel.font = [TGPhotoEditorInterfaceAssets editorItemTitleFont];
        [_highlightsButton setTitle:[TGLocalized(@"PhotoEditor.HighlightsTint") uppercaseString] forState:UIControlStateNormal];
        [_highlightsButton setTitleColor:UIColorRGB(0x808080) forState:UIControlStateNormal];
        [_highlightsButton setTitleColor:[UIColor whiteColor] forState:UIControlStateSelected];
        [_highlightsButton setTitleColor:[UIColor whiteColor] forState:UIControlStateSelected | UIControlStateHighlighted];
        [_highlightsButton addTarget:self action:@selector(modeButtonPressed:) forControlEvents:UIControlEventTouchDown];
        [self addSubview:_highlightsButton];
    }
    return self;
}

- (NSArray *)shadowsColors
{
    static dispatch_once_t onceToken;
    static NSArray *shadowColors;
    dispatch_once(&onceToken, ^
    {
        shadowColors = @[ [UIColor clearColor],
                          UIColorRGB(0xff4d4d),
                          UIColorRGB(0xf48022),
                          UIColorRGB(0xffcd00),
                          UIColorRGB(0x81d281),
                          UIColorRGB(0x71c5d6),
                          UIColorRGB(0x0072bc),
                          UIColorRGB(0x662d91) ];
    });
    return shadowColors;
}

- (NSArray *)highlightsColors
{
    static dispatch_once_t onceToken;
    static NSArray *highlightsColors;
    dispatch_once(&onceToken, ^
    {
        highlightsColors = @[ [UIColor clearColor],
                              UIColorRGB(0xef9286),
                              UIColorRGB(0xeacea2),
                              UIColorRGB(0xf2e17c),
                              UIColorRGB(0xa4edae),
                              UIColorRGB(0x89dce5),
                              UIColorRGB(0x2e8bc8),
                              UIColorRGB(0xcd98e5) ];
    });
    return highlightsColors;
}

- (void)modeButtonPressed:(TGModernButton *)sender
{
    bool editingHighlights = false;
    if (sender == _shadowsButton)
    {
        _shadowsButton.selected = true;
        _highlightsButton.selected = false;
        
        editingHighlights = false;
    }
    else if (sender == _highlightsButton)
    {
        _shadowsButton.selected = false;
        _highlightsButton.selected = true;
        
        editingHighlights = true;
    }
    
    if (editingHighlights != _editingHighlights)
    {
        _editingHighlights = editingHighlights;
        
        PGTintToolValue *value = [(PGTintToolValue *)self.value copy];
        value.editingHighlights = editingHighlights;
        
        _value = value;
        
        [self setHighlightsColors:editingHighlights];
        [self setSelectedColor:editingHighlights ? value.highlightsColor : value.shadowsColor];
        [_sliderView setValue:editingHighlights ? value.highlightsIntensity : value.shadowsIntensity];
        
        self.valueChanged(value, false);
    }
}

- (void)swatchPressed:(TGPhotoEditorTintSwatchView *)sender
{
    PGTintToolValue *value = [(PGTintToolValue *)self.value copy];
    
    for (TGPhotoEditorTintSwatchView *swatchView in _swatchViews)
    {
        bool wasSelected = swatchView.selected;
        swatchView.selected = (swatchView == sender);
        
        if (swatchView.selected)
        {
            if (wasSelected && ![swatchView.color isEqual:[UIColor clearColor]])
            {
                _editingIntensity = true;
                if (_editingHighlights)
                    _startIntensity = value.highlightsIntensity;
                else
                    _startIntensity = value.shadowsIntensity;
                
                value.editingIntensity = true;
                
                [self setIntensitySliderHidden:false animated:true completion:nil];
            }
            else
            {
                if (_editingHighlights)
                    value.highlightsColor = sender.color;
                else
                    value.shadowsColor = sender.color;
            }
            
            _value = value;
            
            if (self.valueChanged != nil)
                self.valueChanged(value, false);
        }
    }
}

- (void)handlePan:(UIPanGestureRecognizer *)gestureRecognizer
{
    CGPoint point = [gestureRecognizer locationInView:gestureRecognizer.view];
    
    for (TGPhotoEditorTintSwatchView *swatchView in _swatchViews)
    {
        if (self.frame.size.width > self.frame.size.height)
        {
            if (point.x >= swatchView.frame.origin.x && point.x <= swatchView.frame.origin.x + swatchView.frame.size.width && !swatchView.isSelected)
            {
                [self swatchPressed:swatchView];
                break;
            }
        }
        else
        {
            if (point.y >= swatchView.frame.origin.y && point.y <= swatchView.frame.origin.y + swatchView.frame.size.height && !swatchView.isSelected)
            {
                [self swatchPressed:swatchView];
                break;
            }
        }
    }
}

- (bool)buttonPressed:(bool)cancelButton
{
    if (_editingIntensity)
    {
        PGTintToolValue *value = [(PGTintToolValue *)self.value copy];
        if (cancelButton)
        {
            if (_editingHighlights)
                value.highlightsIntensity = _startIntensity;
            else
                value.shadowsIntensity = _startIntensity;
            
            _sliderView.value = _startIntensity;
        }

        value.editingIntensity = false;

        _value = value;

        if (self.valueChanged != nil)
            self.valueChanged(value, false);

        _editingIntensity = false;
        
        __weak TGPhotoEditorTintToolView *weakSelf = self;
        [self setIntensitySliderHidden:true animated:true completion:^
        {
            __strong TGPhotoEditorTintToolView *strongSelf = weakSelf;
            if (strongSelf == nil)
                return;
            
            if (cancelButton)
                strongSelf->_sliderView.value =strongSelf->_startIntensity;
        }];

        return false;
    }
    else
    {
        return true;
    }
}

- (void)setIntensitySliderHidden:(bool)hidden animated:(bool)animated completion:(void (^)(void))completion
{
    if (animated)
    {
        CGFloat buttonsDelay = hidden ? 0.07f : 0.0f;
        CGFloat sliderDelay = hidden ? 0.0f : 0.07f;
        
        CGFloat buttonsDuration = hidden ? 0.23f : 0.1f;
        CGFloat sliderDuration = hidden ? 0.1f : 0.23f;
        
        _buttonsWrapper.hidden = false;
        _shadowsButton.hidden = false;
        _highlightsButton.hidden = false;
        [UIView animateWithDuration:buttonsDuration delay:buttonsDelay options:UIViewAnimationOptionCurveLinear animations:^
        {
            _buttonsWrapper.alpha = hidden ? 1.0f : 0.0f;
            _shadowsButton.alpha = hidden ? 1.0f : 0.0f;
            _highlightsButton.alpha = hidden ? 1.0f : 0.0f;
        } completion:^(BOOL finished)
        {
            if (finished)
            {
                _buttonsWrapper.hidden = !hidden;
                _shadowsButton.hidden = !hidden;
                _highlightsButton.hidden = !hidden;
            }
        }];
        
        _sliderView.hidden = false;
        _sliderView.layer.shouldRasterize = true;
        _intensityTitleLabel.hidden = false;
        [UIView animateWithDuration:sliderDuration delay:sliderDelay options:UIViewAnimationOptionCurveLinear animations:^
        {
            _sliderView.alpha = hidden ? 0.0f : 1.0f;
            _intensityTitleLabel.alpha = hidden ? 0.0f : 1.0f;
        } completion:^(BOOL finished)
        {
            _sliderView.layer.shouldRasterize = false;
            if (finished)
            {
                _sliderView.hidden = hidden;
                _intensityTitleLabel.hidden = hidden;
            }
            
            if (completion != nil)
                completion();
        }];
    }
    else
    {
        _buttonsWrapper.hidden = !hidden;
        _buttonsWrapper.alpha = hidden ? 1.0f : 0.0f;
        _shadowsButton.hidden = !hidden;
        _shadowsButton.alpha = hidden ? 1.0f : 0.0f;
        _highlightsButton.hidden = !hidden;
        _highlightsButton.alpha = hidden ? 1.0f : 0.0f;
        
        _sliderView.hidden = hidden;
        _sliderView.alpha = hidden ? 0.0f : 1.0f;
        _intensityTitleLabel.hidden = hidden;
        _intensityTitleLabel.alpha = hidden ? 0.0f : 1.0f;
        
        if (completion != nil)
            completion();
    }
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
    PGTintToolValue *value = [(PGTintToolValue *)self.value copy];
    
    NSInteger newValue = (NSInteger)(CGFloor(sender.value));
    if (_editingHighlights)
        value.highlightsIntensity = newValue;
    else
        value.shadowsIntensity = newValue;
    
    _value = value;
    
    if (self.valueChanged != nil)
        self.valueChanged(value, false);
}

- (bool)hideTitle
{
    return true;
}

- (void)setValue:(id)value
{
    if (![value isKindOfClass:[PGTintToolValue class]])
        return;
    
    _value = value;
    
    PGTintToolValue *tintValue = (PGTintToolValue *)value;
    
    if (tintValue.editingHighlights != _editingHighlights)
    {
        _editingHighlights = tintValue.editingHighlights;
        _shadowsButton.selected = !_editingHighlights;
        _highlightsButton.selected = _editingHighlights;
        
        [self setHighlightsColors:_editingHighlights];
    }
    
    if (tintValue.editingIntensity != _editingIntensity)
    {
        _editingIntensity = tintValue.editingIntensity;
        [self setIntensitySliderHidden:!_editingIntensity animated:false completion:nil];
    }
    
    if (_editingHighlights)
    {
        [_sliderView setValue:tintValue.highlightsIntensity];
        [self setSelectedColor:tintValue.highlightsColor];
    }
    else
    {
        [_sliderView setValue:tintValue.shadowsIntensity];
        [self setSelectedColor:tintValue.shadowsColor];
    }
}

- (void)setHighlightsColors:(bool)highlightsColors
{
    NSArray *colors = nil;
    if (highlightsColors)
        colors = [self highlightsColors];
    else
        colors = [self shadowsColors];
    
    NSInteger i = 0;
    for (TGPhotoEditorTintSwatchView *swatchView in _swatchViews)
    {
        swatchView.color = colors[i];
        i++;
    }
}

- (void)setSelectedColor:(UIColor *)color
{
    for (TGPhotoEditorTintSwatchView *swatchView in _swatchViews)
        swatchView.selected = [swatchView.color isEqual:color];
}

- (void)layoutSubviews
{
    UIInterfaceOrientation orientation = [UIApplication sharedApplication].statusBarOrientation;
    _sliderView.interfaceOrientation = orientation;
    
    if (CGRectIsEmpty(self.frame))
        return;
    
    if (!self.isLandscape)
    {
        CGFloat leftEdge = 30;
        CGFloat spacing = (self.frame.size.width - leftEdge * 2 - 21 * _swatchViews.count) / (_swatchViews.count - 1);
        NSInteger i = 0;
        
        for (UIView *view in _swatchViews)
        {
            view.frame = CGRectMake(leftEdge + (view.frame.size.width + spacing) * i, 51, view.frame.size.width, view.frame.size.height);
            i++;
        }
        
        _sliderView.frame = CGRectMake(TGPhotoEditorSliderViewMargin, (self.frame.size.height - 32) / 2, self.frame.size.width - 2 * TGPhotoEditorSliderViewMargin, 32);
        
        _intensityTitleLabel.frame = CGRectMake((self.frame.size.width - _intensityTitleLabel.frame.size.width) / 2, 8, _intensityTitleLabel.frame.size.width, _intensityTitleLabel.frame.size.height);
        
        _shadowsButton.frame = CGRectMake(floor(self.frame.size.width / 4 - _shadowsButton.frame.size.width / 2 + 20), 8, _shadowsButton.frame.size.width, _shadowsButton.frame.size.height);
        
        _highlightsButton.frame = CGRectMake(floor(self.frame.size.width / 4 * 3 - _highlightsButton.frame.size.width / 2 - 20), 8, _highlightsButton.frame.size.width, _highlightsButton.frame.size.height);
    }
    else
    {
        CGFloat topEdge = 30;
        CGFloat spacing = (self.frame.size.height - 30 * 2 - 21 * _swatchViews.count) / (_swatchViews.count - 1);
        
        _sliderView.frame = CGRectMake((self.frame.size.width - 32) / 2, TGPhotoEditorSliderViewMargin, 32, self.frame.size.height - 2 * TGPhotoEditorSliderViewMargin);
        
        CGFloat swatchOffset = 0;
        
        if (orientation == UIInterfaceOrientationLandscapeLeft)
        {
            swatchOffset = self.frame.size.width - 51 - 21;
            
            [UIView performWithoutAnimation:^
            {
                _intensityTitleLabel.transform = CGAffineTransformMakeRotation(M_PI_2);
                _shadowsButton.transform = CGAffineTransformMakeRotation(M_PI_2);
                _highlightsButton.transform = CGAffineTransformMakeRotation(M_PI_2);
                
                _intensityTitleLabel.frame = CGRectMake(self.frame.size.width - _intensityTitleLabel.frame.size.width - 8, (self.frame.size.height - _intensityTitleLabel.frame.size.height) / 2, _intensityTitleLabel.frame.size.width, _intensityTitleLabel.frame.size.height);

                _shadowsButton.frame = CGRectMake(self.frame.size.width - _shadowsButton.frame.size.width - 8, floor(self.frame.size.height / 4 - _shadowsButton.frame.size.height / 2 + 20), _shadowsButton.frame.size.width, _shadowsButton.frame.size.height);
                
                _highlightsButton.frame = CGRectMake(self.frame.size.width - _highlightsButton.frame.size.width - 8, floor(self.frame.size.height / 4 * 3 - _highlightsButton.frame.size.height / 2 - 20), _highlightsButton.frame.size.width, _highlightsButton.frame.size.height);
            }];
        }
        else if (orientation == UIInterfaceOrientationLandscapeRight)
        {
            swatchOffset = 51;
            
            [UIView performWithoutAnimation:^
            {
                _intensityTitleLabel.transform = CGAffineTransformMakeRotation(-M_PI_2);
                _shadowsButton.transform = CGAffineTransformMakeRotation(-M_PI_2);
                _highlightsButton.transform = CGAffineTransformMakeRotation(-M_PI_2);
                
                _intensityTitleLabel.frame = CGRectMake(8, (self.frame.size.height - _intensityTitleLabel.frame.size.height) / 2, _intensityTitleLabel.frame.size.width, _intensityTitleLabel.frame.size.height);
            
                _shadowsButton.frame = CGRectMake(8, floor(self.frame.size.height / 4 * 3 - _shadowsButton.frame.size.height / 2 - 20), _shadowsButton.frame.size.width, _shadowsButton.frame.size.height);
                
                _highlightsButton.frame = CGRectMake(8, floor(self.frame.size.height / 4 - _highlightsButton.frame.size.height / 2 + 20), _highlightsButton.frame.size.width, _highlightsButton.frame.size.height);
            }];
        }
        
        [UIView performWithoutAnimation:^
        {
            NSInteger i = 0;
            for (UIView *view in _swatchViews)
            {
                view.frame = CGRectMake(swatchOffset, topEdge + (view.frame.size.height + spacing) * i, view.frame.size.width, view.frame.size.height);
                i++;
            }
        }];
    }
    
    _sliderView.hitTestEdgeInsets = UIEdgeInsetsMake(-_sliderView.frame.origin.x,
                                                     -_sliderView.frame.origin.y,
                                                     -(self.frame.size.height - _sliderView.frame.origin.y - _sliderView.frame.size.height),
                                                     -_sliderView.frame.origin.x);
}

@end
