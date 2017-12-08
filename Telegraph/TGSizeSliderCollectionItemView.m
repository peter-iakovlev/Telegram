#import "TGSizeSliderCollectionItemView.h"
#import <LegacyComponents/TGPhotoEditorSliderView.h>
#import <LegacyComponents/TGFont.h>

@interface TGSizeSliderCollectionItemView ()
{
    UILabel *_label;
    TGPhotoEditorSliderView *_sliderView;
    
    NSArray *_values;
}
@end

@implementation TGSizeSliderCollectionItemView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self != nil)
    {
        _values = @[ @1, @5, @10, @50, @100, @300, @500, @4096 ];
        
        _label = [[UILabel alloc] init];
        _label.font = TGSystemFontOfSize(17.0f);
        _label.textColor = [UIColor blackColor];
        _label.textAlignment = NSTextAlignmentCenter;
        [self addSubview:_label];
        
        static UIImage *knobViewImage = nil;
        static dispatch_once_t onceToken;
        dispatch_once(&onceToken, ^
        {
            UIGraphicsBeginImageContextWithOptions(CGSizeMake(40.0f, 40.0f), false, 0.0f);
            CGContextRef context = UIGraphicsGetCurrentContext();
            CGContextSetShadowWithColor(context, CGSizeMake(0, 1.5f), 3.5f, [UIColor colorWithWhite:0.0f alpha:0.25f].CGColor);
            CGContextSetFillColorWithColor(context, [UIColor whiteColor].CGColor);
            CGContextFillEllipseInRect(context, CGRectMake(6.0f, 6.0f, 28.0f, 28.0f));
            knobViewImage = UIGraphicsGetImageFromCurrentImageContext();
            UIGraphicsEndImageContext();
        });
        
        _sliderView = [[TGPhotoEditorSliderView alloc] init];
        _sliderView.backgroundColor = [UIColor whiteColor];
        _sliderView.knobImage = knobViewImage;
        _sliderView.trackCornerRadius = 1.0f;
        _sliderView.trackColor = TGAccentColor();
        _sliderView.backColor = UIColorRGB(0xb7b7b7);
        _sliderView.lineSize = 2.0f;
        _sliderView.dotSize = 5.0f;
        _sliderView.minimumValue = 0.0f;
        _sliderView.maximumValue = 7.0f;
        _sliderView.startValue = 0.0f;
        _sliderView.value = 0;
        _sliderView.positionsCount = 8;
        [_sliderView addTarget:self action:@selector(sliderValueChanged:) forControlEvents:UIControlEventValueChanged];
        [self addSubview:_sliderView];
    }
    return self;
}

- (void)setValue:(int32_t)value
{
    NSInteger i = 0;
    for (NSNumber *nValue in _values)
    {
        if (nValue.int32Value == value)
            break;
        
        i++;
    }
    
    _sliderView.value = i;
    [self updateLabel];
}

- (void)sliderValueChanged:(TGPhotoEditorSliderView *)sender
{
    if (self.valueChanged != nil)
        self.valueChanged([_values[(int)sender.value] int32Value]);
    [self updateLabel];
}

- (void)updateLabel
{
    int32_t limit = [_values[(int)_sliderView.value] int32Value];
    
    NSString *string = nil;
    if (limit == 4096)
        string = TGLocalized(@"AutoDownloadSettings.Unlimited");
    else
        string = [[NSString alloc] initWithFormat:TGLocalized(@"AutoDownloadSettings.UpTo"), [NSString stringWithFormat:@"%d MB", limit]];
    
    _label.text = string;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    _label.frame = CGRectMake(0.0f, 14.0f, self.frame.size.width, 20.0f);
    _sliderView.frame = CGRectMake(15.0f, 34.0f, self.frame.size.width - 30.0f, 44.0f);
}

@end
