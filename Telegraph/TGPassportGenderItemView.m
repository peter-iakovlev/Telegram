#import "TGPassportGenderItemView.h"

#import <LegacyComponents/TGMenuSheetController.h>

@interface TGPassportGenderPickerView : UIPickerView

@property (nonatomic, strong) UIColor *selectorColor;

@end


@interface TGPassportGenderItemView () <UIPickerViewDataSource, UIPickerViewDelegate>
{
    bool _dark;
    NSArray *_genderValues;
    
    TGPassportGenderPickerView *_pickerView;
}
@end

@implementation TGPassportGenderItemView

- (instancetype)initWithValue:(NSNumber *)value
{
    self = [super initWithType:TGMenuSheetItemTypeDefault];
    if (self != nil)
    {
        _genderValues = @[ @" ", TGLocalized(@"Passport.Identity.GenderMale"), TGLocalized(@"Passport.Identity.GenderFemale") ];
     
        NSInteger selectedRow = 0;
        if (value != nil)
            selectedRow = value.integerValue;
        
        _pickerView = [[TGPassportGenderPickerView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, self.frame.size.width, 216.0)];
        _pickerView.dataSource = self;
        _pickerView.delegate = self;
        [self addSubview:_pickerView];
        
        [_pickerView selectRow:selectedRow inComponent:0 animated:false];
    }
    return self;
}

- (void)setPallete:(TGMenuSheetPallete *)pallete
{
    [super setPallete:pallete];
    
    if (pallete.isDark)
        _dark = true;
}

- (NSNumber *)value
{
    NSInteger row = [_pickerView selectedRowInComponent:0];
    if (row == 0)
        return nil;
    
    return @(row);
}

- (void)setDark
{
    _dark = true;
    _pickerView.selectorColor = UIColorRGBA(0xffffff, 0.18f);
}

- (CGFloat)preferredHeightForWidth:(CGFloat)__unused width screenHeight:(CGFloat)__unused screenHeight
{
    return 150.0f;
}

- (bool)requiresDivider
{
    return true;
}

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)__unused pickerView
{
    return 1;
}

- (NSInteger)pickerView:(UIPickerView *)__unused pickerView numberOfRowsInComponent:(NSInteger)__unused component
{
    return _genderValues.count;
}

- (NSString *)pickerView:(UIPickerView *)__unused pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)__unused component
{
    return _genderValues[row];
}

- (NSAttributedString *)pickerView:(UIPickerView *)__unused pickerView attributedTitleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    return [[NSAttributedString alloc] initWithString:_genderValues[row] attributes:@{NSForegroundColorAttributeName: _dark ? [UIColor whiteColor] : [UIColor blackColor]}];
}

- (void)layoutSubviews
{
    _pickerView.frame = self.bounds;
}

@end


@implementation TGPassportGenderPickerView

- (void)didAddSubview:(UIView *)subview
{
    [super didAddSubview:subview];
    if (self.selectorColor == nil)
        return;
    
    if (subview.bounds.size.height <= 1.0)
        subview.backgroundColor = self.selectorColor;
}


- (void)didMoveToWindow
{
    [super didMoveToWindow];
    if (self.selectorColor == nil)
        return;
    
    for (UIView *subview in self.subviews)
    {
        if (subview.bounds.size.height <= 1.0)
            subview.backgroundColor = self.selectorColor;
    }
}

@end

