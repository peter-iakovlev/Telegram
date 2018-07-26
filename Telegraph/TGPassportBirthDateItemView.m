#import "TGPassportBirthDateItemView.h"

@interface TGPassportBirthDateItemView ()
{
    UIDatePicker *_pickerView;
}
@end

@implementation TGPassportBirthDateItemView

- (instancetype)initWithValue:(NSDate *)date minValue:(NSDate *)minValue maxValue:(NSDate *)maxValue
{
    self = [super initWithType:TGMenuSheetItemTypeDefault];
    if (self != nil)
    {        
        _pickerView = [[UIDatePicker alloc] initWithFrame:CGRectMake(0.0f, 0.0f, self.frame.size.width, 216.0)];
        _pickerView.datePickerMode = UIDatePickerModeDate;
        if (date != nil)
            _pickerView.date = date;
        if (minValue != nil)
            _pickerView.minimumDate = minValue;
        if (maxValue != nil)
            _pickerView.maximumDate = maxValue;
        [self addSubview:_pickerView];
    }
    return self;
}

- (void)setPallete:(TGMenuSheetPallete *)pallete
{
    [super setPallete:pallete];
    
    if (iosMajorVersion() >= 7)
        [_pickerView setValue:pallete.textColor forKey:@"textColor"];
}

- (NSDate *)value
{
    return _pickerView.date;
}

- (CGFloat)preferredHeightForWidth:(CGFloat)__unused width screenHeight:(CGFloat)__unused screenHeight
{
    if ((int)screenHeight == 320)
        return 168.0f;
    
    return 216.0f;
}

- (bool)requiresDivider
{
    return true;
}

- (void)layoutSubviews
{
    _pickerView.frame = self.bounds;
}

@end
