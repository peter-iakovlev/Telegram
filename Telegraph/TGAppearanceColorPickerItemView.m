#import "TGAppearanceColorPickerItemView.h"

#import "TGPresentationAssets.h"

@interface TGAppearanceColorSwatchButton : TGModernButton

@end

@interface TGAppearanceColorPickerItemView ()
{
    UILabel *_titleLabel;
    NSArray *_colorViews;
}
@end

@implementation TGAppearanceColorPickerItemView

- (instancetype)initWithCurrentColor:(UIColor *)currentColor
{
    self = [super initWithType:TGMenuSheetItemTypeDefault];
    if (self != nil)
    {
        _titleLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _titleLabel.backgroundColor = [UIColor whiteColor];
        _titleLabel.font = TGMediumSystemFontOfSize(20.0f);
        _titleLabel.text = TGLocalized(@"Appearance.PickAccentColor");
        _titleLabel.textColor = [UIColor blackColor];
        [_titleLabel sizeToFit];
        _titleLabel.userInteractionEnabled = false;
        [self addSubview:_titleLabel];
        
        NSMutableArray *colorViews = [[NSMutableArray alloc] init];
        for (UIColor *color in [TGAppearanceColorPickerItemView colors])
        {
            TGAppearanceColorSwatchButton *swatchView = [[TGAppearanceColorSwatchButton alloc] init];
            swatchView.backgroundColor = color;
            if ([color isEqual:currentColor])
            {
                swatchView.selected = true;
                
                UIImage *selectedImage = [TGPresentationAssets appearanceSwatchCheckIcon:[UIColor whiteColor]];
                [swatchView setImage:selectedImage forState:UIControlStateSelected];
                [swatchView setImage:selectedImage forState:UIControlStateSelected | UIControlStateHighlighted];
            }
            [swatchView addTarget:self action:@selector(swatchButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
            [self addSubview:swatchView];
            
            [colorViews addObject:swatchView];
        }
        _colorViews = colorViews;
    }
    return self;
}

- (void)setPallete:(TGMenuSheetPallete *)pallete
{
    [super setPallete:pallete];
    
    _titleLabel.backgroundColor = pallete.backgroundColor;
    _titleLabel.textColor = pallete.textColor;
}

- (void)swatchButtonPressed:(TGAppearanceColorSwatchButton *)sender
{
    if (self.colorSelected != nil)
        self.colorSelected(sender.backgroundColor);
}

+ (NSArray *)colors
{
    static dispatch_once_t onceToken;
    static NSArray *colors;
    dispatch_once(&onceToken, ^
    {
        colors = @
        [
         UIColorRGB(0xf83b4c), // red
         UIColorRGB(0xff7519), // orange
         UIColorRGB(0xeba239), // yellow
         UIColorRGB(0x29b327), // green
         UIColorRGB(0x00c2ed), // light blue
         UIColorRGB(0x007ee5), // blue
         UIColorRGB(0x7748ff), // purple
         UIColorRGB(0xff5da2)  // pink
        ];
    });
    return colors;
}

- (bool)requiresDivider
{
    return false;
}

- (CGFloat)preferredHeightForWidth:(CGFloat)__unused width screenHeight:(CGFloat)__unused screenHeight
{
    CGFloat margin = TGScreenPixelFloor((width - 60.0f * 4) / 5.0f);
    return 66.0f + 110.0f + margin * 2.0f;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    _titleLabel.frame = CGRectMake(floor((self.frame.size.width - _titleLabel.frame.size.width) / 2), 16.0f, _titleLabel.frame.size.width, _titleLabel.frame.size.height);
    
    CGFloat margin = TGScreenPixelFloor((self.frame.size.width - 60.0f * 4) / 5.0f);
    NSInteger col = 0;
    NSInteger row = 0;
    for (TGAppearanceColorSwatchButton *view in _colorViews)
    {
        if (col == 4)
        {
            col = 0;
            row = 1;
        }
        view.frame = CGRectMake(margin + (view.frame.size.width + margin) * col, 56.0f + (view.frame.size.height + margin) * row, view.frame.size.width, view.frame.size.height);
        col++;
    }
}


@end

@implementation TGAppearanceColorSwatchButton

- (instancetype)init
{
    self = [super initWithFrame:CGRectMake(0.0f, 0.0f, 60.0f, 60.0f)];
    if (self != nil)
    {
        self.layer.cornerRadius = self.frame.size.width / 2.0f;
    }
    return self;
}

@end
